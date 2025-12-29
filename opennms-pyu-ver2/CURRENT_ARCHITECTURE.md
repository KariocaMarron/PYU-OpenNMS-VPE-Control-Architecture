# Current OpenNMS Infrastructure - Documented State
**Date:** 28 December 2025  
**Project:** opennms-pyu-ver2  
**Student:** Karioka (Jose Vasconcelos)

---

## Infrastructure Overview

### Running Containers (7)

| Container Name | Image | Network | IP Address | Ports | Purpose |
|----------------|-------|---------|------------|-------|---------|
| pyu-horizon | opennms/horizon:33.0.2 | kafka_pyu-main | 172.18.0.5 | 8980, 8101 | OpenNMS Horizon Core |
| pyu-postgres | postgres:14 | kafka_pyu-main | 172.18.0.3 | 5432 | PostgreSQL Database |
| pyu-activemq | apache/activemq-classic:5.18.3 | kafka_pyu-main | 172.18.0.4 | 61616, 8161 | ActiveMQ Message Broker |
| pyu-zookeeper | confluentinc/cp-zookeeper:7.5.0 | kafka_pyu-main | 172.18.0.2 | 2181 | Zookeeper (legacy - can be removed) |
| pyu-py-server | nginx:alpine | kafka_pyu-main | 172.18.0.8 | 80 | Pyongyang Web Server (simulated) |
| hamhung-minion | opennms/minion:33.0.2 | kafka_pyu-main | 172.18.0.6 | 8201 | Hamhung Remote Minion |
| chongjin-minion | opennms/minion:33.0.2 | kafka_pyu-main | 172.18.0.7 | 8202 | Chongjin Remote Minion |

**ARCHITECTURE DECISION:** ActiveMQ chosen over Kafka due to configuration issues. Zookeeper container is legacy/orphaned and can be removed.

---

## Directory Structure

```
opennms-pyu-ver2/
├── horizon/
│   ├── docker-compose.yml          # Main OpenNMS Horizon stack
│   └── overlay/                    # OpenNMS configuration overlays
│
├── kafka/
│   └── docker-compose.yml          # Kafka + Zookeeper (Zookeeper only running)
│
├── minions/
│   ├── hamhung/
│   │   ├── docker-compose.yml
│   │   ├── minion-startup.sh
│   │   └── opennms.properties.d/
│   └── chongjin/
│       ├── docker-compose.yml
│       ├── minion-startup.sh
│       └── opennms.properties.d/
│
├── simulated-devices/
│   └── docker-compose.yml          # SNMP simulators + web server
│
└── requisitions/                   # OpenNMS node requisitions (XML)
```

---

## Messaging Architecture Decision: ActiveMQ vs Kafka

**Decision:** ActiveMQ Classic 5.18.3 ✓  
**Alternative Evaluated:** Apache Kafka + Zookeeper ✗

**Rationale:**
- Configuration issues encountered with Kafka integration
- ActiveMQ provides simpler setup for OpenNMS Minion messaging
- Proven compatibility with OpenNMS Horizon 33.0.2
- Adequate performance for academic lab environment
- Reduces architectural complexity

**Legacy Components to Remove:**
- `pyu-zookeeper` container (orphaned from Kafka attempt)
- `kafka/` directory and docker-compose.yml (no longer needed)

**Current Messaging Flow:**
```
OpenNMS Horizon (pyu-horizon)
    ↕
ActiveMQ Broker (pyu-activemq) :61616
    ↕
Minions (hamhung-minion, chongjin-minion)
```

**For Academic Report:**
- Document the architectural pivot from Kafka to ActiveMQ
- Explain troubleshooting process and decision criteria
- Demonstrate understanding of distributed messaging requirements
- This shows advanced problem-solving and architectural decision-making

---

## Network Architecture

**Single Network Design:**
- All containers connected to: `kafka_pyu-main` (bridge network)
- Subnet: 172.18.0.0/16
- No network segmentation between sites (currently flat topology)

**Implications:**
- Simple connectivity (all containers can reach each other)
- No WAN simulation between sites
- Suitable for initial setup, but not realistic for multi-site scenario

---

## Docker Compose Configuration Analysis

### 1. Horizon Stack (`horizon/docker-compose.yml`)

**Components:**
- PostgreSQL 14 (opennms/opennms)
- ActiveMQ Classic 5.18.3
- OpenNMS Horizon 33.0.2

**Key Features:**
- Uses external network: `kafka_pyu-main`
- Persistent volumes for postgres and horizon data
- Overlay configuration support
- Health checks configured

**Missing from Case Study Requirements:**
- ❌ VLE Server
- ❌ LDAP Authentication
- ❌ Ansible Tower/AWX
- ❌ FOG Server
- ❌ DNS/DHCP services

### 2. ActiveMQ Messaging Stack

**Component:**
- ActiveMQ Classic 5.18.3 ✓ (running and functional)

**Purpose:**
- Message broker for OpenNMS Minion communication
- Replaces originally planned Kafka architecture

**Configuration:**
- Port 61616: STOMP/OpenWire protocol (Minion connections)
- Port 8161: ActiveMQ Web Console
- Connected to `kafka_pyu-main` network

**Academic Value:**
- Demonstrates messaging middleware for distributed systems
- Shows troubleshooting and architectural pivoting
- Realistic enterprise messaging solution

**For Report:**
- Explain why ActiveMQ was chosen over Kafka
- Document the configuration challenges encountered
- Demonstrate understanding of distributed messaging requirements

### 3. Simulated Devices (`simulated-devices/docker-compose.yml`)

**Currently Simulated (Pyongyang):**
- ✅ py-router (tandrup/snmpsim - SNMP agent)
- ✅ py-switch (tandrup/snmpsim - SNMP agent)
- ✅ py-server (nginx:alpine - web server)

**What's Good:**
- Already using SNMP simulators (perfect for monitoring)
- Network infrastructure simulation started
- Uses same network as OpenNMS

**What's Missing:**
- No simulated devices at Hamhung
- No simulated devices at Chongjin
- No DNS/DHCP simulation
- No printer simulation

### 4. Minions (`minions/*/docker-compose.yml`)

**Deployed Minions:**
- ✅ Hamhung Minion (Location: Hamhung)
- ✅ Chongjin Minion (Location: Chongjin)

**Configuration:**
- Connected to pyu-horizon via HTTP
- Using ActiveMQ for messaging (tcp://pyu-activemq:61616)
- Each has custom startup script and properties
- Separate data volumes per site

**Status:**
- Both running and connected
- User wants to PAUSE minion work to focus on infrastructure

---

## Academic Alignment with Case Study

### ✅ Currently Implemented
1. OpenNMS network monitoring ✓
2. Containerised architecture (Docker) ✓
3. Multi-campus setup (3 locations defined) ✓
4. PostgreSQL database ✓
5. Message broker (ActiveMQ) ✓
6. Basic simulated network devices ✓

### ❌ Missing from Case Study Requirements
1. **VLE Server** (highest priority - primary student service)
2. **LDAP** (authentication for services)
3. **Ansible Tower/AWX** (configuration management)
4. **FOG Server** (PC imaging)
5. **DNS/DHCP** (network services)
6. **Remote site infrastructure** (only Minions exist, no local services)
7. **Network segmentation** (defence in depth requirement)

---

## Current Naming Convention

**Pattern Observed:**
- Pyongyang central: `pyu-<service>` (e.g., pyu-horizon, pyu-postgres)
- Remote sites: `<site>-<service>` (e.g., hamhung-minion, chongjin-minion)
- Simulated devices: `pyu-py-<device>` for Pyongyang

**Proposed Extensions:**
- Hamhung: `hh-<service>` (e.g., hh-router, hh-dns)
- Chongjin: `cj-<service>` (e.g., cj-router, cj-dns)
- OR keep full names: `hamhung-<service>`, `chongjin-<service>`

---

## Resource Usage

**Current State:**
- 7 running containers
- 109 Docker volumes (many orphaned from previous iterations?)
- 18 Docker images
- Single bridge network

**Estimated Addition:**
- VLE + supporting services: +6-8 containers
- Remote site infrastructure: +10 containers (5 per site)
- **Total projected:** ~23-25 containers

**Within Academic Lab Limits:** ✓ Yes (manageable on standard workstation)

---

## Identified Issues to Address

### 2. Legacy Network Name

**Issue:**
- Network name `kafka_pyu-main` is a legacy artifact from initial Kafka architecture
- Should be renamed to `pyu-main` for clarity

**Impact:** Low (cosmetic naming issue)

**Fix Options:**
1. Rename network in all compose files (requires recreation)
2. Keep as-is (functional, just confusing name)

**Recommendation:** Keep for now (avoid breaking changes), rename during major refactor

### 3. Orphaned Zookeeper Container

- Zookeeper (pyu-zookeeper) is running but unused
- Was intended for Kafka (now using ActiveMQ instead)
- Consuming resources unnecessarily

**Fix:** 
```bash
docker stop pyu-zookeeper
docker rm pyu-zookeeper
# Optionally remove kafka/ directory
```

### 4. No Inter-Site Network Segmentation
- All containers on one flat network
- Doesn't simulate WAN links between campuses
- **Enhancement:** Add network segmentation for realism

### 5. Volume Clutter
- 109 volumes suggests many orphaned volumes
- **Cleanup:** `docker volume prune` after backing up important data

---

## Next Steps (Proposed)

### Phase 1: VLE Implementation (PRIORITY)
1. Choose VLE platform (Moodle lightweight or simulated)
2. Add VLE to Pyongyang infrastructure
3. Configure basic authentication (standalone or LDAP later)
4. Add VLE to OpenNMS monitoring

### Phase 2: Core Services Expansion (Pyongyang)
1. LDAP server (OpenLDAP)
2. DNS/DHCP (dnsmasq or BIND9)
3. Ansible Tower (AWX community edition)
4. FOG server (lightweight container)

### Phase 3: Remote Site Infrastructure
1. Add DNS/DHCP at Hamhung
2. Add DNS/DHCP at Chongjin
3. Add simulated routers/switches at both sites
4. Add network printers (SNMP simulators)

### Phase 4: Network Enhancement (Optional)
1. Create WAN backbone network
2. Add network segmentation
3. Simulate inter-site latency/bandwidth limits

### Phase 5: Integration & Testing
1. Add all new nodes to OpenNMS requisitions
2. Configure SNMP monitoring
3. Test service discovery
4. Validate alerting

---

## Academic Justification Notes

**Why Simulation vs. Production:**
- Resource constraints (lab environment)
- Learning focus (monitoring workflows, not production deployment)
- Time constraints (academic project timeline)
- Sufficient realism (demonstrates competency without over-engineering)

**What Must Be Functional:**
- OpenNMS monitoring (fully operational) ✓
- Database persistence ✓
- SNMP device simulation (for realistic monitoring) ✓
- Service health checks ✓

**What Can Be Simplified:**
- VLE (basic Moodle or static content simulation)
- Network devices (SNMP agents, not full routing)
- DNS/DHCP (dnsmasq vs. enterprise solutions)
- Services (lightweight containers vs. production deployments)

---

**Document Status:** Complete - Based on Audit Results  
**Ready for:** Step 2 - VLE Implementation Planning
