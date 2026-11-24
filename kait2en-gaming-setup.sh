#!/usr/bin/env bash

set -e

# ==========================================================
# KAIT2EN - Fedora Gaming Setup
# MacBook Pro 16" 2019
# AMD Radeon Pro 5300M / 5500M
# ==========================================================

# 1. Update Fedora and Flatpak
sudo dnf upgrade --refresh -y
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak update -y

# 2. Enable Steam repository
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1

# 3. Install complete gaming stack
sudo dnf install -y \
    steam \
    steam-devices \
    mesa-vulkan-drivers.x86_64 \
    mesa-vulkan-drivers.i686 \
    mesa-dri-drivers.x86_64 \
    mesa-dri-drivers.i686 \
    vulkan-loader.i686 \
    vulkan-tools \
    glx-utils \
    gamemode \
    mangohud \
    gamescope \
    lm_sensors \
    radeontop

# 4. Install Faugus Launcher
sudo dnf copr enable -y faugus/faugus-launcher
sudo dnf install -y faugus-launcher

# 5. Install ProtonPlus
flatpak install -y flathub com.vysp3r.ProtonPlus

# Launch ProtonPlus manually:
# flatpak run com.vysp3r.ProtonPlus
# Install the latest GE-Proton for Steam and Faugus
# through the ProtonPlus interface.

# 6. Enable persistent NTSync
sudo modprobe ntsync
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf

# 7. Verify gaming environment
echo "=== NTSync ==="
lsmod | grep ntsync
ls -l /dev/ntsync

echo "=== GPUs ==="
switcherooctl list

echo "=== Vulkan ==="
vulkaninfo --summary

echo "=== OpenGL ==="
glxinfo -B

echo "=== Gamescope ==="
gamescope --version

echo "=== Temperatures ==="
sensors

echo "=== Flatpak repositories ==="
flatpak remotes

echo "=== Installation complete ==="
echo "Reboot recommended before gaming."

# ==========================================================
# POST-INSTALLATION CONFIGURATION
# Everything below is intentionally commented out.
# ==========================================================

# 8. GNOME / XWayland display scaling override
# GNOME Settings -> Displays:
# Native resolution: 3072x1920
# Refresh rate: 60 Hz
# Desktop scaling: 150%
#
# PROBLEM:
# GNOME fractional scaling and XWayland native scaling
# can expose an unnecessarily high virtual resolution
# to Windows games running through Wine/Proton.
# In our configuration:
# Physical display resolution: 3072x1920
# XWayland game resolution:    4096x2560
# This can increase GPU workload if games render at that resolution.
#
# SOLUTION: Force XWayland to use a scaling factor of 1.
# gsettings set org.gnome.mutter.wayland xwayland-scaling-factor 1
#
# EXPECTED RESULT AT 150% DESKTOP SCALING:
# Before override: 4096x2560
# After override:  2048x1280
# GNOME exposes the logical desktop resolution instead of the
# oversized XWayland resolution, reducing exposed pixel count by 75%.
# The physical display remains at 3072x1920; desktop scaling stays 150%.
# Actual rendering resolution depends on game settings.
# Native Wayland applications are not directly affected.
# Other XWayland applications may appear less sharp.
#
# Verify the override:
# gsettings get org.gnome.mutter.wayland xwayland-scaling-factor
# Check the XWayland display resolution:
# xrandr
# Log out and log back in after applying.
# Restore the default scaling behavior if necessary:
# gsettings reset org.gnome.mutter.wayland xwayland-scaling-factor
# Log out and log back in after resetting.

# 9. Why combine the scaling override with Gamescope?
# Gamescope lets us explicitly control internal game resolution,
# output resolution, upscaling, aspect ratio, refresh rate and GPU.
# Example: 1920x1200 -> 3072x1920 with AMD FSR.
# This renders approximately 39% of native pixel count.
# Matching 16:10 resolutions avoid black borders and distortion.

# 10. Recommended Faugus configuration
# Proton: Latest GE-Proton
# NTSync: Enabled
# MangoHud: Enabled through Faugus settings
# MangoApp: Disabled
# GameMode: Disabled
# Experimental Wayland: Disabled
# Gamescope: Through launch arguments
# Avoid adding MangoHud manually to launch arguments if unstable.
# AMD Radeon Pro 5300M / 5500M: Navi 14, PCI ID 1002:7340.
# Verify GPU device IDs:
# lspci -nn | grep -Ei 'vga|3d|display'
# Native output: 3072x1920 (16:10)

# ==========================================================
# 11. FAUGUS GAMESCOPE LAUNCH OPTIONS
# ==========================================================
# Copy into Faugus Launch Arguments without %command%.

# 1280x800 - Maximum performance
# gamescope -w 1280 -h 800 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 1360x850 - Very high performance
# gamescope -w 1360 -h 850 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 1440x900 - High performance
# gamescope -w 1440 -h 900 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 1536x960 - Perfect 2x integer scaling
# gamescope -w 1536 -h 960 -W 3072 -H 1920 -r 60 -S integer -F nearest -f --prefer-vk-device 1002:7340 --

# 1600x1000 - Performance and quality
# gamescope -w 1600 -h 1000 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 1920x1200 - Recommended / confirmed working in Faugus
# gamescope -w 1920 -h 1200 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 2048x1280 - Logical desktop resolution at 150% scaling
# gamescope -w 2048 -h 1280 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 2560x1600 - High quality
# gamescope -w 2560 -h 1600 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 --

# 3072x1920 - Native resolution
# gamescope -w 3072 -h 1920 -W 3072 -H 1920 -r 60 -f --prefer-vk-device 1002:7340 --

# Standard 16:9 stretched to full screen
# Stretching introduces aspect ratio distortion.

# 1280x720
# gamescope -w 1280 -h 720 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 --

# 1366x768
# gamescope -w 1366 -h 768 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 --

# 1600x900
# gamescope -w 1600 -h 900 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 --

# 1920x1080
# gamescope -w 1920 -h 1080 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 --

# 2560x1440
# gamescope -w 2560 -h 1440 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 --

# ==========================================================
# 12. STEAM GAMESCOPE LAUNCH OPTIONS
# ==========================================================
# Steam -> Game Properties -> General -> Launch Options
# Steam requires %command% at the end.

# 1280x800 - Maximum performance
# gamescope -w 1280 -h 800 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1360x850 - Very high performance
# gamescope -w 1360 -h 850 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1440x900 - High performance
# gamescope -w 1440 -h 900 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1536x960 - Perfect 2x integer scaling
# gamescope -w 1536 -h 960 -W 3072 -H 1920 -r 60 -S integer -F nearest -f --prefer-vk-device 1002:7340 -- %command%

# 1600x1000 - Performance and quality
# gamescope -w 1600 -h 1000 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1920x1200 - Recommended / confirmed working in Faugus
# gamescope -w 1920 -h 1200 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 2048x1280 - Logical desktop resolution at 150% scaling
# gamescope -w 2048 -h 1280 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 2560x1600 - High quality
# gamescope -w 2560 -h 1600 -W 3072 -H 1920 -r 60 -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 3072x1920 - Native resolution
# gamescope -w 3072 -h 1920 -W 3072 -H 1920 -r 60 -f --prefer-vk-device 1002:7340 -- %command%

# Standard 16:9 stretched to full screen
# Stretching introduces aspect ratio distortion.

# 1280x720
# gamescope -w 1280 -h 720 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1366x768
# gamescope -w 1366 -h 768 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1600x900
# gamescope -w 1600 -h 900 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 1920x1080
# gamescope -w 1920 -h 1080 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# 2560x1440
# gamescope -w 2560 -h 1440 -W 3072 -H 1920 -r 60 -S stretch -F fsr -f --prefer-vk-device 1002:7340 -- %command%

# ==========================================================
# 13. Additional useful diagnostic commands
# ==========================================================
# switcherooctl list
# lspci -nn | grep -Ei 'vga|3d|display'
# vulkaninfo --summary
# glxinfo -B
# radeontop
# watch -n 1 sensors
# lsmod | grep ntsync
# ls -l /dev/ntsync
# ls -l /dev/kvm
# lsmod | grep kvm
# rpm -qa | grep -Ei 'steam|mesa|vulkan|faugus|gamescope|mangohud|gamemode'
# flatpak list --app
# gamescope --help
# systemctl status t2-zonepowerd.service
# uname -r

# ==========================================================
# 14. Future gaming stack updates
# ==========================================================
# sudo dnf upgrade --refresh -y
# flatpak update -y
# Update GE-Proton through ProtonPlus.
# Reboot after kernel or major graphics driver updates.
# Verify custom KAIT2EN GPU and T2 integrations after kernel updates.
# ==========================================================
# END OF SCRIPT
# ==========================================================
