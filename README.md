# task

# Step 1: Create a Simple Application

brew install python
python3 -m venv venv
source venv/bin/activate
pip install flask prometheus_client
Create app.py

# Step 2: Containerize the Application

docker build -t thanche/task:latest .
docker tag thanche/task:latest task:latest
docker push thanche/task:latest


# Step 3: Set up a Kubernetes Cluster with Kind
# Install Kind
# Create a Cluster Using Kind


# Step 2: Authenticate with Docker Hub
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username= \
  --docker-password= \
  --docker-email=****



# Step 4: Load Docker Image into Kind Cluster

# Step 5: Deploy the Application
# Create Kubernetes Manifests
# Apply Kubernetes Manifests 
{kubectl apply -f deployment.yaml && kubectl apply -f service.yaml}

# Step 6: Deploy Prometheus
 Deploy Prometheus in your Kubernetes cluster to collect and store the metrics exposed by your application.

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Install Grafana
helm install grafana grafana/grafana
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo



# Step 7: Automate the Deployment




# chmod +x setup.sh
# ./setup.sh


