#!/usr/bin/env python3

import importlib.util
import os
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
sys.dont_write_bytecode = True

try:
    from PySide6.QtCore import QUrl
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQuick import QQuickItem, QQuickView
    from PySide6.QtTest import QTest
except ImportError:
    sys.exit("PySide6 is required for QML layout checks.")


PROJECT_DIR = Path(__file__).resolve().parent.parent
RESOLUTIONS = [
    (1280, 720),
    (1366, 768),
    (1920, 1080),
    (2560, 1440),
    (3840, 2160),
    (3440, 1440),
    (1080, 1920),
]


def load_preview_tools():
    path = PROJECT_DIR / "scripts/render-qml-preview.py"
    spec = importlib.util.spec_from_file_location("preview_tools", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def mapped_geometry(item, canvas):
    scale = canvas.scale()
    return (
        canvas.x() + item.x() * scale,
        canvas.y() + item.y() * scale,
        item.width() * scale,
        item.height() * scale,
    )


def check_close(label, actual, expected, failures):
    if abs(actual - expected) > 1.5:
        failures.append(f"{label}: expected {expected:.1f}, got {actual:.1f}")


def main():
    tools = load_preview_tools()
    app = QGuiApplication([])
    view = QQuickView()
    context = view.engine().rootContext()
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
    context.setContextProperty("userModel", tools.UserModel())
    context.setContextProperty("sessionModel", tools.SessionModel())
    context.setContextProperty("sddm", tools.SddmStub())

    view.setSource(QUrl.fromLocalFile(str(PROJECT_DIR / "Main.qml")))
    if view.status() != QQuickView.Ready:
        for error in view.errors():
            print(error.toString(), file=sys.stderr)
        return 1

    root = view.rootObject()
    canvas = root.findChild(QQuickItem, "layoutCanvas")
    login = root.findChild(QQuickItem, "loginContent")
    footer = root.findChild(QQuickItem, "footerControls")
    clock = root.findChild(QQuickItem, "clockText")
    missing = [
        name
        for name, item in (
            ("layoutCanvas", canvas),
            ("loginContent", login),
            ("footerControls", footer),
            ("clockText", clock),
        )
        if item is None
    ]
    if missing:
        print(f"Missing layout objects: {', '.join(missing)}", file=sys.stderr)
        return 1

    view.show()
    failed = False
    for width, height in RESOLUTIONS:
        root.setProperty("width", width)
        root.setProperty("height", height)
        app.processEvents()
        QTest.qWait(40)
        app.processEvents()

        failures = []
        scale = canvas.scale()
        check_close("canvas x", canvas.x(), 0, failures)
        check_close("canvas y", canvas.y(), 0, failures)
        check_close("canvas width", canvas.width() * scale, width, failures)
        check_close("canvas height", canvas.height() * scale, height, failures)

        _, login_y, _, login_height = mapped_geometry(login, canvas)
        if login_y < -1 or login_y + login_height > height + 1:
            failures.append(
                f"login content outside screen: {login_y:.1f}.."
                f"{login_y + login_height:.1f}"
            )

        _, footer_y, _, footer_height = mapped_geometry(footer, canvas)
        check_close(
            "footer bottom",
            footer_y + footer_height,
            height,
            failures,
        )

        _, _, clock_width, _ = mapped_geometry(clock, canvas)
        clock_right = mapped_geometry(clock, canvas)[0] + clock_width
        check_close(
            "clock right margin",
            width - clock_right,
            96 * scale,
            failures,
        )

        if failures:
            failed = True
            print(f"FAIL {width}x{height}:", file=sys.stderr)
            for failure in failures:
                print(f"  {failure}", file=sys.stderr)
        else:
            print(f"Layout OK: {width}x{height}")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
