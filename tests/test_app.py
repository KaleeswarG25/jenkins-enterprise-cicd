from app.app import app

def test_home_endpoint():
    response = app.test_client().get("/")
    assert response.status_code == 200
    assert response.json["application"] == "jenkins-enterprise-cicd"

def test_health_endpoint():
    response = app.test_client().get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"

def test_version_endpoint():
    response = app.test_client().get("/version")
    assert response.status_code == 200
    assert response.json["version"] == "1.0.0"
