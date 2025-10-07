#!/bin/bash

# Betty Camera - Script de ejecución Docker con soporte completo de cámara
echo "🚀 Iniciando Betty Camera Server..."

docker run -p 8001:8001 \
  --privileged \
  -v /opt/vc:/opt/vc \
  -v /dev:/dev \
  -v /sys:/sys \
  -v /proc:/proc \
  -v /run/udev:/run/udev:ro \
  -v /lib/firmware:/lib/firmware:ro \
  -v /usr/share/libcamera:/usr/share/libcamera:ro \
  --device-cgroup-rule='c 81:* rmw' \
  --device-cgroup-rule='c 235:* rmw' \
  --device-cgroup-rule='c 236:* rmw' \
  --name betty-camera-container \
  --rm \
  betty-camera:rpi

echo "🛑 Betty Camera Server detenido."