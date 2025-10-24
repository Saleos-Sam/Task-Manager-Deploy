# Task Manager - Docker Compose Setup Guide

## 🎯 **Quick Start**

This guide will help you set up the complete Task Manager application using Docker Compose with PostgreSQL, pgAdmin, and sample data initialization.

## 📋 **Prerequisites**

- **Docker** and **Docker Compose** installed
- **Git** (to clone the repository)
- **Web browser** (for pgAdmin and application access)

## 🚀 **Step 1: Start the Application**

### **1.1 Navigate to the deployment directory**
```bash
cd Task-Manager-Deploy
```

### **1.2 Start all services**
```bash
docker-compose up -d
```

This will start:
- **Eureka Server** (Service Discovery) - `http://localhost:8761`
- **API Gateway** - `http://localhost:8080`
- **Task Manager Service** - `http://localhost:8081`
- **PostgreSQL Database** - `localhost:5432`
- **pgAdmin** (Database Management) - `http://localhost:5050`
- **Frontend** - `http://localhost:3000`

### **1.3 Verify all containers are running**
```bash
docker-compose ps
```

You should see all services with `Up` status.

## 🗄️ **Step 2: Initialize Database with Sample Data**

### **Method 1: Automated Script (Recommended)**

#### **Windows:**
```cmd
cd sample-data
connect_and_populate.bat
```

#### **Linux/macOS:**
```bash
cd sample-data
chmod +x connect_and_populate.sh
./connect_and_populate.sh
```

### **Method 2: Manual Docker Commands**

#### **Step 2.1: Copy SQL files to PostgreSQL container**
```bash
# Navigate to sample-data directory
cd sample-data

# Copy SQL files to container
docker cp 01_create_tables.sql task-manager-postgres:/tmp/
docker cp 02_insert_sample_data.sql task-manager-postgres:/tmp/
```

#### **Step 2.2: Execute SQL files**
```bash
# Create database schema
docker exec -i task-manager-postgres psql -U taskuser -d taskdb -f /tmp/01_create_tables.sql

# Insert sample data
docker exec -i task-manager-postgres psql -U taskuser -d taskdb -f /tmp/02_insert_sample_data.sql
```

#### **Step 2.3: Verify data was inserted**
```bash
# Check if data was inserted successfully
docker exec -it task-manager-postgres psql -U taskuser -d taskdb -c "SELECT COUNT(*) FROM tasks;"
```

## 🎛️ **Step 3: Access pgAdmin (Database Management)**

### **3.1 Open pgAdmin**
- **URL**: `http://localhost:5050`
- **Login Email**: `admin@admin.com`
- **Login Password**: `admin`

### **3.2 Create Database Connection**

1. **Right-click on "Servers"** → **"Create"** → **"Server..."**

2. **General Tab:**
   - **Name**: `Task Manager Database`

3. **Connection Tab:**
   - **Host name/address**: `task-manager-postgres`
   - **Port**: `5432`
   - **Maintenance database**: `taskdb`
   - **Username**: `taskuser`
   - **Password**: `taskpass`

4. **Click "Save"**

### **3.3 Verify Connection**
- Expand **"Task Manager Database"** → **"Databases"** → **"taskdb"** → **"Schemas"** → **"public"** → **"Tables"**
- You should see the `tasks` table with sample data

## 🌐 **Step 4: Access the Application**

### **4.1 Frontend Application**
- **URL**: `http://localhost:3000`
- **Features**: Task management interface, analytics, search

### **4.2 API Endpoints**
- **Gateway**: `http://localhost:8080/api/v1/tasks`
- **Direct Service**: `http://localhost:8081/api/v1/tasks`

### **4.3 Service Discovery**
- **Eureka Dashboard**: `http://localhost:8761`
- **Service Registry**: View all registered services

## 📊 **Step 5: Sample Data Overview**

The sample data includes **30+ realistic tasks** with:

### **Task Categories**
- 🔒 **Security** (2 tasks)
- 💻 **Development** (3 tasks)
- 🎨 **Frontend** (2 tasks)
- 🗄️ **Database** (2 tasks)
- 📱 **Mobile** (1 task)
- 🧪 **Testing** (3 tasks)
- 🐛 **Bug Fix** (3 tasks)
- 📚 **Documentation** (3 tasks)
- 🚀 **DevOps** (3 tasks)
- 🔬 **Research** (2 tasks)
- 🔧 **Maintenance** (3 tasks)
- 🎯 **Design** (1 task)
- ♿ **Accessibility** (1 task)
- 🎓 **Training** (1 task)

### **Task Status Distribution**
- ✅ **COMPLETED**: 3 tasks
- 🔄 **IN_PROGRESS**: 5 tasks
- 📋 **TODO**: 21 tasks
- ⏸️ **ON_HOLD**: 1 task

### **Priority Levels**
- 🚨 **URGENT**: 1 task
- 🔴 **HIGH**: 7 tasks
- 🟡 **MEDIUM**: 14 tasks
- 🟢 **LOW**: 8 tasks

## 🔍 **Step 6: Useful Queries in pgAdmin**

### **6.1 Check Overdue Tasks**
```sql
SELECT title, due_date, status, priority 
FROM tasks 
WHERE due_date < CURRENT_DATE AND status != 'COMPLETED'
ORDER BY due_date;
```

### **6.2 Tasks by Priority**
```sql
SELECT priority, COUNT(*) as count
FROM tasks 
GROUP BY priority 
ORDER BY 
    CASE priority 
        WHEN 'URGENT' THEN 1
        WHEN 'HIGH' THEN 2
        WHEN 'MEDIUM' THEN 3
        WHEN 'LOW' THEN 4
    END;
```

### **6.3 Tasks Due This Week**
```sql
SELECT title, due_date, assigned_to
FROM tasks 
WHERE due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY due_date;
```

### **6.4 Task Completion Rate by Category**
```sql
SELECT 
    category,
    COUNT(*) as total_tasks,
    COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) as completed_tasks,
    ROUND(
        COUNT(CASE WHEN status = 'COMPLETED' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as completion_rate_percent
FROM tasks 
GROUP BY category
ORDER BY completion_rate_percent DESC;
```

## 🛠️ **Step 7: Development Commands**

### **7.1 View Logs**
```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs task-manager
docker-compose logs task-manager-postgres
```

### **7.2 Restart Services**
```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart task-manager
```

### **7.3 Stop Services**
```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ This will delete all data)
docker-compose down -v
```


## 📁 **Project Structure**

```
Task-Manager-Deploy/
├── docker-compose.yml          # Main Docker Compose configuration
├── sample-data/
│   ├── 01_create_tables.sql    # Database schema
│   ├── 02_insert_sample_data.sql # Sample data
│   ├── connect_and_populate.sh # Linux/macOS script
│   ├── connect_and_populate.bat # Windows script
│   └── README.md               # Database-specific documentation
└── README.md                   # This file
```
