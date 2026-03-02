# GEMINI.md - NixOS Dotfiles Context

This repository contains a modular NixOS configuration managed via Nix Flakes, specifically optimized for ASUS TUF (FA506 series) laptops.

## Project Overview

- **Architecture:** Nix Flakes.
- **Target Hardware:** ASUS TUF A15/FA506 (AMD/NVIDIA hybrid graphics).
- **Core Desktop Environment:** 
  - **Window Manager:** [Niri](https://github.com/YaLTeR/niri) (Scrollable tiling Wayland compositor).
  - **Shell:** [Dank Material Shell (DMS)](https://github.com/AvengeMedia/DankMaterialShell).
- **Main Technologies:** NixOS (Unstable), Wayland, NVIDIA (Proprietary), Docker, QEMU/KVM.

## Directory Structure

- `flake.nix`: Entry point for the configuration, managing dependencies (inputs) and system outputs.
- `configuration.nix`: Main system configuration file importing various modules and defining core system settings (users, bootloader, hardware drivers).
- `network.nix`: Networking configuration, including DNS and NetworkManager settings.
- `samba.nix`: File sharing configuration using Samba.
- `gns3.nix`: Configuration for GNS3 network simulation environment.
- `ollama.nix` & `aiagent.nix`: Configurations for local AI services (Ollama, AI agents).

## Key Commands & Operations

### System Management
- **Rebuild System:**
  ```bash
  sudo nixos-rebuild switch --impure --flake .
  ```
- **Update and Rebuild (Alias: `ncb`):**
  ```bash
  sudo nixos-rebuild switch --impure --flake . --upgrade
  ```
- **Garbage Collection:** Automatically runs weekly, deleting generations older than 30 days.

### Git Workflow (Aliases)
The configuration defines several bash aliases for Git:
- `gs`: `git status`
- `gaa`: `git add --all`
- `gc`: `git commit -am`
- `gp`: `git push`
- `gl`: `git pull`

## Hardware & System Specifics

- **Graphics:** NVIDIA proprietary drivers are enabled with Wayland optimizations (`nvidia_drm.modeset=1`).
- **ASUS Support:** `asusctl`, `supergfxd`, and `rog-control-center` are integrated for hardware control.
- **Power Management:** Configured for ASUS laptops; Bluetooth is disabled by default on boot.
- **Virtualization:** Docker (with NVIDIA support) and Libvirtd (KVM/QEMU) are enabled for user `kaco`.

## Development Conventions

1. **Modularity:** New system-level services should be placed in separate `.nix` files and added to the `imports` list in `configuration.nix`.
2. **Impure Flakes:** The system currently requires the `--impure` flag for rebuilds due to specific configuration requirements (likely hardware-related paths).
3. **Unfree Software:** Enabled via `nixpkgs.config.allowUnfree = true`.
4. **State Version:** The system is tracking state version `25.11`.
