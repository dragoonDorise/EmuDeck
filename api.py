from functions.env import generate_python_env
generate_python_env()
from core.all import *

def resolve_func(func_path):
    if "." in func_path:
        module_name, func_name = func_path.rsplit(".", 1)
        module = importlib.import_module(module_name)
    else:
        module = importlib.import_module("__main__")
        func_name = func_path
    return getattr(module, func_name)

def run_single(func_path, argv_rest, silent):
    args_list = []
    kwargs_dict = {}
    if len(argv_rest) >= 1:
        maybe = argv_rest[0]
        if maybe.startswith("["):
            try:
                args_list = json.loads(maybe)
                if not isinstance(args_list, list):
                    raise ValueError()
            except Exception:
                return {"status": "KO", "error": "Error: args_json must be a JSON array."}
        else:
            args_list = list(argv_rest)
    if len(argv_rest) >= 2:
        try:
            kwargs_dict = json.loads(argv_rest[1])
            if not isinstance(kwargs_dict, dict):
                raise ValueError()
        except Exception:
            pass

    try:
        func = resolve_func(func_path)
    except (ModuleNotFoundError, AttributeError) as e:
        return {"status": "KO", "error": f"Function not found: {e}"}

    return call_func(func, *args_list, silent=silent, **kwargs_dict)

def run_batch(batch_json, silent):
    try:
        calls = json.loads(batch_json)
        if not isinstance(calls, list):
            raise ValueError()
    except Exception:
        return {"status": "KO", "error": "Error: --batch expects a JSON array."}

    results = []
    for entry in calls:
        if not isinstance(entry, dict) or "func" not in entry:
            results.append({"status": "KO", "error": "Each entry must be an object with a 'func' key."})
            continue
        func_path = entry["func"]
        args_list = entry.get("args", [])
        kwargs_dict = entry.get("kwargs", {})
        try:
            func = resolve_func(func_path)
        except (ModuleNotFoundError, AttributeError) as e:
            results.append({"status": "KO", "error": f"Function not found: {e}"})
            continue
        results.append(call_func(func, *args_list, silent=silent, **kwargs_dict))
    return results

def main():
    if len(sys.argv) < 2:
        payload = {"status": "KO", "error": "Usage: python api.py <module.func|func> [args_json] [kwargs_json] [--no-silent] | python api.py --batch '<json_array>' [--no-silent]"}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.exit(1)

    silent = True
    argv = list(sys.argv[1:])
    if "--no-silent" in argv:
        silent = False
        argv.remove("--no-silent")

    if argv[0] == "--batch":
        if len(argv) < 2:
            payload = {"status": "KO", "error": "Error: --batch requires a JSON array argument."}
            sys.stdout.write(json.dumps(payload) + "\n")
            sys.exit(1)
        payload = run_batch(argv[1], silent)
    else:
        payload = run_single(argv[0], argv[1:], silent)

    sys.stdout.write(json.dumps(payload) + "\n")

if __name__ == "__main__":
    main()