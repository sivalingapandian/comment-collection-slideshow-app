1. Load Your Extension in Chrome
  * Change following to server in content.js
  ```javascript
  const operatingMode = "server";
  ```
  * Change below with correct URL
  ```javascript
  const apiURL = 'https://*.*.us-east-1.amazonaws.com/default/messageAPI';
  ```
  * Open Chrome and go to chrome://extensions/.
  * Enable "Developer mode" using the toggle in the top right corner.
  * Click "Load unpacked" and select your project directory.
  * Open tab with photos.google.com
  * Text should start scrolling from bottom up