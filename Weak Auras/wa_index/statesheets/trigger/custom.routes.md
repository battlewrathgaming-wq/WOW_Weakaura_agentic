# custom - routing index
_Main (input) levers only. Open `custom.json` for full handling. rule: `array`=multiEntry (value+operator as arrays) - `dom:X`=value-domain X (see domains.json)._

## Custom
| lever | type | rule |
|---|---|---|
| custom_type (Event Type) | select | dom:custom_trigger_types |
| check (Check On...) | select | dom:check_types |
| events (Event(s)) | input |  |
| check2 (Check On...) | select | dom:check_types |
| onUpdateThrottle (Custom trigger Update Throttle) | range |  |
| events2 (Event(s)) | input |  |
| custom_hide (Hide) | select | dom:eventend_types |
| custom_hide2 (Hide) | select | dom:eventend_types |
| dynamicDuration (Dynamic Duration) | toggle |  |
| duration (Duration (s)) | input |  |
| custom |  |  |
| customDuration |  |  |
| customIcon |  |  |
| customName |  |  |
| customStacks |  |  |
| customTexture |  |  |
| customVariables |  |  |
