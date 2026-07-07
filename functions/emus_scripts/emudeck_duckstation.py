from core.all import *

def duckstation_install():
    set_msg(f"Installing DuckStation")

    if system == "linux":
        name="duckstation"
        type="AppImage"
        look_for="arm64.AppImage" if cpu_arch == "arm" else "x64.AppImage"
        destination = f"{emus_folder}"

    if system.startswith("win"):
        name="duckstation"
        type="zip"
        look_for="windows-x64-release.zip"
        destination = f"{emus_folder}/duckstation"

    if system == "darwin":
        name="DuckStation"
        type="zip"
        look_for="mac"
        destination = f"{emus_folder}"

    try:
        repo=get_latest_release_gh("stenzek/duckstation",type,look_for)
        install_emu(name, repo, type, destination)

        if system == "linux":
            flatpak_cfg = Path(f"{home}/.var/app/org.duckstation.DuckStation/config/duckstation")
            appimage_cfg = Path(f"{home}/.local/share/duckstation")
            if flatpak_cfg.is_dir() and not appimage_cfg.exists():
                appimage_cfg.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(flatpak_cfg), str(appimage_cfg))
            if is_flatpak_installed("org.duckstation.DuckStation"):
                subprocess.run(["flatpak", "uninstall", "org.duckstation.DuckStation", "-y"],
                               capture_output=True)
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def duckstation_uninstall():
    try:
        if system == "linux":
            uninstall_emu("duckstation", "AppImage")
        if system.startswith("win"):
          uninstall_emu("duckstation", "dir")
        if system == "darwin":
          uninstall_emu("DuckStation", "app")
        return True
    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False

def duckstation_is_installed():
    if system == "linux":
        return (emus_folder / "duckstation.AppImage").exists()
    if system.startswith("win"):
      return (emus_folder / "duckstation" / "duckstation-qt-x64-ReleaseLTCG.exe").exists()
    if system == "darwin":
      return (emus_folder / "DuckStation.app").exists()


def duckstation_init():
    set_msg(f"Setting up duckstation")
    if system == "linux":
        destination=f"{home}/.local/share/duckstation/"
    if system.startswith("win"):
        destination=f"{emus_folder}/duckstation/"
    if system == "darwin":
        destination=f"{home}/Library/Application Support/DuckStation"

    copy_setting_dir(f"common/duckstation/",destination)
    copy_and_set_settings_file(f"common/duckstation/settings.ini", destination)

    duckstation_setup_saves()
    #duckstation_setup_storage()
    duckstation_set_resolution()
    duckstation_set_controller_style()
    duckstation_widescreen()
    duckstation_retro_achievements()

def duckstation_install_init():
    duckstation_install()
    duckstation_init()


def duckstation_setup_saves():
    if system == "linux":
        origin_saves=f"{home}/.local/share/duckstation/memcards"
        origin_states=f"{home}/.local/share/duckstation/savestates"
    if system.startswith("win"):
        origin_saves=f"{emus_folder}/duckstation/memcards"
        origin_states=f"{emus_folder}/duckstation/savestates"
    if system == "darwin":
        origin_saves=f"{home}/Library/Application Support/DuckStation/memcards"
        origin_states=f"{home}/Library/Application Support/DuckStation/savestates"

    move_contents_and_link(origin_saves,f"{saves_path}/duckstation/saves")
    move_contents_and_link(origin_states,f"{saves_path}/duckstation/states")


def duckstation_set_resolution():
    print("NYI")

def duckstation_set_abxy_style():
    print("NYI")

def duckstation_set_bayx_style():
    print("NYI")

def duckstation_set_controller_style():
    if settings.controllerLayout == "bayx":
        duckstation_set_bayx_style()
    else:
        duckstation_set_bayx_style()

def duckstation_widescreen():
    if settings.ar.classic3d == "169":
        duckstation_widescreen_on()
    else:
        duckstation_widescreen_off()

def duckstation_widescreen_on():
    if system == "linux":
        config_path=f"{home}/.local/share/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    set_config("WidescreenHack ", " true", config_path)
    set_config("AspectRatio ", " 16:9", config_path)

def duckstation_widescreen_off():
    if system == "linux":
        config_path=f"{home}/.local/share/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    set_config("WidescreenHack ", " false", config_path)
    set_config("AspectRatio ", " 4:3", config_path)

def duckstation_encrypt_cheevos_token(token, username):
    """Cifra el token de logros igual que DuckStation (AES-128-CBC).
    Clave = SHA-256(machineKey + username) + 100 rondas. machineKey por plataforma:
      - Windows: portable -> sin machineKey (solo username)
      - Linux:   /etc/machine-id, leido TAL CUAL (incluido el \\n final)
      - macOS:   hardware UUID (gethostuuid) en hex, minusculas, sin guiones
    Clave con hashlib (puro), bloque AES con openssl. Verificado contra Win y Linux.
    """
    if not token or not username:
        return ""

    machine_key = b""
    if sys.platform.startswith("linux"):
        try:
            with open("/etc/machine-id", "rb") as f:
                machine_key = f.read()  # incluye el \n final, como hace DuckStation
        except Exception:
            machine_key = b""
    elif sys.platform == "darwin":
        try:
            out = subprocess.run(
                ["ioreg", "-rd1", "-c", "IOPlatformExpertDevice"],
                capture_output=True, text=True).stdout
            m = re.search(r'"IOPlatformUUID"\s*=\s*"([0-9A-Fa-f-]+)"', out)
            if m:
                machine_key = m.group(1).replace("-", "").lower().encode("utf-8")
        except Exception:
            machine_key = b""
    # Windows -> portable, sin machineKey

    key = hashlib.sha256(machine_key + username.encode("utf-8")).digest()
    for _ in range(100):
        key = hashlib.sha256(key).digest()
    aeskey, iv = key[:16], key[16:32]

    data = token.encode("utf-8")
    padlen = ((len(data) + 15) // 16) * 16 or 16
    data = data.ljust(padlen, b"\x00")
    try:
        p = subprocess.run(
            ["openssl", "enc", "-aes-128-cbc", "-nopad",
             "-K", aeskey.hex(), "-iv", iv.hex(), "-base64", "-A"],
            input=data, capture_output=True)
        return p.stdout.decode("utf-8").strip()
    except Exception:
        return ""

def duckstation_retro_achievements():
    if settings.achievements.user == '':
        duckstation_retro_achievements_off()
    else:
        duckstation_retro_achievements_on()
        
def duckstation_retro_achievements_on():
    if system == "linux":
        config_path=f"{home}/.local/share/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    enc_token = duckstation_encrypt_cheevos_token(achievements_token, achievements_user)
    set_ini_value(config_path, "Cheevos", "Username", f"{achievements_user}")
    set_ini_value(config_path, "Cheevos", "Token", enc_token)
    set_ini_value(config_path, "Cheevos", "LoginTimestamp", f"{int(time.time())}")
    set_ini_value(config_path, "Cheevos", "Enabled", "true")

    if achievements_hardcore:
        set_ini_value(config_path, "Cheevos", "ChallengeMode", "true")
    else:
        set_ini_value(config_path, "Cheevos", "ChallengeMode", "false")

def duckstation_retro_achievements_off():
    if system == "linux":
        config_path=f"{home}/.local/share/duckstation/settings.ini"
    if system.startswith("win"):
        config_path=f"{emus_folder}/duckstation/settings.ini"
    if system == "darwin":
        config_path=f"{home}/Library/Application Support/DuckStation/settings.ini"

    set_ini_value(config_path, "Cheevos", "Enabled", "false")
    set_ini_value(config_path, "Cheevos", "ChallengeMode", "false")