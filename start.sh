#!/usr/bin/env bash
set -euo pipefail

cd /home/container

echo "Hytale Server Startup Script"
echo "-----------------------------"

# ==============================
# Environment defaults
# ==============================
SERVER_PORT="${SERVER_PORT:-5520}"
AUTH_MODE="${AUTH_MODE:-authenticated}"
ASSETS_PATH="${ASSETS_PATH:-Assets.zip}"

ACCEPT_EARLY_PLUGINS="${ACCEPT_EARLY_PLUGINS:-0}"
ALLOW_OP="${ALLOW_OP:-0}"
ENABLE_BACKUPS="${ENABLE_BACKUPS:-0}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
BACKUP_FREQUENCY="${BACKUP_FREQUENCY:-60}"

# ==============================
# Resolve toggle flags
# ==============================
EARLY_PLUGINS_FLAG=""
ALLOW_OP_FLAG=""
BACKUPS_FLAGS=""

[[ "$ACCEPT_EARLY_PLUGINS" == "1" ]] && EARLY_PLUGINS_FLAG="--accept-early-plugins"
[[ "$ALLOW_OP" == "1" ]] && ALLOW_OP_FLAG="--allow-op"

if [[ "$ENABLE_BACKUPS" == "1" ]]; then
  BACKUPS_FLAGS="--backup --backup-dir ${BACKUP_DIR} --backup-frequency ${BACKUP_FREQUENCY}"
fi

# ==============================
# Ensure downloader exists
# ==============================
if [[ ! -f "./hytale-downloader" ]]; then
  echo "Downloading Hytale downloader..."
  curl -sSL https://downloader.hytale.com/hytale-downloader.zip -o hytale-downloader.zip
  unzip -qo hytale-downloader.zip
  mv hytale-downloader-linux-amd64 hytale-downloader
  chmod +x hytale-downloader
  rm -f hytale-downloader.zip
fi

# ==============================
# Show version + update tool
# ==============================
./hytale-downloader -version || true
./hytale-downloader -check-update || true

# ==============================
# Automatic Update Logic
# ==============================
echo "Checking for Hytale updates..."

LATEST_VERSION=$(./hytale-downloader -print-version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")

INSTALLED_VERSION="none"
[[ -f ".current_version" ]] && INSTALLED_VERSION=$(cat .current_version)

echo "Current: ${INSTALLED_VERSION} | Latest: ${LATEST_VERSION}"

if [[ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]] || [[ ! -d "./Server" ]]; then
  echo "Updating server files..."

  ./hytale-downloader

  if [[ -f "${ASSETS_PATH}" ]]; then
    echo "Extracting assets..."
    unzip -qo "${ASSETS_PATH}" -d .
  fi

  echo "${LATEST_VERSION}" > .current_version
  echo "Update complete."
else
  echo "Server already up to date."
fi

# ==============================
# Verify assets + jar
# ==============================
if [[ ! -f "${ASSETS_PATH}" ]]; then
  echo "ERROR: Assets ZIP not found."
  exit 1
fi

if [[ ! -f "./Server/HytaleServer.jar" ]]; then
  echo "ERROR: HytaleServer.jar missing."
  exit 1
fi

# ==============================
# Start server
# ==============================
echo "Starting Hytale server..."

exec java \
  -Xms128M \
  -XX:MaxRAMPercentage=95.0 \
  -Dterminal.jline=false \
  -Dterminal.ansi=true \
  -jar ./Server/HytaleServer.jar \
  --assets "${ASSETS_PATH}" \
  --auth-mode "${AUTH_MODE}" \
  --bind "0.0.0.0:${SERVER_PORT}" \
  ${EARLY_PLUGINS_FLAG} \
  ${ALLOW_OP_FLAG} \
  ${BACKUPS_FLAGS} \
  --transport QUIC
