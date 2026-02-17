#!/usr/bin/env sh

ln -sf ~/.vim/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/zshrc ~/.zshrc

mkdir -p ~/.config/nvim
ln -sf ~/.vim/init.vim ~/.config/nvim/init.vim

mkdir -p ~/.config/lf
ln -sf ~/.vim/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/lfcd.sh ~/.config/lf/lfcd.sh

sudo npm i -g pyright vscode-langservers-extracted@latest
nvim +PlugInstall +qall
