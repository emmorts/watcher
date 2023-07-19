# Watcher

This script pulls a configured Git repository and monitors a set of directories, compare them with directories inside the repository. If changes are detected, it commits and pushes the changes. This can be useful for keeping files in sync on multiple instances, or for automatically tracking and versioning changes.

## Requirements

- Docker

## Setup

1. Ensure your Docker environment is up and running.

2. Clone this repository and navigate to it:

   ```
   git clone https://git.stropus.dev/tomas/watcher.git
   cd watcher
   ```

3. Build the Docker image:

   ```
   docker build -t watcher .
   ```

## Usage

The directories to be watched are provided via environment variables. Make sure you set correctly the environment variables before running the script:

- **CLONE_URL**: This is the URL of the Git repository to clone and sync with the local directories.
- **SOURCE_PATHS**: Comma-separated list of absolute paths to source directories. For example: `/mnt/blog,/mnt/docs`.
- **TARGET_PATHS**: Comma-separated list of relative paths to target directories. For example: `blog,docs`.
- **SLEEP_TIME**: Time in seconds between successive checks for changes. Default is 60 seconds.
- **BRANCH_NAME**: The branch to which changes should be pushed. Default is `main`.
- **SSH_KEY_NAME**: (Optional) The name of your private SSH key to be used. The default is `id_rsa`. 

If you are using SSH for Git, it is assumed that a directory named `/etc/sshpk` is mounted from the host into the Docker container, containing a private key named according to the `SSH_KEY_NAME` environment variable.

If you are not providing an SSH Key, the script will try to pull the Git repository using HTTP(S). Please ensure to include your username and password or personal access token in the `CLONE_URL` in the format: 
```
https://username:password@github.com/username/repository.git
```
Please be aware that including credentials in plaintext can have security implications. 

To start the directory watcher, run:

```
docker run -d \
  -e CLONE_URL=<clone-url> \
  -e SOURCE_PATHS=<source-paths> \
  -e TARGET_PATHS=<target-paths> \
  -e BRANCH_NAME=<branch-name> \
  -e SLEEP_TIME=<sleep-time> \
  -e SSH_KEY_NAME=<ssh-key-name> \
  -v ./my_dir/one:/mnt/one \
  -v ./my_dir/two:/mnt/two \
  -v ./my_dir/three:/mnt/three \
  -v /etc/sshpk:/etc/sshpk \
  watcher
```

Replace values within the angle brackets with your values. The `-v /mnt:/mnt` argument should be adjusted according to where you have the directories you want to watch on your host machine. The left hand side is the host directory and the right hand side is the corresponding directory in the docker container.

## Contributing

Contributions to improve this script are welcome. Please feel free to open a PR or issue in the repository.

## License

This project is released under the MIT License. See the file LICENSE for more details.