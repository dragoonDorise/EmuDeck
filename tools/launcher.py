import sys
from pathlib import Path
project_root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(project_root))
from functions.env import generate_python_env
generate_python_env()
from core.all import *


emu = sys.argv[1]
args = sys.argv[2:]

if system == "darwin":
    if emu == "es-de":
        exe = f"{emus_folder}/ES-DE.app"
    if emu == "steamrommanager":
        exe = f"{emus_folder}/Steam Rom Manager.app"
    if emu == "azahar":
        exe = f"{emus_folder}/Azahar.app"
    if emu == "bigpemu":
        exe = f"{emus_folder}/bigpemu.app"
    if emu == "cemu":
        exe = f"{emus_folder}/Cemu.app"
    if emu == "citron":
        exe = f"{emus_folder}/citron.app"
    if emu == "dolphin-emu":
        exe = f"{emus_folder}/dolphin-emu.app"
    if emu == "duckstation":
        exe = f"{emus_folder}/DuckStation.app"
    if emu == "flycast":
        exe = f"{emus_folder}/Flycast.app"
    if emu == "mame":
        exe = f"{emus_folder}/mame.app"
    if emu == "melonds":
        exe = f"{emus_folder}/melonds.app"
    if emu == "mgba":
        exe = f"{emus_folder}/mGBA.app"
    if emu == "model-2-emulator":
        exe = f"{emus_folder}/model-2-emulator.app"
    if emu == "pcsx2-qt":
        exe = f"{emus_folder}/PCSX2.app"
    if emu == "ppsspp":
        exe = f"{emus_folder}/PPSSPP.app"
    if emu == "primehack":
        exe = f"{emus_folder}/primehack.app"
    if emu == "retroarch":
        exe = f"{emus_folder}/RetroArch.app"
    if emu == "rosaliesmupengui":
        exe = f"{emus_folder}/rosaliesmupengui.app"
    if emu == "rpcs3":
        exe = f"{emus_folder}/rpcs3.app"
    if emu == "ryujinx":
        exe = f"{emus_folder}/ryujinx.app"
    if emu == "scummvm":
        exe = f"{emus_folder}/scummvm.app"
    if emu == "shadps4":
        exe = f"{emus_folder}/shadps4.app"
    if emu == "supermodel":
        exe = f"{emus_folder}/supermodel.app"
    if emu == "vita3k":
        exe = f"{emus_folder}/vita3k.app"
    if emu == "xemu-emu":
        exe = f"{emus_folder}/xemu-emu.app"
    if emu == "xenia":
        exe = f"{emus_folder}/xenia.app"
    if emu == "yuzu":
        exe = f"{emus_folder}/yuzu.app"

if system == "linux":
    if emu == "es-de":
        exe = f"{emus_folder}/ES-DE.appImage"
    if emu == "steamrommanager":
        exe = f"{emus_folder}/srm.appImage"
    if emu == "azahar":
        exe = f"{emus_folder}/Azahar.appImage"
    if emu == "bigpemu":
        exe = f"{emus_folder}/bigpemu/bigpemu"
    if emu == "cemu":
        exe = f"{emus_folder}/Cemu.AppImage"
    if emu == "citron":
        exe = f"{emus_folder}/citron.AppImage"
    if emu == "dolphin-emu":
        exe = "/usr/bin/flatpak run org.DolphinEmu.dolphin-emu"
    if emu == "duckstation":
        exe = "/usr/bin/flatpak run org.duckstation.DuckStation"
    if emu == "flycast":
        exe = "/usr/bin/flatpak run org.flycast.Flycast"
    if emu == "mame":
        exe = "/usr/bin/flatpak run org.mamedev.MAME"
    if emu == "melonds":
        exe = "/usr/bin/flatpak run net.kuribo64.melonDS"
    if emu == "mgba":
        exe = f"{emus_folder}/mGBA.AppImage"
    if emu == "model-2-emulator":
        exe = f"{emus_folder}/model-2-emulator.AppImage"
    if emu == "pcsx2-qt":
        exe = f"{emus_folder}/pcsx2-qt.AppImage"
    if emu == "ppsspp":
        exe = "/usr/bin/flatpak run org.ppsspp.PPSSPP"
    if emu == "primehack":
        exe = "/usr/bin/flatpak run io.github.shiiion.primehack"
    if emu == "retroarch":
        exe = "/usr/bin/flatpak run org.libretro.RetroArch"
    if emu == "rosaliesmupengui":
        exe = "/usr/bin/flatpak run com.github.Rosalie241.RMG"
    if emu == "rpcs3":
        exe = f"{emus_folder}/rpcs3.AppImage"
    if emu == "ryujinx":
        exe = f"{emus_folder}/ryujinx.AppImage"
    if emu == "scummvm":
        exe = "/usr/bin/flatpak run org.scummvm.ScummVM"
    if emu == "shadps4":
        exe = f"{emus_folder}/shadps4.AppImage"
    if emu == "supermodel":
        exe = "/usr/bin/flatpak run com.supermodel3.Supermodel"
    if emu == "vita3k":
        exe = f"{emus_folder}/vita3k.AppImage"
    if emu == "xemu-emu":
        exe = "/usr/bin/flatpak run app.xemu.xemu"
    if emu == "xenia":
        exe = f"{emus_folder}/xenia.AppImage"
    if emu == "yuzu":
        exe = f"{emus_folder}/yuzu.AppImage"

if system.startswith("win"):
    if emu == "es-de":
        exe = f"{emus_folder}/Azahar.exe"
    if emu == "steamrommanager":
        exe = f"{emus_folder}/Azahar.exe"
    if emu == "azahar":
        exe = f"{emus_folder}/azahar/azahar.exe"
    if emu == "bigpemu":
        exe = f"{emus_folder}/bigpemu/bigpemu.exe"
    if emu == "Cemu":
        exe = f"{emus_folder}/cemu/cemu.exe"
    if emu == "citron":
        exe = f"{emus_folder}/citron/citron.exe"
    if emu == "dolphin-emu":
        exe = f"{emus_folder}/dolphin-x64/dolphin.exe"
    if emu == "duckstation":
        exe = f"{emus_folder}/duckstation/duckstation-qt-x64-ReleaseLTCG.exe"
    if emu == "flycast":
        exe = f"{emus_folder}/flycast/flycast.exe"
    if emu == "mame":
        exe = f"{emus_folder}/mame/mame.exe"
    if emu == "melonDS":
        exe = f"{emus_folder}/melonds/melonds.exe"
    if emu == "mgba":
        exe = f"{emus_folder}/mgba/mgba.exe"
    if emu == "model-2-emulator":
        exe = f"{emus_folder}/model2/model2.exe"
    if emu == "pcsx2-qt":
        exe = f"{emus_folder}/pcsx2/pcsx2.exe"
    if emu == "PPSSPP":
        exe = f"{emus_folder}/ppsspp/PPSSPPWindows64.exe"
    if emu == "primehack":
        exe = f"{emus_folder}/primehack/primehack.exe"
    if emu == "retroarch":
        exe = f"{emus_folder}/retroarch/retroarch.exe"
    if emu == "rosaliesmupengui":
        exe = f"{emus_folder}/rosaliesmupengui/rosaliesmupengui.exe"
    if emu == "rpcs3":
        exe = f"{emus_folder}/rpcs3/rpcs3.exe"
    if emu == "Ryujinx":
        exe = f"{emus_folder}/ryujinx/ryujinx.exe"
    if emu == "ScummVM":
        exe = f"{emus_folder}/scummvm/scummvm.exe"
    if emu == "shadps4":
        exe = f"{emus_folder}/shadps4/shadps4.exe"
    if emu == "supermodel":
        exe = f"{emus_folder}/supermodel/supermodel.exe"
    if emu == "Vita3K":
        exe = f"{emus_folder}/vita3k/vita3k.exe"
    if emu == "xemu-emu":
        exe = f"{emus_folder}/xemu/xemu-emu.exe"
    if emu == "xenia":
        exe = f"{emus_folder}/xenia/xenia_canary.exe"
    if emu == "yuzu":
        exe = f"{emus_folder}/yuzu/yuzu.exe"

exe = str(exe)
cmd = [exe] + args
if system.startswith("win"):
    cmd = [str(exe)] + args
if system == "darwin":
    darwin_trust_app(exe)
    cmd = ["open", "-W", "-a", exe] + args

REMOTE_URL = f"https://token.emudeck.com/cloud-check.php?access_token={settings.patreonToken}"

def load_remote_module(url: str, module_name: str):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    source = resp.text

    spec = importlib.util.spec_from_loader(module_name, loader=None)
    module = importlib.util.module_from_spec(spec)
    exec(source, module.__dict__)
    sys.modules[module_name] = module
    return module

try:
    cloudsync_remote = load_remote_module(REMOTE_URL, "cloudsync_remote")
except Exception as e:
    cloudsync_remote = None

if cloudsync_remote:
    try:
        cloudsync_remote.cloud_sync_download_emu(emu)
    except Exception as e:
        print(f"Error en cloud_sync_download_emu: {e}", exc_info=True)

    t = threading.Thread(
        target=cloudsync_remote.monitor_and_upload,
        kwargs={"poll_interval": 1.0},
        daemon=True
    )
    t.start()

subprocess.run(cmd, check=True)

watch_file = Path(saves_path) / ".watching"
if watch_file.exists():
   watch_file.unlink()