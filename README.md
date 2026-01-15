# 📦 Pterodactyl Hytale Egg

A **production-ready Pterodactyl Egg** for hosting **Hytale** servers.  
This egg uses the **official Hytale Downloader**, handles **OAuth authentication**, extracts server files automatically, and starts the server cleanly with panel-friendly configuration.

Designed for **game server providers** and **self-hosters** who want a reliable, zero-guesswork setup.

---
## Support & Hosting 

Remember we always offer free hosting for hytale and minecraft limited to 3GB Ram And Support @ https://discord.luxxy.cloud
---

## 🚀 Features

- ✅ Automatic server download using the official Hytale Downloader
- ✅ OAuth device authentication handled at runtime
- ✅ Automatic extraction of downloaded server files
- ✅ Clean and readable console output
- ✅ Safe, panel-tested variable validation
- ✅ Optional automatic backups
- ✅ Configurable authentication modes
- ✅ Proper startup detection for Pterodactyl
- ✅ Restart-safe and update-safe
- ✅ Debian 13 + Eclipse Temurin 25 compatible

---

## 🧠 Requirements

| Component | Version |
|---------|---------|
| Pterodactyl Panel | v1.x |
| Wings | Latest |
| Install Container | `debian:13-slim` |
| Runtime Image | `ghcr.io/luxxy-gf/temurin-25:latest` |
| Java | OpenJDK 25 (Temurin) |

---

## 🛠 Installation

1. Download or clone this repository
2. Import the Egg JSON into your Pterodactyl panel
3. Create a new server using the **Hytale Egg**
4. Ensure the following settings are used:


/auth login device

AFTER YOU HAVE VERIFIED YOUR SERVER DO: /auth persistence Encrypted

## 🔐 Authentication (Required)

On the **first startup**, the Hytale server requires OAuth authentication.

### Step 1: Login

Run the following command in the **server console**:

```yaml
/auth login device
```


Follow the instructions shown:
1. Open the provided URL
2. Enter the device code
3. Complete login in your browser

⚠️ **Do not restart the server while authentication is in progress.**

---

### Step 2: Enable Authentication Persistence (IMPORTANT)

After you have **successfully verified and logged into the server**, run this command **once**:
```yaml
/auth persistence encrypted
```

This will:
- Securely store authentication credentials
- Persist authentication across restarts
- Prevent repeated OAuth login prompts

⚠️ **If this step is skipped, authentication may be lost after a restart.**
