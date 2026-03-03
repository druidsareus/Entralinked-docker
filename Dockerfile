# Build stage: Download and prepare Entralinked files
FROM alpine:3.19 AS downloader
RUN apk add --no-cache wget unzip
WORKDIR /tmp

RUN echo "Downloading Entralinked v1.4.1 with PCN Skins..." && \
    wget -q 'https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.+PCN.Skins.zip' && \
    unzip -q 'entralinked.+PCN.Skins.zip' && \
    mkdir -p /build/entralinked && \
    cp entralinked/entralinked.jar /build/entralinked/ && \
    cp entralinked/config.json /build/entralinked/ 2>/dev/null || true && \
    cp -r entralinked/skins /build/entralinked/ 2>/dev/null || true && \
    rm -rf /tmp/entralinked* && \
    echo "Downloading base Entralinked for additional skins..." && \
    wget -q https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.zip && \
    unzip -q entralinked.zip && \
    cp -r entralinked/skins/* /build/entralinked/skins/ 2>/dev/null || true && \
    rm -rf /tmp/* && \
    echo "✓ Entralinked downloaded and prepared"

# Runtime stage
FROM eclipse-temurin:17-jdk-jammy

# Install minimal runtime dependencies only (removed wget, unzip - not needed at runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    netcat-openbsd \
    systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Disable systemd-resolved to free up port 53 for Entralinked DNS
RUN systemctl disable systemd-resolved.service 2>/dev/null || true

# Copy systemd service file
COPY entralinked.service /etc/systemd/system/entralinked.service
RUN systemctl enable entralinked.service 2>&1

# Copy Entralinked files from downloader stage
COPY --from=downloader /build/entralinked /root/entralinked

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose necessary ports:
# 53 - DNS Server (UDP/TCP)
# 80/443 - HTTP/HTTPS Dashboard
# 8080 - Alternative HTTP
# 29900 - GameSpy Server
EXPOSE 53/udp 53/tcp 80 443 8080 29900

ENTRYPOINT ["/entrypoint.sh"]
