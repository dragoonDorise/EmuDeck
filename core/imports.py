from core.vars import emudeck_logs

import os
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = "hide"
import shlex, sys, subprocess, pkgutil, importlib, inspect, json, venv, logging, requests, stat, hashlib, zipfile, re, errno, shutil, subprocess, io, zipfile, tempfile, time, plistlib, zlib, vdf, py7zr, tarfile, fileinput, ctypes, getpass, threading, socket, pygame,  traceback
from multiprocessing import Process
from time import sleep
from math import ceil
from pathlib import Path
from typing import Optional, Union, Callable, Any, Iterable, Callable, Sequence
from pathlib import Path
from contextlib import redirect_stdout, redirect_stderr
from concurrent.futures import ThreadPoolExecutor, as_completed
from PySide6 import QtWidgets, QtCore, QtGui

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
        # Evita líneas vacías
        message = message.rstrip()
        if message:
            self.log_method(message)

    def flush(self):
        pass  # Para compatibilidad

# 5. Redirigimos stdout y stderr
sys.stdout = StreamToLogger(logger.info)
sys.stderr = StreamToLogger(logger.error)



# ─── Single QApplication + QSS ───────────────────────────────────────────────

_qapp: Optional[QtWidgets.QApplication] = None

def ensure_app() -> QtWidgets.QApplication:
    """
    Crea (si hace falta) y devuelve el singleton QApplication
    y carga dialog.qss si existe.
    """
    global _qapp
    if _qapp is None:
        _qapp = QtWidgets.QApplication.instance() or QtWidgets.QApplication(sys.argv)
        qss = Path(__file__).parent / "dialog.qss"
        if qss.exists():
            _qapp.setStyleSheet(qss.read_text(encoding="utf-8"))
    return _qapp


# ─── Gamepad support ──────────────────────────────────────────────────────────

_joystick: Optional[pygame.joystick.Joystick] = None
YES_BTN, NO_BTN, CANCEL_BTN = 0, 1, 2

def ensure_gamepad() -> Optional[pygame.joystick.Joystick]:
    global _joystick
    if _joystick is None:
        pygame.init()
        pygame.joystick.init()
        if pygame.joystick.get_count() > 0:
            _joystick = pygame.joystick.Joystick(0)
            _joystick.init()
    return _joystick

def poll_gamepad() -> Optional[str]:
    """
    Devuelve "yes", "no" o "cancel" si se pulsa A/B/X en el gamepad.
    """
    j = ensure_gamepad()
    if not j:
        return None
    pygame.event.pump()
    for e in pygame.event.get():
        if e.type == pygame.JOYBUTTONDOWN:
            if e.button == YES_BTN:    return "yes"
            if e.button == NO_BTN:     return "no"
            if e.button == CANCEL_BTN: return "cancel"
    return None


# ─── BaseDialog ───────────────────────────────────────────────────────────────

class BaseDialog(QtWidgets.QDialog):
    """
    Dialog sin bordes, fondo transparente.
    El contenido interno (objectName="content") recibirá el QSS.
    """
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
        """
        Añade un widget al contenido.
        """
        if alignment is not None:
            self._inner.addWidget(widget, alignment=alignment)
        else:
            self._inner.addWidget(widget)