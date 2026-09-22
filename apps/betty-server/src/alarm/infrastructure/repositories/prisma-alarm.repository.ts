import { Injectable, OnModuleInit } from '@nestjs/common';
import { Alarm } from '../../domain/entities/alarm.entity';
import { AlarmRepository } from '../../domain/repositories/alarm.repository';
import { PrismaService } from '../../../shared/prisma/prisma.service';

@Injectable()
export class PrismaAlarmRepository
  extends AlarmRepository
  implements OnModuleInit
{
  private readonly SINGLETON_ID = 1;

  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async onModuleInit() {
    await this.ensureAlarmExists();
  }

  async activate(): Promise<void> {
    const current = await this.prisma.alarm.findUnique({
      where: { id: this.SINGLETON_ID },
    });

    if (current?.isActive) {
      throw new Error('Alarm is already active');
    }

    await this.prisma.alarm.update({
      where: { id: this.SINGLETON_ID },
      data: {
        isActive: true,
        lastActivatedAt: new Date(),
      },
    });
  }

  async deactivate(): Promise<void> {
    const current = await this.prisma.alarm.findUnique({
      where: { id: this.SINGLETON_ID },
    });

    if (!current?.isActive) {
      throw new Error('Alarm is already inactive');
    }

    await this.prisma.alarm.update({
      where: { id: this.SINGLETON_ID },
      data: {
        isActive: false,
        lastDeactivatedAt: new Date(),
      },
    });
  }

  async get(): Promise<Alarm> {
    const record = await this.prisma.alarm.findUnique({
      where: { id: this.SINGLETON_ID },
    });

    if (!record) {
      throw new Error('Alarm record not found');
    }

    return new Alarm(
      record.isActive,
      record.createdAt,
      record.password,
      record.lastActivatedAt ?? undefined,
      record.lastDeactivatedAt ?? undefined,
      record.lastTriggeredAt ?? undefined,
    );
  }

  async setPassword(password: string): Promise<void> {
    await this.prisma.alarm.update({
      where: { id: this.SINGLETON_ID },
      data: { password },
    });
  }

  private async ensureAlarmExists(): Promise<void> {
    const exists = await this.prisma.alarm.findUnique({
      where: { id: this.SINGLETON_ID },
    });

    if (!exists) {
      await this.prisma.alarm.create({
        data: {
          id: this.SINGLETON_ID,
          isActive: false,
        },
      });
    }
  }
}
