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
# Apply the task manager API deployment
kubectl apply -f dev/k8s/task_manager_api_deployment.yml

# Apply the task manager gateway deployment
kubectl apply -f dev/k8s/task_manager_gateway_deployment.yaml

# Verify deployment status
kubectl get deployments
kubectl get pods -o wide
```

#### Check Pod Scheduling
```bash
# Verify pods are running on userpool node
kubectl get pods -o wide | grep task-manager

# Check pod events for scheduling issues
kubectl describe pod <task-manager-pod-name>
kubectl describe pod <task-manager-gateway-pod-name>
```

## Files Structure

```
task-manager-deploy/
├── dev/
│   └── k8s/
│       ├── task_manager_api_deployment.yml    # Main deployment with node affinity
│       ├── task_manager_api_service.yml       # Service configuration
│       ├── task_manager_eureka_deployment.yml # Eureka server deployment
│       ├── task_manager_eureka_service.yml    # Eureka service
│       ├── task_manager_gateway_deployment.yaml # Gateway deployment with node affinity
│       └── task_manager_gateway_service.yaml  # Gateway service
├── docker-compose.yml                         # Local development setup
└── README.md                                  # This file
```
