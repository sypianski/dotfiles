#!/bin/bash
# Jednolinijkowa instalacja dotfiles:
# curl -fsSL https://raw.githubusercontent.com/sypianski/dotfiles/master/bootstrap.sh | bash

set -e

DOTFILES="$HOME/dotfiles"
REPO="https://github.com/sypianski/dotfiles.git"

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Bootstrap dotfiles ===${NC}"
echo ""

# === Sprawdzanie wymagań ===
check_requirements() {
    local missing=()

    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi

    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl lub wget")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Brakuje wymaganych programów:${NC}"
        for prog in "${missing[@]}"; do
            echo "  - $prog"
        done
        echo ""
        echo "Zainstaluj je przed kontynuowaniem:"

        # Podpowiedź zależna od systemu
        if command -v apt &> /dev/null; then
            echo "  sudo apt update && sudo apt install -y git curl"
        elif command -v brew &> /dev/null; then
            echo "  brew install git curl"
        elif command -v pkg &> /dev/null; then
            echo "  pkg install git curl"
        fi
        exit 1
    fi

    echo -e "${GREEN}[OK]${NC} Wymagania spełnione (git, curl/wget)"
}

check_requirements

# Klonuj lub aktualizuj repo
if [ -d "$DOTFILES" ]; then
    echo -e "${YELLOW}[*]${NC} Aktualizuję istniejące dotfiles..."
    cd "$DOTFILES" && git pull
else
    echo -e "${YELLOW}[*]${NC} Klonuję dotfiles..."
    git clone "$REPO" "$DOTFILES"
fi

# Uruchom install.sh
echo ""
"$DOTFILES/install.sh"

echo ""
echo -e "${GREEN}=== Następne kroki ===${NC}"
echo "Skopiuj sekrety z obecnego urządzenia:"
echo ""
echo "  scp yaqub@masawayh:~/.secrets ~/.secrets"
echo "  scp -r yaqub@masawayh:~/.ssh ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/*"
echo ""
echo -e "${GREEN}Gotowe!${NC}"
