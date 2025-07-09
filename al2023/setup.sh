#!/bin/bash -eu

BREW_PREFIX="/home/linuxbrew/.linuxbrew"
DOTFILES_DIR="${HOME}/dotfiles"

function print_separator() {
    echo ""
    echo "============================================================================"
    echo ""
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

git_aliases=(
    "c commit"
    "can commit --amend --no-edit"
    "cm commit -m"
    "ds diff --staged"
    "p push"
    "push-f push --force-with-lease"
    "po push origin"
    "pom push origin main"
    "st status"
)

echo "Set up config files..."
for ((i=0; i<${#symlink_src[@]}; i++)); do
  src=${symlink_src[$i]}
  dest=${symlink_dest[$i]}

  if [[ ! -d "$src_dir" ]]; then
    echo "Creating directory: $src_dir"
    mkdir -p "$src_dir"
  fi

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
if type brew > /dev/null 2>&1; then
  echo "Skipping: Homebrew is already installed."
else
  echo "Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "${HOME}/.zshrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Install libraries through Homebrew..."
brew bundle --file="${DOTFILES_DIR}/Brewfile"

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
  echo "Enter file in which to save the key (/\$HOME/.ssh/keys/github.key):"
  echo "Enter passphrase (empty for no passphrase): "
  echo "pbcopy < \$HOME/.ssh/keys/github.key.pub"
  echo "Add the SSH public key to GitHub"
  echo "ssh -T git@github.com"
  echo "If the connection is successful, you should see the following message:"
  echo "> Hi username! You've successfully authenticated, but GitHub does not provide shell access."
  echo ""
  echo "=================================="
fi

echo ""
echo "Setting up Git aliases..."
for alias_pair in "${git_aliases[@]}"; do
    alias_name="${alias_pair%% *}"
    alias_cmd="${alias_pair#* }"

    git config --global alias."$alias_name" "$alias_cmd"
done

