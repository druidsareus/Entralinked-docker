#!/bin/bash
# Entrypoint wrapper to start Entralinked service and keep systemd running

# Run systemd as PID 1
systemd_pid=$$

# Set up trap to handle signals gracefully
trap 'kill $systemd_pid' SIGTERM SIGINT

# Start the entralinked service after short delay for systemd to initialize
(
  sleep 2
  /bin/systemctl start entralinked 2>/dev/null || true
) &

# Start systemd as main process
exec /sbin/init
