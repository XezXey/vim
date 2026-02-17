#!/usr/bin/env sh

ln -sf ~/.vim/config/tmux-config/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/config/zshrc-config/zshrc ~/.zshrc

mkdir -p ~/.config/lf
ln -sf ~/.vim/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/lfcd.sh ~/.config/lf/lfcd.sh

sudo npm i -g pyright vscode-langservers-extracted@latest
nvim +PlugInstall +qall
