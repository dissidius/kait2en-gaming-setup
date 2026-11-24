# KAIT2EN Gaming Setup

A Fedora gaming bootstrap script and configuration reference for Intel Apple T2 MacBooks running KAIT2EN, focused on the 2019 16-inch MacBook Pro with AMD Radeon Pro 5300M / 5500M graphics.

## What it installs

- Fedora updates, Flatpak and Flathub
- Steam and controller device rules
- 64-bit and 32-bit Mesa Vulkan/OpenGL drivers
- Faugus Launcher and ProtonPlus (install GE-Proton manually in ProtonPlus)
- Gamescope, MangoHud, GameMode and GPU/temperature diagnostics
- Persistent NTSync module loading

## Requirements

- A working Fedora Workstation / KAIT2EN installation with GNOME Wayland.
- Internet access and a regular user account with sudo privileges.
- A compatible kernel with NTSync support.
- Review the script before running it: it upgrades system packages and enables third-party repositories (RPM Fusion Steam, Faugus COPR and Flathub). Back up important data. Verify custom KAIT2EN kernel/GPU integration after updates.

This is an independent community setup, not an official Fedora, Apple or KAIT2EN installer.

## Installation

Download [kait2en-gaming-setup.sh](./kait2en-gaming-setup.sh), or clone the repository:

```bash
git clone https://github.com/dissidius/kait2en-gaming-setup.git
cd kait2en-gaming-setup
bash kait2en-gaming-setup.sh
```

Run as your regular desktop user, not as root. Reboot after installation, particularly if the kernel was updated. Launch ProtonPlus and install GE-Proton for the desired launcher. The script stops on errors; a successful package installation does not guarantee hardware compatibility.

## Optional: GNOME / XWayland scaling

On the 3072 × 1920 Retina display at 150% desktop scaling, XWayland may expose a virtual 4096 × 2560 resolution to games. The override below forces an XWayland scale factor of 1, with an expected logical resolution of 2048 × 1280 in this configuration.

```bash
gsettings set org.gnome.mutter.wayland xwayland-scaling-factor 1
```

Log out and back in. Verify with:

```bash
gsettings get org.gnome.mutter.wayland xwayland-scaling-factor
xrandr
```

This does not change the physical panel resolution or the configured GNOME desktop scaling. Actual game rendering depends on in-game settings; other XWayland applications may appear less sharp. The setting is Mutter-version dependent; if the key is unavailable, skip it.

Reset using:

```bash
gsettings reset org.gnome.mutter.wayland xwayland-scaling-factor
```

## Gamescope

The preferred configuration uses a 1920 × 1200 internal resolution, 3072 × 1920 output, FSR and a 60 Hz nested refresh rate. The matching 16:10 aspect ratio fills the panel without stretching.

**Faugus Launcher — Launch Arguments**

```bash
gamescope -w 1920 -h 1200 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --
```

**Steam — Properties → General → Launch Options**

```bash
gamescope -w 1920 -h 1200 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%
```

Verify the PCI ID with `lspci -nn | grep -Ei 'vga|3d|display'`. The target Navi 14 GPU ID is `1002:7340`; adjust it if your hardware differs. This flag selects the preferred Gamescope Vulkan device, not necessarily the GPU chosen by every game.

| Internal resolution | Profile |
| --- | --- |
| 1280 × 800 | Maximum performance |
| 1360 × 850 | Very high performance |
| 1440 × 900 | High performance |
| 1536 × 960 | 2× integer scaling, nearest filter |
| 1600 × 1000 | Performance / quality balance |
| 1920 × 1200 | Recommended; tested in Faugus |
| 2048 × 1280 | Logical desktop resolution at 150% |
| 2560 × 1600 | High quality |
| 3072 × 1920 | Native output |

The script includes all launch options for both launchers, including 16:9 stretch variants. Stretching changes the aspect ratio. Alternative profiles have not all been individually tested.

For Faugus, enable MangoHud through the launcher rather than adding it manually to launch arguments if experiencing instability. See the commented configuration reference in the script.

## Validation and maintenance

```bash
bash -n kait2en-gaming-setup.sh
ls -l /dev/ntsync
switcherooctl list
vulkaninfo --summary
glxinfo -B
```

The script has passed a Bash syntax check. A full clean installation and hardware validation on all supported models remain pending. CI checks syntax and ShellCheck; it does not install the gaming stack or test hardware.

To update later:

```bash
sudo dnf upgrade --refresh -y
flatpak update -y
```

Update GE-Proton via ProtonPlus. Report issues with the MacBook model, Fedora and kernel versions, GPU PCI ID, launcher and relevant logs (remove sensitive details).
