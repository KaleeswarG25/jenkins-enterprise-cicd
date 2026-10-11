from app.app import app

def test_home():
    response = app.test_client().get("/")
    assert response.status_code == 200
    assert response.json["application"] == "CloudCart"

def test_health():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"

def test_readiness():
    assert app.test_client().get("/ready").status_code == 200

def test_version():
    response = app.test_client().get("/version")
    assert response.status_code == 200
    assert "version" in response.json

def test_products():
    response = app.test_client().get("/api/v1/products")
    assert response.status_code == 200
    assert response.json["count"] == 2
