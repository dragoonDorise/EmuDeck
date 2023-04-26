#!/bin/bash

uninstallEmuFP() {
    ID=$1
    flatpak uninstall "$ID" -y --user
    flatpak uninstall "$ID" -y --system
}
