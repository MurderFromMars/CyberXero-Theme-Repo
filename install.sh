#!/usr/bin/env bash
[ -z "$BASH_VERSION" ] && exec bash "$0" "$@"
set -euo pipefail

########################################
# CYBERXERO :: NEON SYSTEM INITIALIZER
########################################

REPO_DIR="$HOME/CyberXero"
BACKUP_DIR="$HOME/CyberXero-backup-$(date +%Y%m%d_%H%M%S)"
DISTRO="unknown"

log()  { printf "\033[1;36m[Ξ]\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[✖]\033[0m %s\n" "$1" >&2; }

section() {
    printf "\n\033[1;35m╔═══════════════════════════════════════════════════════╗\033[0m\n"
    printf "\033[1;35m║\033[0m  %-51s \033[1;35m║\033[0m\n" "$1"
    printf "\033[1;35m╚═══════════════════════════════════════════════════════╝\033[0m\n\n"
}

subsection() {
    printf "\n\033[1;36m┌─────────────────────────────────────────────────────────┐\033[0m\n"
    printf "\033[1;36m│\033[0m  %-50s \033[1;36m│\033[0m\n" "$1"
    printf "\033[1;36m└─────────────────────────────────────────────────────────┘\033[0m\n"
}

backup_file() {
    local target="$1"
    if [ -e "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/"
        log "backup → $target"
    fi
}

fetch_repo() {
    log "syncing CyberXero repository…"

    if [ ! -d "$REPO_DIR/.git" ]; then
        if git clone https://github.com/MurderFromMars/CyberXero "$REPO_DIR" 2>&1 | grep -v -E "^(remote:|Receiving|Resolving|Counting)" | grep -v "^$" || false; then
            ok "repository cloned"
        else
            err "failed to clone repository"
            exit 1
        fi
    else
        if git -C "$REPO_DIR" pull --rebase >/dev/null 2>&1; then
            ok "repository updated"
        else
            warn "failed to update repository (continuing with existing)"
        fi
    fi
}

detect_distro() {
    log "scanning system architecture…"

    if command -v pacman >/dev/null 2>&1; then
        DISTRO="arch"
        ok "arch‑based system detected"
    elif command -v apt >/dev/null 2>&1; then
        DISTRO="debian"
        ok "debian‑based system detected"
    else
        err "unsupported distribution"
        exit 1
    fi
}

install_arch_dependencies() {
    log "installing arch dependencies…"

    sudo pacman -S --needed --noconfirm \
        git cmake extra-cmake-modules base-devel unzip cava \
        kitty fastfetch >/dev/null 2>&1

    if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm qt5-tools >/dev/null 2>&1
    elif command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm qt5-tools >/dev/null 2>&1
    else
        warn "AUR helper not found → qt5-tools skipped"
    fi

    ok "arch dependencies installed"
}

install_debian_dependencies() {
    log "installing debian dependencies…"

    sudo apt update >/dev/null 2>&1
    sudo apt install -y \
        git cmake g++ extra-cmake-modules kwin-dev unzip \
        qt6-base-private-dev qt6-base-dev-tools \
        libkf6kcmutils-dev libdrm-dev libplasma-dev cava \
        kitty fastfetch >/dev/null 2>&1

    ok "debian dependencies installed"
}

install_dependencies() {
    case "$DISTRO" in
        arch)   install_arch_dependencies ;;
        debian) install_debian_dependencies ;;
        *)      err "invalid distro state"; exit 1 ;;
    esac
}

build_panel_colorizer() {
    log "compiling plasma‑panel‑colorizer…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://github.com/luisbocanegra/plasma-panel-colorizer" "$tmp/plasma-panel-colorizer" 2>&1 | grep -v -E "^(remote:|Receiving|Resolving|Counting)" | grep -v "^$" || true

    cd "$tmp/plasma-panel-colorizer"
    chmod +x install.sh
    ./install.sh >/dev/null 2>&1 || true

    cd ~
    rm -rf "$tmp"
    ok "panel colorizer installed"
}

build_kurve() {
    log "installing kurve…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://github.com/luisbocanegra/kurve.git" "$tmp/kurve" 2>&1 | grep -v -E "^(remote:|Receiving|Resolving|Counting)" | grep -v "^$" || true

    cd "$tmp/kurve"
    chmod +x install.sh
    ./install.sh >/dev/null 2>&1 || true

    cd ~
    rm -rf "$tmp"
    ok "kurve installed"
}

install_krohnkite() {
    log "deploying krohnkite kwinscript…"

    local script="$REPO_DIR/krohnkite.kwinscript"

    if [ ! -f "$script" ]; then
        warn "krohnkite.kwinscript missing in repo"
        return
    fi

    # Use kpackagetool6 to install the KWin script
    if command -v kpackagetool6 >/dev/null 2>&1; then
        # Try to install, if already installed, try to upgrade
        if kpackagetool6 --type KWin/Script --install "$script" 2>/dev/null; then
            ok "krohnkite installed"
        elif kpackagetool6 --type KWin/Script --upgrade "$script" 2>/dev/null; then
            ok "krohnkite upgraded"
        else
            warn "krohnkite installation failed, trying manual method"
            # Fallback to manual installation
            local target="$HOME/.local/share/kwin/scripts/krohnkite"
            rm -rf "$target"
            mkdir -p "$target"
            unzip -q "$script" -d "$target"
            ok "krohnkite installed (manual) → $target"
        fi
    else
        warn "kpackagetool6 not found, using manual installation"
        # Manual installation
        local target="$HOME/.local/share/kwin/scripts/krohnkite"
        rm -rf "$target"
        mkdir -p "$target"
        unzip -q "$script" -d "$target"
        ok "krohnkite installed (manual) → $target"
    fi
}

build_kde_rounded_corners() {
    log "compiling kde‑rounded‑corners…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://github.com/matinlotfali/KDE-Rounded-Corners" "$tmp/kde-rounded-corners" 2>&1 | grep -v -E "^(remote:|Receiving|Resolving|Counting)" | grep -v "^$" || true

    cd "$tmp/kde-rounded-corners"
    mkdir build && cd build
    cmake .. >/dev/null 2>&1
    cmake --build . -j"$(nproc)" 2>&1 | grep -E "Built target|^\[" || true
    sudo make install >/dev/null 2>&1

    cd ~
    rm -rf "$tmp"
    ok "rounded corners installed"
}

setup_autorebuild_system() {
    log "configuring auto-rebuild for KDE Rounded Corners…"

    # Ensure the directory exists
    sudo mkdir -p /usr/local/bin

    # Create rebuild script
    sudo tee /usr/local/bin/rebuild-kde-rounded-corners.sh > /dev/null <<'REBUILD_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/kde-rounded-corners-rebuild.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== KDE Rounded Corners Rebuild Started ==="

# Create temporary directory
TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"

log "Cloning repository..."
if git clone "https://github.com/matinlotfali/KDE-Rounded-Corners" kde-rounded-corners; then
    log "Repository cloned successfully"
else
    log "ERROR: Failed to clone repository"
    rm -rf "$TMP_DIR"
    exit 1
fi

cd kde-rounded-corners

log "Building KDE Rounded Corners..."
if mkdir build && cd build; then
    if cmake .. && cmake --build . -j"$(nproc)"; then
        log "Build successful"
        
        log "Installing..."
        if make install; then
            log "Installation successful"
        else
            log "ERROR: Installation failed"
            cd ~
            rm -rf "$TMP_DIR"
            exit 1
        fi
    else
        log "ERROR: Build failed"
        cd ~
        rm -rf "$TMP_DIR"
        exit 1
    fi
else
    log "ERROR: Failed to create build directory"
    cd ~
    rm -rf "$TMP_DIR"
    exit 1
fi

# Cleanup
cd ~
rm -rf "$TMP_DIR"

log "=== KDE Rounded Corners Rebuild Completed Successfully ==="

# Reconfigure KWin to load the updated effect
if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    log "KWin reconfigured"
fi

exit 0
REBUILD_SCRIPT

    sudo chmod +x /usr/local/bin/rebuild-kde-rounded-corners.sh
    sudo touch /var/log/kde-rounded-corners-rebuild.log
    sudo chmod 666 /var/log/kde-rounded-corners-rebuild.log

    case "$DISTRO" in
        arch)
            log "installing pacman hook…"
            sudo mkdir -p /etc/pacman.d/hooks
            sudo tee /etc/pacman.d/hooks/kde-rounded-corners-rebuild.hook > /dev/null <<'HOOK'
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = kwin

[Action]
Description = Rebuilding KDE Rounded Corners after KWin update...
When = PostTransaction
Exec = /usr/local/bin/rebuild-kde-rounded-corners.sh
Depends = kwin
HOOK
            ok "pacman hook installed → auto-rebuild enabled"
            ;;
        debian)
            log "creating apt hook…"
            sudo tee /etc/apt/apt.conf.d/99-kde-rounded-corners-rebuild > /dev/null <<'APTHOOK'
DPkg::Post-Invoke {"if dpkg -l kwin-common 2>/dev/null | grep -q '^ii'; then /usr/local/bin/rebuild-kde-rounded-corners.sh; fi";};
APTHOOK
            ok "apt hook installed → auto-rebuild enabled"
            ;;
    esac

    ok "auto-rebuild system configured"
}

install_kyanite() {
    log "deploying kyanite kwinscript…"

    local script="$REPO_DIR/kyanite.kwinscript"

    if [ ! -f "$script" ]; then
        warn "kyanite.kwinscript missing in repo"
        return
    fi

    # Use kpackagetool6 to install the KWin script
    if command -v kpackagetool6 >/dev/null 2>&1; then
        # Try to install, if already installed, try to upgrade
        if kpackagetool6 --type KWin/Script --install "$script" 2>/dev/null; then
            ok "kyanite installed"
        elif kpackagetool6 --type KWin/Script --upgrade "$script" 2>/dev/null; then
            ok "kyanite upgraded"
        else
            warn "kyanite installation failed, trying manual method"
            # Fallback to manual installation
            local target="$HOME/.local/share/kwin/scripts/kyanite"
            rm -rf "$target"
            mkdir -p "$target"
            unzip -q "$script" -d "$target"
            ok "kyanite installed (manual) → $target"
        fi
    else
        warn "kpackagetool6 not found, using manual installation"
        # Manual installation
        local target="$HOME/.local/share/kwin/scripts/kyanite"
        rm -rf "$target"
        mkdir -p "$target"
        unzip -q "$script" -d "$target"
        ok "kyanite installed (manual) → $target"
    fi
}

deploy_config_folders() {
    log "deploying configuration modules…"

    local folders=(btop kitty fastfetch cava)

    for f in "${folders[@]}"; do
        if [ -d "$REPO_DIR/$f" ]; then
            backup_file "$HOME/.config/$f"
            rm -rf "$HOME/.config/$f"
            cp -r "$REPO_DIR/$f" "$HOME/.config/$f"
            ok "config → $f"
        else
            warn "missing → $f"
        fi
    done
}

deploy_rc_files() {
    log "deploying plasma rc files…"

    # kglobalaccel holds shortcuts in memory and writes on exit — stop it first
    if command -v kquitapp6 >/dev/null 2>&1; then
        kquitapp6 kglobalaccel 2>/dev/null || true
        sleep 1
        log "stopped kglobalaccel daemon"
    elif command -v kquitapp5 >/dev/null 2>&1; then
        kquitapp5 kglobalaccel 2>/dev/null || true
        sleep 1
        log "stopped kglobalaccel daemon"
    fi

    local rc_files=(
        kwinrc
        plasmarc
        plasma-org.kde.plasma.desktop-appletsrc
        breezerc
        kglobalshortcutsrc
    )

    for rc in "${rc_files[@]}"; do
        if [ -f "$REPO_DIR/$rc" ]; then
            backup_file "$HOME/.config/$rc"
            cp "$REPO_DIR/$rc" "$HOME/.config/$rc"
            ok "rc → $rc"
        else
            warn "missing → $rc"
        fi
    done

    # Restart kglobalaccel so it reads the new config
    if command -v kstart6 >/dev/null 2>&1; then
        kstart6 --service kglobalaccel 2>/dev/null || true
        log "restarted kglobalaccel daemon"
    elif command -v kstart5 >/dev/null 2>&1; then
        kstart5 --service kglobalaccel 2>/dev/null || true
        log "restarted kglobalaccel daemon"
    fi
}

deploy_kwinrules() {
    log "deploying kwinrulesrc…"

    local file="kwinrulesrc"

    if [ -f "$REPO_DIR/$file" ]; then
        backup_file "$HOME/.config/$file"
        cp "$REPO_DIR/$file" "$HOME/.config/$file"
        ok "rules → $file"
    else
        warn "missing → $file"
    fi
}

deploy_yamis_icons() {
    log "installing YAMIS icon theme…"

    mkdir -p "$HOME/.local/share/icons"

    local yamis_zip="$REPO_DIR/YAMIS.zip"
    local yamis_dest="$HOME/.local/share/icons"

    if [ -f "$yamis_zip" ]; then
        # Remove existing YAMIS installation if present
        [ -d "$yamis_dest/YAMIS" ] && rm -rf "$yamis_dest/YAMIS"
        
        # Extract YAMIS icons
        unzip -q "$yamis_zip" -d "$yamis_dest"
        ok "icons → YAMIS"
    else
        warn "YAMIS.zip not found at $yamis_zip"
    fi
}

deploy_modernclock() {
    log "installing Modern Clock widget…"

    mkdir -p "$HOME/.local/share/plasma/plasmoids"

    local clock_source="$REPO_DIR/com.github.prayag2.modernclock"
    local clock_dest="$HOME/.local/share/plasma/plasmoids/com.github.prayag2.modernclock"

    if [ -d "$clock_source" ]; then
        # Remove existing installation if present
        [ -d "$clock_dest" ] && rm -rf "$clock_dest"
        
        # Copy Modern Clock widget
        cp -r "$clock_source" "$clock_dest"
        ok "widget → Modern Clock"
    else
        warn "Modern Clock folder not found at $clock_source"
    fi
}

deploy_color_scheme() {
    log "installing CyberXero color scheme…"

    mkdir -p "$HOME/.local/share/color-schemes"

    if [ -f "$REPO_DIR/CyberXero.colors" ]; then
        cp "$REPO_DIR/CyberXero.colors" "$HOME/.local/share/color-schemes/"
        ok "colors → CyberXero"
    else
        warn "CyberXero.colors missing"
    fi
}

deploy_wallpapers() {
    log "deploying wallpapers…"

    mkdir -p "$HOME/Pictures"

    local images=(
        cyberfield.jpg
        cyberxero.png
        cyberxero2.png
    )

    for img in "${images[@]}"; do
        if [ -f "$REPO_DIR/$img" ]; then
            cp "$REPO_DIR/$img" "$HOME/Pictures/"
            ok "wallpaper → $img"
        else
            warn "missing → $img"
        fi
    done
}

set_active_wallpaper() {
    log "setting active wallpaper → cyberfield.jpg…"

    local wallpaper="$HOME/Pictures/cyberfield.jpg"
    local plasma_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

    # Verify the wallpaper file exists
    if [ ! -f "$wallpaper" ]; then
        warn "wallpaper file not found: $wallpaper"
        return 1
    fi

    local config_success=false
    local live_success=false

    # =========================================================================
    # STEP 1: Modify the config file directly (THIS is what persists on reboot)
    # =========================================================================
    
    if [ -f "$plasma_config" ]; then
        # Find all desktop containments (plugin=org.kde.plasma.folder or org.kde.desktopcontainment)
        # These are the containments that have wallpapers
        local desktop_containments
        desktop_containments=$(awk '
            /^\[Containments\]\[[0-9]+\]$/ { 
                gsub(/[^0-9]/, "", $0)
                current_id = $0
            }
            /^plugin=org\.kde\.(plasma\.folder|desktopcontainment)/ {
                print current_id
            }
        ' "$plasma_config" 2>/dev/null | sort -u)

        if [ -n "$desktop_containments" ]; then
            log "found desktop containments: $desktop_containments"
            
            for cid in $desktop_containments; do
                # Use kwriteconfig6 if available (cleaner)
                if command -v kwriteconfig6 >/dev/null 2>&1; then
                    kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
                        --group "Containments" --group "$cid" --group "Wallpaper" \
                        --group "org.kde.image" --group "General" \
                        --key "Image" "file://$wallpaper" 2>/dev/null
                    
                    # Also set WallpaperPlugin to ensure org.kde.image is active
                    kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
                        --group "Containments" --group "$cid" \
                        --key "wallpaperplugin" "org.kde.image" 2>/dev/null
                    
                    ok "config updated for containment $cid"
                    config_success=true
                fi
            done
        fi

        # Fallback: if no desktop containments found or kwriteconfig6 unavailable,
        # use awk to update ALL wallpaper sections in the file
        if [ "$config_success" = false ]; then
            log "using awk fallback for config modification…"
            
            awk -v wp="file://$wallpaper" '
                /^\[Containments\]\[[0-9]+\]\[Wallpaper\]\[org\.kde\.image\]\[General\]/ { in_section=1 }
                /^\[/ && !/^\[Containments\]\[[0-9]+\]\[Wallpaper\]\[org\.kde\.image\]\[General\]/ { in_section=0 }
                in_section && /^Image=/ { $0="Image=" wp }
                { print }
            ' "$plasma_config" > "$plasma_config.tmp" && mv "$plasma_config.tmp" "$plasma_config"
            
            ok "config updated via awk"
            config_success=true
        fi
    else
        warn "plasma config not found: $plasma_config"
    fi

    # =========================================================================
    # STEP 2: Apply live (optional, for immediate visual feedback)
    # This alone does NOT persist — Step 1 is what matters for reboot
    # =========================================================================

    # Try plasma-apply-wallpaperimage (Plasma 6)
    if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
        if plasma-apply-wallpaperimage "$wallpaper" 2>/dev/null; then
            ok "wallpaper applied live via plasma-apply-wallpaperimage"
            live_success=true
        fi
    fi

    # Try qdbus6 if plasma-apply didn't work
    if [ "$live_success" = false ] && command -v qdbus6 >/dev/null 2>&1; then
        local script="
            const allDesktops = desktops();
            for (const desktop of allDesktops) {
                desktop.wallpaperPlugin = 'org.kde.image';
                desktop.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
                desktop.writeConfig('Image', 'file://$wallpaper');
            }
        "
        if qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script" 2>/dev/null; then
            ok "wallpaper applied live via qdbus6"
            live_success=true
        fi
    fi

    # =========================================================================
    # STEP 3: Report results
    # =========================================================================

    if [ "$config_success" = true ]; then
        ok "wallpaper will persist after reboot"
        return 0
    else
        warn "could not modify config file — wallpaper may not persist after reboot"
        warn "please set wallpaper manually in System Settings → Wallpaper"
        return 1
    fi
}

apply_kde_theme_settings() {
    log "activating neon theme parameters…"

    # Set color scheme using plasma-apply-colorscheme
    if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
        plasma-apply-colorscheme CyberXero 2>/dev/null || true
        ok "color scheme activated → CyberXero"
    else
        warn "plasma-apply-colorscheme not found"
    fi

    # Set icon theme using kwriteconfig6
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "YAMIS"
        ok "icon theme activated → YAMIS"
    else
        warn "kwriteconfig6 not found"
    fi

    # Enable Krohnkite KWin script
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled true
        ok "krohnkite enabled"
    fi

    # Enable Kyanite KWin script
    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kwinrc --group Plugins --key kyaniteEnabled true
        ok "kyanite enabled"
    fi

    # Set the active wallpaper
    set_active_wallpaper

    # Reconfigure KWin to apply script changes (safe operation)
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
        ok "KWin reconfigured"
    fi
}

main() {
    printf "\n\033[1;35m┌───────────────────────────────────────────────────────┐\n"
    printf   "│  CYBERXERO DYNAMIC TILING THEME BY MURDERFROMMARS  │\n"
    printf   "└───────────────────────────────────────────────────────┘\033[0m\n\n"

    section "PHASE 1: SYSTEM PREPARATION"
    fetch_repo
    detect_distro
    install_dependencies

    section "PHASE 2: BUILDING CORE COMPONENTS"
    subsection "Window Manager Extensions"
    build_panel_colorizer
    build_kurve
    build_kde_rounded_corners
    setup_autorebuild_system
    
    subsection "KWin Scripts"
    install_krohnkite
    install_kyanite

    section "PHASE 3: THEME DEPLOYMENT"
    subsection "Visual Assets"
    deploy_yamis_icons
    deploy_modernclock
    deploy_color_scheme
    deploy_wallpapers
    
    subsection "Configuration Files"
    deploy_config_folders
    deploy_rc_files
    deploy_kwinrules
    
    subsection "Theme Activation"
    apply_kde_theme_settings

    printf "\n\033[1;35m╔═══════════════════════════════════════════════════════╗\033[0m\n"
    printf "\033[1;35m║\033[0m  \033[1;32mCYBERXERO DEPLOYMENT COMPLETE\033[0m                    \033[1;35m║\033[0m\n"
    printf "\033[1;35m╚═══════════════════════════════════════════════════════╝\033[0m\n\n"
    printf "\033[1;36m📦 Backup archive:\033[0m %s\n" "$BACKUP_DIR"
    printf "\033[1;36m📋 Auto-rebuild logs:\033[0m /var/log/kde-rounded-corners-rebuild.log\n\n"
    printf "\033[1;31m╔═══════════════════════════════════════════════════════╗\033[0m\n"
    printf "\033[1;31m║  ⚠️  ACTION REQUIRED: LOG OUT OR REBOOT NOW           ║\033[0m\n"
    printf "\033[1;31m║     to fully apply all theme changes!                 ║\033[0m\n"
    printf "\033[1;31m╚═══════════════════════════════════════════════════════╝\033[0m\n\n"
}

main "$@"
