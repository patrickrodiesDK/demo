# Delete existing cluster if any
k3d cluster delete my-k3d-cluster

# Create cluster (disk space will use what's available from Docker's 460GB)
k3d cluster create my-k3d-cluster \
  --servers 1 \
  --agents 2 \
  --port "8080:80@loadbalancer" \
  --port "8443:443@loadbalancer" \
  --port "9090:9090@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --wait

# Apply ONLY memory and CPU constraints (not disk)
docker update --memory=2g --cpus=2 k3d-my-k3d-cluster-server-0
docker update --memory=2g --cpus=2 k3d-my-k3d-cluster-agent-0
docker update --memory=2g --cpus=2 k3d-my-k3d-cluster-agent-1

# Verify
kubectl get nodes -o wide
docker stats --no-stream
