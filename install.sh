#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Tim Micheletto
###########################


# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install MacVim with LUA support
brew install macvim --with-cscope --with-lua --override-system-vim

# Install vimrc
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# Install Core utils for consistent tooling between Mac and Linux
brew install coreutils

# Install MacDown
brew cask install macdown

# ADR Tools
brew install adr-tools

#Go
brew install go

# Install Ammonite
sudo sh -c '(echo "#!/usr/bin/env sh" && curl -L https://github.com/lihaoyi/Ammonite/releases/download/1.1.2/2.12-1.1.2) > /usr/local/bin/amm && chmod +x /usr/local/bin/amm' && amm
