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


def enumerate_pads(libpath):
    sdl = ctypes.CDLL(libpath)
    sdl.SDL_GetError.restype = ctypes.c_char_p
    out = []
    if hasattr(sdl, "SDL_NumJoysticks"):
        sdl.SDL_Init.argtypes = [ctypes.c_uint32]
        sdl.SDL_Init.restype = ctypes.c_int
        sdl.SDL_NumJoysticks.restype = ctypes.c_int
        sdl.SDL_JoystickNameForIndex.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickNameForIndex.restype = ctypes.c_char_p
        sdl.SDL_JoystickPathForIndex.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickPathForIndex.restype = ctypes.c_char_p
        sdl.SDL_JoystickGetDeviceVendor.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickGetDeviceVendor.restype = ctypes.c_uint16
        sdl.SDL_JoystickGetDeviceProduct.argtypes = [ctypes.c_int]
        sdl.SDL_JoystickGetDeviceProduct.restype = ctypes.c_uint16
        if sdl.SDL_Init(0x00002000) != 0:
            return None
        ids = range(sdl.SDL_NumJoysticks())
        get = (sdl.SDL_JoystickNameForIndex, sdl.SDL_JoystickPathForIndex,
               sdl.SDL_JoystickGetDeviceVendor, sdl.SDL_JoystickGetDeviceProduct)
    else:
        sdl.SDL_Init.argtypes = [ctypes.c_uint32]
        sdl.SDL_Init.restype = ctypes.c_bool
        sdl.SDL_GetJoysticks.argtypes = [ctypes.POINTER(ctypes.c_int)]
        sdl.SDL_GetJoysticks.restype = ctypes.POINTER(ctypes.c_uint32)
        sdl.SDL_GetJoystickNameForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickNameForID.restype = ctypes.c_char_p
        sdl.SDL_GetJoystickPathForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickPathForID.restype = ctypes.c_char_p
        sdl.SDL_GetJoystickVendorForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickVendorForID.restype = ctypes.c_uint16
        sdl.SDL_GetJoystickProductForID.argtypes = [ctypes.c_uint32]
        sdl.SDL_GetJoystickProductForID.restype = ctypes.c_uint16
        if not sdl.SDL_Init(0x00002000):
            return None
        count = ctypes.c_int(0)
        raw = sdl.SDL_GetJoysticks(ctypes.byref(count))
        ids = [raw[i] for i in range(count.value)]
        get = (sdl.SDL_GetJoystickNameForID, sdl.SDL_GetJoystickPathForID,
               sdl.SDL_GetJoystickVendorForID, sdl.SDL_GetJoystickProductForID)

    get_name, get_path, get_vendor, get_product = get
    for jid in ids:
        name = get_name(jid)
        path = get_path(jid)
        out.append({
            "name": name.decode() if name else "Unknown Controller",
            "path": path.decode() if path else "",
            "vendor": get_vendor(jid),
            "product": get_product(jid),
        })
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

if "--count" in sys.argv:
    print(len(pads))
    sys.exit(0)

seen = {}
for p in pads:
    idx = seen.get(p["name"], 0)
    seen[p["name"]] = idx + 1
    p["device"] = "SDL/%d/%s" % (idx, p["name"])
    info = kernel_info(p["path"])
    p["slot"] = steam_slot(info)
    p["builtin"] = is_builtin(p["vendor"], p["product"], p["name"])
    p["kernel"] = info["name"] if info else ""

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
    log("  %-46s vid=%04x pid=%04x slot=%-4s builtin=%-5s path=%-20s kernel=%s"
        % (p["device"], p["vendor"], p["product"], p["slot"], p["builtin"], p["path"], p["kernel"]))

players = [{"player": i + 1, "device": p["device"]} for i, p in enumerate(ordered)]


def set_devices(path, prefix):
    if not os.path.isfile(path):
        return
    pmap = {p["player"]: p["device"] for p in players}
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    cur = None
    done = set()
    out = []
    for line in lines:
        m = re.match(r"^\[%s(\d+)\]\s*$" % prefix, line)
        if m:
            cur = int(m.group(1))
        if cur in pmap and cur not in done and re.match(r"^\s*Device\s*=", line):
            line = "Device = %s\n" % pmap[cur]
            done.add(cur)
        out.append(line)
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(out)


def set_si_devices(path):
    if not os.path.isfile(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    out = []
    for line in lines:
        m = re.match(r"^SIDevice(\d)\s*=", line)
        if m:
            port = int(m.group(1))
            line = "SIDevice%d = %s\n" % (port, "6" if port < len(players) else "0")
        out.append(line)
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(out)


def set_wiimote_sources(path):
    if not os.path.isfile(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    cur = None
    out = []
    for line in lines:
        m = re.match(r"^\[(\w+)\]\s*$", line)
        if m:
            w = re.match(r"^Wiimote(\d+)$", m.group(1))
            cur = int(w.group(1)) if w else None
        if cur is not None and re.match(r"^\s*Source\s*=", line):
            line = "Source = %s\n" % ("1" if cur <= len(players) else "0")
        out.append(line)
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(out)


def set_hotkeys_device(path):
    if not os.path.isfile(path) or not players:
        return
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    cur = None
    done = False
    out = []
    for line in lines:
        m = re.match(r"^\[(\w+)\]\s*$", line)
        if m:
            cur = m.group(1)
        if cur == "Hotkeys" and not done and re.match(r"^\s*Device\s*=", line):
            line = "Device = %s\n" % players[0]["device"]
            done = True
        out.append(line)
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(out)


if "--write" in sys.argv:
    cfg = os.environ.get("DOLPHIN_CONFIG_DIR", "")
    set_devices(os.path.join(cfg, "GCPadNew.ini"), "GCPad")
    set_devices(os.path.join(cfg, "WiimoteNew.ini"), "Wiimote")
    set_si_devices(os.path.join(cfg, "Dolphin.ini"))
    set_wiimote_sources(os.path.join(cfg, "WiimoteNew.ini"))
    set_hotkeys_device(os.path.join(cfg, "Hotkeys.ini"))

print(json.dumps(players))
