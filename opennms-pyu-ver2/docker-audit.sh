#!/bin/bash
# Docker Environment Audit Script
# Purpose: Document current OpenNMS infrastructure before expansion
# Date: $(date +%Y-%m-%d)

OUTPUT_DIR="audit_output_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"

echo "========================================="
echo "Docker Environment Audit"
echo "========================================="
echo ""

# Function to create separator
separator() {
    echo "=========================================" >> "$1"
    echo "" >> "$1"
}

# 1. System Information
echo "[1/8] Collecting system information..."
{
    echo "SYSTEM INFORMATION"
    separator
    echo "Hostname: $(hostname)"
    echo "Date: $(date)"
    echo "Kernel: $(uname -r)"
    echo "Docker Version: $(docker --version)"
    echo "Docker Compose Version: $(docker-compose --version 2>/dev/null || echo 'Not installed')"
    echo ""
    echo "System Resources:"
    echo "  CPU Cores: $(nproc)"
    echo "  Total RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "  Available RAM: $(free -h | awk '/^Mem:/ {print $7}')"
    echo "  Disk Usage: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    separator
} > "$OUTPUT_DIR/01_system_info.txt"

# 2. Running Containers
echo "[2/8] Listing running containers..."
{
    echo "RUNNING CONTAINERS"
    separator
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "Detailed Container Information:"
    separator
    for container in $(docker ps --format "{{.Names}}"); do
        echo "Container: $container"
        echo "  Image: $(docker inspect --format='{{.Config.Image}}' $container)"
        echo "  Created: $(docker inspect --format='{{.Created}}' $container)"
        echo "  Status: $(docker inspect --format='{{.State.Status}}' $container)"
        echo "  IP Address: $(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container)"
        echo "  Networks: $(docker inspect --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}' $container)"
        echo "  Mounts: $(docker inspect --format='{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' $container)"
        echo ""
    done
} > "$OUTPUT_DIR/02_running_containers.txt"

# 3. All Containers (including stopped)
echo "[3/8] Listing all containers..."
{
    echo "ALL CONTAINERS (Including Stopped)"
    separator
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}"
} > "$OUTPUT_DIR/03_all_containers.txt"

# 4. Docker Networks
echo "[4/8] Documenting Docker networks..."
{
    echo "DOCKER NETWORKS"
    separator
    docker network ls
    echo ""
    echo "Network Details:"
    separator
    for network in $(docker network ls --format "{{.Name}}"); do
        echo "Network: $network"
        docker network inspect $network --format='  Driver: {{.Driver}}'
        docker network inspect $network --format='  Subnet: {{range .IPAM.Config}}{{.Subnet}}{{end}}'
        docker network inspect $network --format='  Gateway: {{range .IPAM.Config}}{{.Gateway}}{{end}}'
        echo "  Connected Containers:"
        docker network inspect $network --format='{{range $k, $v := .Containers}}    - {{$v.Name}} ({{$v.IPv4Address}}){{println}}{{end}}'
        echo ""
    done
} > "$OUTPUT_DIR/04_docker_networks.txt"

# 5. Docker Volumes
echo "[5/8] Documenting Docker volumes..."
{
    echo "DOCKER VOLUMES"
    separator
    docker volume ls
    echo ""
    echo "Volume Details:"
    separator
    for volume in $(docker volume ls --format "{{.Name}}"); do
        echo "Volume: $volume"
        echo "  Mountpoint: $(docker volume inspect $volume --format='{{.Mountpoint}}')"
        echo "  Driver: $(docker volume inspect $volume --format='{{.Driver}}')"
        echo "  Created: $(docker volume inspect $volume --format='{{.CreatedAt}}')"
        echo ""
    done
} > "$OUTPUT_DIR/05_docker_volumes.txt"

# 6. Docker Images
echo "[6/8] Listing Docker images..."
{
    echo "DOCKER IMAGES"
    separator
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
} > "$OUTPUT_DIR/06_docker_images.txt"

# 7. Docker Compose Files
echo "[7/8] Searching for docker-compose files..."
{
    echo "DOCKER COMPOSE FILES"
    separator
    find / -name "docker-compose.yml" -o -name "docker-compose.yaml" 2>/dev/null | while read file; do
        echo "Found: $file"
        echo "Content:"
        cat "$file"
        echo ""
        separator
    done
} > "$OUTPUT_DIR/07_compose_files.txt"

# 8. Container Logs Summary
echo "[8/8] Checking container logs..."
{
    echo "CONTAINER LOGS SUMMARY (Last 50 lines)"
    separator
    for container in $(docker ps --format "{{.Names}}"); do
        echo "=== Logs for: $container ==="
        docker logs --tail 50 $container 2>&1
        echo ""
        separator
    done
} > "$OUTPUT_DIR/08_container_logs.txt"

# Create summary report
echo "Creating summary report..."
{
    echo "INFRASTRUCTURE AUDIT SUMMARY"
    echo "Generated: $(date)"
    separator
    
    echo "CURRENT STATE:"
    echo "  Running Containers: $(docker ps -q | wc -l)"
    echo "  Total Containers: $(docker ps -aq | wc -l)"
    echo "  Docker Networks: $(docker network ls -q | wc -l)"
    echo "  Docker Volumes: $(docker volume ls -q | wc -l)"
    echo "  Docker Images: $(docker images -q | wc -l)"
    echo ""
    
    echo "OPENNMS COMPONENTS DETECTED:"
    docker ps --format "{{.Names}}" | grep -i opennms && echo "  ✓ OpenNMS containers found" || echo "  ✗ No OpenNMS containers detected"
    docker ps --format "{{.Names}}" | grep -i postgres && echo "  ✓ PostgreSQL found" || echo "  ✗ PostgreSQL not detected"
    docker ps --format "{{.Names}}" | grep -i activemq && echo "  ✓ ActiveMQ found" || echo "  ✗ ActiveMQ not detected"
    docker ps --format "{{.Names}}" | grep -i minion && echo "  ✓ Minion(s) found" || echo "  ✗ No Minions detected"
    echo ""
    
    echo "NETWORKS IN USE:"
    docker network ls --format "  - {{.Name}} ({{.Driver}})"
    echo ""
    
    echo "FILES GENERATED:"
    ls -lh "$OUTPUT_DIR"/*.txt | awk '{print "  - " $9 " (" $5 ")"}'
    
    separator
    echo "Next Steps:"
    echo "1. Review all generated files in: $OUTPUT_DIR"
    echo "2. Document current architecture diagram"
    echo "3. Plan VLE implementation"
    
} > "$OUTPUT_DIR/00_SUMMARY.txt"

# Create archive
echo ""
echo "Creating archive..."
tar -czf "audit_$(date +%Y%m%d_%H%M%S).tar.gz" "$OUTPUT_DIR"

echo ""
echo "========================================="
echo "Audit Complete!"
echo "========================================="
echo "Output directory: $OUTPUT_DIR"
echo "Archive created: audit_$(date +%Y%m%d_%H%M%S).tar.gz"
echo ""
echo "To view summary: cat $OUTPUT_DIR/00_SUMMARY.txt"
echo "========================================="
