read -r NODE_KEY
echo "NODE KEY: $NODE_KEY"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if command_exists docker; then
  echo "Docker already installed"
else
  echo "Install Docker..."
  bash -c "$(curl -fsSL https://get.docker.com)"
fi

if command_exists nvidia-ctk; then
  echo "NVIDIA Container Toolkit installed"
else
  echo "Install NVIDIA Container Toolkit..."
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

  sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt-get update
  sudo apt-get install -y nvidia-container-toolkit

  echo "Configure Docker..."
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
fi

echo "Run application..."
echo "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" | docker login ghcr.io -u kolia90 --password-stdin
docker run --restart=always --runtime=nvidia --gpus all --net=host --env NODE_KEY="$NODE_KEY" --env PATH="${PATH}:/var/lib/snapd/hostfs/usr/bin" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/taolie-ai/marketplace-app:latest
