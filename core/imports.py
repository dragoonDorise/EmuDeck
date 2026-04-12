from core.vars import emudeck_logs

import os, warnings
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "hide"
warnings.filterwarnings("ignore", message="urllib3 v2 only supports OpenSSL")
import shlex, sys, subprocess, pkgutil, importlib, inspect, json, venv, logging, requests, stat, hashlib, zipfile, re, errno, shutil, subprocess, io, zipfile, tempfile, time, plistlib, zlib, vdf, tarfile, fileinput, ctypes, getpass, threading, socket, traceback, warnings
from multiprocessing import Process
from time import sleep
from math import ceil
from pathlib import Path
from typing import Optional, Union, Callable, Any, Iterable, Callable, Sequence
from pathlib import Path
from contextlib import redirect_stdout, redirect_stderr
from concurrent.futures import ThreadPoolExecutor, as_completed
from PySide6 import QtWidgets, QtCore, QtGui
from PySide6.QtCore import Qt
from io import BytesIO
from requests.exceptions import RequestsDependencyWarning

# 1. Creamos y configuramos el logger raíz
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# 2. Handler para consola (stdout)
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(logging.INFO)
console_formatter = logging.Formatter(
    '%(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)

# 3. Handler para fichero de log
file_handler = logging.FileHandler(emudeck_logs/'emudeck.log', encoding='utf-8')
file_handler.setLevel(logging.DEBUG)
file_formatter = logging.Formatter(
    '%(asctime)s %(levelname)-8s %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
file_handler.setFormatter(file_formatter)
logger.addHandler(file_handler)

# 4. Clase para redirigir sys.stdout y sys.stderr al logger
class StreamToLogger:
    def __init__(self, log_method):
        self.log_method = log_method

    def write(self, message):
        message = message.rstrip()
        if message:
            self.log_method(message)

    def flush(self):
        pass

# 5. Redirigimos stdout y stderr
sys.stdout = StreamToLogger(logger.info)
sys.stderr = StreamToLogger(logger.error)


# ─── Single QApplication + QSS ───────────────────────────────────────────────

_qapp: Optional[QtWidgets.QApplication] = None

def ensure_app() -> QtWidgets.QApplication:
    global _qapp
    if _qapp is None:
        _qapp = QtWidgets.QApplication.instance() or QtWidgets.QApplication(sys.argv)
        qss = Path(__file__).parent / "dialog.qss"
        if qss.exists():
            _qapp.setStyleSheet(qss.read_text(encoding="utf-8"))
    return _qapp


# ─── Gamepad support ──────────────────────────────────────────────────────────

# Mapeo de teclas que Steam/game mode traduce de los botones del mando
# A=Return/Space, B=Escape, X=Backspace, Y=F1
# D-pad = flechas del teclado

YES_BTN_KEYS    = (Qt.Key_Return, Qt.Key_Space)
NO_BTN_KEYS     = (Qt.Key_Escape,)
CANCEL_BTN_KEYS = (Qt.Key_Backspace,)
DIR_KEYS = {
    Qt.Key_Up:    "up",
    Qt.Key_Down:  "down",
    Qt.Key_Left:  "left",
    Qt.Key_Right: "right",
}


# ─── BaseDialog ───────────────────────────────────────────────────────────────

class BaseDialog(QtWidgets.QDialog):
    def __init__(self, title: str):
        super().__init__(None)
        self.setWindowTitle(title)
        self.setWindowFlags(self.windowFlags() | QtCore.Qt.FramelessWindowHint)
        self.setAttribute(QtCore.Qt.WA_TranslucentBackground)
        self.setAttribute(QtCore.Qt.WA_StyledBackground, True)

        content = QtWidgets.QWidget(self)
        content.setObjectName("content")

        outer = QtWidgets.QVBoxLayout(self)
        outer.setContentsMargins(0,0,0,0)
        outer.addWidget(content)

        inner = QtWidgets.QVBoxLayout(content)
        inner.setContentsMargins(20,20,20,20)
        inner.setSpacing(10)
        self._inner = inner

    def _add(self, widget: QtWidgets.QWidget, *, alignment=None):
        if alignment is not None:
            self._inner.addWidget(widget, alignment=alignment)
        else:
            self._inner.addWidget(widget)

    def keyPressEvent(self, event: QtGui.QKeyEvent):
        key = event.key()
        if key in YES_BTN_KEYS:
            self._on_gamepad_yes()
        elif key in NO_BTN_KEYS:
            self._on_gamepad_no()
        elif key in CANCEL_BTN_KEYS:
            self._on_gamepad_cancel()
        elif key in DIR_KEYS:
            self._on_gamepad_dir(DIR_KEYS[key])
        else:
            super().keyPressEvent(event)

    # Métodos a sobreescribir en subclases según necesiten
    def _on_gamepad_yes(self):
        self.accept()

    def _on_gamepad_no(self):
        self.reject()

    def _on_gamepad_cancel(self):
        self.reject()

    def _on_gamepad_dir(self, direction: str):
        pass  # sobreescribir en subclases que necesiten navegación