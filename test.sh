#!/bin/bash

user=$(zenity --entry --title="ScreenScrapper" --text="User:")
password=$(zenity --password --title="ScreenScrapper" --text="Password:")

encryption_key=$(openssl rand -base64 32)
encrypted_password=$(echo "$password" | openssl enc -aes-256-cbc -pbkdf2 -base64 -pass "pass:$encryption_key")

echo "$encryption_key" > "$HOME/.config/EmuDeck/logs/.key"
echo "$encrypted_password" > "$HOME/.config/EmuDeck/.passSS"
echo "$user" > "$HOME/.config/EmuDeck/.userSS"


#############

encryption_key=$(cat "$HOME/.config/EmuDeck/logs/.key")

encrypted_password=$(cat "$HOME/.config/EmuDeck/.passSS")

decrypted_password=$(echo "$encrypted_password" | openssl enc -d -aes-256-cbc -pbkdf2 -base64 -pass "pass:$encryption_key")

echo $decrypted_password
