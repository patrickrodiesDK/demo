#!/bin/bash

echo "Setting up Vim on macOS with Oh-My-Zsh..."

# Install vim
brew install vim neovim

# Create directories
mkdir -p ~/.vim/{colors,undo,autoload,plugged}
mkdir -p ~/.config/nvim

# Download color schemes
curl -sS -o ~/.vim/colors/gruvbox.vim https://raw.githubusercontent.com/morhetz/gruvbox/master/colors/gruvbox.vim
curl -sS -o ~/.vim/colors/dracula.vim https://raw.githubusercontent.com/dracula/vim/master/colors/dracula.vim

# Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Backup existing .vimrc if it exists
[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.backup

echo "✅ Setup complete!"
echo "Now edit ~/.vimrc with your preferred configuration"
echo "Then run: vim +PlugInstall +qall"
