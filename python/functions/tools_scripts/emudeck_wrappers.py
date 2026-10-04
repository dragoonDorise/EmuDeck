from core.all import *

def wrappers_do_install(script):
    sh_path_dest=Path(f"{tools_path}/wrappers/{script}")
    shutil.copy2(f"{emudeck_backend}/tools/wrappers/{script}", sh_path_dest)
    current_mode = sh_path_dest.stat().st_mode
    sh_path_dest.chmod(current_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)



def wrappers_install():
    #Update Emus
    wrappers_do_install("update-emulators.sh")
    #CloudSync
    wrappers_do_install("cloud_sync_force_download.sh")
    wrappers_do_install("cloud_sync_force_upload.sh")