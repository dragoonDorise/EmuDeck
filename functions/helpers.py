from core.all import *

def emudeck_init():
    for p in (emulation_path, roms_path, tools_path, bios_path, saves_path, storage_path, ESDEscrapData):
        if not p.exists():
            p.mkdir(parents=True, exist_ok=True)
    
    if not roms_path.exists() or not any(roms_path.iterdir()):
        shutil.copytree(f"{emudeck_backend}/configs/common/roms", roms_path, dirs_exist_ok=True)
    if system == "linux":
        create_desktop_icon()
   
def custom_location() -> Optional[str]:
    if system.startswith("linux"):
        if shutil.which("zenity"):
            cmd = ["zenity", "--file-selection", "--directory",
                "--title=Select a destination for the Emulation directory."]
        elif shutil.which("kdialog"):
            cmd = ["kdialog", "--getexistingdirectory", "."]
        else:
            return None
    
        r = subprocess.run(cmd, capture_output=True, text=True)
        return r.stdout.strip() or None
    
    elif system.startswith("darwin"):
        r = subprocess.run(
            ["osascript", "-e",
            'POSIX path of (choose folder with prompt "Select a destination for the Emulation directory.")'],
            capture_output=True, text=True
        )
        return r.stdout.strip() or None
    
    elif system.startswith("win"):
        ps = (
            "Add-Type -AssemblyName System.Windows.Forms;"
            "$d=New-Object System.Windows.Forms.FolderBrowserDialog;"
            "$d.Description='Select a destination for the Emulation directory.';"
            "if($d.ShowDialog() -eq 'OK'){$d.SelectedPath}"
        )
        r = subprocess.run(["powershell", "-Command", ps],
                        capture_output=True, text=True)
        return r.stdout.strip() or None
    
    return None    

def get_sd_path() -> Optional[str]:

    sd_block = "/dev/mmcblk0p1"

    try:
        st = os.stat(sd_block)
    except FileNotFoundError:
        return None

    if not stat.S_ISBLK(st.st_mode):
        return None

    try:
        out = subprocess.check_output(
            ["findmnt", "-n", "--raw", "--evaluate", "--output=target", "-S", sd_block],
            text=True
        ).strip()
        return out or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

def test_location_valid(location_name: str, test_location = "") -> str:

    if " " in test_location:
        return f"Invalid: {location_name} contains spaces"

    if "SD" in location_name:
        test_location = get_sd_path()

    testwrite = os.path.join(test_location, "testwrite")
    symlink  = os.path.join(test_location, "testwrite.link")

    try:
        with open(testwrite, "w") as f:
            pass
        if not os.path.isfile(testwrite):
            return f"Invalid: {location_name} not Writable"

        try:
            os.symlink(testwrite, symlink)
        except OSError:
            return f"Invalid: {location_name} not Linkable"

        if not os.path.islink(symlink) or not os.path.isfile(symlink):
            return f"Invalid: {location_name} not Linkable"

    finally:
        for path in (symlink, testwrite):
            try:
                os.remove(path)
            except OSError as e:
                if e.errno != errno.ENOENT:
                    raise

    return "Valid"
    
def test_location_valid_only_write(location_name: str, test_location: str) -> str:
    test_file = os.path.join(test_location, "testwrite")
    try:
        open(test_file, 'w').close()
        if not os.path.isfile(test_file):
            result = f"Invalid: {location_name} not Writable"
        else:
            result = "Valid"
    except OSError:
        result = f"Invalid: {location_name} not Writable"
    finally:
        if os.path.exists(test_file):
            os.remove(test_file)
    return result    

def get_product_name() -> Optional[str]:
    path = Path('/sys/devices/virtual/dmi/id/product_name')
    try:
        return path.read_text(encoding='utf-8').strip()
    except (OSError, UnicodeError):
        return None

def get_screen_ar() -> int:
    w, h = get_primary_monitor_size()
    screen_width  = w
    screen_height = h
    if screen_height == 0:
        return 0

    ratio_str = f"{(screen_width / screen_height):.2f}"

    if ratio_str == '1.60':
        return 1610
    elif ratio_str == '1.78':
        return 169
    else:
        return 0

def get_environment_details() -> None:
    import json
    sd_path = get_sd_path()
    sd_valid = test_location_valid("sd", sd_path)

    first_run = not Path(emudeck_folder, ".finished").is_file()

    uname = subprocess.check_output(["uname", "-a"], text=True).strip()

    info = {
        "Home":          os.environ.get("HOME", ""),
        "Hostname":      os.environ.get("HOSTNAME", subprocess.getoutput("hostname")),
        "Username":      os.environ.get("USER", ""),
        "SDPath":        sd_path,
        "IsSDValid?":    sd_valid,
        "FirstRun?":     first_run,
        "ProductName":   get_product_name(),
        "AspectRatio":   get_screen_ar(),
        "UName":         uname,
    }

    print(json.dumps(info, ensure_ascii=False))

def get_primary_monitor_size():
    from screeninfo import get_monitors
    monitors = get_monitors()
    m = monitors[0]
    return m.width, m.height

def set_msg(message: str):
    global progress_bar

    progress_bar += 5
    if progress_bar == 95:
        progress_bar = 90

    log_path = Path(emudeck_logs) / "msg.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    with log_path.open("w", encoding="utf-8") as f:
        f.write(f"{progress_bar}")
        f.write(f"# {message}\n")

    print(message)

def update_or_append_config_line(config_file: str, option: str, replacement: str) -> None:
    path = Path(config_file)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.touch(exist_ok=True)

    lines = path.read_text(encoding='utf-8').splitlines(keepends=True)

    updated = False
    new_lines = []
    for line in lines:
        if line.lstrip().startswith(option):
            if not updated:
                print(f"updating: {replacement} in {config_file}")
                updated = True
            new_lines.append(replacement.rstrip('\n') + '\n')
        else:
            new_lines.append(line)

    if not updated:
        print(f"appending: {replacement} to {config_file}")
        new_lines.append(replacement.rstrip('\n') + '\n')

    path.write_text(''.join(new_lines), encoding='utf-8')


def get_xdg_user_dir(name: str) -> Path:
    try:
        out = subprocess.check_output(
            ['xdg-user-dir', name],
            stderr=subprocess.DEVNULL,
            text=True
        ).strip()
        if out:
            return Path(out)
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    return Path.home() / 'Desktop'

def command_exists(cmd: str) -> bool:
    return subprocess.call(['command', '-v', cmd],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL) == 0

def remove_if_exists(path: Path):
    try:
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
    except FileNotFoundError:
        pass

def create_desktop_shortcut(dest: Path, name: str, exec_path: str, terminal: bool):
    system = platform.system().lower()

    if system.startswith("win"):
        import pythoncom
        try:
            from win32com.client import Dispatch
        except ImportError:
            raise RuntimeError("pywin32 is required on Windows to create shortcuts")
        pythoncom.CoInitialize()
        if dest.suffix.lower() != ".lnk":
            dest = dest.with_suffix(".lnk")

        icons_src = Path(emudeck_backend) / "icons"
        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("ico"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                icon = str(src_file)
                break


        pythoncom.CoInitialize()
        shell = Dispatch('WScript.Shell')
        shortcut = shell.CreateShortCut(str(dest))
        shortcut.Targetpath = str(exec_path)
        shortcut.WorkingDirectory = str(Path(exec_path).parent)
        if terminal:
            shortcut.Arguments = '/k'
            shortcut.Targetpath = "cmd.exe"
        shortcut.IconLocation = str(exec_path)
        shortcut.Description = name
        shortcut.save()
        print(f"Created Windows shortcut: {dest}")
        return

    if system == "linux":
        from pathlib import Path
        import shutil

        icons_dest = Path.home() / ".local" / "share" / "icons" / "emudeck"
        icons_dest.mkdir(parents=True, exist_ok=True)

        icons_src = Path(emudeck_backend) / "icons"
        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("svg", "jpg", "png"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                dst_file = icons_dest / src_file.name
                shutil.copy2(src_file, dst_file)
                icon = str(dst_file)
                break

        desktop_entry = [
            "[Desktop Entry]",
            "Type=Application",
            f"Name={name}",
            f"Icon={icon}",
            f"Exec={exec_path}",
            f"Terminal={'true' if terminal else 'false'}",
            "Categories=Utility;"
        ]
        dest = Path(dest)
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text("\n".join(desktop_entry) + "\n", encoding='utf-8')
        dest.chmod(0o755)
        print(f"Created .desktop file: {dest}")

    if system == "darwin":
        if dest.exists() or dest.is_symlink():
            dest.unlink()

        dest.symlink_to(exec_path)

def create_desktop_icon():
    emus_folder = home/"Applications"
    desktop = get_xdg_user_dir('DESKTOP')

    sandbox_flag = ' --no-sandbox' if command_exists('apt-get') else ''

    old_icons = [
        "EmuDeckUninstall.desktop",
        "EmuDeckCHD.desktop",
        "EmuDeck.desktop",
        "EmuDeckSD.desktop",
        "EmuDeckBinUpdate.desktop",
        "EmuDeckApp.desktop",
        "EmuDeckAppImage.desktop",
    ]
    for icon in old_icons:
        remove_if_exists(desktop / icon)

    appimage = f"{emus_folder}/EmuDeck.AppImage{sandbox_flag}"
    create_desktop_shortcut(
        desktop / "EmuDeck.desktop",
        "EmuDeck",
        appimage,
        terminal=False
    )

    applications_dir = Path.home() / ".local" / "share" / "applications"
    create_desktop_shortcut(
        applications_dir / "EmuDeck.desktop",
        "EmuDeck",
        appimage,
        terminal=False
    )

def md5_of(path: Path) -> Optional[str]:
    if not path.is_file():
        return None
    h = hashlib.md5()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def get_latest_release_gh(repository: str,
                          fileType: str,
                          fileNameContains: str) -> str:
    api_url = f"https://api.github.com/repos/{repository}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    resp = requests.get(api_url, headers=headers)
    resp.raise_for_status()
    data = resp.json()

    for asset in data.get("assets", []):
        name = asset.get("name", "")
        if (fileNameContains in name
                and name.endswith(fileType)):
            return asset.get("browser_download_url", "")

    return False

def get_latest_prerelease_gh(repository: str,
                    fileType: str,
                    fileNameContains: str) -> str:
    api_url = f"https://api.github.com/repos/{repository}/releases"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    resp = requests.get(api_url, headers=headers)
    resp.raise_for_status()
    releases = resp.json()

    for release in releases:
        for asset in release.get("assets", []):
            name = asset.get("name", "")
            if (fileNameContains in name and name.endswith(fileType)):
                return asset.get("browser_download_url", "")

    return ""

def linkToSaveFolder(emu: str, folderName: str, path: str, saves_path: str, set_msg) -> None:
    link_path = Path(saves_path) / emu / folderName
    target_path = Path(path)

    if not link_path.is_dir():
        if not link_path.is_symlink():
            (Path(saves_path) / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the Emulation/saves folder")
            target_path.mkdir(parents=True, exist_ok=True)
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                linkToSaveFolder(emu, folderName, path, saves_path, set_msg)

def linkToTexturesFolder(emu: str, folderName: str, path: str, emulation_path: str, set_msg) -> None:
    texturepacks_dir = Path(emulation_path) / "texturepacks"
    texturepacks_dir.mkdir(parents=True, exist_ok=True)

    link_path = texturepacks_dir / emu / folderName
    target_path = Path(path)

    if not link_path.is_dir():
        if not link_path.is_symlink():
            (texturepacks_dir / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the Emulation/texturepacks folder")
            target_path.mkdir(parents=True, exist_ok=True)
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                linkToTexturesFolder(emu, folderName, path, emulation_path, set_msg)

def linkToStorageFolder(emu: str, folderName: str, path: str, storage_path: str, set_msg) -> None:
    link_path = Path(storage_path) / emu / folderName
    target_path = Path(path)

    if not link_path.is_dir():
        if not link_path.is_symlink():
            (Path(storage_path) / emu).mkdir(parents=True, exist_ok=True)
            set_msg(f"Linking {emu} {folderName} to the {storage_path} folder")
            target_path.mkdir(parents=True, exist_ok=True)
            link_path.symlink_to(target_path, target_is_directory=True)
            print(f"Linked: {link_path} → {target_path}")
    else:
        if not link_path.is_symlink():
            print(f"{link_path} is not a link. Please check it.")
        else:
            current_target = os.readlink(str(link_path))
            if Path(current_target) == target_path:
                print(f"{link_path} is already linked.")
                print(f"     Target: {current_target}")
            else:
                print(f"{link_path} not linked correctly, relinking.")
                link_path.unlink()
                linkToStorageFolder(emu, folderName, path, storage_path, set_msg)

def calculate_checksum_sha256(file: Union[str, Path]) -> Optional[str]:
    file = Path(file)
    if not file.is_file():
        print(f"Error: File '{file}' does not exist.")
        return None

    h = hashlib.sha256()
    with file.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def safeDownload(name: str,
                 url: str,
                 outFile: Union[str, Path],
                 showProgress: Union[bool, str, int] = False,
                 headers: Optional[dict] = None,
                 checksumSha256: Optional[str] = None) -> bool:

    outFile = Path(outFile)
    temp_file = outFile.with_suffix(outFile.suffix + '.temp')
    headers = headers or {}


    try:
        with requests.get(url, stream=True, headers=headers, allow_redirects=True) as r:
            r.raise_for_status()
            total = r.headers.get('content-length')
            if showProgress is True:
                total = int(total)
                downloaded = 0
                with temp_file.open('wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if not chunk:
                            continue
                        f.write(chunk)
                        downloaded += len(chunk)
                        percent = downloaded * 100 // total
                        print(f"\r  {percent}% ({downloaded}/{total} bytes)", end='', flush=True)
                print()
            else:
                with temp_file.open('wb') as f:
                    for chunk in r.iter_content(chunk_size=8192):
                        if chunk:
                            f.write(chunk)
    except Exception as e:
        print(f"{name} download failed: {e}")
        if temp_file.exists():
            temp_file.unlink()
        return False

    if checksumSha256:
        actual = calculate_checksum_sha256(temp_file)
        print(f"Downloaded File Checksum: {actual}")
        print(f"Expected Checksum:       {checksumSha256}")
        if not actual or actual.lower() != checksumSha256.lower():
            print("Checksum mismatch, deleting the corrupted file.")
            temp_file.unlink(missing_ok=True)
            return False

    try:
        temp_file.replace(outFile)
        return True
    except Exception as e:
        temp_file.unlink(missing_ok=True)
        return False

def is_flatpak_installed(flatPakID: str) -> bool:
    try:
        user = subprocess.run(
            ["flatpak", "--columns=app", "list", "--user"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True
        ).stdout.splitlines()
        system = subprocess.run(
            ["flatpak", "--columns=app", "list", "--system"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True
        ).stdout.splitlines()
    except subprocess.CalledProcessError:
        return False

    return any(line.strip() == flatPakID for line in user + system)

def addParser(custom_parser: str) -> None:
    source = Path(emudeck_backend) / "configs" / "steam-rom-manager" / "userData" / "parsers" / "optional"
    parser_path = source / custom_parser

    if not parser_path.is_file():
        print(f"Parser file not found: {parser_path}")
        return

    with parser_path.open(encoding='utf-8') as f:
        parser_cfg = json.load(f)

    parser_id = parser_cfg.get("parserId")
    print(f"Parser ID: {parser_id}")

    srm_path = Path(SRM_userConfigurations)
    if not srm_path.is_file():
        srm_path.write_text("[]\n", encoding='utf-8')

    with srm_path.open(encoding='utf-8') as f:
        try:
            configs = json.load(f)
            if not isinstance(configs, list):
                raise ValueError
        except Exception:
            configs = []

    if any(cfg.get("parserId") == parser_id for cfg in configs):
        print(f"Parser {parser_id} already exists in configuration.")
        return

    print("adding parser")
    configs.append(parser_cfg)
    try:
        SRM_setEmulationFolder()
    except NameError:
        print("NYI SRM_setEmulationFolder")

    configs.sort(key=lambda x: x.get("configTitle", ""))
    srm_path.write_text(json.dumps(configs, ensure_ascii=False, indent=2) + "\n", encoding='utf-8')

def server_install() -> None:
    src = Path(emudeck_backend) / "tools" / "server.sh"
    dst = Path(tools_path) / "server.sh"
    if not src.is_file():
        print(f"Source not found: {src}")
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    dst.chmod(dst.stat().st_mode | stat.S_IXUSR)
    print(f"Installed server script to {dst}")

def call_func(func: Callable[..., Any],
              *args,
              silent: bool = True,
              **kwargs) -> Union[Any, dict]:
    if not silent:
        return func(*args, **kwargs)

    buf_out = io.StringIO()
    buf_err = io.StringIO()
    try:
        with redirect_stdout(buf_out), redirect_stderr(buf_err):
            result = func(*args, **kwargs)
    except Exception as e:
        return {"status": "KO", "error": str(e)}

    if result is False:
        return {"status": "KO"}

    return {"status": "OK", "result": result}

def create_symlink_crossplatform(source: Path, link_path: Path):
    if link_path.exists() or link_path.is_symlink():
        link_path.unlink()

    system = platform.system().lower()

    try:
        if system.startswith("win"):
            subprocess.run(
                ["cmd", "/c", "mklink", "/J", str(link_path), str(source)],
                shell=True, check=True
            )
        else:
            subprocess.run(['ln', '-sf', str(source), str(link_path)], check=True)

    except subprocess.CalledProcessError as e:
        print(f"Error creating link: {e}")
        raise

def install_emu(name, url, type_, destination):
    if url is False:
        print(f"Error downloading or processing {url}")
        return False
    if destination is None:
        destination = emus_folder
    destination = Path(destination)
    emus_folder.mkdir(parents=True, exist_ok=True)

    temp_dir = Path(tempfile.mkdtemp())
    archive_path = temp_dir / f"{name}.{type_}"
    dest_file = destination / f"{name}"

    try:
        if "http" in url:
            headers = {
                "User-Agent": (
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/114.0.0.0 Safari/537.36"
                ),
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            }
            response = requests.get(url, stream=True, headers=headers, timeout=30)
            response.raise_for_status()
            with open(archive_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

        if type_ == "exe":
            print(archive_path)
            print(dest_file)
            shutil.move(str(archive_path), str(f"{dest_file}.exe"))
            print(f"{name}.exe installedd at {dest_file}")

        elif type_ == "flatpak":
            result = subprocess.run(
                ["flatpak", "install", url, "-y", "--user"],
                capture_output=True, text=True
            )
            if result.returncode != 0 and "already installed" not in result.stderr:
                print(f"Error installing {name} flatpak: {result.stderr}")
                return False
            print(f"{name} flatpak installed")
            
            return True

        elif type_ in ("AppImage", "appimage"):
            dest_file = Path(f"{dest_file}.AppImage")
            shutil.move(str(archive_path), dest_file)
            dest_file.chmod(0o755)
            print(f"{name}.AppImage installed at {dest_file}")

        elif type_ == "tar.gz":
            extract_to = emus_folder / destination / name
            extract_to.mkdir(parents=True, exist_ok=True)
            extract_tar_gz(archive_path, extract_to)
            print(f"{name} extracted to {extract_to}")


            if system == "linux":
                appimages = list(extract_to.rglob("*.AppImage"))
                if not appimages:
                    print(f"No .AppImage found inside {extract_to}")
                    return False

                appimage_path = appimages[0]
                print(f"Found AppImage: {appimage_path}")

                dest_file = emus_folder / appimage_path.name
                shutil.copy2(appimage_path, dest_file)
                dest_file.chmod(0o755)
                print(f"{name}.AppImage installed at {dest_file}")

            if system == "darwin":
                apps = list(extract_to.rglob("*.app"))
                if not apps:
                    print(f"No .app found inside {extract_to}")
                    return False

                app_path = apps[0]
                print(f"Found App: {app_path}")

                dest_file = emus_folder / f"{name}.app"
                shutil.copytree(app_path, dest_file, dirs_exist_ok=True)
                dest_file.chmod(0o755)
                darwin_trust_app(dest_file)
                print(f"{name}.app installed at {dest_file}")

            shutil.rmtree(extract_to, ignore_errors=True)
        elif type_ in ("tar.xz"):
            extract_to = emus_folder / destination
            extract_to.mkdir(parents=True, exist_ok=True)
            extract_tar_xz(archive_path, extract_to)
            print(f"{name} extracted to {extract_to}")

        elif type_ in ("zip"):
            extract_to = emus_folder / destination if destination else emus_folder / name
            extract_to.mkdir(parents=True, exist_ok=True)

            if system == "linux":
                appimages = list(extract_to.rglob("*.AppImage"))
                if not appimages:
                    print(f"No .AppImage found inside {extract_to}")
                    return False

                appimage_path = appimages[0]
                print(f"Found AppImage: {appimage_path}")

                dest_file = emus_folder / appimage_path.name
                shutil.copy2(appimage_path, dest_file)
                dest_file.chmod(0o755)
                print(f"{name}.AppImage installed at {dest_file}")
                return

            if system == "darwin":
                extract_to = emus_folder
                extract_to.mkdir(parents=True, exist_ok=True)
                with zipfile.ZipFile(archive_path, 'r') as zf:
                    zf.extractall(path=extract_to)
                return

            try:
                extract_flat(archive_path, extract_to)
            except Exception as e:
                extract(archive_path, extract_to)

            print(f"{name} extracted to {extract_to}")


        elif type_ in ("7z"):
            extract_to = emus_folder / destination if destination else emus_folder / name
            extract_to.mkdir(parents=True, exist_ok=True)

            extract7z_flat(archive_path, extract_to)

            print(f"{name} extracted to {extract_to}")


        elif type_ == "dmg":
            print(f"Opening {archive_path} in Finder…")
            install_dmg(name,archive_path)
        else:
            print(f"Unsupported type or platform: {type_}")
            return False

        create_app_shortcut(name)
        return True

    except Exception as e:
        print(f"Error downloading or processing {url}: {e}")
        return False

    finally:
        shutil.rmtree(temp_dir, ignore_errors=True)

def uninstall_emu(name, type_):
    if type_ == "app":
        app = Path(emus_folder / f"{name}.app" )
        app_link = Path(f"/Applications/EmuDeck/{name}.app")
        if app.exists():
            shutil.rmtree(app, ignore_errors=True)
            print(f"Removed App at {app}")
        if app_link.exists():
            shutil.rmtree(app_link, ignore_errors=True)
            print(f"Removed Link at {app_link}")

    if type_ == "AppImage":
        appimage = Path(emus_folder) /  f"{name}.AppImage"
        appimage_link = Path.home() / ".local" / "share" / "applications" / f"{name}.desktop"
        print(appimage)
        if appimage.exists():
            appimage.unlink()
            print(f"Removed AppImage at {appimage}")
        if appimage_link.exists():
            appimage_link.unlink()
            print(f"Removed AppImage Link at {appimage_link}")

    if type_ == "dir":
        dir = Path(emus_folder / name)
        if dir.exists():
            shutil.rmtree(dir, ignore_errors=True)
            print(f"Removed directory at {dir}")

    if type_ == "flatpak":
        subprocess.run(["flatpak", "uninstall", name, "-y", "--user"])
        print(f"Removed Flatpak")

def create_app_shortcut(name: str):
    launcher_name = name

    dest = Path(f"{tools_path}/launchers")
    dest.mkdir(parents=True, exist_ok=True)

    if name == "Dolphin":
        launcher_name = "dolphin-emu"
    if name == "xemu":
        launcher_name = "xemu-emu"
    if name == "pcsx2":
        launcher_name = "pcsx2-qt"

    if system.startswith("win"):
        import pythoncom
        appdata = Path(os.environ["APPDATA"])
        programs = appdata / "Microsoft" / "Windows" / "Start Menu" / "Programs"
        emudeck_folder_start_menu = programs / "EmuDeck"
        emudeck_folder_start_menu.mkdir(parents=True, exist_ok=True)

        if name == "ES-DE":
            link_name = "EmulationStationDE"
        elif name == "srm":
            link_name = "SteamRomManager"
        else:
            link_name = name.lower()

        dest = emudeck_folder_start_menu / link_name
        if dest.suffix.lower() != ".lnk":
            dest = dest.with_suffix(".lnk")

        try:
            from win32com.client import Dispatch
        except ImportError:
            raise RuntimeError("pywin32 is required on Windows to create shortcuts")

        icons_src = Path(emudeck_backend) / "icons" / "ico"
        base = name.split(" ", 1)[0]
        icon = ""
        ico_file = icons_src / f"{base}.ico"
        if ico_file.exists():
            icon = str(ico_file)

        if name == "ES-DE":
            folder = "es-de"
            script_filename = "es-de.bat"
            display_name = "EmulationStationDE"
        elif name == "srm":
            folder = "srm"
            script_filename = "steamrommanager.bat"
            display_name = "SteamRomManager"
        else:
            folder = ""
            if name.lower() == "model2":
                script_filename = "model-2-emulator.bat"
            else:
                script_filename = f"{launcher_name.lower()}.bat"
            display_name = name

        src_file = Path(emudeck_backend) / "tools" / "launchers" / "windows" / folder / script_filename
        script_path = Path(str(tools_path).replace("$HOME", str(Path.home()), 1)) / "launchers" / folder / script_filename

        script_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_file, script_path)

        pythoncom.CoInitialize()
        shell = Dispatch("WScript.Shell")
        shortcut = shell.CreateShortCut(str(dest))

        cmd_exe = Path(os.environ["WINDIR"]) / "System32" / "cmd.exe"
        shortcut.Targetpath = str(cmd_exe)
        shortcut.Arguments = f'/d /c ""{script_path}""'
        shortcut.WorkingDirectory = str(script_path.parent)

        if icon:
            shortcut.IconLocation = icon

        shortcut.Description = display_name
        shortcut.save()

        print(f"Created Windows shortcut: {dest}")
        return

    if system == "linux":
        icons_src = Path(emudeck_backend) / "icons"
        icons_dest = Path.home() / ".local" / "share" / "icons" / "emudeck"
        icons_dest.mkdir(parents=True, exist_ok=True)

        base = name.split(" ", 1)[0]
        icon = ""
        for ext in ("svg", "jpg", "png"):
            src_file = icons_src / f"{base}.{ext}"
            if src_file.exists():
                dst_file = icons_dest / src_file.name
                shutil.copy2(src_file, dst_file)
                icon = str(dst_file)
                break

        folder = ""
        script_filename = f"{launcher_name.lower()}.sh"
        display_name = name
        desktop_filename = f"{name}.desktop"
        keywords = f"{name.lower()};emudeck;"

        if name == "ES-DE":
            folder = "es-de"

        if name == "srm":
            folder = "srm"
            script_filename = "steamrommanager.sh"
            display_name = "SteamRomManager"
            desktop_filename = "srm.desktop"
            keywords = "srm;steam;rom;manager;steamrommanager;steam rom manager;emudeck;"

        src_file = Path(emudeck_backend) / "tools" / "launchers" / "unix" / folder / script_filename
        exec_path = Path(tools_path) / "launchers" / folder / script_filename

        exec_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src_file, exec_path)
        exec_path.chmod(exec_path.stat().st_mode | 0o111)

        desktop_entry = [
            "[Desktop Entry]",
            "Type=Application",
            f"Name={display_name} - EmuDeck",
            f"Icon={icon}",
            f"Exec={exec_path}",
            "Terminal=false",
            "Categories=Utility;",
            f"Keywords={keywords}",
        ]

        applications_dir = Path.home() / ".local" / "share" / "applications"
        dest = applications_dir / desktop_filename
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text("\n".join(desktop_entry) + "\n", encoding="utf-8")
        dest.chmod(0o755)
        print(f"Created .desktop file: {dest}")

    if system == "darwin":
        folder = ""
        if name == "ES-DE":
            folder = "es-de"

        src_file = Path(emudeck_backend) / "tools" / "launchers" / "unix" / folder / f"{launcher_name.lower()}.sh"
        exec_path = Path(tools_path) / "launchers" / folder / f"{launcher_name.lower()}.sh"
        shutil.copy2(src_file, exec_path)

        create_mac_app(name, Path(exec_path))


def create_mac_app(app_name: str, script_path: Path, output_dir: Path = Path("/Applications/EmuDeck")):

    app_bundle = output_dir / f"{app_name}.app"
    contents_dir = app_bundle / "Contents"
    macos_dir = contents_dir / "MacOS"
    resources_dir = contents_dir / "Resources"

    macos_dir.mkdir(parents=True, exist_ok=True)
    resources_dir.mkdir(parents=True, exist_ok=True)

    exec_name = script_path.stem
    target_exec = macos_dir / exec_name
    shutil.copy2(script_path, target_exec)
    target_exec.chmod(target_exec.stat().st_mode | stat.S_IEXEC)

    plist = {
        "CFBundleName": app_name,
        "CFBundleDisplayName": app_name,
        "CFBundleIdentifier": f"com.local.{app_name.lower()}",
        "CFBundleVersion": "1.0",
        "CFBundlePackageType": "APPL",
        "CFBundleExecutable": exec_name,
        "CFBundleInfoDictionaryVersion": "6.0"
    }
    with open(contents_dir / "Info.plist", "wb") as f:
        plistlib.dump(plist, f)

    print(f"✅ Created macOS app bundle at: {app_bundle}")

def extract(zip_path: Path, extract_to: Path) -> None:
    extract_to.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(zip_path, 'r') as zf:
        zf.extractall(path=extract_to)

def extract_flat(zip_path: Path, extract_to: Path):
    with zipfile.ZipFile(zip_path, 'r') as zf:
        files = [name for name in zf.namelist() if not name.endswith('/')]
        roots = {Path(f).parts[0] for f in files}
        common_root = roots.pop() if len(roots) == 1 else None

        for member in zf.infolist():
            if member.is_dir():
                continue
            src = Path(member.filename)
            parts = src.parts[1:] if common_root and src.parts[0] == common_root else src.parts
            dest = extract_to.joinpath(*parts)
            dest.parent.mkdir(parents=True, exist_ok=True)
            with zf.open(member) as src_file, open(dest, 'wb') as dst_file:
                shutil.copyfileobj(src_file, dst_file)

def extract7z_flat(archive_path: Path, extract_to: Path):
    import py7zr
    extract_to.mkdir(parents=True, exist_ok=True)

    if sys.platform == "win32":
        cmd = [
            "tar", "-xf", str(archive_path),
            "-C", str(extract_to)
        ]
        subprocess.run(cmd, check=True)
        items = list(extract_to.iterdir())
        if len(items) == 1 and items[0].is_dir():
            top = items[0]
            for child in top.iterdir():
                child.rename(extract_to / child.name)
            top.rmdir()
        return

    try:
        with py7zr.SevenZipFile(str(archive_path), mode='r') as zf:
            all_files = [n for n in zf.getnames() if not n.endswith('/')]
            roots = {Path(f).parts[0] for f in all_files}
            common_root = roots.pop() if len(roots) == 1 else None

            for name, bio in zf.readall().items():
                if name.endswith('/'):
                    continue
                src = Path(name)
                parts = src.parts[1:] if common_root and src.parts[0] == common_root else src.parts
                dest = extract_to.joinpath(*parts)
                dest.parent.mkdir(parents=True, exist_ok=True)
                with open(dest, 'wb') as f:
                    f.write(bio.read())
        return

    except Exception as e:
        if "BCJ2 filter is not supported" not in str(e):
            raise

    cmd = [
        "7z", "x",
        "-y",
        f"-o{extract_to}",
        str(archive_path)
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    items = list(extract_to.iterdir())
    if len(items) == 1 and items[0].is_dir():
        top = items[0]
        for child in top.iterdir():
            child.rename(extract_to / child.name)
        top.rmdir()

def install_dmg(name, archive_path):
    subprocess.run(["open", str(archive_path)], check=True)
    mount_point = None
    for _ in range(30):
        for vol in Path("/Volumes").iterdir():
            mount_point = vol
            break
        if mount_point:
            break

    if not mount_point:
        print("❌ Timeout: DMG did not mount in /Volumes.")
        return False

    print(f"✅ Mounted at {mount_point}")

    apps = list(mount_point.glob("*.app"))
    if not apps:
        print("❌ No .app found inside the DMG.")
        input("Press Enter to unmount…")
        subprocess.run(["hdiutil", "detach", str(mount_point)])
        return False

    app_bundle = apps[0]
    target = Path.home() / "Applications" / app_bundle.name
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(app_bundle, target, dirs_exist_ok=True)
    print(f"✔️  Copied {app_bundle.name} → {target}")
    darwin_trust_app(target)
    subprocess.run(["hdiutil", "detach", str(mount_point)], stdout=subprocess.DEVNULL)
    print("✔️  DMG detached.")
    return True

def extract_tar_gz(archive_path: Path, extract_to: Path):
    extract_to.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive_path, mode="r:gz") as tf:
        tf.extractall(path=extract_to)

def copy_setting_dir(src: Path, dst: Path):
    src = Path( emudeck_backend / "configs" / src)
    shutil.copytree(
        src,
        dst,
        dirs_exist_ok=True
    )
def copy_and_set_settings_file(src: Union[str, Path],
                               dst: Union[str, Path]) -> Path:
    src_path = Path(emudeck_backend) / "configs" / Path(src)
    if not src_path.is_file():
        raise FileNotFoundError(f"Source file not found: {src_path}")

    dst_dir = Path(dst)
    dst_dir.mkdir(parents=True, exist_ok=True)

    dst_file = dst_dir / src_path.name

    shutil.copy2(src_path, dst_file)

    print(f"Copied {src_path} → {dst_file}")
    sed("EMULATIONPATH",emulation_path,dst_file)
    sed("STEAMPATH",steam_install_path,dst_file)
    ext=".sh"
    if system.startswith("win"):
        ext=".bat"
    sed(".EXT",ext,dst_file)

def sed(old: str, replacement: str, file_path: str) -> None:
    replacement = str(replacement)
    file_str = str(file_path)

    pattern = re.compile(re.escape(old))
    safe_repl = replacement.replace("\\", "\\\\")
    for line in fileinput.input(str(file_path), inplace=True, backup=".bak"):
        new_line = pattern.sub(safe_repl, line)
        print(new_line, end="")


def move_contents_and_link(origin: Union[str, Path], destination: Union[str, Path]) -> bool:
    origin = Path(origin)
    destination = Path(destination)
    print("Linking...")
    
    if not origin.exists() and not origin.is_symlink():
        origin.mkdir(parents=True, exist_ok=True)
        print("Info: No origin, creating")
    
    if origin.is_symlink():
        print("Warning: Origin is symlink")
        return False
    
    if origin.is_dir():
        destination.mkdir(parents=True, exist_ok=True)
        
        if any(origin.iterdir()):
            backup_path = origin.parent / f"{origin.name}_backup"
            if backup_path.exists():
                from datetime import datetime
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                backup_path = origin.parent / f"{origin.name}_backup_{timestamp}"
            shutil.copytree(str(origin), str(backup_path))
            print(f"Backup created: {backup_path}")
        
        for item in origin.iterdir():
            dest_item = destination / item.name
            if dest_item.exists():
                if dest_item.is_dir():
                    shutil.rmtree(str(dest_item))
                else:
                    dest_item.unlink()
            shutil.move(str(item), str(dest_item))
        
        try:
            shutil.rmtree(str(origin))
        except OSError as e:
            print(f"Error removing origin: {e}")
            return False
        
        if system.startswith("win"):
            try:
                os.symlink(str(destination), str(origin), target_is_directory=True)
            except (OSError, NotImplementedError):
                subprocess.run(
                    ["cmd", "/c", "mklink", "/J", str(origin), str(destination)],
                    shell=True,
                    check=True
                )
        else:
            os.symlink(str(destination), str(origin))
        
        return True
    
        return False

def set_config(old: str, new: str, file_to_check: Path, separator: str = "=") -> None:
    file_to_check = Path(file_to_check)
    lines = file_to_check.read_text(encoding="utf-8").splitlines()

    new_line = f"{old}{separator}{new}"

    for idx, line in enumerate(lines):
        if old in line:
            old_line = line
            lines[idx] = new_line
            file_to_check.write_text("\n".join(lines) + "\n", encoding="utf-8")
            print(f"Line '{old_line}' changed to '{new_line}'")
            return

    with file_to_check.open("a", encoding="utf-8") as f:
        f.write(new_line + "\n")
    print(f"Line '{new_line}' created in {file_to_check}")

def extract_tar_xz(archive_path: Path, extract_to: Path):
    extract_to.mkdir(parents=True, exist_ok=True)

    with tarfile.open(archive_path, mode="r:xz") as tar:
        tar.extractall(path=extract_to)

def darwin_trust_app(app_path: Path):
        subprocess.run([
            "xattr", "-r", "-d", "com.apple.quarantine", str(app_path)
        ], check=False)
def get_linux_version_id() -> str:
    try:
        with open("/etc/os-release", encoding="utf-8") as f:
            for line in f:
                if line.startswith("VERSION_ID="):
                    return line.split("=",1)[1].strip().strip('"')
    except FileNotFoundError:
        pass
    return ""

def update_json_key(key: str, new_value: Any, file_path: Path) -> None:
    data = {}
    file_path = Path(file_path)
    if file_path.exists():
        with file_path.open("r", encoding="utf-8") as f:
            data = json.load(f)

    data[key] = new_value

    with file_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")


def md5_of_file(path: Path) -> str:
    
    h = hashlib.md5()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def set_setting(key: str, value: Any) -> None:
    json_path = Path(emudeck_folder) / "settings.json"
    data: dict[str, Any]
    if json_path.exists():
        try:
            with json_path.open('r', encoding='utf-8') as f:
                data = json.load(f)
                if not isinstance(data, dict):
                    data = {}
        except json.JSONDecodeError:
            data = {}
    else:
        data = {}

    keys = key.split('.')
    d = data
    for k in keys[:-1]:
        if k not in d or not isinstance(d[k], dict):
            d[k] = {}
        d = d[k]
    d[keys[-1]] = value

    with json_path.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")
    json_settings_path = Path(emudeck_folder) / "settings.json"
    if json_settings_path.exists():
        with open(json_settings_path, encoding='utf-8') as jf:
            settings = json.load(jf, object_hook=lambda d: SimpleNamespace(**d))

def get_launcher_setting(key: str, default: Any = None) -> Any:
    json_path = Path(emudeck_folder) / "launcher_settings.json"
    if not json_path.exists():
        return default
    try:
        with json_path.open('r', encoding='utf-8') as f:
            data = json.load(f)
    except json.JSONDecodeError:
        return default
    if not isinstance(data, dict):
        return default
    keys = key.split('.')
    d = data
    for k in keys:
        if not isinstance(d, dict) or k not in d:
            return default
        d = d[k]
    return d

def set_launcher_setting(key: str, value: Any) -> None:
    json_path = Path(emudeck_folder) / "launcher_settings.json"
    data: dict[str, Any]
    if json_path.exists():
        try:
            with json_path.open('r', encoding='utf-8') as f:
                data = json.load(f)
                if not isinstance(data, dict):
                    data = {}
        except json.JSONDecodeError:
            data = {}
    else:
        data = {}

    keys = key.split('.')
    d = data
    for k in keys[:-1]:
        if k not in d or not isinstance(d[k], dict):
            d[k] = {}
        d = d[k]
    d[keys[-1]] = value

    with json_path.open('w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")

def popup_show_info(title: str, message: str) -> None:
    app = ensure_app()
    dlg = BaseDialog(title)

    lbl = QtWidgets.QLabel(message)
    lbl.setWordWrap(True)
    dlg._add(lbl)

    ok = QtWidgets.QPushButton("OK")
    ok.clicked.connect(dlg.accept)
    dlg._add(ok, alignment=QtCore.Qt.AlignCenter)

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        if poll_gamepad() in ("yes","no","cancel"):
            dlg.accept()
        QtCore.QThread.msleep(50)

def popup_show_commands(title: str, commands: list) -> bool:
    app = ensure_app()
    dlg = QtWidgets.QDialog(None)
    dlg.setWindowTitle(title)
    dlg.setWindowFlags(dlg.windowFlags() | QtCore.Qt.FramelessWindowHint)
    dlg.setAttribute(QtCore.Qt.WA_TranslucentBackground)
    dlg.setStyleSheet("""
        QDialog { background: transparent; }
            background: rgba(20, 20, 30, 0.92);
            border-radius: 12px;
        }
    """)

    overlay = QtWidgets.QWidget(dlg)
    overlay.setObjectName("overlay")
    outer = QtWidgets.QVBoxLayout(dlg)
    outer.setContentsMargins(0, 0, 0, 0)
    outer.addWidget(overlay)

    layout = QtWidgets.QVBoxLayout(overlay)
    layout.setContentsMargins(30, 24, 30, 24)
    layout.setSpacing(6)

    title_lbl = QtWidgets.QLabel(title.upper())
    title_lbl.setStyleSheet("color: #ffffff; font-size: 16px; font-weight: bold; letter-spacing: 2px; padding-bottom: 8px;")
    layout.addWidget(title_lbl)

    layout.addSpacing(4)

    _glyphs = {
        "START": "\u2630",
        "SELECT": "\u29C9",
        "STEAM": "STEAM",
        "A": "\u24B6", "B": "\u24B7", "X": "\u24CD", "Y": "\u24CE",
    }

    for shortcut, description in commands:
        row = QtWidgets.QHBoxLayout()
        row.setSpacing(0)

        parts = [p.strip() for p in shortcut.split("+")]
        for i, part in enumerate(parts):
            if i > 0:
                plus = QtWidgets.QLabel("+")
                plus.setStyleSheet("color: rgba(255,255,255,0.5); font-size: 13px; padding: 0 4px;")
                plus.setSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
                row.addWidget(plus)
            label = _glyphs.get(part.upper(), part)
            btn_lbl = QtWidgets.QLabel(label)
            btn_lbl.setStyleSheet(
                "color: #ffffff; font-size: 12px; font-weight: bold;"
                "background: rgba(255,255,255,0.13); border-radius: 4px;"
                "padding: 3px 10px;"
            )
            btn_lbl.setSizePolicy(QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Fixed)
            row.addWidget(btn_lbl)

        row.addStretch(1)

        desc_lbl = QtWidgets.QLabel(description)
        desc_lbl.setStyleSheet("color: rgba(255,255,255,0.85); font-size: 13px;")
        desc_lbl.setAlignment(QtCore.Qt.AlignRight | QtCore.Qt.AlignVCenter)
        row.addWidget(desc_lbl)

        layout.addLayout(row)

    layout.addSpacing(4)

    btn_layout = QtWidgets.QHBoxLayout()
    btn_layout.addStretch(1)

    ok_btn = QtWidgets.QPushButton("OK")
    ok_btn.clicked.connect(dlg.accept)
    btn_layout.addWidget(ok_btn)

    dont_btn = QtWidgets.QPushButton("Don't show again")
    dont_btn.clicked.connect(dlg.reject)
    btn_layout.addWidget(dont_btn)

    btn_layout.addStretch(1)
    layout.addLayout(btn_layout)

    show_again = True

    dlg.resize(520, dlg.sizeHint().height())

    screen = QtWidgets.QApplication.primaryScreen().geometry()
    dlg.move((screen.width() - dlg.width()) // 2, (screen.height() - dlg.height()) // 2)

    widgets = [ok_btn, dont_btn]
    idx = 0
    ok_btn.setFocus()

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        direction = poll_gamepad_dir()
        if direction in ("left", "right"):
            idx = (idx + 1) % len(widgets)
            widgets[idx].setFocus()
        gp = poll_gamepad()
        if gp == "yes":
            dlg.accept()
        elif gp in ("no", "cancel"):
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Rejected:
        show_again = False

    return show_again

def show_hotkeys(emu: str, commands: list) -> None:
    setting_key = f"show_hotkeys_{emu.lower()}"
    if not get_launcher_setting(setting_key, True):
        return
    show_again = popup_show_commands(f"{emu} Hotkeys", commands)
    set_launcher_setting(setting_key, show_again)

def get_connected_controllers() -> int:
    if not pygame.get_init():
        pygame.init()
    pygame.joystick.init()
    return pygame.joystick.get_count()

def popup_wii_players(title: str) -> Optional[int]:
    app = ensure_app()
    dlg = BaseDialog(title)

    heading = QtWidgets.QLabel("How many players?")
    heading.setAlignment(QtCore.Qt.AlignCenter)
    heading.setStyleSheet("font-size: 18px; font-weight: bold;")
    dlg._add(heading)

    btn_layout = QtWidgets.QHBoxLayout()
    btn_layout.setSpacing(16)
    btn_layout.addStretch(1)

    choice: Optional[int] = None
    buttons = []

    def _pick(n: int):
        nonlocal choice
        choice = n
        dlg.accept()

    for n in range(1, 5):
        btn = QtWidgets.QPushButton(str(n))
        btn.setStyleSheet("font-size: 28px; font-weight: bold;")
        btn.setMinimumHeight(140)
        btn.setMinimumWidth(140)
        btn.clicked.connect(lambda checked=False, num=n: _pick(num))
        btn_layout.addWidget(btn)
        buttons.append(btn)

    btn_layout.addStretch(1)
    dlg._inner.addLayout(btn_layout)

    widgets = buttons
    idx = -1
    dlg.setFocus()

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        direction = poll_gamepad_dir()
        if direction in ("left", "right"):
            if idx == -1:
                idx = 0
            else:
                idx = (idx + (1 if direction == "right" else -1)) % len(widgets)
            widgets[idx].setFocus()
        gp = poll_gamepad()
        if gp == "yes" and idx >= 0:
            widgets[idx].click()
        elif gp in ("no", "cancel"):
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Rejected:
        return None
    return choice

def popup_wii_controller_type(title: str, player: int = 1) -> Optional[str]:
    app = ensure_app()
    dlg = BaseDialog(title)

    heading = QtWidgets.QLabel(f"Player {player} — Select emulated controller")
    heading.setAlignment(QtCore.Qt.AlignCenter)
    heading.setStyleSheet("font-size: 18px; font-weight: bold;")
    dlg._add(heading)

    img_dir = Path(emudeck_backend) / "images"

    btn_layout = QtWidgets.QHBoxLayout()
    btn_layout.setSpacing(16)
    btn_layout.addStretch(1)

    icon_size = QtCore.QSize(96, 96)

    wiimote_btn = QtWidgets.QPushButton()
    wiimote_ico = QtGui.QIcon(str(img_dir / "wiimote.webp"))
    wiimote_btn.setIcon(wiimote_ico)
    wiimote_btn.setIconSize(icon_size)
    wiimote_btn.setMinimumHeight(140)
    wiimote_btn.setMinimumWidth(180)

    nunchuck_btn = QtWidgets.QPushButton()
    nunchuck_ico = QtGui.QIcon(str(img_dir / "wiimote_nunchuck.png"))
    nunchuck_btn.setIcon(nunchuck_ico)
    nunchuck_btn.setIconSize(icon_size)
    nunchuck_btn.setMinimumHeight(140)
    nunchuck_btn.setMinimumWidth(180)

    classic_btn = QtWidgets.QPushButton()
    classic_ico = QtGui.QIcon(str(img_dir / "wii_classic_controller.png"))
    classic_btn.setIcon(classic_ico)
    classic_btn.setIconSize(icon_size)
    classic_btn.setMinimumHeight(140)
    classic_btn.setMinimumWidth(180)

    btn_layout.addWidget(wiimote_btn)
    btn_layout.addWidget(nunchuck_btn)
    btn_layout.addWidget(classic_btn)
    btn_layout.addStretch(1)
    dlg._inner.addLayout(btn_layout)

    choice: Optional[str] = None

    def _pick(value: str):
        nonlocal choice
        choice = value
        dlg.accept()

    wiimote_btn.clicked.connect(lambda: _pick("wiimote"))
    nunchuck_btn.clicked.connect(lambda: _pick("wiimote_nunchuck"))
    classic_btn.clicked.connect(lambda: _pick("wii_classic_controller"))

    widgets = [wiimote_btn, nunchuck_btn, classic_btn]
    idx = -1
    dlg.setFocus()

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        direction = poll_gamepad_dir()
        if direction in ("left", "right"):
            if idx == -1:
                idx = 0
            else:
                idx = (idx + (1 if direction == "right" else -1)) % len(widgets)
            widgets[idx].setFocus()
        gp = poll_gamepad()
        if gp == "yes" and idx >= 0:
            widgets[idx].click()
        elif gp in ("no", "cancel"):
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Rejected:
        return None
    return choice

def popup_show_menu(title: str, options: list) -> Optional[bool]:

    if not options:
        return None

    app = ensure_app()
    dlg = BaseDialog(title)

    heading = QtWidgets.QLabel(title)
    heading.setAlignment(QtCore.Qt.AlignCenter)
    heading.setStyleSheet("font-size: 18px; font-weight: bold;")
    dlg._add(heading)

    btn_layout = QtWidgets.QVBoxLayout()
    btn_layout.setSpacing(10)

    chosen_cb = None
    buttons = []

    def _pick(cb):
        nonlocal chosen_cb
        chosen_cb = cb
        dlg.accept()

    for label, cb in options:
        btn = QtWidgets.QPushButton(label)
        btn.setStyleSheet("font-size: 16px; padding: 10px 20px;")
        btn.setMinimumHeight(50)
        btn.clicked.connect(lambda checked=False, callback=cb: _pick(callback))
        btn_layout.addWidget(btn)
        buttons.append(btn)

    # Cancel button
    cancel_btn = QtWidgets.QPushButton("Cancel")
    cancel_btn.setStyleSheet("font-size: 14px; padding: 8px 16px;")
    cancel_btn.setMinimumHeight(40)
    cancel_btn.clicked.connect(dlg.reject)
    btn_layout.addWidget(cancel_btn)
    buttons.append(cancel_btn)

    dlg._inner.addLayout(btn_layout)

    idx = 0
    buttons[0].setFocus()

    dlg.show()
    while dlg.isVisible():
        app.processEvents()
        direction = poll_gamepad_dir()
        if direction in ("up", "down"):
            idx = (idx + (1 if direction == "down" else -1)) % len(buttons)
            buttons[idx].setFocus()
        gp = poll_gamepad()
        if gp == "yes":
            buttons[idx].click()
        elif gp in ("no", "cancel"):
            dlg.reject()
        QtCore.QThread.msleep(50)

    if dlg.result() == QtWidgets.QDialog.Rejected:
        return None

    if chosen_cb:
        chosen_cb()
    return True


def add_parser(
        custom_parser: str,
    ) -> bool:
    source_dir = (
        emudeck_backend
        / "configs"
        / "steam-rom-manager"
        / "userData"
        / "parsers"
        / "optional"
    )

    srm_user_configurations = f"{srm_path}/userData/userConfigurations.json"

    parser_path = source_dir / f"{custom_parser}.json"
    if not parser_path.is_file():
        return False

    new_cfg = json.loads(parser_path.read_text(encoding="utf-8"))
    parser_id = new_cfg.get("parserId")
    print(f"Parser ID: {parser_id}")

    if not srm_user_configurations.exists():
        srm_user_configurations.write_text("[]", encoding="utf-8")

    configs = json.loads(srm_user_configurations.read_text(encoding="utf-8"))

    if any(item.get("parserId") == parser_id for item in configs):
        return True

    print("adding parser")
    configs.append(new_cfg)

    configs.sort(key=lambda x: x.get("configTitle", ""))

    srm_user_configurations.write_text(
        json.dumps(configs, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return True


def load_remote_module(url: str, module_name: str):
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
    source = resp.text

    spec = importlib.util.spec_from_loader(module_name, loader=None)
    module = importlib.util.module_from_spec(spec)
    exec(source, module.__dict__)
    sys.modules[module_name] = module
    return module

def load_remote_cloud_sync():
    REMOTE_URL = f"https://token.emudeck.com/cloud-check.php?access_token={settings.patreonToken}"
    try:
       cloudsync_remote = load_remote_module(REMOTE_URL, "cloudsync_remote")
    except Exception as e:
       cloudsync_remote = None

    return cloudsync_remote

def netplay_set_ip() -> Optional[str]:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
    except Exception:
        return None

    octets = local_ip.split(".")
    if len(octets) != 4:
        return None
    segment = ".".join(octets[:3]) + "."

    port = 55435
    for i in range(2, 256):
        ip = f"{segment}{i}"
        try:
            with socket.create_connection((ip, port), timeout=0.05):
                set_setting("netplay_cmd", f"'-C {ip}'")
                return ip
        except (socket.timeout, ConnectionRefusedError, OSError):
            continue

    return None


def calculate_md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def set_ini_value(file_path, section, key, value):
    config = configparser.ConfigParser()
    config.optionxform = str
    config.read(file_path)
    
    if section not in config:
        config[section] = {}
    
    config[section][key] = value
    
    with open(file_path, 'w') as f:
        config.write(f)


from .helpers_scripts.unused import *