#!/bin/bash
set -e

#############################################################
#  Whatbot Playbook Site — Deploy Script
#  Static playbook demo served by nginx in Docker.
#  Default host port: 6200 (for Nginx Proxy Manager).
#############################################################

IMAGE_NAME="whatbot-playbook"
IMAGE_TAG="latest"
CONTAINER_NAME="whatbot-playbook"
HOST_PORT="${PLAYBOOK_PORT:-6200}"
COMPOSE_FILE="docker-compose.yml"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     ${BOLD}Whatbot Playbook Site — Deploy${NC}${CYAN}            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
}

preflight() {
    echo -e "${YELLOW}► Pre-flight checks...${NC}"

    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✘ Docker is not installed.${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✔${NC} Docker installed"

    if ! docker info &> /dev/null 2>&1; then
        echo -e "${RED}✘ Docker daemon is not running.${NC}"
        exit 1
    fi
    echo -e "  ${GREEN}✔${NC} Docker daemon running"
    echo ""
}

show_help() {
    header
    echo -e "${BOLD}Usage:${NC} ./deploy.sh [COMMAND]"
    echo ""
    echo -e "${BOLD}Commands:${NC}"
    echo "  deploy       Build image and start container (default)"
    echo "  build        Build the Docker image only"
    echo "  start        Start container via docker compose"
    echo "  stop         Stop container"
    echo "  restart      Restart container"
    echo "  logs         Follow container logs"
    echo "  status       Show container status"
    echo "  destroy      Stop and remove container"
    echo "  rebuild      Full rebuild and restart"
    echo "  help         Show this help"
    echo ""
    echo -e "${BOLD}Environment:${NC}"
    echo "  PLAYBOOK_PORT   Host port (default: 6200)"
    echo ""
    echo -e "${BOLD}Nginx Proxy Manager:${NC}"
    echo "  Scheme: http"
    echo "  Forward Hostname/IP: 127.0.0.1"
    echo "  Forward Port: ${HOST_PORT}"
    echo "  Websockets: not required (static site)"
    echo ""
}

compose() {
    if docker compose version &> /dev/null 2>&1; then
        docker compose -f "${COMPOSE_FILE}" "$@"
    elif command -v docker-compose &> /dev/null; then
        docker-compose -f "${COMPOSE_FILE}" "$@"
    else
        echo -e "${RED}Docker Compose not found.${NC}"
        exit 1
    fi
}

build_image() {
    echo -e "${YELLOW}► Building ${IMAGE_NAME}:${IMAGE_TAG}...${NC}"
    compose build --pull
    echo -e "${GREEN}✔ Image built.${NC}"
}

start_stack() {
    echo -e "${YELLOW}► Starting on port ${HOST_PORT}...${NC}"
    PLAYBOOK_PORT="${HOST_PORT}" compose up -d
    print_access_info
}

stop_stack() {
    echo -e "${YELLOW}► Stopping stack...${NC}"
    compose down
    echo -e "${GREEN}✔ Stopped.${NC}"
}

print_access_info() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Whatbot Playbook Site is running${NC}"
    echo -e ""
    echo -e "  ${BOLD}Local:${NC}   http://localhost:${HOST_PORT}"
    echo -e "  ${BOLD}Pages:${NC}   /index.html, /playbook.html, /playbook-th.html"
    echo -e "  ${BOLD}Logs:${NC}    ./deploy.sh logs"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
}

show_logs() {
    compose logs -f --tail 100
}

show_status() {
    compose ps
}

ACTION="${1:-deploy}"

case "${ACTION}" in
    deploy)
        header
        preflight
        build_image
        start_stack
        ;;
    build)
        header
        preflight
        build_image
        ;;
    start)
        header
        preflight
        start_stack
        ;;
    stop)
        header
        stop_stack
        ;;
    restart)
        header
        stop_stack
        start_stack
        ;;
    logs)
        show_logs
        ;;
    status)
        header
        show_status
        ;;
    destroy)
        header
        stop_stack
        ;;
    rebuild)
        header
        preflight
        stop_stack
        build_image
        start_stack
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: ${ACTION}${NC}"
        show_help
        exit 1
        ;;
esac
