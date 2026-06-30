#include "http_api.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include <ArduinoJson.h>
#include <esp_timer.h>

static const char* TAG = "[HttpApi]";

// ============================================================
//  NUKI scan / pair state (run in dedicated tasks)
// ============================================================
enum class NScan { IDLE, SCANNING, DONE };
static volatile NScan          sNScan = NScan::IDLE;
static std::vector<NukiDevice> sNScanResults;

enum class NPair { IDLE, PAIRING, OK, FAILED };
static volatile NPair sNPair = NPair::IDLE;
static String         sNPairAddress;

static void nukiScanTaskOp(void* /*p*/) {
    NukiDriver tmp;
    tmp.begin();
    sNScanResults = tmp.scan(6000);
    sNScan = NScan::DONE;
    Serial.printf("[HttpApi] NUKI scan done: %d device(s)\n", (int)sNScanResults.size());
    vTaskDelete(nullptr);
}

static void nukiPairTaskOp(void* /*p*/) {
    NukiDriver tmp;
    tmp.begin();
    bool ok = tmp.pair(sNPairAddress, 30000);
    if (ok) {
        Config().setHardwareNuki(sNPairAddress, true);
    }
    sNPair = ok ? NPair::OK : NPair::FAILED;
    Serial.printf("[HttpApi] NUKI pairing %s\n", ok ? "OK" : "FAILED");
    vTaskDelete(nullptr);
}

const char* HttpApi::INDEX_HTML = R"rawhtml(<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>DoorInterface</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;background:#f0f2f5;min-height:100vh;display:flex;align-items:center;justify-content:center;position:relative}
  .card{background:#fff;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,.12);width:100%;max-width:420px;padding:28px;margin:16px}
  h1{font-size:1.3rem;color:#1a1a2e;margin-bottom:20px;text-align:center}
  .row{display:flex;justify-content:space-between;align-items:center;padding:10px 0;border-bottom:1px solid #f3f4f6;font-size:.9rem}
  .row:last-of-type{border-bottom:none}
  .label{color:#6b7280}.value{font-weight:600;color:#111}
  .badge{padding:3px 10px;border-radius:99px;font-size:.75rem;font-weight:700}
  .green{background:#dcfce7;color:#166534}.red{background:#fee2e2;color:#991b1b}.gray{background:#f3f4f6;color:#374151}
  .btn{display:block;width:100%;padding:14px;border:none;border-radius:10px;cursor:pointer;font-size:1rem;font-weight:700;margin-top:12px;transition:.2s;text-decoration:none;text-align:center}
  .open{background:#22c55e;color:#fff}.open:hover{background:#16a34a}
  .close{background:#ef4444;color:#fff}.close:hover{background:#dc2626}
  .pri{background:#2563eb;color:#fff}.pri:hover{background:#1d4ed8}
  .sec{background:#f3f4f6;color:#374151;border:1px solid #d1d5db;font-size:.85rem;font-weight:600}
  .sec:hover{background:#e5e7eb}
  .btn:disabled{opacity:.55;cursor:not-allowed}
  .settings{position:absolute;top:16px;right:16px;width:42px;height:42px;border-radius:50%;border:1px solid #d1d5db;background:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:1.3rem;text-decoration:none;color:#374151}
  .settings:hover{background:#f3f4f6}
  #msg{margin-top:12px;padding:10px;border-radius:8px;text-align:center;font-size:.88rem;display:none}
  .ok{background:#dcfce7;color:#166534}.err{background:#fee2e2;color:#991b1b}.info{background:#dbeafe;color:#1e40af}
  .spinner{display:inline-block;width:14px;height:14px;border:2px solid #fff;border-top-color:transparent;border-radius:50%;animation:spin .7s linear infinite;vertical-align:middle;margin-right:4px}
  .setup-box{margin-top:20px;padding:24px;background:#eff6ff;border-radius:12px;text-align:center}
  .setup-box h2{font-size:1.1rem;color:#1e40af;margin-bottom:10px}
  .setup-box p{color:#3b82f6;font-size:.9rem;margin-bottom:16px}
  @keyframes spin{to{transform:rotate(360deg)}}
</style>
</head>
<body>
<a class="settings" href="/settings" title="Einstellungen">&#9881;</a>
<div class="card">
  <h1>DoorInterface</h1>
  <div class="row"><span class="label">WLAN</span><span id="wifi" class="value">&mdash;</span></div>
  <div class="row"><span class="label">IP</span><span id="ip" class="value">&mdash;</span></div>

  <!-- Not paired: show setup call-to-action only -->
  <div id="setupBox" class="setup-box" style="display:none">
    <h2>Türöffner einrichten</h2>
    <p>Verbinde dein NUKI Smart Lock per Bluetooth, um die Tür zu steuern.</p>
    <a href="/settings" class="btn pri">NUKI koppeln</a>
  </div>

  <!-- Paired: show status and controls -->
  <div id="pairedBox" style="display:none">
    <div class="row"><span class="label">NUKI</span><span id="nukiState" class="value">&mdash;</span></div>
    <div class="row"><span class="label">Türstatus</span><span id="doorState" class="value">&mdash;</span></div>
    <button class="btn open" id="btnOpen" onclick="act('open',this)">Tür öffnen</button>
    <button class="btn close" id="btnClose" onclick="act('close',this)">Tür schließen</button>
  </div>

  <div id="msg"></div>
</div>
<script>
function fmtState(s){
  return s==='open'?'<span class="badge green">OFFEN</span>':
         s==='closed'?'<span class="badge red">ZU</span>':
         '<span class="badge gray">UNBEKANNT</span>';
}
function load(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/status',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    document.getElementById('wifi').textContent=d.wifi.connected?(d.wifi.ssid+' ('+d.wifi.rssi+' dBm)'):'getrennt';
    document.getElementById('ip').textContent=d.wifi.ip||'—';
    var paired=!!d.nuki_paired;
    document.getElementById('setupBox').style.display=paired?'none':'block';
    document.getElementById('pairedBox').style.display=paired?'block':'none';
    if(paired){
      document.getElementById('nukiState').innerHTML='<span class="badge green">GEKOPPELT</span>';
      document.getElementById('doorState').innerHTML=fmtState(d.door.state);
    }
  };
  xhr.send();
}
function act(a,btn){
  var o=btn.innerHTML;btn.disabled=true;btn.innerHTML='<span class="spinner"></span>';
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/'+a,true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    btn.disabled=false;btn.innerHTML=o;
    var e=document.getElementById('msg');
    if(xhr.status===200){e.className='msg ok';e.textContent=a==='open'?'Tür geöffnet':'Tür geschlossen';}
    else {try{var r=JSON.parse(xhr.responseText);e.className='msg err';e.textContent='Fehler: '+(r.error||xhr.status);}catch(x){e.className='msg err';e.textContent='Fehler: '+xhr.status;}}
    e.style.display='block';setTimeout(function(){e.style.display='none';},3000);load();
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML=o;var e=document.getElementById('msg');e.className='msg err';e.textContent='Netzwerkfehler';e.style.display='block';};
  xhr.send();
}
load();setInterval(load,5000);
</script>
</body>
</html>)rawhtml";
const char* HttpApi::SETTINGS_HTML = R"rawhtml(<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>NUKI Koppeln</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;background:#f0f2f5;min-height:100vh;display:flex;align-items:flex-start;justify-content:center}
  .card{background:#fff;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,.12);width:100%;max-width:440px;padding:28px;margin:16px}
  h1{font-size:1.25rem;color:#1a1a2e;margin-bottom:18px}
  .btn{display:block;width:100%;padding:11px;border:none;border-radius:8px;cursor:pointer;font-size:.9rem;font-weight:700;margin-top:14px;transition:.2s}
  .pri{background:#2563eb;color:#fff}.pri:hover{background:#1d4ed8}
  .sec{background:#f3f4f6;color:#374151;border:1px solid #d1d5db;font-weight:600;font-size:.85rem}
  .sec:hover{background:#e5e7eb}
  .danger{background:#fee2e2;color:#991b1b;border:1px solid #fecaca}
  .danger:hover{background:#fecaca}
  .btn:disabled{opacity:.55;cursor:not-allowed}
  .nlist{margin-top:10px;max-height:180px;overflow-y:auto;border:1px solid #e5e7eb;border-radius:8px}
  .nitem{padding:10px 12px;cursor:pointer;display:flex;justify-content:space-between;border-bottom:1px solid #f3f4f6;font-size:.88rem}
  .nitem:last-child{border-bottom:none}.nitem:hover{background:#eff6ff}.nitem.sel{background:#dbeafe;font-weight:700}
  .msg{margin-top:12px;padding:10px;border-radius:8px;text-align:center;font-size:.85rem;display:none}
  .ok{background:#dcfce7;color:#166534}.err{background:#fee2e2;color:#991b1b}.info{background:#dbeafe;color:#1e40af}
  .hint{font-size:.78rem;color:#6b7280;margin-top:12px}
  .spinner{display:inline-block;width:14px;height:14px;border:2px solid currentColor;border-top-color:transparent;border-radius:50%;animation:spin .7s linear infinite;vertical-align:middle;margin-right:5px}
  .section{margin-top:18px;padding:16px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:10px}
  .section h2{font-size:1rem;color:#374151;margin-bottom:8px}
  .section p{font-size:.85rem;color:#6b7280;margin-bottom:12px}
  @keyframes spin{to{transform:rotate(360deg)}}
  a.back{display:inline-block;margin-top:16px;color:#2563eb;text-decoration:none;font-size:.85rem}
</style>
</head>
<body>
<div class="card">
  <h1>NUKI koppeln</h1>

  <div id="pairedSection" class="section" style="display:none">
    <h2>Bereits gekoppelt</h2>
    <p id="pairedAddr">-</p>
    <button class="btn danger" id="btnForget" onclick="forgetNuki(this)">NUKI-Verbindung löschen</button>
  </div>

  <div id="pairSection" style="display:none">
    <button class="btn sec" id="btnScan" onclick="nukiScan()">NUKI suchen</button>
    <div id="nlist" class="nlist" style="display:none"></div>

    <div id="selectSection" style="display:none">
      <div class="msg info" style="display:block;margin-top:12px">Drücke den Knopf am NUKI 3 Sekunden, dann starte das Pairing.</div>
      <button class="btn pri" id="btnPair" onclick="nukiPair(this)" disabled>Pairing starten</button>
    </div>
  </div>

  <div id="nukiMsg" class="msg"></div>

  <a class="back" href="/">&larr; Zurück zum Dashboard</a>
</div>

<script>
var nukiAddr='', nScanTimer=null, nPairTimer=null;
function setMsg(type,m){var e=document.getElementById('nukiMsg');e.className='msg '+type;e.style.display='block';e.innerHTML=m;}
function loadStatus(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/status',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    var paired=!!d.nuki_paired;
    document.getElementById('pairedSection').style.display=paired?'block':'none';
    document.getElementById('pairSection').style.display=paired?'none':'block';
    if(paired) document.getElementById('pairedAddr').textContent=d.nuki_address||'-';
  };
  xhr.send();
}
function forgetNuki(btn){
  if(!confirm('NUKI-Verbindung wirklich löschen? Das Gerät startet danach neu.'))return;
  var o=btn.innerHTML;btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Löschen...';
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/nuki/forget',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    setMsg('ok','Verbindung gelöscht. Gerät startet neu...');
    setTimeout(function(){location.href='/';},3000);
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML=o;setMsg('err','Netzwerkfehler');};
  xhr.send();
}
function nukiScan(){
  var btn=document.getElementById('btnScan');
  if(nScanTimer){clearInterval(nScanTimer);nScanTimer=null;}
  btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Suche...';
  document.getElementById('nlist').style.display='none';document.getElementById('nlist').innerHTML='';
  document.getElementById('selectSection').style.display='none';
  nukiAddr='';document.getElementById('btnPair').disabled=true;
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/nuki/scan/start',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200){btn.disabled=false;btn.innerHTML='NUKI suchen';setMsg('err','Scan konnte nicht gestartet werden');return;}
    nukiPoll();nScanTimer=setInterval(nukiPoll,1500);
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML='NUKI suchen';setMsg('err','Netzwerkfehler');};
  xhr.send();
}
function nukiPoll(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/nuki/scan/result',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    if(d.status==='scanning'||d.status==='idle')return;
    if(nScanTimer){clearInterval(nScanTimer);nScanTimer=null;}
    var btn=document.getElementById('btnScan');btn.disabled=false;btn.innerHTML='NUKI suchen';
    var list=document.getElementById('nlist');list.innerHTML='';list.style.display='block';
    var devs=(d.devices&&Array.isArray(d.devices))?d.devices:[];
    if(devs.length>0){
      document.getElementById('selectSection').style.display='block';
      devs.forEach(function(dev){
        var div=document.createElement('div');div.className='nitem';
        div.innerHTML='<span>'+escapeHtml(dev.name||'NUKI')+'</span><span style="color:#6b7280">'+dev.rssi+' dBm</span>';
        div.onclick=function(){var it=document.getElementsByClassName('nitem');for(var i=0;i<it.length;i++)it[i].classList.remove('sel');div.classList.add('sel');nukiAddr=dev.address;document.getElementById('btnPair').disabled=false;};
        list.appendChild(div);
      });
    } else {
      list.innerHTML='<div style="padding:12px;color:#6b7280;font-size:.85rem;text-align:center">Keine NUKI-Geräte gefunden.</div>';
    }
  };
  xhr.send();
}
function nukiPair(btn){
  if(!nukiAddr){setMsg('err','Bitte ein Gerät auswählen.');return;}
  var o=btn.innerHTML;btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Pairing...';
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/nuki/pair/start',true);
  xhr.setRequestHeader('Content-Type','application/json');
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200){btn.disabled=false;btn.innerHTML=o;setMsg('err','Pairing konnte nicht gestartet werden');return;}
    nPairTimer=setInterval(function(){pairPoll(btn,o);},1500);
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML=o;setMsg('err','Netzwerkfehler');};
  xhr.send(JSON.stringify({address:nukiAddr}));
}
function pairPoll(btn,o){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/nuki/pair/status',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    if(d.status==='pairing')return;
    if(nPairTimer){clearInterval(nPairTimer);nPairTimer=null;}
    btn.disabled=false;btn.innerHTML=o;
    if(d.status==='ok'){setMsg('ok','Pairing erfolgreich! Gerät startet neu...');setTimeout(function(){location.href='/';},2000);}
    else setMsg('err','Pairing fehlgeschlagen. Knopf am NUKI gedrückt?');
  };
  xhr.send();
}
function escapeHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
loadStatus();
</script>
</body>
</html>)rawhtml";

HttpApi::HttpApi() : _server(80), _nuki(nullptr), _rebootAt(0) {}

void HttpApi::begin(NukiDriver* nuki) {
    _nuki = nuki;
    setupRoutes();
    _server.begin();
    Serial.printf("%s Started on port 80\n", TAG);
}

void HttpApi::process() {
    if (_rebootAt != 0 && millis() >= _rebootAt) {
        Serial.printf("%s Rebooting\n", TAG);
        ESP.restart();
    }
}

void HttpApi::setupRoutes() {
    _server.on("/", HTTP_GET, [this](AsyncWebServerRequest* r){ handleIndex(r); });
    _server.on("/settings", HTTP_GET, [this](AsyncWebServerRequest* r){ handleSettingsPage(r); });
    _server.on("/status", HTTP_GET, [this](AsyncWebServerRequest* r){ handleStatus(r); });
    _server.on("/open", HTTP_POST, [this](AsyncWebServerRequest* r){ handleOpen(r); });
    _server.on("/close", HTTP_POST, [this](AsyncWebServerRequest* r){ handleClose(r); });
    _server.on("/reset-wifi", HTTP_POST, [this](AsyncWebServerRequest* r){ handleResetWifi(r); });
    _server.on("/reboot", HTTP_POST, [this](AsyncWebServerRequest* r){ handleReboot(r); });

    _server.on("/nuki/scan/start", HTTP_POST, [this](AsyncWebServerRequest* r){ handleNukiScanStart(r); });
    _server.on("/nuki/scan/result", HTTP_GET, [this](AsyncWebServerRequest* r){ handleNukiScanResult(r); });
    _server.on("/nuki/pair/status", HTTP_GET, [this](AsyncWebServerRequest* r){ handleNukiPairStatus(r); });
    _server.on("/nuki/forget", HTTP_POST, [this](AsyncWebServerRequest* r){ handleNukiForget(r); });

    _server.on("/nuki/pair/start", HTTP_POST, [](AsyncWebServerRequest* r){}, nullptr,
        [this](AsyncWebServerRequest* r, uint8_t* d, size_t l, size_t i, size_t t){
            if (i + l == t) handleNukiPairStart(r, d, l);
        });

    _server.onNotFound([](AsyncWebServerRequest* r){
        r->send(404, "application/json", "{\"error\":\"Not found\"}");
    });
}

void HttpApi::handleIndex(AsyncWebServerRequest* req) {
    AsyncWebServerResponse* resp = req->beginResponse(200, "text/html", INDEX_HTML);
    resp->addHeader("Cache-Control", "no-store");
    req->send(resp);
}

void HttpApi::handleSettingsPage(AsyncWebServerRequest* req) {
    AsyncWebServerResponse* resp = req->beginResponse(200, "text/html", SETTINGS_HTML);
    resp->addHeader("Cache-Control", "no-store");
    req->send(resp);
}

void HttpApi::handleStatus(AsyncWebServerRequest* req) {
    JsonDocument doc;
    doc["device"] = Config().getDeviceName();

    auto wifi = doc["wifi"].to<JsonObject>();
    wifi["connected"] = Wifi().isConnected();
    wifi["ssid"]      = Wifi().getSSID();
    wifi["ip"]        = Wifi().getIP();
    wifi["rssi"]      = Wifi().getRSSI();

    bool paired = _nuki && _nuki->isPaired();
    doc["nuki_paired"] = paired;
    doc["nuki_address"] = Config().getNukiAddress();

    auto door = doc["door"].to<JsonObject>();
    door["state"] = paired ? doorStateStr(_nuki->getState()) : "unknown";
    door["ready"] = paired;

    doc["uptime_s"] = (uint32_t)(esp_timer_get_time() / 1000000ULL);

    String out; serializeJson(doc, out);
    sendJson(req, 200, out);
}

void HttpApi::handleOpen(AsyncWebServerRequest* req) {
    if (!_nuki || !_nuki->isPaired()) {
        sendJson(req, 503, "{\"success\":false,\"error\":\"NUKI not paired\"}");
        return;
    }
    bool ok = _nuki->open(Config().getOpenDurationMs());
    sendJson(req, ok ? 200 : 500, ok ? "{\"success\":true}" : "{\"success\":false,\"error\":\"Command failed\"}");
}

void HttpApi::handleClose(AsyncWebServerRequest* req) {
    if (!_nuki || !_nuki->isPaired()) {
        sendJson(req, 503, "{\"success\":false,\"error\":\"NUKI not paired\"}");
        return;
    }
    bool ok = _nuki->close();
    sendJson(req, ok ? 200 : 500, ok ? "{\"success\":true}" : "{\"success\":false,\"error\":\"Command failed\"}");
}

void HttpApi::handleNukiScanStart(AsyncWebServerRequest* req) {
    if (sNScan != NScan::SCANNING) {
        sNScan = NScan::SCANNING;
        sNScanResults.clear();
        xTaskCreate(nukiScanTaskOp, "nuki_scan_op", 8192, nullptr, 1, nullptr);
    }
    sendJson(req, 200, "{\"status\":\"scanning\"}");
}

void HttpApi::handleNukiScanResult(AsyncWebServerRequest* req) {
    if (sNScan == NScan::SCANNING) { sendJson(req, 200, "{\"status\":\"scanning\"}"); return; }
    if (sNScan == NScan::IDLE)     { sendJson(req, 200, "{\"status\":\"idle\"}"); return; }

    JsonDocument doc;
    doc["status"] = "done";
    JsonArray arr = doc["devices"].to<JsonArray>();
    for (const auto& dev : sNScanResults) {
        JsonObject o = arr.add<JsonObject>();
        o["name"]    = dev.name;
        o["address"] = dev.address;
        o["rssi"]    = dev.rssi;
    }
    String out; serializeJson(doc, out);
    Serial.printf("%s Serving NUKI scan result: %d devices\n", TAG, (int)sNScanResults.size());
    sNScan = NScan::IDLE;
    sendJson(req, 200, out);
}

void HttpApi::handleNukiPairStart(AsyncWebServerRequest* req, uint8_t* data, size_t len) {
    JsonDocument doc;
    if (deserializeJson(doc, data, len) != DeserializationError::Ok) {
        sendJson(req, 400, "{\"error\":\"Invalid JSON\"}");
        return;
    }
    sNPairAddress = doc["address"].as<String>();
    if (sNPair != NPair::PAIRING) {
        sNPair = NPair::PAIRING;
        xTaskCreate(nukiPairTaskOp, "nuki_pair_op", 8192, nullptr, 1, nullptr);
    }
    sendJson(req, 200, "{\"status\":\"pairing\"}");
}

void HttpApi::handleNukiPairStatus(AsyncWebServerRequest* req) {
    switch (sNPair) {
        case NPair::PAIRING: sendJson(req, 200, "{\"status\":\"pairing\"}"); break;
        case NPair::OK:      sNPair = NPair::IDLE; sendJson(req, 200, "{\"status\":\"ok\"}"); break;
        case NPair::FAILED:  sNPair = NPair::IDLE; sendJson(req, 200, "{\"status\":\"failed\"}"); break;
        default:             sendJson(req, 200, "{\"status\":\"idle\"}"); break;
    }
}

void HttpApi::handleNukiForget(AsyncWebServerRequest* req) {
    Config().setHardwareNuki("", false);
    sendJson(req, 200, "{\"success\":true,\"message\":\"NUKI pairing cleared. Rebooting...\"}");
    _rebootAt = millis() + 1000;
}

void HttpApi::handleResetWifi(AsyncWebServerRequest* req) {
    sendJson(req, 200, "{\"success\":true,\"message\":\"Rebooting into setup mode...\"}");
    Config().setWifi("", "");
    Config().setConfigured(false);
    _rebootAt = millis() + 1000;
}

void HttpApi::handleReboot(AsyncWebServerRequest* req) {
    sendJson(req, 200, "{\"success\":true}");
    _rebootAt = millis() + 800;
}

void HttpApi::sendJson(AsyncWebServerRequest* req, int code, const String& json) {
    AsyncWebServerResponse* resp = req->beginResponse(code, "application/json", json);
    resp->addHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    resp->addHeader("Pragma", "no-cache");
    req->send(resp);
}

String HttpApi::doorStateStr(DoorState s) {
    switch (s) {
        case DoorState::OPEN:   return "open";
        case DoorState::CLOSED: return "closed";
        default:                return "unknown";
    }
}
