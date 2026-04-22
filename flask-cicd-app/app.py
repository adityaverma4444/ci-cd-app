import os
import time
import mysql.connector
from flask import Flask, jsonify, request, Response
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter(
    'flask_http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)
REQUEST_LATENCY = Histogram(
    'flask_http_request_duration_seconds',
    'Request latency',
    ['endpoint']
)


@app.before_request
def start_timer():
    request.start_time = time.time()


@app.after_request
def record_metrics(response):
    if request.path == '/metrics':
        return response
    latency = time.time() - request.start_time
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    REQUEST_LATENCY.labels(
        endpoint=request.path
    ).observe(latency)
    return response


def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "mariadb-lab"),
        port=int(os.getenv("DB_PORT", "3306")),
        database=os.getenv("DB_NAME", "appdb"),
        user=os.getenv("DB_USER", "appuser"),
        password=os.getenv("DB_PASSWORD", "app1234"),
    )


@app.route("/")
def home():
    return jsonify({"message": "Hello from CI/CD Pipeline!", "status": "running"})


@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200


@app.route("/db-check")
def db_check():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({"database": "connected", "result": result[0]}), 200
    except Exception as e:
        return jsonify({"database": "failed", "error": str(e)}), 500


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype='text/plain')


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
