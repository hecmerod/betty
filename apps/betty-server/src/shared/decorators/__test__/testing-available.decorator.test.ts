import {
  TestingAvailable,
  TestingAvailableClass,
} from '../testing-available.decorator';

describe('TestingAvailable decorator', () => {
  const originalNodeEnv = process.env.NODE_ENV;

  afterEach(() => {
    process.env.NODE_ENV = originalNodeEnv;
  });

  describe('when applied to a method', () => {
    class TestClass {
      @TestingAvailable
      testMethod(): string {
        return 'test result';
      }
    }

    it('should allow method execution in test environment', () => {
      process.env.NODE_ENV = 'test';
      const instance = new TestClass();

      expect(instance.testMethod()).toBe('test result');
    });

    it('should throw error when called outside test environment', () => {
      process.env.NODE_ENV = 'production';
      const instance = new TestClass();

      expect(() => instance.testMethod()).toThrow(
        'testMethod is only available in TEST environment'
      );
    });
  });

  describe('when applied to a getter', () => {
    class TestClass {
      private _value = 'test value';

      @TestingAvailable
      get testGetter(): string {
        return this._value;
      }
    }

    it('should allow getter access in test environment', () => {
      process.env.NODE_ENV = 'test';
      const instance = new TestClass();

      expect(instance.testGetter).toBe('test value');
    });

    it('should throw error when getter accessed outside test environment', () => {
      process.env.NODE_ENV = 'development';
      const instance = new TestClass();

      expect(() => instance.testGetter).toThrow(
        'testGetter is only available in TEST environment'
      );
    });
  });

  describe('when applied to a method with parameters', () => {
    class TestClass {
      @TestingAvailable
      methodWithParams(a: number, b: string): string {
        return `${a}-${b}`;
      }
    }

    it('should pass parameters correctly in test environment', () => {
      process.env.NODE_ENV = 'test';
      const instance = new TestClass();

      expect(instance.methodWithParams(42, 'hello')).toBe('42-hello');
    });
  });

  describe('when applied to a class using TestingAvailableClass', () => {
    it('should allow class instantiation in test environment', () => {
      process.env.NODE_ENV = 'test';

      @TestingAvailableClass
      class TestClassDecorated {
        private _value = 'test value';

        getValue(): string {
          return this._value;
        }
      }

      expect(() => new TestClassDecorated()).not.toThrow();
      const instance = new TestClassDecorated();
      expect(instance.getValue()).toBe('test value');
    });

    it('should throw error when instantiated outside test environment', () => {
      process.env.NODE_ENV = 'production';

      @TestingAvailableClass
      class TestClassDecorated {
        private _value = 'test value';

        getValue(): string {
          return this._value;
        }
      }

      expect(() => new TestClassDecorated()).toThrow(
        'TestClassDecorated is only available in TEST environment'
      );
    });
  });
});
