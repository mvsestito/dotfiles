#!/usr/bin/env bash

if [ "${PWD}" != "$HOME/bin" ]; then
    echo "PWD != $HOME/bin."
    echo "Please run the setup script from $HOME/bin"
    echo "Exiting..."
    exit
fi


echo "Starting setup..."
source scripts/functions.sh

# install homebrew
echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
exit_on_error "could not install homebrew"

# setup homebrew packages
which brew &> /dev/null
exit_on_error "brew command not found"

echo "Running brew update..."
brew update
exit_on_error "brew update failed"

echo "Installing required packages using brew bundle..."
brew bundle --filepath=../Brewfile
exit_on_error "brew bundle failed"

echo "Brew packages successfully installed"

## Setup symlinks to dotfiles
#### bash config
echo "Configuring bash dotfiles..."
ln -sf ~/bin/bash/bashrc ~/.bashrc
ln -sf ~/bin/bash/bash_profile ~/.bash_profile

### ssh config
echo "Configuring ssh dotfiles..."
# [ operator is a conditional test. shorthand for "test" keyword cmd
# check for existing sym link and rm it if exist
[ -L ~/.ssh/config ] && rm ~/.ssh/config
[ -f ~/.ssh/config ] && echo "~/.ssh/config exists. Delete and re-run setup." && exit
mkdir -p ~/.ssh
ln ~/bin/ssh/config ~/.ssh/config
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config

#### git config
echo "Configuring git dotfiles..."
ln -sf ~/bin/git/gitconfig ~/.gitconfig

#### tmux config
#echo "Configuring tmux dotfiles..."
# check for existing sym link and rm it if exist
#[ -L ~/.tmux ] && rm ~/.tmux
#[ -d ~/.tmux ] && echo "~/.tmux exists. Delete and re-run setup." && exit
#ln -sf ~/bin/tmux ~/.tmux
#ln -sf ~/bin/tmux/tmux.conf ~/.tmux.conf
#mkdir -p ~/.tmux/plugins
#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#~/.tmux/plugins/tpm/bin/install_plugins

#### vim config
echo "Configuring vim dotfiles..."
# check for existing sym link and rm it if exist
[ -L ~/.vim ] && rm ~/.vim
[ -d ~/.vim ] && echo "~/.vim exists. Delete and re-run setup." && exit
[ -L ~/.local/share/nvim/site/autoload] && rm ~/.local/share/nvim/site/autoload
[ -d ~/.local/share/nvim/site/autoload] && echo "~/.local/share/nvim/site/autoload exists. Delete and re-run setup." && exit
mkdir -p ~/.vim/autoload && mkdir -p ~/.local/share/nvim/site/autoload
ln -sf ~/bin/nvim ~/.vim
ln -sf ~/bin/nvim/init.vim ~/.vimrc
ln -sf ~/bin/nvim/autoload/plug.vim ~/.vim/autoload/plug.vim
# symlinks for neovim
ln -sf ~/.vim/autoload/plug.vim ~/.local/share/nvim/site/autoload/plug.vim
ln -sf ~/.vim/init.vim ~/.config/nvim/init.vim

#### Install all vim plugins
echo "Installing vim plugins"
vim +PlugInstall +PlugClean +qall

echo "dotfiles setup complete!"

