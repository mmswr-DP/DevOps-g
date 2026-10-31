# MongoDB with Web UI (Mongo Express) Docker Setup Guide

This document contains instructions to set up and manage a local MongoDB instance along with a browser-based user interface using Docker.

---

## 🚀 Quick Start (Recommended: Docker Compose)

Using a configuration file prevents typos and manages container dependencies automatically.

### 1. Create a `docker-compose.yml` file
Create an empty directory on your machine, create a file named `docker-compose.yml`, and add the following contents:

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongo
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: 123
    volumes:
      - ./custom-db:/data/db

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    ports:
      - "8081:8081"
    environment:
      ME_CONFIG_MONGODB_URL: "mongodb://root:123@mongodb:27017/?authSource=admin"
    depends_on:
      - mongodb
```

### 2. Start the Stack
Open your terminal inside that directory and run:
```bash
docker compose up -d
```

### 3. Access in Browser
Go to **`http://localhost:8081`** to manage your databases.

---

## 💻 Manual Setup (Using pure Docker Run commands)

If you prefer to start the containers individually via the terminal line-by-line, run this exact sequence:

```bash
# 1. Create a dedicated internal network
docker network create mongo-net 2>/dev/null || true

# 2. Spin up the MongoDB Database Container
docker run -d \
  -p 27017:27017 \
  --name mongo \
  --network mongo-net \
  -v ./custom-db:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME='root' \
  -e MONGO_INITDB_ROOT_PASSWORD='123' \
  mongo:latest

# 3. Wait 5 seconds for initialization, then spin up the Web UI
docker run -d \
  -p 8081:8081 \
  --name mongo-web-ui \
  --network mongo-net \
  -e ME_CONFIG_MONGODB_URL='mongodb://root:123@mongo:27017/?authSource=admin' \
  mongo-express:latest
```

---

## 🔑 Key Environment Variables Breakdown

| Variable | Application | Description |
| :--- | :--- | :--- |
| **`MONGO_INITDB_ROOT_USERNAME`** | MongoDB | Configures the administrative root username. |
| **`MONGO_INITDB_ROOT_PASSWORD`** | MongoDB | Configures the administrative root password. |
| **`ME_CONFIG_MONGODB_URL`** | Mongo Express | The exact internal connection URI string targeting your database container over the shared Docker network. |

---

## 🛠️ Troubleshooting & Commands Cheatsheet

### Clean Up / Factory Reset Everything
If you encounter **"The connection was reset"** errors or password updates aren't sticking, completely wipe the existing containers and local storage folder:
```bash
# Stop and destroy containers
docker rm -f mongo mongo-web-ui mongo-express 2>/dev/null

# Clean up the persistent storage data (Sudo might be needed on Linux)
rm -rf ./custom-db
```
*Note: A change in environment root password credentials will **not** update automatically if old data still exists inside the `./custom-db` storage directory.*

### Check Container Status
```bash
docker ps
```

### Read Container Logs (Useful for checking errors)
```bash
docker logs mongo-web-ui
```

---

## 💡 Technical Concepts Explained

* **`-v ./custom-db:/data/db`**: Maps a folder named `custom-db` in your current working directory to the container's database engine folder. This ensures your data stays safe even if the container is destroyed.
* **`2>/dev/null || true`**: A shell technique used to silence error alerts (like "network already exists") and ensure automated code blocks keep executing without crashing.
