Import("env")

def erase_otadata(source, target, env):
    port = env.subst("$UPLOAD_PORT")
    if not port:
        return
    print(f"[post_upload] Erasing otadata after upload on {port}")
    env.Execute(f'esptool.py --port "{port}" --baud 460800 erase_region 0xd000 0x2000')

env.AddPostAction("$BUILD_DIR/${PROGNAME}.bin", erase_otadata)