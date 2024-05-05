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

# Step 5: Download .env file from bucket if it does not exist
cd deployment-master
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Downloading $ENV_FILE from URL..."

    # Download .env file from bucket using curl
    curl -o "$ENV_FILE" https://storage.googleapis.com/online-tryout/.env

    echo "$ENV_FILE downloaded"
else
    echo "$ENV_FILE already exists"
fi

# Step 6: Add user to docker group
sudo usermod -aG docker indra_mahaarta22

# Step 7: Run script inside the project
./script/setup.sh
