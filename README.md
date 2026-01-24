# NixOS Dotfiles Configuration (ASUS TUF)

This repository contains my personal NixOS configuration, tailored for ASUS TUF laptops. It includes a variety of hardware tweaks, software packages, and theming configurations to create a robust and beautiful desktop environment.

## Features

### 💻 Hardware Support
- **ASUS TUF/ROG Optimization**: Specific tweaks for ASUS TUF A15/FA506 series.
- **Bluetooth**: Full support with `blueman` manager; configured to power off on boot by default.
- **Printing**: 
  - Enabled CUPS service.
  - Drivers: `gutenprint`, `epson-escpr`, `epson-escpr2`.
- **Power Management**: Fixes for suspend, battery detection, and CPU frequency management.
- **Backlight**: Fixes for screen brightness control.

### 🛠 Software & Tools
- **System Info**: `fastfetch` for system fetching.
- **Browsers**: `google-chrome`, `firefox`.
- **Remote Desktop**: `rustdesk`.
- **Office**: `onlyoffice`.
- **Virtualization**: `docker` support enabled.
- **Wayland Utilities**: `wl-mirror`, `xwayland-satellite`.
- **Authentication**: Polkit agent for DMS.

### 🎨 Theming & Appearance
- **Icons**: 
  - `papirus-icon-theme`
  - `tela-icon-theme`
- **Cursors**: `bibata-cursors`.
- **Theming Tools**: `nwg-look` for GTK styling.
- **Colors & Fonts**: Custom configuration included in `configuration.nix`.

## 🚀 Installation

To apply this configuration to your NixOS system, run the following command in the directory:

```bash
sudo nixos-rebuild switch --impure --flake .
```

*Note: The `--impure` flag is currently required due to some configuration specifics.*

## 📝 Recent Changes
- Added `tela-icon-theme`.
- Configured Bluetooth to be off by default on boot.
- Added Fastfetch.
- Fixed printing drivers (Epson/Gutenprint).
- Added Rustdesk and Docker support.
