#!/usr/bin/env bash
set -euo pipefail
subprocess.run(["git","-C",WORK,"add","."],capture_output=True)
subprocess.run(["git","-C",WORK,"commit","-m",f"Jarvis auto-update {time.ctime()}"],capture_output=True)
subprocess.run(["git","-C",WORK,"push","-u","origin","main"],capture_output=True)