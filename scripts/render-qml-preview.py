#!/usr/bin/env python3

import argparse
import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

try:
    from PySide6.QtCore import (
        QAbstractListModel,
        QModelIndex,
        Property,
        QTimer,
        QUrl,
        Qt,
        Signal,
        Slot,
    )
    from PySide6.QtGui import QColor, QGuiApplication, QImage, QPainter
    from PySide6.QtQuick import QQuickView
except ImportError:
    sys.exit("PySide6 is required for this optional offscreen preview.")


PROJECT_DIR = Path(__file__).resolve().parent.parent


class UserModel(QAbstractListModel):
    countChanged = Signal()
    lastIndexChanged = Signal()
    lastUserChanged = Signal()

    rows = [
        {"name": "lily", "realName": "lily", "icon": "", "needsPassword": True},
        {"name": "guest", "realName": "访客", "icon": "", "needsPassword": True},
    ]

    def rowCount(self, parent=QModelIndex()):
        return 0 if parent.isValid() else len(self.rows)

    def roleNames(self):
        return {
            Qt.UserRole + 1: b"name",
            Qt.UserRole + 2: b"realName",
            Qt.UserRole + 3: b"icon",
            Qt.UserRole + 4: b"needsPassword",
        }

    def data(self, index, role):
        if not index.isValid():
            return None
        row = self.rows[index.row()]
        values = {
            Qt.UserRole + 1: row["name"],
            Qt.UserRole + 2: row["realName"],
            Qt.UserRole + 3: row["icon"],
            Qt.UserRole + 4: row["needsPassword"],
        }
        return values.get(role)

    @Property(int, notify=countChanged)
    def count(self):
        return len(self.rows)

    @Property(int, notify=lastIndexChanged)
    def lastIndex(self):
        return 0

    @Property(str, notify=lastUserChanged)
    def lastUser(self):
        return "lily"


class SessionModel(QAbstractListModel):
    countChanged = Signal()
    lastIndexChanged = Signal()
    rows = ["Plasma (Wayland)", "Plasma (X11)"]

    def rowCount(self, parent=QModelIndex()):
        return 0 if parent.isValid() else len(self.rows)

    def roleNames(self):
        return {Qt.UserRole + 1: b"name"}

    def data(self, index, role):
        if index.isValid() and role == Qt.UserRole + 1:
            return self.rows[index.row()]
        return None

    @Property(int, notify=countChanged)
    def count(self):
        return len(self.rows)

    @Property(int, notify=lastIndexChanged)
    def lastIndex(self):
        return 0


class SddmStub(QAbstractListModel):
    loginSucceeded = Signal()
    loginFailed = Signal()
    informationMessage = Signal(str)
    canSuspendChanged = Signal()
    canRebootChanged = Signal()
    canPowerOffChanged = Signal()

    @Property(bool, notify=canSuspendChanged)
    def canSuspend(self):
        return True

    @Property(bool, notify=canRebootChanged)
    def canReboot(self):
        return True

    @Property(bool, notify=canPowerOffChanged)
    def canPowerOff(self):
        return True

    @Slot(str, str, int)
    def login(self, user, password, session):
        pass

    @Slot()
    def suspend(self):
        pass

    @Slot()
    def reboot(self):
        pass

    @Slot()
    def powerOff(self):
        pass


def main():
    parser = argparse.ArgumentParser(
        description="Render Main.qml offscreen with mock SDDM models."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=PROJECT_DIR / "docs/preview.png",
    )
    parser.add_argument("--width", type=int, default=1920)
    parser.add_argument("--height", type=int, default=1080)
    parser.add_argument("--menu", choices=("user", "session"))
    parser.add_argument("--power", choices=("suspend", "reboot", "powerOff"))
    args = parser.parse_args()

    app = QGuiApplication([])
    view = QQuickView()
    view.setResizeMode(QQuickView.SizeViewToRootObject)

    context = view.engine().rootContext()
    users = UserModel()
    sessions = SessionModel()
    sddm = SddmStub()
    context.setContextProperty(
        "config",
        {
            "background": "assets/wallpaper.webp",
            "autoColors": "true",
            "autoSurfaceColors": "true",
            "fontFamily": "Noto Sans CJK SC",
            "accentColor": "#e0c7de",
            "accentSoftColor": "#d2afcb",
            "panelColor": "#2b1e33",
            "textColor": "#fff7fc",
            "mutedColor": "#e5d5e8",
            "tertiaryColor": "#e2d7e7",
            "glassTintColor": "#2d1e35",
            "errorColor": "#ffd1d9",
        },
    )
    context.setContextProperty("userModel", users)
    context.setContextProperty("sessionModel", sessions)
    context.setContextProperty("sddm", sddm)

    view.setSource(QUrl.fromLocalFile(str(PROJECT_DIR / "Main.qml")))
    if view.status() != QQuickView.Ready:
        for error in view.errors():
            print(error.toString(), file=sys.stderr)
        return 1

    root = view.rootObject()
    root.setProperty("width", args.width)
    root.setProperty("height", args.height)
    root.setProperty("previewWithoutBackground", True)
    view.setColor(QColor(0, 0, 0, 0))
    if args.menu:
        root.setProperty("activeMenu", args.menu)
    if args.power:
        root.setProperty("pendingPowerAction", args.power)
    view.show()

    result = {"ok": False}

    def capture():
        print(
            "users:",
            users.rowCount(),
            "session:",
            sessions.rowCount(),
            "selected user:",
            root.property("currentUserIndex"),
            "selected session:",
            root.property("sessionIndex"),
            "palette:",
            root.property("sampledPaletteReady"),
            root.property("accentColor").name(),
        )
        ui = view.grabWindow()
        wallpaper = QImage(str(PROJECT_DIR / "assets/wallpaper.webp"))
        scaled = wallpaper.scaled(
            ui.size(),
            Qt.KeepAspectRatioByExpanding,
            Qt.SmoothTransformation,
        )
        crop_x = max(0, (scaled.width() - ui.width()) // 2)
        crop_y = max(0, (scaled.height() - ui.height()) // 2)
        cropped = scaled.copy(crop_x, crop_y, ui.width(), ui.height())
        small = cropped.scaled(
            max(1, ui.width() // 20),
            max(1, ui.height() // 20),
            Qt.IgnoreAspectRatio,
            Qt.SmoothTransformation,
        )
        blurred = small.scaled(
            ui.size(),
            Qt.IgnoreAspectRatio,
            Qt.SmoothTransformation,
        )

        background = cropped.copy()
        painter = QPainter(background)
        rail_width = round(root.property("railWidth"))
        painter.setClipRect(0, 0, rail_width, ui.height())
        painter.drawImage(0, 0, blurred)
        painter.setClipping(False)

        tint = QColor(root.property("glassTintColor"))
        tint.setAlphaF(0.32)
        painter.fillRect(
            0,
            0,
            rail_width,
            ui.height(),
            tint,
        )
        painter.drawImage(0, 0, ui)
        painter.end()

        args.output.parent.mkdir(parents=True, exist_ok=True)
        result["ok"] = background.save(str(args.output))
        print(args.output)
        app.quit()

    QTimer.singleShot(1500, capture)
    app.exec()
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
