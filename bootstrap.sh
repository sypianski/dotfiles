#!/bin/bash
# Jednolinijkowa instalacja dotfiles:
# curl -fsSL https://raw.githubusercontent.com/sypianski/dotfiles/master/bootstrap.sh | bash

set -e

DOTFILES="$HOME/dotfiles"
REPO="https://github.com/sypianski/dotfiles.git"

echo "=== Bootstrap dotfiles ==="

# Klonuj lub aktualizuj repo
if [ -d "$DOTFILES" ]; then
    echo "Aktualizuję istniejące dotfiles..."
    cd "$DOTFILES" && git pull
else
    echo "Klonuję dotfiles..."
    git clone "$REPO" "$DOTFILES"
fi

# Uruchom install.sh
echo ""
"$DOTFILES/install.sh"

echo ""
echo "=== Następne kroki ==="
echo "Skopiuj sekrety z obecnego urządzenia:"
echo ""
echo "  scp yaqub@masawayh:~/.secrets ~/.secrets"
echo "  scp -r yaqub@masawayh:~/.ssh ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/*"
echo ""
echo "Gotowe!"
