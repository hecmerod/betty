export type TripStatus = 'in_progress' | 'completed';

export class Trip {
  constructor(
    private readonly _id: string,
    private readonly _name: string,
    private readonly _startedAt: Date,
    private _endedAt?: Date,
    private readonly _createdAt: Date = new Date(),
    private _updatedAt: Date = new Date()
  ) {
    this.validateName();
    this.validateDates();
  }

  get id(): string {
    return this._id;
  }

  get name(): string {
    return this._name;
  }

  get startedAt(): Date {
    return this._startedAt;
  }

  get endedAt(): Date | undefined {
    return this._endedAt;
  }

  get createdAt(): Date {
    return this._createdAt;
  }

  get updatedAt(): Date {
    return this._updatedAt;
  }

  get status(): TripStatus {
    return this._endedAt ? 'completed' : 'in_progress';
  }

  get isInProgress(): boolean {
    return !this._endedAt;
  }

  get isCompleted(): boolean {
    return !!this._endedAt;
  }

  /**
   * Duración del viaje en milisegundos
   */
  get duration(): number {
    const endTime = this._endedAt || new Date();
    return endTime.getTime() - this._startedAt.getTime();
  }

  /**
   * Duración del viaje en formato legible (horas, minutos, segundos)
   */
  getDurationFormatted(): string {
    const durationMs = this.duration;
    const seconds = Math.floor(durationMs / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);

    const remainingMinutes = minutes % 60;
    const remainingSeconds = seconds % 60;

    if (hours > 0) {
      return `${hours}h ${remainingMinutes}m ${remainingSeconds}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${remainingSeconds}s`;
    } else {
      return `${seconds}s`;
    }
  }

  /**
   * Finaliza el viaje
   */
  end(): void {
    if (this.isCompleted) {
      throw new Error('Trip is already completed');
    }

    this._endedAt = new Date();
    this._updatedAt = new Date();
  }

  private validateName(): void {
    if (!this._name || this._name.trim().length === 0) {
      throw new Error('Trip name cannot be empty');
    }

    if (this._name.length > 100) {
      throw new Error('Trip name cannot exceed 100 characters');
    }
  }

  private validateDates(): void {
    if (this._endedAt && this._endedAt < this._startedAt) {
      throw new Error('End date cannot be before start date');
    }
  }

  toJSON() {
    return {
      id: this._id,
      name: this._name,
      startedAt: this._startedAt.toISOString(),
      endedAt: this._endedAt?.toISOString(),
      status: this.status,
      duration: this.duration,
      durationFormatted: this.getDurationFormatted(),
      createdAt: this._createdAt.toISOString(),
      updatedAt: this._updatedAt.toISOString(),
    };
  }
}
