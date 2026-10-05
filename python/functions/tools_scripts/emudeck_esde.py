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
esde_settings_file = esde_settings_folder / "settings" / "es_settings.xml"


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

    if hybrid_mode:
        esde_add_custom_systems_file()
        source = Path(bash_backend) / "configs" / "emulationstation"
        copy_with_backup(source / "es_settings.xml", esde_settings_file)
        copy_with_backup(source / "custom_systems" / "es_find_rules.xml", esde_rules_file)
        copy_with_backup(source / "custom_systems" / "es_systems.xml", esde_systems_file)
        esde_set_default_settings()
    else:
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
            sed("/run/media/mmcblk0p1/Emulation", emulation_path, config_file)
            ext = ".bat" if system.startswith("win") else ".sh"
            sed(".EXT", ext, config_file)

    if not hybrid_mode:
        dlmedia = Path(storage_path / "es-de/downloaded-media")
        dlmedia.mkdir(parents=True, exist_ok=True)

    esde_set_default_emulators()
    if hybrid_mode:
        esde_apply_theme(esde_theme_url, esde_theme_name)
        esde_migrate_downloaded_media()
    if system == "linux":
        esde_symlink_gamelists()
        add_steam_input_custom_icons()
        esde_flush_tool_launcher()
        srm_flush_old_symlinks()
    if hybrid_mode:
        esde_link_downloaded_media()
    esde_add_arm_cores()


def esde_set_default_settings():
    if not esde_settings_file.is_file():
        return False
    update_or_append_config_line(esde_settings_file, '<string name="ROMDirectory"', f'<string name="ROMDirectory" value="{roms_path}" />')
    media_line = f'<string name="MediaDirectory" value="{ESDEscrapData}" />'
    text = esde_settings_file.read_text(encoding="utf-8")
    if "MediaDirectory" not in text:
        update_or_append_config_line(esde_settings_file, '<string name="MediaDirectory"', media_line)
    elif '<string name="MediaDirectory" value="" />' not in text or "Emulation/tools/downloaded_media" in text:
        update_or_append_config_line(esde_settings_file, '<string name="MediaDirectory"', media_line)
    return True


def esde_migrate_downloaded_media():
    original = esde_settings_folder / "downloaded_media"
    if original.is_symlink():
        original.unlink()
    elif original.is_dir():
        shutil.copytree(original, Path(tools_path) / "downloaded_media", symlinks=True, dirs_exist_ok=True)
        shutil.rmtree(original)
    return True


def esde_link_downloaded_media():
    link = Path(storage_path) / "downloaded_media"
    if link.is_symlink():
        link.unlink()
    if not link.exists():
        link.symlink_to(Path(ESDEscrapData))
    return True


def esde_add_arm_cores():
    if not (system == "linux" and cpu_arch == "arm"):
        return
    for xml in (esde_systems_file, esde_rules_file):
        if xml.exists():
            sed("<!--armcores", "", xml)
            sed("armcores-->", "", xml)
    gamelist = esde_settings_folder / "gamelists" / "ps2" / "gamelist.xml"
    if gamelist.is_file():
        sed("PCSX2", "ARMSX2", gamelist)


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


def esde_ensure_cemu_find_rule():
    if not esde_rules_file.exists():
        return
    ext = "bat" if system.startswith("win") else "sh"
    entry = f"{tools_path}/launchers/cemu.{ext}"
    content = esde_rules_file.read_text(encoding="utf-8")
    if f"<entry>{entry}</entry>" in content:
        return
    if 'name="CEMU"' in content:
        content = re.sub(
            r'(<emulator name="CEMU">.*?)<entry>.*?</entry>(.*?</emulator>)',
            rf"\1<entry>{entry}</entry>\2",
            content,
            count=1,
            flags=re.DOTALL,
        )
    else:
        rule_block = (
            '    <emulator name="CEMU">\n'
            '        <rule type="staticpath">\n'
            f'            <entry>{entry}</entry>\n'
            '        </rule>\n'
            '    </emulator>\n'
        )
        content = content.replace("</ruleList>", rule_block + "</ruleList>")
    esde_rules_file.write_text(content, encoding="utf-8")


def esde_ensure_ps3_emulators():
    ps3_roms = roms_path / "ps3"
    if not ps3_roms.is_dir():
        return
    gamelist = esde_settings_folder / "gamelists" / "ps3" / "gamelist.xml"
    tool = Path(emudeck_backend) / "tools" / "esde_ps3_emulators.py"
    if not tool.is_file():
        return
    env = dict(os.environ)
    env["PS3_ROMS_DIR"] = str(ps3_roms)
    env["PS3_GAMELIST"] = str(gamelist)
    subprocess.run(
        [sys.executable, str(tool)],
        check=False,
        env=env,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def esde_launch_fixes():
    esde_ensure_ryujinx_find_rule()
    esde_ensure_cemu_find_rule()
    esde_ensure_ps3_emulators()


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
    if dest.is_dir():
        subprocess.run(["git", "-C", str(dest), "pull"])
    else:
        subprocess.run(["git", "clone", esde_theme_url, str(dest)])

    for key in ("ThemeSet", "Theme"):
        update_or_append_config_line(esde_settings_file, f'<string name="{key}"', f'<string name="{key}" value=""')
    text = esde_settings_file.read_text(encoding="utf-8")
    for key in ("ThemeSet", "Theme"):
        new_line = f'<string name="{key}" value="{esde_theme_name}"/>'
        text = re.sub(rf'<string name="{key}" value="[^"]*"', lambda _: new_line, text)
    esde_settings_file.write_text(text, encoding="utf-8")
    return True


def esde_set_default_emulators():
    from functions.emus_scripts.emudeck_melonds import melonds_is_installed, melonds_set_esde_emu
    from functions.emus_scripts.emudeck_mgba import mgba_is_installed, mgba_set_esde_emu
    from functions.emus_scripts.emudeck_flycast import flycast_is_installed, flycast_set_esde_emu
    from functions.emus_scripts.emudeck_mame import mame_is_installed, mame_set_esde_emu
    from functions.emus_scripts.emudeck_bigpemu import bigpemu_is_installed, bigpemu_set_esde_emu

    gamelists_dir = esde_settings_folder / "gamelists"
    gamelists_dir.mkdir(parents=True, exist_ok=True)

    emus = [
        ("Dolphin (Standalone)", "gc"),
        ("PPSSPP (Standalone)", "psp"),
        ("Dolphin (Standalone)", "wii"),
        ("PCSX2 (Standalone)", "ps2"),
        ("Azahar (Standalone)", "n3ds"),
        ("Beetle Lynx", "atarilynx"),
        ("DuckStation (Standalone)", "psx"),
        ("Beetle Saturn", "saturn"),
        ("ScummVM (Standalone)", "scummvm"),
        ("Ryujinx (Standalone)", "switch"),
    ]

    for label, system_code in emus:
        esde_set_emu(label, system_code)

    if melonds_is_installed():
        melonds_set_esde_emu()
    else:
        esde_set_emu("melonDS DS", "nds")

    for is_installed, set_esde_emu in (
        (mgba_is_installed, mgba_set_esde_emu),
        (flycast_is_installed, flycast_set_esde_emu),
        (mame_is_installed, mame_set_esde_emu),
        (bigpemu_is_installed, bigpemu_set_esde_emu),
    ):
        if is_installed():
            set_esde_emu()


def esde_set_emu(emu: str, system_code: str) -> None:
    """Sets a system's default emulator in its ES-DE gamelist, keeping alternativeEmulator at the top level where ES-DE reads it."""
    gamelist_file = esde_settings_folder / "gamelists" / system_code / "gamelist.xml"
    gamelist_file.parent.mkdir(parents=True, exist_ok=True)

    if not gamelist_file.exists():
        if hybrid_mode:
            template = Path(bash_backend) / "configs" / "emulationstation" / "gamelists" / system_code / "gamelist.xml"
        else:
            template = Path(emudeck_backend) / "configs" / "common" / "emulationstation" / "gamelists" / system_code / "gamelist.xml"
        if template.is_file():
            shutil.copy(template, gamelist_file)
        else:
            gamelist_file.write_text('<?xml version="1.0"?>\n<gameList />\n', encoding="utf-8")

    text = gamelist_file.read_text(encoding="utf-8")
    label = f"<label>{emu}</label>"
    block = re.search(r"<alternativeEmulator>.*?</alternativeEmulator>", text, re.S)
    if block:
        current = block.group(0)
        if "<label>" in current:
            updated = re.sub(r"<label>[^<]*</label>", lambda _: label, current, count=1)
        else:
            updated = f"<alternativeEmulator>\n    {label}\n</alternativeEmulator>"
        text = text[:block.start()] + updated + text[block.end():]
    else:
        declaration = re.match(r"\s*<\?xml[^>]*\?>\s*\n?", text)
        position = declaration.end() if declaration else 0
        text = text[:position] + f"<alternativeEmulator>\n    {label}\n</alternativeEmulator>\n" + text[position:]

    gamelist_file.write_text(text, encoding="utf-8")
    print(f"Set {system_code} alternative emulator to '{emu}'")


def esde_add_custom_systems_file() -> bool:
    for junk in (esde_settings_folder / "settings", esde_settings_folder / "custom_systems"):
        if junk.is_file():
            junk.unlink()

    if hybrid_mode:
        source = Path(bash_backend) / "configs" / "emulationstation" / "custom_systems" / "es_systems.xml"
    else:
        source = Path(emudeck_backend) / "configs" / "common" / "emulationstation" / "custom_systems" / "es_systems.xml"

    esde_systems_file.parent.mkdir(parents=True, exist_ok=True)
    if not esde_systems_file.exists() and source.is_file():
        shutil.copy2(source, esde_systems_file)
        if not hybrid_mode:
            sed("EMULATIONPATH", emulation_path, esde_systems_file)
            sed(".EXT", ".bat" if system.startswith("win") else ".sh", esde_systems_file)
    return True


def esde_flush_tool_launcher():
    source = get_launchers_source_dir() / "es-de" / "es-de.sh"
    destination = Path(tools_path) / "launchers" / "es-de" / "es-de.sh"
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)
    destination.chmod(destination.stat().st_mode | 0o111)
    return True


def esde_symlink_gamelists():
    old = Path(saves_path) / "es-de"
    if old.is_symlink():
        old.unlink()
    elif old.exists():
        shutil.rmtree(old, ignore_errors=True)
    link_to_storage_folder(esde_settings_folder / "gamelists", "es-de/gamelists")
    return True


def esde_add_to_steam():
    set_msg("Adding ES-DE to Steam")

    if system in ("linux", "darwin"):
        launcher = str(tools_path / "launchers/es-de/es-de.sh")
        icon_path = str(icons_path / "ES-DE.png")
        start_dir = str(esde_settings_folder)
    elif system.startswith("win"):
        launcher = str(tools_path / "launchers/es-de/es-de.bat")
        icon_path = str(icons_path / "ico/es-de.ico")
        start_dir = str(esde_folder)
    else:
        return

    add_steam_shortcut(
        "esde",
        "EmulationStationDE",
        launcher,
        start_dir,
        str(icon_path),
        recent=True,
    )