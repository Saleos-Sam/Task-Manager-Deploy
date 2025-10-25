#!/bin/bash

# 🚀 Deploy script for Task Manager application
set -e

# === Paths ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "SCRIPT_DIR: $SCRIPT_DIR"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
echo "PROJECT_DIR: $PROJECT_DIR"
K8S_DIR="$PROJECT_DIR/dev/k8s"
echo "K8S_DIR: $K8S_DIR"
SAMPLE_DATA_DIR="$PROJECT_DIR/sample-data"
echo "SAMPLE_DATA_DIR: $SAMPLE_DATA_DIR"
CONFIG_FILE="$PROJECT_DIR/dev-config.env"
echo "CONFIG_FILE: $CONFIG_FILE"

NAMESPACE="task-manager"
REGISTRY="ghcr.io"
ORG_NAME="saleos-sam"

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Task Manager deployment...${NC}"
echo -e "${YELLOW}📁 Project directory: $PROJECT_DIR${NC}"
echo -e "${YELLOW}📁 K8s directory: $K8S_DIR${NC}"
echo -e "${YELLOW}📁 Sample data directory: $SAMPLE_DATA_DIR${NC}"

# === Check dev-config.env ===
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Configuration file not found: $CONFIG_FILE${NC}"
    echo -e "${YELLOW}📝 Please create dev-config.env from the example:${NC}"
    echo -e "${YELLOW}   cp dev-config.env.example dev-config.env${NC}"
    echo -e "${YELLOW}   # Edit dev-config.env with your desired image tags${NC}"
    exit 1
fi

# === Load configuration ===
echo -e "${YELLOW}📋 Loading configuration from dev-config.env...${NC}"
source "$CONFIG_FILE"

# Validate required tags
if [ -z "$FRONTEND_TAG" ] || [ -z "$API_TAG" ] || [ -z "$GATEWAY_TAG" ] || [ -z "$EUREKA_TAG" ]; then
    echo -e "${RED}❌ Missing required tags in dev-config.env${NC}"
    echo -e "${YELLOW}   Required: FRONTEND_TAG, API_TAG, GATEWAY_TAG, EUREKA_TAG${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Configuration loaded:${NC}"
echo -e "   Frontend: ${YELLOW}$FRONTEND_TAG${NC}"
echo -e "   API: ${YELLOW}$API_TAG${NC}"
echo -e "   Gateway: ${YELLOW}$GATEWAY_TAG${NC}"
echo -e "   Eureka: ${YELLOW}$EUREKA_TAG${NC}"

# === Function to get image reference ===
get_image_reference() {
    local service_name=$1
    local tag=$2
    local image_base="${REGISTRY}/${ORG_NAME}/${service_name}"
    
    # Check if tag starts with "sha-"
    if [[ $tag == sha-* ]]; then
        # Extract SHA (remove "sha-" prefix)
        local sha="${tag#sha-}"
        echo "${image_base}@sha256:${sha}"
    else
        # Use regular tag
        echo "${image_base}:${tag}"
    fi
}

# === Build image references ===
FRONTEND_IMAGE=$(get_image_reference "task-manager-frontend" "$FRONTEND_TAG")
API_IMAGE=$(get_image_reference "task-manager-api" "$API_TAG")
GATEWAY_IMAGE=$(get_image_reference "task-manager-gateway" "$GATEWAY_TAG")
EUREKA_IMAGE=$(get_image_reference "task-manager-eureka" "$EUREKA_TAG")

echo -e "${GREEN}📦 Image references:${NC}"
echo -e "   Frontend: ${YELLOW}$FRONTEND_IMAGE${NC}"
echo -e "   API: ${YELLOW}$API_IMAGE${NC}"
echo -e "   Gateway: ${YELLOW}$GATEWAY_IMAGE${NC}"
echo -e "   Eureka: ${YELLOW}$EUREKA_IMAGE${NC}"

# === Check kubectl ===
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# === Ensure namespace ===
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo -e "${YELLOW}📦 Creating namespace: $NAMESPACE${NC}"
    kubectl create namespace $NAMESPACE
fi

# === Check registry secret ===
echo -e "${YELLOW}🔐 Checking registry secret...${NC}"
if kubectl get secret ghcr-creds -n $NAMESPACE &> /dev/null; then
    echo -e "${GREEN}✅ Registry secret 'ghcr-creds' found${NC}"
else
    echo -e "${RED}❌ Registry secret 'ghcr-creds' not found!${NC}"
    echo -e "${YELLOW}📝 Please create it manually using:${NC}"
    echo -e "${YELLOW}   kubectl create secret docker-registry ghcr-creds \\${NC}"
    echo -e "${YELLOW}     --docker-server=ghcr.io \\${NC}"
    echo -e "${YELLOW}     --docker-username=your-github-username \\${NC}"
    echo -e "${YELLOW}     --docker-password=your-github-token \\${NC}"
    echo -e "${YELLOW}     --docker-email=your-email@example.com \\${NC}"
    echo -e "${YELLOW}     -n $NAMESPACE${NC}"
    exit 1
fi

# === Deploy PostgreSQL ===
echo -e "${YELLOW}🗄️ Deploying PostgreSQL...${NC}"
kubectl apply -f $K8S_DIR/task_manager_postgres_statefulset.yml
kubectl apply -f $K8S_DIR/task_manager_postgres_service.yml

echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=task-manager-postgres -n $NAMESPACE --timeout=300s

# === Deploy Eureka ===
echo -e "${YELLOW}🔍 Deploying Eureka Server...${NC}"
sed "s|image:.*task-manager-eureka.*|image: $EUREKA_IMAGE|g" $K8S_DIR/task_manager_eureka_deployment.yml | kubectl apply -f -
kubectl apply -f $K8S_DIR/task_manager_eureka_service.yml

echo -e "${YELLOW}⏳ Waiting for Eureka to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=task-manager-eureka -n $NAMESPACE --timeout=300s

# === Deploy API Gateway ===
echo -e "${YELLOW}🌐 Deploying API Gateway...${NC}"
sed "s|image:.*task-manager-gateway.*|image: $GATEWAY_IMAGE|g" $K8S_DIR/task_manager_gateway_deployment.yaml | kubectl apply -f -
kubectl apply -f $K8S_DIR/task_manager_gateway_service.yaml

# === Deploy Task Manager API ===
echo -e "${YELLOW}📋 Deploying Task Manager API...${NC}"
sed "s|image:.*task-manager-api.*|image: $API_IMAGE|g" $K8S_DIR/task_manager_api_deployment.yml | kubectl apply -f -
kubectl apply -f $K8S_DIR/task_manager_api_service.yml

# === Deploy Frontend ===
echo -e "${YELLOW}🎨 Deploying Frontend...${NC}"
sed "s|image:.*task-manager-frontend.*|image: $FRONTEND_IMAGE|g" $K8S_DIR/task_manager_frontend_deployment.yml | kubectl apply -f -
kubectl apply -f $K8S_DIR/task_manager_frontend_service.yml

# === Wait for all deployments ===
echo -e "${YELLOW}⏳ Waiting for all deployments to be ready...${NC}"
kubectl wait --for=condition=available deployment --all -n $NAMESPACE --timeout=600s

# === Populate PostgreSQL sample data ===
echo -e "${YELLOW}📦 Copying and populating sample data into PostgreSQL...${NC}"

POSTGRES_POD=$(kubectl get pods -n $NAMESPACE -l app=task-manager-postgres -o jsonpath="{.items[0].metadata.name}")
echo "POSTGRES_POD: $POSTGRES_POD"

cd $SAMPLE_DATA_DIR

kubectl cp -n $NAMESPACE "01_create_tables.sql" "$POSTGRES_POD:/tmp/01_create_tables.sql"
kubectl cp -n $NAMESPACE "02_insert_sample_data.sql" "$POSTGRES_POD:/tmp/02_insert_sample_data.sql"

echo -e "${YELLOW}🧩 Executing SQL scripts inside PostgreSQL pod...${NC}"
kubectl exec -it -n "$NAMESPACE" "$POSTGRES_POD" -- sh -c "psql -U taskuser -d taskdb -f /tmp/01_create_tables.sql"
kubectl exec -it -n "$NAMESPACE" "$POSTGRES_POD" -- sh -c "psql -U taskuser -d taskdb -f /tmp/02_insert_sample_data.sql"

echo -e "${GREEN}✅ Sample data successfully populated!${NC}"

# === Deployment Summary ===
echo -e "${GREEN}✅ Deployment completed!${NC}"
kubectl get services -n $NAMESPACE

echo -e "${GREEN}🔗 Access URLs:${NC}"
echo "Frontend: http://localhost:3000"
echo "API Gateway: http://localhost:8080"
echo "Eureka Dashboard: http://localhost:8761"
echo "PostgreSQL: localhost:5432"

echo -e "${GREEN}🎉 Task Manager is now running with sample data!${NC}"
