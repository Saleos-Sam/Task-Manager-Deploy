# Task Manager Deployment Repo

This repository is used to run all Task Manager microservices together via Docker Compose.

## 📦 Microservices

- `Task-Manager-Eureka` → Service discovery
- `Task-Manager-Gateway` → API gateway
- `Task-Manager` → Core business logic

## 🛠 Prerequisites

- Docker + Docker Compose installed
- Git

## 🚀 Setup

```bash
git clone https://github.com/Saleos-Sam/Task-Manager-Deploy.git
cd task-manager-deploy

# Clone the individual services
git clone https://github.com/Saleos-Sam/Task-Manager-Eureka.git eureka-server
git clone https://github.com/Saleos-Sam/Task-Manager-Gateway.git gateway
git clone https://github.com/Saleos-Sam/Task-Manager.git taskmanager

# Run all services
docker-compose up --build
