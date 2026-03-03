# Entralinked Docker Server

A Docker container for running Entralinked, a Game Sync emulator for Pokemon Black & White.

## Quick Start

```bash
# Clone repo
git clone https://github.com/druidsareus/entralinked-docker-server.git
cd entralinked-docker-server

# Build image
docker build -t entralinked-debian-server .

# Run container
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --privileged \
  entralinked-debian-server

# Check logs
docker logs -f Entralinked-docker-server
```

## Container Requirements

- Docker
- 512mb RAM (1gb recommended)
- 500mb disk space

## Port Mapping

| Port | Protocol | Purpose |
|------|----------|---------|
| 53 | TCP/UDP | DNS Server |
| 80 | TCP | HTTP Dashboard |
| 443 | TCP | HTTPS Dashboard |
| 8080 | TCP | Alt HTTP |
| 29900 | TCP/UDP | GameSpy Server |

## Accessing Dashboard

Game Sync GUI: `http://[container-ip]/dashboard/profile.html`

To find container IP:
```bash
docker inspect Entralinked-docker-server | grep '"IPAddress"'
```

## Control Container

Start service:
```bash
docker exec Entralinked-docker-server systemctl start entralinked.service
```

Check status:
```bash
docker exec Entralinked-docker-server systemctl status entralinked.service
```

View logs:
```bash
docker exec Entralinked-docker-server journalctl -u entralinked.service -f
```

Stop service:
```bash
docker exec Entralinked-docker-server systemctl stop entralinked.service
```

## Nintendo DS Setup

1. Go to System Settings on DS
2. Open Internet Settings
3. Select your Wi-Fi
4. Go to DNS Settings
5. Set Primary DNS to container IP
6. Save and connect to game

## Data Persistence

To keep data between container recreations, use a volume:

```bash
docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  -v entralinked-data:/root/entralinked \
  --privileged \
  entralinked-debian-server
```

## Using Docker Compose

Create docker-compose.yml:

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

Run with:
```bash
docker-compose up -d
```

## Troubleshooting

DNS port conflict:
```bash
docker exec Entralinked-docker-server systemctl stop systemd-resolved.service
docker exec Entralinked-docker-server systemctl restart entralinked.service
```

Container not running:
```bash
docker ps | grep Entralinked-docker-server
docker logs Entralinked-docker-server
```

Dashboard not loading:
- Try alternate port: `http://[ip]:8080/dashboard/profile.html`
- Try HTTPS: `https://[ip]/dashboard/profile.html` (self-signed cert)

## License

MIT License
