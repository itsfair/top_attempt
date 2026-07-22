import os
import subprocess

Import("env")

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
os.environ["FW_VERSION_FLAGS"] = flags
print(f"[pre_upload] FW_VERSION_FLAGS = {flags}")

def erase_otadata(*args, **kwargs):
    port = env.subst("$UPLOAD_PORT")
    if not port:
        return
    print(f"[pre_upload] Erasing otadata on {port}")
    env.Execute(f"esptool.py --port {port} erase_region 0xd000 0x2000")

env.AddPreAction("upload", erase_otadata)