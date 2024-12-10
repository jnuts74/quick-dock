# dock-magic

# DockMagic: A Streamlined Docker Deployment

Simplify your Docker deployment workflow with DockMagic. 
Manage your Docker instances effortlessly with Portainer and stay ahead with automated updates using Watchtower.

DockMagic is a shell script created to facilitate the quick deployment of Docker on new Linux systems. It automates the installation of Linux system updates and installs Docker with Portainer for managing Docker instances and applications, and Watchtower for automating container image updates and security patches.

## Key Features

- **Rapid Docker Deployment**: Simplify and expedite Docker setup on fresh Linux systems.
- **Portainer Integration**: Easily manage Docker containers using Portainer.
- **Watchtower Automation**: Streamline container updates and security patch management.

## Installation Instructions

**Clone the Repository to your home directory:**

git clone https://github.com/jnuts74/dock-magic.git

**Set shell script permissions to execute:**

sudo chmod +x dockmagic.sh

**Execute the script to start the automated Docker setup process:**

./dockmagic.sh

## Usage

- The script requires sudo privileges to initiate the setup process.
- It automatically updates the system and installs essential packages for Docker setup.
- Docker, Portainer, and Watchtower are deployed and configured for immediate use.

Access your Docker environment locally at [https://localhost:9443](https://localhost:9443) or remotely at [https://host-ip:9443](https://host-ip:9443).
