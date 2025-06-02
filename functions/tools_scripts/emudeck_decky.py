from core.all import *

#Wrappers for old functions names

def Decky_autoSave():
    retroarch_auto_save()
    if settings.autosave == False:
        set_setting("autosave",True)
    else:
        set_setting("autosave",False)

def Decky_bezels():
    if settings.bezels == False:
        retroarch_bezel_on_all()
        set_setting("bezels",True)
    else:
        retroarch_bezel_off_all()
        set_setting("bezels",False)

def Decky_shaders_LCD():
    if settings.shaders.handhelds == False:
        retroarch_matrix_shaders_on_all()
        set_setting("shaders.handhelds",True)
    else:
        retroarch_matrix_shaders_on_all()
        set_setting("shaders.handhelds",False)

def Decky_shaders_2D():
    if settings.shaders.classic == False:
        retroarch_crt_shader_on_all()
        set_setting("shaders.classic",True)
    else:
        retroarch_crt_shader_off_all()
        set_setting("shaders.classic",False)

def Decky_shaders_3D():
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

def Decky_setAR():
    retroarch_set_customizations()
    xemu_widescreen()
    duckstation_widescreen()
    #PCSX2QT_setCustomizations
    #Dolphin_setCustomizations