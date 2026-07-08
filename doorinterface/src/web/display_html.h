#pragma once
#include <pgmspace.h>

const char DISPLAY_HTML[] PROGMEM = R"HTML(
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DoorInterface – Kundendisplay</title>
  <link rel="stylesheet" href="/main.css">
  <style>
    html,body{height:100%;}
    body{max-width:none;background:#fff;display:flex;flex-direction:column;justify-content:center;align-items:center;padding:0;margin:0;}
    .qr-wrap{padding:1.5em;background:#fff;border:1px solid #e1e4e8;border-radius:12px;}
    #qr{width:300px;height:300px;}
    .qr-cap{text-align:center;margin-top:1em;font-size:1.1em;color:#2c3e50;}
    .qr-cap small{display:block;color:#6a737d;font-size:0.85em;margin-top:0.3em;}
  </style>
</head>
<body>
  <div class="qr-wrap">
    <div id="qr"></div>
    <div class="qr-cap" id="qrCap">Lade QR-Code …</div>
  </div>
  <script src="/qr.js"></script>
  <script src="/display.js"></script>
</body>
</html>
)HTML";