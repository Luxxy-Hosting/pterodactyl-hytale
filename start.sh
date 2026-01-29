#!/usr/bin/env bash
set -euo pipefail

cd /home/container

# ==============================
# Colors (ANSI)
# ==============================
COLOR_RESET="\033[0m"
COLOR_BOLD="\033[1m"
COLOR_BLUE="\033[34m"
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"

log_info() { printf "%b\n" "${COLOR_BLUE}$1${COLOR_RESET}"; }
log_ok() { printf "%b\n" "${COLOR_GREEN}$1${COLOR_RESET}"; }
log_warn() { printf "%b\n" "${COLOR_YELLOW}$1${COLOR_RESET}"; }
log_err() { printf "%b\n" "${COLOR_RED}$1${COLOR_RESET}"; }

printf "%b\n" "${COLOR_BOLD}Hytale Server Startup Script${COLOR_RESET}"
printf "%b\n" "${COLOR_BOLD}-----------------------------${COLOR_RESET}"

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
AUTO_START="${AUTO_START:-1}"

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
  log_info "Downloading Hytale downloader..."
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
if [[ "$AUTO_START" == "1" ]]; then
  log_info "Checking for Hytale updates..."

  LATEST_VERSION=$(./hytale-downloader -print-version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")

  INSTALLED_VERSION="none"
  [[ -f ".current_version" ]] && INSTALLED_VERSION=$(cat .current_version)

  printf "%b\n" "${COLOR_BOLD}Current:${COLOR_RESET} ${INSTALLED_VERSION} ${COLOR_BOLD}| Latest:${COLOR_RESET} ${LATEST_VERSION}"

  if [[ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]] || [[ ! -d "./Server" ]]; then
    log_warn "Updating server files..."

    ./hytale-downloader

    if [[ -f "${ASSETS_PATH}" ]]; then
      log_info "Extracting assets..."
      unzip -qo "${ASSETS_PATH}" -d .
    fi

    echo "${LATEST_VERSION}" > .current_version
    log_ok "Update complete."
  else
    log_ok "Server already up to date."
  fi
else
  log_warn "Auto update disabled (AUTO_START=0)."
  if [[ ! -d "./Server" ]]; then
    log_err "Server files not found. Enable auto update or run the downloader manually."
    exit 1
  fi
fi

# ==============================
# Verify assets + jar
# ==============================
if [[ ! -f "${ASSETS_PATH}" ]]; then
  log_err "ERROR: Assets ZIP not found."
  exit 1
fi

if [[ ! -f "./Server/HytaleServer.jar" ]]; then
  log_err "ERROR: HytaleServer.jar missing."
  exit 1
fi

# ==============================
# Start server
# ==============================
log_ok "Starting Hytale server..."

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
