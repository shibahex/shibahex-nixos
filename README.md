# ❄️ My Personal NixOS Setup
## This is my personal NixOS setup for programming using GPU passthrough for cybersecurity, virtualization, and compilation for windows
<img width="3839" height="2159" alt="github" src="https://github.com/user-attachments/assets/14b5d552-8b1a-406a-aaa2-b4a3df89f9ec" />
(Left is Windows VM with a 1080ti; Right is Main PC with 3080)

---

## ❄️ NixOS Features

- Entire system is a config file in Git, fully reproducible across any machine.
- Rollback any update with nix commands.
- Packages and dependencies are pinned, nothing breaks unexpectedly.
- Modular config share common settings across machines, and have custom configs per host.

Easily clone my main setup into a VM in minutes, with all my tools and settings.

---

## 🖥️ GPU Passthrough
Instead of slow emulated graphics, GPU passthrough lets a VM own a physical GPU outright. `cyber-vm` gets a dedicated GTX 1080 Ti passed through via VFIO/IOMMU using real hardware.

**What this enables:**
- Windows VMs with real GPU acceleration for cross-compilation and testing
- CTF challenges and security research on a separate OS from your daily driver
- Running real workloads in the VM
- Tools in the VM can fully use GPU acceleration (hashcat)

---

## 🖥️ Hosts

| Host | Description |
|------|-------------|
| `nixos-desktop` | Main workstation for development, gaming, and the VFIO passthrough host. Runs libvirt/QEMU with software TPM, Looking Glass for low-latency VM display, and USB/IP to forward a YubiKey into the VM |
| `cyber-vm` | NixOS VM on the passed-through 1080 Ti. With all the cyber tooling, Accessible via XRDP or looking-glass, and has YubiKey support via USB/IP |

---

Built on top of [shibahex/nixos-template](https://github.com/shibahex/nixos-template) :)
