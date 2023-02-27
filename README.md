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

| System                    | Emulator                                      | Roms format                                                         | File Required in the base of Emulation/bios (or special consideration)                                                                                                                                                    |
| ------------------------- | --------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Atari 2600                | Retroarch Stella core                         | .7z .a26 .bin .zip                                                  |                                                                                                                                                                                                                           |
| Atari Lynx                | Retroarch Beetle Lynx core                    | .7z .lnx .bin .zip                                                  |                                                                                                                                                                                                                           |
| Cloud Services            | Web Browser                                   | .sh                                                                 | cloud/cloud.conf                                                                                                                                                                                                          |
| Final Burn Neo            | Retroarch Fbn core                            | .zip .7z                                                            | Bioses will be searched through 3 folders :<br>\* the folder of the current romset<br>\* the Emulation/bios/fbneo/<br>\* the Emulation/bios/                                                                              |
| Mame 2003 Plus            | Retroarch Mame 2003 Plus core                 | .zip                                                                |                                                                                                                                                                                                                           |
| Mame 2010                 | Retroarch Mame 2010 core                      | .zip                                                                |                                                                                                                                                                                                                           |
| Mame Current              | Retroarch Mame Current core                   | .zip                                                                |                                                                                                                                                                                                                           |
| Microsoft Xbox            | Xemu                                          | .iso (xiso formatted)                                               | Emulation/bios:<br>mcpx\_1.0.bin<br>modified retail "COMPLEX 4627" BIOS<br><br>Emulation/storage/xemu:<br>xbox\_hdd.qcow2                                                                                                 |
| Neo Geo Pocket & Color    | Retroarch Beetle NeoPop                       | .7z .ngp .ngc .bin .zip                                             |                                                                                                                                                                                                                           |
| Nintendo 3DS              | Citra                                         | .3ds .3dsx .app .axf .cci .cxi .elf .cia(FOR INSTALL ONLY)          | Title keys required for encrypted rom types                                                                                                                                                                               |
| Nintendo 64               | Retroarch Mupen64plus-Next                    | .7z .bin .n64 .ndd .u1 .v64 .z64 .zip                               |                                                                                                                                                                                                                           |
| Nintendo DS               | Retroarch melonDS core                        | .7z .nds .zip                                                       | bios7.bin<br>bios9.bin<br>firmware.bin                                                                                                                                                                                    |
| Nintendo GameBoy          | Retroarch Gambatte core                       | .7z .gb .dmg .zip                                                   |                                                                                                                                                                                                                           |
| Nintendo GameBoy Advance  | Retroarch mGBA core                           | .7z .gba .zip                                                       |                                                                                                                                                                                                                           |
| Nintendo GameBoy Color    | Retroarch Gambatte core                       | .7z .gb .gbc .dmg .zip                                              |                                                                                                                                                                                                                           |
| Nintendo GameCube         | Dolphin Standalone                            | .ciso .dol .elf .gcm .gcz .iso .nkit.iso .rvz .wad .wia .wbfs       |                                                                                                                                                                                                                           |
| Nintendo NES              | Retroarch Nestopia core                       | .7z .nes .fds .unf .unif .zip                                       |                                                                                                                                                                                                                           |
| Nintendo PrimeHack        | PrimeHack (Metroid Prime specific)            | .ciso .dol .elf .gcm .gcz .iso .json .nkit.iso .rvz .wad .wia .wbfs |                                                                                                                                                                                                                           |
| Nintendo Switch           | Yuzu                                          | .kp .nca .nro .nso .nsp .xci                                        | Title keys required for encrypted rom types<br>firmware installation with valid mii data required for some games                                                                                                          |
| Nintendo Wii              | Dolphin Standalone                            | .ciso .dol .elf .gcm .gcz .iso .json .nkit.iso .rvz .wad .wia .wbfs |                                                                                                                                                                                                                           |
| Nintendo Wii U            | Cemu                                          | .rpx .wud .wux .elf .iso .wad                                       | Title keys required for encrypted rom types                                                                                                                                                                               |
| Remote Play Clients       | (Chiaki, Moonlight, Parsec)                   | .sh (flatpak)                                                       |                                                                                                                                                                                                                           |
| Sega 32X                  | Retroarch PicoDrive core                      | .7z .32x .bin .zip                                                  |                                                                                                                                                                                                                           |
| Sega CD                   | Retroarch Genesis Plus GX core                | .7z .32x .cue .chd .iso .zip                                        | bios\_CD\_E.bin<br>bios\_CD\_U.bin<br>bios\_CD\_J.bin                                                                                                                                                                     |
| Sega Dreamcast            | Retroarch FlyCast Core                        | .7z .cdi .chd .cue .gdi .m3u                                        | dc/dc\_boot.bin                                                                                                                                                                                                           |
| Sega Game Gear            | Retroarch Genesis Plus GX core                | .7z .gg .zip                                                        |                                                                                                                                                                                                                           |
| Sega Genesis / Mega Drive | Retroarch Genesis Plus GX core                | .7z .gen .md .smd .zip                                              |                                                                                                                                                                                                                           |
| Sega Genesis Widescreen   | Retroarch Genesis Plus GX Wide core           | .7z .gen .md .smd .zip                                              |                                                                                                                                                                                                                           |
| Sega Master System        | Retroarch Genesis Plus GX core                | .7z .gen .sms .zip                                                  |                                                                                                                                                                                                                           |
| Sega Saturn               | Retroarch Yabause core                        | .7z .cue .iso .chd .zip .m3u                                        | sega\_101.bin<br>mpr-17933.bin                                                                                                                                                                                            |
| Sony Playstation          | DuckStation Standalone<br>Retroarch Beetle HW | .cue .chd .ecm .iso .m3u .mds .pbp                                  | scph5500.bin<br>scph5501.bin<br>scph5502.bin                                                                                                                                                                              |
| Sony Playstation 2        | PCSX2 & PCSX2 QT                              | .bin .chd .cso .dump .gz .img .iso .mdf .nrg                        | Bios files are required. Here is an example set:<br>SCPH-70004\_BIOS\_V12\_EUR\_200.BIN<br>SCPH-70004\_BIOS\_V12\_EUR\_200.EROM<br>SCPH-70004\_BIOS\_V12\_EUR\_200.ROM1<br>SCPH-70004\_BIOS\_V12\_EUR\_200.ROM2           |
| Sony Playstation 3        | RPCS3                                         | /PS3\_GAME/USRDIR/eboot.bin                                         | Firmware installation in the Emulator is required.                                                                                                                                                                        |
| Sony Playstation Portable | PPSSPP Standalone<br>PPSSPP Retroarch core    | .7z (RA only) .elf .cso .iso .pbp .prx                              | The retroarch core requires ppsspp.zip in the bios folder.<br>You can obtain it from within RetroArch's downloader.<br>Standalone PPSSPP does not require anything special.                                               |
| Super Nintendo            | Retroarch Snes9x Current core                 | .7z .bs .fig .sfc .smc .swx .zip                                    |                                                                                                                                                                                                                           |
| Super Nintendo Widescreen | Retroarch bsnes hd beta Current core          | .7z .bs .fig .sfc .smc .swx .zip                                    |                                                                                                                                                                                                                           |
| Wonderswan & Color        | Retroarch Beetle Cygne core                   | .7z .pc2 .ws .wsc .zip                                              |

## Using EmulationStation DE

<img src="https://es-de.org/____impro/1/onewebmedia/ES-DE_logo.png?etag=%226071-6041244a%22&sourceContentType=image%2Fpng&ignoreAspectRatio&resize=240%2B168">

EmuDeck configures EmulationStation DE to use the same rom folders that EmuDeck creates for you and it even downloads all the emulators and cores the ES-DE needs, all configurations that EmuDeck installs are carried over when using EmulationStation DE. For a comprehensive list of all the systems that ESDE supports go to [ES-DE](https://es-de.org)

# Hotkeys

We try to use the same hotkeys for every emulator but some of them have their own different hotkeys, shown here:

|  Hotkey                 | RetroArch      | Dolphin        | Citra\*  | Cemu\*         | Yuzu           | PCSX2\*      | RPCS3        | Cloud\*        |
| ----------------------- | -------------- | -------------- | -------- | -------------- | -------------- | ------------ | ------------ | -------------- |
| Menu                    | L3 + R3        | -              | -        | -              | -              | -            | -            | -              |
| Exit                    | Select + Start | Select + Start | R5       | Select + Start | Select + Start | STEAM Button | STEAM Button | Select + Start |
| Pause/Unpause Emulation | Select + A     | Select + A     | -        | -              | Select + A     |              | -            | -              |
| Fast Forward            | Select + R2    | Select + R2    | -        | -              | Select + R2    | Select + R2  | -            | -              |
| Load State              | Select + L1    | Select + L1    | -        | -              | -              | Select + L1  | -            | -              |
| Save State              | Select + R1    | Select + R1    | -        | -              | -              | Select + R1  | -            | -              |
| Full Screen             | -              | -              | L4       | -              | -              | -            | -            | -              |
| Swap Screens            | -              | -              | R4       | R4             | -              | -            | -            | -              |
| Toggle Layout           | -              | -              | L5       | -              | -              | -            | -            | -              |
| Hold Action Set\*       | -              | -              | -        | -              | -              | -            | -            | L4             |

\* You need to activate Steam Input to get those hotkeys to work https://www.emudeck.com/#steam_input

Note that Nintendo-oriented emulators refer to "A" in the emulated sense (physical Steam Deck "B")

# Developers, developers, developers.

If you wanna help us improve EmuDeck we are open to accept your PR! Just keep in mind this simple guide:

- Think EmuDeck is for everybody, tech savvy and regular users, so everything has to be properly explained, use Easy mode for unattended automatic stuff.
- User input is non recommended, everything should be done with no mouse or keyboard input. If input is a must then you have to code your feature only on expert mode.
- Things using sudo are a big no no, there are exceptions but always try to find a way of prevent using sudo.
- Every Emulator added has to be included on this readme file, have a SRM profile and follow the AmberElec hotkey mapping ( just check the previous table)
- Always do your PR to the dev branch.
