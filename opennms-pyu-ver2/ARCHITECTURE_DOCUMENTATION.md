# University Network Monitoring Infrastructure
## Architecture Documentation

**Project:** OpenNMS Distributed Network Monitoring  
**Institution:** Three-Campus University Network  
**Date:** $(date +%Y-%m-%d)  
**Student:** Karioka  
**Module:** COM622 - Network Management

---

## 1. Executive Summary

### 1.1 Project Objectives
- Implement distributed network monitoring across three university campuses
- Deploy OpenNMS Horizon for centralized monitoring and management
- Simulate realistic university network infrastructure
- Support Virtual Learning Environment (VLE) availability monitoring

### 1.2 Campus Locations
1. **Pyongyang** - Central/Primary Campus (CIOC - Central IT Operations Centre)
2. **Hamhung** - Remote Campus
3. **Chongjin** - Remote Campus

---

## 2. Current Infrastructure State

### 2.1 Deployed Components
*(To be filled from audit results)*

**Running Containers:**
- [ ] OpenNMS Horizon Core
- [ ] PostgreSQL Database
- [ ] ActiveMQ Message Broker
- [ ] OpenNMS Minion(s)
- [ ] Other: _______________

**Docker Networks:**
- [ ] Network 1: _______________
- [ ] Network 2: _______________

**Data Persistence:**
- [ ] Volume 1: _______________
- [ ] Volume 2: _______________

### 2.2 Network Architecture
*(Diagram to be created)*

```
[Current State - To be documented]

Pyongyang (Central):
├── OpenNMS Horizon Core
├── PostgreSQL
├── ActiveMQ
└── [Other services]

Hamhung (Remote):
└── [To be documented]

Chongjin (Remote):
└── [To be documented]
```

---

## 3. Planned Infrastructure Expansion

### 3.1 Pyongyang (Central Site) - Full Implementation

**Core Services:**
1. ✓ OpenNMS Horizon Core (existing)
2. ✓ PostgreSQL Database (existing)
3. ✓ ActiveMQ Messaging (existing)
4. **NEW:** VLE Server (Moodle/simulated)
5. **NEW:** LDAP Authentication Server (OpenLDAP)
6. **NEW:** Ansible Tower/AWX (Configuration Management)
7. **NEW:** FOG Server (PC Imaging)
8. **NEW:** DNS Server (Authoritative)
9. **NEW:** DHCP Server
10. **NEW:** Core Router (SNMP-enabled)
11. **NEW:** Core Switch (SNMP-enabled)
12. **NEW:** File Server (NFS/Samba)
13. **NEW:** Firewall (pfSense/iptables)

**Rationale:**
- VLE is primary student service (highest priority per case study)
- LDAP provides centralized authentication
- Ansible Tower aligns with case study requirements
- FOG supports laboratory PC management requirement
- Network devices enable realistic monitoring scenarios

### 3.2 Hamhung (Remote Site) - Minimal Implementation

**Essential Services:**
1. **NEW:** DNS Server (dnsmasq - local caching/forwarding)
2. **NEW:** DHCP Server (dnsmasq - local subnet management)
3. **NEW:** Local Router (SNMP-enabled container)
4. **NEW:** Local Switch (SNMP-enabled container)
5. **NEW:** Network Printer (SNMP simulator)
6. **FUTURE:** OpenNMS Minion (paused for now)

**Rationale:**
- DNS/DHCP required for local subnet operation
- Router/Switch demonstrate WAN connectivity monitoring
- Printer represents endpoint device monitoring
- Minion deployment deferred to focus on infrastructure

### 3.3 Chongjin (Remote Site) - Minimal Implementation

**Essential Services:**
1. **NEW:** DNS Server (dnsmasq)
2. **NEW:** DHCP Server (dnsmasq)
3. **NEW:** Local Router (SNMP-enabled container)
4. **NEW:** Local Switch (SNMP-enabled container)
5. **NEW:** Network Printer (SNMP simulator)
6. **FUTURE:** OpenNMS Minion (paused for now)

**Rationale:**
- Mirror Hamhung configuration for consistency
- Demonstrates multi-site monitoring capability
- Keeps resource requirements manageable

---

## 4. Docker Network Design

### 4.1 Network Segmentation Strategy

**Planned Networks:**

```yaml
networks:
  # Central Campus (Pyongyang)
  pyongyang_core:
    driver: bridge
    subnet: 172.20.0.0/24
    gateway: 172.20.0.1
    
  pyongyang_services:
    driver: bridge
    subnet: 172.20.1.0/24
    gateway: 172.20.1.1
    
  # Remote Campus (Hamhung)
  hamhung_site:
    driver: bridge
    subnet: 172.21.0.0/24
    gateway: 172.21.0.1
    
  # Remote Campus (Chongjin)
  chongjin_site:
    driver: bridge
    subnet: 172.22.0.0/24
    gateway: 172.22.0.1
    
  # Inter-site WAN simulation
  wan_backbone:
    driver: bridge
    subnet: 10.0.0.0/24
    gateway: 10.0.0.1
```

### 4.2 Network Connectivity Matrix

| Source Network | Destination Network | Purpose |
|----------------|---------------------|---------|
| pyongyang_core | pyongyang_services | Monitoring & Management |
| pyongyang_core | wan_backbone | Remote site monitoring |
| hamhung_site | wan_backbone | Central connectivity |
| chongjin_site | wan_backbone | Central connectivity |

---

## 5. Implementation Phases

### Phase 1: Audit & Documentation (CURRENT)
- [x] Create audit script
- [ ] Run Docker environment audit
- [ ] Document existing architecture
- [ ] Create baseline diagram

### Phase 2: VLE Implementation (NEXT)
- [ ] Select VLE platform (Moodle or simulated)
- [ ] Deploy VLE container
- [ ] Configure LDAP integration (if using real Moodle)
- [ ] Add VLE to OpenNMS monitoring

### Phase 3: Core Services Expansion
- [ ] Deploy LDAP server
- [ ] Deploy Ansible Tower/AWX
- [ ] Deploy FOG server
- [ ] Configure service interdependencies

### Phase 4: Network Infrastructure
- [ ] Implement SNMP-enabled router containers
- [ ] Implement SNMP-enabled switch containers
- [ ] Deploy DNS/DHCP services
- [ ] Create WAN backbone network

### Phase 5: Remote Sites
- [ ] Deploy Hamhung infrastructure
- [ ] Deploy Chongjin infrastructure
- [ ] Configure inter-site routing

### Phase 6: OpenNMS Integration
- [ ] Add all new nodes to OpenNMS
- [ ] Configure SNMP monitoring
- [ ] Create service monitors
- [ ] Configure alerting

### Phase 7: Testing & Validation
- [ ] Verify monitoring functionality
- [ ] Test service dependencies
- [ ] Document monitoring workflows
- [ ] Prepare for Minion re-introduction

---

## 6. Academic Justification

### 6.1 Alignment with Case Study Requirements

| Requirement | Implementation |
|-------------|----------------|
| VLE hosting on private cloud | Containerised Moodle on Docker infrastructure |
| Network monitoring (OpenNMS) | ✓ OpenNMS Horizon deployed |
| Containerised services | ✓ Docker-based architecture |
| Load balancing consideration | Multiple container instances possible |
| Ansible/Ansible Tower | AWX community edition planned |
| FOG for PC imaging | FOG server container planned |
| Defence in depth security | Network segmentation, firewall planned |

### 6.2 Simulation vs. Production Justification

**Simulated Components:**
- Network devices (containers with SNMP, not full routing)
- Lightweight service implementations (dnsmasq vs. BIND9)
- Limited VLE functionality (if using static simulation)

**Functional Components:**
- OpenNMS monitoring (fully functional)
- PostgreSQL database (production-grade)
- LDAP authentication (functional if integrated)
- Container orchestration (real Docker)

**Academic Defence:**
This approach balances resource constraints with learning objectives. All monitoring workflows are genuine; infrastructure is simulated only where full implementation adds no educational value.

---

## 7. Resource Requirements

### 7.1 Estimated Container Count
- Pyongyang: ~13 containers
- Hamhung: ~5 containers
- Chongjin: ~5 containers
- **Total: ~23 containers**

### 7.2 Estimated Resource Usage
- **RAM:** 8-12 GB (with lightweight service choices)
- **CPU:** 4+ cores recommended
- **Storage:** 20-30 GB for volumes and images

---

## 8. Future Enhancements

1. Re-introduce OpenNMS Minions at remote sites
2. Implement Kubernetes orchestration
3. Add load balancing (HAProxy/NGINX)
4. Enhance security with IDS/IPS
5. Add log aggregation (ELK stack)
6. Implement backup/disaster recovery

---

## 9. References

- OpenNMS Horizon Documentation: https://docs.opennms.com/horizon/
- Docker Networking: https://docs.docker.com/network/
- Case Study: NetMan_CaseStudy_University_v1.docx

---

## Appendices

### Appendix A: Container Inventory
*(To be generated from audit)*

### Appendix B: Network Diagrams
*(To be created)*

### Appendix C: Configuration Files
*(To be attached)*

---

**Document Version:** 1.0  
**Last Updated:** $(date +%Y-%m-%d)  
**Status:** Draft - Awaiting Audit Results
