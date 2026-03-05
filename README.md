# ❄️ NixOS Setup

My personal NixOS configuration for development, cybersecurity research, and cross-platform compilation, built around GPU passthrough and a fully reproducible system.

> **Left:** Windows VM (GTX 1080 Ti) · **Right:** Main Desktop (RTX 3080)

![Desktop Screenshot](https://github.com/user-attachments/assets/14b5d552-8b1a-406a-aaa2-b4a3df89f9ec)

---

## Hosts

| Host | Role |
|------|------|
| `nixos-desktop` | Main workstation. Runs libvirt/QEMU with VFIO passthrough, Looking Glass for low-latency VM display, software TPM, and USB/IP YubiKey forwarding. |
| `cyber-vm` | NixOS VM on the passed-through 1080 Ti. Full cyber tooling, accessible via XRDP or Looking Glass, with YubiKey support via USB/IP. |

---

## Why NixOS

- **Reproducible**: the entire system is a config file in Git, deployable on any machine
- **Atomic rollbacks**: revert any update with a single `nixos-rebuild` switch
- **Pinned dependencies**: packages never break unexpectedly
- **Modular**: shared settings across hosts with per-host overrides
- **Fast VM cloning**: spin up a full copy of my setup in minutes

---

## GPU Passthrough

Instead of slow emulated graphics, `cyber-vm` gets a dedicated GTX 1080 Ti passed through via VFIO/IOMMU — owning the hardware outright.

This enables:
- Windows VMs with real GPU acceleration for cross-compilation and testing
- CTF challenges and security research outside from the daily driver
- Full GPU acceleration for tools like `hashcat` inside the VM

---

## Desktop Environments

### Niri · Wayland

Niri is a scrollable-tiling Wayland compositor.

https://github.com/user-attachments/assets/fedafeb5-5513-4f91-8f56-312bd69c9777
- **Scratchpads**: Spotify, Discord, EasyEffects, and Pavucontrol toggle as floating overlays via [niri-scratchpad](https://github.com/gvolpe/niri-scratchpad)
- **Per-monitor workspaces**: each monitor gets 9 independent named workspaces, switched with `Mod+1–9` relative to the focused monitor
- **Dynamic generation**: workspaces are defined once in `variables.nix` and auto-generated per monitor, with suffixes for secondary displays
- **Multi-monitor aware**: supports main, side-right, and side-left layouts

### DWM · X11

DWM is a minimal suckless window manager, used on `cyber-vm` and for X11 sessions.

- **Per-host `config.h`**: DWM, dmenu, st, and slstatus are compiled with host-specific configs from `hosts/<host>/dwm-config/`
- **Tokyo Night theme**: colors baked in at compile time across all suckless tools
- **slstatus**: lightweight bar showing CPU, RAM, uptime, and time; runs as a systemd user service
- **st terminal**: compiled with JetBrainsMono Nerd Font

---

Built on [shibahex/nixos-template](https://github.com/shibahex/nixos-template)
