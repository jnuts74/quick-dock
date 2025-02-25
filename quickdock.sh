#!/bin/bash

# Welcome to QuickDock! A Streamlined Docker Deployment For New Linux System Builds!
# This script automates the installation of system updates, Docker, Portainer, and Watchtower on a Linux system.
# It uses sudo privileges initially and ensures that the rest of the script can run without further sudo prompts.
# The script is designed to run on Ubuntu-based systems and is fully automated to answer 'yes' to all prompts.

# Elevate the script to run as root to avoid repeated sudo prompts
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update and upgrade the system
echo "Updating and upgrading the system..."
if ! apt update -y && apt upgrade -y; then
  echo "System update failed. Exiting."
  exit 1
fi

# Install necessary packages for Docker installation
echo "Installing necessary packages..."
if ! apt install -y apt-transport-https curl ca-certificates gnupg lsb-release; then
  echo "Failed to install necessary packages. Exiting."
  exit 1
fi

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.asc; then
  echo "Failed to add Docker's GPG key. Exiting."
  exit 1
fi

# Set up the Docker stable repository
echo "Setting up Docker repository..."
if ! echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; then
  echo "Failed to set up Docker repository. Exiting."
  exit 1
fi

# Update the package index
echo "Updating package index..."
if ! apt update -y; then
  echo "Package index update failed. Exiting."
  exit 1
fi

# Install Docker
echo "Installing Docker..."
if ! apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
  echo "Docker installation failed. Exiting."
  exit 1
fi

# Enable Docker to start on boot and start Docker service
echo "Enabling and starting Docker service..."
if ! systemctl enable docker && systemctl start docker; then
  echo "Failed to enable or start Docker service. Exiting."
  exit 1
fi

# Check if Docker is running
if systemctl is-active --quiet docker; then
  echo "Docker is running."
else
  echo "Docker installation failed."
  exit 1
fi

# Deploy Portainer
echo "Deploying Portainer with latest version..."
docker volume create portainer_data
if ! docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer-ce:latest; then
  echo "Portainer deployment failed. Exiting."
  exit 1
fi

# Deploy Watchtower
echo "Deploying Watchtower..."
if ! docker run --detach --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower; then
  echo "Watchtower deployment failed. Exiting."
  exit 1
fi

# Validate that Portainer and Watchtower are running
echo "Validating Portainer and Watchtower deployment..."
if docker ps --filter "name=portainer" --filter "name=watchtower" | grep -q "portainer" && docker ps --filter "name=watchtower" | grep -q "watchtower"; then
  echo "Deployment completed successfully!"
  echo "You can access your Docker environment:"
  echo "Locally @ https://localhost:9443"
  echo "Remotely @ https://host-ip:9443"
else
  echo "Deployment failed. Please check Docker logs for more details."
  exit 1
fi
