from core.all import *

if system == "linux":
    retroarch_cfg_file=Path(f"{home}/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg")
    retroarch_dir=Path(f"{home}/.var/app/org.libretro.RetroArch/config/retroarch")
if system.startswith("win"):
    retroarch_cfg_file=Path(f"{emus_folder}/retroarch/retroarch.cfg")
    retroarch_dir=Path(f"{emus_folder}/retroarch")
if system == "darwin":
    retroarch_cfg_file=Path(f"{home}/Library/Application Support/RetroArch/retroarch.cfg")
    retroarch_dir=Path(f"{home}/Library/Application Support/RetroArch")

    retroarch_shaders_path=Path(f"{retroarch_dir}/shaders")
    retroarch_shaderscg_path=Path(f"{retroarch_dir}/shaders/shaders_cg")
    retroarch_shadersglsl_path=Path(f"{retroarch_dir}/shaders/shaders_glsl")
    retroarch_shadersslang_path=Path(f"{retroarch_dir}/shaders/shaders_slang")
    retroarch_assets_path=Path(f"{retroarch_dir}/assets")
    retroarch_autoconfig_path=Path(f"{retroarch_dir}/autoconfig")
    retroarch_overlays_path=Path(f"{retroarch_dir}/overlays")
    retroarch_info_path=Path(f"{retroarch_dir}/info")
    retroarch_ppsspp_path=Path(f"{bios_path}/PPSSPP")
    retroarch_cheats_path=Path(f"{retroarch_dir}/cheats")

def retroarch_install():
    set_msg(f"Installing retroarch")

    if system == "linux":
        type="org.libretro.RetroArch"
        repo=""
        path=emus_folder

    if system.startswith("win"):
        type="7z"
        repo="https://buildbot.libretro.com/nightly/windows/x86_64/RetroArch.7z"
        path=f"{emus_folder}/retroarch"

    if system == "darwin":
        type="dmg"
        repo="https://buildbot.libretro.com/nightly/apple/osx/universal/RetroArch_Metal.dmg"
        path=emus_folder

    try:
        install_emu("retroarch", repo, type, path)
        retroarch_install_cores()
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def retroarch_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.libretro.RetroArch", "flatpak")
        if system.startswith("win"):
          uninstall_emu("retroarch", "dir")
        if system == "darwin":
          uninstall_emu("RetroArch", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def retroarch_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.libretro.RetroArch")
    if system.startswith("win"):
      return (emus_folder / "retroarch" / "retroarch.exe").exists()
    if system == "darwin":
      return (emus_folder / "RetroArch.app").exists()


def retroarch_init():
    set_msg(f"Setting up retroarch")

    retroarch_backup_configs()

    copy_setting_dir(f"common/retroarch/",retroarch_dir)
    #copy_and_set_settings_file(f"common/retroarch/retroarch.cfg", retroarch_dir)
    retroarch_setup_cfg_file_paths()
    retroarch_setup_saves()
    retroarch_set_controller_style()
    retroarch_set_core_opt_all()
    retroarch_set_config_all()
    retroarch_setup_extra_configurations()
    retroarch_set_customizations()
    retroarch_auto_save()
    retroarch_set_retroachievements()
    retroarch_buildbot_downloader()

    #Customizations

def retroarch_install_init():
    retroarch_install()
    retroarch_init()


def retroarch_setup_cfg_file_paths():
    src = Path(f"{emudeck_backend}/configs/common/retroarch/retroarch.cfg")
    shutil.copy2(src, retroarch_dir)
    sed("EMULATIONPATH",emulation_path,retroarch_cfg_file)
    sed("RETROARCHFOLDER",retroarch_dir,retroarch_cfg_file)
    sed("ASSETSFOLDER",retroarch_assets_path,retroarch_cfg_file)



def retroarch_setup_saves():
    origin_saves=f"{retroarch_dir}/saves"
    origin_states=f"{retroarch_dir}/states"

    move_contents_and_link(origin_saves,f"{saves_path}/retroarch/saves")
    move_contents_and_link(origin_states,f"{saves_path}/retroarch/states")

def retroarch_set_abxy_style():
    remaps=f"{retroarch_dir}/config/remaps"

    retroarch_enable_remap(f"{remaps}/mGBA/mGBA.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Gambatte/Gambatte.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/bsnes-hd beta/bsnes-hd beta.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/melonDS DS/melonDS DS.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Mupen64Plus-Next/Mupen64Plus-Next.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/SameBoy/SameBoy.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Snes9x/Snes9x.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Mesen/Mesen.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Nestopia/Nestopia.rmp.disabled")
    retroarch_enable_remap(f"{remaps}/Beetle VB/Beetle VB.rmp.disabled")

def retroarch_set_bayx_style():
    remaps=f"{retroarch_dir}/config/remaps"

    retroarch_disable_remap(f"{remaps}/mGBA/mGBA.rmp")
    retroarch_disable_remap(f"{remaps}/Gambatte/Gambatte.rmp")
    retroarch_disable_remap(f"{remaps}/bsnes-hd beta/bsnes-hd beta.rmp")
    retroarch_disable_remap(f"{remaps}/melonDS DS/melonDS DS.rmp")
    retroarch_disable_remap(f"{remaps}/Mupen64Plus-Next/Mupen64Plus-Next.rmp")
    retroarch_disable_remap(f"{remaps}/SameBoy/SameBoy.rmp")
    retroarch_disable_remap(f"{remaps}/Snes9x/Snes9x.rmp")
    retroarch_disable_remap(f"{remaps}/Mesen/Mesen.rmp")
    retroarch_disable_remap(f"{remaps}/Nestopia/Nestopia.rmp")
    retroarch_disable_remap(f"{remaps}/Beetle VB/Beetle VB.rmp")


def retroarch_set_controller_style():
    if settings.controllerLayout == "bayx":
        retroarch_set_bayx_style()
    else:
        retroarch_set_bayx_style()

def retroarch_set_core_setting(config_name: str,
                                   core: str,
                                   key: str,
                                   value: str) -> None:
    """
    Ensure that every config file named `config_name` under
    `${retroarch_dir}/config/{core}` has `key = value`.
    If no such file exists, create one with that single setting.
    """
    config_root = Path(retroarch_dir) / "config" / core

    # Pattern to match lines beginning with the key (possibly with whitespace)
    pattern = re.compile(rf'^\s*{re.escape(key)}\s*=.*$')

    # Find all existing config files
    configs = list(config_root.rglob(config_name))

    if not configs:
        # No config found: create one
        new_cfg = config_root / config_name
        new_cfg.parent.mkdir(parents=True, exist_ok=True)
        new_cfg.write_text(f"{key} = {value}\n", encoding="utf-8")
        print(f"Created {new_cfg!s} with {key} = {value}")
        return

    # Update each existing config
    for cfg_path in configs:
        lines = cfg_path.read_text(encoding="utf-8").splitlines()
        updated = False

        for idx, line in enumerate(lines):
            if pattern.match(line):
                lines[idx] = f"{key} = {value}"
                updated = True
                break

        if not updated:
            lines.append(f"{key} = {value}")

        cfg_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        print(f"Updated {cfg_path!s}: set {key} = {value}")

def retroarch_enable_remap(path: Path) -> Path:
    path = Path(path)
    suffix = ".disabled"
    if path.name.endswith(suffix):
        # 'mesen.cfg.disabled' -> 'mesen.cfg'
        new_name = path.name[:-len(suffix)]
        new_path = path.with_name(new_name)
        path.rename(new_path)

def retroarch_disable_remap(path: Path) -> Path:
    path=Path(path)
    if path.is_file() and path.suffix.lower() == ".rmp":
        # path.name = "algo.rmp"; queremos "algo.rmp.disabled"
        new_name = path.name + ".disabled"
        new_path = path.with_name(new_name)
        path.rename(new_path)

def retroarch_install_cores():
    print("DIY")

def retroarch_backup_configs() -> None:
    core_config_folders = [
        Path(retroarch_dir) / "cores",
        # Path("/otra/carpeta/de/cores"),  # puedes añadir más rutas aquí
    ]

    # 1) Main config
    if retroarch_cfg_file.is_file():
        bak = retroarch_cfg_file.with_suffix(retroarch_cfg_file.suffix + ".bak")
        shutil.copy2(retroarch_cfg_file, bak)
        print(f"Backed up {retroarch_cfg_file} → {bak}")
    else:
        print(f"Warning: main config not found: {retroarch_cfg_file}")

    # 2) Extensiones a buscar
    exts = [".cfg", ".opt", ".slangp", ".glslp"]

    # 3) Ahora sí iteramos la lista de carpetas
    for folder in core_config_folders:
        if not folder.is_dir():
            continue
        for ext in exts:
            for path in folder.rglob(f"*{ext}"):
                if path.is_file():
                    bak = path.with_suffix(path.suffix + ".bak")
                    shutil.copy2(path, bak)
                    print(f"Backed up {path} → {bak}")

def retroarch_set_core_opt_all():
    funcs = [
        fn for fn, obj in globals().items()
        if inspect.isfunction(obj) and fn.endswith('_setup_core_opt')
    ]
    funcs.sort()

    for fn_name in funcs:
        fn = globals()[fn_name]
        print(fn_name)
        try:
            fn()
        except Exception as e:
            print(f"Error running {fn_name}: {e}")

def retroarch_set_config_all():
            funcs = [
                name for name, obj in globals().items()
                if inspect.isfunction(obj)
                   and name.startswith("retroarch_")
                   and name.endswith("_set_config")
            ]
            funcs.sort()

            for fn_name in funcs:
                print(fn_name)
                try:
                    globals()[fn_name]()  # call the function
                except Exception as e:
                    print(f"Error running {fn_name}: {e}")

def retroarch_setup_extra_configurations():
    if system == "linux":
        set_config("input_driver", "sdl2", retroarch_cfg_file)
        set_config("microphone_driver", "sdl2", retroarch_cfg_file)

    set_config("savestate_thumbnail_enable", "true", retroarch_cfg_file)


def retroarch_set_customizations():
    print("NYI")

def retroarch_auto_save():
    if settings.autosave:
        retroarch_auto_save_on()
    else:
        retroarch_auto_save_off()

def retroarch_auto_save_on():
    set_config("savestate_auto_load", "true", retroarch_cfg_file)
    set_config("savestate_auto_save", "true", retroarch_cfg_file)

def retroarch_auto_save_off():
    set_config("savestate_auto_load", "false", retroarch_cfg_file)
    set_config("savestate_auto_save", "false", retroarch_cfg_file)

def retroarch_set_retroachievements():
    retroarch_retroachievements_set_login()
    if settings.achievements.user == '':
        retroarch_retroachievements_off()
    else:
        retroarch_retroachievements_on()


def retroarch_update_assets(assets_url: str, assets_dir: Path) -> bool:
    # Ensure directory exists
    assets_dir.mkdir(parents=True, exist_ok=True)

    # Check if directory is empty ([] == empty)
    if any(assets_dir.iterdir()):
        return False

    zip_path = assets_dir / "assets.zip"

    try:
        # Download ZIP
        resp = requests.get(assets_url, stream=True, timeout=30)
        resp.raise_for_status()
        with open(zip_path, "wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                f.write(chunk)

        # Extract quietly, overwriting existing files
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(path=assets_dir)

    except Exception:
        # Suppress all errors (like `&> /dev/null` in shell)
        return False
    finally:
        # Clean up ZIP if it was created
        if zip_path.exists():
            zip_path.unlink()

    return True
def retroarch_buildbot_downloader():

    retroarch_assets_url="https://buildbot.libretro.com/assets/frontend/assets.zip"
    retroarch_shaderscg_url="https://buildbot.libretro.com/assets/frontend/shaders_cg.zip"
    retroarch_shadersglsl_url="https://buildbot.libretro.com/assets/frontend/shaders_glsl.zip"
    retroarch_shadersslang_url="https://buildbot.libretro.com/assets/frontend/shaders_slang.zip"
    retroarch_autoconfig_url="https://buildbot.libretro.com/assets/frontend/autoconfig.zip"
    retroarch_overlays_url="https://buildbot.libretro.com/assets/frontend/overlays.zip"
    retroarch_info_url="https://buildbot.libretro.com/assets/frontend/info.zip"
    retroarch_ppsspp_url="https://buildbot.libretro.com/assets/system/PPSSPP.zip"
    retroarch_cheats_url="https://buildbot.libretro.com/assets/frontend/cheats.zip"

    retroarch_update_assets(retroarch_assets_url, retroarch_assets_path)
    retroarch_update_assets(retroarch_shaderscg_url, retroarch_shaderscg_path)
    retroarch_update_assets(retroarch_shadersglsl_url, retroarch_shadersglsl_path)
    retroarch_update_assets(retroarch_shadersslang_url, retroarch_shadersslang_path)
    retroarch_update_assets(retroarch_info_url, retroarch_info_path)
    retroarch_update_assets(retroarch_ppsspp_url, retroarch_ppsspp_path)
    retroarch_update_assets(retroarch_autoconfig_url, retroarch_autoconfig_path)
    retroarch_update_assets(retroarch_overlays_url, retroarch_overlays_path)
    retroarch_update_assets(retroarch_cheats_url, retroarch_cheats_path)

def retroarch_vice_xvic_set_config():
        retroarch_set_core_setting('xvic.cfg','VICE xvic','video_driver',"glcore")

def retroarch_vice_xscpu64_set_config():
    retroarch_set_core_setting('xscpu64.cfg','VICE xscpu64','video_driver',"glcore")

def retroarch_vice_x64sc_set_config():
    retroarch_set_core_setting('x64sc.cfg','VICE x64sc','video_driver',"glcore")

def retroarch_vice_x64_set_config():
    retroarch_set_core_setting('x64.cfg','VICE x64','video_driver',"glcore")


def retroarch_wswanc_set_config():
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle Cygne','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle WonderSwan','input_player1_analog_dpad_mode',"1")

def retroarch_wswanc_bezel_on():
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle Cygne','input_overlay_enable',"false")
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle WonderSwan','input_overlay_enable',"false")

def retroarch_wswanc_bezel_off():
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle Cygne','input_overlay_enable',"false")
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle WonderSwan','input_overlay_enable',"false")

def retroarch_wswanc_matrix_shader_on():
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle Cygne','video_shader_enable','true')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,Cygne','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,Cygne','video_smooth',"false")

    retroarch_set_core_setting('wonderswancolor.cfg','Beetle WonderSwan','video_shader_enable','true')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,WonderSwan'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,WonderSwan'	,'video_smooth',"false")


def retroarch_wswanc_matrix_shader_off():
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle Cygne','video_shader_enable','false')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,Cygne','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,Cygne','video_smooth',"true")

    retroarch_set_core_setting('wonderswancolor.cfg','Beetle WonderSwan','video_shader_enable','false')
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,WonderSwan'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('wonderswancolor.cfg','Beetle,WonderSwan'	,'video_smooth',"true")


def retroarch_wswan_set_config():
    retroarch_set_core_setting('wonderswan.cfg','Beetle Cygne','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('wonderswan.cfg','Beetle WonderSwan','input_player1_analog_dpad_mode',"1")

def retroarch_wswan_bezel_on():
    retroarch_set_core_setting('wonderswan.cfg','Beetle Cygne','input_overlay_enable',"false")
    retroarch_set_core_setting('wonderswan.cfg','Beetle WonderSwan','input_overlay_enable',"false")


def retroarch_wswan_bezel_off():
    retroarch_set_core_setting('wonderswan.cfg','Beetle Cygne','input_overlay_enable',"false")
    retroarch_set_core_setting('wonderswan.cfg','Beetle WonderSwan','input_overlay_enable',"false")


def retroarch_wswan_matrix_shader_on():
    retroarch_set_core_setting('wonderswan.cfg','Beetle Cygne','video_shader_enable','true')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,Cygne','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,Cygne','video_smooth',"false")

    retroarch_set_core_setting('wonderswan.cfg','Beetle WonderSwan','video_shader_enable','true')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,WonderSwan'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,WonderSwan'	,'video_smooth',"false")


def retroarch_wswan_matrix_shader_off():
    retroarch_set_core_setting('wonderswan.cfg','Beetle Cygne','video_shader_enable','false')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,Cygne','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('wonderswan.cfg','Beetle,Cygne','video_smooth',"true")

    retroarch_set_core_setting('wonderswan.cfg','Beetle WonderSwan','video_shader_enable','false')
    retroarch_set_core_setting('wonderswan.cfg','Beetle,WonderSwan'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('wonderswan.cfg','Beetle,WonderSwan'	,'video_smooth',"true")


def retroarch_dolphin_emu_set_config():
    retroarch_set_core_setting('dolphin_emu.cfg','dolphin_emu','video_driver',"gl")
    retroarch_set_core_setting('dolphin_emu.cfg','dolphin_emu','video_driver',"gl")


def retroarch_PPSSPP_set_config():
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_auto_frameskip',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_block_transfer_gpu',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_button_preference',"Cross")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_cheats',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_cpu_core',"JIT")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_disable_slow_framebuffer_effects',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_fast_memory',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_force_lag_sync',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_frameskip',"Off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_frameskiptype',"Number")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_gpu_hardware_transform',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_ignore_bad_memory_access',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_inflight_frames',"Up")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_internal_resolution',"1440x816")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_io_timing_method',"Fast")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_language',"Automatic")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_lazy_texture_caching',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_locked_cpu_speed',"off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_lower_resolution_for_effects',"Off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_rendering_mode',"Buffered")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_retain_changed_textures',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_software_skinning',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_spline_quality',"Low")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_anisotropic_filtering',"off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_deposterize',"disabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_filtering',"Auto")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_replacement',"enabled")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_scaling_level',"Off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_scaling_type',"xbrz")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_texture_shader',"Off")
    retroarch_set_core_setting('psp.cfg','PPSSPP','ppsspp_vertex_cache',"disabled")


def retroarch_pcengine_set_config():
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','input_player1_analog_dpad_mode',"1")

def retroarch_pcengine_bezel_on():
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','aspect_ratio_index',"21")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','custom_viewport_height',"1200")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','custom_viewport_x',"0")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast', 'input_overlay',f"{retroarch_overlays_path}/pegasus/pcengine.cfg")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','input_overlay_aspect_adjust_landscape',"-0.150000")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','input_overlay_enable',"true")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','input_overlay_scale_landscape',"1.075000")

    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','aspect_ratio_index',"21")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','custom_viewport_height',"1200")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','custom_viewport_x',"0")
    retroarch_set_core_setting('pcengine.cfg','Beetle,PCE', 'input_overlay',f"{retroarch_overlays_path}/pegasus/pcengine.cfg")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','input_overlay_aspect_adjust_landscape',"-0.150000")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','input_overlay_enable',"true")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','input_overlay_scale_landscape',"1.075000")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','aspect_ratio_index',"21")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','custom_viewport_height',"1200")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','custom_viewport_x',"0")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast', 'input_overlay',f"{retroarch_overlays_path}/pegasus/pcengine.cfg")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','input_overlay_aspect_adjust_landscape',"-0.150000")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','input_overlay_enable',"true")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','input_overlay_scale_landscape',"1.075000")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE','aspect_ratio_index',"21")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','custom_viewport_height',"1200")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','custom_viewport_x',"0")
    retroarch_set_core_setting('tg16.cfg','Beetle,PCE', 'input_overlay',f"{retroarch_overlays_path}/pegasus/pcengine.cfg")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','input_overlay_aspect_adjust_landscape',"-0.150000")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','input_overlay_enable',"true")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','input_overlay_scale_landscape',"1.075000")



def retroarch_pcengine_bezel_off():
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','input_overlay_enable',"false")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','input_overlay_enable',"false")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','input_overlay_enable',"false")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE','input_overlay_enable',"false")


def retroarch_pcengine_crt_shader_on():
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_shader_enable',"true")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_smooth',"false")

    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','video_shader_enable',"true")
    retroarch_set_core_setting('pcengine.cfg','Beetle,PCE','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('pcengine.cfg','Beetle,PCE','video_smooth',"false")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_shader_enable',"true")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_smooth',"false")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE','video_shader_enable',"true")
    retroarch_set_core_setting('tg16.cfg','Beetle,PCE','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('tg16.cfg','Beetle,PCE','video_smooth',"false")


def retroarch_pcengine_crt_shader_off():
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_shader_enable',"false")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('pcengine.cfg','Beetle PCE Fast','video_smooth' "true")

    retroarch_set_core_setting('pcengine.cfg','Beetle PCE','video_shader_enable',"false")
    retroarch_set_core_setting('pcengine.cfg','Beetle,PCE','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('pcengine.cfg','Beetle,PCE','video_smooth',"true")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_shader_enable',"false")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('tg16.cfg','Beetle PCE Fast','video_smooth' "true")

    retroarch_set_core_setting('tg16.cfg','Beetle PCE','video_shader_enable',"false")
    retroarch_set_core_setting('tg16.cfg','Beetle,PCE','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('tg16.cfg','Beetle,PCE','video_smooth',"true")


def retroarch_amiga1200_crt_shader_off():
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_shader_enable',"false")
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_smooth',"true")


def retroarch_amiga1200_crt_shader_on():
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_shader_enable',"true")
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('amiga1200.cfg','PUAE','video_smooth',"false")


def retroarch_amiga1200_setup_core_opt():
    retroarch_set_core_setting('amiga1200.opt','PUAE','puae_model',"A1200")


def retroarch_nes_set_config():
    retroarch_set_core_setting('nes.cfg','Mesen','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('nes.cfg','Nestopia','input_player1_analog_dpad_mode',"1")


def retroarch_nes_bezel_on():
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay',f"{retroarch_overlays_path}/pegasus/nes.cfg")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_enable',"true")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_opacity',"0.700000")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_aspect_adjust_landscape',"0.100000")
    retroarch_set_core_setting('nes.cfg','Mesen','video_scale_integer',"false")
    retroarch_set_core_setting('nes.cfg','Mesen','aspect_ratio_index',"0")

    if settings.ar.snes == "87":
        retroarch_nes_ar87()
    elif settings.ar.snes == "32":
        retroarch_nes_ar32()
    else:
        retroarch_nes_ar43()


def retroarch_nes_bezel_off():
    retroarch_set_core_setting('nes.cfg','Nestopia','input_overlay_enable',"false")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_enable',"false")


def retroarch_nes_crt_shader_on():
    retroarch_set_core_setting('nes.cfg','Mesen','video_shader_enable',"true")
    retroarch_set_core_setting('nes.cfg','Mesen','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('nes.cfg','Mesen','video_smooth',"false")

    retroarch_set_core_setting('nes.cfg','Nestopia','video_shader_enable',"true")
    retroarch_set_core_setting('nes.cfg','Nestopia','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('nes.cfg','Nestopia','video_smooth',"false")


def retroarch_nes_crt_shader_off():
    retroarch_set_core_setting('nes.cfg','Mesen','video_shader_enable',"false")
    retroarch_set_core_setting('nes.cfg','Mesen','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('nes.cfg','Mesen','video_smooth',"true")

    retroarch_set_core_setting('nes.cfg','Nestopia','video_shader_enable',"false")
    retroarch_set_core_setting('nes.cfg','Nestopia','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('nes.cfg','Nestopia','video_smooth',"true")


def retroarch_nes_ar43():
    #retroarch_nes_bezel_on
    retroarch_set_core_setting('nes.cfg','Nestopia','aspect_ratio_index',"0")
    retroarch_set_core_setting('nes.cfg','Mesen','aspect_ratio_index',"0")


def retroarch_nes_ar87():
    retroarch_set_core_setting('nes.cfg','Nestopia','input_overlay_scale_landscape',"1.380000")
    retroarch_set_core_setting('nes.cfg','Nestopia','input_overlay_aspect_adjust_landscape',"-0.170000")
    retroarch_set_core_setting('nes.cfg','Nestopia','aspect_ratio_index',"15")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_scale_landscape',"1.380000")
    retroarch_set_core_setting('nes.cfg','Mesen','input_overlay_aspect_adjust_landscape',"-0.170000")
    retroarch_set_core_setting('nes.cfg','Mesen','aspect_ratio_index',"15")


def retroarch_nes_ar32():
    retroarch_set_core_setting('nes.cfg','Nestopia','aspect_ratio_index',"7")
    retroarch_set_core_setting('nes.cfg','Mesen','aspect_ratio_index',"7")
    retroarch_nes_bezel_off


def retroarch_mupen64plus_next_set_config():
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','aspect_ratio_index',"0")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_crop_overscan',"false")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_smooth','ED_RM_LINE')
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_shader_enable',"false")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay_auto_scale',"false")





def retroarch_n64_3d_crt_shader_on():
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_shader_enable',"true")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_smooth','ED_RM_LINE')


def retroarch_n64_3d_crt_shader_off():
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_shader_enable',"false")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','video_smooth','ED_RM_LINE')


def retroarch_n64_set_config():
    retroarch_n64_3d_crt_shader_off


def retroarch_lynx_set_config():
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_player1_analog_dpad_mode',"1")


def retroarch_lynx_bezel_on():
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','aspect_ratio_index',"21")
    retroarch_set_core_setting('lynx.cfg','Beetle,Lynx', 'input_overlay',f"{retroarch_overlays_path}/pegasus/lynx.cfg")
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_overlay_enable',"true")
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_overlay_opacity',"0.700000")
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','video_scale_integer',"false")

    retroarch_set_core_setting('atarilynx.cfg','Handy','aspect_ratio_index',"21")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay',f"{retroarch_overlays_path}/pegasus/lynx.cfg")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay_enable',"true")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay_opacity',"0.700000")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('atarilynx.cfg','Handy','video_scale_integer',"false")


def retroarch_lynx_bezel_off():
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','input_overlay_enable',"false")
    retroarch_set_core_setting('atarilynx.cfg','Handy','input_overlay_enable',"false")


def retroarch_lynx_matrix_shader_on():
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','video_shader_enable','true')
    retroarch_set_core_setting('lynx.cfg','Beetle,Lynx','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('lynx.cfg','Beetle,Lynx','video_smooth',"false")

    retroarch_set_core_setting('atarilynx.cfg','Handy','video_shader_enable','true')
    retroarch_set_core_setting('atarilynx.cfg','Handy','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('atarilynx.cfg','Handy','video_smooth',"false")


def retroarch_lynx_matrix_shader_off():
    retroarch_set_core_setting('lynx.cfg','Beetle Lynx','video_shader_enable','false')
    retroarch_set_core_setting('lynx.cfg','Beetle,Lynx','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('lynx.cfg','Beetle,Lynx','video_smooth',"true")

    retroarch_set_core_setting('atarilynx.cfg','Handy','video_shader_enable','false')
    retroarch_set_core_setting('atarilynx.cfg','Handy','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('atarilynx.cfg','Handy','video_smooth',"true")



def retroarch_SameBoy_gb_set_config():
    retroarch_set_core_setting('gb.cfg','SameBoy','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_dark_filter_level',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_bootloader',"enabled")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_colorization',"internal")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_hwmode',"Auto")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_internal_palette','GB')
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_mode','Not')
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_port',"56400")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_1',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_10',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_11',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_12',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_2',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_3',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_4',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_5',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_6',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_7',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_8',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_link_network_server_ip_9',"0")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_palette_twb64_1','TWB64')
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_gb_palette_twb64_2','TWB64')
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_mix_frames',"disabled")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_rumble_level',"10")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_show_gb_link_settings',"disabled")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_turbo_period',"4")
    retroarch_set_core_setting('gb.cfg','SameBoy','gambatte_up_down_allowed',"disabled")


def retroarch_ngp_set_config():
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_player1_analog_dpad_mode',"1")


def retroarch_ngp_bezel_on():
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','aspect_ratio_index',"21")
    retroarch_set_core_setting('ngp.cfg','Beetle,NeoPop', 'input_overlay',f"{retroarch_overlays_path}/pegasus/ngpc.cfg")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_aspect_adjust_landscape',"-0.310000")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_enable',"true")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_scale_landscape',"1.625000")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_x_separation_portrait',"-0.010000")
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_y_offset_landscape',"-0.135000")


def retroarch_ngp_bezel_off():
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','input_overlay_enable',"false")


def retroarch_ngp_matrix_shader_on():
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','video_shader_enable','true')
    retroarch_set_core_setting('ngp.cfg','Beetle,NeoPop'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('ngp.cfg','Beetle,NeoPop'	,'video_smooth',"false")


def retroarch_ngp_matrix_shader_off():
    retroarch_set_core_setting('ngp.cfg','Beetle NeoPop','video_shader_enable','false')
    retroarch_set_core_setting('ngp.cfg','Beetle,NeoPop'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('ngp.cfg','Beetle,NeoPop'	,'video_smooth',"true")


def retroarch_ngpc_set_config():
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_player1_analog_dpad_mode',"1")


def retroarch_ngpc_bezel_on():
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','aspect_ratio_index',"21")
    retroarch_set_core_setting('ngpc.cfg','Beetle,NeoPop', 'input_overlay',f"{retroarch_overlays_path}/pegasus/ngpc.cfg")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_aspect_adjust_landscape',"-0.170000")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_enable',"true")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_scale_landscape',"1.615000")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_x_separation_portrait',"-0.010000")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_y_offset_landscape',"-0.135000")


def retroarch_ngpc_bezel_off():
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','input_overlay_enable',"false")


def retroarch_ngpc_matrix_shader_on():
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','video_shader_enable','true')
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','video_smooth',"false")


def retroarch_ngpc_matrix_shader_off():
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','video_shader_enable','false')
    retroarch_set_core_setting('ngpc.cfg','Beetle,NeoPop', 'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('ngpc.cfg','Beetle NeoPop','video_smooth',"true")


def retroarch_atari2600_set_config():
    retroarch_set_core_setting('atari2600.cfg','Stella','input_player1_analog_dpad_mode',"1")


def retroarch_atari2600_bezel_on():
    retroarch_set_core_setting('atari2600.cfg','Stella','input_overlay',f"{retroarch_overlays_path}/pegasus/atari2600.cfg")
    retroarch_set_core_setting('atari2600.cfg','Stella','input_overlay_enable',"true")
    retroarch_set_core_setting('atari2600.cfg','Stella','input_overlay_aspect_adjust_landscape',"0.095000")
    retroarch_set_core_setting('atari2600.cfg','Stella','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('atari2600.cfg','Stella','aspect_ratio_index',"0")


def retroarch_atari2600_bezel_off():
    retroarch_set_core_setting('atari2600.cfg','Stella','input_overlay_enable',"false")


def retroarch_atari2600_crt_shader_on():
    retroarch_set_core_setting('atari2600.cfg','Stella','video_shader_enable','true')
    retroarch_set_core_setting('atari2600.cfg','Stella','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('atari2600.cfg','Stella','video_smooth',"false")


def retroarch_atari2600_crt_shader_off():
    retroarch_set_core_setting('atari2600.cfg','Stella','video_shader_enable',"false")
    retroarch_set_core_setting('atari2600.cfg','Stella','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('atari2600.cfg','Stella','video_smooth',"true")


def retroarch_mame_set_config():
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('mame.cfg','MAME','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('mame.cfg','MAME', 'cheevos_enable',"false")


def retroarch_mame_bezel_on():
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','input_overlay_enable',"false")
    retroarch_set_core_setting('mame.cfg','MAME','input_overlay_enable',"false")


def retroarch_mame_bezel_off():
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','input_overlay_enable',"false")
    retroarch_set_core_setting('mame.cfg','MAME','input_overlay_enable',"false")


def retroarch_mame_crt_shader_on():
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_shader_enable','true')
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_smooth',"false")

    retroarch_set_core_setting('mame.cfg','MAME','video_shader_enable','true')
    retroarch_set_core_setting('mame.cfg','MAME','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('mame.cfg','MAME','video_smooth',"false")


def retroarch_mame_crt_shader_off():
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_shader_enable','false')
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','video_smooth',"true")

    retroarch_set_core_setting('mame.cfg','MAME','video_shader_enable','false')
    retroarch_set_core_setting('mame.cfg','MAME','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('mame.cfg','MAME','video_smooth',"true")


def retroarch_neogeo_bezel_on():
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo', 'input_overlay',f"{retroarch_overlays_path}/pegasus/neogeo.cfg")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn Neo','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn Neo','input_overlay_enable',"true")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn Neo','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn Neo','input_overlay_scale_landscape',"1.170000")


def retroarch_neogeo_bezel_off():
    retroarch_set_core_setting('neogeo.cfg','FinalBurn Neo','input_overlay_enable',"false")


def retroarch_neogeo_crt_shader_on():
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_shader_enable','true')
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_smooth',"false")


def retroarch_neogeo_crt_shader_off():
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_shader_enable',"false")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('neogeo.cfg','FinalBurn,Neo','video_smooth',"true")


def retroarch_fbneo_bezel_on():
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo', 'input_overlay',f"{retroarch_overlays_path}/pegasus/neogeo.cfg")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn Neo','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn Neo','input_overlay_enable',"true")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn Neo','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn Neo','input_overlay_scale_landscape',"1.170000")


def retroarch_fbneo_bezel_off():
    retroarch_set_core_setting('fbneo.cfg','FinalBurn Neo','input_overlay_enable',"false")


def retroarch_fbneo_crt_shader_on():
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_shader_enable','true')
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_smooth',"false")


def retroarch_fbneo_crt_shader_off():
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_shader_enable',"false")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('fbneo.cfg','FinalBurn,Neo','video_smooth',"true")



def retroarch_segacd_set_config():
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")


def retroarch_segacd_bezel_on():
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX', 'input_overlay' ,f"{retroarch_overlays_path}/pegasus/segacd.cfg")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','aspect_ratio_index',"0")

    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX', 'input_overlay',f"{retroarch_overlays_path}/pegasus/segacd.cfg")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','aspect_ratio_index',"0")

def retroarch_segacd_bezel_off():
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','input_overlay_enable',"false")
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','input_overlay_enable',"false")


def retroarch_segacd_crt_shader_on():
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','video_shader_enable',"true")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','video_shader_enable',"true")


def retroarch_segacd_crt_shader_off():
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','video_shader_enable',"false")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','video_shader_enable',"false")



def retroarch_segacd_ar32():
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','aspect_ratio_index',"7")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','aspect_ratio_index',"7")
    retroarch_segacd_bezel_off

def retroarch_segacd_ar43():
    retroarch_set_core_setting('segacd.cfg','Genesis Plus GX','aspect_ratio_index',"21")
    retroarch_set_core_setting('megacd.cfg','Genesis Plus GX','aspect_ratio_index',"21")


def retroarch_genesis_set_config():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")


def retroarch_genesis_bezel_on():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX', 'input_overlay',f"{retroarch_overlays_path}/pegasus/genesis.cfg")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','aspect_ratio_index',"0")

    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX', 'input_overlay',f"{retroarch_overlays_path}/pegasus/genesis.cfg")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','aspect_ratio_index',"0")



def retroarch_genesis_bezel_off():
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','input_overlay_enable',"false")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','input_overlay_enable',"false")


def retroarch_genesis_ar32():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','aspect_ratio_index',"7")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','aspect_ratio_index',"7")
    retroarch_genesis_bezel_off


def retroarch_genesis_ar43():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','aspect_ratio_index',"21")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','aspect_ratio_index',"21")


def retroarch_genesis_crt_shader_on():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_shader_enable',"true")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_smooth',"false")

    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_shader_enable',"true")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_smooth',"false")


def retroarch_genesis_crt_shader_off():
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_shader_enable',"false")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('genesis.cfg','Genesis Plus GX','video_smooth',"true")

    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_shader_enable',"false")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('megadrive.cfg','Genesis Plus GX','video_smooth',"true")


def retroarch_gamegear_set_config():
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_player1_analog_dpad_mode',"1")


def retroarch_gamegear_bezel_on():
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','aspect_ratio_index',"21")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX', 'input_overlay',f"{retroarch_overlays_path}/pegasus/gg.cfg")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_overlay_aspect_adjust_landscape',"-0.115000")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.545000")

    retroarch_set_core_setting('gamegear.cfg','Gearsystem','aspect_ratio_index',"21")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay',f"{retroarch_overlays_path}/pegasus/gg.cfg")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay_aspect_adjust_landscape',"-0.115000")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay_enable',"true")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay_scale_landscape',"1.545000")


def retroarch_gamegear_bezel_off():
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','input_overlay_enable',"false")

    retroarch_set_core_setting('gamegear.cfg','Gearsystem','input_overlay_enable',"false")


def retroarch_gamegear_matrix_shader_on():
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_shader_enable',"true")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_smooth',"false")

    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_shader_enable',"true")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_smooth',"false")


def retroarch_gamegear_matrix_shader_off():
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_shader_enable',"false")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gamegear.cfg','Genesis Plus GX','video_smooth',"true")

    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_shader_enable',"false")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gamegear.cfg','Gearsystem','video_smooth',"true")


def retroarch_mastersystem_set_config():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','input_player1_analog_dpad_mode',"1")


def retroarch_mastersystem_bezel_on():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','aspect_ratio_index',"21")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX', 'input_overlay',f"{retroarch_overlays_path}/pegasus/mastersystem.cfg")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','input_overlay_enable',"true")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','input_overlay_scale_landscape',"1.170000")


def retroarch_mastersystem_bezel_off():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','input_overlay_enable',"false")


def retroarch_mastersystem_ar32():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','aspect_ratio_index',"7")
    retroarch_mastersystem_bezel_off


def retroarch_mastersystem_crt_shader_on():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_shader_enable',"true")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_smooth',"false")


def retroarch_mastersystem_crt_shader_off():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_shader_enable',"false")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','video_smooth',"true")


def retroarch_mastersystem_ar43():
    retroarch_set_core_setting('mastersystem.cfg','Genesis Plus GX','aspect_ratio_index',"21")

def retroarch_sega32x_set_config():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_player1_analog_dpad_mode',"1")

def retroarch_sega32x_bezel_on():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay',f"{retroarch_overlays_path}/pegasus/sega32x.cfg")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_enable',"true")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_aspect_adjust_landscape',"0.095000")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','aspect_ratio_index',"0")

    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay',f"{retroarch_overlays_path}/pegasus/sega32x.cfg")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_enable',"true")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_hide_in_menu',"false")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_aspect_adjust_landscape',"0.095000")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','aspect_ratio_index',"0")


def retroarch_sega32x_bezel_off():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','input_overlay_enable',"false")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','input_overlay_enable',"false")


def retroarch_sega32x_crt_shader_on():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','video_shader_enable',"true")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('sega32x.cfg','PicoDrive'	,'video_smooth',"false")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','video_shader_enable',"true")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive'	,'video_smooth',"false")


def retroarch_sega32x_crt_shader_off():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','video_shader_enable',"false")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('sega32x.cfg','PicoDrive'	,'video_smooth',"true")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','video_shader_enable',"false")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive'	,'video_smooth',"true")


def retroarch_sega32x_ar32():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','aspect_ratio_index',"7")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','aspect_ratio_index',"7")
    retroarch_sega32x_bezel_off


def retroarch_sega32x_ar43():
    retroarch_set_core_setting('sega32x.cfg','PicoDrive','aspect_ratio_index',"21")
    retroarch_set_core_setting('sega32xna.cfg','PicoDrive','aspect_ratio_index',"21")
    retroarch_sega32x_bezel_off


#def retroarch_gba_bezel_on():
#	#missing stuff?
#	retroarch_set_core_setting('gba.cfg','mGBA','aspect_ratio_index',"21")
#
def retroarch_gba_set_config():
    retroarch_set_core_setting('gba.cfg','mGBA','input_player1_analog_dpad_mode',"1")

def retroarch_gba_matrix_shader_on():
    retroarch_set_core_setting('gba.cfg','mGBA','video_shader_enable',"true")
    retroarch_set_core_setting('gba.cfg','mGBA'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gba.cfg','mGBA'	,'video_smooth',"false")


def retroarch_gba_matrix_shader_off():
    retroarch_set_core_setting('gba.cfg','mGBA','video_shader_enable',"false")
    retroarch_set_core_setting('gba.cfg','mGBA'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gba.cfg','mGBA'	,'video_smooth',"true")


def retroarch_gb_bezel_on():
    retroarch_set_core_setting('gb.cfg','SameBoy','aspect_ratio_index',"21")
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay',f"{retroarch_overlays_path}/pegasus/gb.cfg")
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay_enable',"true")
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay_scale_landscape',"1.860000")
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay_y_offset_landscape',"-0.150000")

    retroarch_set_core_setting('gb.cfg','Gambatte','aspect_ratio_index',"21")
    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay',f"{retroarch_overlays_path}/pegasus/gb.cfg")
    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay_enable',"true")
    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay_scale_landscape',"1.860000")
    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay_y_offset_landscape',"-0.150000")


def retroarch_gb_set_config():
    retroarch_set_core_setting('gb.cfg','Gambatte','input_player1_analog_dpad_mode',"1")


def retroarch_gb_bezel_off():
    retroarch_set_core_setting('gb.cfg','SameBoy','input_overlay_enable',"false")


    retroarch_set_core_setting('gb.cfg','Gambatte','input_overlay_enable',"false")


def retroarch_gb_matrix_shader_on():
    retroarch_set_core_setting('gb.cfg','SameBoy','video_shader_enable','true')
    retroarch_set_core_setting('gb.cfg','SameBoy'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gb.cfg','SameBoy'	,'video_smooth',"false")

    retroarch_set_core_setting('gb.cfg','Gambatte','video_shader_enable',"true")
    retroarch_set_core_setting('gb.cfg','Gambatte'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gb.cfg','Gambatte'	,'video_smooth',"false")


def retroarch_gb_matrix_shader_off():
    retroarch_set_core_setting('gb.cfg','SameBoy','video_shader_enable','false')
    retroarch_set_core_setting('gb.cfg','SameBoy'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gb.cfg','SameBoy'	,'video_smooth',"true")

    retroarch_set_core_setting('gb.cfg','Gambatte','video_shader_enable',"false")
    retroarch_set_core_setting('gb.cfg','Gambatte'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gb.cfg','Gambatte'	,'video_smooth',"true")


def retroarch_SameBoy_gbc_set_config():
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('gbc.cfg','SameBoy','gambatte_gbc_color_correction',"GBC")
    retroarch_set_core_setting('gbc.cfg','SameBoy','gambatte_gbc_color_correction_mode',"accurate")
    retroarch_set_core_setting('gbc.cfg','SameBoy','gambatte_gbc_frontlight_position',"central")



def retroarch_gbc_set_config():
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_player1_analog_dpad_mode',"1")


def retroarch_gbc_bezel_on():
    retroarch_set_core_setting('gbc.cfg','SameBoy','aspect_ratio_index',"21")
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay',f"{retroarch_overlays_path}/pegasus/gbc.cfg")
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay_enable',"true")
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay_scale_landscape',"1.870000")
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay_y_offset_landscape',"-0.220000")

    retroarch_set_core_setting('gbc.cfg','Gambatte','aspect_ratio_index',"21")
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay',f"{retroarch_overlays_path}/pegasus/gbc.cfg")
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay_enable',"true")
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay_scale_landscape',"1.870000")
    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay_y_offset_landscape',"-0.220000")


def retroarch_gbc_bezel_off():
    retroarch_set_core_setting('gbc.cfg','SameBoy','input_overlay_enable',"false")


    retroarch_set_core_setting('gbc.cfg','Gambatte','input_overlay_enable',"false")


def retroarch_gbc_matrix_shader_on():
    retroarch_set_core_setting('gbc.cfg','SameBoy','video_shader_enable','true')
    retroarch_set_core_setting('gbc.cfg','SameBoy'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gbc.cfg','SameBoy'	,'video_smooth',"false")

    retroarch_set_core_setting('gbc.cfg','Gambatte','video_shader_enable','true')
    retroarch_set_core_setting('gbc.cfg','Gambatte'	,'video_filter','ED_RM_LINE')
    retroarch_set_core_setting('gbc.cfg','Gambatte'	,'video_smooth',"false")


def retroarch_gbc_matrix_shader_off():
    retroarch_set_core_setting('gbc.cfg','SameBoy','video_shader_enable','false')
    retroarch_set_core_setting('gbc.cfg','SameBoy'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gbc.cfg','SameBoy'	,'video_smooth',"true")

    retroarch_set_core_setting('gbc.cfg','Gambatte','video_shader_enable','false')
    retroarch_set_core_setting('gbc.cfg','Gambatte'	,'video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('gbc.cfg','Gambatte'	,'video_smooth',"true")


def retroarch_n64_wideScreenOn():
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-aspect',"16:9 adjusted")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','aspect_ratio_index',"1")
    retroarch_n64_bezel_off
    retroarch_n64_3d_crt_shader_off


def retroarch_n64_wideScreenOff():
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-aspect',"4:3")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','aspect_ratio_index',"0")
    #retroarch_n64_bezel_on


def retroarch_n64_bezel_on():
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','aspect_ratio_index',"0")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay',f"{retroarch_overlays_path}/pegasus/N64.cfg")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay_aspect_adjust_landscape',"0.085000")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay_enable',"true")
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay_scale_landscape',"1.065000")


def retroarch_n64_bezel_off():
    retroarch_set_core_setting('n64.cfg','Mupen64Plus-Next','input_overlay_enable',"false")


def retroarch_atari800_set_config():
    retroarch_set_core_setting('atari800.cfg','Stella','input_player1_analog_dpad_mode',"1")


def retroarch_atari800_bezel_on():
    retroarch_set_core_setting('atari800.cfg','Stella','aspect_ratio_index',"0")
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay',f"{retroarch_overlays_path}/pegasus/atari800.cfg")
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay_enable',"true")
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay_hide_in_menu',"true")
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay_scale_landscape',"1.175000")
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay_aspect_adjust_landscape',"0.000000")


def retroarch_atari800_bezel_off():
    retroarch_set_core_setting('atari800.cfg','Stella','input_overlay_enable',"false")


def retroarch_atari5200_set_config():
    retroarch_set_core_setting('atari5200.cfg','Stella','input_player1_analog_dpad_mode',"1")


def retroarch_atari5200_bezel_on():
    retroarch_set_core_setting('atari5200.cfg','Stella','aspect_ratio_index',"0")
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay',f"{retroarch_overlays_path}/pegasus/atari5200.cfg")
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay_enable',"true")
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay_hide_in_menu',"true")
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay_scale_landscape',"1.175000")
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay_aspect_adjust_landscape',"0.000000")


def retroarch_atari5200_bezel_off():
    retroarch_set_core_setting('atari5200.cfg','Stella','input_overlay_enable',"false")


def retroarch_dreamcast_bezel_on():
    retroarch_set_core_setting('dreamcast.cfg','Flycast','aspect_ratio_index',"0")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','input_overlay',f"{retroarch_overlays_path}/pegasus/Dreamcast.cfg")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','input_overlay_aspect_adjust_landscape',"0.110000")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','input_overlay_enable',"true")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','input_overlay_scale_landscape',"1.054998")


def retroarch_dreamcast_bezel_off():
    retroarch_set_core_setting('dreamcast.cfg','Flycast','input_overlay_enable',"false")


#temporary
def retroarch_Flycast_bezel_off():
    retroarch_dreamcast_bezel_off


def retroarch_Flycast_bezel_on():
    retroarch_dreamcast_bezel_on


def retroarch_Beetle_PSX_HW_bezel_off():
    retroarch_psx_bezel_off


def retroarch_Beetle_PSX_HW_bezel_on():
    retroarch_psx_bezel_on


def retroarch_dreamcast_3d_crt_shader_on():
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_shader_enable',"true")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_smooth','ED_RM_LINE')


def retroarch_dreamcast_set_config():
    retroarch_dreamcast_3d_crt_shader_off()


def retroarch_dreamcast_3d_crt_shader_off():
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_shader_enable',"false")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('dreamcast.cfg','Flycast','video_smooth','ED_RM_LINE')


def retroarch_saturn_set_config():
    Path(f"{bios_path}/kronos").mkdir(parents=True, exist_ok=True)
    retroarch_set_core_setting('saturn.cfg','Yabause','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','input_player1_analog_dpad_mode',"1")
    retroarch_saturn_3d_crt_shader_off()


def retroarch_saturn_bezel_on():
    retroarch_set_core_setting('saturn.cfg','Yabause','aspect_ratio_index',"0")
    retroarch_set_core_setting('saturn.cfg','Yabause','input_overlay',f"{retroarch_overlays_path}/pegasus/saturn.cfg")
    retroarch_set_core_setting('saturn.cfg','Yabause','input_overlay_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Yabause','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('saturn.cfg','Yabause','input_overlay_aspect_adjust_landscape',"0.095000")

    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','aspect_ratio_index',"0")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_overlay',f"{retroarch_overlays_path}/pegasus/saturn.cfg")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_overlay_enable',"true")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_overlay_aspect_adjust_landscape',"0.095000")


    retroarch_set_core_setting('saturn.cfg','Kronos','aspect_ratio_index',"0")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_overlay',f"{retroarch_overlays_path}/pegasus/saturn.cfg")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_overlay_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_overlay_aspect_adjust_landscape',"0.095000")

    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','aspect_ratio_index',"0")
    retroarch_set_core_setting('saturn.cfg','Beetle,Saturn', 'input_overlay',f"{retroarch_overlays_path}/pegasus/saturn.cfg")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','input_overlay_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','input_overlay_scale_landscape',"1.070000")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','input_overlay_aspect_adjust_landscape',"0.095000")


def retroarch_saturn_bezel_off():
    retroarch_set_core_setting('saturn.cfg','Yabause','input_overlay_enable',"false")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','input_overlay_enable',"false")
    retroarch_set_core_setting('saturn.cfg','Kronos','input_overlay_enable',"false")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','input_overlay_enable',"false")


def retroarch_saturn_3d_crt_shader_on():
    retroarch_set_core_setting('saturn.cfg','Yabause','video_shader_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Yabause','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Yabause','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_shader_enable',"true")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','Kronos','video_shader_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Kronos','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Kronos','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','video_shader_enable',"true")
    retroarch_set_core_setting('saturn.cfg','Beetle,Saturn','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Beetle,Saturn','video_smooth','ED_RM_LINE')


def retroarch_saturn_3d_crt_shader_off():
    retroarch_set_core_setting('saturn.cfg','Yabause','video_shader_enable',"false")
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_shader_enable',"false")
    retroarch_set_core_setting('saturn.cfg','Kronos','video_shader_enable',"false")
    retroarch_set_core_setting('saturn.cfg','Beetle Saturn','video_shader_enable',"false")

    retroarch_set_core_setting('saturn.cfg','Yabause','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Yabause','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','YabaSanshiro','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','Kronos','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Kronos','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('saturn.cfg','Beetle,Saturn','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('saturn.cfg','Beetle,Saturn','video_smooth','ED_RM_LINE')


def retroarch_snes_set_config():
    retroarch_set_core_setting('snes.cfg','Snes9x','input_player1_analog_dpad_mode',"1")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_player1_analog_dpad_mode',"1")


def retroarch_snes_bezel_on():
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes.cfg")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_enable',"true")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_opacity',"0.700000")
    retroarch_set_core_setting('snes.cfg','Snes9x','video_scale_integer',"false")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes.cfg")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_auto_scale',"false")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_enable',"true")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_opacity',"0.700000")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_scale_integer',"false")

    if settings.ar.snes == "87":
        retroarch_snes_ar87()
    elif settings.ar.snes == "32":
        retroarch_snes_ar32()
    else:
        retroarch_snes_ar43()


def retroarch_snes_bezel_off():
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_enable',"false")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_enable',"false")


def retroarch_snes_crt_shader_on():
    retroarch_set_core_setting('snes.cfg','Snes9x','video_shader_enable',"true")
    retroarch_set_core_setting('snes.cfg','Snes9x','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('snes.cfg','Snes9x','video_smooth',"false")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_shader_enable',"true")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_smooth',"false")


def retroarch_snes_crt_shader_off():
    retroarch_set_core_setting('snes.cfg','Snes9x','video_shader_enable',"false")
    retroarch_set_core_setting('snes.cfg','Snes9x','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('snes.cfg','Snes9x','video_smooth',"true")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_shader_enable',"false")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_filter',f"{retroarch_video_path}/Normal4x.filt")
    retroarch_set_core_setting('snesna.cfg','Snes9x','video_smooth',"true")


def retroarch_snes_ar43():
    retroarch_set_core_setting('snes.cfg','Snes9x','aspect_ratio_index',"0")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_aspect_adjust_landscape',"0")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes.cfg")
    retroarch_set_core_setting('snesna.cfg','Snes9x','aspect_ratio_index',"0")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_scale_landscape',"1.170000")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_aspect_adjust_landscape',"0")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes.cfg")


def retroarch_snes_ar87():
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes87.cfg")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_scale_landscape',"1.380000")
    retroarch_set_core_setting('snes.cfg','Snes9x','input_overlay_aspect_adjust_landscape',"-0.170000")
    retroarch_set_core_setting('snes.cfg','Snes9x','aspect_ratio_index',"15")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay',f"{retroarch_overlays_path}/pegasus/snes87.cfg")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_scale_landscape',"1.380000")
    retroarch_set_core_setting('snesna.cfg','Snes9x','input_overlay_aspect_adjust_landscape',"-0.170000")
    retroarch_set_core_setting('snesna.cfg','Snes9x','aspect_ratio_index',"15")


def retroarch_snes_ar32():
    retroarch_set_core_setting('snes.cfg','Snes9x','aspect_ratio_index',"7")
    retroarch_set_core_setting('snesna.cfg','Snes9x','aspect_ratio_index',"7")
    retroarch_snes_bezel_off



#def retroarch_bsnes_hd_beta_bezel_on():
# 	retroarch_set_core_setting('sneshd.cfg','bsnes-hd beta','video_scale_integer',"false")
#

def retroarch_melonds_setup_core_opt():
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_audio_bitrate',"Automatic")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_audio_interpolation',"None")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_boot_directly',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_console_mode',"DS")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_dsi_sdcard',"disabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_hybrid_ratio',"2")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_hybrid_small_screen',"Duplicate")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_jit_block_size',"32")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_jit_branch_optimisations',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_jit_enable',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_jit_fast_memory',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_jit_literal_optimisations',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_opengl_better_polygons',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_opengl_filtering',"nearest")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_opengl_renderer',"enabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_opengl_resolution',"5x native (1280x960)")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_randomize_mac_address',"disabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_screen_gap',"0")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_screen_layout',"Hybrid Bottom")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_swapscreen_mode',"Toggle")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_threaded_renderer',"disabled")
    retroarch_set_core_setting('melonDS.opt','melonDS','melonds_touch_mode',"Touch")


def retroarch_melonds_set_config():
    retroarch_set_core_setting('nds.cfg','melonDS','rewind_enable',"false")


def retroarch_melondsds_setup_core_opt():
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_audio_bitdepth',"auto")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_audio_interpolation',"disabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_boot_mode',"disabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS,DS','melonds_console_mode',"ds")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_dsi_sdcard',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_hybrid_ratio',"2")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_hybrid_small_screen',"both")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_jit_block_size',"32")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_jit_branch_optimisations',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_jit_enable',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_jit_fast_memory',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_jit_literal_optimisations',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_opengl_better_polygons',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_opengl_filtering',"nearest")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_render_mode',"software")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_opengl_resolution',"5")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_show_mic_state',"disabled")
#	Unsupported in melonDSDS at this time.
#	retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_randomize_mac_address',"disabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_gap',"0")
#	No equivalent in melonDSDS at this time.
#	retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout',"Hybrid Bottom")
#	No equivalent in melonDSDS at this time.
#	retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_swapscreen_mode',"Toggle")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_threaded_renderer',"enabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_touch_mode',"auto")
    # Screen layouts
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_show_current_layout',"disabled")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_number_of_screen_layouts ',"8")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout1',"hybrid-top")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout2',"hybrid-bottom")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout3',"top")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout4',"bottom")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout5',"top-bottom")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout6',"left-right")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout7',"bottom-top")
    retroarch_set_core_setting('melonDS DS.opt','melonDS DS','melonds_screen_layout8',"right-left")



def retroarch_melondsds_set_config():
    retroarch_set_core_setting('melonDS DS.cfg','melonDS DS','rewind_enable',"true")
    retroarch_set_core_setting('melonDS DS.cfg','melonDS DS','rewind_granularity',"6")


def retroarch_mupen64plus_next_setup_core_opt():
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-169screensize',"1920x1080")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-43screensize',"1280x960")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-alt-map',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-angrylion-multithread',"all threads")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-angrylion-overscan',"disabled")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-angrylion-sync',"Low")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-angrylion-vioverlay',"Filtered")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-aspect',"4:3")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-astick-deadzone',"15")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-astick-sensitivity',"100")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-BackgroundMode',"OnePiece")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-BilinearMode',"standard")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-CorrectTexrectCoords',"Auto")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-CountPerOp',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-CountPerOpDenomPot',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-cpucore',"dynamic_recompiler")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-d-cbutton',"C3")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-DitheringPattern',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-DitheringQuantization',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableCopyAuxToRDRAM',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableCopyColorToRDRAM',"Async")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableCopyDepthToRDRAM',"Software")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedHighResStorage',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedTextureStorage',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableFBEmulation',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableFragmentDepthWrite',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableHiResAltCRC',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableHWLighting',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableInaccurateTextureCoordinates',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableLegacyBlending',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableLODEmulation',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableN64DepthCompare',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableNativeResFactor',"4")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableNativeResTexrects',"Optimized")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableOverscan',"Enabled")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableShadersStorage',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableTexCoordBounds',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableTextureCache',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-ForceDisableExtraMem',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-FrameDuping',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-Framerate',"Fullspeed")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-FXAA',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-GLideN64IniBehaviour',"late")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-HybridFilter',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-IgnoreTLBExceptions',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-l-cbutton',"C2")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-MaxHiResTxVramLimit',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-MaxTxCacheSize',"8000")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-MultiSampling',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-OverscanBottom',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-OverscanLeft',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-OverscanRight',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-OverscanTop',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-pak1',"memory")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-pak2',"none")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-pak3',"none")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-pak4',"none")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-deinterlace-method',"Bob")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-dither-filter',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-divot-filter',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-downscaling',"disable")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-gamma-dither',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-native-tex-rect',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-native-texture-lod',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-overscan',"0")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-super-sampled-read-back',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-super-sampled-read-back-dither',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-synchronous',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-upscaling',"1x")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-vi-aa',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-parallel-rdp-vi-bilinear',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-r-cbutton',"C1")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-rdp-plugin',"gliden64")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-RDRAMImageDitheringMode',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-rsp-plugin',"hle")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-ThreadedRenderer',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txEnhancementMode',"As Is")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txFilterIgnoreBG',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txFilterMode',"None")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresEnable',"True")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresFullAlphaChannel',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-u-cbutton',"C4")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-virefresh',"Auto")

    # hd pack settings
    # Commenting these out. These seem to be causing a lot of graphical issues.
    #retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresEnable',"True")
    #retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresFullAlphaChannel',"True")
    #retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txCacheCompression',"True")
    #retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedHighResStorage',"True")
    #retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedTextureStorage',"False") # lazy loading

    # revert hd pack settings
    # These seem to be causing a lot of graphical issues.
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresEnable',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txHiresFullAlphaChannel',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-txCacheCompression',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedHighResStorage',"False")
    retroarch_set_core_setting('Mupen64Plus-Next.opt','Mupen64Plus-Next','mupen64plus-EnableEnhancedTextureStorage',"False") # lazy loading



def retroarch_Beetle_PSX_HW_setup_core_opt():
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_adaptive_smoothing',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_analog_calibration',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_analog_toggle',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_aspect_ratio',"corrected")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_cd_access_method',"sync")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_cd_fastload',"2x(native)")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_core_timing_fps',"force_progressive")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_cpu_dynarec',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_cpu_freq_scale',"100%(native)")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_crop_overscan',"smart")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_crosshair_color_p1',"red")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_crosshair_color_p2',"blue")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_depth',"16bpp(native)")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_display_internal_fps',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_display_vram',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_dither_mode',"1x(native)")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_dump_textures',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_dynarec_eventcycles',"128")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_dynarec_invalidate',"full")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_enable_memcard1',"enabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_enable_multitap_port1',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_enable_multitap_port2',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_filter',"nearest")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_filter_exclude_2d_polygon',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_filter_exclude_sprite',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_frame_duping',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_gpu_overclock',"1x(native)")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_gte_overclock',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_gun_cursor',"cross")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_gun_input_mode',"lightgun")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_image_crop',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_image_offset',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_image_offset_cycles',"0")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_initial_scanline',"0")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_initial_scanline_pal',"0")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_internal_resolution',"2x")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_last_scanline',"239")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_last_scanline_pal',"287")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_line_render',"default")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_mdec_yuv',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_memcard_left_index',"0")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_memcard_right_index',"1")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_mouse_sensitivity',"100%")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_msaa',"1x")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_negcon_deadzone',"0%")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_negcon_response',"linear")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_override_bios',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pal_video_timing_override',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pgxp_2d_tol',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pgxp_mode',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pgxp_nclip',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pgxp_texture',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_pgxp_vertex',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_renderer',"hardware")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_renderer_software_fb',"enabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_replace_textures',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_scaled_uv_offset',"enabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_shared_memory_cards',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_skip_bios',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_super_sampling',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_track_textures',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_use_mednafen_memcard0_method',"libretro")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_widescreen_hack',"disabled")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_widescreen_hack_aspect_ratio',"16:9")
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_wireframe',"disabled")


def retroarch_Flycast_setup_core_opt():
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_allow_service_buttons',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_alpha_sorting',"per-triangle (normal)")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_analog_stick_deadzone',"15%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_anisotropic_filtering',"4")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_auto_skip_frame',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_boot_to_bios',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_broadcast',"NTSC")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_cable_type',"TV")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_custom_textures',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_delay_frame_swapping',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_digital_triggers',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_dump_textures',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_enable_dsp',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_enable_purupuru',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_enable_rttb',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_fog',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_force_wince',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_frame_skipping',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_gdrom_fast_loading',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_hle_bios',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_internal_resolution',"960x720")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_language',"English")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_lightgun1_crosshair',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_lightgun2_crosshair',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_lightgun3_crosshair',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_lightgun4_crosshair',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_mipmapping',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_oit_abuffer_size',"512MB")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_per_content_vmus',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_pvr2_filtering',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_region',"USA")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_screen_rotation',"horizontal")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_show_lightgun_settings',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_show_vmu_screen_settings',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_texupscale',"1")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_texupscale_max_filtered_texture_size',"256")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_threaded_rendering',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_trigger_deadzone',"0%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_pixel_off_color',"DEFAULT_OFF 01")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_pixel_on_color',"DEFAULT_ON 00")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_screen_display',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_screen_opacity',"100%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_screen_position',"Upper Left")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu1_screen_size_mult',"1x")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_pixel_off_color',"DEFAULT_OFF 01")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_pixel_on_color',"DEFAULT_ON 00")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_screen_display',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_screen_opacity',"100%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_screen_position',"Upper Left")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu2_screen_size_mult',"1x")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_pixel_off_color',"DEFAULT_OFF 01")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_pixel_on_color',"DEFAULT_ON 00")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_screen_display',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_screen_opacity',"100%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_screen_position',"Upper Left")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu3_screen_size_mult',"1x")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_pixel_off_color',"DEFAULT_OFF 01")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_pixel_on_color',"DEFAULT_ON 00")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_screen_display',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_screen_opacity',"100%")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_screen_position',"Upper Left")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_vmu4_screen_size_mult',"1x")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_volume_modifier_enable',"enabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_widescreen_cheats',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_widescreen_hack',"disabled")


def retroarch_Gambatte_setup_core_opt():
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_audio_resampler',"sinc")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_dark_filter_level',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_bootloader',"enabled")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_colorization',"auto")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_hwmode',"Auto")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_internal_palette',"GB - DMG")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_mode',"Not Connected")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_port',"56400")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_1',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_10',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_11',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_12',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_2',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_3',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_4',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_5',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_6',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_7',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_8',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_link_network_server_ip_9',"0")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_palette_pixelshift_1',"PixelShift 01 - Arctic Green")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_palette_twb64_1',"WB64 001 - Aqours Blue")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gb_palette_twb64_2',"TWB64 101 - 765PRO Pink")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gbc_color_correction',"GBC only")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gbc_color_correction_mode',"accurate")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_gbc_frontlight_position',"central")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_mix_frames',"disabled")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_rumble_level',"10")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_show_gb_link_settings',"disabled")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_turbo_period',"4")
    retroarch_set_core_setting('Gambatte.opt','Gambatte','gambatte_up_down_allowed',"disabled")


def retroarch_Nestopia_setup_core_opt():
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_arkanoid_device',"mouse")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_aspect',"auto")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_dpcm',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_fds',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_mmc5',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_n163',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_noise',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_s5b',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_sq1',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_sq2',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_tri',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_vrc6',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_audio_vol_vrc7',"100")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_blargg_ntsc_filter',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_button_shift',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_favored_system',"auto")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_fds_auto_insert',"enabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_genie_distortion',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_nospritelimit',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_overclock',"1x")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_overscan_h',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_overscan_v',"enabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_palette',"cxa2025as")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_ram_power_state',"0x00")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_select_adapter',"auto")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_show_advanced_av_settings',"disabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_show_crosshair',"enabled")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_turbo_pulse',"2")
    retroarch_set_core_setting('Nestopia.opt','Nestopia','nestopia_zapper_device',"lightgun")

def retroarch_bsnes_hd_beta_setup_core_opt():
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_blur_emulation',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_coprocessor_delayed_sync',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_coprocessor_prefer_hle',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_cpu_fastmath',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_cpu_overclock',"100")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_cpu_sa1_overclock',"100")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_cpu_sfx_overclock',"100")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_dsp_cubic',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_dsp_echo_shadow',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_dsp_fast',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_entropy',"Low")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_hotfixes',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ips_headered',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_bgGrad',"4")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_igwin',"outside")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_igwinx',"128")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_mosaic',"1x scale")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_perspective',"on")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_scale',"1x")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_strWin',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_supersample',"none")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_widescreen',"16:10")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_windRad',"0")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsbg1',"auto horz and vert")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsbg2',"auto horz and vert")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsbg3',"auto horz and vert")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsbg4',"auto horz and vert")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsBgCol',"auto")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsMarker',"none")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsMarkerAlpha',"1/1")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsMode',"all")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_mode7_wsobj',"safe")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ppu_deinterlace',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ppu_fast',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ppu_no_sprite_limit',"ON")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ppu_no_vram_blocking',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_ppu_show_overscan',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_run_ahead_frames',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_sgb_bios',"SGB1.sfc")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_video_aspectcorrection',"OFF")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_video_gamma',"100")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_video_luminance',"100")
    retroarch_set_core_setting('bsnes-hd beta.opt','bsnes-hd beta','bsnes_video_saturation',"100")


def retroarch_dos_box_setup_core_opt():
    retroarch_set_core_setting('DOSBox-pure.opt','DOSBox-pure','dosbox_pure_conf',"inside")



def retroarch_Flycast_wideScreenOn():
    retroarch_set_core_setting('Flycast.opt',	'Flycast',	'reicast_widescreen_cheats',	"enabled")
    retroarch_set_core_setting('Flycast.opt',	'Flycast',	'reicast_widescreen_hack',	"enabled")
    retroarch_set_core_setting('dreamcast.cfg',	'Flycast',	'aspect_ratio_index',		"1")
    retroarch_dreamcast_bezel_off
    retroarch_dreamcast_3d_crt_shader_off


def retroarch_Flycast_wideScreenOff():
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_widescreen_cheats',"disabled")
    retroarch_set_core_setting('Flycast.opt','Flycast','reicast_widescreen_hack',"disabled")
    retroarch_set_core_setting('dreamcast.cfg','Flycast','aspect_ratio_index',"0")


def retroarch_Beetle_PSX_HW_wideScreenOn():
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_widescreen_hack',"enabled")
    retroarch_set_core_setting('Beetle PSX.opt','Beetle PSX','beetle_psx_hw_widescreen_hack',"enabled")
    retroarch_psx_bezel_off


def retroarch_Beetle_PSX_HW_wideScreenOff():
    retroarch_set_core_setting('Beetle PSX HW.opt','Beetle PSX HW','beetle_psx_hw_widescreen_hack',"disabled")
    retroarch_set_core_setting('Beetle PSX.opt','Beetle PSX','beetle_psx_hw_widescreen_hack',"disabled")



def retroarch_SwanStation_set_config():
    retroarch_set_core_setting('SwanStation.opt','SwanStation','duckstation_GPU.ResolutionScale',"3")


def retroarch_SwanStation_wideScreenOn():
    retroarch_set_core_setting('SwanStation.opt','SwanStation','duckstation_GPU.WidescreenHack',"true")
    retroarch_set_core_setting('SwanStation.opt','SwanStation','duckstation_Display.AspectRatio',"16:9")
    retroarch_set_core_setting('psx.cfg','SwanStation','aspect_ratio_index',"1")
    retroarch_psx_bezel_off


def retroarch_SwanStation_wideScreenOff():
    retroarch_set_core_setting('SwanStation.opt','SwanStation','duckstation_GPU.WidescreenHack',"false")
    retroarch_set_core_setting('SwanStation.opt','SwanStation','duckstation_Display.AspectRatio',"auto")
    retroarch_set_core_setting('psx.cfg','SwanStation','aspect_ratio_index',"0")


def retroarch_psx_bezel_on():
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay_enable', "true")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','aspect_ratio_index', "0")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay', f"{retroarch_overlays_path}/pegasus/psx.cfg")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay_aspect_adjust_landscape', "0.100000")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay_enable', "true")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay_scale_landscape', "1.060000")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','input_overlay_enable',"true")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','aspect_ratio_index',"0")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','input_overlay',f"{retroarch_overlays_path}/pegasus/psx.cfg")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','input_overlay_aspect_adjust_landscape',"0.100000")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','input_overlay_enable',"true")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','input_overlay_scale_landscape',"1.060000")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay_enable',"true")
    retroarch_set_core_setting('psx.cfg','SwanStation','aspect_ratio_index',"0")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay',f"{retroarch_overlays_path}/pegasus/psx.cfg")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay_aspect_adjust_landscape',"0.100000")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay_enable',"true")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay_scale_landscape',"1.060000")



def retroarch_psx_bezel_off():
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','input_overlay_enable',"false")
    retroarch_set_core_setting('psx.cfg','Beetle PSX','input_overlay_enable',"false")
    retroarch_set_core_setting('psx.cfg','SwanStation','input_overlay_enable',"false")


def retroarch_psx_3d_crt_shader_on():
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_shader_enable','true')
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('psx.cfg','Beetle PSX','video_shader_enable','true')
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('psx.cfg','SwanStation','video_shader_enable','true')
    retroarch_set_core_setting('psx.cfg','SwanStation','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','SwanStation','video_smooth','ED_RM_LINE')


def retroarch_psx_3d_crt_shader_off():
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_shader_enable',"false")
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','Beetle PSX HW','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('psx.cfg','Beetle PSX','video_shader_enable',"false")
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','Beetle,PSX','video_smooth','ED_RM_LINE')

    retroarch_set_core_setting('psx.cfg','SwanStation','video_shader_enable',"false")
    retroarch_set_core_setting('psx.cfg','SwanStation','video_filter','ED_RM_LINE')
    retroarch_set_core_setting('psx.cfg','SwanStation','video_smooth','ED_RM_LINE')

def retroarch_psx_set_config():
    retroarch_psx_3d_crt_shader_off()


def retroarch_retroachievements_on():
    set_config("cheevos_enable", "true", retroarch_cfg_file)

    if settings.achievements.hardcore == False:
        retroarch_retroachievements_hardcore_off()
    else:
        retroarch_retroachievements_hardcore_on()

    #Mame fix
    #retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','cheevos_enable',"false")
    #retroarch_set_core_setting('mame.cfg','MAME','cheevos_enable',"false")

def retroarch_retroachievements_off():
    set_config("cheevos_enable", "false", retroarch_cfg_file)
    #Mame fix
    #retroarch_set_core_setting('mame.cfg','MAME 2003-Plus','cheevos_enable',"false")
    #retroarch_set_core_setting('mame.cfg','MAME','cheevos_enable',"false")


def retroarch_retroachievements_hardcore_on():
    set_config("cheevos_hardcore_mode_enable", true, retroarch_cfg_file)
    retroarch_set_core_setting('FinalBurn Neo.opt','FinalBurn Neo','fbneo-allow-patched-romsets',"disabled")


def retroarch_retroachievements_hardcore_off():
    set_config("cheevos_hardcore_mode_enable", false, retroarch_cfg_file)
    retroarch_set_core_setting('FinalBurn Neo.opt','FinalBurn Neo','fbneo-allow-patched-romsets',"enabled")

def retroarch_setup_core_opt_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj) and name.endswith('_setup_core_opt')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_set_config_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_set_config')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_bezel_on_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_bezel_on')
           and name != 'retroarch_bezel_on_all'
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_bezel_off_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_bezel_off')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_crt_shader_on_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_crt_shader_on')
           and 'bezel_on' not in name
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_crt_shader_off_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_crt_shader_off')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_3d_crt_shader_on_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_3d_crt_shader_on')
           and 'bezel_on' not in name
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_3d_crt_shader_off_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_3d_crt_shader_off')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_matrix_shaders_on_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_matrix_shader_on')
           and 'bezel_on' not in name
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()

def retroarch_matrix_shaders_off_all():
    funcs = [
        name for name, obj in globals().items()
        if inspect.isfunction(obj)
           and name.startswith('retroarch_')
           and name.endswith('_matrix_shader_off')
    ]
    for name in sorted(funcs):
        print(name)
        globals()[name]()



def retroarch_retroachievements_set_login():
    print("NYI")
    #set_config('cheevos_username',rau,retroarch_cfg_file)
    #set_config('cheevos_token',rat,retroarch_cfg_file)
    #retroarch_retroachievements_on()
    #setSetting cheevos_username $rau


def retroarch_set_bezels():
    if settings.bezels == True:
        retroarch_bezel_on_all()
    else:
        retroarch_bezel_off_all()

def retroarch_set_shaders_crt():
    if settings.shaders.classic == True:
        retroarch_crt_shader_on_all()
    else:
        retroarch_crt_shader_off_all()

def retroarch_set_shaders_3d_crt():
    if settings.shaders.classic3d == True:
        retroarch_3d_crt_shader_on_all()
    else:
        retroarch_3d_crt_shader_off_all()

def retroarch_set_shaders_matrix():
    if settings.shaders.handhelds == True:
        retroarch_matrix_shaders_on_all()
    else:
        retroarch_matrix_shaders_off_all()