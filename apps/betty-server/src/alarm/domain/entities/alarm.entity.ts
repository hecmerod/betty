export class Alarm {
  constructor(
    private _isActive = false,
    public readonly createdAt: Date = new Date(),
    private _password: string,
    private _lastActivatedAt?: Date,
    private _lastDeactivatedAt?: Date,
    private _lastTriggeredAt?: Date,
  ) {}

  get isActive(): boolean {
    return this._isActive;
  }

  get lastActivatedAt(): Date | undefined {
    return this._lastActivatedAt;
  }

  get lastDeactivatedAt(): Date | undefined {
    return this._lastDeactivatedAt;
  }

  get lastTriggeredAt(): Date | undefined {
    return this._lastTriggeredAt;
  }

  get password(): string {
    return this._password;
  }

  get status(): AlarmStatus {
    return this._isActive ? 'active' : 'inactive';
  }

  activate(): void {
    if (this._isActive) {
      throw new Error('Alarm is already active');
    }

    this._isActive = true;
    this._lastActivatedAt = new Date();
  }

  deactivate(): void {
    if (!this._isActive) {
      throw new Error('Alarm is already inactive');
    }

    this._isActive = false;
    this._lastDeactivatedAt = new Date();
  }

  getActiveDuration(): number {
    if (!this._isActive || !this._lastActivatedAt) {
      return 0;
    }

    return Date.now() - this._lastActivatedAt.getTime();
  }

  toJSON(): {
    isActive: boolean;
    status: AlarmStatus;
    createdAt: string;
    lastActivatedAt?: string;
    lastDeactivatedAt?: string;
    lastTriggeredAt?: string;
    activeDuration: number;
  } {
    return {
      isActive: this._isActive,
      status: this.status,
      createdAt: this.createdAt.toISOString(),
      lastActivatedAt: this._lastActivatedAt?.toISOString(),
      lastDeactivatedAt: this._lastDeactivatedAt?.toISOString(),
      lastTriggeredAt: this._lastTriggeredAt?.toISOString(),
      activeDuration: this.getActiveDuration(),
    };
  }
}

export type AlarmStatus = 'active' | 'inactive';
