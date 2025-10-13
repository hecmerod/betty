import {
  RegisterTokenUseCase,
  RegisterTokenResponse,
} from '../register-token.use-case';
import { RegisterTokenDto } from '../../../../presentation/dto/notification.dto';
import { DeviceTokenRepository } from '../../../../domain/repositories/device-token.repository';
import { DeviceToken } from '../../../../domain/entities/device-token.entity';

describe('RegisterTokenUseCase', () => {
  let useCase: RegisterTokenUseCase;
  let mockRepository: jest.Mocked<DeviceTokenRepository>;

  beforeEach(() => {
    mockRepository = {
      save: jest.fn(),
      getAll: jest.fn(),
    };

    useCase = new RegisterTokenUseCase(mockRepository);
  });

  it('should be defined', () => {
    expect(useCase).toBeDefined();
  });

  describe('execute', () => {
    it('should register token successfully', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-device-token-123',
      };

      mockRepository.save.mockResolvedValue();

      const result: RegisterTokenResponse = await useCase.execute(
        registerTokenDto
      );

      expect(result).toEqual({
        success: true,
        message: 'Token registrado correctamente',
      });
      expect(mockRepository.save).toHaveBeenCalledWith(expect.any(DeviceToken));
    });

    it('should handle save repository errors', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: 'test-device-token-456',
      };

      mockRepository.save.mockRejectedValue(new Error('Repository error'));

      const result = await useCase.execute(registerTokenDto);

      expect(result).toEqual({
        success: false,
        message: 'Error al registrar token: Repository error',
      });
    });

    it('should handle invalid token errors', async () => {
      const registerTokenDto: RegisterTokenDto = {
        token: '',
      };

      const result = await useCase.execute(registerTokenDto);

      expect(result).toEqual({
        success: false,
        message: 'Error al registrar token: Token cannot be empty',
      });
      expect(mockRepository.save).not.toHaveBeenCalled();
    });
  });
});
