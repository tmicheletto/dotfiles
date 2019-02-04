#!/usr/bin/env bash

set -eou pipefail
shopt -s extglob

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Tim Micheletto
###########################

repo_home="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

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

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install vimrc
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#Brew bundle
brew tap Homebrew/bundle
brew bundle --file "${repo_home}/brew/Brewfile"

# Install Ammonite
sudo sh -c '(echo "#!/usr/bin/env sh" && curl -L https://github.com/lihaoyi/Ammonite/releases/download/1.1.2/2.12-1.1.2) > /usr/local/bin/amm && chmod +x /usr/local/bin/amm' && amm
