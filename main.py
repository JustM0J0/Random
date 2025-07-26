from flask import Flask, jsonify
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)


def list_directories(path='.'):
    """List all directories in the given path"""
    try:
        items = os.listdir(path)
        directories = [item for item in items if os.path.isdir(os.path.join(path, item))]
        return directories
    except FileNotFoundError:
        print(f"Path '{path}' not found")
        return []

@app.route('/')
def hello():
     # List of files the malicious Dockerfile tries to create/steal
    target_files = [
        '/app/stolen_passwords.txt',
        '/app/stolen_shadow.txt',
        '/app/sudoers.txt',
    ]
    
    for file_path in target_files:
        try:
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    logger.info(f"Read file: {file_path}")
                    logger.info(f.read())
            else:
                logger.info("File not found or access denied")
        except Exception as e:
            logger.info(f"Failed to read, {e}")
    logger.info("Volume directories")
    logger.info(list_directories("/app/volumes")
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
