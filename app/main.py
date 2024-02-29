#!/usr/bin/env python3
"""Module docstring"""
from fastapi import FastAPI
from app.ans import q_a

app = FastAPI()
VERSION = "1.0.1"


@app.get("/")
async def read_root():
    """function root"""
    return {"msg": "Hello world!!!"}


@app.get("/name/{name}")
async def read_item(name: str):
    """function general"""
    return {"msg": f"Hello {name}"}


@app.get("/healthcheck")
async def heathcheck():
    """function healthcheck"""
    qoute = q_a("What is the qoute of the day", "person with a wealth of experience")
    return {"msg": "ready", "status_code": 200, "precheck": qoute}


@app.get("/version")
async def version():
    """function general"""
    return {"msg": f"Version {VERSION}"}


@app.get("/message")
async def message(cerere: str = ""):
    """function general"""
    return {"msg": f"Hello {cerere}"}
