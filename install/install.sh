#!/usr/bin/env sh

ln -sf ~/.vim/install/config/tmux-config/tmux.conf ~/.tmux.conf
ln -sf ~/.vim/install/config/zshrc-config/zshrc ~/.zshrc

mkdir -p ~/.config/lf
ln -sf ~/.vim/install/lfrc ~/.config/lf/lfrc
ln -sf ~/.vim/install/lfcd.sh ~/.config/lf/lfcd.sh

sudo npm i -g pyright vscode-langservers-extracted@latest
nvim +PlugInstall +qall
