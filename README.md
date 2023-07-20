# Watcher

This repository contains a Dockerized script to monitor changes in specified directories and automatically commit and push those changes to a git repository.

The script pulls down a repository specified by `CLONE_URL` and watches the directories listed in `SOURCE_PATHS`. It periodically checks if those directories differ from the corresponding ones in `TARGET_PATHS` inside the cloned repo. Any differences found are committed and pushed to the repo.

This allows keeping the repository repository in sync with changes to files/directories on the host machine or on remote instances. It can be useful for centralized logging, version control and backup of important data.

The script is packaged into a Docker image for portability. It can be configured via environment variables passed into docker run. SSH keys can be mounted into the container to enable pushing over SSH.

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