#pragma once
#include <pgmspace.h>

const char DISPLAY_JS[] PROGMEM = R"JS(
(async () => {
  try {
    const r = await fetch('/api/ble/info');
    const info = await r.json();
    const payload = info.qrContent || '';
    const qr = qrcode(0, 'M');
    qr.addData(payload);
    qr.make();
    const img = qr.createImgTag(6, 12);
    document.getElementById('qr').innerHTML = img;
    const cap = document.getElementById('qrCap');
    cap.innerHTML = payload + '<small>Mit der DoorInterface-App scannen</small>';
  } catch (e) {
    document.getElementById('qrCap').textContent = 'Fehler: ' + e.message;
  }
})();
)JS";