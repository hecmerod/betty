import { IrInput } from '../../../../ir/domain/enums/ir-input.enum';
import { IrSignalReceivedEvent } from '../../../../ir/domain/events/ir-signal-received.event';
import { PasswordService } from '../../../application/services/password.service';
import { IrSignalReceivedHandler } from '../ir-signal-received.handler';

describe('IrSignalReceivedHandler', () => {
  let handler: IrSignalReceivedHandler;
  let irPasswordService: jest.Mocked<Pick<PasswordService, 'handleInput'>>;

  beforeEach(() => {
    irPasswordService = { handleInput: jest.fn() };
    handler = new IrSignalReceivedHandler(
      irPasswordService as unknown as PasswordService
    );
  });

  it('should forward the IR input to the password service', () => {
    handler.handle(new IrSignalReceivedEvent(IrInput.STAR));

    expect(irPasswordService.handleInput).toHaveBeenCalledWith(IrInput.STAR);
  });
});
