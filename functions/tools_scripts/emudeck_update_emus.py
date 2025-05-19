from core.all import *

def load_qss(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8')
    except Exception:
        return ""

def get_available_emulators() -> list[str]:
    avail = []
    for name, fn in globals().items():
        if inspect.isfunction(fn) and name.endswith("_is_installed"):
            emu = name[:-len("_is_installed")]
            try:
                if fn():
                    avail.append(emu)
            except Exception:
                pass
    return sorted(avail)

class InstallDialog(QtWidgets.QDialog):
    def __init__(self, emus: list[str], parent=None):
        super().__init__(parent)
        # Sin barra de título, fondo traslúcido, estilizable con QSS
        flags = QtCore.Qt.Window | QtCore.Qt.FramelessWindowHint | QtCore.Qt.Dialog
        self.setWindowFlags(flags)
        self.setAttribute(QtCore.Qt.WA_TranslucentBackground)

        # ─── Contenedor principal (fondo redondeado aplicado a #content en QSS) ───
        content = QtWidgets.QWidget(self)
        content.setObjectName("content")

        # Usamos un QVBoxLayout en content para meter grid + botones
        content_layout = QtWidgets.QVBoxLayout(content)
        content_layout.setContentsMargins(20, 20, 20, 20)
        content_layout.setSpacing(15)

        # ─── Grid de checkboxes ─────────────────────────────────────────────────
        cols = 2
        rows = ceil(len(emus) / cols)
        grid = QtWidgets.QGridLayout()
        grid.setSpacing(10)

        self.checks: dict[str, QtWidgets.QCheckBox] = {}
        for idx, emu in enumerate(emus):
            row = idx % rows
            col = idx // rows
            display = emu.replace('_', ' ').title()
            cb = QtWidgets.QCheckBox(display)
            grid.addWidget(cb, row, col)
            self.checks[emu] = cb

        content_layout.addLayout(grid)
        # ────────────────────────────────────────────────────────────────────────

        # ─── Botones OK / Cancel centrados ─────────────────────────────────────
        btns = QtWidgets.QDialogButtonBox(
            QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel
        )
        btns.accepted.connect(self.accept)
        btns.rejected.connect(self.reject)
        # los metemos dentro de content_layout para que queden dentro de la caja
        content_layout.addWidget(btns, alignment=QtCore.Qt.AlignHCenter)
        # ────────────────────────────────────────────────────────────────────────

        # ─── Finalmente, un layout sobre el propio diálogo para centrar 'content' ─
        outer = QtWidgets.QVBoxLayout(self)
        outer.setContentsMargins(0, 0, 0, 0)
        outer.addWidget(content, alignment=QtCore.Qt.AlignCenter)
        # ────────────────────────────────────────────────────────────────────────

        # Ajuste de tamaño automático
        self.adjustSize()

    def selected(self) -> list[str]:
        """Devuelve la lista de emus marcados."""
        return [emu for emu, cb in self.checks.items() if cb.isChecked()]

def show_dialog_update_emulators():
    app = QtWidgets.QApplication(sys.argv)
    # cargar QSS
    qss = load_qss(Path(emudeck_backend) / "core/dialog.qss")
    if qss:
        app.setStyleSheet(qss)

    emus = get_available_emulators()
    if not emus:
        QtWidgets.QMessageBox.information(
            None, "Sin emuladores", "No se han detectado emuladores instalados."
        )
        return

    dlg = InstallDialog(emus)
    if dlg.exec() != QtWidgets.QDialog.Accepted:
        return

    to_install = dlg.selected()
    if not to_install:
        QtWidgets.QMessageBox.information(
            None, "Nada seleccionado", "No se ha seleccionado ningún emulador."
        )
        return

    for emu in to_install:
        fn_name = f"{emu}_install"
        fn = globals().get(fn_name)
        if fn and inspect.isfunction(fn):
            try:
                fn()
            except Exception as e:
                QtWidgets.QMessageBox.critical(
                    None,
                    "Error",
                    f"Error al instalar {emu}:\n{e}"
                )
        else:
            QtWidgets.QMessageBox.warning(
                None,
                "No encontrada",
                f"No existe la función {fn_name}()"
            )

    QtWidgets.QMessageBox.information(
        None, "Terminado", "Instalación completada."
    )
