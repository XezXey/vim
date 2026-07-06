#!/usr/bin/env sh
set -e

ln -sf ~/.vim/install/config/tmux-config/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/install/config/zshrc-config/zshrc ~/.zshrc

mkdir -p ~/.config/lf
ln -sf ~/.vim/install/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/install/lfcd.sh ~/.config/lf/lfcd.sh

# Install/update global LSP packages (pyright + CSS/HTML/JSON/ESLint language servers)
echo "==> Installing global npm packages for LSP..."
sudo npm install -g pyright vscode-langservers-extracted@latest

# Bootstrap lazy.nvim and install all plugins headlessly
echo "==> Bootstrapping neovim plugins (this may take a while)..."
nvim --headless "+Lazy! sync" +qa 2>&1 || true
