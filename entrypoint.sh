#!/bin/sh

sphinx-autobuild --host 0.0.0.0 --port 80 docs docs/_build/html &

uvicorn app.main:app --host 0.0.0.0 --port 8080
