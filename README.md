# EmuDeck

[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/from-referrer/)
<img src="https://www.emudeck.com/img/hero.png">

EmuDeck is a collection of scripts that allows you to autoconfigure your Steam Deck or any other Linux Distro, it creates your roms directory structure and downloads all of the needed Emulators for you along with the best configurations for each of them. EmuDeck works great with [Steam Rom Manager](https://github.com/SteamGridDB/steam-rom-manager) or with [EmulationStation DE](https://es-de.org)

# How to use EmuDeck?

We recomend you take a look at our extensive Wiki, you'll find guides, videos and all sorts of content about the project:

[EmuDeck Wiki](https://emudeck.github.io/how-to-install-emudeck/steamos/)

# Developers, developers, developers.

If you wanna help us improve EmuDeck we are open to accept your PR! Just keep in mind this simple guide:

- Think that EmuDeck is for everybody, tech savvy and is specially directed to regular users that are new to Emulation, so everything has to be properly explained.
- Things using sudo are a big no no, there are exceptions but always try to find a way of prevent using sudo.
- Every Emulator needs to have a SRM profile and follow the AmberElec hotkey mapping.
- Always do your PR to the dev branch.

## Submitting a PR Request for a Steam ROM Manager Parser

If you would like to submit a PR request for a Steam ROM Manager parser, use the following format:

### The Basics

- Spell out console names - no acronyms
  - For example, `PSP` should be spelled out as `PlayStation Portable`
- Respect original capitalization and spacing
  - A few examples:
    - `RetroArch` uses a capital `R` and capital `A`
    - The `Nintendo Game Boy` uses a capital `N`, `G`, and `B` with spaces between each word
    - The `PlayStation Portable` uses a capital `P` and `S` in `PlayStation` as do the other `PlayStation` handhelds and consoles

### Parser Structure

- `configTitle`:
  - `COMPANYNAME SYSTEMNAME - EMULATORNAME RETROARCHCORENAME`
    - If the standalone emulator name is identical to the RetroArch core name, add `(Standalone)` behind the `EMULATORNAME`
  - A few examples:
    - Config Title: `"configTitle": "Amiga - RetroArch PUAE",`
    - Config Title: `"configTitle": "Nintendo Game Boy Color - mGBA (Standalone)",`
    - Config Title: `"configTitle": "Sony PlayStation 2 - PCSX2",`
- `steamCategory`:
  - **Note:** Non-Default Parsers refer to when a system has multiple emulation choices (through alternative emulators or RetroArch cores). Only one of these parsers is enabled by default and any alternative choices are disabled by default.
  - Default Parsers:
    - `COMPANYNAME CONSOLENAME`
  - Non-Default Parsers:
    - Standalone: `COMPANYNAME CONSOLENAME - EMULATORNAME`
    - RetroArch Core: `COMPANYNAME CONSOLENAME - RETROARCHCORENAME`
      - If the RetroArch core's name is identical to the Standalone emulator name, add `RetroArch` in front of the `RETROARCHCORENAME`
      - If the standalone emulator name is identical to the RetroArch core name, add `(Standalone)` behind the `EMULATORNAME`
  - A few examples:
    - Default Parsers:
      - Mupen64Plus Next (RetroArch core for Nintendo 64)
        - Steam Category Name: `"steamCategory": ""${Nintendo 64}",`
      - DuckStation (PSX Emulator)
        - Steam Category Name: `"steamCategory": "${Sony PlayStation}",`
    - Non-Default Parsers:
      - Rosalie's Mupen GUI (N64 Emulator)
        - Steam Category Name: `"steamCategory": "${Nintendo 64 - Rosalie's Mupen GUI}",`
      - Beetle PSX HW (RetroArch core for PSX)
        - Steam Category Name: `"steamCategory": "${Sony PlayStation - Beetle PSX HW}",`

### Parser Filename

`companyname_systemname-emulatorname-retroarchcore.json`

If it is a RetroArch core, replace `emulatorname` with `ra`.

- A few examples:
  - `nintendo_wii-dolphin.json`
  - `nintendo_64-rmg.json`
  - `nintendo_gba-ra-mgba.json`
  - `sega_saturn-ra-mednafen.json`
