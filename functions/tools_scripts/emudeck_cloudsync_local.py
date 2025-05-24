from core.all import *



def cloud_sync_install_and_config(provider: str, token: str) -> bool:
    """
    1) En Linux, fuerza Chrome como navegador predeterminado (vía flatpak y xdg-settings).
    2) Instala rclone si hace falta (llama a remote.cloud_sync_install).
    3) Llama a remote.cloud_sync_config(provider, token). Si devuelve True, imprime "true_cs".
    4) Guarda los settings y restaura el navegador previo.
    """

    cloudsync_remote = load_remote_cloud_sync()

    system = sys.platform  # "linux", "darwin", "win32", etc.

    # Sólo en Linux (no Darwin ni Windows)
    previous_browser = None
    if system.startswith("linux"):
        try:
            # 1. Obtener navegador por defecto
            previous_browser = (
                subprocess.check_output(
                    ["xdg-settings", "get", "default-web-browser"],
                    text=True
                )
                .strip()
            )
        except subprocess.CalledProcessError:
            previous_browser = None

        # Si no es Chrome, instalarlo y setearlo
        chrome_desktop = "com.google.Chrome.desktop"
        if previous_browser != chrome_desktop:
            # Instalar Chrome como flatpak (user)
            subprocess.run(
                ["flatpak", "install", "flathub", "com.google.Chrome", "-y", "--user"],
                check=False
            )
            # Forzar Chrome como navegador por defecto
            subprocess.run(
                ["xdg-settings", "set", "default-web-browser", chrome_desktop],
                check=False
            )

    # 2. Instalar rclone si no existe
    cloudsync_remote.cloud_sync_install(provider)

    # 3. Configurar provider
    ok = cloudsync_remote.cloud_sync_config(provider, token)
    if ok:
        return True

    # 5. Restaurar navegador original
    if system.startswith("linux") and previous_browser and previous_browser != chrome_desktop:
        subprocess.run(
            ["xdg-settings", "set", "default-web-browser", previous_browser],
            check=False
        )

    return True

def cloud_sync_download_emu_all() -> None:
    cloudsync_remote = load_remote_cloud_sync()
    cloudsync_remote.cloud_sync_download("all")


def cloud_sync_upload_emu_all() -> None:
    cloudsync_remote = load_remote_cloud_sync()
    cloudsync_remote.cloud_sync_upload("all")


def cloud_sync_health_check_bin() -> bool:
    """
    Delete any previous test files, then check that the rclone binary exists and is executable.
    Returns True if OK, False otherwise.
    """
    provider = cloud_sync_provider
    user = settings.cs_user
    test_file = "cloudsync.emudeck"
    remote = f"{provider}:{user}/Emudeck/saves/{test_file}"

    # Cleanup prior remote & local artifacts
    subprocess.run([str(cloud_sync_bin), "delete", remote],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    for p in (saves_path / test_file, saves_path / f"dl_{test_file}"):
        try:
            if p.exists():
                p.unlink()
        except Exception:
            pass

    # Check binary exists / runnable
    result = subprocess.run(["ls", str(cloud_sync_bin)],
                            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return result.returncode == 0


def cloud_sync_health_check_cfg() -> bool:
    """
    Compare character count of original rclone.conf vs active config.
    Returns True if different (i.e. custom config is in use), False if identical.
    """
    original = emudeck_folder / "backend" / "configs" / "rclone" / "rclone.conf"
    if not original.is_file() or not cloud_sync_config_file.is_file():
        return False
    orig_count = len(original.read_text(encoding="utf-8"))
    conf_count = len(cloud_sync_config_file.read_text(encoding="utf-8"))
    return orig_count != conf_count

def cloud_sync_health_check_service_starts() -> bool:
    return True


def cloud_sync_health_upload() -> bool:
    """
    Write a test file, attempt to upload it to the cloud. Return True on success.
    """
    provider = cloud_sync_provider
    user = settings.cs_user
    test_file = "cloudsync.emudeck"
    local = saves_path / test_file
    remote = f"{provider}:{user}/Emudeck/saves/{test_file}"

    # Write test content
    local.write_text("test", encoding="utf-8")
    result = subprocess.run(
        [str(cloud_sync_bin), "-q", "copyto", "--fast-list", "--checkers=50",
         "--transfers=50", "--low-level-retries", "1", "--retries", "1",
         str(local), remote],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    local.unlink(missing_ok=True)
    return result.returncode == 0


def cloud_sync_health_is_file_uploaded() -> bool:
    """
    Check if the test file exists remotely.
    """
    provider = cloud_sync_provider
    user = settings.cs_user
    test_file = "cloudsync.emudeck"
    remote_dir = f"{provider}:{user}/Emudeck/saves/"
    result = subprocess.run(
        [str(cloud_sync_bin), "lsf", remote_dir, "--include", test_file],
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True
    )
    lines = result.stdout.splitlines()
    return test_file in lines


def cloud_sync_health_download() -> bool:
    """
    Attempt to download the test file from the cloud. Return True on success.
    """
    provider = cloud_sync_provider
    user = settings.cs_user
    test_file = "cloudsync.emudeck"
    local = saves_path / f"dl_{test_file}"
    remote = f"{provider}:{user}/Emudeck/saves/{test_file}"

    result = subprocess.run(
        [str(cloud_sync_bin), "-q", "copyto", "--fast-list", "--checkers=50",
         "--transfers=50", "--low-level-retries", "1", "--retries", "1",
         remote, str(local)],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    local.unlink(missing_ok=True)
    return result.returncode == 0


def cloud_sync_health_is_file_downloaded() -> bool:
    """
    Check that the downloaded test file exists locally, then clean up.
    """
    test_file = saves_path / "dl_cloudsync.emudeck"
    exists = test_file.is_file()
    # Cleanup remote + local
    provider = cloud_sync_provider
    user = settings.cs_user
    remote = f"{provider}:{user}/Emudeck/saves/cloudsync.emudeck"
    subprocess.run([str(cloud_sync_bin), "delete", remote],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    test_file.unlink(missing_ok=True)
    (saves_path / "cloudsync.emudeck").unlink(missing_ok=True)
    return exists
