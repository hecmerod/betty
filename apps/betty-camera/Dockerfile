FROM balenalib/raspberrypi4-64-debian:bookworm

# Variables de entorno para Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Instalar Python y dependencias básicas del sistema
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    gcc \
    g++ \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libcap-dev \
    cmake \
    wget \
    gnupg \
    git \
    make \
    build-essential \
    libvulkan-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Agregar repositorio de Raspberry Pi para libcamera
RUN wget -qO - https://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add - && \
    echo "deb https://archive.raspberrypi.org/debian/ bookworm main" >> /etc/apt/sources.list.d/raspi.list && \
    apt-get update && \
    apt-get install -y python3-picamera2 python3-libcamera libcamera-apps || \
    echo "Raspberry Pi packages not available, will use pip version"

WORKDIR /app

# Copiar archivos de dependencias
COPY apps/betty-camera/requirements.txt ./
COPY apps/betty-camera/requirements-basic.txt ./

# Instalar dependencias de Python (con --break-system-packages para entornos gestionados)
RUN python3 -m pip install --no-cache-dir --break-system-packages --upgrade pip setuptools wheel

# Instalar dependencias básicas (incluye uvicorn y fastapi)
RUN python3 -m pip install --no-cache-dir --break-system-packages -r requirements-basic.txt

# Instalar ultralytics para YOLO
RUN python3 -m pip install --no-cache-dir --break-system-packages ultralytics

# Instalar PyJWT para autenticación
RUN python3 -m pip install --no-cache-dir --break-system-packages PyJWT

# Instalar ncnn para modelos YOLO NCNN
RUN python3 -m pip install --no-cache-dir --break-system-packages git+https://github.com/Tencent/ncnn.git

# Reinstalar numpy para evitar conflictos binarios
RUN python3 -m pip install --no-cache-dir --break-system-packages --force-reinstall numpy

# Instalar opencv-python-headless
RUN python3 -m pip install --no-cache-dir --break-system-packages opencv-python-headless

# Reinstalar simplejpeg para compatibilidad con numpy
RUN python3 -m pip install --no-cache-dir --break-system-packages --force-reinstall simplejpeg

# Intentar instalar picamera2 desde pip si no está disponible del sistema
RUN python3 -c "import picamera2; print('✓ picamera2 del sistema disponible')" || \
    python3 -m pip install --no-cache-dir --break-system-packages picamera2

# Verificar que las dependencias críticas están disponibles
RUN python3 -c "import uvicorn; print('✓ uvicorn disponible')"
RUN python3 -c "import fastapi; print('✓ fastapi disponible')"
RUN python3 -c "import picamera2; print('✓ picamera2 disponible')" || echo "⚠ picamera2 no disponible"

# Copiar código fuente
COPY apps/betty-camera/src/ ./src/

# Copiar modelos YOLO
COPY apps/betty-camera/yolov8n_ncnn_model/ ./yolov8n_ncnn_model/
COPY apps/betty-camera/yolov8n.pt ./yolov8n.pt

# Crear directorios necesarios
RUN mkdir -p config output

# Exponer puerto por defecto
EXPOSE 8001

# Variables de entorno por defecto
ENV HOST=0.0.0.0 \
    PORT=8001 \
    LOG_LEVEL=INFO \
    PYTHONPATH=/app/src

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Comando para ejecutar la aplicación
CMD ["python3", "src/main.py", "--host", "0.0.0.0", "--port", "8001"]