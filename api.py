from functions.env import generate_python_env
generate_python_env()
from core.all import *

def main():
    # Necesitamos al menos el nombre de la función
    if len(sys.argv) < 2:
        payload = {"status": "KO", "error": "Usage: python api.py <module.func|func> [args_json] [kwargs_json] [--no-silent]"}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.exit(1)

    # argv[1] = función a ejecutar
    func_path = sys.argv[1]

    # Flags
    silent = True
    if "--no-silent" in sys.argv:
        silent = False
        sys.argv.remove("--no-silent")

    # Parsear args / kwargs JSON si los hay
    args_list = []
    kwargs_dict = {}
    if len(sys.argv) >= 3:
        maybe = sys.argv[2]
        if maybe.startswith("["):
            try:
                args_list = json.loads(maybe)
                if not isinstance(args_list, list):
                    raise ValueError()
            except Exception:
                payload = {"status": "KO", "error": "Error: args_json must be a JSON array."}
                sys.stdout.write(json.dumps(payload) + "\n")
                sys.exit(1)
        else:
            # args planos: todo lo que venga a partir de argv[2]
            args_list = sys.argv[2:]
    if len(sys.argv) >= 10:
        try:
            kwargs_dict = json.loads(sys.argv[3])
            if not isinstance(kwargs_dict, dict):
                raise ValueError()
        except Exception:
            payload = {"status": "KO", "error": "Error: kwargs_json must be a JSON object."}
            sys.stdout.write(json.dumps(payload) + "\n")
            sys.exit(1)

    # Importar dinámicamente la función
    try:
        if "." in func_path:
            module_name, func_name = func_path.rsplit(".", 1)
            module = importlib.import_module(module_name)
        else:
            module = importlib.import_module("__main__")
            func_name = func_path
        func = getattr(module, func_name)
    except (ModuleNotFoundError, AttributeError) as e:
        # Si no la encontramos, devolvemos KO
        payload = {"status": "KO", "error": f"Function not found: {e}"}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.exit(1)

    # Llamar a la función
    payload = call_func(func, *args_list, silent=silent, **kwargs_dict)

    # Imprimir el JSON resultante
    sys.stdout.write(json.dumps(payload) + "\n")

if __name__ == "__main__":
    main()