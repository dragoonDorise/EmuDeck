import os, re, sys
import xml.etree.ElementTree as ET

DIRECTORY_EMU = "RPCS3 Directory (Standalone)"
ISO_EMU = "RPCS3 ISO (Standalone)"
SHORTCUT_EMU = "RPCS3 Shortcut (Standalone)"

ISO_EXTS = (".iso",)
SHORTCUT_EXTS = (".desktop",)

roms_dir = os.environ.get("PS3_ROMS_DIR", "")
gamelist = os.environ.get("PS3_GAMELIST", "")

if not gamelist:
    sys.stderr.write("PS3_GAMELIST not set\n")
    sys.exit(1)


def load(path):
    raw = ""
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            raw = f.read()
    raw = re.sub(r"<\?xml[^>]*\?>", "", raw).strip()
    if not raw:
        raw = "<gameList></gameList>"
    wrapper = ET.fromstring("<esroot>" + raw + "</esroot>")
    alt = wrapper.find("alternativeEmulator")
    gl = wrapper.find("gameList")
    if gl is None:
        gl = ET.SubElement(wrapper, "gameList")
    if alt is None:
        alt = gl.find("alternativeEmulator")
        if alt is not None:
            gl.remove(alt)
    return alt, gl


def ensure_alt(alt, label):
    if alt is None:
        alt = ET.Element("alternativeEmulator")
    lbl = alt.find("label")
    if lbl is None:
        lbl = ET.SubElement(alt, "label")
    lbl.text = label
    return alt


def find_game(gl, rel_path):
    for g in gl.findall("game"):
        p = g.find("path")
        if p is not None and (p.text or "").strip() == rel_path:
            return g
    return None


def set_game_emu(gl, rel_path, emu):
    g = find_game(gl, rel_path)
    if g is None:
        g = ET.SubElement(gl, "game")
        p = ET.SubElement(g, "path")
        p.text = rel_path
    ae = g.find("altemulator")
    if ae is None:
        ae = ET.SubElement(g, "altemulator")
    ae.text = emu
    return g


alt, gl = load(gamelist)
alt = ensure_alt(alt, DIRECTORY_EMU)

count_iso = 0
count_shortcut = 0
if os.path.isdir(roms_dir):
    for name in sorted(os.listdir(roms_dir)):
        full = os.path.join(roms_dir, name)
        if not os.path.isfile(full):
            continue
        lower = name.lower()
        rel = "./" + name
        if lower.endswith(ISO_EXTS):
            set_game_emu(gl, rel, ISO_EMU)
            count_iso += 1
        elif lower.endswith(SHORTCUT_EXTS):
            set_game_emu(gl, rel, SHORTCUT_EMU)
            count_shortcut += 1

out = '<?xml version="1.0"?>\n' \
      + ET.tostring(alt, encoding="unicode").strip() + "\n" \
      + ET.tostring(gl, encoding="unicode").strip() + "\n"

os.makedirs(os.path.dirname(gamelist), exist_ok=True)
with open(gamelist, "w", encoding="utf-8") as f:
    f.write(out)

sys.stderr.write("ps3 default=%s iso=%d shortcut=%d\n" % (DIRECTORY_EMU, count_iso, count_shortcut))
