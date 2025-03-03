#!/bin/zsh -eu

# Install Homebrew and add it to the system PATH
if ! type brew >/dev/null 2>&1; then
  echo "----------------------------------------------------------------------------"
  echo "installing brew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/ka.kimura/.zprofile
  eval $(/opt/homebrew/bin/brew shellenv)
fi

echo "Install tools through brew......"
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Install..."
    brew install node
    echo "Node.js installed successfully!"
fi
node -v
npm -v

PLUG_VIM_PATH="$HOME/.vim/autoload/plug.vim"

# Install plug_vim unless it is not locally found
if [ ! -f "$PLUG_VIM_PATH" ]; then
    echo "----------------------------------------------------------------------------"
    echo "vim-plug not found. Installing..."
    curl -fLo "$PLUG_VIM_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "vim-plug installed successfully."
else
    echo "vim-plug is already installed."
fi


echo "----------------------------------------------------------------------------"
echo "Setting up config files..."
ln -sf ~/dotfiles/zsh/zshenv ~/.zshenv
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/zprofile ~/.zprofile

ln -sf ~/dotfiles/vim/vimrc ~/.vimrc
ln -sf ~/dotfiles/vim/coc-settings.json ~/.config/vim/coc-settings.json

echo "----------------------------------------------------------------------------"
echo "please set up iTerm2"

echo "----------------------------------------------------------------------------"
echo "PLEASE SET UP FOR GIT ( ssh-key, name, email )"

if ! type git >/dev/null 2>&1; then
  echo "----------------------------------------------------------------------------"
  echo "installing git..."
  brew install git
fi

echo "> git config --global user.name \"USERNAME\""
echo "> git config --global user.email \"EMAIL\""
echo ""
echo "ssh-keygen"
echo "Enter file in which to save the key (/Users/USERNAME/.ssh/id_rsa):"
echo "Enter passphrase (empty for no passphrase): "
echo "pbcopy < ~/.ssh/HOGE.pub"
echo "Add the SSH public key to GitHub"
echo "ssh -T git@github.com"
echo "If the connection is successful, you should see the following message:"
echo "> Hi username! You've successfully authenticated, but GitHub does not provide shell access."
echo ""
echo "When trying to connect via HTTPS from the terminal, you will be prompted for your GitHub username and password."
echo "Username for 'https://github.com': USERNAME"
echo "Password for 'https://username@github.com': PAT"


echo "----------------------------------------------------------------------------"
echo "Success!"

