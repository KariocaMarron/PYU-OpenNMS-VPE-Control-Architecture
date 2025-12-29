# VLE Deployment Guide - Option B (Standalone Stack)

**Approach:** Deploy VLE as separate Docker Compose stack  
**Benefit:** Existing Horizon stack remains completely untouched  
**Integration:** Connects to existing `kafka_pyu-main` network and `pyu-postgres` database

---

## Prerequisites Check

Before deploying VLE, ensure:

```bash
# 1. Horizon stack is running
docker ps | grep pyu-horizon
docker ps | grep pyu-postgres

# 2. Network exists
docker network ls | grep kafka_pyu-main

# Expected: All containers should be running and healthy
```

---

## Deployment Steps

### Step 1: Create VLE Directory

```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2

# Create VLE directory
mkdir -p vle
cd vle
```

### Step 2: Create Docker Compose File

Copy the `docker-compose.yml` file provided separately into the `vle/` directory.

Or create it manually:

```bash
cat > docker-compose.yml << 'EOF'
# [Paste the VLE docker-compose.yml content here]
EOF
```

### Step 3: Setup Database

Run the database setup script:

```bash
# Make script executable
chmod +x ../setup-vle-database.sh

# Run database setup
../setup-vle-database.sh
```

**Expected Output:**
```
✓ PostgreSQL container is running
✓ Database setup completed successfully
✓ Moodle database verified
```

**If you see errors:** The VLE container can create the database automatically, but it's slower. You can skip this step and let Moodle handle it.

### Step 4: Deploy VLE

```bash
# From the vle/ directory
docker-compose up -d

# Watch the logs
docker-compose logs -f vle
```

**What to expect:**
1. Container pulls Moodle image (~600MB) - takes 2-5 minutes
2. Moodle initializes database - takes 3-5 minutes
3. First-time setup completes - total ~5-10 minutes

**Log indicators of success:**
```
moodle 12:34:56.78 INFO  ==> ** Moodle setup finished! **
moodle 12:34:56.79 INFO  ==> ** Starting Apache **
```

### Step 5: Verify Deployment

```bash
# Check container is running
docker ps | grep pyu-vle

# Check container is healthy (wait 2-3 minutes after startup)
docker inspect pyu-vle | grep -A 5 Health

# Test HTTP access
curl -I http://localhost:8081

# Expected: HTTP/1.1 200 OK
```

### Step 6: Access VLE

**URL:** http://localhost:8081

**Login Credentials:**
- Username: `admin`
- Password: `Admin123!`

**First Login:**
1. You may see Moodle installation wizard (if database was empty)
2. Click through the setup steps (defaults are fine)
3. Create admin account when prompted
4. Complete site configuration

---

## Verification Checklist

After deployment, verify:

- [ ] Container `pyu-vle` is running
- [ ] Container shows as `(healthy)` in `docker ps`
- [ ] Port 8081 is accessible
- [ ] VLE login page loads
- [ ] Can login with admin credentials
- [ ] VLE connects to database (check: `docker exec pyu-postgres psql -U moodle -d moodle -c "\dt"`)

---

## Integration with Existing Infrastructure

### Network Connectivity

```bash
# Verify VLE is on the same network as OpenNMS
docker network inspect kafka_pyu-main | grep pyu-vle

# Expected: You should see pyu-vle listed with an IP address (e.g., 172.18.0.9)
```

### Database Sharing

```bash
# Verify VLE database exists alongside OpenNMS database
docker exec pyu-postgres psql -U postgres -c "\l"

# Expected: You should see both 'opennms' and 'moodle' databases
```

---

## Directory Structure After Deployment

```
opennms-pyu-ver2/
├── horizon/
│   ├── docker-compose.yml          # Unchanged
│   └── overlay/
├── vle/                             # NEW
│   └── docker-compose.yml          # VLE stack
├── minions/
│   ├── hamhung/
│   └── chongjin/
├── simulated-devices/
└── requisitions/
```

---

## Managing VLE

### Start VLE
```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle
docker-compose up -d
```

### Stop VLE
```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle
docker-compose down
```

### View Logs
```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle
docker-compose logs -f
```

### Restart VLE
```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle
docker-compose restart
```

### Remove VLE (if needed)
```bash
cd ~/opennms-pyu-lab/opennms-pyu-ver2/vle
docker-compose down -v  # -v removes volumes too
```

---

## Troubleshooting

### Issue: Container won't start

```bash
# Check logs for errors
docker logs pyu-vle --tail 100

# Common issues:
# - Database connection refused → Ensure pyu-postgres is running
# - Port 8081 in use → Change port in docker-compose.yml
# - Memory issues → Reduce PHP_MEMORY_LIMIT to 128M
```

### Issue: Database connection failed

```bash
# Test database connectivity from VLE container
docker exec pyu-vle pg_isready -h pyu-postgres -p 5432

# If fails, check network:
docker network inspect kafka_pyu-main | grep -E "pyu-vle|pyu-postgres"
```

### Issue: VLE shows blank page

```bash
# Check PHP errors
docker exec pyu-vle cat /opt/bitnami/moodle/error.log

# Check Apache is running
docker exec pyu-vle ps aux | grep apache

# Restart container
docker restart pyu-vle
```

### Issue: Cannot login

**Reset admin password:**
```bash
docker exec -it pyu-vle /bin/bash

# Inside container:
cd /bitnami/moodle
php admin/cli/reset_password.php
# Follow prompts to reset admin password
```

---

## Next Step: Add VLE to OpenNMS Monitoring

Once VLE is running successfully, proceed to add it to OpenNMS for monitoring.

Create: `~/opennms-pyu-lab/opennms-pyu-ver2/requisitions/vle-node.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<model-import xmlns="http://xmlns.opennms.org/xsd/config/model-import"
              date-stamp="2025-12-28T00:00:00.000Z"
              foreign-source="pyu-services">
    
    <!-- VLE Server -->
    <node foreign-id="pyu-vle" node-label="Pyongyang VLE Server">
        <interface ip-addr="pyu-vle" status="1" snmp-primary="N">
            <monitored-service service-name="ICMP"/>
            <monitored-service service-name="HTTP-8080"/>
        </interface>
        
        <category name="Production"/>
        <category name="VLE"/>
        <category name="Pyongyang"/>
    </node>
    
</model-import>
```

**Import to OpenNMS:**
1. Access OpenNMS: http://localhost:8980/opennms
2. Login: admin / admin
3. Navigate: Configure → Manage Provisioning Requisitions
4. Import the XML file
5. Click "Synchronize"
6. Verify: Info → Nodes → Search "VLE"

---

## Resource Impact

**New Resources Added:**
- Container: 1 (pyu-vle)
- RAM: ~400-500 MB
- Storage: ~2 GB (volumes)
- Network: Internal only

**Total System After VLE:**
- Containers: 7 (Horizon) + 1 (VLE) = **8 containers**
- Estimated RAM: ~4 GB total
- Well within lab limits ✓

---

## For Your Academic Report

**What to document:**
1. VLE deployment decision (Moodle as industry-standard platform)
2. Integration approach (shared database, containerised deployment)
3. Monitoring strategy (HTTP health checks, service availability)
4. Screenshots:
   - VLE login page
   - VLE dashboard
   - OpenNMS showing VLE as monitored node
   - VLE service status in OpenNMS

**Key academic points:**
- VLE is the primary student-facing service (case study requirement)
- Demonstrates realistic educational infrastructure
- Shows understanding of service dependencies (database, web server)
- Proves monitoring capability for critical services

---

## Summary

✓ **Standalone deployment** - doesn't modify existing stacks  
✓ **Shared resources** - uses existing PostgreSQL and network  
✓ **Easy rollback** - just `docker-compose down`  
✓ **Ready for monitoring** - integrates with OpenNMS  

**Status:** Ready to deploy  
**Estimated time:** 15-20 minutes (including initial setup and testing)
