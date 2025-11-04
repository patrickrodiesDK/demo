# 🔄 n8n Workflow Automation Platform on Kubernetes

This deployment sets up n8n workflow automation platform with PostgreSQL database and pgAdmin for database management on a Kubernetes cluster.

## 🏗️ Architecture

- **🔄 n8n**: Workflow automation platform
- **🐘 PostgreSQL**: Database backend for n8n
- **🛠️ pgAdmin**: Web-based PostgreSQL administration tool

## ✅ Prerequisites

- 🚀 Kubernetes cluster (K3s, minikube, etc.)
- 🔧 `kubectl` configured to access your cluster
- 📚 Basic understanding of Kubernetes concepts

## 📁 Deployment Files

```
n8n/
├── 📖 README.md
├── 🔐 postgres-secrets.yaml      # PostgreSQL credentials
├── 🐘 postgres-deployment.yaml   # PostgreSQL database
├── 🌐 postgres-service.yaml      # PostgreSQL service
├── 🔐 n8n-secrets.yaml          # n8n credentials
├── ⚙️ n8n-configmap.yaml        # n8n configuration
├── 🔄 n8n-deployment.yaml       # n8n application
├── 🌐 n8n-service.yaml          # n8n service
├── 🔐 pgadmin-secrets.yaml      # pgAdmin credentials
├── ⚙️ pgadmin-configmap.yaml    # pgAdmin configuration
├── 🛠️ pgadmin-deployment.yaml   # pgAdmin application
└── 🌐 pgadmin-service.yaml      # pgAdmin service
```

## 🚀 Quick Start

### 1. 🐘 Deploy PostgreSQL Database

```bash
# Deploy PostgreSQL secrets and database
kubectl apply -f postgres-secrets.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# ✅ Verify PostgreSQL is running
kubectl get pods -l app=postgres
kubectl get service postgres-service
```

### 2. 🔄 Deploy n8n Application

```bash
# Deploy n8n secrets and application
kubectl apply -f n8n-secrets.yaml
kubectl apply -f n8n-configmap.yaml
kubectl apply -f n8n-deployment.yaml
kubectl apply -f n8n-service.yaml

# ✅ Verify n8n is running
kubectl get pods -l app=n8n
kubectl get service n8n-service
```

### 3. 🛠️ Deploy pgAdmin (Optional)

```bash
# Deploy pgAdmin for database management
kubectl apply -f pgadmin-secrets.yaml
kubectl apply -f pgadmin-configmap.yaml
kubectl apply -f pgadmin-deployment.yaml
kubectl apply -f pgadmin-service.yaml

# ✅ Verify pgAdmin is running
kubectl get pods -l app=pgadmin
kubectl get service pgadmin-service
```

### 4. 🎯 Deploy All at Once

```bash
# 🚀 Deploy everything in order
kubectl apply -f postgres-secrets.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f n8n-secrets.yaml
kubectl apply -f n8n-configmap.yaml
kubectl apply -f n8n-deployment.yaml
kubectl apply -f n8n-service.yaml
kubectl apply -f pgadmin-secrets.yaml
kubectl apply -f pgadmin-configmap.yaml
kubectl apply -f pgadmin-deployment.yaml
kubectl apply -f pgadmin-service.yaml
```

## 🌐 Access Services

### 🔄 n8n Workflow Platform

**Method 1: 🔗 Direct NodePort Access**
```bash
# Get node IP and access n8n
kubectl get nodes -o wide
# 🌐 Access via: http://<node-ip>:31915
```

**Method 2: 🔀 Port Forward**
```bash
kubectl port-forward service/n8n-service 8080:5678
# 🌐 Access via: http://localhost:8080
```

**🔑 Login Credentials:**
- Username: `n8n`
- Password: `n8n123`

### 🛠️ pgAdmin Database Management

**Method 1: 🔗 Direct NodePort Access**
```bash
# Get node IP and access pgAdmin
kubectl get nodes -o wide
# 🌐 Access via: http://<node-ip>:31080
```

**Method 2: 🔀 Port Forward**
```bash
kubectl port-forward service/pgadmin-service 8081:80
# 🌐 Access via: http://localhost:8081
```

**🔑 Login Credentials:**
- Email: `admin@pgadmin.com`
- Password: `pgadmin123`

**🐘 PostgreSQL Connection in pgAdmin:**
- Host: `postgres-service`
- Port: `5432`
- Username: `n8n`
- Password: `n8n`
- Database: `n8n`

### 🐘 PostgreSQL Database Direct Access

**Method 1: 🔀 Port Forward**
```bash
kubectl port-forward service/postgres-service 5432:5432
# 🔗 Connect via: postgresql://n8n:n8n@localhost:5432/n8n
```

**Method 2: 🛡️ Temporary psql Pod**
```bash
kubectl run psql-client --rm -it --image=postgres:15 --restart=Never -- \
  psql postgresql://n8n:n8n@postgres-service:5432/n8n
```

## ⚙️ Configuration Details

### 🐘 Database Configuration
- **Database**: PostgreSQL 15
- **Username**: `n8n`
- **Password**: `n8n`
- **Database Name**: `n8n`
- **Internal Service**: `postgres-service:5432`
- **Data Path**: `/var/lib/postgresql/data/pgdata`

### 🔄 n8n Configuration
- **Environment**: Production
- **Timezone**: Europe/Lisbon
- **Basic Auth**: Enabled
- **Database**: PostgreSQL backend
- **Webhook URL**: Auto-configured based on service IP

### 💾 Resource Limits
- **🐘 PostgreSQL**: 1 CPU, 1Gi memory
- **🔄 n8n**: 1 CPU, 1Gi memory
- **🛠️ pgAdmin**: 0.5 CPU, 512Mi memory

## 🔍 Troubleshooting

### 📊 Check Pod Status
```bash
# Check all pods
kubectl get pods

# Check specific app pods
kubectl get pods -l app=postgres
kubectl get pods -l app=n8n
kubectl get pods -l app=pgadmin

# 📋 Check pod logs
kubectl logs -l app=n8n
kubectl logs -l app=postgres
kubectl logs -l app=pgadmin
```

### 🌐 Check Services
```bash
# List all services
kubectl get services

# Check service endpoints
kubectl get endpoints postgres-service
kubectl get endpoints n8n-service
kubectl get endpoints pgadmin-service
```

### ⚠️ Common Issues

1. **🚫 Pod not starting**: Check logs with `kubectl logs <pod-name>`
2. **🔌 Database connection issues**: Verify PostgreSQL pod is running first
3. **🌐 Service not accessible**: Check NodePort services and node IPs
4. **🔑 pgAdmin login issues**: Verify secrets are applied correctly

### 🔄 Reset Deployment
```bash
# 🗑️ Delete all resources
kubectl delete -f .

# ⏳ Wait for cleanup
kubectl get pods

# 🚀 Redeploy
kubectl apply -f postgres-secrets.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
# ... continue with other services
```

## 🔒 Security Notes

- 🔑 Change default passwords in production
- 🛡️ Consider using proper secrets management
- 🌐 Review network policies for production use
- 🔐 Enable TLS/SSL for production deployments

## 📈 Scaling

To scale n8n horizontally:
```bash
kubectl scale deployment n8n-deployment --replicas=3
```

⚠️ **Note**: Ensure your workflows are designed for horizontal scaling.

## 🎨 Customization

### ⚙️ Update n8n Configuration
Edit `n8n-configmap.yaml` and apply:
```bash
kubectl apply -f n8n-configmap.yaml
kubectl rollout restart deployment n8n-deployment
```

### 🔑 Update Database Credentials
Edit `postgres-secrets.yaml` and apply:
```bash
kubectl apply -f postgres-secrets.yaml
kubectl rollout restart deployment postgres-deployment
kubectl rollout restart deployment n8n-deployment
```

## 📊 Monitoring

Monitor your deployment:
```bash
# 👀 Watch pod status
kubectl get pods -w

# 📈 Monitor resource usage
kubectl top pods
kubectl top nodes
```

## 💾 Backup

Backup PostgreSQL data:
```bash
kubectl exec -it deployment/postgres-deployment -- \
  pg_dump -U n8n -d n8n > n8n-backup.sql
```

## 🎯 Quick Access Commands

```bash
# 🌐 Get all service URLs
echo "🔄 n8n: http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):31915"
echo "🛠️ pgAdmin: http://$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}'):31080"

# 📊 Check all deployments
kubectl get deployments

# 🔍 Check all pods status
kubectl get pods -o wide

# 📋 View all logs
kubectl logs -l app=n8n --tail=50
kubectl logs -l app=postgres --tail=50
kubectl logs -l app=pgadmin --tail=50
```

---

**🎉 Happy Automating with n8n!** 🔄✨


## 📚 References

- [n8n Official Documentation](https://docs.n8n.io/)
- [n8n install on k8s](https://www.andreffs.com/blog/setup-n8n-on-kubernetes/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)