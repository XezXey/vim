#!/bin/bash
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XezXey/vim/refs/heads/master/install/install0.sh)"
set -e  # exit on error

echo "==> Updating apt and adding repos..."
# Remove old/deprecated PPAs
sudo add-apt-repository --remove ppa:x4121/ripgrep 2>/dev/null || true
sudo add-apt-repository --remove ppa:neovim-ppa/stable 2>/dev/null || true
sudo add-apt-repository --remove ppa:neovim-ppa/unstable 2>/dev/null || true

# Neovim PPA: only needed on Ubuntu < 24.04 — Ubuntu 24.04+ and 26.04 (Resolute)
# ship a recent neovim (0.11/0.12) in their official repos, so no PPA required.
UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null || echo "0")
if awk "BEGIN {exit !($UBUNTU_VERSION < 24.04)}"; then
  echo "==> Ubuntu < 24.04 detected — adding neovim-ppa/stable..."
  sudo add-apt-repository -y ppa:neovim-ppa/stable
else
  echo "==> Ubuntu $UBUNTU_VERSION — neovim available from official repos, skipping PPA."
fi

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