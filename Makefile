PKGNAME ?= lily-sddm-plasma6
PREFIX ?= /usr
DESTDIR ?=
DATADIR ?= $(PREFIX)/share
THEME_DIR ?= $(DESTDIR)$(DATADIR)/sddm/themes/$(PKGNAME)
DOC_DIR ?= $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)
LICENSE_DIR ?= $(DESTDIR)$(DATADIR)/licenses/$(PKGNAME)

.DEFAULT_GOAL := help
.PHONY: help check check-layout install preview prototype render-preview

help:
	@printf '%s\n' \
		'Usage: make <target>' \
		'' \
		'make check           Run theme, prototype and layout checks' \
		'make check-layout    Run multi-resolution layout checks' \
		'make preview         Preview with the real SDDM Qt 6 greeter' \
		'make prototype       Open the HTML prototype' \
		'make render-preview  Regenerate full and KCM previews' \
		'make install         Install the theme (honors PREFIX and DESTDIR)' \
		'make help            Show this help'

check:
	./scripts/check-theme.sh
	./scripts/check-prototype.sh
	@if python3 -c 'import PySide6' >/dev/null 2>&1; then \
		./scripts/check-layout.py; \
	else \
		printf 'Layout checks skipped: PySide6 is not installed.\n'; \
	fi

check-layout:
	./scripts/check-layout.py

install:
	install -d \
		"$(THEME_DIR)/assets/icons" \
		"$(DOC_DIR)" \
		"$(LICENSE_DIR)"
	install -m644 Main.qml metadata.desktop theme.conf "$(THEME_DIR)/"
	install -m644 assets/*.webp assets/*.png "$(THEME_DIR)/assets/"
	install -m644 assets/icons/*.svg "$(THEME_DIR)/assets/icons/"
	install -m644 README.md README.en.md CHANGELOG.md "$(DOC_DIR)/"
	install -m644 LICENSE LICENSES/CC-BY-SA-4.0.txt "$(LICENSE_DIR)/"

preview:
	./scripts/preview.sh

prototype:
	./scripts/preview-prototype.sh

render-preview:
	./scripts/render-previews.sh
