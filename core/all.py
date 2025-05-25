import core.imports            # Carga módulos y variables globales
from core.imports import *     # Expone en este espacio nombres de imports.py
from core.vars import *
import functions

def _import_all_functions_and_vars():
    project_root = Path(__file__).resolve().parent.parent
    if str(project_root) not in sys.path:
        sys.path.insert(0, str(project_root))

    all_modules = []
    for finder, module_name, is_pkg in pkgutil.walk_packages(functions.__path__,
                                                            prefix=functions.__name__ + "."):
        all_modules.append(module_name)

    forced = [
        "functions.helpers",
        "functions.tools_scripts.emudeck_plugins",
        "functions.mocks",
        "functions.vdf",
        "functions.tools_scripts.emudeck_esde",
        # …add any others you need first…
    ]

    forced_to_load = [m for m in forced if m in all_modules]
    missing_forced = [m for m in forced if m not in all_modules]
    if missing_forced:
        print("⚠️ Forced modules not found:", missing_forced)

    remaining = sorted(m for m in all_modules if m not in forced_to_load)

    for module_name in forced_to_load + remaining:
        #print(f"Importing module: {module_name}")
        module = importlib.import_module(module_name)

        for fn_name, fn in inspect.getmembers(module, inspect.isfunction):
            globals()[fn_name] = fn

        for var_name, val in vars(module).items():
            if (not var_name.startswith("_")
                and not inspect.isfunction(val)
                and not inspect.ismodule(val)):
                globals()[var_name] = val

_import_all_functions_and_vars()

__all__ = [n for n in globals().keys() if not n.startswith("_")]
