import os
import mysql.connector
from flask import Flask, jsonify

app = Flask(__name__)


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

        return jsonify({
            "database": "connected",
            "result": result[0]
        }), 200
    except Exception as e:
        return jsonify({
            "database": "failed",
            "error": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)