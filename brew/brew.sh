#!/usr/bin/env bash

 set -eou pipefail
 shopt -s extglob

 ###########################
 # This script installs the dotfiles and runs all other system configuration scripts
 # @author Tim Micheletto
 ###########################

 repo_home="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"

 # Change ownership of /usr/local
 sudo chown -R $(whoami) /usr/local/share/man/man8

 brew bundle
