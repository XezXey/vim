#!/bin/bash
#sh -c "$(curl -fsSL https://raw.githubusercontent.com/XezXey/vim/refs/heads/master/install/install0.sh)"
sudo add-apt-repository --remove ppa:x4121/ripgrep
sudo add-apt-repository ppa:neovim-ppa/unstable
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get update
sudo apt -y install neovim zsh tmux curl ripgrep git exuberant-ctags nodejs unzip
chsh -s /usr/bin/zsh
# Check if .vim is already existed then rename it to .vim_old
if [ -d "$HOME/.vim" ]; then
    sudo mv "$HOME/.vim" "$HOME/.vim_old"
fi
git clone https://github.com/XezXey/vim.git ~/.vim
rm -rf ~/.config/nvim
cp -r ~/.vim/install/config/nvim-config ~/.config/nvim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
sh ~/.vim/install/install.sh
zsh
