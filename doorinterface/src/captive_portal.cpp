#include "captive_portal.h"
#include "config_manager.h"
#include "wifi_manager.h"
#include <ArduinoJson.h>

static const char* TAG = "[Portal]";

// ============================================================
//  Scan state (WiFi scan runs in a dedicated FreeRTOS task)
// ============================================================
enum class ScanState { IDLE, SCANNING, DONE };
static volatile ScanState       sScanState = ScanState::IDLE;
static std::vector<WiFiNetwork> sScanResults;
static SemaphoreHandle_t        sScanMutex = nullptr;

static void wifiScanTask(void* /*param*/) {
    int n = WiFi.scanNetworks(/*async=*/false, /*hidden=*/true);

    std::vector<WiFiNetwork> found;
    if (n > 0) {
        for (int i = 0; i < n; i++) {
            String ssid = WiFi.SSID(i);
            if (ssid.isEmpty()) continue;
            WiFiNetwork net;
            net.ssid = ssid;
            net.rssi = WiFi.RSSI(i);
            net.open = (WiFi.encryptionType(i) == WIFI_AUTH_OPEN);
            found.push_back(net);
        }
    }
    WiFi.scanDelete();

    if (sScanMutex) xSemaphoreTake(sScanMutex, portMAX_DELAY);
    sScanResults = found;
    if (sScanMutex) xSemaphoreGive(sScanMutex);

    sScanState = ScanState::DONE;
    Serial.printf("%s WiFi scan done: %d found, %d usable\n",
                  TAG, n, (int)found.size());
    vTaskDelete(nullptr);
}

// ============================================================
//  WiFi connect test (non-blocking, driven by process())
// ============================================================
enum class ConnState { IDLE, REQUESTED, CONNECTING, OK, FAILED };
static volatile ConnState sConnState = ConnState::IDLE;
static String             sConnSsid;
static String             sConnPass;
static uint32_t           sConnStart = 0;
static uint32_t           sRebootAt  = 0;

// ============================================================
//  Setup Wizard HTML (WiFi only)
// ============================================================
const char* CaptivePortal::SETUP_HTML = R"rawhtml(<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>DoorInterface Setup</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;background:#f0f2f5;min-height:100vh;display:flex;align-items:center;justify-content:center}
  .card{background:#fff;border-radius:12px;box-shadow:0 4px 20px rgba(0,0,0,.12);width:100%;max-width:440px;padding:30px;margin:16px}
  h1{font-size:1.4rem;color:#1a1a2e;margin-bottom:6px;text-align:center}
  .sub{text-align:center;color:#6b7280;font-size:.85rem;margin-bottom:22px}
  label{display:block;font-size:.85rem;color:#555;margin-bottom:4px;margin-top:14px}
  input{width:100%;padding:11px 12px;border:1px solid #d1d5db;border-radius:8px;font-size:.95rem;outline:none}
  input:focus{border-color:#2563eb;box-shadow:0 0 0 3px rgba(37,99,235,.15)}
  .btn{display:block;width:100%;padding:12px;border:none;border-radius:8px;cursor:pointer;font-size:.95rem;font-weight:700;margin-top:16px;transition:.2s}
  .btn-primary{background:#2563eb;color:#fff}
  .btn-primary:hover{background:#1d4ed8}
  .btn-secondary{background:#f3f4f6;color:#374151;border:1px solid #d1d5db;font-size:.85rem;font-weight:600}
  .btn-secondary:hover{background:#e5e7eb}
  .btn:disabled{opacity:.55;cursor:not-allowed}
  .net-list{margin-top:10px;max-height:220px;overflow-y:auto;border:1px solid #e5e7eb;border-radius:8px}
  .net-item{padding:11px 14px;cursor:pointer;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #f3f4f6;font-size:.9rem}
  .net-item:last-child{border-bottom:none}
  .net-item:hover{background:#eff6ff}
  .net-item.selected{background:#dbeafe;font-weight:700}
  .rssi{font-size:.75rem;color:#6b7280}
  .lock{font-size:.7rem;color:#f59e0b;margin-left:4px}
  .status{margin-top:14px;padding:11px 14px;border-radius:8px;font-size:.87rem;display:none}
  .status.ok{background:#dcfce7;color:#166534;display:block}
  .status.err{background:#fee2e2;color:#991b1b;display:block}
  .status.info{background:#dbeafe;color:#1e40af;display:block}
  .spinner{display:inline-block;width:15px;height:15px;border:2px solid currentColor;border-top-color:transparent;border-radius:50%;animation:spin .7s linear infinite;vertical-align:middle;margin-right:6px}
  @keyframes spin{to{transform:rotate(360deg)}}
</style>
</head>
<body>
<div class="card">
  <h1>DoorInterface</h1>
  <div class="sub">WLAN einrichten</div>

  <button class="btn btn-secondary" id="btnScan" onclick="scan()">Netzwerke suchen</button>
  <div id="netList" class="net-list" style="display:none"></div>

  <label>WLAN-Name (SSID)</label>
  <input type="text" id="ssid" placeholder="Netzwerkname" autocomplete="off">

  <label>Passwort</label>
  <input type="password" id="pass" placeholder="Passwort (leer wenn offen)" autocomplete="off">

  <button class="btn btn-primary" id="btnConnect" onclick="connect()">Verbinden &amp; Speichern</button>

  <div id="status" class="status"></div>
</div>

<script>
function setStatus(type,msg){var e=document.getElementById('status');e.className='status '+type;e.innerHTML=msg;}

var scanTimer=null, connTimer=null;

function scan(){
  var btn=document.getElementById('btnScan');
  if(scanTimer){clearInterval(scanTimer);scanTimer=null;}
  btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Suche...';
  document.getElementById('netList').style.display='none';
  document.getElementById('netList').innerHTML='';
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/scan/start',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200){btn.disabled=false;btn.innerHTML='Netzwerke suchen';setStatus('err','Scan konnte nicht gestartet werden');return;}
    pollScan();
    scanTimer=setInterval(pollScan,1200);
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML='Netzwerke suchen';setStatus('err','Netzwerkfehler');};
  xhr.send();
}
function pollScan(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/scan/result',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    if(d.status==='scanning'||d.status==='idle')return;
    if(scanTimer){clearInterval(scanTimer);scanTimer=null;}
    var btn=document.getElementById('btnScan');btn.disabled=false;btn.innerHTML='Netzwerke suchen';
    renderNetworks(d.networks||[]);
  };
  xhr.send();
}
function renderNetworks(nets){
  var list=document.getElementById('netList');
  list.innerHTML='';list.style.display='block';
  if(!nets.length){
    list.innerHTML='<div style="padding:12px;color:#6b7280;font-size:.85rem">Keine Netzwerke gefunden</div>';
    return;
  }
  nets.sort(function(a,b){return b.rssi-a.rssi;});
  nets.forEach(function(n){
    var div=document.createElement('div');div.className='net-item';
    div.innerHTML='<span>'+escapeHtml(n.ssid)+(n.open?'':' <span class="lock">&#128274;</span>')+'</span><span class="rssi">'+n.rssi+'&nbsp;dBm</span>';
    div.onclick=function(){
      var items=document.getElementsByClassName('net-item');
      for(var i=0;i<items.length;i++)items[i].classList.remove('selected');
      div.classList.add('selected');
      document.getElementById('ssid').value=n.ssid;
      document.getElementById('pass').focus();
    };
    list.appendChild(div);
  });
}
function escapeHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}

function connect(){
  var ssid=document.getElementById('ssid').value.trim();
  var pass=document.getElementById('pass').value;
  if(!ssid){setStatus('err','Bitte WLAN-Name eingeben oder ein Netzwerk auswählen.');return;}
  var btn=document.getElementById('btnConnect');
  btn.disabled=true;btn.innerHTML='<span class="spinner"></span>Verbinde...';
  setStatus('info','Verbinde mit "'+escapeHtml(ssid)+'"...');
  var xhr=new XMLHttpRequest();
  xhr.open('POST','/connect',true);
  xhr.setRequestHeader('Content-Type','application/json');
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200){btn.disabled=false;btn.innerHTML='Verbinden &amp; Speichern';setStatus('err','Fehler: '+xhr.status);return;}
    pollConnect();
    connTimer=setInterval(pollConnect,1200);
  };
  xhr.onerror=function(){btn.disabled=false;btn.innerHTML='Verbinden &amp; Speichern';setStatus('err','Netzwerkfehler');};
  xhr.send(JSON.stringify({ssid:ssid,password:pass}));
}
function pollConnect(){
  var xhr=new XMLHttpRequest();
  xhr.open('GET','/connect/status',true);
  xhr.setRequestHeader('Accept','application/json');
  xhr.onload=function(){
    if(xhr.status!==200)return;
    var d; try{d=JSON.parse(xhr.responseText);}catch(e){return;}
    if(d.status==='connecting')return;
    if(connTimer){clearInterval(connTimer);connTimer=null;}
    var btn=document.getElementById('btnConnect');
    if(d.status==='ok'){
      setStatus('ok','Verbunden! IP: '+d.ip+'<br>Gerät startet neu. Verbinde dich anschließend mit deinem WLAN und öffne http://'+(d.host||'doorinterface')+'.local');
      btn.style.display='none';
    } else {
      btn.disabled=false;btn.innerHTML='Verbinden &amp; Speichern';
      setStatus('err','Verbindung fehlgeschlagen. Passwort prüfen und erneut versuchen.');
    }
  };
  xhr.send();
}
</script>
</body>
</html>)rawhtml";

// ============================================================
//  CaptivePortal implementation
// ============================================================

CaptivePortal::CaptivePortal()
    : _server(80), _saved(false) {}

void CaptivePortal::begin() {
    if (!sScanMutex) sScanMutex = xSemaphoreCreateMutex();
    sScanState = ScanState::IDLE;
    sConnState = ConnState::IDLE;
    sRebootAt  = 0;
    {
        if (sScanMutex) xSemaphoreTake(sScanMutex, portMAX_DELAY);
        sScanResults.clear();
        if (sScanMutex) xSemaphoreGive(sScanMutex);
    }

    setupRoutes();
    _dns.start(53, "*", IPAddress(192, 168, 4, 1));
    _server.begin();
    Serial.printf("%s Setup wizard active at http://192.168.4.1\n", TAG);
}

void CaptivePortal::process() {
    _dns.processNextRequest();

    // Non-blocking WiFi connect test
    if (sConnState == ConnState::REQUESTED) {
        Serial.printf("%s Connecting to '%s'...\n", TAG, sConnSsid.c_str());
        WiFi.begin(sConnSsid.c_str(), sConnPass.c_str());
        sConnStart = millis();
        sConnState = ConnState::CONNECTING;
    } else if (sConnState == ConnState::CONNECTING) {
        if (WiFi.status() == WL_CONNECTED) {
            Serial.printf("%s Connected! IP: %s\n", TAG, WiFi.localIP().toString().c_str());
            Config().setWifi(sConnSsid, sConnPass);
            Config().setConfigured(true);
            sConnState = ConnState::OK;
            sRebootAt  = millis() + 4000;
        } else if (millis() - sConnStart > 15000) {
            Serial.printf("%s Connect timeout\n", TAG);
            WiFi.disconnect();
            sConnState = ConnState::FAILED;
        }
    }

    // Scheduled reboot after successful save
    if (sRebootAt != 0 && millis() >= sRebootAt) {
        Serial.printf("%s Rebooting into operational mode\n", TAG);
        ESP.restart();
    }
}

void CaptivePortal::setupRoutes() {
    _server.on("/", HTTP_GET, [this](AsyncWebServerRequest* req) {
        handleRoot(req);
    });
    _server.on("/setup", HTTP_GET, [this](AsyncWebServerRequest* req) {
        handleSetupPage(req);
    });

    _server.on("/scan/start", HTTP_POST, [this](AsyncWebServerRequest* req) {
        handleScanStart(req);
    });
    _server.on("/scan/result", HTTP_GET, [this](AsyncWebServerRequest* req) {
        handleScanResult(req);
    });

    _server.on("/connect", HTTP_POST,
        [](AsyncWebServerRequest* req) {},
        nullptr,
        [this](AsyncWebServerRequest* req, uint8_t* data, size_t len, size_t idx, size_t total) {
            if (idx + len == total) handleConnect(req, data, len);
        }
    );
    _server.on("/connect/status", HTTP_GET, [this](AsyncWebServerRequest* req) {
        handleConnectStatus(req);
    });

    // Captive portal detection endpoints -> redirect to setup page
    _server.onNotFound([](AsyncWebServerRequest* req) {
        req->redirect("http://192.168.4.1/setup");
    });
}

// ---- Handlers ----

void CaptivePortal::handleRoot(AsyncWebServerRequest* req) {
    req->redirect("/setup");
}

void CaptivePortal::handleSetupPage(AsyncWebServerRequest* req) {
    AsyncWebServerResponse* resp =
        req->beginResponse(200, "text/html", SETUP_HTML);
    resp->addHeader("Cache-Control", "no-store");
    req->send(resp);
}

void CaptivePortal::handleScanStart(AsyncWebServerRequest* req) {
    if (sScanState != ScanState::SCANNING) {
        sScanState = ScanState::SCANNING;
        Serial.printf("%s WiFi scan task starting\n", TAG);
        xTaskCreatePinnedToCore(wifiScanTask, "wifi_scan", 4096, nullptr, 1, nullptr, 0);
    }
    sendNoCacheJson(req, 200, "{\"status\":\"scanning\"}");
}

void CaptivePortal::handleScanResult(AsyncWebServerRequest* req) {
    if (sScanState == ScanState::SCANNING) {
        sendNoCacheJson(req, 200, "{\"status\":\"scanning\"}");
        return;
    }
    if (sScanState == ScanState::IDLE) {
        sendNoCacheJson(req, 200, "{\"status\":\"idle\"}");
        return;
    }

    JsonDocument doc;
    doc["status"] = "done";
    JsonArray arr = doc["networks"].to<JsonArray>();
    if (sScanMutex) xSemaphoreTake(sScanMutex, portMAX_DELAY);
    for (const auto& net : sScanResults) {
        JsonObject o = arr.add<JsonObject>();
        o["ssid"] = net.ssid;
        o["rssi"] = net.rssi;
        o["open"] = net.open;
    }
    int count = (int)sScanResults.size();
    if (sScanMutex) xSemaphoreGive(sScanMutex);

    String out;
    serializeJson(doc, out);
    Serial.printf("%s Serving scan result: %d networks, %d bytes\n",
                  TAG, count, (int)out.length());
    sScanState = ScanState::IDLE; // allow re-scan
    sendNoCacheJson(req, 200, out);
}

void CaptivePortal::handleConnect(AsyncWebServerRequest* req,
                                   uint8_t* data, size_t len) {
    JsonDocument doc;
    if (deserializeJson(doc, data, len) != DeserializationError::Ok) {
        sendNoCacheJson(req, 400, "{\"error\":\"Invalid JSON\"}");
        return;
    }
    sConnSsid = doc["ssid"].as<String>();
    sConnPass = doc["password"].as<String>();
    if (sConnSsid.isEmpty()) {
        sendNoCacheJson(req, 400, "{\"error\":\"SSID required\"}");
        return;
    }
    sConnState = ConnState::REQUESTED;
    Serial.printf("%s Connect requested for '%s'\n", TAG, sConnSsid.c_str());
    sendNoCacheJson(req, 200, "{\"status\":\"connecting\"}");
}

void CaptivePortal::handleConnectStatus(AsyncWebServerRequest* req) {
    switch (sConnState) {
        case ConnState::IDLE:
        case ConnState::REQUESTED:
        case ConnState::CONNECTING:
            sendNoCacheJson(req, 200, "{\"status\":\"connecting\"}");
            break;
        case ConnState::OK: {
            _saved = true;
            String ip   = WiFi.localIP().toString();
            String host = Config().getDeviceName();
            sendNoCacheJson(req, 200,
                "{\"status\":\"ok\",\"ip\":\"" + ip + "\",\"host\":\"" + host + "\"}");
            break;
        }
        case ConnState::FAILED:
            sConnState = ConnState::IDLE; // allow retry
            sendNoCacheJson(req, 200, "{\"status\":\"failed\"}");
            break;
    }
}

// ---- Utility ----

void CaptivePortal::sendNoCacheJson(AsyncWebServerRequest* req,
                                     int code, const String& json) {
    AsyncWebServerResponse* resp =
        req->beginResponse(code, "application/json", json);
    resp->addHeader("Cache-Control", "no-store, no-cache, must-revalidate");
    req->send(resp);
}
