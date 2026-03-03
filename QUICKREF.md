# Command Reference

## Build and Run

```bash
docker build -t entralinked-debian-server .

docker run -d \
  --name Entralinked-docker-server \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --privileged \
  entralinked-debian-server

docker-compose up -d
```

## Container Control

```bash
docker ps
docker logs -f Entralinked-docker-server
docker stop Entralinked-docker-server
docker rm Entralinked-docker-server
docker restart Entralinked-docker-server
```

## Service Control

```bash
docker exec Entralinked-docker-server systemctl start entralinked.service
docker exec Entralinked-docker-server systemctl stop entralinked.service
docker exec Entralinked-docker-server systemctl restart entralinked.service
docker exec Entralinked-docker-server systemctl status entralinked.service
docker exec Entralinked-docker-server journalctl -u entralinked.service -f
```

## Info

```bash
docker ps | grep Entralinked-docker-server
docker inspect Entralinked-docker-server | grep '"IPAddress"'
docker port Entralinked-docker-server
docker stats Entralinked-docker-server
```

## Volumes

```bash
docker volume create entralinked-data
docker volume ls
docker volume inspect entralinked-data

# Backup
docker run --rm -v entralinked-data:/data -v $(pwd):/backup \
  ubuntu tar czf /backup/entralinked-backup.tar.gz /data

# Restore
docker run --rm -v entralinked-data:/data -v $(pwd):/backup \
  ubuntu tar xzf /backup/entralinked-backup.tar.gz -C /data
```

## Troubleshooting

```bash
docker logs Entralinked-docker-server
docker exec -it Entralinked-docker-server bash
docker exec Entralinked-docker-server systemctl stop systemd-resolved.service
docker exec Entralinked-docker-server systemctl restart entralinked.service
```

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 53 | TCP/UDP | DNS Server |
| 80 | TCP | HTTP Dashboard |
| 443 | TCP | HTTPS Dashboard |
| 8080 | TCP | Alt HTTP |
| 29900 | TCP/UDP | GameSpy Server |

## Files

```
Dockerfile              Container definition
entralinked.service     Systemd service
docker-compose.yml      Docker Compose config
README.md               Overview
SETUP.md                Installation guide
LICENSE                 MIT License
```
