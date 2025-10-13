/* eslint-disable @typescript-eslint/no-explicit-any */
export function TestingAvailable(
  target: object,
  propertyKey: string | symbol,
  descriptor: PropertyDescriptor
): PropertyDescriptor {
  const originalMethod = descriptor.value || descriptor.get;
  const methodName = String(propertyKey);

  if (descriptor.value) {
    descriptor.value = function (...args: unknown[]) {
      checkTestEnvironment(methodName);
      return originalMethod.apply(this, args);
    };
  } else if (descriptor.get) {
    descriptor.get = function () {
      checkTestEnvironment(methodName);
      return originalMethod.apply(this);
    };
  }

  return descriptor;
}

export function TestingAvailableClass<
  T extends { new (...args: any[]): object }
>(constructor: T): T {
  return class extends constructor {
    constructor(...args: any[]) {
      checkTestEnvironment(constructor.name);
      super(...args);
    }
  } as T;
}

function checkTestEnvironment(name: string): void {
  if (process.env.NODE_ENV !== 'test') {
    throw new Error(`${name} is only available in TEST environment`);
  }
}
