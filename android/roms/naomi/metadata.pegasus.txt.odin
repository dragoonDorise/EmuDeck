collection: Sega Naomi
shortname: naomi
extensions: 7z, bin, cdi, chd, cue, dat, elf, gdi, iso, lst, m3u, zip
launch: am start
  -n com.retroarch/.browser.retroactivity.RetroActivityFuture
  -e ROM {file.path}
  -e LIBRETRO /data/data/com.retroarch/cores/flycast_libretro_android.so
  -e CONFIGFILE /storage/emulated/0/Android/data/com.retroarch/files/retroarch.cfg
  -e IME com.android.inputmethod.latin/.LatinIME
  -e DATADIR /data/data/com.retroarch
  -e APK /data/app/com.retroarch-1/base.apk
  -e SDCARD /storage/emulated/0
  -e EXTERNAL /storage/emulated/0/Android/data/com.retroarch/files