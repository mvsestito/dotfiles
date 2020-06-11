#!/usr/bin/env bash

if [ "${PWD}" != "$HOME/bin" ]; then
    echo "PWD != $HOME/bin."
    echo "Please run the setup script from $HOME/bin"
    echo "Exiting..."
    exit
fi


echo "Starting setup..."
source scripts/functions.sh

# first switch the shell to zsh
echo "Switching shell to zsh..."
chsh -s /bin/zsh

# install homebrew
# check if already installed
echo "Checking for existing Homebrew installation..."
which brew &> /dev/null
if [[ 0"$?" != 0"0" ]]; then
    echo "Installing Homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    exit_on_error "could not install homebrew"
else
    echo "Existing Homebrew found"
fi

# setup homebrew packages
echo "Running brew update..."
brew update
exit_on_error "brew update failed"

echo "Installing required packages using brew bundle..."
brew bundle
exit_on_error "brew bundle failed"

echo "Brew packages successfully installed"

## Setup symlinks to dotfiles
#### bash config
echo "Configuring bash dotfiles..."
ln -sf $HOME/bin/bash/bashrc $HOME/.bashrc
ln -sf $HOME/bin/bash/bash_profile $HOME/.bash_profile

## create ctags file
# run "ctags -R ." on project directory root to build tags file
echo "Linking ctags files..."
# create directory if not exists
mkdir -p $HOME/.ctags.d
for f in $HOME/bin/ctags/* do
	OUT_PATH="$HOME/.ctags.d/$(echo $f | cut -d'/' -f6)"
	echo "linking $f to $OUT_PATH"

	ln -sf $f $OUT_PATH
done

### ssh config
echo "Configuring ssh dotfiles..."
# [ operator is a conditional test. shorthand for "test" keyword cmd
# check for existing sym link and rm it if exist
[ -L $HOME/.ssh/config ] && rm $HOME/.ssh/config
[ -f $HOME/.ssh/config ] && echo "$HOME/.ssh/config exists. Delete and re-run setup." && exit
mkdir -p $HOME/.ssh
ln $HOME/bin/ssh/config $HOME/.ssh/config
chmod 700 $HOME/.ssh
chmod 600 $HOME/.ssh/config

#### git config
echo "Configuring git dotfiles..."
ln -sf $HOME/bin/git/gitconfig $HOME/.gitconfig

#### tmux config
#echo "Configuring tmux dotfiles..."
# check for existing sym link and rm it if exist
#[ -L $HOME/.tmux ] && rm $HOME/.tmux
#[ -d $HOME/.tmux ] && echo "$HOME/.tmux exists. Delete and re-run setup." && exit
#ln -sf $HOME/bin/tmux $HOME/.tmux
#ln -sf $HOME/bin/tmux/tmux.conf $HOME/.tmux.conf
#mkdir -p $HOME/.tmux/plugins
#git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
#$HOME/.tmux/plugins/tpm/bin/install_plugins

#### vim config
echo "Configuring vim dotfiles..."
# check for existing sym link and rm it if exist
[ -L $HOME/.vim ] && rm $HOME/.vim
# check if real dir
[ -d $HOME/.vim ] && echo "$HOME/.vim exists. Delete and re-run setup." && exit
[ -L $HOME/.local/share/nvim/site/autoload ] && rm $HOME/.local/share/nvim/site/autoload
[ -d $HOME/.local/share/nvim/site/autoload ] && echo "$HOME/.local/share/nvim/site/autoload exists. Delete and re-run setup." && exit
[ -L $HOME/.config/nvim/init.vim ] && rm $HOME/.config/nvim/init.vim
# check if real file
[ -f $HOME/.config/nvim/init.vim ] && echo "$HOME/.config/nvim/init.vim exists. Delete and re-run setup." && exit
# check for plugged dir
[ -d $HOME/.config/nvim/plugged ] && echo "$HOME/.config/nvim/plugged exists. Delete and re-run setup." && exit

mkdir -p $HOME/.vim/autoload
mkdir -p $HOME/.vim/colors
mkdir -p $HOME/.local/share/nvim/site/autoload

ln -sf $HOME/bin/nvim $HOME/.vim
ln -sf $HOME/bin/nvim/init.vim $HOME/.vim/.vimrc
ln -sf $HOME/bin/nvim/colors/molokai.vim $HOME/.vim/colors/molokai.vim
ln -sf $HOME/bin/nvim/autoload/plug.vim $HOME/.vim/autoload/plug.vim

# symlinks for local neovim
ln -sf $HOME/.vim/autoload/plug.vim $HOME/.local/share/nvim/site/autoload/plug.vim
mkdir -p $HOME/.config/nvim
ln -sf $HOME/.vim/.vimrc $HOME/.config/nvim/init.vim

#### install pip packages
echo "Installing pip packages..."
pip3 install -r requirements.txt

# need to install neovim for python2.7 for ctags
pip2 install neovim

#### Install all vim plugins
echo "Installing vim plugins..."
nvim -c "PlugInstall | PlugClean | qall"

#### source colorscheme
nvim -c "source $HOME/.vim/colors/molokai.vim | qall"

#### Coc Extensions
echo "Installing coc-extensions..."
nvim -c 'CocInstall -sync coc-json coc-python coc-java coc-go coc-metals coc-solargraph coc-tsserver | qall'

echo "dotfiles setup complete!"

