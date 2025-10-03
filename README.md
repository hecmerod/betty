# Betty Server 🍓

**Servidor NestJS optimizado para Raspberry Pi con monorepo Nx**

<a alt="Nx logo" href="https://nx.dev" target="_blank" rel="noreferrer"><img src="https://raw.githubusercontent.com/nrwl/nx/master/images/nx-logo.png" width="45"></a>

Un servidor Node.js moderno construido con NestJS y Nx, optimizado específicamente para ejecutarse de manera eficiente en Raspberry Pi con arquitectura ARM.

## 🚀 Características

- **NestJS**: Framework robusto y escalable para Node.js
- **Nx Monorepo**: Herramientas avanzadas de desarrollo y construcción
- **Optimizado para ARM**: Configuraciones específicas para Raspberry Pi
- **Production Ready**: PM2, Docker, logs, monitoreo de recursos
- **Health Checks**: Endpoints para supervisar el estado del servidor
- **TypeScript**: Desarrollo tipado y moderno

## 📋 Requisitos

- Node.js 20+ (incluido en la instalación)
- NPM 9+
- Raspberry Pi con Debian/Ubuntu
- Al menos 512MB de RAM disponible

## 🛠️ Instalación Rápida

El proyecto ya está configurado y listo para usar. Todas las dependencias están instaladas.

## 🚀 Comandos Disponibles

### Desarrollo

```bash
npm run start:dev          # Servidor de desarrollo con hot-reload
npm run build              # Compilar para producción
npm run start              # Iniciar servidor compilado
npm run start:debug        # Modo debug
```

### Producción en Raspberry Pi

```bash
npm run start:prod         # Servidor optimizado para RPi
npm run start:rpi          # Script completo con monitoreo
npm run pm2:start          # Iniciar con PM2 (recomendado)
npm run pm2:status         # Ver estado de PM2
```

### Testing y Calidad

```bash
npm run test              # Ejecutar tests unitarios
npm run test:e2e          # Tests end-to-end
npm run lint              # Verificar código con ESLint
```

### Docker para Raspberry Pi

```bash
npm run docker:build:rpi  # Construir imagen Docker ARM
npm run docker:run:rpi    # Ejecutar contenedor
```

## 📡 Endpoints API

El servidor expone los siguientes endpoints:

- `GET /api` - Información básica del servidor
- `GET /api/health` - Estado de salud y métricas
- `GET /api/system` - Información del sistema y hardware

Puedes probar estos endpoints usando el archivo `test-api.http` con la extensión REST Client.

## 🔧 Configuración para Raspberry Pi

### Optimizaciones ARM

- Límite de memoria heap a 512MB
- Configuración de PM2 optimizada
- Monitoreo de temperatura del CPU
- Gestión eficiente de recursos

### Archivos Importantes

- `ecosystem.config.js` - Configuración PM2
- `Dockerfile.rpi` - Imagen Docker para ARM
- `scripts/start-rpi.sh` - Script de inicio con monitoreo

## 📊 Monitoreo

### Health Check

```bash
curl http://localhost:3000/api/health
```

### Información del Sistema

```bash
curl http://localhost:3000/api/system
```

### Logs

- `logs/combined.log` - Logs combinados
- `logs/error.log` - Solo errores
- `logs/system.log` - Monitoreo del sistema

## 🛠️ Desarrollo con Nx

### Generar Nuevos Módulos

```bash
npx nx g @nx/nest:resource users           # Generar recurso REST completo
npx nx g @nx/nest:service auth             # Generar servicio
npx nx g @nx/nest:controller products      # Generar controlador
```

### Estructura del Monorepo

```
betty/
├── apps/
│   ├── betty/              # Aplicación principal NestJS
│   └── betty-e2e/          # Tests end-to-end
├── scripts/                # Scripts de utilidad
├── ecosystem.config.js     # Configuración PM2
└── Dockerfile.rpi         # Docker para ARM
```

## 🎯 Uso en Producción

### 1. Iniciar el Servidor

```bash
# Método recomendado con PM2
npm run pm2:start

# O usar el script optimizado
npm run start:rpi
```

### 2. Verificar Estado

```bash
# Verificar que está corriendo
curl http://localhost:3000/api/health

# Ver logs de PM2
pm2 logs betty-server

# Estado de PM2
npm run pm2:status
```

### 3. Acceso Remoto

Si quieres acceder desde otros dispositivos en la red:

```bash
# En el RPi, obtén la IP
hostname -I

# Desde otro dispositivo
curl http://[IP-de-tu-RPi]:3000/api
```

## 🔧 Configuración Avanzada

### Variables de Entorno

Crea un archivo `.env` para configuraciones personalizadas:

```bash
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
```

### Firewall (opcional)

```bash
# Permitir tráfico en puerto 3000
sudo ufw allow 3000
```

### Servicio Systemd (inicio automático)

```bash
# Crear servicio para inicio automático en boot
sudo cp scripts/betty.service /etc/systemd/system/
sudo systemctl enable betty
```

## 📚 Recursos Adicionales

- [Documentación de NestJS](https://docs.nestjs.com/)
- [Guía de Nx](https://nx.dev/getting-started/intro)
- [Optimización para Raspberry Pi](https://www.raspberrypi.org/documentation/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

MIT License - ve el archivo [LICENSE](LICENSE) para más detalles.

---

**Betty Server** - Hecho con ❤️ para Raspberry Pi 🍓
