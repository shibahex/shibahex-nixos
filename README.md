# ❄️ NixOS Setup
My personal NixOS configuration for development, cybersecurity research, and cross-platform compilation, built around GPU passthrough and a fully reproducible system.
> **Left:** Windows VM (GTX 1080 Ti) · **Right:** Main Desktop (RTX 3080)
![Desktop Screenshot](https://github.com/user-attachments/assets/14b5d552-8b1a-406a-aaa2-b4a3df89f9ec)

---

## Hosts

| Host | Role | Hardware |
|------|------|----------|
| `nixos-desktop` | Main workstation. libvirt/QEMU with VFIO passthrough, Looking Glass for low-latency VM display, software TPM, USB/IP YubiKey forwarding. | RTX 3080 (host) · 9800x3d · 32GB RAM ·  GTX 1080 Ti (passed to VM) |
| `cyber-vm` | NixOS VM on the passed-through 1080 Ti. Full cyber tooling, accessible via XRDP or Looking Glass. YubiKey forwarded from host via USB/IP. GPU-accelerated hashcat and reverse engineering. | GTX 1080 Ti (VFIO passthrough) |
| `nixos-console` | Mini PC. Made for Couch co-op gaming, Sunshine/Moonlight streaming host for any device on the local network, and  AI compute serving Ollama/vLLM to other hosts. | RTX 4070 Super · 64 GB RAM · Ryzen 9 9800X3D · Fractal Design Terra Jade Mini-ITX |
| `thinkpad-nix` | Modded T480 with better cooling used for studying and programming with long battery life. | Intel Core i5-8350U · 16GB ram ·  Dual-pipe heatsink|

---


## Why NixOS
- **Reproducible**: the entire system is a config file in Git, deployable on any machine
- **Atomic rollbacks**: revert any update with a single `nixos-rebuild` switch
- **Pinned dependencies**: packages never break unexpectedly
- **Modular**: shared settings across hosts with per-host overrides
- **Fast VM cloning**: spin up a full copy of my setup in minutes

---

## GPU Passthrough
Instead of slow emulated graphics, `cyber-vm` gets a dedicated GTX 1080 Ti passed through via VFIO/IOMMU.

This enables:
- Windows VMs with real GPU acceleration for cross-compilation and testing
- CTF challenges and security research outside from the daily driver
- Full GPU acceleration for tools like `hashcat` inside the VM

---

## Desktop Environments

### Niri · Wayland
Niri is a scrollable-tiling Wayland compositor.
https://github.com/user-attachments/assets/bbd9e773-7289-4449-8959-a0a6b27caf2f
- **Scratchpads**: Spotify, Discord, EasyEffects, and Pavucontrol toggle as floating overlays via [niri-scratchpad](https://github.com/gvolpe/niri-scratchpad)
- **Per-monitor workspaces**: each monitor gets 9 independent named workspaces, switched with `Mod+1-9` relative to the focused monitor
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
