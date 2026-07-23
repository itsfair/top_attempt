import os
import subprocess
from SCons.Script import Import

Import("env")

# ==========================================
# 1. Git-Version auslesen (Dein bestehender Code)
# ==========================================
try:
    tag = subprocess.check_output(
        ["git", "describe", "--tags", "--match", "fw-v*", "--abbrev=0"],
        stderr=subprocess.DEVNULL
    ).decode().strip()
    version = tag[3:] if tag.startswith("fw-") else tag
    if version.startswith("v"):
        version = version[1:]
except Exception:
    version = "0.0.0-dev"

flags = f'-DFW_VERSION=\\"{version}\\"'
env.Append(CCFLAGS=[flags])
print(f"[pre_upload] FW_VERSION = {version}")


# ==========================================
# 2. otadata-Partition bei USB-Flash löschen
# ==========================================
def erase_otadata(source, target, env):
    # Prüfen, ob es sich um einen OTA-Upload handelt (z.B. per IP-Adresse)
    upload_port = env.get("UPLOAD_PORT", "")
    
    # Falls der Port eine IP oder das Protokoll ota ist, nicht löschen
    if upload_port.startswith("192.") or env.get("UPLOAD_PROTOCOL") == "espota":
        print("[pre_upload] OTA-Upload erkannt. otadata wird NICHT gelöscht.")
        return

    # Parameter für den USB-Flash ermitteln
    etool = env.subst("$UPLOADER")
    port = env.subst("$UPLOAD_PORT")
    speed = env.subst("$UPLOAD_SPEED")
    
    # Befehl für esptool zusammenbauen (Offset und Größe aus deiner partitions.csv)
    erase_cmd = f'"{etool}" --port {port} --baud {speed} erase_region 0xd000 0x2000'
    
    print("\n[pre_upload] USB-Flash erkannt. Lösche otadata Partition (0xd000)...")
    try:
        env.Execute(erase_cmd)
        print("[pre_upload] otadata erfolgreich gelöscht.\n")
    except Exception as e:
        print(f"[pre_upload] FEHLER beim Löschen von otadata: {e}\n")

# Registriert die Funktion, damit sie direkt vor dem Upload-Vorgang startet
env.AddPreAction("upload", erase_otadata)