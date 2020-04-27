#!/usr/bin/env bash

set -eou pipefail
shopt -s extglob

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Tim Micheletto
###########################

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --file=brew/Brewfile --no-upgrade

prezto_home="${HOME}/.zprezto"
repo_home="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

# Make sure Prezto has been installed
if [[ ! -d "${prezto_home}" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
  echo "Prezto already installed. Skipping..."
fi

# Clean out any Prezto changes and get latest
cd "${prezto_home}"
git checkout -- .
git pull
git submodule update --init --recursive

# Delete existing Prezto-owned RC files and re-link
cd "${prezto_home}/runcoms"
for rc_file in z*; do
  rm -f "${HOME}/.${rc_file}" 2> /dev/null || true
  ln -s "${prezto_home}/runcoms/${rc_file}" "${HOME}/.${rc_file}"
done

# Update ~/.zshrc to source dotfile repo zshrc
echo >&2 'Updating ~/.zshrc...'
echo "source ${repo_home}/dots/zshrc" >> "${HOME}/.zshrc"

# Link each of the dotfile repo files into the home directory
cd "${repo_home}/dots"
for dot_file in !(zshrc); do
  rm -f "${HOME}/.${dot_file}" 2> /dev/null || true
  echo >&2 "Linking ~/.${dot_file}..."
  ln -s "${repo_home}/dots/${dot_file}" "${HOME}/.${dot_file}"
done

# Create an extra settings file that to put things we don't want under source control
touch "${HOME}/.extra"

# Setup bin directory
# mkdir -p "${HOME}/bin"
# cp "${repo_home}"/bin/* "${HOME}/bin"

# Install powerline fonts
echo "Installing powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1 .fonts
# install
cd .fonts
./install.sh
# clean-up a bit
cd ..
rm -rf .fonts

# Install iterm2 color schemes
echo "Installing iterm2 color schemes"
if [ ! -d ~/iTerm2-Color-Schemes ];
then
  git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git ~/iTerm2-Color-Schemes
else
  echo "~/iTerm2-Color-Schemes directory exists. Skipping iTerm2-Color-Schemes..."
fi


# Install vimrc
echo "Installing vimrc..."
if [ ! -d ~/.vim_runtime ];
then
  git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh
else
  echo "~/.vim_runtime directory exists. Skipping vimrc..."
fi

# Import iterm preferences

# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/iterm"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# https://stackoverflow.com/questions/13762280/zsh-compinit-insecure-directories/41674919#41674919
sudo chown -R $(whoami) /usr/local/share/zsh
sudo chmod -R 755 /usr/local/share/zsh

# Set Zsh as default shell
chsh -s /bin/zsh

