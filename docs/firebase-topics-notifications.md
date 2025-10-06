# 📱 Sistema de Notificaciones Push con Firebase Topics

## 🎯 **Cómo funciona ahora**

El sistema de notificaciones de Betty ahora utiliza **Firebase Cloud Messaging Topics** para enviar notificaciones a todos los dispositivos sin necesidad de registrar tokens previamente.

## 🔥 **Firebase Topics (Temas)**

Los **Topics** son canales de comunicación que permiten enviar mensajes a múltiples dispositivos que se han suscrito al mismo tema.

### **Ventajas de usar Topics:**

✅ **Sin registro previo** - No necesitas almacenar tokens en el servidor
✅ **Escalable** - Funciona con miles de dispositivos
✅ **Automático** - Los dispositivos se suscriben al instalar la app
✅ **Persistente** - Las suscripciones se mantienen aunque la app se cierre

## 📋 **Configuración en betty_app (Flutter/Android)**

### 1. **Suscribirse automáticamente al tema**

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> subscribeToAlerts() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic('betty_alerts');
      print('✅ Suscrito a alertas de Betty');
    } catch (e) {
      print('❌ Error suscribiéndose: $e');
    }
  }

  static Future<void> unsubscribeFromAlerts() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('betty_alerts');
      print('✅ Desuscrito de alertas de Betty');
    } catch (e) {
      print('❌ Error desuscribiéndose: $e');
    }
  }
}
```

### 2. **Llamar en la inicialización de la app**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Suscribirse automáticamente a las alertas
  await NotificationService.subscribeToAlerts();

  runApp(MyApp());
}
```

## 🚨 **Endpoints disponibles**

### **Enviar alarma a todos (SIN tokens)**

```bash
POST /api/notifications/alarm
Content-Type: application/json

{
  "detectionType": "person",
  "metadata": {
    "camera": "frontal",
    "confidence": 0.85
  }
}
```

### **Suscribir dispositivo manualmente**

```bash
POST /api/notifications/subscribe
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}
```

### **Desuscribir dispositivo**

```bash
POST /api/notifications/unsubscribe
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}
```

## 🎯 **Flujo completo de notificaciones**

1. **betty_app se instala** → Se suscribe automáticamente al tema `betty_alerts`
2. **betty-camera detecta persona** → Llama a betty-server
3. **betty-server dispara alarma** → Envía notificación al tema `betty_alerts`
4. **Firebase entrega la notificación** → A todos los dispositivos suscritos
5. **betty_app recibe notificación** → Incluso si la app está cerrada

## 🔧 **Configuración automática en AlarmService**

El `AlarmService` ahora envía notificaciones automáticamente:

```typescript
async trigger(data: Record<string, unknown>) {
  // Se dispara automáticamente cuando betty-camera detecta persona
  const result = await this.notificationsService.sendAlarmToAllDevices({
    detectionType: 'person',
    metadata: data
  });

  return {
    triggered: true,
    notificationSent: result.success
  };
}
```

## 📱 **Ejemplo de notificación recibida**

```json
{
  "notification": {
    "title": "🚨 BETTY ALARM",
    "body": "Persona detectada en tu hogar"
  },
  "data": {
    "type": "alarm",
    "timestamp": "2025-10-06T14:30:00.000Z",
    "detectionType": "person"
  }
}
```

## ✅ **Estado actual**

- ✅ **Firebase configurado** con credenciales correctas
- ✅ **Topics implementados** para envío masivo
- ✅ **Integración con AlarmService** automática
- ✅ **Endpoints REST** para gestión manual
- 🔄 **Pendiente**: Configurar betty_app para suscribirse al tema

## 🚀 **Próximos pasos para betty_app**

1. **Añadir Firebase SDK** a betty_app
2. **Implementar suscripción automática** al tema `betty_alerts`
3. **Configurar manejo de notificaciones** en foreground/background
4. **Probar notificaciones push** end-to-end

¡Ahora betty-server puede enviar notificaciones a todos los dispositivos sin necesidad de gestionar tokens individualmente! 🎉
