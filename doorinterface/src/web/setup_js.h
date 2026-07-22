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
      html += '<p class="muted">NUKI ist erfolgreich gekoppelt. Tür-Status, Akku und RSSI werden im Dashboard angezeigt.</p>';
      html += '<div class="btn-row"><button class="btn" id="nukiOpen">Tür öffnen (Test)</button><button class="btn" id="nukiUnpair">Entkopplung</button></div>';
      html += '<h3 style="margin-top:1em">Status-Poll-Intervall</h3>';
      html += '<p class="muted">Wie oft soll der ESP den NUKI-Status aktiv abfragen? Kürzere Intervalle = schnellere Updates, aber höherer Stromverbrauch des NUKI.</p>';
      html += '<form id="nukiPollForm"><label>Intervall (Sekunden, 10–3600) <input type="number" id="nukiPollInput" min="10" max="3600" value="' + (lk.pollInterval || 120) + '" inputmode="numeric"></label>';
      html += '<button class="btn" id="nukiPollBtn">Speichern</button></form>';
      html += '<div id="nukiPollStatus" style="margin-top:0.5em"></div>';
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
  const p = $('nukiPair'), c = $('nukiCancel'), o = $('nukiOpen'), up = $('nukiUnpair'), pf = $('nukiPinForm'), pollf = $('nukiPollForm');
  if (p) p.onclick = async () => { p.disabled = true; await fetch('/api/nuki/pair', { method:'POST' }); setTimeout(refreshNuki, 500); };
  if (c) c.onclick = async () => { c.disabled = true; await fetch('/api/nuki/cancel', { method:'POST' }); setTimeout(refreshNuki, 500); };
  if (o) o.onclick = async () => { o.disabled = true; await fetch('/api/nuki/open', { method:'POST' }); setTimeout(refreshNuki, 1000); };
  if (up) up.onclick = async () => { up.disabled = true; await fetch('/api/nuki/unpair', { method:'POST' }); setTimeout(refreshNuki, 1000); };
  if (pollf) pollf.onsubmit = async (e) => {
    e.preventDefault();
    const v = $('nukiPollInput').value.trim();
    const n = parseInt(v, 10);
    if (!n || n < 10 || n > 3600) { $('nukiPollStatus').textContent = 'Bitte 10–3600 eingeben.'; return; }
    $('nukiPollBtn').disabled = true;
    try {
      const r = await fetch('/api/nuki/poll', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'interval='+encodeURIComponent(n) });
      const s = await r.json();
      if (r.ok) { $('nukiPollStatus').textContent = 'Gespeichert: ' + n + 's'; $('nukiPollBtn').disabled = false; }
      else { $('nukiPollStatus').textContent = 'Fehler: ' + (s.error || 'unbekannt'); $('nukiPollBtn').disabled = false; }
    } catch(err) { $('nukiPollStatus').textContent = 'Fehler'; $('nukiPollBtn').disabled = false; }
  };
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

let updPoll = null;
async function updRefresh() {
  try {
    const r = await fetch('/api/update/progress'); const s = await r.json();
    $('updCurrent').textContent = s.current || '?';
    let html = '';
    if (s.state === 'IDLE') {
      html = '<button class="btn" id="updCheck">Nach Update suchen</button>';
    } else if (s.state === 'CHECKING') {
      html = '<p class="muted">Prüfe GitHub…</p>';
    } else if (s.state === 'UPDATE_AVAILABLE') {
      html = '<p>Neue Version: <strong>' + (s.latest || '?') + '</strong></p>';
      html += '<button class="btn" id="updInstall">Jetzt installieren</button>';
    } else if (s.state === 'DOWNLOADING') {
      const pct = s.total > 0 ? Math.round((s.progress / s.total) * 100) : 0;
      html = '<p class="muted">Download läuft… ' + pct + '%</p>';
      html += '<progress value="' + (s.progress) + '" max="' + (s.total > 0 ? s.total : 100) + '"></progress>';
    } else if (s.state === 'DONE') {
      html = '<p><span class="badge ok">Installiert</span> Neustart erforderlich.</p>';
      html += '<button class="btn" id="updReboot">Gerät neu starten</button>';
    } else if (s.state === 'FAILED') {
      html = '<p><span class="badge err">Fehler</span> ' + (s.error || 'unbekannt') + '</p>';
      html += '<button class="btn" id="updCheck">Erneut suchen</button>';
    }
    $('updArea').innerHTML = html;
    const c = $('updCheck'), i = $('updInstall'), rb = $('updReboot');
    if (c) c.onclick = async () => { c.disabled = true; await fetch('/api/update/check', { method:'POST' }); startUpdPoll(); };
    if (i) i.onclick = async () => { i.disabled = true; await fetch('/api/update/start', { method:'POST' }); startUpdPoll(); };
    if (rb) rb.onclick = async () => { rb.disabled = true; await fetch('/api/reboot', { method:'POST' }); document.body.innerHTML = '<p style="text-align:center;margin-top:3em">Neustart... bitte warten.</p>'; };
    if (s.state === 'CHECKING' || s.state === 'DOWNLOADING') {
      startUpdPoll();
    } else {
      stopUpdPoll();
    }
  } catch(e) {}
}
function startUpdPoll() { if (!updPoll) updPoll = setInterval(updRefresh, 1000); }
function stopUpdPoll() { if (updPoll) { clearInterval(updPoll); updPoll = null; } }
updRefresh();
)JS";
