jest.mock('xapi', () => ({
  status: {
    get: jest.fn()
  },
  command: jest.fn()
}), { virtual: true });

describe('SystemMonitor', () => {
  let consoleLogMock;
  let originalSetInterval;
  let xapi;

  beforeEach(() => {
    originalSetInterval = global.setInterval;
    global.setInterval = jest.fn();
    consoleLogMock = jest.spyOn(console, 'log').mockImplementation(() => {});
    jest.resetModules();
    jest.clearAllMocks();
    xapi = require('xapi');
  });

  afterEach(() => {
    global.setInterval = originalSetInterval;
    consoleLogMock.mockRestore();
  });

  it('should successfully get temp and air quality', async () => {
    xapi.status.get.mockResolvedValueOnce('22').mockResolvedValueOnce('50');

    require('./SystemMonitor');

    // flush promises
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(xapi.status.get).toHaveBeenCalledWith('RoomAnalytics AmbientTemperature');
    expect(xapi.status.get).toHaveBeenCalledWith('RoomAnalytics AirQuality Index');
    expect(consoleLogMock).toHaveBeenCalledWith('Current Temp: 22°C');
  });

  it('should catch error when metrics are not available', async () => {
    xapi.status.get.mockRejectedValueOnce(new Error('Not available'));

    require('./SystemMonitor');

    // flush promises
    await new Promise(resolve => setTimeout(resolve, 0));

    expect(consoleLogMock).toHaveBeenCalledWith('Metrics not available on this firmware/hardware');
  });
});
