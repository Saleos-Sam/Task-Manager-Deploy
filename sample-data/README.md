# PostgreSQL Connection Guide

## 🎉 **STATUS: DATABASE SUCCESSFULLY POPULATED!**
- **Total Tasks**: 31 sample tasks inserted
- **Schema**: Created with proper indexes
- **Connection**: Verified and working

This guide shows you how to connect to your Kubernetes PostgreSQL database locally and work with the sample data.

## 🚀 Quick Start

### Prerequisites
1. **Port forwarding active**: `kubectl port-forward task-manager-postgres-0 5432:5432`
2. **PostgreSQL client installed** (choose one):
   - [PostgreSQL official client](https://www.postgresql.org/download/)
   - [pgAdmin](https://www.pgadmin.org/)
   - [DBeaver](https://dbeaver.io/)
   - [DataGrip](https://www.jetbrains.com/datagrip/)

### Connection Details
```
Host: localhost
Port: 5432
Database: taskdb
Username: taskuser
Password: taskpass
```

## 📋 Method 1: Automated Script (Recommended)

### Windows
```cmd
cd sample-data
connect_and_populate.bat
```

### Linux/macOS
```bash
cd sample-data
chmod +x connect_and_populate.sh
./connect_and_populate.sh
```

## 🔧 Method 2: Manual Commands

### Step 1: Set up Port Forwarding
```bash
kubectl port-forward task-manager-postgres-0 5432:5432
```

### Step 2: Connect with psql
```bash
# Set password (optional)
export PGPASSWORD=taskpass

# Connect to database
psql -h localhost -p 5432 -U taskuser -d taskdb
```

### Step 3: Create Schema
```sql
\i 01_create_tables.sql
```

### Step 4: Insert Sample Data
```sql
\i 02_insert_sample_data.sql
```

### Step 5: Verify Data
```sql
SELECT COUNT(*) FROM tasks;
SELECT status, COUNT(*) FROM tasks GROUP BY status;
```

## 🛠️ Method 3: GUI Tools

### pgAdmin
1. **Create Server**:
   - Name: `Task Manager (K8s)`
   - Host: `localhost`
   - Port: `5432`
   - Database: `taskdb`
   - Username: `taskuser`
   - Password: `taskpass`

2. **Execute Scripts**:
   - Tools → Query Tool
   - Open and run `01_create_tables.sql`
   - Open and run `02_insert_sample_data.sql`

### DBeaver
1. **New Connection** → PostgreSQL
2. **Connection Settings**:
   - Server Host: `localhost`
   - Port: `5432`
   - Database: `taskdb`
   - Username: `taskuser`
   - Password: `taskpass`
3. **Execute Scripts**: Drag and drop SQL files

## 🔍 Method 4: Direct Kubernetes Access

### Connect via kubectl exec
```bash
kubectl exec -it task-manager-postgres-0 -n task-manager -- psql -U taskuser -d taskdb -c "SELECT version();"
```

### Copy files and execute
```bash
# Copy SQL files to pod
kubectl cp 01_create_tables.sql task-manager-postgres-0:/tmp/ -n task-manager
kubectl cp 02_insert_sample_data.sql task-manager-postgres-0:/tmp/ -n task-manager

# Execute inside pod
kubectl exec -it task-manager-postgres-0 -n task-manager -- psql -U taskuser -d taskdb -f /tmp/01_create_tables.sql
kubectl exec -it task-manager-postgres-0 -n task-manager -- psql -U taskuser -d taskdb -f /tmp/02_insert_sample_data.sql
```

## 📊 Sample Data Overview

The sample data includes **30 realistic tasks** with:

### Task Categories
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

### Task Status Distribution
- ✅ **COMPLETED**: 3 tasks
- 🔄 **IN_PROGRESS**: 5 tasks
- 📋 **TODO**: 21 tasks
- ⏸️ **ON_HOLD**: 1 task

### Priority Levels
- 🚨 **URGENT**: 1 task
- 🔴 **HIGH**: 7 tasks
- 🟡 **MEDIUM**: 14 tasks
- 🟢 **LOW**: 8 tasks

### Realistic Scenarios
- **Overdue tasks** (past due dates)
- **Current sprint tasks** (due within 2 weeks)
- **Future planning** (due in months)
- **Completed tasks** with proper timestamps

## 🔍 Useful Queries

### Check overdue tasks
```sql
SELECT title, due_date, status, priority 
FROM tasks 
WHERE due_date < CURRENT_DATE AND status != 'COMPLETED'
ORDER BY due_date;
```

### Tasks by priority
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

### Tasks due this week
```sql
SELECT title, due_date, assigned_to
FROM tasks 
WHERE due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY due_date;
```

### Task completion rate by category
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

## 🚨 Troubleshooting

### Port forwarding not working
```bash
# Check if port forwarding is running
kubectl get pods | grep postgres

# Restart port forwarding
kubectl port-forward task-manager-postgres-0 5432:5432
```

### Connection refused
1. Verify PostgreSQL pod is running: `kubectl get pods`
2. Check port forwarding: `netstat -an | grep 5432`
3. Verify credentials in pod: `kubectl exec -it task-manager-postgres-0 -- env | grep POSTGRES`

### Permission denied
- Ensure the `taskuser` has proper permissions
- Check if the database `taskdb` exists
- Verify password is correct: `taskpass`

### Schema already exists
- Drop existing tables: `DROP TABLE IF EXISTS tasks CASCADE;`
- Or use the `DELETE FROM tasks;` line in the sample data script

## 🔐 Security Notes

- **Development only**: These credentials are for development
- **Production**: Use proper secrets management
- **Network**: Port forwarding exposes database locally only
- **Cleanup**: Stop port forwarding when done: `Ctrl+C`
