import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { config } from 'dotenv';
import { join } from 'path';
import { AppModule } from './app.module';
import { SendNotificationUseCase } from './notifications/application/use-cases/send-notification/send-notification.use-case';
import { CustomLogger } from './core/logger/custom-logger';

// Cargar variables de entorno desde .env
config({ path: join(__dirname, '../.env') });

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useLogger(app.get(CustomLogger));

  app.enableCors({
    origin: [
      /^http:\/\/localhost(:\d+)?$/,
      /^http:\/\/127\.0\.0\.1(:\d+)?$/,
      /^http:\/\/192\.168\.\d+\.\d+(:\d+)?$/,
      /^http:\/\/10\.\d+\.\d+\.\d+(:\d+)?$/,
      /^http:\/\/172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+(:\d+)?$/,
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: [
      'Origin',
      'X-Requested-With',
      'Content-Type',
      'Accept',
      'Authorization',
      'Access-Control-Allow-Headers',
    ],
    credentials: true,
  });

  const globalPrefix = 'api';
  app.setGlobalPrefix(globalPrefix);

  const port = process.env.PORT || 3000;

  // Escuchar en todas las interfaces para permitir acceso externo
  await app.listen(port, '0.0.0.0');

  Logger.log(
    `🍓 Betty Server is running on: http://0.0.0.0:${port}/${globalPrefix}`
  );
  Logger.log(`📊 Health check: http://0.0.0.0:${port}/${globalPrefix}/health`);

  // Enviar notificación de inicio del sistema
  try {
    if (process.env.NODE_ENV !== 'production') return;

    const sendNotificationUseCase = app.get(SendNotificationUseCase);
    await sendNotificationUseCase.execute({
      notification: {
        title: 'Betty iniciada',
        body: 'La Raspberry Pi se ha iniciado correctamente',
      },
      data: { type: 'system_startup' },
    });
  } catch (error) {
    Logger.error('❌ Failed to send startup notification:', error.message);
  }
}

bootstrap();
