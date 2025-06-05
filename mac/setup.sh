#!/bin/bash -eu

readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly BREW_LIBS=(
  "aws-vault --cask"
  "git"
  "go-task"
  "neovim"
  "tfenv"
  "tmux"
)

function separator_line() {
    echo "============================================================================"
}

function print_separator() {
    echo ""
    separator_line
    echo ""
}

function is_installed() {
  type "$1" >/dev/null 2>&1
}

print_separator


#######################################
# Create symlink.
#######################################
symlink_src=(
  "${HOME}/.config/nvim/coc-settings.json"
  "${HOME}/.config/nvim/init.lua"
  "${HOME}/.config/nvim/lua/config/lazy.lua"
  "${HOME}/.tmux.conf"
  "${HOME}/.vimrc"
  "${HOME}/.vim/coc-settings.json"
  "${HOME}/.zshenv"
  "${HOME}/.zshrc"
  "${HOME}/.zprofile"
)

symlink_dest=(
  "${DOTFILES_DIR}/nvim/coc-settings.json"
  "${DOTFILES_DIR}/nvim/init.lua"
  "${DOTFILES_DIR}/nvim/lazy.lua"
  "${DOTFILES_DIR}/tmux/tmux.conf"
  "${DOTFILES_DIR}/vim/vimrc"
  "${DOTFILES_DIR}/vim/coc-settings.json"
  "${DOTFILES_DIR}/zsh/zshenv"
  "${DOTFILES_DIR}/zsh/zshrc"
  "${DOTFILES_DIR}/zsh/zprofile"
)

echo "Set up config files..."
for ((i=0; i<${#symlink_src[@]}; i++)); do
  src=${symlink_src[$i]}
  dest=${symlink_dest[$i]}

  if [[ -L $src ]] && [[ $(readlink $src) == $dest ]]; then
    echo "Skipping: ${src} already links to ${dest}."
  else
    echo "Creating symlink: ${src} -> ${dest}..."
    ln -sf $dest $src
  fi
done

print_separator


#######################################
# Install Homebrew and add it to the system PATH. Then, installing libraries.
#######################################
echo "Install Homebrew..."
if is_installed brew; then
  echo "Skipping: Homebrew is already installed."
else
  echo "Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/${USER}/.zprofile
  eval $(/opt/homebrew/bin/brew shellenv)
fi

echo "Install libraries through Homebrew..."
brew bundle --file=../Brewfile

print_separator


#######################################
# Set up git.
#######################################
if ! git config --global user.name>/dev/null 2>&1; then
  echo "============= DO IT =============="
  echo "Your name is not set in git config"
  echo ""
  echo "> git config --global user.name \"USERNAME\""
  echo "=================================="
fi

if ! git config --global user.email>/dev/null 2>&1; then
  echo "============= DO IT =============="
  echo "Your email is not set in git config"
  echo ""
  echo "> git config --global user.name \"EMAIL\""
  echo "=================================="
fi

if ssh -T git@github.com>/dev/null 2>&1; then
  echo "============= DO IT =============="
  echo "Your SSH key is either not added to GitHub or not being used correctly."
  echo ""
  echo "ssh-keygen"
  echo "Enter file in which to save the key (/\$HOME/.ssh/github.key):"
  echo "Enter passphrase (empty for no passphrase): "
  echo "pbcopy < \$HOME/.ssh/github.key.pub"
  echo "Add the SSH public key to GitHub"
  echo "ssh -T git@github.com"
  echo "If the connection is successful, you should see the following message:"
  echo "> Hi username! You've successfully authenticated, but GitHub does not provide shell access."
  echo ""
  echo "=================================="
fi

if is_installed git; then
  echo "Setting up Git aliases..."
  git config --global alias.c "commit"
  git config --global alias.cm "commit -m"
  git config --global alias.can "commit --amend --no-edit"
  git config --global alias.p "push"
  git config --global alias.push-f "push --force-with-lease"
  git config --global alias.po "push origin"
  git config --global alias.pom "push origin main"
  git config --global alias.ds "diff --staged"
  git config --global alias.st "status"
fi

