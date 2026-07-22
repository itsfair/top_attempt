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
env.Append(CCFLAGS=[flags])
print(f"[pre_upload] FW_VERSION = {version}")

def fix_otadata(*args, **kwargs):
    port = env.subst("$UPLOAD_PORT")
    if not port:
        return
    print(f"[post_upload] Erasing otadata to force slot 0 on {port}")
    env.Execute(f'esptool.py --port "{port}" --baud 460800 erase_region 0xd000 0x2000')

env.AddPostAction("upload", fix_otadata)