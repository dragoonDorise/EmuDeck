# EmuDeck
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-908a85?logo=gitpod)](https://gitpod.io/from-referrer/)
<img src="https://www.emudeck.com/img/hero.png">

EmuDeck is a collection of scripts that allows you to autoconfigure your Steam Deck, it creates your roms directory structure and downloads all of the needed Emulators for you along with the best configurations for each of them. EmuDeck works great with [Steam Rom Manager](https://github.com/SteamGridDB/steam-rom-manager) or with [EmulationStation DE](https://es-de.org)

** If you are a dev please read till the bottom **

There are two ways of using EmuDeck:

## Using Steam Rom Manager

<img src="https://www.emudeck.com/img/ss1.png">

This option gives you all your games presented with their box arts as if they were a regular Steam Game.
EmuDeck has preloaded configurations for Steam Rom Manager for the following systems:

https://emudeck.github.io/emulators/steamos/supported-emulators/

## Using EmulationStation DE

<img src="https://es-de.org/____impro/1/onewebmedia/ES-DE_logo.png?etag=%226071-6041244a%22&sourceContentType=image%2Fpng&ignoreAspectRatio&resize=240%2B168">

EmuDeck configures EmulationStation DE to use the same rom folders that EmuDeck creates for you and it even downloads all the emulators and cores the ES-DE needs, all configurations that EmuDeck installs are carried over when using EmulationStation DE. For a comprehensive list of all the systems that ESDE supports go to [ES-DE](https://es-de.org)

# Hotkeys

We try to use the same hotkeys for every emulator but some of them have their own different hotkeys, shown here:

https://emudeck.github.io/controls-and-hotkeys/windows/hotkeys/?h=hotkeys

Note that Nintendo-oriented emulators refer to "A" in the emulated sense (physical Steam Deck "B")

# Developers, developers, developers.

If you wanna help us improve EmuDeck we are open to accept your PR! Just keep in mind this simple guide:

- Think EmuDeck is for everybody, tech savvy and regular users, so everything has to be properly explained, use Easy mode for unattended automatic stuff.
- User input is non recommended, everything should be done with no mouse or keyboard input. If input is a must then you have to code your feature only on expert mode.
- Things using sudo are a big no no, there are exceptions but always try to find a way of prevent using sudo.
- Every Emulator added has to be included on this readme file, have a SRM profile and follow the AmberElec hotkey mapping ( just check the previous table)
- Always do your PR to the dev branch.

## Submitting a PR Request for a Steam ROM Manager Parser

If you would like to submit a PR request for a Steam ROM Manager parser, use the following format:

### The Basics

* Spell out console names - no acronyms
    * For example, `PSP` should be spelled out as `PlayStation Portable`
* Respect original capitalization and spacing 
    * A few examples:
        * `RetroArch` uses a capital `R` and capital `A`
        * The `Nintendo Game Boy` uses a capital `N`, `G`, and `B` with spaces between each word
        * The `PlayStation Portable` uses a capital `P` and `S` in `PlayStation` as do the other `PlayStation` handhelds and consoles

### Parser Structure

* `configTitle`: 
    * `COMPANYNAME SYSTEMNAME - EMULATORNAME RETROARCHCORENAME`
        * If the standalone emulator name is identical to the RetroArch core name, add `(Standalone)` behind the `EMULATORNAME`
    * A few examples:
        * Config Title: `"configTitle": "Amiga - RetroArch PUAE",` 
        * Config Title: `"configTitle": "Nintendo Game Boy Color - mGBA (Standalone)",`
        * Config Title: `"configTitle": "Sony PlayStation 2 - PCSX2",`
* `steamCategory`:
    * **Note:** Non-Default Parsers refer to when a system has multiple emulation choices (through alternative emulators or RetroArch cores). Only one of these parsers is enabled by default and any alternative choices are disabled by default.  
    * Default Parsers:
        * `COMPANYNAME CONSOLENAME`
    * Non-Default Parsers:
        * Standalone: `COMPANYNAME CONSOLENAME - EMULATORNAME`
        * RetroArch Core: `COMPANYNAME CONSOLENAME - RETROARCHCORENAME`
            * If the RetroArch core's name is identical to the Standalone emulator name, add `RetroArch` in front of the `RETROARCHCORENAME`
            * If the standalone emulator name is identical to the RetroArch core name, add `(Standalone)` behind the `EMULATORNAME`
    * A few examples: 
        * Default Parsers:  
            * Mupen64Plus Next (RetroArch core for Nintendo 64)
                * Steam Category Name: `"steamCategory": ""${Nintendo 64}",`
            * DuckStation  (PSX Emulator)
                * Steam Category Name: `"steamCategory": "${Sony PlayStation}",`
        * Non-Default Parsers:
            * Rosalie's Mupen GUI (N64 Emulator) 
                * Steam Category Name: `"steamCategory": "${Nintendo 64 - Rosalie's Mupen GUI}",`
            * Beetle PSX HW (RetroArch core for PSX)
                * Steam Category Name: `"steamCategory": "${Sony PlayStation - Beetle PSX HW}",`

### Parser Filename

`companyname_systemname-emulatorname-retroarchcore.json`

If it is a RetroArch core, replace `emulatorname` with `ra`.

* A few examples:
    * `nintendo_wii-dolphin.json`
    * `nintendo_64-rmg.json`
    * `nintendo_gba-ra-mgba.json`
    * `sega_saturn-ra-mednafen.json`
