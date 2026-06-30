#include "config_manager.h"

void ConfigManager::begin() {
    _prefs.begin(NVS_NAMESPACE, false);
    loadDefaults();

    _cfg.wifiSSID             = _prefs.getString("wifi_ssid",      "");
    _cfg.wifiPassword         = _prefs.getString("wifi_pass",      "");
    _cfg.serverUrl            = _prefs.getString("server_url",     "");
    _cfg.hardwareType         = static_cast<HardwareType>(_prefs.getUChar("hw_type", 0));
    _cfg.relayPin             = _prefs.getUChar("relay_pin",       18);
    _cfg.relayNormallyClosed  = _prefs.getBool("relay_nc",         false);
    _cfg.openDurationMs       = _prefs.getUInt("open_duration_ms", 3000);
    _cfg.nukiAddress          = _prefs.getString("nuki_address",   "");
    _cfg.nukiPaired           = _prefs.getBool("nuki_paired",      false);
    _cfg.deviceName           = _prefs.getString("device_name",    "doorinterface");
    _cfg.isConfigured         = _prefs.getBool("is_configured",    false);

    // OTA — NVS keys are <=15 chars (Preferences limit). HTTP/JSON names are
    // the long ones from the spec. Mapping:
    //   ota_man_url      <- ota_manifest_url
    //   ota_chan_lbl     <- ota_channel_label
    //   ota_auto_check   <- ota_auto_check
    //   ota_chk_int_min  <- ota_check_interval_min
    //   last_boot_ver    <- last_boot_version
    _cfg.otaManifestUrl       = _prefs.getString("ota_man_url",
        "https://raw.githubusercontent.com/itsfair/top_attempt/main/doorinterface/firmware/manifest-dev.json");
    _cfg.otaChannelLabel      = _prefs.getString("ota_chan_lbl",     "dev");
    _cfg.otaAutoCheck         = _prefs.getBool("ota_auto_check",     true);
    _cfg.otaCheckIntervalMin  = _prefs.getUInt("ota_chk_int_min",    360);
    _cfg.lastBootVersion      = _prefs.getString("last_boot_ver",    "");

    Serial.println("[Config] Loaded from NVS");
    Serial.printf("[Config] WiFi SSID: %s\n", _cfg.wifiSSID.c_str());
    Serial.printf("[Config] Hardware: %d  Configured: %s\n",
                  (int)_cfg.hardwareType, _cfg.isConfigured ? "yes" : "no");
}

void ConfigManager::save() {
    _prefs.putString("wifi_ssid",      _cfg.wifiSSID);
    _prefs.putString("wifi_pass",      _cfg.wifiPassword);
    _prefs.putString("server_url",     _cfg.serverUrl);
    _prefs.putUChar("hw_type",         static_cast<uint8_t>(_cfg.hardwareType));
    _prefs.putUChar("relay_pin",       _cfg.relayPin);
    _prefs.putBool("relay_nc",         _cfg.relayNormallyClosed);
    _prefs.putUInt("open_duration_ms", _cfg.openDurationMs);
    _prefs.putString("nuki_address",   _cfg.nukiAddress);
    _prefs.putBool("nuki_paired",      _cfg.nukiPaired);
    _prefs.putString("device_name",    _cfg.deviceName);
    _prefs.putBool("is_configured",    _cfg.isConfigured);

    _prefs.putString("ota_man_url",       _cfg.otaManifestUrl);
    _prefs.putString("ota_chan_lbl",      _cfg.otaChannelLabel);
    _prefs.putBool("ota_auto_check",      _cfg.otaAutoCheck);
    _prefs.putUInt("ota_chk_int_min",     _cfg.otaCheckIntervalMin);
    _prefs.putString("last_boot_ver",     _cfg.lastBootVersion);
    Serial.println("[Config] Saved to NVS");
}

void ConfigManager::reset() {
    _prefs.clear();
    loadDefaults();
    Serial.println("[Config] Factory reset — NVS cleared");
}

void ConfigManager::loadDefaults() {
    _cfg.wifiSSID            = "";
    _cfg.wifiPassword        = "";
    _cfg.serverUrl           = "";
    _cfg.hardwareType        = HardwareType::NONE;
    _cfg.relayPin            = 18;
    _cfg.relayNormallyClosed = false;
    _cfg.openDurationMs      = 3000;
    _cfg.nukiAddress         = "";
    _cfg.nukiPaired          = false;
    _cfg.deviceName          = "doorinterface";
    _cfg.isConfigured        = false;
    _cfg.otaManifestUrl      = "https://raw.githubusercontent.com/itsfair/top_attempt/main/doorinterface/firmware/manifest-dev.json";
    _cfg.otaChannelLabel     = "dev";
    _cfg.otaAutoCheck        = true;
    _cfg.otaCheckIntervalMin = 360;
    _cfg.lastBootVersion     = "";
}

// --- Mutators ---

void ConfigManager::setWifi(const String& ssid, const String& password) {
    _cfg.wifiSSID     = ssid;
    _cfg.wifiPassword = password;
    _prefs.putString("wifi_ssid", ssid);
    _prefs.putString("wifi_pass", password);
}

void ConfigManager::setServerUrl(const String& url) {
    _cfg.serverUrl = url;
    _prefs.putString("server_url", url);
}

void ConfigManager::setHardwareRelay(uint8_t pin, bool normallyClosed, uint32_t durationMs) {
    _cfg.hardwareType        = HardwareType::RELAY;
    _cfg.relayPin            = pin;
    _cfg.relayNormallyClosed = normallyClosed;
    _cfg.openDurationMs      = durationMs;
    _prefs.putUChar("hw_type",         static_cast<uint8_t>(HardwareType::RELAY));
    _prefs.putUChar("relay_pin",       pin);
    _prefs.putBool("relay_nc",         normallyClosed);
    _prefs.putUInt("open_duration_ms", durationMs);
}

void ConfigManager::setHardwareNuki(const String& address, bool paired) {
    _cfg.hardwareType = HardwareType::NUKI;
    _cfg.nukiAddress  = address;
    _cfg.nukiPaired   = paired;
    _prefs.putUChar("hw_type",      static_cast<uint8_t>(HardwareType::NUKI));
    _prefs.putString("nuki_address", address);
    _prefs.putBool("nuki_paired",    paired);
}

void ConfigManager::setHardwareType(HardwareType type) {
    _cfg.hardwareType = type;
    _prefs.putUChar("hw_type", static_cast<uint8_t>(type));
}

void ConfigManager::setOpenDurationMs(uint32_t ms) {
    _cfg.openDurationMs = ms;
    _prefs.putUInt("open_duration_ms", ms);
}

void ConfigManager::setNukiPaired(bool paired) {
    _cfg.nukiPaired = paired;
    _prefs.putBool("nuki_paired", paired);
}

void ConfigManager::setNukiAddress(const String& address) {
    _cfg.nukiAddress = address;
    _prefs.putString("nuki_address", address);
}

void ConfigManager::setDeviceName(const String& name) {
    _cfg.deviceName = name;
    _prefs.putString("device_name", name);
}

void ConfigManager::setConfigured(bool configured) {
    _cfg.isConfigured = configured;
    _prefs.putBool("is_configured", configured);
}

// --- OTA setters ---

void ConfigManager::setOtaManifestUrl(const String& url) {
    _cfg.otaManifestUrl = url;
    _prefs.putString("ota_man_url", url);
}

void ConfigManager::setOtaChannelLabel(const String& label) {
    _cfg.otaChannelLabel = label;
    _prefs.putString("ota_chan_lbl", label);
}

void ConfigManager::setOtaAutoCheck(bool enabled) {
    _cfg.otaAutoCheck = enabled;
    _prefs.putBool("ota_auto_check", enabled);
}

void ConfigManager::setOtaCheckIntervalMin(uint32_t minutes) {
    _cfg.otaCheckIntervalMin = minutes;
    _prefs.putUInt("ota_chk_int_min", minutes);
}

void ConfigManager::setLastBootVersion(const String& version) {
    _cfg.lastBootVersion = version;
    _prefs.putString("last_boot_ver", version);
}
