import xapi from 'xapi';

// Example xAPI Macro: Listen for Touch 10 Widget Button clicks
xapi.Event.UserInterface.Extensions.Widget.Action.on(action => {
  if (action.WidgetId === 'btn_vks_direct' && action.Type === 'clicked') {
    console.log('VKS One-Touch Call triggered');
    xapi.Command.Dial({ Number: 'vks@conference.bayern.de' });
  }
});
