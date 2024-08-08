#!/bin/bash

# Exit script on any error
set -e

# Load variables from .env file
if [ -f .env ]; then
  export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
else
  echo ".env file not found. Please create it and set the necessary variables."
  exit 1
fi

# Step 1: Create a Simple Application (if needed)
echo "Step 1: Create a Simple Application"
brew install python
python3 -m venv venv
source venv/bin/activate
pip install flask prometheus_client

# Create app.py if it doesn't exist
if [ ! -f app.py ]; then
cat <<EOF > app.py
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
EOF
fi

# Step 2: Containerize the Application
echo "Step 2: Containerize the Application"
if [ ! -f Dockerfile ]; then
cat <<EOF > Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir flask prometheus_client

# Make port 80 and 8000 available to the world outside this container
EXPOSE 80 8000

# Run app.py when the container launches
CMD ["python", "app.py"]
EOF
fi

# Step 3: Authenticate with Docker Hub
echo "Step 3: Authenticate with Docker Hub"
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Step 4: Build and Push the Docker Image
echo "Step 4: Build and Push the Docker Image"
docker build -t $IMAGE_NAME .
docker push $IMAGE_NAME

# Step 5: Set up a Kubernetes Cluster with Kind
echo "Step 5: Set up a Kubernetes Cluster with Kind"
kind create cluster --name $KIND_CLUSTER_NAME

# Step 6: Create Kubernetes Secret for Docker Registry
echo "Step 6: Create Kubernetes Secret for Docker Registry"
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=$DOCKER_USERNAME \
  --docker-password=$DOCKER_PASSWORD \
  --docker-email=$DOCKER_EMAIL

# Step 7: Deploy the Application
echo "Step 7: Deploy the Application"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml

# Step 8: Deploy Prometheus and Grafana
echo "Step 8: Deploy Prometheus and Grafana"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Install Grafana
helm install grafana grafana/grafana

# Get Grafana admin password
echo "Grafana admin password:"
kubectl get secret --namespace $NAMESPACE grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

echo "Setup complete. Access Grafana at http://localhost:3000"
