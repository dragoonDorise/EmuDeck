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
    g = bytearray(p["guid"])
    g[2] = g[3] = 0
    guid = "".join("%02x" % b for b in g)
    port = seen.get(guid, 0)
    seen[guid] = port + 1
    p["sdl_guid"] = guid
    p["port"] = port
    p["vendor"] = g[4] | (g[5] << 8)
    p["product"] = g[8] | (g[9] << 8)
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
    log("  %-42s guid=%s port=%d slot=%-4s builtin=%-5s kernel=%s"
        % (p["name"], p["sdl_guid"], p["port"], p["slot"], p["builtin"], p["kernel"]))

players = [{"player": i, "guid": p["sdl_guid"], "port": p["port"], "name": p["name"]}
           for i, p in enumerate(ordered)]


def set_players(path):
    if not os.path.isfile(path) or not players:
        return
    with open(path, "r", encoding="utf-8", newline="") as f:
        lines = f.readlines()
    out = []
    for line in lines:
        m = re.match(r"^player_(\d+)_", line)
        player = int(m.group(1)) if m else None
        if player is not None and player < MAX_PLAYERS:
            eol = line[len(line.rstrip("\r\n")):]
            if re.match(r"^player_%d_connected=" % player, line):
                line = "player_%d_connected=%s%s" % (player, "true" if player < len(players) else "false", eol)
            elif re.match(r"^player_%d_connected\\default=" % player, line):
                line = "player_%d_connected\\default=false%s" % (player, eol)
            elif player < len(players) and "engine:sdl" in line:
                line = re.sub(r"port:\d+", "port:%d" % players[player]["port"], line)
                line = re.sub(r"guid:[0-9a-f]+", "guid:%s" % players[player]["guid"], line)
        out.append(line)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.writelines(out)


if "--write" in sys.argv:
    set_players(os.environ.get("EDEN_CONFIG_FILE", ""))

print(json.dumps(players))
