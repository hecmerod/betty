export const SensorState = {
  Opened: "OPENED",
  CLOSED: "CLOSED",
} as const;

export type SensorState = typeof SensorState[keyof typeof SensorState];