#!/bin/bash
# ~/dotfiles/install.sh - automatyczna instalacja symlinków
# Użycie: ./install.sh

set -e
DOTFILES="$HOME/dotfiles"

# Detekcja Termux
if [ -n "$PREFIX" ] && [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=1
    PKG="pkg"
    echo "Wykryto Termux"
else
    IS_TERMUX=0
    PKG="sudo apt"
    echo "Wykryto Linux"
fi

echo "Instaluję dotfiles z $DOTFILES..."

# Instaluj fish jeśli brakuje
if ! command -v fish &> /dev/null; then
    echo "Instaluję fish..."
    $PKG install fish -y
fi

mkdir -p ~/.config

# Usuń istniejące pliki/katalogi jeśli istnieją
rm -rf ~/.config/fish ~/.config/nvim ~/.config/himalaya ~/.tmux.conf ~/.tmux ~/.termux ~/.bashrc ~/.gitconfig ~/.hushlogin

# Utwórz symlinki
ln -s "$DOTFILES/fish" ~/.config/fish
ln -s "$DOTFILES/nvim" ~/.config/nvim
ln -s "$DOTFILES/himalaya" ~/.config/himalaya
ln -s "$DOTFILES/.tmux.conf" ~/.tmux.conf
ln -s "$DOTFILES/.tmux" ~/.tmux
ln -s "$DOTFILES/termux" ~/.termux
ln -s "$DOTFILES/.bashrc" ~/.bashrc
ln -s "$DOTFILES/.gitconfig" ~/.gitconfig
ln -s "$DOTFILES/.hushlogin" ~/.hushlogin

echo ""
echo "Symlinki utworzone!"
echo ""
echo "Pamiętaj o ręcznym skopiowaniu:"
echo "  - ~/.secrets (API keys)"
echo "  - ~/.ssh/ (klucze SSH)"
