#!/bin/bash
# VLE Database Setup Script
# Creates Moodle database and user in existing pyu-postgres container

echo "=========================================="
echo "VLE Database Setup for Pyongyang University"
echo "=========================================="
echo ""

# Check if PostgreSQL container is running
if ! docker ps | grep -q pyu-postgres; then
    echo "ERROR: pyu-postgres container is not running!"
    echo "Please start the Horizon stack first:"
    echo "  cd ~/opennms-pyu-lab/opennms-pyu-ver2/horizon"
    echo "  docker-compose up -d"
    exit 1
fi

echo "✓ PostgreSQL container is running"
echo ""

# Create Moodle database and user
echo "Creating Moodle database and user..."

docker exec pyu-postgres psql -U opennms -d postgres << 'EOF'
-- Create Moodle database if it doesn't exist
SELECT 'CREATE DATABASE moodle'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'moodle')\gexec

-- Create Moodle user if it doesn't exist
DO
$$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'moodle') THEN
      CREATE USER moodle WITH PASSWORD 'moodle';
   END IF;
END
$$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE moodle TO moodle;
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Database setup completed successfully"
    echo ""
    echo "Database Details:"
    echo "  Host: pyu-postgres"
    echo "  Port: 5432"
    echo "  Database: moodle"
    echo "  User: moodle"
    echo "  Password: moodle"
    echo ""
else
    echo ""
    echo "✗ Database setup failed!"
    echo "Please check the error messages above."
    exit 1
fi

# Verify database was created
echo "Verifying database creation..."
docker exec pyu-postgres psql -U postgres -c "\l" | grep moodle

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Moodle database verified"
    echo ""
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Deploy VLE: cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle && docker-compose up -d"
    echo "2. Watch logs: docker logs -f pyu-vle"
    echo "3. Access VLE: http://localhost:8081"
    echo ""
else
    echo ""
    echo "⚠ Warning: Could not verify database creation"
    echo "VLE deployment may still work. Monitor logs carefully."
    echo ""
fi
