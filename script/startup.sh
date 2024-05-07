#!/bin/bash

# Step 1: Update the package
sudo apt-get update -y
sudo apt-get upgrade -y

# Step 2: Install Docker and Docker Compose if not installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get install -y docker.io
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose not found. Installing Docker Compose..."
    sudo apt-get install -y docker-compose
fi

# Step 3: Change directory to indra_mahaarta22 directory
sudo useradd -m -s /bin/bash indra_mahaarta22
USER_HOME="/home/indra_mahaarta22"
if [ "$(pwd)" != "$USER_HOME" ]; then
    echo "Changing directory to $USER_HOME"
    cd "$USER_HOME" || { echo "Failed to change directory"; exit 1; }
fi

# Step 4: Clone repository if it does not exist
if [ ! -d "deployment-master" ]; then
    echo "Repository not found. Cloning..."
    git clone https://github.com/online-tryout/deployment-master.git
fi

# Step 5: Add user to docker group & add another permission
sudo usermod -aG docker indra_mahaarta22
sudo chown -R indra_mahaarta22:indra_mahaarta22 /home/indra_mahaarta22/deployment-master
sudo chmod -R 755 /home/indra_mahaarta22/deployment-master

# Step 6: Run script inside the project
cd deployment-master || { echo "Failed to change directory to deployment-master"; exit 1; }
./script/setup.sh || { echo "Failed to run setup script"; exit 1; }
