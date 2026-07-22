#pragma once
#include <pgmspace.h>

const char SETUP_HTML[] PROGMEM = R"HTML(
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DoorInterface – Einrichtung</title>
  <link rel="stylesheet" href="/main.css">
</head>
<body>
  <header><h1>Einrichtung</h1></header>
  <main>
    <section class="card" id="wifi">
      <h2>Gerätename</h2>
      <p class="muted">Name für mDNS (&lt;name&gt;.local). Nach Änderung startet das Gerät neu.</p>
      <form id="hostForm">
        <label>Hostname
          <input type="text" id="hostInput" pattern="[a-z0-9\-]{1,63}" title="a-z, 0-9, Bindestrich; max. 63 Zeichen">
        </label>
        <button type="submit" id="hostBtn">Speichern &amp; Neustart</button>
      </form>
      <div id="hostStatus"></div>
    </section>
    <section class="card">
      <h2>NUKI Smart Lock</h2>
      <div id="nukiStatus"></div>
    </section>
    <section class="card" id="about">
      <h2>Zugriffsschutz</h2>
      <p class="muted">Login/Auth folgt in einem späteren Schritt.</p>
      <a class="btn" href="/">&larr; Zurück zum Dashboard</a>
    </section>
    <section class="card">
      <h2>Firmware-Update</h2>
      <p class="muted">Aktuelle Version: <span id="updCurrent">…</span></p>
      <div id="updArea"></div>
    </section>
    <section class="card">
      <h2>Statischer QR-Code (Kundendisplay)</h2>
      <p class="muted">Dieser Textinhalt ist für den statischen QR-Code, den der Kunde mit der App scant. Drucke ihn einmalig aus und lege ihn gut sichtbar aus — oder rufe die <a href="/display">Kundendisplay-Seite</a> auf einem externen Gerät auf.</p>
      <label>Inhalt (exakt so übernehmen)
        <input type="text" id="qrContent" readonly>
      </label>
      <button class="btn" id="qrCopy">Inhalt kopieren</button>
      <div id="qrCopyStatus"></div>
      <p class="muted">Online-Generator z.B.:</p>
      <ul class="muted">
        <li><a href="https://www.qr-code-generator.com/" target="_blank" rel="noopener">qr-code-generator.com</a> → "Text" wählen, den Inhalt oben einfügen, Korrekturlevel M, als PNG/SVG herunterladen.</li>
        <li>Alternativ: <a href="https://qifi.org/" target="_blank" rel="noopener">qifi.org</a> (nur WiFi, also ungeeignet), <a href="https://duckduckgo.com/?q=qr+code+generator" target="_blank" rel="noopener">Suche</a>.</li>
      </ul>
      <p class="muted">Tipp: Kundendisplay-Seite <a href="/display">/display</a> zeigt den QR direkt im Browser, ggf. auf einem Tablet/Display im Türbereich.</p>
    </section>
  </main>
  <script src="/setup.js"></script>
</body>
</html>
)HTML";
