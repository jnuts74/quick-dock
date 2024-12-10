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
apt update -y && apt upgrade -y

# Install necessary packages for Docker installation
echo "Installing necessary packages..."
apt install -y apt-transport-https curl ca-certificates gnupg lsb-release

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker stable repository
echo "Setting up Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index
echo "Updating package index..."
apt update -y

# Install Docker
echo "Installing Docker..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker to start on boot and start Docker service
echo "Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

# Check if Docker is running
if systemctl is-active --quiet docker; then
  echo "Docker is running."
else
  echo "Docker installation failed."
  exit 1
fi

# Deploy Portainer
echo "Deploying Portainer..."
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.4

# Deploy Watchtower
echo "Deploying Watchtower..."
docker run --detach --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower

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