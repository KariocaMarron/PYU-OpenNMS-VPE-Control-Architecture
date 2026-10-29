# PYU-OpenNMS-VPE-Control-Architecture
Distributed OpenNMS Horizon implementation for PYU, demonstrating a VPE Control Architecture with centralised monitoring, Docker-based Minions, and SLA-driven network observability across a multi-campus environment.

## Running the lab

All credentials are local lab defaults supplied via `.env`, which is never committed. Change them before any non-lab use.

    cp .env.example .env     # then set your own values
    ./render-config.sh       # builds the OpenNMS and LDAP config files from their templates
