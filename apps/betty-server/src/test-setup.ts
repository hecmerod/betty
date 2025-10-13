/**
 * Configuración global para tests
 * Este archivo se ejecuta antes de todos los tests
 */

import { Logger } from '@nestjs/common';

// Suprimir todos los logs de NestJS durante los tests
Logger.overrideLogger(false);
