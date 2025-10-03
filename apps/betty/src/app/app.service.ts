import { Injectable } from '@nestjs/common';
import * as os from 'os';
import { execSync } from 'child_process';

@Injectable()
export class AppService {
  getData() {
    return {
      message: 'Betty Server - Optimized for Raspberry Pi',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
    };
  }

  getHealth() {
    const uptime = process.uptime();
    const memoryUsage = process.memoryUsage();

    return {
      status: 'healthy',
      uptime: `${Math.floor(uptime)}s`,
      memory: {
        used: `${Math.round(memoryUsage.heapUsed / 1024 / 1024)}MB`,
        total: `${Math.round(memoryUsage.heapTotal / 1024 / 1024)}MB`,
        external: `${Math.round(memoryUsage.external / 1024 / 1024)}MB`,
      },
      timestamp: new Date().toISOString(),
    };
  }

  getSystemInfo() {
    try {
      // Información específica de Raspberry Pi
      let temperature = 'N/A';
      try {
        temperature = execSync('vcgencmd measure_temp').toString().trim();
      } catch (e) {
        // No es un RPi o vcgencmd no disponible
      }

      return {
        platform: os.platform(),
        architecture: os.arch(),
        nodeVersion: process.version,
        cpus: os.cpus().length,
        totalMemory: `${Math.round(os.totalmem() / 1024 / 1024)}MB`,
        freeMemory: `${Math.round(os.freemem() / 1024 / 1024)}MB`,
        loadAverage: os.loadavg(),
        temperature: temperature,
        hostname: os.hostname(),
        uptime: `${Math.floor(os.uptime())}s`,
      };
    } catch (error) {
      return {
        error: 'Could not retrieve system information',
        message: error.message,
      };
    }
  }
}
