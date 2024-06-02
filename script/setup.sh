#!/bin/bash

echo "Start to execute script"
echo "============================================================"

docker-compose down

clone_or_pull_repo() {
    local dir=$1
    local repo_url=$2
    local env_file_name=${3:-".env"}

    if [ -d "$dir" ]; then
        echo "Directory '$dir' exists. Checking if it's a Git repository..."
        cd "$dir"
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "'$dir' is a Git repository. Pulling updates..."
            git pull origin main
            cd ..
        else
            echo "'$dir' is not a Git repository."
            cd ..
            sudo rm -rf "$dir"
            git clone "$repo_url" "$dir"
        fi
    else
        echo "Directory '$dir' does not exist. Cloning repository..."
        git clone "$repo_url" "$dir"
    fi

    cp .env "./$dir/$env_file_name"
    echo "Environment file copied to $dir/$env_file_name"
    echo "'$dir': Done"
    echo "============================================================"
}

declare -a repos=( 
    "online-tryout|https://github.com/online-tryout/online-tryout|.env"
    "admin-app|https://github.com/online-tryout/admin-app.git|.env"
    "parsing-sheets-api|https://github.com/online-tryout/parsing-sheets-api.git|app.env"
    "auth-api|https://github.com/online-tryout/online-tryout-auth|app.env"
    "db-api|https://github.com/online-tryout/online-tryout-db-service.git|.env"
    "tryout-api|https://github.com/online-tryout/online-tryout-backend-api.git|.env"
    "payment-api|https://github.com/online-tryout/payment-api.git|.env"
)

for repo in "${repos[@]}"; do
    IFS='|' read -r dir repo_url env_file_name <<< "$repo"
    clone_or_pull_repo "$dir" "$repo_url" "$env_file_name"
done

if command -v docker >/dev/null 2>&1; then
    echo "Docker is installed."
else
    echo "Docker is not installed. Please install :)"
    exit 1
fi

if command -v docker-compose >/dev/null 2>&1; then
    echo "Docker Compose is installed."
else
    echo "Docker Compose is not installed. Please install; :)"
    exit 1
fi

sudo docker-compose up -d --build
sudo docker image prune -f
