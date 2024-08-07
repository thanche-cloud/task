# task

Step 1: Create a Simple Application

brew install python
python3 -m venv venv
source venv/bin/activate
pip install flask prometheus_client
Create app.py

Step 2: Containerize the Application

docker build -t thanche/task:latest .
docker tag thanche/task:latest task:latest
docker push thanche/task:latest


Step 3: Set up a Kubernetes Cluster with Kind
Install Kind
Create a Cluster Using Kind

Step 4: Load Docker Image into Kind Cluster