#pragma once

#include <Arduino.h>
#include <Preferences.h>

// Hardware types
enum class HardwareType : uint8_t {
    NONE  = 0,
    RELAY = 1,
    NUKI  = 2
};

// All persistent device configuration
struct DeviceConfig {
    // WiFi
    String wifiSSID;
    String wifiPassword;

    // Local server
    String serverUrl;

    // Hardware
    HardwareType hardwareType;
    uint8_t      relayPin;
    bool         relayNormallyClosed; // true = normally closed (NC)
    uint32_t     openDurationMs;

    // NUKI
    String nukiAddress;  // BLE MAC address
    bool   nukiPaired;

    // Device
    String deviceName;
    bool   isConfigured; // Setup wizard completed
};

// Singleton configuration manager backed by NVS (Non-Volatile Storage)
class ConfigManager {
public:
    static ConfigManager& instance() {
        static ConfigManager inst;
        return inst;
    }

    // Load config from NVS. Call once at startup.
    void begin();

    // Save the full config struct to NVS.
    void save();

    // Reset all values to defaults and erase NVS namespace.
    void reset();

    // --- Accessors (read) ---
    const DeviceConfig& get() const { return _cfg; }

    String getWifiSSID()      const { return _cfg.wifiSSID; }
    String getWifiPassword()  const { return _cfg.wifiPassword; }
    String getServerUrl()     const { return _cfg.serverUrl; }
    HardwareType getHardwareType() const { return _cfg.hardwareType; }
    uint8_t  getRelayPin()    const { return _cfg.relayPin; }
    bool     isRelayNC()      const { return _cfg.relayNormallyClosed; }
    uint32_t getOpenDurationMs() const { return _cfg.openDurationMs; }
    String   getNukiAddress() const { return _cfg.nukiAddress; }
    bool     isNukiPaired()   const { return _cfg.nukiPaired; }
    String   getDeviceName()  const { return _cfg.deviceName; }
    bool     isConfigured()   const { return _cfg.isConfigured; }

    // --- Mutators (write + persist) ---
    void setWifi(const String& ssid, const String& password);
    void setServerUrl(const String& url);
    void setHardwareRelay(uint8_t pin, bool normallyClosed, uint32_t durationMs);
    void setHardwareNuki(const String& address, bool paired);
    void setHardwareType(HardwareType type);
    void setOpenDurationMs(uint32_t ms);
    void setNukiPaired(bool paired);
    void setNukiAddress(const String& address);
    void setDeviceName(const String& name);
    void setConfigured(bool configured);

private:
    ConfigManager() = default;
    ConfigManager(const ConfigManager&) = delete;
    ConfigManager& operator=(const ConfigManager&) = delete;

    void loadDefaults();

    Preferences  _prefs;
    DeviceConfig _cfg;

    static constexpr const char* NVS_NAMESPACE = "doorconfig";
};

// Global shorthand
inline ConfigManager& Config() { return ConfigManager::instance(); }
