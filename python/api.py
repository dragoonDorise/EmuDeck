import os, sys
if "--hybrid" in sys.argv:
    os.environ["EMUDECK_HYBRID"] = "1"
    sys.argv.remove("--hybrid")

from functions.env import generate_python_env
generate_python_env()

#We clean up the output noise
real_stdout = os.dup(1)
os.dup2(2, 1)

from core.all import *

def call(func, *args, **kwargs):
    """Calls func letting its output reach the logs and wraps the result as OK/KO."""
    try:
        result = func(*args, **kwargs)
    except Exception as e:
        traceback.print_exc()
        return {"status": "KO", "error": str(e)}
    if result is False:
        return {"status": "KO"}
    return {"status": "OK", "result": result}

def resolve_func(func_path):
    if "." in func_path:
        module_name, func_name = func_path.rsplit(".", 1)
        module = importlib.import_module(module_name)
    else:
        module = importlib.import_module("__main__")
        func_name = func_path
    return getattr(module, func_name)

def run_single(func_path, argv_rest):
    """ Runs a single function... """
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

    return call(func, *args_list, **kwargs_dict)

def run_batch(batch_json):
    """ Runs a batch of multiple functions... """
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
        results.append(call(func, *args_list, **kwargs_dict))
    return results

def respond(payload):
    """Writes the JSON payload to the real stdout and exits with 0 only if every call is OK."""
    if isinstance(payload, dict):
        payload["progress"] = getattr(sys.modules.get("functions.helpers"), "progress_bar", None)
    os.write(real_stdout, (json.dumps(payload, default=str) + "\n").encode("utf-8"))
    results = payload if isinstance(payload, list) else [payload]
    sys.exit(0 if all(isinstance(r, dict) and r.get("status") == "OK" for r in results) else 1)

def main():
    argv = list(sys.argv[1:])
    if not argv:
        respond({"status": "KO", "error": "Usage: python api.py [--hybrid] <module.func|func> [args_json] [kwargs_json] | python api.py [--hybrid] --batch '<json_array>'"})

    if argv[0] == "--batch":
        if len(argv) < 2:
            respond({"status": "KO", "error": "Error: --batch requires a JSON array argument."})
        respond(run_batch(argv[1]))

    respond(run_single(argv[0], argv[1:]))

if __name__ == "__main__":
    main()
