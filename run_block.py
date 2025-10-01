print("Hello from python")
open("python_was_here.txt","w").write("ok")

CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY, body TEXT);
INSERT INTO notes(body) VALUES ('hi from sql');
SELECT * FROM notes;