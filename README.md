# CyberXero  
Neon Dynamic KDE Plasma Environment

## Overview

CyberXero is a fully automated KDE Plasma 6 environment initializer that transforms a stock Plasma installation into a cohesive, behavior driven desktop.

This project is not just a theme. It is a complete system configuration that installs dependencies, builds required components, deploys curated configuration files, and activates a workflow centered around dynamic tiling and true GNOME style dynamic workspaces.

The goal of CyberXero is to reshape how Plasma behaves, not merely how it looks.

All configuration changes are backed up automatically before being applied.

---

## Quick Install

Run the following command from any shell. The script will execute using Bash.

```
curl -fsSL https://raw.githubusercontent.com/MurderFromMars/CyberXero-Theme-Repo/main/install.sh | bash
```

---

## Design Goals

CyberXero is built around three core ideas.

Dynamic workspaces that behave exactly like GNOME Shell  
Dynamic tiling that integrates cleanly with KWin  
A unified neon visual identity across the desktop  

Static workspace counts, manual layout management, and fragmented visuals are intentionally avoided.

---

## Core Components

### Kyanite  
GNOME Style Dynamic Workspaces for KDE Plasma 6

Kyanite provides true GNOME style dynamic workspaces on KDE Plasma 6.

This behavior does not exist natively in Plasma. Kyanite implements it directly at the KWin script level.

Workspaces are created automatically when needed  
Empty workspaces are removed automatically  
There is always exactly one empty workspace  
Workspace lifecycle is driven entirely by window movement  

Kyanite targets Plasma 6 exclusively and is designed to be predictable, fast, and compositor friendly. It works alongside Krohnkite without managing tiling itself.

Kyanite is designed and maintained by me and is a core part of the CyberXero environment.

Repository  
https://github.com/MurderFromMars/Kyanite

Kyanite is installed, enabled, and activated automatically during CyberXero deployment.

---

### Krohnkite  
Dynamic Tiling Window Manager

Krohnkite provides automatic tiling for application windows within each workspace. It handles window placement and layout while deferring workspace lifecycle entirely to Kyanite.

---

### Visual and UI Components

plasma-panel-colorizer for dynamic panel coloring  
kurve for UI motion and animation polish  
KDE Rounded Corners for true rounded window edges  

---

## Supported Systems

CyberXero currently supports the following platforms.

Arch Linux and Arch based distributions  
Debian and Ubuntu based distributions  

Other distributions are not supported.

KDE Plasma 6 is required.

---

## What the Script Does

When executed, the CyberXero initializer performs the following actions.

The CyberXero repository is cloned or updated  
The host distribution is detected automatically  
System dependencies are installed  
Required KDE components are built and installed  
KWin scripts are deployed and enabled  
Icon theme and color scheme are installed  
Curated configuration files are deployed  
KDE settings are applied automatically  
Plasma Shell is restarted to apply changes  

The process is designed to be repeatable and mostly idempotent.

---

## Installed Dependencies

### Arch Linux

git  
cmake  
extra-cmake-modules  
base-devel  
unzip  
qt5-tools via yay or paru when available  

### Debian and Ubuntu

git  
cmake  
g++  
extra-cmake-modules  
kwin-dev  
qt6 base and development tools  
KDE Frameworks 6 development libraries  

---

## Configuration Deployed

### Configuration Directories

The following directories are deployed to ~/.config.

kitty  
btop  
fastfetch  

Existing directories are backed up before replacement.

---

### KDE Configuration Files

The following files are installed into ~/.config.

kwinrc  
plasmarc  
plasma-org.kde.plasma.desktop-appletsrc  
kwinrulesrc  

---

### Themes

Color scheme  
CyberXero  

Icon theme  
YAMIS  

The YAMIS icon theme is installed locally under ~/.local/share/icons.

---

## KWin Scripts Enabled

The following KWin scripts are enabled automatically.

Krohnkite for dynamic tiling  
Kyanite for GNOME style dynamic workspace management  

KWin is reconfigured live to apply these changes.

---

## Backups

Before any existing configuration is modified, a timestamped backup directory is created.

Example location  
~/CyberXero-backup-YYYYMMDD_HHMMSS

This includes previous configuration directories and KDE rc files.

Manual restoration is always possible by copying files back from this directory.

---

## Installation

### Manual Install

Clone the repository.

```
git clone https://github.com/MurderFromMars/CyberXero-Theme-Repo
cd CyberXero-Theme-Repo
```

Make the script executable and run it.

```
chmod +x cyberxero.sh
./cyberxero.sh
```

Root privileges are required for dependency installation.

---

## Post Installation Notes

Some effects may require a full logout and login to behave correctly.  
Krohnkite keybindings can be adjusted in System Settings under Window Management.  
Workspace behavior is entirely controlled by Kyanite and does not require manual configuration.

---

## Philosophy

CyberXero treats workspaces as ephemeral state, not configuration.

A desktop environment should adapt to how windows are used, not force the user to manage layout and workspace counts manually. CyberXero applies this principle consistently across window management, workspace lifecycle, and visual design.

---

## License

The CyberXero initializer script and configuration are provided under the MIT License.

Third party components installed or built by this script are distributed under their respective licenses. CyberXero does not modify the licensing terms of any bundled or external software.
