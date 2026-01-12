#!/bin/bash
set -e

cd /home/container || exit 1

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# First run: download server + assets
if [ ! -f HytaleServer.jar ]; then
  echo -e "${YELLOW}Hytale server files not found.${NC}"
  echo -e "${GREEN}Authentication required to download server files.${NC}"
  echo
  echo -e "${BLUE}When prompted below:${NC}"
  echo -e "  • Open the URL shown"
  echo -e "  • Enter the device code"
  echo -e "  • Complete login in your browser"
  echo
  echo -e "${RED}Do NOT restart the server during authentication.${NC}"
  echo

  # Run downloader (OAuth device flow)
  ./hytale-downloader --skip-update-check || true

  echo
  echo -e "${YELLOW}Waiting for authentication to complete...${NC}"

  while [ ! -f HytaleServer.jar ]; do
    echo -e "${BLUE}Still waiting for OAuth login...${NC}"
    sleep 5
  done

  echo -e "${GREEN}Authentication successful. Server files downloaded.${NC}"
  echo
fi

# Sanity check
if [ ! -f HytaleServer.jar ]; then
  echo -e "${RED}ERROR: Server files missing after authentication.${NC}"
  echo -e "${RED}Please restart the server and complete login.${NC}"
  exit 1
fi

echo -e "${GREEN}Starting Hytale server...${NC}"
echo

exec java -Xms128M -Xmx${SERVER_MEMORY}M -jar HytaleServer.jar --assets assets.zip
