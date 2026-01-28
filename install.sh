#!/usr/bin/env bash
[ -z "$BASH_VERSION" ] && exec bash "$0" "$@"
set -euo pipefail

########################################
# CYBERXERO :: NEON SYSTEM INITIALIZER
########################################

REPO_DIR="$HOME/CyberXero-Theme-Repo"
BACKUP_DIR="$HOME/CyberXero-backup-$(date +%Y%m%d_%H%M%S)"
DISTRO="unknown"

log()  { printf "\033[1;36m[Ξ]\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m[✔]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$1"; }
err()  { printf "\033[1;31m[✖]\033[0m %s\n" "$1" >&2; }

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
        git clone https://github.com/MurderFromMars/CyberXero-Theme-Repo "$REPO_DIR"
        ok "repository cloned"
    else
        git -C "$REPO_DIR" pull --rebase
        ok "repository updated"
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
        git cmake extra-cmake-modules base-devel unzip

    if command -v yay >/dev/null 2>&1; then
        yay -S --needed --noconfirm qt5-tools
    elif command -v paru >/dev/null 2>&1; then
        paru -S --needed --noconfirm qt5-tools
    else
        warn "AUR helper not found → qt5-tools skipped"
    fi

    ok "arch dependencies installed"
}

install_debian_dependencies() {
    log "installing debian dependencies…"

    sudo apt update
    sudo apt install -y \
        git cmake g++ extra-cmake-modules kwin-dev unzip \
        qt6-base-private-dev qt6-base-dev-tools \
        libkf6kcmutils-dev libdrm-dev libplasma-dev

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
    git clone "https://github.com/luisbocanegra/plasma-panel-colorizer" "$tmp/plasma-panel-colorizer"

    cd "$tmp/plasma-panel-colorizer"
    chmod +x install.sh
    ./install.sh || true

    cd ~
    rm -rf "$tmp"
    ok "panel colorizer installed"
}

build_kurve() {
    log "installing kurve…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://github.com/luisbocanegra/kurve.git" "$tmp/kurve"

    cd "$tmp/kurve"
    chmod +x install.sh
    ./install.sh || true

    cd ~
    rm -rf "$tmp"
    ok "kurve installed"
}

install_krohnkite() {
    log "checking krohnkite…"

    local dir="$HOME/.local/share/kwin/scripts/krohnkite"

    if [ -d "$dir" ]; then
        ok "krohnkite already present"
        return
    fi

    log "installing krohnkite…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://codeberg.org/anametologin/Krohnkite" "$tmp/krohnkite"

    cd "$tmp/krohnkite"
    chmod +x install.sh
    ./install.sh || true

    cd ~
    rm -rf "$tmp"
    ok "krohnkite installed"
}

build_kde_rounded_corners() {
    log "compiling kde‑rounded‑corners…"

    local tmp
    tmp="$(mktemp -d)"
    git clone "https://github.com/matinlotfali/KDE-Rounded-Corners" "$tmp/kde-rounded-corners"

    cd "$tmp/kde-rounded-corners"
    mkdir build && cd build
    cmake ..
    cmake --build . -j"$(nproc)"
    sudo make install

    cd ~
    rm -rf "$tmp"
    ok "rounded corners installed"
}

install_kyanite() {
    log "deploying kyanite kwinscript…"

    local script="$REPO_DIR/kyanite.kwinscript"
    local target="$HOME/.local/share/kwin/scripts/kyanite"

    if [ ! -f "$script" ]; then
        warn "kyanite.kwinscript missing in repo"
        return
    fi

    if [ -d "$target" ]; then
        ok "kyanite already installed"
        return
    fi

    mkdir -p "$target"
    unzip -q "$script" -d "$target"

    ok "kyanite installed → $target"
}

deploy_config_folders() {
    log "deploying configuration modules…"

    local folders=(btop kitty fastfetch)

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

    local rc_files=(
        kwinrc
        plasmarc
        plasma-org.kde.plasma.desktop-appletsrc
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

    local yamis_source="$REPO_DIR/YAMIS"
    local yamis_dest="$HOME/.local/share/icons/YAMIS"

    if [ -d "$yamis_source" ]; then
        # Remove existing installation if present
        [ -d "$yamis_dest" ] && rm -rf "$yamis_dest"
        
        # Copy YAMIS icons
        cp -r "$yamis_source" "$yamis_dest"
        ok "icons → YAMIS"
    else
        warn "YAMIS folder not found at $yamis_source"
        ls -la "$REPO_DIR" | head -20
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

apply_kde_theme_settings() {
    log "activating neon theme parameters…"

    # Set color scheme using plasma-apply-colorscheme
    if command -v plasma-apply-colorscheme >/dev/null 2>&1; then
        plasma-apply-colorscheme CyberXero
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

    # Reconfigure KWin to apply script changes
    if command -v qdbus6 >/dev/null 2>&1; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
        ok "KWin reconfigured"
    fi

    # Refresh KDE settings
    if command -v kquitapp6 >/dev/null 2>&1; then
        kquitapp6 plasmashell 2>/dev/null || true
        sleep 1
        kstart plasmashell 2>/dev/null & disown
        ok "plasmashell restarted"
    fi
}

main() {
    printf "\n\033[1;35m┌───────────────────────────────────────────────────────┐\n"
    printf   "│  CYBERXERO DYNAMIC TILING THEME BY MURDERFROMMARS  │\n"
    printf   "└───────────────────────────────────────────────────────┘\033[0m\n\n"

    fetch_repo
    detect_distro
    install_dependencies

    build_panel_colorizer
    build_kurve
    install_krohnkite
    build_kde_rounded_corners
    install_kyanite

    deploy_config_folders
    deploy_rc_files
    deploy_kwinrules
    deploy_yamis_icons
    deploy_color_scheme
    apply_kde_theme_settings

    printf "\n\033[1;32m[✔] CYBERXERO DEPLOYMENT COMPLETE\033[0m\n"
    printf "\033[1;36mbackup archive → $BACKUP_DIR\033[0m\n\n"
}

main "$@"
