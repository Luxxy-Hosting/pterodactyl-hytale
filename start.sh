#!/bin/bash
set -e

cd /home/container || exit 1

# Colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

SERVER_PORT="${SERVER_PORT:-5520}"
AUTH_MODE="${AUTH_MODE:-authenticated}"
ENABLE_BACKUPS="${ENABLE_BACKUPS:-false}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
BACKUP_FREQUENCY="${BACKUP_FREQUENCY:-60}"

JAVA_ARGS=()
[ "${ACCEPT_EARLY_PLUGINS}" = "true" ] && JAVA_ARGS+=(--accept-early-plugins)
[ "${ALLOW_OP}" = "true" ] && JAVA_ARGS+=(--allow-op)

if [ "${ENABLE_BACKUPS}" = "true" ]; then
  JAVA_ARGS+=(--backup)
  JAVA_ARGS+=(--backup-dir "${BACKUP_DIR}")
  JAVA_ARGS+=(--backup-frequency "${BACKUP_FREQUENCY}")
fi

# Ensure downloader exists
if [ ! -f hytale-downloader ]; then
  echo -e "${YELLOW}Hytale downloader not found. Downloading...${NC}"
  curl -sSL -o hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip >/dev/null 2>&1
  unzip -oq hytale-downloader.zip >/dev/null 2>&1
  mv hytale-downloader-linux-amd64 hytale-downloader >/dev/null 2>&1
  chmod +x hytale-downloader
  rm -f hytale-downloader-windows-amd64.exe QUICKSTART.md hytale-downloader.zip >/dev/null 2>&1
fi

# Info (clean UX)
echo -e "${BLUE}Hytale Downloader:${NC} $(./hytale-downloader -version 2>/dev/null || echo unknown)"
./hytale-downloader -check-update >/dev/null 2>&1 || true

# Ensure assets exist
if [ ! -f Assets.zip ]; then
  echo -e "${YELLOW}Assets not found.${NC}"
  echo -e "${GREEN}Authentication required to download server files.${NC}"

  ./hytale-downloader --skip-update-check || true

  while [ ! -f Assets.zip ]; do
    echo -e "${BLUE}Waiting for OAuth login...${NC}"
    sleep 5
  done
fi

# Sanity checks
if [ ! -f Server/HytaleServer.jar ]; then
  echo -e "${RED}ERROR: Server/HytaleServer.jar not found.${NC}"
  exit 1
fi

echo -e "${GREEN}Starting Hytale server...${NC}"
echo

exec java \
  -Xms128M \
  -Xmx${SERVER_MEMORY}M \
  -jar Server/HytaleServer.jar \
  --assets Assets.zip \
  --auth-mode "${AUTH_MODE}" \
  --bind "0.0.0.0:${SERVER_PORT}" \
  "${JAVA_ARGS[@]}"