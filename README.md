# 🕵️‍♂️ Private_i — IP Webcam → Edge AI Camera Node

**Private_i** turns an Android phone running **IP Webcam** into a tiny AI camera node.

It pulls frames from your phone (`/shot.jpg`), runs **MobileNet-SSD** locally (CPU) via OpenCV’s DNN, keeps the **latest detection summary in memory**, and serves a small **Flask dashboard** with live MJPEG and JSON endpoints you can embed in a portfolio or Notion.

It’s a self-contained demo of: “phone → network camera → local AI → web UI → machine-readable JSON.”

---

## What it does

- 📷 **Ingests video** from an Android IP Webcam (`CAMERA_URL` in `.env`)
- 🧠 **Runs object detection** with MobileNet-SSD (person, bottle, dog, car, etc.)
- 🗣️ **Generates an English sentence** like: `I currently see 2 people, 1 bottle.`
- 🌐 **Serves a dashboard** at `/` (Flask, single-file HTML template in `app.py`)
- 🧩 **Exposes endpoints** you can curl/screenshot:
  - `/health`
  - `/summary.json`
  - `/shot.jpg`
  - `/annotated.jpg`
  - `/video` (MJPEG — falls back to manual frames if native stream fails)
- 🧪 **Capture script** in `scripts/capture_screens.sh` to dump current images + JSON into `captures/` for your portfolio
- 🛠️ **Bootstrap scripts** to create venv, install deps, and fetch the Caffe model

---

## Repo layout

```text
Private_i-main/
├── app.py                     # Flask app + detection + HTML dashboard
├── requirements.txt           # Flask, requests, numpy, opencv-python-headless, python-dotenv
├── .env.example               # CAMERA_URL + timing + port
├── .gitignore                 # venv, .env, pycache
├── scripts/
│   ├── dev_run.sh             # create venv, install, fetch models, run app
│   ├── fetch_models.sh        # gets MobileNetSSD_deploy.{prototxt,caffemodel}
│   └── capture_screens.sh     # grabs /shot.jpg, /annotated.jpg, /summary.json → ./captures
├── models/
│   ├── MobileNetSSD_deploy.prototxt
│   └── MobileNetSSD_deploy.caffemodel
├── captures/                  # sample output from the running service
│   ├── shot.jpg
│   ├── annotated.jpg
│   └── summary.json
└── bootstrap.sh               # older scaffold script pointing to a local path

Notes from the code:

    app.py will exit if models/MobileNetSSD_deploy.* are missing — that’s why ./scripts/fetch_models.sh exists.

    Detection classes come from the standard MobileNet-SSD VOC list (person, dog, bottle, etc.).

    Everything is kept in-memory in last_summary and last_frame.

Requirements

    Python 3

    An Android phone running IP Webcam (or anything that exposes /shot.jpg)

    Ability to install OpenCV headless

    Network reachability from your machine → phone

1. Configure environment

The project already has .env.example. Make your own .env the way you like to work — with a HEREDOC:

cat <<'ENV' > .env
# Base URL of your Android IP Webcam (no trailing slash)
CAMERA_URL=http://192.168.0.42:8080

# How often (in seconds) to re-run AI on a fresh frame
ANALYZE_EVERY=2

# Flask bind
HOST=0.0.0.0
PORT=5005
ENV

Adjust the IP to whatever your phone shows in IP Webcam.
2. Install & run (dev path)

The repo already gives you the happy-path script:

./scripts/dev_run.sh

What that does (you can read it in scripts/dev_run.sh):

    cd to project root

    create .venv

    install requirements.txt

    run ./scripts/fetch_models.sh

    show your .env

    start python app.py

So after it finishes, open:

http://localhost:5005/

3. Endpoints (from app.py)

These are the routes actually defined:

    / — dashboard HTML (rendered with render_template_string(...), includes auto-refresh for the summary)

    /health — returns { ok: true, camera: "...", last_update: ... }

    /summary.json — returns the latest detection in machine-readable form:

    {
      "timestamp": 1730950000.123,
      "counts": { "person": 2, "bottle": 1 },
      "english": "I currently see 2 people, 1 bottle.",
      "camera": "http://192.168.0.42:8080"
    }

    /shot.jpg — raw current frame (from phone)

    /annotated.jpg — same frame but with boxes + labels (drawn in draw_annotations(...))

    /video — MJPEG stream; tries to proxy IP Webcam’s own stream first, then falls back to “poll shot → encode → stream”

This matches what your minimal README said, but now mapped to real code.
4. Capturing portfolio evidence

You already have captures/ with:

    shot.jpg

    annotated.jpg

    summary.json

To regenerate them from a live run:

./scripts/capture_screens.sh

That script just curls your local Flask app:

curl -fsS http://localhost:5005/shot.jpg       -o captures/shot.jpg
curl -fsS http://localhost:5005/annotated.jpg  -o captures/annotated.jpg
curl -fsS http://localhost:5005/summary.json   -o captures/summary.json

That’s good for “here’s the output of my AI cam node” in a portfolio.
5. Model fetching

app.py refuses to start if the model isn’t present:

if not (os.path.exists(PTX_PATH) and os.path.exists(CAFFEM_PATH)):
    raise SystemExit("[!] Missing model files. Run: ./scripts/fetch_models.sh")

So if you move this project or clone it somewhere clean, run:

./scripts/fetch_models.sh

That downloads:

    models/MobileNetSSD_deploy.prototxt

    models/MobileNetSSD_deploy.caffemodel

from GitHub (raw). The script even has a message telling you to swap to another model if GitHub blocks it.
6. How the pipeline works (from app.py)

    Frame grab

    r = requests.get(f"{CAMERA_URL}/shot.jpg", timeout=5)
    frame = cv2.imdecode(...)

    Detection (every ANALYZE_EVERY seconds in a background thread):

        build blob 300×300

        run net.forward()

        filter conf < 0.5

        store: counts + individual detections + timestamp

    Presentation

        HTML dashboard pulls /summary.json on an interval

        /annotated.jpg draws green boxes and labels

        /video tries native → fallback MJPEG

    State

        kept in memory in last_frame and last_summary

This is enough to show “live computer vision from a phone, on CPU, in Python, served over HTTP.”
7. Notes / portfolio framing

    This is a single-file Flask CV demo — perfect to show “I can glue mobile → vision → web.”

    You already included example outputs in captures/, so reviewers don’t have to run the phone.

    Because endpoints are clean (/summary.json, /annotated.jpg), this can be chained into another service (like your other pipeline projects).

8. Troubleshooting

    Blank dashboard: make sure your phone is reachable at the IP in .env, and that IP Webcam is actually running.

    Model missing: run ./scripts/fetch_models.sh

    Port already in use: change PORT= in .env

    Different camera app: as long as it gives you a JPEG at something like /shot.jpg, you can point CAMERA_URL there.

9. Requirements file (already in repo)

flask==3.0.3
requests==2.32.3
numpy==1.26.4
opencv-python-headless==4.10.0.84
python-dotenv==1.0.1

That matches what scripts/dev_run.sh will install.
10. Run it the manual way (no script)

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./scripts/fetch_models.sh
python app.py

Open: http://localhost:5005/
