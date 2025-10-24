# Task Manager - Kubernetes Deployment Guide

## 🎯 **Quick Start**

This guide shows you how to deploy the Task Manager application to Kubernetes using the automated deploy script.

## 📋 **Prerequisites**

- **kubectl** installed and configured
- **Kubernetes cluster** access
- **GitHub Container Registry** access (for pulling images)

## 🔐 **Step 1: Create Registry Secret**

**Important:** You must create the GitHub Container Registry secret before running the deploy script.

### **1.1 Create GitHub Personal Access Token**

1. Go to **GitHub Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. **Name**: `Kubernetes Registry Access`
4. **Expiration**: Choose appropriate duration
5. **Scopes**: Select `read:packages` (minimum required)
6. **Copy the token** (starts with `ghp_...`)

### **1.2 Create Registry Secret**

```bash
# Create the registry secret in task-manager namespace
kubectl create secret docker-registry ghcr-creds \
  --docker-server=ghcr.io \
  --docker-username=your-github-username \
  --docker-password=your-github-token \
  --docker-email=your-email@example.com \
  -n task-manager
```

### **1.3 Verify Secret Creation**

```bash
# Check if secret was created successfully
kubectl get secret ghcr-creds -n task-manager

# Expected output:
# NAME         TYPE                             DATA   AGE
# ghcr-creds   kubernetes.io/dockerconfigjson   1      1m
```

## 🚀 **Step 2: Run Deploy Script**

### **2.1 Navigate to Deployment Directory**

```bash
cd Task-Manager-Deploy
```

### **2.2 Make Script Executable**

```bash
chmod +x scripts/deploy.sh
```

### **2.3 Run Deployment**

```bash
./scripts/deploy.sh
```

## 📊 **What the Script Does**

The deploy script will:

1. **Create namespace** (`task-manager`) if it doesn't exist
2. **Check registry secret** (exits if not found)
3. **Deploy PostgreSQL** (with secret and StatefulSet)
4. **Deploy Eureka Server** (service discovery)
5. **Deploy API Gateway** (load balancer)
6. **Deploy Task Manager API** (main service)
7. **Deploy Frontend** (web interface)
8. **Wait for all services** to be ready
9. **Populate sample data** (automatically loads test data)
10. **Show service status** and access URLs

## 🔍 **Expected Output**

```bash
🚀 Starting Task Manager deployment...
📁 Project directory: /path/to/Task-Manager-Deploy
📁 K8s directory: /path/to/Task-Manager-Deploy/dev/k8s
📦 Creating namespace: task-manager
🔐 Checking registry secret...
✅ Registry secret 'ghcr-creds' found
🗄️ Deploying PostgreSQL...
⏳ Waiting for PostgreSQL to be ready...
🔍 Deploying Eureka Server...
⏳ Waiting for Eureka to be ready...
🌐 Deploying API Gateway...
📋 Deploying Task Manager API...
🎨 Deploying Frontend...
⏳ Waiting for all deployments to be ready...
📦 Copying and populating sample data into PostgreSQL...
🧩 Executing SQL scripts inside PostgreSQL pod...
✅ Sample data successfully populated!
✅ Deployment completed!
📊 Service Status:
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
task-manager           ClusterIP      10.96.1.100     <none>        8081/TCP         2m
task-manager-eureka    ClusterIP      10.96.1.101     <none>        8761/TCP         2m
task-manager-gateway   LoadBalancer   10.96.1.102      <pending>     8080:30000/TCP   2m
task-manager-postgres  ClusterIP      10.96.1.103     <none>        5432/TCP         2m

🔗 Access URLs:
Frontend: http://localhost:3000
API Gateway: http://localhost:8080
Eureka Dashboard: http://localhost:8761
PostgreSQL: localhost:5432

🎉 Task Manager is now running!
```

## 🛠️ **Verification Commands**

### **Check Pod Status**
```bash
kubectl get pods -n task-manager
```

### **Check Services**
```bash
kubectl get services -n task-manager
```

### **Check Logs**
```bash
# Check specific service logs
kubectl logs -f deployment/task-manager -n task-manager
kubectl logs -f statefulset/task-manager-postgres -n task-manager
```

### **Test Application**
```bash
# Test API endpoint
curl http://localhost:8080/api/v1/tasks

# Check Eureka dashboard
curl http://localhost:8761
```

### **Verify Sample Data**
```bash
# Check if sample data was loaded
kubectl exec -it task-manager-postgres-0 -n task-manager -- psql -U taskuser -d taskdb -c "SELECT COUNT(*) FROM tasks;"

# Expected output: Should show 30+ tasks
#  count 
# -------
#     31
```

## 🚨 **Troubleshooting**

### **Registry Secret Issues**
```bash
# Check if secret exists
kubectl get secret ghcr-creds -n task-manager

# If not found, create it (see Step 1)
kubectl create secret docker-registry ghcr-creds \
  --docker-server=ghcr.io \
  --docker-username=your-github-username \
  --docker-password=your-github-token \
  --docker-email=your-email@example.com \
  -n task-manager
```

### **Pod Issues**
```bash
# Check pod status
kubectl get pods -n task-manager

# Check pod details
kubectl describe pod <pod-name> -n task-manager

# Check pod logs
kubectl logs <pod-name> -n task-manager
```

### **Image Pull Issues**
```bash
# Check if image exists
docker pull ghcr.io/saleos-sam/task-manager:latest

# Check registry credentials
kubectl get secret ghcr-creds -n task-manager -o yaml
```

## 🗑️ **Cleanup**

### **Remove All Resources**
```bash
# Delete entire namespace (removes everything)
kubectl delete namespace task-manager
```

### **Remove Specific Service**
```bash
# Delete specific deployment
kubectl delete deployment task-manager -n task-manager

# Delete specific service
kubectl delete service task-manager -n task-manager
```

## 📝 **Quick Reference**

### **Essential Commands**
```bash
# Create registry secret
kubectl create secret docker-registry ghcr-creds \
  --docker-server=ghcr.io \
  --docker-username=your-github-username \
  --docker-password=your-github-token \
  --docker-email=your-email@example.com \
  -n task-manager

# Run deployment
cd Task-Manager-Deploy
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Check status
kubectl get pods -n task-manager
kubectl get services -n task-manager
```

### **Access URLs**
- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **Eureka Dashboard**: http://localhost:8761
- **PostgreSQL**: localhost:5432

---

**That's it! Your Task Manager application is now running on Kubernetes! 🎯**
