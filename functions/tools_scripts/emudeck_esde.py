from core.all import *

esde_release_json = "https://gitlab.com/es-de/emulationstation-de/-/raw/master/latest_release.json"
esde_add_steam_input_file = (
    Path(emudeck_backend)
    / "configs"
    / "steam-input"
    / "emulationstation-de_controller_config.vdf"
)
steam_input_templateFolder = home / ".steam" / "steam" / "controller_base" / "templates"

esde_settings_file = esde_settings_folder / "settings" / "es_settings.xml"
esde_systems_file = esde_settings_folder / "custom_systems" / "es_systems.xml"
esde_rules_file = esde_settings_folder / "custom_systems" / "es_find_rules.xml"


def esde_get_url():
    try:
        resp = requests.get(esde_release_json, timeout=10)
        resp.raise_for_status()
        data = resp.json()
    except Exception as e:
        print(f"Warning: could not fetch release JSON: {e}")
        return False

    if system == "linux":
        exename = "LinuxAArch64AppImage" if cpu_arch == "arm" else "LinuxSteamDeckAppImage"
    elif system.startswith("win"):
        exename = "WindowsPortable"
    elif system == "darwin":
        exename = "macOSApple"
    else:
        return False

    for pkg in data.get("stable", {}).get("packages", []):
        if pkg.get("name") == exename:
            return pkg.get("url", "")

    return False


def esde_install():
    set_msg("Installing ES-DE")

    if system == "linux":
        type_ = "AppImage"
    elif system.startswith("win"):
        type_ = "zip"
    elif system == "darwin":
        type_ = "dmg"
    else:
        return False

    # App dir (Linux: ~/Applications, Win: Roaming/EmuDeck/EmulationStation-DE)
    esde_folder.mkdir(parents=True, exist_ok=True)

    # Settings dir (Linux: ~/ES-DE, Win: .../EmulationStation-DE/ES-DE)
    esde_settings_folder.mkdir(parents=True, exist_ok=True)

    try:
        install_emu("ES-DE", esde_get_url(), type_, esde_folder)
        esde_add_to_steam()
        return True
    except Exception as e:
        print(f"Error during install: {e}")
        return False


def esde_uninstall():
    try:
        if system == "linux":
            uninstall_emu("ES-DE", "AppImage")
            if esde_settings_folder.exists():
                shutil.rmtree(esde_settings_folder, ignore_errors=True)
                print(f"Removed config directory at {esde_settings_folder}")
            return True

        if system.startswith("win"):
            # In Windows both app + config live under esde_folder
            if esde_folder.exists():
                shutil.rmtree(esde_folder, ignore_errors=True)
                print(f"Removed {esde_folder}")
            return True

        if system == "darwin":
            uninstall_emu("ES-DE", "app")
            return True

        return False

    except Exception as e:
        print(f"Error during uninstall: {e}")
        return False


def esde_init():
    set_msg("EmulationStation DE - Paths and Themes")

    esde_settings_folder.mkdir(parents=True, exist_ok=True)

    src = Path(emudeck_backend) / "configs" / "common" / "emulationstation"
    shutil.copytree(src, esde_settings_folder, dirs_exist_ok=True)

    copy_and_set_settings_file(
        "common/emulationstation/settings/es_settings.xml",
        esde_settings_folder / "settings",
    )

    # Replace EMULATIONPATH and .EXT in find rules and systems config
    for config_file in (esde_rules_file, esde_systems_file):
        if config_file.exists():
            sed("EMULATIONPATH", emulation_path, config_file)
            ext = ".bat" if system.startswith("win") else ".sh"
            sed(".EXT", ext, config_file)

    dlmedia = Path(storage_path / "es-de/downloaded-media")
    dlmedia.mkdir(parents=True, exist_ok=True)

    # esde_apply_theme(esde_theme_url, esde_theme_name)
    esde_set_default_emulators()


def esde_ensure_ryujinx_find_rule():
    if not esde_rules_file.exists():
        return
    content = esde_rules_file.read_text(encoding="utf-8")
    if 'name="RYUJINX"' in content:
        return
    ext = "bat" if system.startswith("win") else "sh"
    entry = f"{tools_path}/launchers/ryujinx.{ext}"
    rule_block = (
        '    <emulator name="RYUJINX">\n'
        '        <rule type="staticpath">\n'
        f'            <entry>{entry}</entry>\n'
        '        </rule>\n'
        '    </emulator>\n'
    )
    content = content.replace("</ruleList>", rule_block + "</ruleList>")
    esde_rules_file.write_text(content, encoding="utf-8")


def esde_launch_fixes():
    esde_ensure_ryujinx_find_rule()


def esde_launch_fixes():
    esde_ensure_ryujinx_find_rule()


def esde_install_init():
    esde_install()
    esde_init()


def esde_is_installed():
    if system == "linux":
        return (esde_folder / "ES-DE.AppImage").exists()
    if system.startswith("win"):
        return (esde_folder / "ES-DE.exe").exists()
    if system == "darwin":
        return (esde_folder / "ES-DE.app").exists()
    return False


def esde_apply_theme(esde_theme_url: str, esde_theme_name: str):
    themes_dir = esde_settings_folder / "themes"
    themes_dir.mkdir(parents=True, exist_ok=True)

    dest = themes_dir / esde_theme_name
    if not dest.exists():
        subprocess.run(["git", "clone", esde_theme_url, str(dest)], check=True)

    settings_file = esde_settings_folder / "settings" / "es_settings.xml"
    text = settings_file.read_text(encoding="utf-8")

    pattern = r'(?<=<string name="ThemeSet" value=").*?(?=" />)'
    new_text = re.sub(pattern, esde_theme_name, text)

    settings_file.write_text(new_text, encoding="utf-8")


def esde_set_default_emulators():
    gamelists_dir = esde_settings_folder / "gamelists"
    gamelists_dir.mkdir(parents=True, exist_ok=True)

    emus = [
        ("Dolphin (Standalone)", "gc"),
        ("PPSSPP (Standalone)", "psp"),
        ("Dolphin (Standalone)", "wii"),
        ("PCSX2 (Standalone)", "ps2"),
        ("melonDS", "nds"),
        ("Azahar (Standalone)", "n3ds"),
        ("Beetle Lynx", "atarilynx"),
        ("DuckStation (Standalone)", "psx"),
        ("Beetle Saturn", "saturn"),
        ("ScummVM (Standalone)", "scummvm"),
    ]

    for label, system_code in emus:
        esde_set_emu(label, system_code)


def esde_set_emu(emu: str, system_code: str) -> None:
    import xml.etree.ElementTree as ET

    gamelist_file = esde_settings_folder / "gamelists" / system_code / "gamelist.xml"
    gamelist_file.parent.mkdir(parents=True, exist_ok=True)

    if gamelist_file.exists():
        try:
            tree = ET.parse(gamelist_file)
            root = tree.getroot()
        except ET.ParseError:
            # File exists but is not valid XML (e.g. dual-root template format).
            # Read as text and handle the alternativeEmulator block manually.
            text = gamelist_file.read_text(encoding="utf-8")
            # Replace existing alternativeEmulator block
            alt_pattern = re.compile(
                r"<alternativeEmulator>\s*<label>[^<]*</label>\s*</alternativeEmulator>"
            )
            new_block = f"<alternativeEmulator>\n\t<label>{emu}</label>\n</alternativeEmulator>"
            if alt_pattern.search(text):
                text = alt_pattern.sub(new_block, text)
            else:
                # Insert before <gameList
                text = new_block + "\n" + text
            gamelist_file.write_text(text, encoding="utf-8")
            print(f"Updated {system_code} alternative emulator to '{emu}' (text mode)")
            return

        # Valid XML — modify in-place
        alt_emu = root.find("alternativeEmulator")
        if alt_emu is None:
            alt_emu = ET.SubElement(root, "alternativeEmulator")

        label_el = alt_emu.find("label")
        if label_el is None:
            label_el = ET.SubElement(alt_emu, "label")
        label_el.text = emu

        tree.write(gamelist_file, xml_declaration=True, encoding="unicode")
        print(f"Updated {system_code} alternative emulator to '{emu}'")
    else:
        # Create new gamelist with alternativeEmulator
        root = ET.Element("gameList")
        alt_emu = ET.SubElement(root, "alternativeEmulator")
        label_el = ET.SubElement(alt_emu, "label")
        label_el.text = emu
        tree = ET.ElementTree(root)
        tree.write(gamelist_file, xml_declaration=True, encoding="unicode")
        print(f"Created {system_code} gamelist with emulator '{emu}'")


def esde_add_to_steam():
    set_msg("Adding ES-DE to Steam")

    if system in ("linux", "darwin"):
        launcher = str(tools_path / "launchers/es-de/es-de.sh")
        icon_path = str(emudeck_backend / "icons/ES-DE.png")
        start_dir = str(esde_settings_folder)
    elif system.startswith("win"):
        launcher = str(tools_path / "launchers/es-de/es-de.bat")
        icon_path = str(emudeck_backend / "icons/ico/es-de.ico")
        start_dir = str(esde_folder)
    else:
        return

    add_steam_shortcut(
        "esde",
        "EmulationStationDE",
        launcher,
        start_dir,
        str(icon_path),
    )