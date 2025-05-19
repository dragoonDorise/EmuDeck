from core.all import *


def flycast_install():
    set_msg(f"Installing Flycast")

    if system == "linux":
        name="org.flycast.Flycast"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="flycast"
        type="zip"
        look_for="win64"
        destination = f"{emus_folder}/flycast"

    if system == "darwin":
        name="Flycast"
        type="zip"
        look_for="macOS"
        destination = f"{emus_folder}"

    try:
        repo=get_latest_release_gh("flyinghead/flycast",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def flycast_uninstall():
    try:
        if system == "linux":
            uninstall_emu("org.flycast.Flycast", "flatpak")
        if system.startswith("win"):
          uninstall_emu("flycast", "dir")
        if system == "darwin":
          uninstall_emu("Flycast", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def flycast_is_installed():
    if system == "linux":
        return is_flatpak_installed("org.flycast.Flycast")
    if system.startswith("win"):
      return (emus_folder / "flycast" / "flycast.exe").exists()
    if system == "darwin":
      return (emus_folder / "Flycast.app").exists()


def flycast_init():
    set_msg(f"Setting up flycast")
    if system == "linux":
        destination=f"{home}/.var/app/org.flycast.Flycast/config/flycast/"
        bios=f"{home}/.var/app/org.flycast.Flycast/data/flycast/"
    if system.startswith("win"):
        destination=f"{emus_folder}/flycast/"
        bios=""
    if system == "darwin":
        destination=f"{home}/Library/Application Support/flycast"
        bios=""

    copy_setting_dir(f"common/flycast/",destination)
    copy_and_set_settings_file(f"common/flycast/emu.cfg", destination)



   # move_contents_and_link(bios,f"{bios_path}/flycast")

    flycast_setup_saves()
    #flycast_setup_storage()
    flycast_set_resolution()
    flycast_set_controller_style()
    flycast_widescreen()

    esde_set_emu("Flycast (Standalone)","dreamcast")
    esde_set_emu("Flycast (Standalone)","naomi")
    esde_set_emu("Flycast (Standalone)","naomi2")
    flycast_add_custom_parser()

def flycast_install_init():
    flycast_install()
    flycast_init()


def flycast_add_custom_parser():
    if flycast_is_installed():
      add_parser("atomiswave_flycast")
      add_parser("naomi_flycast")
      add_parser("naomi2_flycast")
      add_parser("sega_dreamcast_flycast")


def flycast_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.var/app/org.flycast.Flycast/data/flycast/saves"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/flycast/saves"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/Flycast/saves"

    move_contents_and_link(origin_saves,f"{saves_path}/flycast/saves")


def flycast_set_resolution():
    print("NYI")

def flycast_set_abxy_style():
    print("NYI")

def flycast_set_bayx_style():
    print("NYI")

def flycast_set_controller_style():
    if settings.controllerLayout == "bayx":
        flycast_set_bayx_style()
    else:
        flycast_set_bayx_style()

def flycast_widescreen():
    if settings.ar.classic3d == "169":
        flycast_widescreen_on()
    else:
        flycast_widescreen_off()

def flycast_widescreen_on():
    if system == "linux":
        config_path=f"{home}/.var/app/org.flycast.Flycast/config/flycast/emu.cfg"
    if system.startswith("win"):
        config_path=f"{emus_folder}/flycast/emu.cfg"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/Flycast/emu.cfg"

    set_config("rend.WidescreenGameHacks ", " yes", config_path)
    set_config("rend.WideScreen ", " yes", config_path)

def flycast_widescreen_off():
    if system == "linux":
        config_path=f"{home}/.var/app/org.flycast.Flycast/config/flycast/emu.cfg"
    if system.startswith("win"):
        config_path=f"{emus_folder}/flycast/emu.cfg"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/Flycast/emu.cfg"

    set_config("rend.WidescreenGameHacks ", " no", config_path)
    set_config("rend.WideScreen ", " no", config_path)
