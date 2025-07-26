from flask import Flask, jsonify
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/')
def hello():
     # List of files the malicious Dockerfile tries to create/steal
    target_files = [
        '/app/stolen_passwords.txt',
        '/app/stolen_shadow.txt',
    ]
    
    for file_path in target_files:
        try:
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    logger.info(f.read())
            else:
                logger.info("File not found or access denied")
        except Exception as e:
            logger.info(f"Failed to read, {e}")
    return jsonify({
        "message": "Hello World!",
        "status": "running",
        "service": "dummy-api"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
