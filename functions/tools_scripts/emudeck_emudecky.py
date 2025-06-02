from core.all import *

#Wrappers for old functions names

def decky_autoSave():
    retroarch_auto_save()
    if settings.autosave == False:
        set_setting("autosave",True)
    else:
        set_setting("autosave",False)

def decky_bezels():
    if settings.bezels == False:
        retroarch_bezel_on_all()
        set_setting("bezels",True)
    else:
        retroarch_bezel_off_all()
        set_setting("bezels",False)

def decky_shaders_LCD():
    if settings.shaders.handhelds == False:
        retroarch_matrix_shaders_on_all()
        set_setting("shaders.handhelds",True)
    else:
        retroarch_matrix_shaders_on_all()
        set_setting("shaders.handhelds",False)

def decky_shaders_2D():
    if settings.shaders.classic == False:
        retroarch_crt_shader_on_all()
        set_setting("shaders.classic",True)
    else:
        retroarch_crt_shader_off_all()
        set_setting("shaders.classic",False)

def decky_shaders_3D():
    if settings.shaders.classic3d == False:
        retroarch_3d_crt_shader_on_all()
        set_setting("shaders.classic3d",True)
    else:
        retroarch_3d_crt_shader_on_all()
        set_setting("shaders.classic3d",False)

def Dolphin_setCustomizations():
    print("NYI")

def RetroArch_setCustomizations():
    retroarch_set_customizations()

def decky_netplay():
    if settings.netPlay == False:
        set_setting("netPlay",True)
    else:
        set_setting("netPlay",False)

def decky_cloud_sync_status():
    if settings.cloud_sync_status == True:
        set_setting("cloud_sync_status",False)
    else:
        set_setting("cloud_sync_status",True)

def decky_set_ar_sega(value):
    set_setting("ar.sega",value)
    retroarch_set_customizations()

def decky_set_ar_nintendo(value):
    set_setting("ar.snes",value)
    retroarch_set_customizations()

def decky_set_ar_3d(value):
    set_setting("ar.classic3d",value)
    xemu_widescreen()
    duckstation_widescreen()

def decky_set_ar_dolphin(value):
    set_setting("ar.dolphin",value)
