/**
 * Cisco DX80 - USB Webcam Persistence Macro
 * 
 * Target: CE 9.x / RoomOS
 * Feature: Keeps the device in "USB Device Mode" permanently.
 * Useful when the DX80 is primarily used as a PC peripheral (Webcam/Mic/Speaker).
 */

const xapi = require('xapi');

// Configuration
const CONFIG = {
  checkInterval: 10000, // ms
  aggressiveMode: true,  // Re-enable even if manually disabled
};

let lastState = '';

async function checkAndEnableUsb() {
  try {
    const state = await xapi.status.get('Video USBDeviceMode State');
    
    if (state !== lastState) {
      console.log(`USB Device Mode State changed: ${state}`);
      lastState = state;
    }

    // We want the state to be 'Enabled'.
    // 'Inactive' usually means the mode is ready but no USB cable is detected.
    // 'Disabled' means the mode is off.
    if (state === 'Disabled' || state === 'Inactive') {
      console.log('Force enabling USB Device Mode...');
      await xapi.command('Video USBDeviceMode Enable');
    }
  } catch (err) {
    // If the command or status is unknown, this firmware might not support it.
    console.error(`USB Macro Error: ${err.message}`);
  }
}

function init() {
  // Start periodic check
  setInterval(checkAndEnableUsb, CONFIG.checkInterval);

  // Initial check
  checkAndEnableUsb();

  console.log('USB Webcam Persistence Macro loaded.');
}

// Safely execute init() unless we are in a testing environment
if (typeof process === 'undefined' || process.env.NODE_ENV !== 'test') {
  init();
}

// Safely export functions for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    checkAndEnableUsb,
    init
  };
}
