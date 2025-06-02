from core.all import *

def wrappers_install():
    sh_path_dest=f"{tools_path}/wrappers/update-emulators.sh"
    shutil.copy2(f"{emudeck_backend}/tools/wrappers/update-emulators.sh", sh_path_dest)
    current_mode = sh_path_dest.stat().st_mode
    sh_path_dest.chmod(current_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)