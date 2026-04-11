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

# Detect if a button is held down at launch
y_pressed = False
try:
    if not pygame.get_init():
        pygame.init()
    pygame.joystick.init()
    if pygame.joystick.get_count() > 0:
        js = pygame.joystick.Joystick(0)
        js.init()
        pygame.event.pump()
        if js.get_button(3):  # Button Y
            y_pressed = True
            print(f"Button detected")
except Exception as e:
    print(f"Button detection skipped: {e}")

# Per-emulator configuration menu (shown on Y button press)
if y_pressed:
    print(f"Y pressed - emu: '{emu.lower()}'")
    try:
        emu_menus = {
            "retroarch":    [
                  ("Reset RetroArch configuration", retroarch_init),
                  ("Reset RetroArch configuration", retroarch_init),
            ],
            "dolphin-emu":  [("Reset Dolphin configuration", dolphin_init)],
            "duckstation":  [("Reset DuckStation configuration", duckstation_init)],
            "pcsx2-qt":     [("Reset PCSX2 configuration", pcsx2_init)],
            "ppsspp":       [("Reset PPSSPP configuration", ppsspp_init)],
            "rpcs3":        [("Reset RPCS3 configuration", rpcs3_init)],
            "cemu":         [("Reset Cemu configuration", cemu_init)],
            "ryujinx":      [("Reset Ryujinx configuration", ryujinx_init)],
            "vita3k":       [("Reset Vita3K configuration", vita3k_init)],
            "xemu-emu":     [("Reset Xemu configuration", xemu_init)],
            "mgba":         [("Reset mGBA configuration", mgba_init)],
            "melonds":      [("Reset melonDS configuration", melonds_init)],
            "mame":         [("Reset MAME configuration", mame_init)],
            "flycast":      [("Reset Flycast configuration", flycast_init)],
            "shadps4":      [("Reset ShadPS4 configuration", shadps4_init)],
            "citron":       [("Reset Citron configuration", citron_init)],
            "azahar":       [("Reset Azahar configuration", azahar_init)],
            "scummvm":      [("Reset ScummVM configuration", scummvm_init)],
            "primehack":    [("Reset PrimeHack configuration", primehack_init)],
            "bigpemu":      [("Reset BigPEmu configuration", bigpemu_init)],
            "supermodel":   [("Reset Supermodel configuration", supermodel_init)],
            "xenia":        [("Reset Xenia configuration", xenia_init)],
            "eden":         [("Reset Eden configuration", eden_init)],
        }
        print(f"Menu keys: {list(emu_menus.keys())}")
        menu_options = emu_menus.get(emu.lower(), [])
        print(f"Menu options for '{emu.lower()}': {menu_options}")
        if menu_options:
            popup_show_menu(f"Quick Menu", menu_options)
        else:
            print(f"No menu options found for emu '{emu.lower()}'")
    except Exception as e:
        print(f"Menu error: {e}")
        import traceback
        traceback.print_exc()

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
        exe = f"{emus_folder}/ES-DE.AppImage"
    if emu.lower() == "steamrommanager":
        exe = f"{emus_folder}/srm.AppImage"
    if emu.lower() == "azahar":
        exe = f"{emus_folder}/azahar.AppImage"
    if emu.lower() == "bigpemu":
        exe = f"{emus_folder}/BigPEmu/bigpemu"
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
    # if emu.lower() == "model-2-emulator":
    #     exe = f"{emus_folder}/model-2-emulator.AppImage"
    if emu.lower() == "pcsx2-qt":
        exe = f"{emus_folder}/pcsx2-Qt.AppImage"
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
        exe = f"{emus_folder}/Shadps4-qt.AppImage"
    if emu.lower() == "supermodel":
        exe = "/usr/bin/flatpak run com.supermodel3.Supermodel"
    if emu.lower() == "vita3k":
        exe = f"{emus_folder}/Vita3K/Vita3K"
    if emu.lower() == "xemu-emu":
        exe = "/usr/bin/flatpak run app.xemu.xemu"
    if emu.lower() == "xenia":
        exe = f"{emus_folder}/xenia_canary_linux/build/bin/Linux/Release/xenia_canary"
    if emu.lower() == "yuzu":
        exe = f"{emus_folder}/yuzu.AppImage"
    if emu.lower() == "eden":
          exe = f"{emus_folder}/Eden.AppImage"

if system.startswith("win"):
    if emu.lower() in ("es-de", "emulationstationde"):
        exe = str(esde_folder / "ES-DE.exe")
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
        exe = f"{emus_folder}/Dolphin-x64/Dolphin.exe"
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
        exe = f"{emus_folder}/m2emulator/EMULATOR.EXE"
    if emu.lower() == "pcsx2-qt" or emu.lower() == "pcsx2":
        exe = f"{emus_folder}/pcsx2/pcsx2.exe"
    if emu.lower() == "ppsspp":
        exe = f"{emus_folder}/ppsspp/PPSSPPWindows64.exe"
    if emu.lower() == "primehack":
        exe = f"{emus_folder}/primehack/Dolphin.exe"
    if emu.lower() == "retroarch":
        exe = f"{emus_folder}/retroarch/retroarch.exe"
    if emu.lower() == "rpcs3":
        exe = f"{emus_folder}/rpcs3/rpcs3.exe"
    if emu.lower() == "ryujinx":
        exe = f"{emus_folder}/ryujinx/ryujinx.exe"
    if emu.lower() == "scummvm":
        exe = f"{emus_folder}/scummvm/scummvm.exe"
    if emu.lower() == "shadps4":
        exe = f"{emus_folder}/ShadPS4-qt/shadPS4QtLauncher.exe"
    if emu.lower() == "supermodel":
        exe = f"{emus_folder}/supermodel/supermodel.exe"
    if emu.lower() == "vita3k":
        exe = f"{emus_folder}/vita3k/vita3k.exe"
    if emu.lower() == "xemu-emu" or emu.lower() == "xemu":
        exe = f"{emus_folder}/xemu/xemu.exe"
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

#Launch popups
if emu.lower() == "retroarch":
   show_hotkeys("RetroArch", [                                                                                                               
         ("SELECT + START", "Exit emulation"),
         ("SELECT + L1", "Load save state"),
         ("SELECT + R1", "Save save state"),
         ("SELECT + L2", "Rewind"),
         ("SELECT + R2", "Fast Forward"),
   ])
   
if emu.lower() == "dolphin":
   show_hotkeys("Dolphin", [                                                                                                               
      ("SELECT + START", "Exit emulation"),
      ("SELECT + L1", "Load save state"),
      ("SELECT + R1", "Save save state"),
   ])
   
if emu.lower() == "dolphin" and any("wii" in a.lower() for a in sys.argv[1:]):
   controllers = get_connected_controllers()
   if controllers > 1:
       players = popup_wii_players("Wii Setup")
   else:
       players = 1
   
   if players:
       for p in range(1, players + 1):
           ctrl = popup_wii_controller_type("Wii Setup", player=p)
           print(f"Player {p}: {ctrl}")
           if ctrl is None:
               break
               
   
   

#Dobule "'XXX'" cleanup
if args:
    last = args[-1]
    if len(last) >= 2 and last.startswith("'") and last.endswith("'"):
        args[-1] = last[1:-1]


cmd = [exe] + shlex.split(settings.netplay_cmd) + args


if system.startswith("win"):
    cmd = [str(exe)] + shlex.split(settings.netplay_cmd) + args
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
#    popup_show_info("title",cmd)
    cmd = cmd.replace("'/usr", "/usr")
    cmd = cmd.replace("' ", " ")
    cmd = cmd.replace("'", '"')
    #Last " for solo emulators
    if cmd.count('"') == 1:
       cmd = cmd.replace('"', "")

    shell_status = True

#popup_show_info("title",cmd)


subprocess.run(cmd, check=True, shell=shell_status)

watch_file = Path(saves_path) / ".watching"
if watch_file.exists():
   watch_file.unlink()
