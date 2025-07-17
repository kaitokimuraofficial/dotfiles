#!/bin/bash -eu

#######################################
# If running in zsh, re-execute the script with bash.
#######################################
if [ -n "$ZSH_VERSION" ]; then
    echo "Detected zsh. Re-executing with bash..."
    exec bash "$0" "$@"
    return $?
fi


#######################################
# Detecting OS.
# Only Amazon Linux 2023 and macOS are supported.
#######################################
function detect_os() {
  [[ "$(uname)" == "Darwin" ]] && { echo macos; return; }

  if [[ -f /etc/os-release ]]; then
      . /etc/os-release
      [[ "$ID" == "amzn" && "$VERSION_ID" == "2023" ]] && { echo al2023; return; }
  fi

  echo unknown
  return 1
}

OS_TYPE=$(detect_os)

if [[ "$OS_TYPE" == "unknown" ]]; then
  echo "Unsupported OS. Exiting."
  exit 1
fi


#######################################
# Get the absolute path of the parent directory of
# this script's parent directory.
#######################################
function get_dotfiles_dir() {
    local script_path

    case "$OS_TYPE" in
        al2023)
            script_path="$(readlink -f "$0")"
            ;;
        macos)
            script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
            ;;
        *)
            echo "Unsupported OS: $OS_TYPE" >&2
            return 1
            ;;
    esac

    dirname "$(dirname "$script_path")"
}

DOTFILES_DIR=$(get_dotfiles_dir)

source "${DOTFILES_DIR}"/setups/utils.sh


#######################################
# FUNCTIONS FOR SETUP
#######################################
function create_symlinks() {
  local pairs=("$@")

  echo "Set up config files..."

  for pair in "${pairs[@]}"; do

      local src="${pair%%:::*}"
      local dest="${pair##*:::}"
      local src_dir
      src_dir="$(dirname "$src")"

      if [[ ! -d "$src_dir" ]]; then
          echo "Creating parent directory: $src_dir"
          mkdir -p "$src_dir"
      fi

      if [[ -L "$src" ]]; then
          local current_target
          current_target="$(readlink "$src")"

          if [[ "$current_target" == "$dest" ]]; then
              echo "Skipping: already linked correctly: $src -> $dest"
              continue
          else
              echo "Existing symlink points to $current_target, will update."
          fi
      elif [[ -e "$src" ]]; then
          echo "WARNING: $src exists but is not a symlink. It will be replaced."
      fi

      echo "Creating symlink: $src -> $dest"
      ln -sf "$dest" "$src"
  done
}


function is_brew_installed() {
    command -v brew >/dev/null 2>&1 && brew --version >/dev/null 2>&1
}


function install_homebrew_and_packages() {
    if is_brew_installed; then
        echo "Skipping: Homebrew is already installed."
    else
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        local brew_path
        case "$OS_TYPE" in
            macos)
                brew_path="/opt/homebrew/bin/brew"
                ;;
            al2023|linux)
                brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
                ;;
            *)
                echo "Unsupported OS for Homebrew setup: $OS_TYPE" >&2
                return 1
                ;;
        esac

        echo "eval \"\$($brew_path shellenv)\"" >> "$HOME/.zshrc"
        eval "$($brew_path shellenv)"
    fi

    echo "Install libraries through Homebrew..."
    brew bundle --file="${DOTFILES_DIR}/Brewfile"
}


function check_git_user_name() {
    if ! git config --global user.name >/dev/null 2>&1; then
        echo "============= DO IT =============="
        echo "Your name is not set in git config"
        echo ""
        echo "> git config --global user.name \"USERNAME\""
        echo "=================================="
    fi
}


function check_git_user_email() {
    if ! git config --global user.email >/dev/null 2>&1; then
        echo "============= DO IT =============="
        echo "Your email is not set in git config"
        echo ""
        echo "> git config --global user.email \"EMAIL\""
        echo "=================================="
    fi
}


function check_github_ssh_access() {
    ssh -T git@github.com >/dev/null 2>&1
    local ret=$?
    if [[ $ret -ne 1 ]]; then
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
}


function setup_git_aliases() {
    if command -v git >/dev/null 2>&1; then
        echo "Setting up Git aliases..."
        git config --global alias.c "commit"
        git config --global alias.cm "commit -m"
        git config --global alias.can "commit --amend --no-edit"
        git config --global alias.p "push"
        git config --global alias.push-f "push --force-with-lease"
        git config --global alias.ds "diff --staged"
        git config --global alias.st "status"
    fi
}


function setup_git() {
    check_git_user_name
    check_git_user_email
    check_github_ssh_access
    setup_git_aliases
}



#######################################
# SETUP PROCEDURE
#######################################
symlinks=(
  "$HOME/.config/nvim/coc-settings.json:::$DOTFILES_DIR/nvim/coc-settings.json"
  "$HOME/.config/nvim/init.lua:::$DOTFILES_DIR/nvim/init.lua"
  "$HOME/.config/nvim/lua/config/lazy.lua:::$DOTFILES_DIR/nvim/lazy.lua"
  "$HOME/.tmux.conf:::$DOTFILES_DIR/tmux/tmux.conf"
  "$HOME/.vimrc:::$DOTFILES_DIR/vim/vimrc"
  "$HOME/.vim/coc-settings.json:::$DOTFILES_DIR/vim/coc-settings.json"
  "$HOME/.zshenv:::$DOTFILES_DIR/zsh/zshenv"
  "$HOME/.zshrc:::$DOTFILES_DIR/zsh/zshrc"
  "$HOME/.zprofile:::$DOTFILES_DIR/zsh/zprofile"
)

create_symlinks "${symlinks[@]}"

install_homebrew_and_packages

setup_git
