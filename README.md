# Watcher

This project sets up a Docker container that automatically monitors changes in a directory, and commits and pushes them to a specified Git repository.

## Prerequisites

- Docker installed on your system.
- SSH key pair for accessing your private Git repository.

## Description

The Docker image is based on Alpine Linux and contains a shell script that clones the specified Git repository, and periodically (every `SLEEP_TIME` seconds) checks for any changes in the mounted directory. If there are any changes, it stages these changes, commits them with the filenames of the changed files included in the commit message, and pushes them to the specified Git branch (`BRANCH_NAME`).

The default `SLEEP_TIME` is 60 seconds and can be overridden by setting the `SLEEP_TIME` environment variable at runtime. The default `BRANCH_NAME` is `main` and can also be overridden by setting the `BRANCH_NAME` environment variable at runtime.

## Usage

Build the Docker image:
```sh
docker build -t git-auto-commit .
```

Run the Docker container:
```sh
docker run -d -v /local/directory:/home/app -v /path/to/ssh/key:/etc/sshpk -e CLONE_URL='https://github.com/user/repo.git' -e SLEEP_TIME=120 -e BRANCH_NAME=dev --name git-auto-commit git-auto-commit
```
- Replace `/local/directory` with the local directory you wish to watch and commit to your Git repository.
- Replace `/path/to/ssh/key` with the path to your private SSH key.
- Replace `https://github.com/user/repo.git` with the URL of your Git repository.
- Adjust `SLEEP_TIME` and `BRANCH_NAME` as needed.

## Notes

The SSH key is used for authentication with private Git repositories. The key is copied from `/etc/sshpk` (on the Docker container) to the appropriate location and added to the SSH agent.

This solution is secure as long as the private SSH key remains secure.