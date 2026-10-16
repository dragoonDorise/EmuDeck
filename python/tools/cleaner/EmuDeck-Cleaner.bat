@echo off
cd /d "%APPDATA%\EmuDeck\backend\tools\cleaner"
python cleaner.py
echo.
echo Press any key to close...
pause >nul
