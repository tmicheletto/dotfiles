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
echo "Linking dot files..."
cd "${repo_home}/dots"
for dot_file in !(zshrc); do
  rm -f "${HOME}/.${dot_file}" 2> /dev/null || true
  echo >&2 "Linking ~/.${dot_file}..."
  ln -s "${repo_home}/dots/${dot_file}" "${HOME}/.${dot_file}"
done

# Install powerline fonts
echo "Installing powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1 .fonts
# install
cd .fonts
./install.sh
# clean-up a bit
cd ..
rm -rf .fonts

# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install vimrc
echo "Installing vimrc..."
if [ ! -d ~/.vim_runtime ];
then
  git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh
else
  echo "~/.vim_runtime directory exists. Skipping vimrc..."
fi

# Install Ammonite
echo "Installng Ammonite..."
sudo sh -c '(echo "#!/usr/bin/env sh" && curl -L https://github.com/lihaoyi/Ammonite/releases/download/1.1.2/2.12-1.1.2) > /usr/local/bin/amm && chmod +x /usr/local/bin/amm' && amm
