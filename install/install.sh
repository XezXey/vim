#!/usr/bin/env sh
set -e

ln -sf ~/.vim/install/config/tmux-config/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/install/config/zshrc-config/zshrc ~/.zshrc

mkdir -p ~/.config/lf
ln -sf ~/.vim/install/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/install/lfcd.sh ~/.config/lf/lfcd.sh

# Install/update global npm packages:
# - pyright, vscode-langservers-extracted: LSP servers for Python, CSS, HTML, JSON, ESLint
# - tree-sitter-cli: required by nvim-treesitter (main branch) to compile parsers
echo "==> Installing global npm packages for LSP + tree-sitter..."
sudo npm install -g pyright vscode-langservers-extracted@latest tree-sitter-cli

# Bootstrap lazy.nvim and install all plugins headlessly
echo "==> Bootstrapping neovim plugins (this may take a while)..."
nvim --headless "+Lazy! sync" +qa 2>&1 || true
