export class DeviceToken {
  constructor(
    private readonly _token: string,
    private readonly _registeredAt: Date = new Date(),
    private _lastUsed: Date = new Date(),
    private readonly _userId?: string,
    private readonly _platform?: string
  ) {
    this.validateToken(_token);
  }

  get token(): string {
    return this._token;
  }

  get registeredAt(): Date {
    return this._registeredAt;
  }

  get lastUsed(): Date {
    return this._lastUsed;
  }

  get userId(): string | undefined {
    return this._userId;
  }

  get platform(): string | undefined {
    return this._platform;
  }

  updateLastUsed(): void {
    this._lastUsed = new Date();
  }

  isExpired(expirationTimeInMs: number = 30 * 24 * 60 * 60 * 1000): boolean {
    const now = new Date().getTime();
    const lastUsedTime = this._lastUsed.getTime();
    return now - lastUsedTime > expirationTimeInMs;
  }

  private validateToken(token: string): void {
    if (!token || token.trim().length === 0) {
      throw new Error('Token cannot be empty');
    }

    if (token.length > 255) {
      throw new Error('Token length cannot exceed 255 characters');
    }
  }

  toJSON() {
    return {
      token: this._token,
      registeredAt: this._registeredAt.toISOString(),
      lastUsed: this._lastUsed.toISOString(),
      userId: this._userId,
      platform: this._platform,
    };
  }
}
