import sys
import os
import shutil

# Add backend root to path so core/ and functions/ resolve
backend_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, backend_root)

from core.vars import emudeck_backend

from functions.env import generate_python_env
generate_python_env()

from core.all import *

# EmuDeck folders
shutil.rmtree(tools_path, ignore_errors=True)

# Emulators
emulators = {
    "Azahar": {"uninstall": azahar_uninstall, "is_installed": azahar_is_installed},
    "BigPEmu": {"uninstall": bigpemu_uninstall, "is_installed": bigpemu_is_installed},
    "Cemu": {"uninstall": cemu_uninstall, "is_installed": cemu_is_installed},
    "Citron": {"uninstall": citron_uninstall, "is_installed": citron_is_installed},
    "Dolphin": {"uninstall": dolphin_uninstall, "is_installed": dolphin_is_installed},
    "DuckStation": {"uninstall": duckstation_uninstall, "is_installed": duckstation_is_installed},
    "Eden": {"uninstall": eden_uninstall, "is_installed": eden_is_installed},
    "Flycast": {"uninstall": flycast_uninstall, "is_installed": flycast_is_installed},
    "MAME": {"uninstall": mame_uninstall, "is_installed": mame_is_installed},
    "melonDS": {"uninstall": melonds_uninstall, "is_installed": melonds_is_installed},
    "mGBA": {"uninstall": mgba_uninstall, "is_installed": mgba_is_installed},
    "Model2": {"uninstall": model2_uninstall, "is_installed": model2_is_installed},
    "PCSX2": {"uninstall": pcsx2_uninstall, "is_installed": pcsx2_is_installed},
    "PPSSPP": {"uninstall": ppsspp_uninstall, "is_installed": ppsspp_is_installed},
    "PrimeHack": {"uninstall": primehack_uninstall, "is_installed": primehack_is_installed},
    "RetroArch": {"uninstall": retroarch_uninstall, "is_installed": retroarch_is_installed},
    "RMG": {"uninstall": rmg_uninstall, "is_installed": rmg_is_installed},
    "RPCS3": {"uninstall": rpcs3_uninstall, "is_installed": rpcs3_is_installed},
    "Ryujinx": {"uninstall": ryujinx_uninstall, "is_installed": ryujinx_is_installed},
    "ScummVM": {"uninstall": scummvm_uninstall, "is_installed": scummvm_is_installed},
    "shadPS4": {"uninstall": shadps4_uninstall, "is_installed": shadps4_is_installed},
    "SuperModel": {"uninstall": supermodel_uninstall, "is_installed": supermodel_is_installed},
    "Vita3K": {"uninstall": vita3k_uninstall, "is_installed": vita3k_is_installed},
    "Xemu": {"uninstall": xemu_uninstall, "is_installed": xemu_is_installed},
    "Xenia": {"uninstall": xenia_uninstall, "is_installed": xenia_is_installed},
    "Yuzu": {"uninstall": yuzu_uninstall, "is_installed": yuzu_is_installed},
}

# Tools
tools = {
    "ESDE": {"uninstall": esde_uninstall},
    "SRM": {"uninstall": srm_uninstall},
}

results = {}

for name, funcs in emulators.items():
    print(f"Uninstalling {name}...")
    try:
        funcs["uninstall"]()
        results[name] = "uninstalled"
    except Exception as e:
        results[name] = f"error: {e}"

for name, funcs in tools.items():
    print(f"Uninstalling {name}...")
    try:
        funcs["uninstall"]()
        results[name] = "uninstalled"
    except Exception as e:
        results[name] = f"error: {e}"

# Emulator config/data folders
config_folders = {}

if system == "linux":
    config_folders = {
        "Azahar": [
            home / ".config" / "azahar",
            home / ".local" / "share" / "azahar-emu",
        ],
        "BigPEmu": [
            emus_folder / "bigpemu",
        ],
        "Cemu": [
            home / ".config" / "Cemu",
        ],
        "Citron": [
            home / ".config" / "citron",
            home / ".local" / "share" / "citron-emu",
        ],
        "Dolphin": [
            home / ".var" / "app" / "org.DolphinEmu.dolphin-emu",
        ],
        "DuckStation": [
            home / ".var" / "app" / "org.duckstation.DuckStation",
        ],
        "Eden": [
            home / ".config" / "eden",
            home / ".local" / "share" / "eden-emu",
        ],
        "Flycast": [
            home / ".var" / "app" / "org.flycast.Flycast",
        ],
        "MAME": [
            home / ".mame",
        ],
        "melonDS": [
            home / ".var" / "app" / "net.kuribo64.melonDS",
        ],
        "mGBA": [
            home / ".config" / "mgba",
        ],
        "PCSX2": [
            home / ".config" / "PCSX2",
        ],
        "PPSSPP": [
            home / ".var" / "app" / "org.ppsspp.PPSSPP",
        ],
        "PrimeHack": [
            home / ".var" / "app" / "io.github.shiiion.primehack",
        ],
        "RetroArch": [
            home / ".var" / "app" / "org.libretro.RetroArch",
        ],
        "RMG": [
            home / ".var" / "app" / "com.github.Rosalie241.RMG",
        ],
        "RPCS3": [
            home / ".config" / "rpcs3",
        ],
        "Ryujinx": [
            home / ".config" / "Ryujinx",
            home / ".config" / "ryujinx",
            home / ".local" / "share" / "ryujinx-emu",
        ],
        "ScummVM": [
            home / ".var" / "app" / "org.scummvm.scummvm",
        ],
        "shadPS4": [
            home / ".local" / "share" / "shadPS4",
        ],
        "SuperModel": [
            home / ".supermodel",
        ],
        "Vita3K": [
            home / ".config" / "Vita3K",
        ],
        "Xemu": [
            home / ".var" / "app" / "app.xemu.xemu",
        ],
        "Xenia": [
            home / ".config" / "xenia",
        ],
        "Yuzu": [
            home / ".config" / "yuzu",
            home / ".local" / "share" / "yuzu-emu",
        ],
    }

elif system == "darwin":
    app_support = home / "Library" / "Application Support"
    config_folders = {
        "Azahar": [
            app_support / "azahar",
        ],
        "Cemu": [
            app_support / "Cemu",
        ],
        "Dolphin": [
            app_support / "Dolphin",
        ],
        "DuckStation": [
            app_support / "DuckStation",
        ],
        "Flycast": [
            app_support / "flycast",
            app_support / "Flycast",
        ],
        "MAME": [
            app_support / "mame",
        ],
        "melonDS": [
            app_support / "melonDS",
        ],
        "mGBA": [
            home / ".config" / "mgba",
        ],
        "PCSX2": [
            app_support / "PCSX2",
        ],
        "PPSSPP": [
            app_support / "ppsspp",
            app_support / "PPSSPP",
            home / ".config" / "ppsspp",
        ],
        "PrimeHack": [
            app_support / "Dolphin",
        ],
        "RetroArch": [
            app_support / "RetroArch",
        ],
        "RMG": [
            app_support / "rmg",
        ],
        "RPCS3": [
            app_support / "RPCS3",
            app_support / "rpcs3",
        ],
        "Ryujinx": [
            app_support / "Ryujinx",
        ],
        "ScummVM": [
            app_support / "ScummVM",
        ],
        "shadPS4": [
            app_support / "shadPS4",
        ],
        "SuperModel": [
            app_support / "supermodel",
        ],
        "Vita3K": [
            home / ".config" / "vita3k",
        ],
        "Xemu": [
            app_support / "xemu",
        ],
        "Xenia": [
            home / ".config" / "xenia",
        ],
        "Yuzu": [
            home / ".local" / "share" / "yuzu-emu",
        ],
    }

elif system.startswith("win"):
    config_folders = {
        "Azahar": [emus_folder / "azahar"],
        "BigPEmu": [emus_folder / "bigpemu"],
        "Cemu": [emus_folder / "cemu"],
        "Citron": [emus_folder / "citron"],
        "Dolphin": [emus_folder / "Dolphin-x64"],
        "DuckStation": [emus_folder / "duckstation"],
        "Eden": [emus_folder / "eden"],
        "Flycast": [emus_folder / "flycast"],
        "MAME": [emus_folder / "mame"],
        "melonDS": [emus_folder / "melonds"],
        "mGBA": [emus_folder / "mgba"],
        "Model2": [emus_folder / "m2emulator"],
        "PCSX2": [emus_folder / "pcsx2"],
        "PPSSPP": [emus_folder / "ppsspp"],
        "PrimeHack": [emus_folder / "primehack"],
        "RetroArch": [emus_folder / "retroarch"],
        "RMG": [emus_folder / "rmg"],
        "RPCS3": [emus_folder / "rpcs3"],
        "Ryujinx": [emus_folder / "ryujinx"],
        "ScummVM": [emus_folder / "scummvm"],
        "shadPS4": [emus_folder / "ShadPS4-qt"],
        "SuperModel": [emus_folder / "supermodel"],
        "Vita3K": [emus_folder / "vita3k"],
        "Xemu": [emus_folder / "xemu"],
        "Xenia": [emus_folder / "xenia"],
        "Yuzu": [emus_folder / "yuzu"],
    }

print("\nRemoving emulator config folders...")
folders_removed = []
folders_failed = []

for name, paths in config_folders.items():
    for path in paths:
        if path.exists():
            try:
                shutil.rmtree(path)
                folders_removed.append(f"{name}: {path}")
                print(f"  Removed {path}")
            except Exception as e:
                folders_failed.append(f"{name}: {path} ({e})")
                print(f"  Failed {path}: {e}")

# Report
print("\n" + "=" * 40)
print("UNINSTALL REPORT")
print("=" * 40)

still_installed = []
removed = []
errors = []

for name, funcs in emulators.items():
    try:
        if funcs["is_installed"]():
            still_installed.append(name)
        else:
            removed.append(name)
    except Exception:
        errors.append(name)

for name in tools:
    removed.append(name)

if removed:
    print(f"\nRemoved ({len(removed)}):")
    for name in removed:
        print(f"  - {name}")

if still_installed:
    print(f"\nStill installed ({len(still_installed)}):")
    for name in still_installed:
        print(f"  ! {name}")

if errors:
    print(f"\nCould not verify ({len(errors)}):")
    for name in errors:
        print(f"  ? {name}")

if folders_removed:
    print(f"\nConfig folders removed ({len(folders_removed)}):")
    for entry in folders_removed:
        print(f"  - {entry}")

if folders_failed:
    print(f"\nConfig folders failed ({len(folders_failed)}):")
    for entry in folders_failed:
        print(f"  ! {entry}")

print(f"\nTotal: {len(removed)} removed, {len(still_installed)} still installed, {len(errors)} unknown")
print(f"Config folders: {len(folders_removed)} removed, {len(folders_failed)} failed")
print("=" * 40)