#pragma once
#include <pgmspace.h>

const char SETUP_JS[] PROGMEM = R"JS(
const $ = id => document.getElementById(id);

(async () => {
  try { const r = await fetch('/api/hostname'); const h = await r.json(); if (h.hostname) $('hostInput').value = h.hostname; } catch(e){}
  try {
    const r = await fetch('/api/ble/info'); const b = await r.json();
    if (b.qrContent) {
      $('qrContent').value = b.qrContent;
      $('qrCopy').onclick = async () => {
        try {
          await navigator.clipboard.writeText(b.qrContent);
          $('qrCopyStatus').textContent = 'In die Zwischenablage kopiert.';
        } catch (e) {
          $('qrCopyStatus').textContent = 'Kopieren fehlgeschlagen — bitte manuell auswählen.';
        }
      };
    }
  } catch(e){}
})();

$('hostForm').onsubmit = async (e) => {
  e.preventDefault();
  const v = $('hostInput').value.trim();
  if (!v) { $('hostStatus').textContent = 'Hostname darf nicht leer sein'; return; }
  $('hostBtn').disabled = true;
  $('hostStatus').textContent = 'speichere ...';
  try {
    const r = await fetch('/api/hostname', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'hostname='+encodeURIComponent(v) });
    const s = await r.json();
    if (r.ok) {
      $('hostStatus').innerHTML = 'Gespeichert. Gerät startet neu — erreichbar unter <a href="http://'+v+'.local">http://'+v+'.local</a>';
    } else {
      $('hostStatus').textContent = 'Fehler: ' + (s.error || 'ungültiger Hostname');
      $('hostBtn').disabled = false;
    }
  } catch(err) { $('hostStatus').textContent = 'Fehler'; $('hostBtn').disabled = false; }
};

async function refreshNuki() {
  try {
    const r = await fetch('/api/status'); const s = await r.json();
    const lk = s.locks;
    let html = '';
    if (lk.pairing) {
      html = '<p class="muted">Pairing läuft … Taste am Nuki 10s gedrückt halten, bis der LED-Ring leuchtet.</p>';
      html += '<button class="btn" id="nukiCancel">Pairing abbrechen</button>';
    } else if (lk.paired) {
      html = '<p><span class="badge ok">eingerichtet</span></p>';
      html += '<p class="muted">NUKI ist erfolgreich gekoppelt.Tür-Status, Akku und RSSI werden im Dashboard angezeigt.</p>';
      html += '<div class="btn-row"><button class="btn" id="nukiOpen">Tür öffnen (Test)</button><button class="btn" id="nukiUnpair">Entkopplung</button></div>';
    } else {
      html = '<p class="muted">Nicht gekoppelt.</p>';
      html += '<p class="muted">1. In der Nuki App: Bluetooth Pairing aktivieren (Settings → Features & Configuration → Button and LED).</p>';
      html += '<p class="muted">2. Taste am Nuki 10s drücken, bis der LED-Ring leuchtet.</p>';
      if (!lk.hasUltraPin) {
        html += '<p class="muted" style="color:#c62828">Achtung: Für Smart Lock Go / Ultra / 5.0 / Pro muss unten eine 6-stellige PIN eingegeben sein (dieselbe wie in der Nuki-App).</p>';
      }
      html += '<p class="muted">3. Hier Pairing starten:</p>';
      html += '<button class="btn" id="nukiPair">Pairing starten</button>';
    }
    $('nukiStatus').innerHTML = html;

    let pinHtml = '';
    if (!lk.paired && !lk.pairing) {
      pinHtml = '<h3 style="margin-top:1em">Ultra-/Go-PIN</h3>';
      pinHtml += '<p class="muted">Nur für Smart Lock Go / Ultra / 5.0 / Pro nötig. Standard-Locks (1.0–4.0) brauchen keine PIN.</p>';
      pinHtml += '<p class="muted">Status: <span class="badge ' + (lk.hasUltraPin ? 'ok' : 'err') + '">' + (lk.hasUltraPin ? 'PIN gesetzt' : 'keine PIN') + '</span></p>';
      pinHtml += '<form id="nukiPinForm"><label>6-stellige PIN <input type="password" id="nukiPinInput" pattern="[0-9]{6}" maxlength="6" inputmode="numeric" title="Genau 6 Ziffern"></label>';
      pinHtml += '<button class="btn" id="nukiPinBtn">PIN speichern</button></form>';
      pinHtml += '<div id="nukiPinStatus" style="margin-top:0.5em"></div>';
    }
    $('nukiPinSection').innerHTML = pinHtml;
    bindNuki();
  } catch (e) {}
}

function bindNuki() {
  const p = $('nukiPair'), c = $('nukiCancel'), o = $('nukiOpen'), up = $('nukiUnpair'), pf = $('nukiPinForm');
  if (p) p.onclick = async () => { p.disabled = true; await fetch('/api/nuki/pair', { method:'POST' }); setTimeout(refreshNuki, 500); };
  if (c) c.onclick = async () => { c.disabled = true; await fetch('/api/nuki/cancel', { method:'POST' }); setTimeout(refreshNuki, 500); };
  if (o) o.onclick = async () => { o.disabled = true; await fetch('/api/nuki/open', { method:'POST' }); setTimeout(refreshNuki, 1000); };
  if (up) up.onclick = async () => { up.disabled = true; await fetch('/api/nuki/unpair', { method:'POST' }); setTimeout(refreshNuki, 1000); };
  if (pf) pf.onsubmit = async (e) => {
    e.preventDefault();
    const v = $('nukiPinInput').value.trim();
    if (!/^[0-9]{6}$/.test(v)) { $('nukiPinStatus').textContent = 'Bitte genau 6 Ziffern eingeben.'; return; }
    $('nukiPinBtn').disabled = true;
    try {
      const r = await fetch('/api/nuki/pin', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'pin='+encodeURIComponent(v) });
      const s = await r.json();
      if (r.ok) { $('nukiPinStatus').textContent = 'PIN gespeichert.'; $('nukiPinInput').value = ''; setTimeout(refreshNuki, 500); }
      else { $('nukiPinStatus').textContent = 'Fehler: ' + (s.error || 'unbekannt'); $('nukiPinBtn').disabled = false; }
    } catch(err) { $('nukiPinStatus').textContent = 'Fehler'; $('nukiPinBtn').disabled = false; }
  };
}

refreshNuki();
)JS";
