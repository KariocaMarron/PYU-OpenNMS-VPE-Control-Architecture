# PYU-OpenNMS-VPE-Control-Architecture

> **Fictional case study.** "Pyongyang University (PYU)" is a fictional three-campus university used as the case study for the COM615 Network Management module at Southampton Solent University. No real organisation, network or data is involved: every system runs as a container in a local lab.

Distributed OpenNMS Horizon implementation for PYU, demonstrating a VPE Control Architecture with centralised monitoring, Docker-based Minions, and SLA-driven network observability across a multi-campus environment.

## Running the lab

All credentials are local lab defaults supplied via `.env`, which is never committed. Change them before any non-lab use.

    cp .env.example .env     # then set your own values
    ./render-config.sh       # builds the OpenNMS config file from its template
