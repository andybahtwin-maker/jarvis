# 🕵️‍♂️ Private_i — IP Webcam → Edge AI Camera Node

**Private_i** turns an Android phone running **IP Webcam** into a tiny AI camera node.

It pulls frames from your phone (`/shot.jpg`), runs **MobileNet-SSD** locally (CPU) via OpenCV’s DNN, keeps the latest detection summary in memory, and serves a small **Flask dashboard** with live MJPEG and JSON endpoints.

It’s a self-contained demo of: “phone → network camera → local AI → web UI → machine-readable JSON.”

---

## What it does

- 📷 **Pulls frames** from an Android IP Webcam (`CAMERA_URL` in `.env`)
- 🧠 **Runs object detection** with MobileNet-SSD (person, bottle, dog, car, etc.)
- 🗣️ **Generates an English sentence** like: `I currently see 2 people, 1 bottle.`
- 🌐 **Serves a dashboard** at `/` (inline HTML template in `app.py`)
- 🧩 **Exposes endpoints** you can curl/screenshot:
  - `/health`
  - `/summary.json`
  - `/shot.jpg`
  - `/annotated.jpg`
  - `/video` (MJPEG — tries the camera’s stream, then falls back to frame-by-frame)
- 🧪 **Capture script** in `scripts/capture_screens.sh` to dump current images + JSON into `captures/`
- 🛠️ **Helper scripts** to create venv, install deps, and fetch the Caffe model

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
└── bootstrap.sh               # scaffold script with a local path from your machine

Notes from the code:

    app.py will exit if models/MobileNetSSD_deploy.* are missing — that’s why ./scripts/fetch_models.sh exists.

    Detection classes come from the standard MobileNet-SSD VOC list.

    Everything is kept in memory in last_summary and last_frame.

Requirements

    Python 3

    Android phone running IP Webcam (or anything that exposes /shot.jpg)

    OpenCV headless installable

    Your machine can reach the phone over the LAN

1. Configure environment

cat <<'ENV' > .env
# Base URL of your Android IP Webcam (no trailing slash)
CAMERA_URL=http://192.168.0.42:8080

# How often (in seconds) to re-run AI on a fresh frame
ANALYZE_EVERY=2

# Flask bind
HOST=0.0.0.0
PORT=5005
ENV

Set CAMERA_URL to whatever IP Webcam shows.
2. Install & run (dev path)

./scripts/dev_run.sh

That script:

    creates .venv

    installs requirements.txt

    runs ./scripts/fetch_models.sh

    shows your .env

    starts python app.py

Then open:

http://localhost:5005/

3. Endpoints (actual from app.py)

    / — dashboard HTML

    /health — {"ok": true, "camera": "...", "last_update": <timestamp>}

    /summary.json — actual shape:

    {
      "ts": 0,
      "counts": {},
      "detections": [],
      "english": "No notable objects detected."
    }

    /shot.jpg — raw frame

    /annotated.jpg — frame with boxes + labels

    /video — MJPEG stream (tries camera stream first, then falls back)

4. Capturing portfolio evidence

./scripts/capture_screens.sh

This writes to ./captures:

    shot.jpg

    annotated.jpg

    summary.json

5. Model fetching

./scripts/fetch_models.sh

Downloads the two MobileNet-SSD files into ./models. app.py won’t start without them.
6. How it works (pipeline)

    Grab frame from CAMERA_URL/shot.jpg

    Run MobileNet-SSD via OpenCV DNN (300×300 blob, 0.5 conf)

    Store: counts, detections, timestamp

    Serve HTML + JSON + annotated images

    Background thread keeps everything fresh every ANALYZE_EVERY seconds

7. Manual run (no script)

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./scripts/fetch_models.sh
python app.py

Open http://localhost:5005/.
