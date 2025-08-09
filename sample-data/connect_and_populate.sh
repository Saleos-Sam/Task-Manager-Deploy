#!/bin/bash

echo "====================================================="
echo "PostgreSQL Connection and Data Population Script"
echo "====================================================="
echo
echo "Prerequisites:"
echo "1. kubectl port-forward is running (localhost:5432)"
echo "2. PostgreSQL client (psql) is installed"
echo
echo "Connection Details:"
echo "- Host: localhost"
echo "- Port: 5432"
echo "- Database: taskdb"
echo "- Username: taskuser"
echo "- Password: taskpass"
echo

# Check if port forwarding is active
echo "Checking if port forwarding is active..."
if ! netstat -an | grep -q ":5432"; then
    echo "❌ ERROR: Port 5432 is not listening. Please run:"
    echo "kubectl port-forward task-manager-postgres-0 5432:5432"
    echo
    exit 1
fi

echo "✅ Port forwarding detected on 5432"
echo

# Set PostgreSQL password
export PGPASSWORD=taskpass

echo "Step 1: Creating database schema..."
if ! psql -h localhost -p 5432 -U taskuser -d taskdb -f 01_create_tables.sql; then
    echo "❌ Schema creation failed"
    exit 1
fi

echo "✅ Schema created successfully"
echo

echo "Step 2: Inserting sample data..."
if ! psql -h localhost -p 5432 -U taskuser -d taskdb -f 02_insert_sample_data.sql; then
    echo "❌ Data insertion failed"
    exit 1
fi

echo "✅ Sample data inserted successfully"
echo

echo "Step 3: Verifying data..."
psql -h localhost -p 5432 -U taskuser -d taskdb -c "SELECT COUNT(*) as total_tasks FROM tasks;"
psql -h localhost -p 5432 -U taskuser -d taskdb -c "SELECT status, COUNT(*) FROM tasks GROUP BY status;"

echo
echo "✅ Database setup completed successfully!"
echo
echo "To connect manually:"
echo "psql -h localhost -p 5432 -U taskuser -d taskdb"
echo
