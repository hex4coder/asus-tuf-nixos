# GEMINI.md - NixOS Dotfiles Context

This repository contains a modular NixOS configuration managed via Nix Flakes, specifically optimized for ASUS TUF (FA506 series) laptops with AMD/NVIDIA hybrid graphics.

## Project Overview

- **Architecture:** Nix Flakes.
- **Target Hardware:** ASUS TUF A15/FA506 (AMD/NVIDIA hybrid graphics).
- **Core Desktop Environment:** 
  - **Window Manager:** [Niri](https://github.com/YaLTeR/niri) (Scrollable tiling Wayland compositor).
  - **Shell:** [Dank Material Shell (DMS)](https://github.com/AvengeMedia/DankMaterialShell).
- **Main Technologies:** NixOS (Unstable), Wayland, NVIDIA (Proprietary), Docker, QEMU/KVM, VirtualBox KVM.

## Directory Structure

- `flake.nix`: Entry point for the configuration, managing dependencies (inputs) and system outputs.
- `configuration.nix`: Main system configuration file importing various modules and defining core system settings.
- `home.nix`: Home Manager configuration for user `kaco`.
- `network.nix`: Networking configuration, including DNS and NetworkManager settings.
- `samba.nix`: File sharing configuration using Samba.
- `labtjkt.nix`: Lab TJKT tools (GNS3, Wireshark, Winbox, etc.) for networking & troubleshooting.
- `aiagent.nix`: Configurations for local AI services (currently `gemini-cli`).
- `virtualisations.nix`: Virtualization settings (Docker, Libvirtd, VirtualBox).
- `vscode.nix`: Visual Studio Code installation.
- `android-devs.nix`: Android development tools (imported in `home.nix`).

## Key Commands & Operations

### System Management
- **Rebuild System (Recommended):**
  ```bash
  nos # Alias for: nh os switch . -- --impure
  ```
- **Manual Rebuild:**
  ```bash
  sudo nixos-rebuild switch --impure --flake .
  ```
- **Update and Rebuild (Alias: `ncb`):**
  ```bash
  sudo nixos-rebuild switch --impure --flake . --upgrade
  ```
- **Full Update Loop (`n-up`):** `git pull` -> `nix flake update` -> `nos` -> `git commit` -> `git push`.

### Application Launcher (Fuzzel)
- **Primary Launcher:** Fuzzel is configured as the main Wayland launcher.
- **Configuration:** Managed via Home Manager link to `./fuzzel/`.

### Theme Management
- **Switch to Dark Mode:** `set-dark`
- **Switch to Light Mode:** `set-light`
> Note: These commands sync GTK settings and DMS colors via `gsettings`.

### Git & Shell Workflow (Aliases)
Zsh is the preferred shell with several aliases:
- `gs`: `git status`
- `gaa`: `git add --all`
- `gc`: `git commit -am`
- `gp`: `git push`
- `gl`: `git pull`
- `nos`: `nh os switch . -- --impure` (Primary rebuild command)

## AI & Agentic Workflows

- **Gemini CLI:** Installed via `aiagent.nix`.
- **BrowserOS (Planned/Research):** A Chromium-based AI-native browser for agentic workflows. Can be integrated via flakes (e.g., `github:Hill-Brandon-M/browseros-ai`).
- **Local AI:** Support for Ollama and MCP (Model Context Protocol) is a key area of development for this setup.

## Hardware & System Specifics

- **Graphics:** NVIDIA proprietary drivers with Wayland optimizations (`nvidia_drm.modeset=1`).
  - **Hybrid Boot Fix:** `amdgpu` and `nvidia` modules are included in `boot.initrd.kernelModules`.
- **ASUS Support:** `asusctl`, `supergfxd`, and `rog-control-center` are integrated.
- **Power Management:** ASUS battery limit set to 80% via `asusd`.
- **Virtualization:** Docker (with NVIDIA support), Libvirtd (KVM/QEMU), and VirtualBox KVM are enabled for user `kaco`.

## Development Conventions

1. **Modularity:** System-level services go in separate `.nix` files imported in `configuration.nix`.
2. **Impure Flakes:** Rebuilds require `--impure` due to local path dependencies and hardware specificities.
3. **Kernel:** Pinned to `pkgs.linuxPackages_6_12` (LTS) for stability with VirtualBox.
4. **State Version:** Tracking state version `25.11`.
