%global debug_package %{nil}

Name:           lily-sddm-plasma6
Version:        0.2.3
Release:        1%{?dist}
Summary:        Frosted-glass SDDM theme for Plasma 6
License:        GPL-3.0-or-later AND CC-BY-SA-4.0
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  make
BuildRequires:  ripgrep
Requires:       sddm
Recommends:     sddm-kcm

%if 0%{?fedora} || 0%{?rhel}
BuildRequires:  qt6-qtdeclarative-devel
Requires:       qt6-qtdeclarative
Requires:       qt6-qtsvg
%endif

%if 0%{?suse_version}
BuildRequires:  qt6-declarative-devel
Requires:       libQt6Quick6
Requires:       libQt6QuickEffects6
Requires:       libQt6Svg6
%endif

%description
Lily is a Qt 6 QML login theme for SDDM with a frosted-glass side rail,
wallpaper-derived colors, user and session selection, and power actions.

%prep
%autosetup -n %{name}-%{version}

%build

%check
make check

%install
make install DESTDIR=%{buildroot} PREFIX=/usr

%files
%license %{_licensedir}/%{name}/LICENSE
%license %{_licensedir}/%{name}/CC-BY-SA-4.0.txt
%doc %{_docdir}/%{name}/README.md
%doc %{_docdir}/%{name}/README.en.md
%doc %{_docdir}/%{name}/CHANGELOG.md
%{_datadir}/sddm/themes/%{name}

%changelog
* Fri Oct 30 2026 Lily <gt001well@users.noreply.github.com> - 0.2.3-1
- Replace external avatar assets with system avatars and initials
- Use Breeze Next (Hanabi) as the default wallpaper
- Update wallpaper attribution and licensing

* Fri Oct 30 2026 Lily <gt001well@users.noreply.github.com> - 0.2.2-1
- Add Fedora and openSUSE packaging metadata
- Add shared DESTDIR installation and packaging checks
- Require the Qt 6 SVG runtime explicitly
