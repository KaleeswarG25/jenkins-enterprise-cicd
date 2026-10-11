import os
from flask import Flask, jsonify

app = Flask(__name__)
VERSION = os.getenv("APP_VERSION", "1.0.0")

@app.get("/")
def index():
    return jsonify({
        "application": "CloudCart",
        "description": "Cloud-native commerce API",
        "version": VERSION,
        "status": "running"
    })

@app.get("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.get("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

@app.get("/version")
def version():
    return jsonify({"version": VERSION}), 200

@app.get("/api/v1/products")
def products():
    return jsonify({
        "items": [
            {"id": "SKU-1001", "name": "CloudCart Starter", "price": 499},
            {"id": "SKU-1002", "name": "CloudCart Pro", "price": 999}
        ],
        "count": 2
    }), 200
