FROM eclipse-temurin:17-jdk-jammy

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    netcat-openbsd \
    unzip \
    systemd \
    && rm -rf /var/lib/apt/lists/*

# Disable systemd-resolved to free up port 53 for Entralinked DNS
RUN systemctl disable systemd-resolved.service 2>/dev/null || true

# Create systemd service file
RUN mkdir -p /etc/systemd/system
COPY entralinked.service /etc/systemd/system/entralinked.service

# Download and extract Entralinked with extras (C-Gear and Pokédex skins)
RUN mkdir -p /root/entralinked && \
    cd /tmp && \
    echo "Downloading Entralinked v1.4.1 with PCN Skins..." && \
    wget -q 'https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.+PCN.Skins.zip' && \
    unzip -q 'entralinked.+PCN.Skins.zip' && \
    cp entralinked/entralinked.jar /root/entralinked/ && \
    cp entralinked/config.json /root/entralinked/ 2>/dev/null || true && \
    cp -r entralinked/skins /root/entralinked/ 2>/dev/null || true && \
    echo "Downloading base Entralinked for additional skins..." && \
    wget -q https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.zip && \
    unzip -q entralinked.zip && \
    cp -r entralinked/skins/* /root/entralinked/skins/ 2>/dev/null || true && \
    rm -rf /tmp/entralinked* && \
    echo "Entralinked installation complete:" && \
    ls -lah /root/entralinked/ && \
    echo "Skins directory:" && \
    ls -lah /root/entralinked/skins/ 2>/dev/null | head -10 || echo "Skins will be loaded from JAR"

# Expose necessary ports:
# 80/443 - HTTP/HTTPS (Dashboard)
# 29900 - GameSpy Server
# 53 - DNS Server
EXPOSE 53/udp 53/tcp 80 443 8080 29900

CMD ["/lib/systemd/systemd"]
