#!/bin/bash

echo "Start to execute script"
echo "============================================================"

echo "Downloading $ENV_FILE from URL..."
ENV_FILE=".env"
curl -o "$ENV_FILE" https://storage.googleapis.com/online-tryout/.env
echo "$ENV_FILE downloaded"

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
            rm -rf "$dir"
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
    "parsing-sheets-api|https://github.com/online-tryout/parsing-sheets-api.git|app.env"
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

docker-compose up -d --build
docker image prune -f
