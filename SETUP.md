# Setup Instructions

## System Requirements

- Docker installed and running
- 512mb RAM minimum (1gb recommended)
- 500mb free disk space

## Installation

### Clone Repository

```bash
git clone https://github.com/druidsareus/entralinked-docker-server.git
cd entralinked-docker-server
```

### Verify Docker

```bash
docker --version
docker ps
```

## Build and Run

### Build Image

```bash
docker build -t entralinked-debian-server .
```

### Run Container

```bash
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --privileged \
  entralinked-debian-server
```

### Verify Running

```bash
docker ps | grep Entralinked-docker-server
docker logs -f Entralinked-docker-server
```

## Configure DS

1. Power on Nintendo DS
2. Go to System Settings (wrench icon)
3. Select Internet Settings
4. Choose your Wi-Fi network
5. Select Change Settings
6. Go to DNS Settings
7. Set Primary DNS to container IP

Find container IP:
```bash
docker inspect Entralinked-docker-server | grep '"IPAddress"'
```

Example: If output shows 172.17.0.2, use that as DNS

8. Save settings
9. Connect to Pokemon game and access Game Sync

## Access Dashboard

GUI: `http://[container-ip]/dashboard/profile.html`

Example: `http://172.17.0.2/dashboard/profile.html`

From here you can:
- Download Pokemon
- Download items
- Download C-Gear skins
- Download Pokedex skins
- Configure Game Sync settings

## Container Management

### View Logs

```bash
docker exec Entralinked-docker-server journalctl -u entralinked.service -f
```

### Restart Service

```bash
docker exec Entralinked-docker-server systemctl restart entralinked.service
```

### Check Status

```bash
docker exec Entralinked-docker-server systemctl status entralinked.service
```

### Stop Container

```bash
docker stop Entralinked-docker-server
```

### Remove Container

```bash
docker rm Entralinked-docker-server
```

## Data Persistence

Game data, DLC, and config stored in container. To keep between recreations:

```bash
# Create volume
docker volume create entralinked-data

# Run with volume
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  -v entralinked-data:/root/entralinked \
  --privileged \
  entralinked-debian-server
```

## Docker Compose

### Create docker-compose.yml

```yaml
version: '3.8'

services:
  entralinked:
    build: .
    container_name: Entralinked-docker-server
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "80:80"
      - "443:443"
      - "8080:8080"
      - "29900:29900"
    volumes:
      - entralinked-data:/root/entralinked
    privileged: true
    restart: unless-stopped

volumes:
  entralinked-data:
```

### Run

```bash
docker-compose up -d
```

### View Logs

```bash
docker-compose logs -f entralinked
```

### Stop

```bash
docker-compose down
```

## Custom Configuration

Edit config.json:

```bash
# Copy config from container
docker cp Entralinked-docker-server:/root/entralinked/config.json ./config.json

# Edit with your editor
nano config.json

# Copy back to container
docker cp ./config.json Entralinked-docker-server:/root/entralinked/config.json

# Restart service
docker exec Entralinked-docker-server systemctl restart entralinked.service
```

## Memory and CPU Limits

```bash
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --memory=1g \
  --cpus="1.0" \
  --privileged \
  entralinked-debian-server
```

## Update Image

```bash
git pull origin main
docker build -t entralinked-debian-server .
docker stop Entralinked-docker-server
docker rm Entralinked-docker-server
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --privileged \
  entralinked-debian-server
```

## Troubleshooting

### DNS Port Conflict

If you see "Address already in use" for port 53:

```bash
docker exec Entralinked-docker-server systemctl stop systemd-resolved.service
docker exec Entralinked-docker-server systemctl restart entralinked.service
```

### Container Not Starting

```bash
docker ps -a | grep Entralinked-docker-server
docker logs Entralinked-docker-server
```

### Can't Connect to Server

Verify:
- Container running: `docker ps`
- Ports mapped: `docker port Entralinked-docker-server`
- DS has correct IP
- DS and host on same network
- Firewall not blocking ports

Debug:
```bash
docker inspect Entralinked-docker-server | grep IPAddress
ping [container-ip]
nslookup pokemons.nintendomsg.com [container-ip]
```

### Dashboard Won't Load

Try:
```
http://[container-ip]:8080/dashboard/profile.html
https://[container-ip]/dashboard/profile.html
```

### High Memory Usage

```bash
docker stats Entralinked-docker-server
docker update --memory=512m Entralinked-docker-server
docker restart Entralinked-docker-server
```

## Backup

Volume backup:
```bash
docker run --rm -v entralinked-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/entralinked-backup.tar.gz /data
```

Restore:
```bash
docker run --rm -v entralinked-data:/data -v $(pwd):/backup \
  ubuntu tar xzf /backup/entralinked-backup.tar.gz -C /data
```

## Additional Resources

- Entralinked: https://github.com/kuroppoi/entralinked
- Docker Docs: https://docs.docker.com
