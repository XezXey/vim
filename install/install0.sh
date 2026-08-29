#!/bin/bash
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/XezXey/vim/refs/heads/master/install/install0.sh)"
set -e  # exit on error

echo "==> Updating apt and adding repos..."
# Remove old/deprecated PPAs
sudo add-apt-repository --remove ppa:x4121/ripgrep 2>/dev/null || true
sudo add-apt-repository --remove ppa:neovim-ppa/stable 2>/dev/null || true
sudo add-apt-repository --remove ppa:neovim-ppa/unstable 2>/dev/null || true

# Neovim: check what version apt actually offers before adding any PPA.
# The config requires nvim >= 0.10 (lazy.nvim, treesitter main branch, etc.)
NVIM_MIN="0.10"
sudo apt-get update -qq
NVIM_APT=$(apt-cache policy neovim 2>/dev/null \
  | awk '/Candidate:/{print $2}' \
  | grep -oP '\d+\.\d+' | head -1 || echo "0.0")
echo "==> neovim available in apt: ${NVIM_APT:-none}  (minimum required: $NVIM_MIN)"
if awk "BEGIN {exit !(${NVIM_APT:-0} < $NVIM_MIN)}"; then
  echo "==> apt neovim is too old — adding ppa:neovim-ppa/stable..."
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get update -qq
else
  echo "==> apt neovim $NVIM_APT is sufficient, skipping PPA."
fi

# Node.js: use setup_lts.x (always points to the latest Active LTS, currently Node 22)
echo "==> Installing Node.js LTS via NodeSource..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

sudo apt-get install -y neovim zsh tmux curl ripgrep fzf git exuberant-ctags nodejs unzip build-essential

echo "==> Changing default shell to zsh..."
chsh -s /usr/bin/zsh

# Clone or update the vim config repo
REPO_URL="https://github.com/XezXey/vim.git"
if [ -d "$HOME/.vim/.git" ] && git -C "$HOME/.vim" remote get-url origin 2>/dev/null | grep -q "XezXey/vim"; then
  echo "==> ~/.vim already cloned \u2014 pulling latest changes..."
  git -C "$HOME/.vim" pull --ff-only
elif [ -d "$HOME/.vim" ]; then
  echo "==> ~/.vim exists but is not the vim repo \u2014 backing up to ~/.vim_old..."
  mv "$HOME/.vim" "$HOME/.vim_old"
  git clone "$REPO_URL" ~/.vim
else
  git clone "$REPO_URL" ~/.vim
fi

echo "==> Copying neovim config..."
rm -rf ~/.config/nvim
cp -r ~/.vim/install/config/nvim-config ~/.config/nvim

echo "==> Copying dotfiles's script..."
cp -r ~/.vim/install/config/dotfiles/ ~/dotfiles


echo "==> Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "==> Running secondary install (symlinks, LSP tools)..."
sh ~/.vim/install/install.sh

echo "==> Done! Please restart your shell or run: exec zsh"
exec zsh
