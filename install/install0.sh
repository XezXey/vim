#!/bin/bash
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XezXey/vim/refs/heads/master/install/install0.sh)"
set -e  # exit on error

echo "==> Updating apt and adding repos..."
# Remove old/deprecated PPAs
sudo add-apt-repository --remove ppa:x4121/ripgrep 2>/dev/null || true
# Use stable neovim PPA (more reliable than unstable)
sudo add-apt-repository -y ppa:neovim-ppa/stable

# Node.js: use setup_lts.x (always points to the latest Active LTS, currently Node 22)
echo "==> Installing Node.js LTS via NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

sudo apt-get update
sudo apt-get install -y neovim zsh tmux curl ripgrep git exuberant-ctags nodejs unzip build-essential

echo "==> Changing default shell to zsh..."
chsh -s /usr/bin/zsh

# Clone the vim config (back up if existing)
if [ -d "$HOME/.vim" ]; then
    echo "==> Backing up existing ~/.vim to ~/.vim_old..."
    mv "$HOME/.vim" "$HOME/.vim_old"
fi
git clone https://github.com/XezXey/vim.git ~/.vim

echo "==> Copying neovim config..."
rm -rf ~/.config/nvim
cp -r ~/.vim/install/config/nvim-config ~/.config/nvim

echo "==> Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> Running secondary install (symlinks, LSP tools)..."
sh ~/.vim/install/install.sh

echo "==> Done! Please restart your shell or run: exec zsh"
exec zsh