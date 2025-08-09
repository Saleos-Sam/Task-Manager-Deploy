@echo off
echo =====================================================
echo PostgreSQL Connection and Data Population Script
echo =====================================================
echo.
echo Prerequisites:
echo 1. kubectl port-forward is running (localhost:5432)
echo 2. PostgreSQL client (psql) is installed
echo.
echo Connection Details:
echo - Host: localhost
echo - Port: 5432
echo - Database: taskdb
echo - Username: taskuser
echo - Password: taskpass
echo.

REM Check if port forwarding is active
echo Checking if port forwarding is active...
netstat -an | findstr ":5432" >nul
if %errorlevel% neq 0 (
    echo ERROR: Port 5432 is not listening. Please run:
    echo kubectl port-forward task-manager-postgres-0 5432:5432
    echo.
    pause
    exit /b 1
)

echo ✅ Port forwarding detected on 5432
echo.

REM Set PostgreSQL password
set PGPASSWORD=taskpass

echo Step 1: Creating database schema...
psql -h localhost -p 5432 -U taskuser -d taskdb -f 01_create_tables.sql
if %errorlevel% neq 0 (
    echo ❌ Schema creation failed
    pause
    exit /b 1
)

echo ✅ Schema created successfully
echo.

echo Step 2: Inserting sample data...
psql -h localhost -p 5432 -U taskuser -d taskdb -f 02_insert_sample_data.sql
if %errorlevel% neq 0 (
    echo ❌ Data insertion failed
    pause
    exit /b 1
)

echo ✅ Sample data inserted successfully
echo.

echo Step 3: Verifying data...
psql -h localhost -p 5432 -U taskuser -d taskdb -c "SELECT COUNT(*) as total_tasks FROM tasks;"
psql -h localhost -p 5432 -U taskuser -d taskdb -c "SELECT status, COUNT(*) FROM tasks GROUP BY status;"

echo.
echo ✅ Database setup completed successfully!
echo.
echo To connect manually:
echo psql -h localhost -p 5432 -U taskuser -d taskdb
echo.
pause
