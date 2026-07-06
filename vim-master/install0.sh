#!/bin/bash
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/supasorn/vim/master/install0.sh)"
sudo add-apt-repository --remove ppa:x4121/ripgrep
sudo add-apt-repository ppa:neovim-ppa/unstable
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get update
sudo apt -y install neovim zsh tmux curl ripgrep git exuberant-ctags nodejs unzip
chsh -s /usr/bin/zsh
rm -rf ~/.config/nvim
cp -r ./nvim-config ~/.config/nvim
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended"
cp -r ./v ~/.vim
sh ~//install.sh
zsh

#!/usr/bin/env sh

ln -sf ~/.vim/vimrc ~/.vimrc
ln -sf ~/.vim/gvimrc ~/.gvimrc
ln -sf ~/.vim/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/zshrc ~/.zshrc

mkdir -p ~/.config/lf
ln -sf ~/.vim/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/lfcd.sh ~/.config/lf/lfcd.sh

sudo npm i -g pyright vscode-langservers-extracted@latest
nvim +PlugInstall +qall
