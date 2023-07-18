# Watcher

This project contains a Docker setup to monitor and automatically commit changes to a Git repository.

## Description

This Docker image is based on Alpine Linux and contains the necessary scripts to clone a Git repository, monitor changes and automatically commit and push any changes. This is done via polling every 60 seconds to check for changes.

## Usage 

1. Pull the Docker image.
2. Run the Docker container, mounting the directory you want to watch. Specify the Git repo URL as a CLONE_URL environment variable while running the docker container.

```sh
docker run -d -v /local/dir/to/watch:/home/app -e CLONE_URL='https://github.com/user/repo.git' --name git-auto-commit git-auto-commit
```

In this example, replace `/local/dir/to/watch` with the path to the directory on your host machine that you want to monitor, and replace `'https://github.com/user/repo.git'` with the URL of your Git repository.

## Note

The script uses Git's differential index functionality to check for changes. If there are changes, it stages, commits, and pushes them to the remote repository. 

Ensure you have the necessary permissions (concerning SSH keys or Access Tokens) in place to commit and push to your selected Git repository.

## Building the Image Locally

If you would like to build this image yourself, you can do so with the following commands:

```sh
docker build -t git-auto-commit .
```

This command builds the Docker image and names it "git-auto-commit".
