"""doc string"""
from urllib.parse import quote
from fastapi.testclient import TestClient
from app.main import app

VERSION = '1.0.0'

client = TestClient(app)

def test_read_root():
    """doc string"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"msg": "Hello world"}

def test_read_item():
    """doc string"""
    response = client.get("/name/Ionescu")
    assert response.status_code == 200
    assert response.json() == {"msg": "Hello Ionescu"}

def test_heathcheck():
    """test function healthcheck"""
    response = client.get("/healthcheck")
    assert response.status_code == 200
    answ = response.json()
    assert 'msg' in answ and answ['msg'] == 'ready'

def test_version():
    """test function verison"""
    response = client.get('/version')
    assert response.status_code == 200
    answ = response.json()
    assert "msg" in answ and answ['msg'] ==  f"Version {VERSION}"

def test_message():
    """test function message"""
    response = client.get(f'/message?cerere={quote("Incă un test române.")}')
    assert response.status_code == 200
    assert response.json() == {"msg": "Hello Incă un test române."}
