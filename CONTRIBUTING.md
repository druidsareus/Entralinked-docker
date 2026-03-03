# Contributing

## Report Issues

Found a bug? Open an issue and include:
- Docker version
- OS (Windows, Mac, Linux)
- Steps to reproduce
- Expected vs actual result
- Relevant logs

## Suggest Features

Have an idea? Open an issue with:
- What problem it solves
- How it could work
- Examples if possible

## Code Changes

### 1. Fork Repo

Click the fork button on GitHub.

### 2. Clone Fork

```bash
git clone https://github.com/YOUR_USERNAME/entralinked-docker-server.git
cd entralinked-docker-server
```

### 3. Create Branch

```bash
git checkout -b feature/my-feature
```

### 4. Make Changes

Edit files as needed.

### 5. Test Changes

```bash
docker build -t entralinked-debian-server:local .

docker run -d \
  --name test-entralinked \
  -p 53:53/tcp -p 53:53/udp \
  -p 80:80 -p 443:443 \
  -p 8080:8080 -p 29900:29900 \
  --privileged \
  entralinked-debian-server:local

docker exec test-entralinked systemctl status entralinked.service
docker logs test-entralinked
docker exec test-entralinked journalctl -u entralinked.service

docker stop test-entralinked
docker rm test-entralinked
```

### 6. Commit

```bash
git commit -m "Brief description of changes"
```

### 7. Push

```bash
git push origin feature/my-feature
```

### 8. Create Pull Request

Go to GitHub and create a pull request. Describe what you changed and why.

## Code Style

- Keep it simple
- Use clear comments for complex code
- Follow existing style
- Write clear commit messages

## Documentation Updates

If you change code, update:
- README.md for quick info
- SETUP.md for setup details
- QUICKREF.md for commands

## License

Contributions are MIT licensed.

Thanks for contributing!
