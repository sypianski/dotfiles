#!/bin/bash
# ~/dotfiles/install.sh - automatyczna instalacja dotfiles
# Użycie: ./install.sh [--yes]
#   --yes  Pomiń pytania, zainstaluj wszystko

set -e

DOTFILES="$HOME/dotfiles"

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flaga auto-yes
AUTO_YES=false
[[ "$1" == "--yes" || "$1" == "-y" ]] && AUTO_YES=true

# === Wykrywanie platformy ===
detect_platform() {
    if [[ -n "$TERMUX_VERSION" ]]; then
        PLATFORM="termux"
        PKG_INSTALL="pkg install -y"
        PKG_UPDATE="pkg update"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        PKG_INSTALL="brew install"
        PKG_UPDATE="brew update"
    elif [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
        PKG_INSTALL="sudo apt install -y"
        PKG_UPDATE="sudo apt update"
    elif [[ -f /etc/arch-release ]]; then
        PLATFORM="arch"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
    else
        PLATFORM="linux"
        PKG_INSTALL=""
        PKG_UPDATE=""
    fi

    echo -e "${BLUE}[i]${NC} Wykryto platformę: ${GREEN}$PLATFORM${NC}"
}

# === Funkcja pytania tak/nie ===
ask() {
    if $AUTO_YES; then
        return 0
    fi

    # Jeśli nie ma terminala (np. curl | bash), użyj domyślnej odpowiedzi
    if [[ ! -t 0 ]]; then
        [[ "${2:-y}" == "y" ]] && return 0 || return 1
    fi

    local prompt="$1"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -p "$prompt" -n 1 -r < /dev/tty
    echo

    if [[ -z "$REPLY" ]]; then
        [[ "$default" == "y" ]] && return 0 || return 1
    fi

    [[ "$REPLY" =~ ^[Yy]$ ]]
}

# === Instalacja zależności ===
install_dependencies() {
    if [[ -z "$PKG_INSTALL" ]]; then
        echo -e "${YELLOW}[!]${NC} Nieznany menedżer pakietów - pomiń instalację zależności"
        return
    fi

    echo ""
    echo -e "${BLUE}=== Instalacja zależności ===${NC}"

    # Lista pakietów do instalacji
    local packages=()

    if ask "Zainstalować Fish shell?"; then
        packages+=("fish")
    fi

    if ask "Zainstalować tmux?"; then
        packages+=("tmux")
    fi

    if ask "Zainstalować Neovim?"; then
        if [[ "$PLATFORM" == "termux" ]]; then
            packages+=("neovim")
        elif [[ "$PLATFORM" == "macos" ]]; then
            packages+=("neovim")
        else
            packages+=("neovim")
        fi
    fi

    if ask "Zainstalować narzędzia pomocnicze (fzf, ripgrep, bat, eza)?"; then
        packages+=("fzf" "ripgrep" "bat")
        if [[ "$PLATFORM" == "macos" || "$PLATFORM" == "termux" ]]; then
            packages+=("eza")
        elif [[ "$PLATFORM" == "debian" ]]; then
            packages+=("exa")  # starsze wersje Debiana
        fi
    fi

    if ask "Zainstalować monitor systemu (htop)?"; then
        packages+=("htop")
    fi

    if ask "Zainstalować Node.js (wymagane dla Claude Code)?"; then
        if [[ "$PLATFORM" == "termux" ]]; then
            packages+=("nodejs")
        elif [[ "$PLATFORM" == "macos" ]]; then
            packages+=("node")
        else
            packages+=("nodejs" "npm")
        fi
    fi

    if [[ ${#packages[@]} -eq 0 ]]; then
        echo -e "${YELLOW}[!]${NC} Brak pakietów do instalacji"
        return
    fi

    echo ""
    echo -e "${YELLOW}[*]${NC} Aktualizuję listę pakietów..."
    eval "$PKG_UPDATE"

    echo -e "${YELLOW}[*]${NC} Instaluję: ${packages[*]}"
    eval "$PKG_INSTALL ${packages[*]}"

    echo -e "${GREEN}[OK]${NC} Zależności zainstalowane"
}

# === Instalacja Claude Code ===
install_claude() {
    if ! command -v npm &> /dev/null; then
        return
    fi

    echo ""
    if ask "Zainstalować Claude Code?"; then
        echo -e "${YELLOW}[*]${NC} Instaluję Claude Code..."
        npm install -g @anthropic-ai/claude-code
        echo -e "${GREEN}[OK]${NC} Claude Code zainstalowany"
    fi
}

# === Tworzenie symlinków ===
create_symlinks() {
    echo ""
    echo -e "${BLUE}=== Tworzenie symlinków ===${NC}"

    mkdir -p ~/.config ~/.ssh ~/.claude

    # Lista symlinków: źródło -> cel
    declare -A symlinks=(
        ["$DOTFILES/fish"]="$HOME/.config/fish"
        ["$DOTFILES/nvim"]="$HOME/.config/nvim"
        ["$DOTFILES/himalaya"]="$HOME/.config/himalaya"
        ["$DOTFILES/.tmux.conf"]="$HOME/.tmux.conf"
        ["$DOTFILES/.tmux"]="$HOME/.tmux"
        ["$DOTFILES/.bashrc"]="$HOME/.bashrc"
        ["$DOTFILES/.gitconfig"]="$HOME/.gitconfig"
        ["$DOTFILES/.hushlogin"]="$HOME/.hushlogin"
        ["$DOTFILES/ssh/config"]="$HOME/.ssh/config"
        ["$DOTFILES/.claude/settings.local.json"]="$HOME/.claude/settings.local.json"
    )

    # Termux-specific
    if [[ "$PLATFORM" == "termux" ]]; then
        symlinks["$DOTFILES/termux"]="$HOME/.termux"
    fi

    for src in "${!symlinks[@]}"; do
        local dst="${symlinks[$src]}"
        local name=$(basename "$dst")

        # Sprawdź czy źródło istnieje
        if [[ ! -e "$src" ]]; then
            echo -e "${YELLOW}[!]${NC} Pominięto $name (brak źródła)"
            continue
        fi

        # Usuń istniejący plik/symlink
        if [[ -e "$dst" || -L "$dst" ]]; then
            rm -rf "$dst"
        fi

        ln -s "$src" "$dst"
        echo -e "${GREEN}[+]${NC} $name"
    done

    # Uprawnienia SSH
    chmod 700 ~/.ssh 2>/dev/null || true
    chmod 600 ~/.ssh/config 2>/dev/null || true

    echo -e "${GREEN}[OK]${NC} Symlinki utworzone"
}

# === Ustawienie Fish jako domyślnej powłoki ===
set_default_shell() {
    if ! command -v fish &> /dev/null; then
        return
    fi

    local fish_path=$(which fish)
    local current_shell=$(basename "$SHELL")

    if [[ "$current_shell" == "fish" ]]; then
        echo -e "${GREEN}[OK]${NC} Fish już jest domyślną powłoką"
        return
    fi

    echo ""
    if ask "Ustawić Fish jako domyślną powłokę?"; then
        if [[ "$PLATFORM" == "termux" ]]; then
            chsh -s "$fish_path" && echo -e "${GREEN}[OK]${NC} Fish ustawiony jako domyślna powłoka"
        else
            # Dodaj fish do /etc/shells jeśli nie ma
            if ! grep -q "$fish_path" /etc/shells 2>/dev/null; then
                echo -e "${YELLOW}[*]${NC} Dodaję fish do /etc/shells..."
                echo "$fish_path" | sudo tee -a /etc/shells > /dev/null
            fi
            if chsh -s "$fish_path" 2>/dev/null; then
                echo -e "${GREEN}[OK]${NC} Fish ustawiony jako domyślna powłoka (zaloguj się ponownie)"
            else
                echo -e "${YELLOW}[!]${NC} Nie udało się zmienić powłoki. Uruchom ręcznie: chsh -s $fish_path"
            fi
        fi
    fi
}

# === Instalacja pluginów tmux ===
install_tmux_plugins() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo ""
        if ask "Zainstalować tmux plugin manager (TPM)?"; then
            echo -e "${YELLOW}[*]${NC} Klonuję TPM..."
            git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
            echo -e "${GREEN}[OK]${NC} TPM zainstalowany"
            echo -e "${BLUE}[i]${NC} Uruchom tmux i naciśnij prefix + I aby zainstalować pluginy"
        fi
    fi
}

# === Main ===
main() {
    echo -e "${GREEN}=== Instalacja dotfiles ===${NC}"
    echo ""

    detect_platform

    if ask "Zainstalować zależności systemowe?" "y"; then
        install_dependencies
    fi

    install_claude
    create_symlinks
    set_default_shell
    install_tmux_plugins

    echo ""
    echo -e "${GREEN}=== Instalacja zakończona ===${NC}"
    echo ""
    echo -e "${YELLOW}Pamiętaj o ręcznym skopiowaniu:${NC}"
    echo "  - ~/.secrets (API keys)"
    echo "  - ~/.ssh/id_* (klucze SSH)"
}

main
