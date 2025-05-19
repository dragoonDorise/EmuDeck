from core.all import *


def melonds_install():
    set_msg(f"Installing melonds")

    if system == "linux":
        name="net.kuribo64.melonDS"
        type="flatpak"
        look_for=""
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="melonds"
        type="zip"
        look_for="windows"
        destination = f"{emus_folder}/melonds"

    if system == "darwin":
        return False

    try:
        repo=get_latest_release_gh("melonDS-emu/melonDS",type,look_for)
        install_emu(name, repo, type, destination)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def melonds_uninstall():
    try:
        if system == "linux":
            uninstall_emu("net.kuribo64.melonDS", "flatpak")
        if system.startswith("win"):
          uninstall_emu("melonds", "dir")
        if system == "darwin":
          uninstall_emu("melonds", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def melonds_is_installed():
    if system == "linux":
        return is_flatpak_installed("net.kuribo64.melonDS")
    if system.startswith("win"):
      return (emus_folder / "melonds" / "melonds.exe").exists()
    if system == "darwin":
      return (emus_folder / "melonds.app").exists()


def melonds_init():
    set_msg(f"Setting up melonds")
    if system == "linux":
        destination=f"{home}/.var/app/net.kuribo64.melonDS/config/melonDS/"
    if system.startswith("win"):
        destination=f"{emus_folder}/melonds/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/melonDS"

    copy_setting_dir(f"common/melonds/",destination)
    copy_and_set_settings_file(f"common/melonds/melonDS.ini", destination)

    # move_contents_and_link(bios,f"{bios_path}/melonds")

    #melonds_setup_saves()
    #melonds_setup_storage()
    melonds_set_resolution()
    melonds_set_controller_style()
    esde_set_emu("melonDS (Standalone)","nds")
    melonds_add_custom_parser()

def melonds_install_init():
    melonds_install()
    melonds_init()


def melonds_add_custom_parser():
   if melonds_is_installed():
      add_parser("nintendo_nds_melonds")



def melonds_setup_saves():
    print("NYI")


def melonds_set_resolution():
    if system == "linux":
      config_file=f"{home}/.var/app/net.kuribo64.melonDS/config/melonDS/melonDS.ini"
    if system.startswith("win"):
      config_file=f"{emus_folder}/melonds/melonDS.ini"
    if system == "darwin":
      config_file=f"{home}/Library/Application Support/melonDS/melonDS.ini"

    mapping = {
         "720P":  (1024,  768),
         "1080P": (1536, 1152),
         "1440P": (2048, 1536),
         "4K":    (2816, 2112),
     }
    dims = mapping.get(settings.resolutions.melonds)
    if dims is None:
      print(f"Error: unsupported resolution '{resolution}'")
      return False

    window_width, window_height = dims

    # Ensure the destination folder exists (if you need to copy defaults, etc.)
    dest_dir = emus_folder / "melonDS"
    dest_dir.mkdir(parents=True, exist_ok=True)

    # Update the two config keys
    set_config("WindowWidth",  window_width,  config_file)
    set_config("WindowHeight", window_height, config_file)

    return True

def melonds_set_abxy_style():
    print("NYI")

def melonds_set_bayx_style():
    print("NYI")

def melonds_set_controller_style():
    if settings.controllerLayout == "bayx":
        melonds_set_bayx_style()
    else:
        melonds_set_bayx_style()