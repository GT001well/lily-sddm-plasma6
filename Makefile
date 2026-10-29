PKGNAME ?= lily-sddm-plasma6
VERSION ?= $(shell sed -n 's/^Version=//p' metadata.desktop | head -n 1)
PREFIX ?= /usr
DESTDIR ?=
DATADIR ?= $(PREFIX)/share
THEME_DIR ?= $(DESTDIR)$(DATADIR)/sddm/themes/$(PKGNAME)
DOC_DIR ?= $(DESTDIR)$(DATADIR)/doc/$(PKGNAME)
LICENSE_DIR ?= $(DESTDIR)$(DATADIR)/licenses/$(PKGNAME)

.PHONY: check check-layout check-packaging install dist preview prototype render-preview wallpaper

check:
	./scripts/check-theme.sh
	./scripts/check-prototype.sh
	./scripts/check-packaging.sh
	@if python3 -c 'import PySide6' >/dev/null 2>&1; then \
		./scripts/check-layout.py; \
	else \
		printf 'Layout checks skipped: PySide6 is not installed.\n'; \
	fi

check-layout:
	./scripts/check-layout.py

check-packaging:
	./scripts/check-packaging.sh

install:
	install -d \
		"$(THEME_DIR)/assets/icons" \
		"$(DOC_DIR)" \
		"$(LICENSE_DIR)"
	install -m644 Main.qml metadata.desktop theme.conf "$(THEME_DIR)/"
	install -m644 assets/*.webp assets/*.png "$(THEME_DIR)/assets/"
	install -m644 assets/icons/*.svg "$(THEME_DIR)/assets/icons/"
	install -m644 README.md README.en.md CHANGELOG.md "$(DOC_DIR)/"
	install -m644 LICENSE "$(LICENSE_DIR)/LICENSE"

dist:
	./scripts/build-source-archive.sh

preview:
	./scripts/preview.sh

prototype:
	./scripts/preview-prototype.sh

render-preview:
	./scripts/render-previews.sh

wallpaper:
	./scripts/generate-wallpaper.py
