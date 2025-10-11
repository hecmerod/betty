export function TestingAvailable(
  target: object,
  propertyKey: string,
  descriptor: PropertyDescriptor
) {
  if (descriptor.get) {
    const originalGetter = descriptor.get;
    descriptor.get = function () {
      checkTestEnvironment(propertyKey);
      return originalGetter.call(this);
    };
  } else if (descriptor.value && typeof descriptor.value === 'function') {
    const originalMethod = descriptor.value;
    descriptor.value = function (...args: unknown[]) {
      checkTestEnvironment(propertyKey);
      return originalMethod.apply(this, args);
    };
  }

  return descriptor;
}

function checkTestEnvironment(propertyKey: string): void {
  if (process.env.NODE_ENV !== 'test') {
    throw new Error(`${propertyKey} is only available in TEST environment`);
  }
}
