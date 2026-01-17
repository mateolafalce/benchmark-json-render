#!/bin/bash

# Script to setup and run json-render and toon-render dev servers
# Clones repositories, installs dependencies and runs dev servers in background

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_ENV_FILE="$SCRIPT_DIR/.env"

# Project directories
JSON_RENDER_DIR="json-render"
TOON_RENDER_DIR="toon-render"

# Repository URLs
JSON_RENDER_REPO="https://github.com/mateolafalce/json-render"
TOON_RENDER_REPO="https://github.com/mateolafalce/toon-render"

# Array to store process PIDs
PIDS=()

# Function to clean up processes on exit
cleanup() {
    echo -e "\n${YELLOW}Cleaning up processes...${NC}"
    for pid in "${PIDS[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${RED}Terminating process $pid${NC}"
            kill -9 "$pid" 2>/dev/null || true
        fi
    done
    echo -e "${GREEN}Processes terminated successfully${NC}"
    exit 0
}

# Register cleanup function to run on exit
trap cleanup EXIT INT TERM

# Function to clone or update repository
setup_repo() {
    local repo_url=$1
    local dir_name=$2
    
    if [ -d "$dir_name" ]; then
        echo -e "${YELLOW}Directory $dir_name already exists, skipping clone${NC}"
    else
        echo -e "${GREEN}Cloning $repo_url...${NC}"
        git clone "$repo_url" "$dir_name"
    fi
}

# Function to copy .env file to repository
copy_env_file() {
    local dir_name=$1
    local project_name=$2
    local target_env="$dir_name/apps/web/.env"
    
    if [ ! -f "$LOCAL_ENV_FILE" ]; then
        echo -e "${RED}Warning: Local .env file not found at $LOCAL_ENV_FILE${NC}"
        return 1
    fi
    
    # Create apps/web directory if it doesn't exist
    mkdir -p "$dir_name/apps/web"
    
    # Copy .env file
    echo -e "${GREEN}Copying .env file to $project_name...${NC}"
    cp "$LOCAL_ENV_FILE" "$target_env"
    echo -e "${GREEN}.env file copied successfully to $target_env${NC}"
}

# Function to install dependencies and run dev server
start_dev_server() {
    local dir_name=$1
    local project_name=$2
    
    echo -e "${GREEN}Setting up $project_name...${NC}"
    cd "$dir_name"
    
    # Install dependencies
    echo -e "${YELLOW}Installing dependencies with pnpm...${NC}"
    pnpm install
    
    # Run dev server in background
    echo -e "${GREEN}Starting development server for $project_name...${NC}"
    pnpm dev &
    
    # Save the process PID
    local pid=$!
    PIDS+=("$pid")
    echo -e "${GREEN}Server $project_name started with PID: $pid${NC}"
    
    # Return to previous directory
    cd ..
}

echo -e "${GREEN}=== Starting project setup ===${NC}\n"

# Setup json-render
setup_repo "$JSON_RENDER_REPO" "$JSON_RENDER_DIR"
copy_env_file "$JSON_RENDER_DIR" "json-render"
start_dev_server "$JSON_RENDER_DIR" "json-render"

echo ""

# Setup toon-render
setup_repo "$TOON_RENDER_REPO" "$TOON_RENDER_DIR"
copy_env_file "$TOON_RENDER_DIR" "toon-render"
start_dev_server "$TOON_RENDER_DIR" "toon-render"

echo -e "\n${GREEN}=== Both servers are running ===${NC}"
echo -e "${YELLOW}json-render: http://localhost:3000${NC}"
echo -e "${YELLOW}toon-render: http://localhost:2999${NC}"
echo -e "${YELLOW}Process PIDs: ${PIDS[*]}${NC}"
echo -e "\n${GREEN}To run the benchmark, execute: ./benchmark.sh${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop all processes and exit${NC}\n"

# Keep the script running
wait
