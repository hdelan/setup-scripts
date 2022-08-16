if [ "$EUID" -ne 0 ]
  then echo "This setup script must be run as root."
  exit
fi

set -e
set -v

cd
HOME=$(pwd)

apt update && apt upgrade -y
apt install git zsh build-essential nodejs curl wget neovim cmake ninja-build -y

git config --global user.email "hugh.delaney@codeplay.com"
git config --global user.name "Hugh Delaney"

sudo snap install node --classic

# Neovim stuff
python3 -m pip install pynvim

# Vim-plug for Neovim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
cd .config && git clone https://github.com/hdelan/nvim.git

# CUDA toolkit 
wget https://developer.download.nvidia.com/compute/cuda/11.7.1/local_installers/cuda_11.7.1_515.65.01_linux.run
sh cuda_11.7.1_515.65.01_linux.run

# Ohmyzsh
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/hdelan/llvm.git
