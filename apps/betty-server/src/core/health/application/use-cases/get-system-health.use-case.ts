import { Injectable } from '@nestjs/common';

@Injectable()
export class GetSystemHealthUseCase {
  async execute(): Promise<SystemHealthResponse> {
    const memoryUsage = process.memoryUsage();

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      memory: {
        used: Math.round(memoryUsage.heapUsed / 1024 / 1024),
        total: Math.round(memoryUsage.heapTotal / 1024 / 1024),
        rss: Math.round(memoryUsage.rss / 1024 / 1024),
      },
    };
  }
}

export interface SystemHealthResponse {
  status: string;
  timestamp: string;
  uptime: number;
  memory: {
    used: number;
    total: number;
    rss: number;
  };
}
