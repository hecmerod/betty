# Betty Camera Application

# Gestión de cámara Raspberry Pi con PiCamera2

Una aplicación Python para gestionar la cámara de Raspberry Pi usando PiCamera2.

## Características

- 📸 Captura de fotos y videos
- 🔄 Streaming en vivo
- ⚙️ Configuración de resolución y calidad
- 🎯 Detección de movimiento
- 🌐 API REST para control remoto
- 📊 Integración con Betty Server

## Instalación

```bash
# Instalar dependencias del sistema (Raspberry Pi)
sudo apt update
sudo apt install python3-picamera2 python3-opencv python3-pip

# Instalar dependencias de Python
pip install -r requirements.txt
```

## Uso

```bash
# Ejecutar la aplicación
python src/main.py

# Ejecutar con configuración personalizada
python src/main.py --config config/camera.yaml
```

## API Endpoints

- `GET /camera/status` - Estado de la cámara
- `POST /camera/photo` - Capturar foto
- `POST /camera/video/start` - Iniciar grabación
- `POST /camera/video/stop` - Detener grabación
- `GET /camera/stream` - Stream en vivo
