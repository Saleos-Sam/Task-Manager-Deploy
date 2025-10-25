# Development Workflow Guide

## Overview

This guide explains how to deploy specific branches or commits to your Minikube cluster for development and testing.

## How It Works

### 1. **CI/CD Pipeline** (Automatic)

When you push code to any branch in your service repositories, GitHub Actions automatically:

- Builds a Docker image
- Pushes it to GHCR with multiple tags:
  - **Branch name**: `feature-new-ui`, `master`, `develop`
  - **SHA tag**: `sha-89b4ddb` (commit hash)
  - **Latest**: `latest` (only for master/main branch)

**Example:**
```bash
# Push to feature branch
git checkout -b feature/new-ui
git push origin feature/new-ui

# Creates images:
ghcr.io/saleos-sam/task-manager-frontend:feature-new-ui
ghcr.io/saleos-sam/task-manager-frontend:sha-89b4ddb
```

### 2. **Local Deployment** (Manual)

Update `dev-config.env` with the tags you want to deploy, then run the deploy script.

## Quick Start

### Step 1: Create Configuration File

```bash
cd Task-Manager-Deploy
cp dev-config.env.example dev-config.env
```

### Step 2: Edit Configuration

Edit `dev-config.env` with your desired image tags:

```bash
# Example: Deploy feature branch for frontend, master for others
FRONTEND_TAG=feature-new-ui
API_TAG=master
GATEWAY_TAG=master
EUREKA_TAG=master
```

### Step 3: Deploy

```bash
./scripts/deploy.sh
```