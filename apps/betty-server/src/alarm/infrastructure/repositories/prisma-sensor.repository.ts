import { Injectable, OnModuleInit } from '@nestjs/common';
import { Sensor, SensorType } from '../../domain/entities/sensor.entity';
import { SensorRepository } from '../../domain/repositories/sensor.repository';
import { PrismaService } from '../../../shared/prisma/prisma.service';

@Injectable()
export class PrismaSensorRepository
  extends SensorRepository
  implements OnModuleInit
{
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async onModuleInit() {
    await this.ensureSensorsExist();
  }

  async get(id: SensorType): Promise<Sensor> {
    const record = await this.prisma.sensor.findUnique({
      where: { id },
    });

    if (!record) {
      throw new Error(`Sensor ${id} not found`);
    }

    return new Sensor(
      record.id as SensorType,
      record.isListening,
      record.createdAt,
      record.updatedAt
    );
  }

  async getAll(): Promise<Sensor[]> {
    const records = await this.prisma.sensor.findMany();
    return records.map(
      (record) =>
        new Sensor(
          record.id as SensorType,
          record.isListening,
          record.createdAt,
          record.updatedAt
        )
    );
  }

  async enableListening(id: SensorType): Promise<void> {
    const current = await this.prisma.sensor.findUnique({
      where: { id },
    });

    if (current?.isListening) {
      throw new Error(`Sensor ${id} is already listening`);
    }

    await this.prisma.sensor.update({
      where: { id },
      data: {
        isListening: true,
        updatedAt: new Date(),
      },
    });
  }

  async disableListening(id: SensorType): Promise<void> {
    const current = await this.prisma.sensor.findUnique({
      where: { id },
    });

    if (!current?.isListening) {
      throw new Error(`Sensor ${id} is already not listening`);
    }

    await this.prisma.sensor.update({
      where: { id },
      data: {
        isListening: false,
        updatedAt: new Date(),
      },
    });
  }

  async isListening(id: SensorType): Promise<boolean> {
    const record = await this.prisma.sensor.findUnique({
      where: { id },
      select: { isListening: true },
    });

    return record?.isListening ?? true;
  }

  private async ensureSensorsExist(): Promise<void> {
    const sensorTypes: SensorType[] = [
      'motion',
      'door_claraboyas',
      'door_trasera',
      'door_lateral',
      'door_delanteras',
    ];

    for (const id of sensorTypes) {
      const exists = await this.prisma.sensor.findUnique({
        where: { id },
      });

      if (!exists) {
        await this.prisma.sensor.create({
          data: {
            id,
            isListening: true,
          },
        });
      }
    }
  }
}
