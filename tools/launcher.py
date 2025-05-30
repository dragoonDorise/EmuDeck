import sys
from pathlib import Path
project_root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(project_root))
from functions.env import generate_python_env
generate_python_env()
from core.all import *

if system in ("darwin", "linux"):
    emu = Path(sys.argv[1]).stem  # strip off the .sh
else:
    emu = sys.argv[1]

args = sys.argv[2:]
raw = sys.argv[2:]

if system == "darwin":
    if emu.lower() == "es-de":
        exe = f"{emus_folder}/ES-DE.app"
    if emu.lower() == "steamrommanager":
        exe = f"{emus_folder}/Steam Rom Manager.app"
    if emu.lower() == "azahar":
        exe = f"{emus_folder}/Azahar.app"
    if emu.lower() == "bigpemu":
        exe = f"{emus_folder}/bigpemu.app"
    if emu.lower() == "cemu":
        exe = f"{emus_folder}/Cemu.app"
    if emu.lower() == "citron":
        exe = f"{emus_folder}/citron.app"
    if emu.lower() == "dolphin-emu":
        exe = f"{emus_folder}/Dolphin.app"
    if emu.lower() == "duckstation":
        exe = f"{emus_folder}/DuckStation.app"
    if emu.lower() == "flycast":
        exe = f"{emus_folder}/Flycast.app"
    if emu.lower() == "mame":
        exe = f"{emus_folder}/mame.app"
    if emu.lower() == "melonds":
        exe = f"{emus_folder}/melonds.app"
    if emu.lower() == "mgba":
        exe = f"{emus_folder}/mGBA.app"
    if emu.lower() == "model-2-emulator":
        exe = f"{emus_folder}/model-2-emulator.app"
    if emu.lower() == "pcsx2-qt":
        exe = f"{emus_folder}/PCSX2.app"
    if emu.lower() == "ppsspp":
        exe = f"{emus_folder}/PPSSPP.app"
    if emu.lower() == "primehack":
        exe = f"{emus_folder}/primehack.app"
    if emu.lower() == "retroarch":
        exe = f"{emus_folder}/RetroArch.app"
    if emu.lower() == "rosaliesmupengui":
        exe = f"{emus_folder}/rosaliesmupengui.app"
    if emu.lower() == "rpcs3":
        exe = f"{emus_folder}/rpcs3.app"
    if emu.lower() == "ryujinx":
        exe = f"{emus_folder}/ryujinx.app"
    if emu.lower() == "scummvm":
        exe = f"{emus_folder}/scummvm.app"
    if emu.lower() == "shadps4":
        exe = f"{emus_folder}/shadps4.app"
    if emu.lower() == "supermodel":
        exe = f"{emus_folder}/supermodel.app"
    if emu.lower() == "vita3k":
        exe = f"{emus_folder}/vita3k.app"
    if emu.lower() == "xemu-emu":
        exe = f"{emus_folder}/xemu-emu.app"
    if emu.lower() == "xenia":
        exe = f"{emus_folder}/xenia.app"
    if emu.lower() == "yuzu":
        exe = f"{emus_folder}/yuzu.app"
    #Legacy names



if system == "linux":
    if emu.lower() == "es-de":
        exe = f"{emus_folder}/ES-DE.appImage"
    if emu.lower() == "steamrommanager":
        exe = f"{emus_folder}/srm.appImage"
    if emu.lower() == "azahar":
        exe = f"{emus_folder}/Azahar.appImage"
    if emu.lower() == "bigpemu":
        exe = f"{emus_folder}/bigpemu/bigpemu"
    if emu.lower() == "cemu":
        exe = f"{emus_folder}/Cemu.AppImage"
    if emu.lower() == "citron":
        exe = f"{emus_folder}/citron.AppImage"
    if emu.lower() == "dolphin-emu":
        exe = "/usr/bin/flatpak run org.DolphinEmu.dolphin-emu"
    if emu.lower() == "duckstation":
        exe = "/usr/bin/flatpak run org.duckstation.DuckStation"
    if emu.lower() == "flycast":
        exe = "/usr/bin/flatpak run org.flycast.Flycast"
    if emu.lower() == "mame":
        exe = "/usr/bin/flatpak run org.mamedev.MAME"
    if emu.lower() == "melonds":
        exe = "/usr/bin/flatpak run net.kuribo64.melonDS"
    if emu.lower() == "mgba":
        exe = f"{emus_folder}/mGBA.AppImage"
    if emu.lower() == "model-2-emulator":
        exe = f"{emus_folder}/model-2-emulator.AppImage"
    if emu.lower() == "pcsx2-qt":
        exe = f"{emus_folder}/pcsx2-qt.AppImage"
    if emu.lower() == "ppsspp":
        exe = "/usr/bin/flatpak run org.ppsspp.PPSSPP"
    if emu.lower() == "primehack":
        exe = "/usr/bin/flatpak run io.github.shiiion.primehack"
    if emu.lower() == "retroarch":
        exe = "/usr/bin/flatpak run org.libretro.RetroArch"
    if emu.lower() == "rosaliesmupengui":
        exe = "/usr/bin/flatpak run com.github.Rosalie241.RMG"
    if emu.lower() == "rpcs3":
        exe = f"{emus_folder}/rpcs3.AppImage"
    if emu.lower() == "ryujinx":
        exe = f"{emus_folder}/ryujinx.AppImage"
    if emu.lower() == "scummvm":
        exe = "/usr/bin/flatpak run org.scummvm.ScummVM"
    if emu.lower() == "shadps4":
        exe = f"{emus_folder}/shadps4.AppImage"
    if emu.lower() == "supermodel":
        exe = "/usr/bin/flatpak run com.supermodel3.Supermodel"
    if emu.lower() == "vita3k":
        exe = f"{emus_folder}/vita3k.AppImage"
    if emu.lower() == "xemu-emu":
        exe = "/usr/bin/flatpak run app.xemu.xemu"
    if emu.lower() == "xenia":
        exe = f"{emus_folder}/xenia.AppImage"
    if emu.lower() == "yuzu":
        exe = f"{emus_folder}/yuzu.AppImage"
    if emu.lower() == "eden":
          exe = f"{emus_folder}/eden.AppImage"

if system.startswith("win"):
    if emu.lower() == "es-de" or emu.lower() == "emulationstationde":
        exe = f"{emus_folder}/es-de.exe"
    if emu.lower() == "steamrommanager":
        exe = f"{emus_folder}/srm.exe"
    if emu.lower() == "azahar":
        exe = f"{emus_folder}/azahar/azahar.exe"
    if emu.lower() == "bigpemu":
        exe = f"{emus_folder}/bigpemu/bigpemu.exe"
    if emu.lower() == "Cemu":
        exe = f"{emus_folder}/cemu/cemu.exe"
    if emu.lower() == "citron":
        exe = f"{emus_folder}/citron/citron.exe"
    if emu.lower() == "dolphin-emu" or emu.lower() == "dolphin":
        exe = f"{emus_folder}/dolphin-x64/dolphin.exe"
    if emu.lower() == "duckstation":
        exe = f"{emus_folder}/duckstation/duckstation-qt-x64-ReleaseLTCG.exe"
    if emu.lower() == "flycast":
        exe = f"{emus_folder}/flycast/flycast.exe"
    if emu.lower() == "mame":
        exe = f"{emus_folder}/mame/mame.exe"
    if emu.lower() == "melonds":
        exe = f"{emus_folder}/melonds/melonds.exe"
    if emu.lower() == "mgba":
        exe = f"{emus_folder}/mgba/mgba.exe"
    if emu.lower() == "model-2-emulator":
        exe = f"{emus_folder}/model2/model2.exe"
    if emu.lower() == "pcsx2-qt" or emu.lower() == "pcsx2":
        exe = f"{emus_folder}/pcsx2/pcsx2.exe"
    if emu.lower() == "ppsspp":
        exe = f"{emus_folder}/ppsspp/PPSSPPWindows64.exe"
    if emu.lower() == "primehack":
        exe = f"{emus_folder}/primehack/primehack.exe"
    if emu.lower() == "retroarch":
        exe = f"{emus_folder}/retroarch/retroarch.exe"
    if emu.lower() == "rpcs3":
        exe = f"{emus_folder}/rpcs3/rpcs3.exe"
    if emu.lower() == "ryujinx":
        exe = f"{emus_folder}/ryujinx/ryujinx.exe"
    if emu.lower() == "scummvm":
        exe = f"{emus_folder}/scummvm/scummvm.exe"
    if emu.lower() == "shadps4":
        exe = f"{emus_folder}/shadps4/shadps4.exe"
    if emu.lower() == "supermodel":
        exe = f"{emus_folder}/supermodel/supermodel.exe"
    if emu.lower() == "vita3k":
        exe = f"{emus_folder}/vita3k/vita3k.exe"
    if emu.lower() == "xemu-emu" or emu.lower() == "xemu":
        exe = f"{emus_folder}/xemu/xemu-emu.exe"
    if emu.lower() == "xenia":
        exe = f"{emus_folder}/xenia/xenia_canary.exe"
    if emu.lower() == "yuzu":
        exe = f"{emus_folder}/yuzu/yuzu.exe"
    if emu.lower() == "eden":
        exe = f"{emus_folder}/eden/eden.exe"

#netplay
if emu.lower() == "retroarch":
   if settings.netplay == True:
      set_setting("netplay_cmd","-H")
      netplay_set_ip()
   else:
      set_setting("netplay_cmd",'')


exe = str(exe)
cmd = [exe] + shlex.split(settings.netplay_cmd) + args

if system.startswith("win"):
    cmd = [str(exe)] + settings.netplay_cmd + args
    cmd = [part.replace("/", "\\") for part in cmd]
if system == "darwin":
    darwin_trust_app(exe)
    cmd = ["open", "-W", "-a", exe, settings.netplay_cmd] + args

if cloud_sync_provider and settings.netplay == False:
    REMOTE_URL = f"https://token.emudeck.com/cloud-check.php?access_token={settings.patreonToken}"
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

if system.startswith("win") and raw and raw[0] == "-L" and len(raw) > 2:
    args = [ raw[0], raw[1], " ".join(raw[2:]) ]
    cmd = [str(exe)] + netplay_cmd + args
    shell_status = True
else:
    cmd = shlex.join(cmd)
    cmd = cmd.replace("'/usr", "/usr")
    cmd = cmd.replace("Arch'", "Arch")
    cmd = cmd.replace("'", '"')
    shell_status = True




subprocess.run(cmd, check=True, shell=shell_status)

watch_file = Path(saves_path) / ".watching"
if watch_file.exists():
   watch_file.unlink()
