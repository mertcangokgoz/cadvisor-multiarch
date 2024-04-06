# cadvisor-multiarch

cAdvisor arm and amd64 os/arch combined in one image.

Supported OS/ARCH

- linux/arm64
- linux/amd64
- linux/arm/v7
- linux/arm/v8


Example Usage

```yaml
---
version: '3'

service:
  cadvisor:
    image: mertcangokgoz/cadvisor:latest
    hostname: cadvisor
    ports:
      - '8080:8080'
    command:
      - '--logtostderr'
      - '--allow_dynamic_housekeeping=true'
      - '--disable_metrics=referenced_memory'
      - '--docker_only=true'
      - '--profiling=true'
    restart: unless-stopped
    devices:
      - /dev/kmsg:/dev/kmsg
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    healthcheck:
      test: [ "CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1" ]
      interval: 30s
      timeout: 3s
      retries: 0
```