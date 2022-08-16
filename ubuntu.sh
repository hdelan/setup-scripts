#!/bin/bash

if [ "$EUID" -ne 0 ]
then echo "This setup script must be run as root."
  exit
fi

set -e
set -v

HOME=/home/hugh
cd $HOME

apt update && apt upgrade -y
apt install git \
  zsh \
  build-essential \
  openssh-server \
  ccache \
  curl \
  wget \
  neovim \
  cmake \
  ninja-build \
  python3-distutils \
  htop -y

git config --global user.email "hugh.delaney@codeplay.com"
git config --global user.name "Hugh Delaney"

NODE=node-v16.17.0-linux-x64
if [[ $(command -v node | wc -l) -eq 0 ]]
then
  wget https://nodejs.org/dist/v16.17.0/$NODE.tar.xz
  tar -xf $NODE.tar.xz
  mv $NODE .config
fi

snap install code --classic

# Python-pip
if [[ $(command -v pip | wc -l) -eq 0 ]]
then
  wget https://bootstrap.pypa.io/get-pip.py
  python3 get-pip.py
  rm get-pip.py
fi

sudo -u hugh python3 -m pip install --upgrade pip

# Neovim stuff
sudo -u hugh python3 -m pip install pynvim pss

# Vim-plug for Neovim
if [[ ! -e $HOME/.config/nvim ]]
then
  sudo -u hugh sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      cd .config && git clone https://github.com/hdelan/nvim.git
fi

# CUDA toolkit 
if [[ ! -e /usr/local/cuda-11.7 ]]
then
  sudo -u hugh wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
  dpkg -i cuda-keyring_1.0-1_all.deb
  apt-get update
  apt-get -y install cuda
fi

# Ohmyzsh
if [[ ! -e $HOME/.oh-my-zsh ]]
then
  sudo -u hugh sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -e $HOME/llvm ]]
then
  sudo -u hugh git clone https://github.com/hdelan/llvm.git
fi

if [[ ! $(tail $HOME/.zshrc | grep "llvm/build/bin" | wc -l) -eq 0 ]]
then
  sudo -u hugh echo "export PATH=$HOME/llvm/build/bin:$HOME/.local/bin:$HOME/.config/$NODE/bin:/usr/local/cuda-11.7/bin:$PATH" >> $HOME/.zshrc
  sudo -u hugh echo "export LD_LIBRARY_PATH=$HOME/llvm/build/lib:/usr/local/cuda-11.7/lib64:$LD_LIBRARY_PATH" >> $HOME/.zshrc
fi
