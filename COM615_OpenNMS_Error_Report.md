COM615 Coursework: Distributed Monitoring Lab - Error Report & Resolution
1. Executive Summary
Objective: Deploy OpenNMS Horizon 33.0.2 with distributed Minion architecture using external ActiveMQ broker for RPC/Sink communication.
Outcome: Critical bug discovered in OpenNMS Horizon 33.0.2 Docker image preventing external ActiveMQ broker configuration. Successfully pivoted to Apache Kafka messaging system as enterprise-grade alternative.

2. Laboratory Environment
2.1 Infrastructure Components
ComponentVersionRoleHost OSUbuntu 24.04.3 LTSPhysical hostDockerCurrent stableContainer runtimeDocker ComposeCurrent stableOrchestrationOpenNMS Horizon33.0.2Network monitoring corePostgreSQL14Database backendApache ActiveMQ5.18.3Message broker (attempted)Apache Kafka7.5.0Message broker (final solution)OpenNMS Minion33.0.2Remote poller
2.2 Network Topology
