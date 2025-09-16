# Task Manager Kubernetes Deployment

This repository contains Kubernetes deployment configurations for the Task Manager application with node affinity configurations for dedicated node pool scheduling.

## Node Configuration

### Current Node Setup
The cluster has two node pools:
- **aks-agentpool-35736359-vmss000000**: Default agent pool
- **aks-userpool-35736359-vmss000002**: User pool (dedicated for high-performance workloads)

### Node Labels and Taints Setup

#### 1. Label the User Pool Node
```bash
# Label the userpool node for high-performance workloads
kubectl label nodes aks-userpool-35736359-vmss000002 workload-type=high-performance

# Verify the label was applied
kubectl get nodes --show-labels | grep userpool
```

#### 2. Add Taint to User Pool Node (Optional)
```bash
# Add taint to prevent other workloads from scheduling on userpool
kubectl taint nodes aks-userpool-35736359-vmss000002 workload-type=high-performance:NoSchedule

# Verify the taint was applied
kubectl describe node aks-userpool-35736359-vmss000002
```

#### 3. Remove Taint (if needed)
```bash
# Remove taint if you want to allow other workloads
kubectl taint nodes aks-userpool-35736359-vmss000002 workload-type=high-performance:NoSchedule-
```

## Deployment Configuration

### PostgreSQL Database Deployment
The `task-manager-postgres` deployment provides the database layer:

#### Database Configuration
- **Image**: `postgres:15-alpine`
- **Database**: `taskdb`
- **User**: `taskuser`
- **Password**: `taskpass` (stored in Kubernetes secret)
- **Storage**: 5GB persistent volume
- **Resources**: 256Mi-512Mi memory, 100m-200m CPU

#### Features
- **Persistent Storage**: Data survives pod restarts
- **Health Checks**: Readiness and liveness probes
- **Security**: Password stored in Kubernetes secret
- **Node Affinity**: Scheduled on userpool nodes

### Task Manager API Deployment
The `task-manager` deployment is configured with:

#### Node Affinity
- **Target**: User pool nodes (`kubernetes.azure.com/agentpool=userpool`)
- **Purpose**: Ensures the pod is scheduled only on userpool nodes

#### Tolerations
- **Key**: `workload-type`
- **Value**: `high-performance`
- **Effect**: `NoSchedule`
- **Purpose**: Allows the pod to be scheduled on tainted userpool nodes

#### Dependency Management
- **Init Container**: Waits for PostgreSQL to be ready before starting
- **Database Connection**: Automatically connects to PostgreSQL service
- **Health Checks**: Readiness and liveness probes for Spring Boot actuator

### Task Manager Gateway Deployment
The `task-manager-gateway` deployment is configured with the same node affinity and tolerations:

#### Node Affinity
- **Target**: User pool nodes (`kubernetes.azure.com/agentpool=userpool`)
- **Purpose**: Ensures the gateway pod is scheduled only on userpool nodes

#### Tolerations
- **Key**: `workload-type`
- **Value**: `high-performance`
- **Effect**: `NoSchedule`
- **Purpose**: Allows the gateway pod to be scheduled on tainted userpool nodes

### Deployment Commands

#### Apply All Deployments
```bash
# 1. Apply PostgreSQL deployment first (dependency)
kubectl apply -f dev/k8s/task_manager_postgres_deployment.yml
kubectl apply -f dev/k8s/task_manager_postgres_service.yml

# 2. Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=task-manager-postgres --timeout=300s

# 3. Apply the task manager API deployment (depends on PostgreSQL)
kubectl apply -f dev/k8s/task_manager_api_deployment.yml

# 4. Apply the task manager gateway deployment
kubectl apply -f dev/k8s/task_manager_gateway_deployment.yaml

# 5. Verify deployment status
kubectl get deployments
kubectl get pods -o wide
kubectl get pvc
```

#### Check Pod Scheduling
```bash
# Verify pods are running on userpool node
kubectl get pods -o wide | grep task-manager

# Check pod events for scheduling issues
kubectl describe pod <task-manager-pod-name>
kubectl describe pod <task-manager-gateway-pod-name>
```

## Service Name Consistency

**✅ UPDATED**: Service names are now consistent between Docker Compose and Kubernetes:

| Service | Docker Compose | Kubernetes | Port |
|---------|---------------|------------|------|
| Eureka Server | `task-manager-eureka` | `task-manager-eureka` | 8761 |
| API Gateway | `task-manager-gateway` | `task-manager-gateway` | 8080 |
| Task Manager API | `task-manager` | `task-manager` | 8080→8081 |
| PostgreSQL | `task-manager-postgres` | `task-manager-postgres` | 5432 |

**Benefits:**
- 🔄 **Same service names** across environments
- 📝 **Consistent configuration** in application properties
- 🚀 **Easy migration** between Docker Compose and Kubernetes
- 🐛 **Reduced debugging** time

## Files Structure

```
task-manager-deploy/
├── dev/
│   └── k8s/
│       ├── task_manager_api_deployment.yml       # Main deployment with node affinity & dependencies
│       ├── task_manager_api_service.yml          # Service configuration
│       ├── task_manager_postgres_statefulset.yml # PostgreSQL StatefulSet deployment
│       ├── task_manager_postgres_service.yml     # PostgreSQL service
│       ├── task_manager_eureka_deployment.yml    # Eureka server deployment
│       ├── task_manager_eureka_service.yml       # Eureka service
│       ├── task_manager_gateway_deployment.yaml  # Gateway deployment with node affinity
│       └── task_manager_gateway_service.yaml     # Gateway service
├── sample-data/
│   ├── README.md                                 # Database connection guide
│   ├── 01_create_tables.sql                     # Database schema
│   ├── 02_insert_sample_data.sql                # Sample data (31 tasks)
│   ├── connect_and_populate.bat                 # Windows automation script
│   └── connect_and_populate.sh                  # Linux/macOS automation script
├── docker-compose.yml                           # Local development setup (UPDATED)
└── README.md                                     # This file
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   Agent Pool    │    │   User Pool     │                │
│  │   (Default)     │    │ (High-Perf)     │                │
│  │                 │    │                 │                │
│  │ - Other pods    │    │ - PostgreSQL    │                │
│  │ - System pods   │    │ - Task Manager  │                │
│  │                 │    │ - Gateway       │                │
│  │                 │    │ - Dependencies  │                │
│  │                 │    │ - Persistent DB │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## Dependency Management in Kubernetes

Unlike Docker Compose's `depends_on`, Kubernetes uses different strategies for handling dependencies:

### 1. **Init Containers** (Current Implementation)
```yaml
initContainers:
  - name: wait-for-postgres
    image: busybox:1.35
    command: ["sh", "-c", "until nc -z task-manager-postgres 5432; do sleep 2; done"]
```
- **Purpose**: Waits for PostgreSQL to be ready before starting main container
- **Behavior**: Task Manager pod won't start until PostgreSQL is accessible

### 2. **Health Checks**
```yaml
readinessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
livenessProbe:
  httpGet:
    path: /actuator/health
    port: 8081
```
- **Purpose**: Ensures services are healthy before receiving traffic
- **Behavior**: Service only receives traffic when ready

### 3. **Deployment Order**
```bash
# 1. Deploy database first
kubectl apply -f task_manager_postgres_deployment.yml

# 2. Wait for database to be ready
kubectl wait --for=condition=ready pod -l app=task-manager-postgres

# 3. Deploy application
kubectl apply -f task_manager_api_deployment.yml
```
