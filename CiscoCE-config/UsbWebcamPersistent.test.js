const mockGet = jest.fn();
const mockCommand = jest.fn();

jest.mock('xapi', () => ({
  status: {
    get: mockGet
  },
  command: mockCommand
}), { virtual: true });

// Require after mock is set up
const moduleUnderTest = require('./UsbWebcamPersistent.js');

describe('UsbWebcamPersistent', () => {
  beforeEach(() => {
    jest.useFakeTimers();
    mockGet.mockClear();
    mockCommand.mockClear();
  });

  afterEach(() => {
    jest.clearAllTimers();
    jest.useRealTimers();
  });

  it('should not enable if already Enabled', async () => {
    mockGet.mockResolvedValue('Enabled');

    await moduleUnderTest.checkAndEnableUsb();

    expect(mockGet).toHaveBeenCalledWith('Video USBDeviceMode State');
    expect(mockCommand).not.toHaveBeenCalled();
  });

  it('should enable if Disabled', async () => {
    mockGet.mockResolvedValue('Disabled');

    await moduleUnderTest.checkAndEnableUsb();

    expect(mockGet).toHaveBeenCalledWith('Video USBDeviceMode State');
    expect(mockCommand).toHaveBeenCalledWith('Video USBDeviceMode Enable');
  });

  it('should enable if Inactive', async () => {
    mockGet.mockResolvedValue('Inactive');

    await moduleUnderTest.checkAndEnableUsb();

    expect(mockGet).toHaveBeenCalledWith('Video USBDeviceMode State');
    expect(mockCommand).toHaveBeenCalledWith('Video USBDeviceMode Enable');
  });

  it('should check periodically', async () => {
    mockGet.mockResolvedValue('Enabled');

    moduleUnderTest.init();

    // init calls checkAndEnableUsb initially without await, so we await here
    await Promise.resolve(); // microtask queue flush
    await Promise.resolve(); // extra flush just in case

    expect(mockGet).toHaveBeenCalledTimes(1);

    // change status to Disabled
    mockGet.mockResolvedValue('Disabled');

    // fast forward 10 seconds (checkInterval)
    jest.advanceTimersByTime(10000);

    // Wait for the promise in setInterval callback to resolve
    await Promise.resolve(); // microtask queue flush
    await Promise.resolve(); // another tick

    expect(mockGet).toHaveBeenCalledTimes(2);
    expect(mockCommand).toHaveBeenCalledWith('Video USBDeviceMode Enable');
  });

  it('should handle errors gracefully', async () => {
    mockGet.mockRejectedValue(new Error('Unknown status'));
    const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

    await moduleUnderTest.checkAndEnableUsb();

    expect(consoleErrorSpy).toHaveBeenCalledWith('USB Macro Error: Unknown status');
    consoleErrorSpy.mockRestore();
  });
});
