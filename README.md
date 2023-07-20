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
- **SSH_KEY_PATH**: (Optional) Absolute path to your private SSH key to be used. The default is `/etc/sshpk/id_rsa`. 

If you are using SSH for Git, the private SSH key must exist in the path provided in `SSH_KEY_PATH`.

If you are not providing an SSH Key, the script will try to pull the Git repository using HTTP(S). Please ensure to include your username and password or personal access token in the `CLONE_URL` in the format: 
```
https://username:password@github.com/username/repository.git
```
Please be aware that including credentials in plaintext can have security implications. 

### Running directly

The `watcher.sh` script can be executed directly from the shell without using Docker. Here's how to use it:

1. Make sure you have all the required dependencies installed: Git, Bash, and SSH (if applicable).

2. Set the necessary environment variables before running the script.

3. Run the script using bash:

   ```bash
   bash watcher.sh
   ```

The script will continue running in the background, periodically checking for changes according to the specified sleep time. You can stop the script by pressing Ctrl + C.

Note: If you are using SSH for Git, make sure your SSH key is correctly configured and accessible to the script.

### Running with Docker Compose

In case you prefer using Docker Compose, here is a sample docker-compose.yml configuration:

```yaml
version: '3'
services:
  watcher:
    image: ghcr.io/emmorts/watcher:main
    volumes:
      - ./my_dir/one:/mnt/one
      - ./my_dir/two:/mnt/two
      - ./my_dir/three:/mnt/three
      - ~/.ssh/id_rsa:/etc/sshpk/id_rsa:ro
    environment:
      - CLONE_URL=<clone-url>
      - SOURCE_PATHS=<source-paths>
      - TARGET_PATHS=<target-paths>
      - BRANCH_NAME=<branch-name>
      - SLEEP_TIME=<sleep-time>
      - SSH_KEY_PATH=<ssh-key-path>
```

Be aware that the value on the left of each volume entry corresponds to the host directory, and the value on the right corresponds to the respective directory in the Docker container.

To start the services, run:

```
docker-compose up -d
```

### Running with Docker

To start the directory watcher using Docker command-line interface, run:

```sh
docker run -d \
  -e CLONE_URL=<clone-url> \
  -e SOURCE_PATHS=<source-paths> \
  -e TARGET_PATHS=<target-paths> \
  -e BRANCH_NAME=<branch-name> \
  -e SLEEP_TIME=<sleep-time> \
  -e SSH_KEY_PATH=<ssh-key-path> \
  -v ./my_dir/one:/mnt/one \
  -v ./my_dir/two:/mnt/two \
  -v ./my_dir/three:/mnt/three \
  -v ~/.ssh/id_rsa:/etc/sshpk/id_rsa \
  ghcr.io/emmorts/watcher:main
```

## Example

Let's take the example of a repository hosted on GitHub which you want to keep in sync with three local directories.

### Sample Repository

Consider a repository stored at `https://github.com/gatsby/my_repository.git` on the `main` branch. This repository contains the directories `dir1`, `dir2`, and `dir3`.

### Local Directories

Your source directories on your local machine are `/home/gatsby/dir1`, `/home/gatsby/dir2`, `/home/gatsby/dir3` respectively. These directories contain files that frequently change and you want to automatically back up changes to your GitHub repository.

### Running the Project

To enable synchronization of these directories, update the environment variables in the Docker Compose or Docker command as follows:

```
  CLONE_URL: https://github.com/gatsby/my_repository.git
  SOURCE_PATHS: /home/gatsby/dir1,/home/gatsby/dir2,/home/gatsby/dir3
  TARGET_PATHS: dir1,dir2,dir3
  BRANCH_NAME: main
  SLEEP_TIME: 60
  SSH_KEY_PATH: [If Applicable]
```

You can choose to use Docker Compose or Docker commands to run the project.

After successfully running the Docker container, the `watcher` script will start monitoring the local directories for any changes. If a change is detected, it will commit and push the changes back to the defined target paths in the repository.

This will keep your local directories and GitHub repository in sync, ensuring regular and efficient backup of your crucial data.

## Contributing

Contributions to improve this script are welcome. Please feel free to open a PR or issue in the repository.

## License

This project is released under the MIT License. See the file LICENSE for more details.