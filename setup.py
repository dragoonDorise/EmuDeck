#!/usr/bin/env python3
from functions.env import generate_python_env
generate_python_env()
from core.all import *
progress_bar=0
#Log reset
with open(emudeck_logs/'emudeck.log', 'w', encoding='utf-8') as f:
    f.write("")

# Github API limits

print('Github API limits:')

response = requests.get('https://api.github.com/rate_limit', headers={
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28'
})
if response.ok:
    rate_info = response.json()
    print(rate_info)
else:
    print(f"Error {response.status_code}: {response.text}")
#
# Create folders
#
emulation_path.mkdir(parents=True, exist_ok=True)
roms_path.mkdir(parents=True, exist_ok=True)
tools_path.mkdir(parents=True, exist_ok=True)
bios_path.mkdir(parents=True, exist_ok=True)
saves_path.mkdir(parents=True, exist_ok=True)
storage_path.mkdir(parents=True, exist_ok=True)
ESDEscrapData.mkdir(parents=True, exist_ok=True)

# Copy roms estructure
shutil.copytree(f"{emudeck_backend}/configs/common/roms", roms_path, dirs_exist_ok=True)

# Set proper launchers
print("NYI")

#get_environment_details()

#
# Installs
#

MAX_JOBS = 5
commands = [
    (install_frontends.esde.status,    esde_install),
    (True,     srm_install),
    (install_emus.azahar.status,           azahar_install),
    (install_emus.bigpemu.status,          bigpemu_install),
    (install_emus.cemu.status,             cemu_install),
    (install_emus.flycast.status,          flycast_install),
    (install_emus.dolphin.status,          dolphin_install),
    (install_emus.duckstation.status,             duckstation_install),
    (install_emus.mame.status,             mame_install),
    (install_emus.melonds.status,          melonds_install),
    (install_emus.mgba.status,             mgba_install),
    (install_emus.model2.status,             model2_install),    (install_emus.pcsx2.status,          pcsx2qt_install),
    (install_emus.ppsspp.status,           ppsspp_install),
    (install_emus.primehack.status,        primehack_install),
    (install_emus.rpcs3.status,            rpcs3_install),
    (install_emus.ra.status,               retroarch_install),
    (install_emus.rmg.status,              rmg_install),
    (install_frontends.deckyromlauncher.status,     plugins_install_retro_library),
    (install_emus.ryujinx.status,          ryujinx_install),
    (install_emus.scummvm.status,          scummvm_install),
    (install_emus.shadps4.status,          shadps4_install),
    (install_emus.supermodel.status,       supermodel_install),
    (install_emus.vita3k.status,           vita3k_install),
    (install_emus.xemu.status,             xemu_install),
    (install_emus.xenia.status,            xenia_install),
]

with ThreadPoolExecutor(max_workers=MAX_JOBS) as executor:
    future_to_func = {
        executor.submit(func): func.__name__
        for flag, func in commands
        if flag
    }

    for future in as_completed(future_to_func):
        name = future_to_func[future]
        try:
            future.result()
            print(f"[OK] {name}")
        except Exception as exc:
            print(f"[ERROR] {name} -> {exc!r}")
#
# Configurations
#
commands = [
    (overwrite_config_emus.esde.status,    esde_init),
    (True,     srm_init),
    (overwrite_config_emus.azahar.status,           azahar_init),
    (overwrite_config_emus.bigpemu.status,          bigpemu_init),
    (overwrite_config_emus.cemu.status,             cemu_init),
    (overwrite_config_emus.flycast.status,          flycast_init),
    (overwrite_config_emus.dolphin.status,          dolphin_init),
    (overwrite_config_emus.duckstation.status,             duckstation_init),
    (overwrite_config_emus.mame.status,             mame_init),
    (overwrite_config_emus.melonds.status,          melonds_init),
    (overwrite_config_emus.mgba.status,             mgba_init),
    (overwrite_config_emus.model2.status,             model2_init),    (overwrite_config_emus.pcsx2.status,          pcsx2qt_init),
    (overwrite_config_emus.ppsspp.status,           ppsspp_init),
    (overwrite_config_emus.primehack.status,        primehack_init),
    (overwrite_config_emus.rpcs3.status,            rpcs3_init),
    (overwrite_config_emus.ra.status,               retroarch_init),
    (overwrite_config_emus.rmg.status,              rmg_init),
    (overwrite_config_emus.ryujinx.status,          ryujinx_init),
    (overwrite_config_emus.scummvm.status,          scummvm_init),
    (overwrite_config_emus.shadps4.status,          shadps4_init),
    (overwrite_config_emus.supermodel.status,       supermodel_init),
    (overwrite_config_emus.vita3k.status,           vita3k_init),
    (overwrite_config_emus.xemu.status,             xemu_init),
    (overwrite_config_emus.xenia.status,            xenia_init),
]

with ThreadPoolExecutor(max_workers=MAX_JOBS) as executor:
    future_to_func = {
        executor.submit(func): func.__name__
        for flag, func in commands
        if flag
    }

    for future in as_completed(future_to_func):
        name = future_to_func[future]
        try:
            future.result()
            print(f"[OK] {name}")
        except Exception as exc:
            print(f"[ERROR] {name} -> {exc!r}")

#
##
##End of installation
##
#

# BINUP_install &
# AutoCopy_install &
# server_install &
# FlatpakUP_install &
# CHD_install &

#
##
## Overrides for non Steam hardware...
##
#

if get_screen_ar() == 169:
   ar_169_screen()

create_desktop_icon()

#Mark as finished
log_path = Path(emudeck_logs) / "msg.log"
with log_path.open("w", encoding="utf-8") as f:
    f.write("100")

with log_path.open("a", encoding="utf-8") as f:
    f.write("# Installation Complete\n")