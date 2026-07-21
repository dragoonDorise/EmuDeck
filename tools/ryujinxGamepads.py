import ctypes, os, sys, json

sdl = ctypes.CDLL(os.environ["SDL_LIB"])

class GUID(ctypes.Structure):
    _fields_ = [("data", ctypes.c_uint8 * 16)]

sdl.SDL_Init.argtypes = [ctypes.c_uint32]
sdl.SDL_Init.restype = ctypes.c_bool
sdl.SDL_GetGamepads.argtypes = [ctypes.POINTER(ctypes.c_int)]
sdl.SDL_GetGamepads.restype = ctypes.POINTER(ctypes.c_uint32)
sdl.SDL_GetJoystickNameForID.argtypes = [ctypes.c_uint32]
sdl.SDL_GetJoystickNameForID.restype = ctypes.c_char_p
sdl.SDL_GetJoystickGUIDForID.argtypes = [ctypes.c_uint32]
sdl.SDL_GetJoystickGUIDForID.restype = GUID
sdl.SDL_GetError.restype = ctypes.c_char_p

BUILTIN_DEVICES = {
    (0x28DE, 0x1205), (0x28DE, 0x1206),
    (0x0B05, 0x1ABE), (0x0B05, 0x1B4C),
    (0x17EF, 0x6182), (0x17EF, 0x6183),
    (0x17EF, 0x6184), (0x17EF, 0x6185),
}
BUILTIN_NAME_HINTS = ("steam deck", "rog ally", "legion go", "ayaneo", "aya neo", "onexplayer")

def is_builtin(vendor, product, name):
    return (vendor, product) in BUILTIN_DEVICES \
           or any(hint in (name or "").lower() for hint in BUILTIN_NAME_HINTS)

SDL_INIT_GAMEPAD = 0x00002000
if not sdl.SDL_Init(SDL_INIT_GAMEPAD):
    sys.stderr.write("SDL_Init failed: %s\n" % sdl.SDL_GetError().decode())
    sys.exit(1)

count = ctypes.c_int(0)
ids = sdl.SDL_GetGamepads(ctypes.byref(count))
if "--count" in sys.argv:
    sdl.SDL_Quit()
    print(count.value)
    sys.exit(0)
if count.value < 1:
    sdl.SDL_Quit()
    sys.exit(1)

pads = []
seen = {}
for i in range(count.value):
    jid = ids[i]
    b = bytes(sdl.SDL_GetJoystickGUIDForID(jid).data)
    name = sdl.SDL_GetJoystickNameForID(jid)
    name = name.decode() if name else "Unknown Controller"
    h = lambda i: "%02x" % b[i]
    guid = "0000" + h(1) + h(0) + "-" + h(5) + h(4) + "-" + h(6) + h(7) + "-" + \
           h(8) + h(9) + "-" + "".join("%02x" % x for x in b[10:16])
    vendor  = b[4] | (b[5] << 8)
    product = b[8] | (b[9] << 8)
    builtin = is_builtin(vendor, product, name)
    dup = seen.get(guid, 0)
    seen[guid] = dup + 1
    pads.append({"id": "%d-%s" % (dup, guid), "name": "%s (%d)" % (name, dup),
                 "is_builtin": builtin})

sdl.SDL_Quit()

if len(pads) > 1:
    pads = [p for p in pads if not p["is_builtin"]] + [p for p in pads if p["is_builtin"]]
pads = pads[:4]

players = ["Player1", "Player2", "Player3", "Player4"]
print(json.dumps([{"player": players[i], "id": p["id"], "name": p["name"]}
                  for i, p in enumerate(pads)]))
