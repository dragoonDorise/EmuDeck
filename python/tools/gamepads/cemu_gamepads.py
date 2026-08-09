import ctypes, os, re, sys, json

BUILTIN_DEVICES = {
    (0x28DE, 0x1205), (0x28DE, 0x1206),
    (0x0B05, 0x1ABE), (0x0B05, 0x1B4C),
    (0x17EF, 0x6182), (0x17EF, 0x6183),
    (0x17EF, 0x6184), (0x17EF, 0x6185),
}
BUILTIN_NAME_HINTS = ("steam deck", "rog ally", "legion go", "ayaneo", "aya neo", "onexplayer")
STEAM_VIRTUAL = (0x28DE, 0x11FF)
MAX_PLAYERS = 4
EMPTY_UUID = "0_00000000000000000000000000000000"


class GUID(ctypes.Structure):
    _fields_ = [("data", ctypes.c_uint8 * 16)]


def is_builtin(vendor, product, name):
    return (vendor, product) in BUILTIN_DEVICES \
           or any(hint in (name or "").lower() for hint in BUILTIN_NAME_HINTS)


def kernel_info(path):
    m = re.match(r"^/dev/input/(event\d+)$", path or "")
    if not m:
        return None
    base = "/sys/class/input/%s/device" % m.group(1)
    try:
        with open(os.path.join(base, "name")) as f:
            name = f.read().strip()
        with open(os.path.join(base, "id/vendor")) as f:
            vendor = int(f.read().strip(), 16)
        with open(os.path.join(base, "id/product")) as f:
            product = int(f.read().strip(), 16)
    except OSError:
        return None
    return {"name": name, "vendor": vendor, "product": product}


def steam_slot(info):
    if not info or (info["vendor"], info["product"]) != STEAM_VIRTUAL:
        return None
    m = re.search(r"pad\s+(\d+)\s*$", info["name"])
    return int(m.group(1)) if m else None


def has_touchscreen():
    import glob
    for d in glob.glob("/sys/class/input/event*/device"):
        try:
            with open(os.path.join(d, "properties")) as f:
                props = int(f.read().strip(), 16)
        except (OSError, ValueError):
            continue
        if props & 0x02:
            return True
    return False


def enumerate_pads(libpath):
    sdl = ctypes.CDLL(libpath)
    sdl.SDL_GetError.restype = ctypes.c_char_p
    out = []
    if hasattr(sdl, "SDL_GetJoysticks"):
        sdl.SDL_Init.argtypes = [ctypes.c_uint32]
        sdl.SDL_Init.restype = ctypes.c_bool
        sdl.SDL_GetJoysticks.argtypes = [ctypes.POINTER(ctypes.c_int)]
        sdl.SDL_GetJoysticks.restype = ctypes.POINTER(ctypes.c_uint32)
        sdl.SDL_GetJoystickNameForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickNameForID.restype = ctypes.c_char_p
        sdl.SDL_GetJoystickGUIDForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickGUIDForID.restype = GUID
        sdl.SDL_GetJoystickPathForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickPathForID.restype = ctypes.c_char_p
        if not sdl.SDL_Init(0x00002000):
            return None
        count = ctypes.c_int(0)
        ids = sdl.SDL_GetJoysticks(ctypes.byref(count))
        for i in range(count.value):
            jid = ids[i]
            name = sdl.SDL_GetJoystickNameForID(jid)
            path = sdl.SDL_GetJoystickPathForID(jid)
            g = bytes(sdl.SDL_GetJoystickGUIDForID(jid).data)
            out.append({"name": name.decode() if name else "Unknown Controller",
                        "guid": g, "path": path.decode() if path else ""})
    else:
        sdl.SDL_Init.argtypes = [ctypes.c_uint32]
        sdl.SDL_Init.restype = ctypes.c_int
        sdl.SDL_NumJoysticks.restype = ctypes.c_int
        sdl.SDL_JoystickNameForIndex.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickNameForIndex.restype = ctypes.c_char_p
        sdl.SDL_JoystickGetDeviceGUID.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickGetDeviceGUID.restype = GUID
        sdl.SDL_JoystickPathForIndex.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickPathForIndex.restype = ctypes.c_char_p
        if sdl.SDL_Init(0x00002000) != 0:
            return None
        for i in range(sdl.SDL_NumJoysticks()):
            name = sdl.SDL_JoystickNameForIndex(i)
            path = sdl.SDL_JoystickPathForIndex(i)
            g = bytes(sdl.SDL_JoystickGetDeviceGUID(i).data)
            out.append({"name": name.decode() if name else "Unknown Controller",
                        "guid": g, "path": path.decode() if path else ""})
    sdl.SDL_Quit()
    return out


def log(msg):
    sys.stderr.write(msg + "\n")


lib = os.environ.get("SDL_LIB", "")
if not lib or not os.path.exists(lib):
    log("SDL_LIB missing or not found: %s" % lib)
    sys.exit(1)

pads = enumerate_pads(lib)
if pads is None:
    log("SDL_Init failed")
    sys.exit(1)

seen = {}
for p in pads:
    guid = "".join("%02x" % b for b in p["guid"])
    dup = seen.get(guid, 0)
    seen[guid] = dup + 1
    p["uuid"] = "%d_%s" % (dup, guid)
    p["vendor"] = p["guid"][4] | (p["guid"][5] << 8)
    p["product"] = p["guid"][8] | (p["guid"][9] << 8)
    info = kernel_info(p["path"])
    p["slot"] = steam_slot(info)
    p["kernel"] = info["name"] if info else ""
    p["builtin"] = is_builtin(p["vendor"], p["product"], p["name"])

steam_input = any(p["slot"] is not None for p in pads)

if steam_input:
    ordered = sorted([p for p in pads if p["slot"] is not None], key=lambda p: p["slot"])
else:
    ordered = pads
    if len(ordered) > 1:
        ordered = [p for p in ordered if not p["builtin"]] + [p for p in ordered if p["builtin"]]

ordered = ordered[:MAX_PLAYERS]

log("steam_input=%s pads=%d" % (steam_input, len(pads)))
for p in pads:
    log("  %-42s uuid=%s slot=%-4s builtin=%-5s kernel=%s"
        % (p["name"], p["uuid"], p["slot"], p["builtin"], p["kernel"]))

players = [{"player": i, "uuid": p["uuid"], "name": p["name"]} for i, p in enumerate(ordered)]

touchscreen = has_touchscreen()
gamepad_mode = len(players) == 1 and touchscreen
log("touchscreen=%s gamepad_mode=%s" % (touchscreen, gamepad_mode))


def patch_sdl_block(text, uuid, display_name):
    blocks = text.split("<controller>")
    for i in range(1, len(blocks)):
        if "<api>SDLController</api>" in blocks[i]:
            blocks[i] = re.sub(r"<uuid>.*?</uuid>",
                               "<uuid>%s</uuid>" % uuid, blocks[i], count=1)
            blocks[i] = re.sub(r"<display_name>.*?</display_name>",
                               "<display_name>%s</display_name>" % display_name,
                               blocks[i], count=1)
            break
    return "<controller>".join(blocks)


def write_profile(path, template, uuid, display_name):
    if not os.path.isfile(template):
        return
    with open(template, "r", encoding="utf-8") as f:
        text = f.read()
    with open(path, "w", encoding="utf-8") as f:
        f.write(patch_sdl_block(text, uuid, display_name))


def clear_profile(path, template_pro):
    if not os.path.isfile(template_pro):
        return
    with open(template_pro, "r", encoding="utf-8") as f:
        text = f.read()
    with open(path, "w", encoding="utf-8") as f:
        f.write(patch_sdl_block(text, EMPTY_UUID, "Disconnected"))


if "--write" in sys.argv:
    cfg = os.environ.get("CEMU_CONTROLLER_DIR", "")
    tpl = os.environ.get("CEMU_TEMPLATE_DIR", "")
    tpl_gamepad = os.path.join(tpl, "gamepad.xml")
    tpl_pro = os.path.join(tpl, "pro.xml")
    for i in range(MAX_PLAYERS):
        path = os.path.join(cfg, "controller%d.xml" % i)
        if i < len(players):
            template = tpl_gamepad if (i == 0 and gamepad_mode) else tpl_pro
            write_profile(path, template, players[i]["uuid"], players[i]["name"])
        else:
            clear_profile(path, tpl_pro)

print(json.dumps(players))
