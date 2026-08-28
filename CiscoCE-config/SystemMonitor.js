const xapi = require('xapi');

/**
 * Cisco DX80 System Monitor Macro
 * Displays room analytics and device status.
 */

async function updateStatus() {
  try {
    const temp = await xapi.status.get('RoomAnalytics AmbientTemperature');
    const airQuality = await xapi.status.get('RoomAnalytics AirQuality Index');
    
    console.log(`Current Temp: ${temp}°C`);
    // Note: You can also push these values to a UI Extension widget label
    // xapi.command('UserInterface Extensions Widget SetValue', { WidgetId: 'temp_label', Value: temp + '°C' });
  } catch (e) {
    console.log('Metrics not available on this firmware/hardware');
  }
}

// Update every 5 minutes
setInterval(updateStatus, 300000);
updateStatus();
