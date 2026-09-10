export type SensorType =
  | 'motion'
  | 'door_claraboyas'
  | 'door_trasera'
  | 'door_lateral'
  | 'door_delanteras'
  | 'location';

export class Sensor {
  constructor(
    private _id: SensorType,
    private _isListening = true,
    public readonly createdAt: Date = new Date(),
    public readonly updatedAt: Date = new Date()
  ) {}

  get id(): SensorType {
    return this._id;
  }

  get isListening(): boolean {
    return this._isListening;
  }

  enableListening(): void {
    if (this._isListening) {
      throw new Error(`Sensor ${this._id} is already listening`);
    }
    this._isListening = true;
  }

  disableListening(): void {
    if (!this._isListening) {
      throw new Error(`Sensor ${this._id} is already not listening`);
    }
    this._isListening = false;
  }

  toJSON(): {
    id: SensorType;
    isListening: boolean;
    createdAt: string;
    updatedAt: string;
  } {
    return {
      id: this._id,
      isListening: this._isListening,
      createdAt: this.createdAt.toISOString(),
      updatedAt: this.updatedAt.toISOString(),
    };
  }
}
