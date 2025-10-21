export interface IGpioPort {
  setPin(pin: number, state: boolean): Promise<void>;
  getPin(pin: number): Promise<boolean>;
  watchPin(
    pin: number,
    onEvent: (eventType: string, state: boolean) => void,
    onError?: (error: string) => void,
    onExit?: (code: number | null) => void
  ): void;
  unwatchPin(pin: number): void;
}
