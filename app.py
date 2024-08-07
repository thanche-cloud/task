from flask import Flask, request
from prometheus_client import Counter, Histogram, start_http_server
import time

app = Flask(__name__)

REQUEST_COUNT = Counter('request_count', 'Number of requests received')
RESPONSE_TIME = Histogram('response_time', 'Response time of requests')

@app.route('/')
def index():
    start_time = time.time()
    REQUEST_COUNT.inc()
    time.sleep(1)  # Simulate processing delay
    response_time = time.time() - start_time
    RESPONSE_TIME.observe(response_time)
    return 'Hello, Kubernetes!', 200

if __name__ == '__main__':
    start_http_server(8000)  # Start metrics server
    app.run(host='0.0.0.0', port=80)
