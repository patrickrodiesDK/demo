# 🐘 PostgreSQL Database Platform on Kubernetes

This deployment sets up PostgreSQL database with pgAdmin for database management on a Kubernetes cluster using a dedicated database namespace.

## 🏗️ Architecture

- **🐘 PostgreSQL**: Production-ready database server
- **🛠️ pgAdmin**: Web-based PostgreSQL administration tool
- **🌐 Namespace**: Isolated `database` namespace for organization
- **📦 Kustomize**: GitOps-ready deployment management

## ✅ Prerequisites

- 🚀 Kubernetes cluster (K3s, minikube, etc.)
- 🔧 `kubectl` configured to access your cluster
- 📚 Basic understanding of Kubernetes concepts

### Create demo cluster (default: 4GB, 2 CPU)
```bash
./k3d.sh

# Create demo cluster with custom resources with namespace called database
./k3d.sh 8 4 demo database

# Create production cluster
./k3d.sh 16 8 production
```

## 📁 Deployment Files

```
postgres/
├── 📖 README.md
├── 📦 kustomization.yaml           # Kustomize configuration
├── 🌐 namespace.yaml               # Database namespace
├── 🔐 postgres-secrets.yaml        # PostgreSQL credentials
├── ⚙️ postgres-configmap.yaml      # PostgreSQL configuration
├── 💾 postgres-pvc.yaml            # PostgreSQL data storage
├── 💾 postgres-logs-pvc.yaml       # PostgreSQL logs storage
├── 🐘 postgres-deployment.yaml     # PostgreSQL database
├── 🌐 postgres-service.yaml        # PostgreSQL service
├── 🔐 pgadmin-secrets.yaml         # pgAdmin credentials
├── ⚙️ pgadmin-configmap.yaml       # pgAdmin configuration
├── 🛠️ pgadmin-deployment.yaml      # pgAdmin application
├── 🌐 pgadmin-service.yaml         # pgAdmin service
├── 🚀 k3d.sh                       # Cluster creation script
├── 🔄 restart-k3d-demo.sh          # Cluster restart script
└── 📁 logs/                        # Log directory
```

## 🚀 Quick Start

### 🎯 Deploy with Kustomize (Recommended)

```bash
# Single command to deploy everything
kubectl apply -k postgres/

# Watch the deployment progress
kubectl get pods -n database -w

# Verify deployment
kubectl get all -n database
```

#### 🔍 Kustomize Commands

```bash
# Preview deployment (dry-run)
kubectl apply -k postgres/ --dry-run=client

# See generated YAML
kubectl kustomize postgres/

# Deploy with enhanced script
chmod +x deploy-postgres.sh
./deploy-postgres.sh
```

### 0. 🎯 Create Demo Cluster (Optional)

If you need to create a new K3d cluster for this demo:

```bash
# Create demo cluster with custom resources
# Usage: ./k3d.sh [memory_gb] [cpu_count] [cluster_name]

# Default demo cluster (4GB RAM, 2 CPUs)
./k3d.sh 4 2 demo

# Or with custom resources
./k3d.sh 8 4 demo-large

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### 1. 🌐 Manual Deployment (Step by Step)

If you prefer manual deployment:

```bash
# Create dedicated namespace for database services
kubectl apply -f namespace.yaml

# Deploy PostgreSQL
kubectl apply -f postgres-secrets.yaml
kubectl apply -f postgres-configmap.yaml
kubectl apply -f postgres-pvc.yaml
kubectl apply -f postgres-logs-pvc.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# Deploy pgAdmin
kubectl apply -f pgadmin-secrets.yaml
kubectl apply -f pgadmin-configmap.yaml
kubectl apply -f pgadmin-deployment.yaml
kubectl apply -f pgadmin-service.yaml

# ✅ Verify deployment
kubectl get all -n database
```

### 2. 🔄 After Laptop Restart

```bash
# Start the existing cluster (cluster persists across reboots)
k3d cluster start demo

# Pods will automatically restart, or redeploy if needed
kubectl get pods -n database

# If pods aren't running, redeploy
kubectl apply -k postgres/
```

## 🌐 Access Services

### 🛠️ pgAdmin Database Management

**Method 1: 🔗 Direct NodePort Access**
```bash
# Access pgAdmin via NodePort
open http://localhost:31080
# or check node IP
kubectl get nodes -o wide
# 🌐 Access via: http://<node-ip>:31080
```

**Method 2: 🔀 Port Forward**
```bash
kubectl port-forward -n database service/pgadmin-service 8080:80
# 🌐 Access via: http://localhost:8080
```

**🔑 pgAdmin Login Credentials:**
- Email: `admin@pgadmin.com`
- Password: `pgadmin123`

### 🐘 PostgreSQL Database Direct Access

**Method 1: 🔀 Port Forward**
```bash
kubectl port-forward -n database service/postgres-service 5432:5432
# 🔗 Connect via: postgresql://pgadmin:pgadmin123@localhost:5432/postgres
```

**Method 2: 🛡️ Temporary psql Pod**
```bash
kubectl run psql-client --rm -it --image=postgres:15 --restart=Never -n database -- \
  psql postgresql://pgadmin:pgadmin123@postgres-service:5432/postgres
```

**🐘 PostgreSQL Connection in pgAdmin:**
- Host: `postgres-service`
- Port: `5432`
- Username: `pgadmin`
- Password: `pgadmin123`
- Database: `postgres`

## ⚙️ Configuration Details

### 🐘 Database Configuration
- **Database**: PostgreSQL 15
- **Username**: `pgadmin`
- **Password**: `pgadmin123`
- **Database Name**: `postgres`
- **Namespace**: `database`
- **Internal Service**: `postgres-service.database.svc.cluster.local:5432`
- **Data Path**: `/var/lib/postgresql/data/pgdata`
- **Storage**: 10Gi persistent volume for data, 5Gi for logs

### 🛠️ pgAdmin Configuration
- **Email**: `admin@pgadmin.com`
- **Password**: `pgadmin123`
- **Namespace**: `database`
- **Port**: 80 (internal), 31080 (NodePort)

### 💾 Resource Limits
- **🐘 PostgreSQL**: 1 CPU, 2Gi memory, 10Gi data storage, 5Gi log storage
- **🛠️ pgAdmin**: 0.5 CPU, 512Mi memory

## 🔄 Cluster Management

### 🚀 Restart After Laptop Reboot

```bash
# Enhanced restart script
chmod +x restart-k3d-demo.sh
./restart-k3d-demo.sh

# Or manually
k3d cluster start demo
kubectl apply -k postgres/
```

### 💾 Backup & Restore

```bash
# Create backup
./backup-postgres-data.sh

# Restore from backup
./restore-postgres-data.sh [backup-file]

# Manual backup
kubectl exec -n database deployment/postgres-deployment -- \
  pg_dumpall -U pgadmin > postgres-backup-$(date +%Y%m%d).sql
```

### 📊 Status Check

```bash
# Check cluster and deployment status
./check-k3d-status.sh

# Manual status check
k3d cluster list
kubectl get all -n database
```

## 🔍 Troubleshooting

### 📊 Check Pod Status
```bash
# Check all pods in database namespace
kubectl get pods -n database

# Check specific app pods
kubectl get pods -n database -l app=postgres
kubectl get pods -n database -l app=pgadmin

# 📋 Check pod logs
kubectl logs -n database -l app=postgres -f
kubectl logs -n database -l app=pgadmin -f
```

### 🌐 Check Services and Storage
```bash
# List all services in database namespace
kubectl get services -n database

# Check service endpoints
kubectl get endpoints -n database

# Check persistent volume claims
kubectl get pvc -n database

# Check storage usage
kubectl exec -n database deployment/postgres-deployment -- df -h /var/lib/postgresql/data
```

### ⚠️ Common Issues

1. **🚫 Pod not starting**: Check logs with `kubectl logs -n database <pod-name>`
2. **🔌 Database connection issues**: Verify PostgreSQL pod is running and service exists
3. **🌐 pgAdmin can't connect**: Use `postgres-service` as hostname, not localhost
4. **🔑 Authentication issues**: Verify secrets are correctly applied
5. **💾 Storage issues**: Check PVC status with `kubectl get pvc -n database`
6. **🔄 After restart**: Cluster may need to be recreated if Docker cleaned up containers

### 🔄 Reset Deployment
```bash
# 🗑️ Delete all resources
kubectl delete namespace database

# Or delete entire cluster and recreate
k3d cluster delete demo
./k3d.sh

# 🚀 Redeploy
kubectl apply -k postgres/
```

## 🎯 Kustomize Features

### 🏷️ Common Labels
All resources are automatically labeled with:
- `stack: postgres`
- `environment: demo`
- `app.kubernetes.io/managed-by: kustomize`

### 📦 Resource Organization
- **Namespace scoping**: All resources deployed to `database` namespace
- **Dependency management**: Resources applied in correct order
- **Configuration management**: Centralized via kustomization.yaml

### 🔧 Customization
```bash
# Edit kustomization.yaml to:
# - Add/remove resources
# - Change common labels
# - Modify namespace
# - Add patches or overlays

# Example: Add custom labels
commonLabels:
  stack: postgres
  environment: demo
  team: data-engineering
```

## 🔒 Security Notes

- 🔑 Change default passwords in production
- 🛡️ Consider using proper secrets management (e.g., Vault, Sealed Secrets)
- 🌐 Review network policies for production use
- 🔐 Enable TLS/SSL for production deployments
- 🌐 Use namespace isolation for multi-tenant setups

## 📈 Scaling & Production

### 🏗️ Production Considerations
```bash
# For production, consider:
# - PostgreSQL Operator (e.g., Zalando, Crunchy Data)
# - Read replicas with Patroni
# - Backup automation with pgBackRest
# - Monitoring with Prometheus/Grafana
# - Resource quotas and limits
# - Network policies
# - Pod security policies
```

### ⚙️ Update Configuration
```bash
# Update PostgreSQL config
kubectl apply -f postgres-configmap.yaml
kubectl rollout restart deployment -n database postgres-deployment

# Update pgAdmin config
kubectl apply -f pgadmin-configmap.yaml
kubectl rollout restart deployment -n database pgadmin-deployment

# Or update everything with Kustomize
kubectl apply -k postgres/
```

## 📊 Monitoring

Monitor your deployment:
```bash
# 👀 Watch pod status
kubectl get pods -n database -w

# 📈 Monitor resource usage
kubectl top pods -n database
kubectl top nodes

# 🔍 Check events
kubectl get events -n database --sort-by='.lastTimestamp'

# 📊 Port forward for monitoring
kubectl port-forward -n database service/pgadmin-service 8080:80
```

## 🎯 Quick Access Commands

```bash
# 🌐 Access URLs
echo "🛠️ pgAdmin: http://localhost:31080"
echo "🔗 pgAdmin (port-forward): kubectl port-forward -n database service/pgadmin-service 8080:80"

# 📊 Check all deployments
kubectl get all -n database

# 🔍 Check all pod status
kubectl get pods -n database -o wide

# 📋 View recent logs
kubectl logs -n database -l app=postgres --tail=50
kubectl logs -n database -l app=pgadmin --tail=50

# 🔗 Quick database connection test
kubectl exec -n database deployment/postgres-deployment -- \
  psql -U pgadmin -d postgres -c "SELECT version();"

# 💾 Storage status
kubectl get pvc -n database
kubectl describe pvc -n database

# 🏷️ Resources by label
kubectl get all -n database -l app=postgres
kubectl get all -n database -l app=pgadmin
```

## 🎨 Advanced Usage

### 🔧 Kustomize Overlays
```bash
# Create environment-specific overlays
mkdir -p overlays/development
mkdir -p overlays/production

# Example development overlay (overlays/development/kustomization.yaml)
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
patchesStrategicMerge:
- postgres-resources.yaml
commonLabels:
  environment: development
```

### 🌐 Namespace Management
```bash
# List all resources in database namespace
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -n database

# Describe namespace
kubectl describe namespace database

# Delete entire namespace (⚠️ destructive)
kubectl delete namespace database
```

---

**🎉 Happy Database Management with Kustomize!** 🐘📦✨

## 📋 Quick Reference

| **Command** | **Description** |
|-------------|-----------------|
| `kubectl apply -k postgres/` | Deploy entire stack |
| `kubectl get all -n database` | Check all resources |
| `k3d cluster start demo` | Start cluster after restart |
| `./restart-k3d-demo.sh` | Auto-restart script |
| `http://localhost:31080` | pgAdmin web interface |
| `postgres-service:5432` | PostgreSQL connection in pgAdmin |