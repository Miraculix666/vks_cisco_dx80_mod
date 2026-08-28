// ============================================================
// Cisco DX80 - Meeting Shortcuts Macro (V3 - Optimized)
// ============================================================
// Features: Hybrid Loading (Web/SIP), Better UI Feedback
// ============================================================

const xapi = require('xapi');

// Konfiguration
const CONFIG = {
  zoomSipDomain: 'zoomcrc.com',
  teamsSipDomain: '66.198.25.10',
  // Test-URL fuer Webview (falls unterstuetzt)
  webLoaderUrl: 'https://zoom.us/join', 
};

/**
 * Versucht eine Webseite zu oeffnen. Falls dies fehlschlaegt oder
 * nicht unterstuetzt wird, erfolgt ein Fallback auf SIP.
 */
async function launchMeeting(service, meetingId) {
  console.log(`Launching ${service} for ID: ${meetingId}`);
  
  const sipAddress = service === 'zoom' 
    ? `${meetingId}@${CONFIG.zoomSipDomain}`
    : `${meetingId}@${CONFIG.teamsSipDomain}`;

  try {
    // Versuch 1: WebView (Browser)
    // Wir nutzen eine kurze Verzoegerung um zu sehen ob der Befehl akzeptiert wird
    console.log('Attempting WebView launch...');
    await xapi.command('UserInterface WebView Display', {
      Url: CONFIG.webLoaderUrl,
      Target: 'Self',
    });
    
    xapi.command('UserInterface Message Toast Display', {
      Text: `${service} wird im Browser geoeffnet...`,
      Duration: 3
    });
  } catch (e) {
    console.warn('WebView not supported or failed, falling back to SIP Dial.');
    
    // Fallback: Direkte SIP Einwahl
    xapi.command('Dial', { Number: sipAddress }).catch(err => {
      console.error('Dial error: ' + err.message);
      xapi.command('UserInterface Message Alert Display', {
        Title: 'Fehler',
        Text: 'Verbindung konnte nicht hergestellt werden.'
      });
    });
  }
}

// Widget Action Handler
xapi.event.on('UserInterface Extensions Widget Action', (event) => {
  if (event.Type !== 'clicked') return;

  const service = event.WidgetId;
  if (service === 'teams' || service === 'zoom') {
    const title = service === 'teams' ? 'Microsoft Teams' : 'Zoom Meeting';
    
    xapi.command('UserInterface Message TextInput Display', {
      FeedbackId: `${service}_id`,
      Title: title,
      Text: 'Geben Sie die Meeting-ID ein:',
      Placeholder: 'z.B. 123456789',
      InputType: 'SingleLine',
      SubmitText: 'Verbinden',
    }).catch(e => console.error(e));
  }
});

// Response Handler
xapi.event.on('UserInterface Message TextInput Response', (event) => {
  const input = event.Text.replace(/\s/g, ''); 
  
  if (event.FeedbackId === 'teams_id') {
    launchMeeting('teams', input);
  } else if (event.FeedbackId === 'zoom_id') {
    launchMeeting('zoom', input);
  }
});

console.log('Meeting Shortcuts Macro V3 (Hybrid) geladen.');
