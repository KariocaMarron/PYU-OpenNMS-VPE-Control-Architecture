# PYU-OpenNMS-VPE-Control-Architecture

> **Fictional case study.** "Pyongyang University (PYU)" is a fictional three-campus university used as the case study for the COM615 Network Management module at Southampton Solent University. No real organisation, network or data is involved: every system runs as a container in a local lab.

Earlier version of a distributed OpenNMS Horizon monitoring lab, built for COM615 Network Management in December 2025. It records the first architecture and how a messaging fault between the central server and a remote collector was diagnosed.

The current, complete lab is in **[opennms-pyu-monitoring](https://github.com/KariocaMarron/opennms-pyu-monitoring)**.

## My role

Team project with four members. I was responsible for OpenNMS monitoring and alerting.

## Architecture

```
Central site (Pyongyang CIOC)            Remote site (Hamhung)
OpenNMS Horizon 33.0.2 + PostgreSQL 14   OpenNMS Minion 33.0.2
            \                              /
             Apache Kafka + ZooKeeper (7.5.0)
```

| Folder | Contents |
|--------|----------|
| `horizon/` | OpenNMS Horizon and PostgreSQL |
| `kafka/` | Kafka and ZooKeeper (Confluent images) |
| `minions/` | Hamhung Minion with simulated router, web and DNS services |
| `test-services/` | Main campus router, NGINX web server and DNS |

## The messaging fault and how it was diagnosed

The first design connected Horizon and the Minion through an external Apache ActiveMQ broker. Horizon failed to start its broker connection with a `ConditionalActiveMQContext` error.

- Four configuration approaches were tried: environment variables, overlay property files, the documented property names, and a single consolidated file. The error persisted in each case.
- The fault was isolated with Karaf health checks, an RPC stress test (5 of 5 requests failed), ActiveMQ queue inspection and `netstat`. The Minion reached the broker; Horizon did not.
- The messaging layer was switched to Apache Kafka, which OpenNMS supports for Minion communication.

The later lab in [opennms-pyu-monitoring](https://github.com/KariocaMarron/opennms-pyu-monitoring) uses a different, working ActiveMQ configuration.

Full write-up: [COM615_OpenNMS_Error_Report.md](COM615_OpenNMS_Error_Report.md)

## Status and limitations

- Archived for reference; not maintained.
- Two files used by the Minion (`hamhung-custom.properties` and `minion-startup.sh`) are not included, so this version does not run on its own. Use [opennms-pyu-monitoring](https://github.com/KariocaMarron/opennms-pyu-monitoring) for a working lab.

## Configuration

All credentials are local lab defaults supplied via `.env`, which is never committed. Change them before any non-lab use.

    cp .env.example .env     # then set your own values
    ./render-config.sh       # builds the OpenNMS config file from its template
