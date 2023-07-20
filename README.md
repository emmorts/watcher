# Watcher

This repository contains a Dockerized script to monitor changes in specified directories and automatically commit and push those changes to a git repository.

The script pulls down a repository specified by `CLONE_URL` and watches the directories listed in `SOURCE_PATHS`. It periodically checks if those directories differ from the corresponding ones in `TARGET_PATHS` inside the cloned repo. Any differences found are committed and pushed to the repo.

This allows keeping the repository repository in sync with changes to files/directories on the host machine or on remote instances. It can be useful for centralized logging, version control and backup of important data.

The script is packaged into a Docker image for portability. It can be configured via environment variables passed into docker run. SSH keys can be mounted into the container to enable pushing over SSH.

## Table of Contents
- [Usage](#usage)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Running directly](#running-directly)
  - [Running with Docker Compose](#running-with-docker-compose)
  - [Running with Docker](#running-with-docker)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)

## Configuration

Configuration of the `watcher` is done through environment variables. Here are the variables you can set:

| Variable       | Description                                                                                                                               | Default Value       | Required          |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | ----------------- |
| `CLONE_URL`    | The URL of the Git repository you want to sync changes to.                                                                                | N/A                 | Yes               |
| `SOURCE_PATHS` | A comma-separated list of absolute paths to the source directories on the host machine or remote instance.                                | N/A                 | Yes               |
| `TARGET_PATHS` | A comma-separated list of paths to the target directories in the `CLONE_URL` repository. These paths are relative to the repository root. | N/A                 | Yes               |
| `BRANCH_NAME`  | The name of the branch in the `CLONE_URL` repository that the changes will be pushed to.                                                  | `main`              | No                |
| `SLEEP_TIME`   | The time (in seconds) before each check for changes.                                                                                      | `60`                | No                |
| `SSH_KEY_PATH` | If using SSH for Git operations, specify the path to the SSH private key file.                                                            | `/etc/sshpk/id_rsa` | Only if using SSH |


Example of configuration variables setup: 

```env
  CLONE_URL=https://github.com/my_repository.git \
  SOURCE_PATHS=/home/myapp/logs,/var/logs/nginx \
  TARGET_PATHS=logs,nginx_logs \
  BRANCH_NAME=main \
  SLEEP_TIME=300 \
  SSH_KEY_PATH=/home/foo/.ssh/id_rsa \
```
Remember to replace these values with your specific setup. Ensure your `SOURCE_PATHS` and `TARGET_PATHS` align vertically i.e., each source path is synced to the corresponding target path based on their order in the comma-separated list. For example, in the above case, `/home/myapp/logs` is synced with `logs` in the repository root, and `/var/logs/nginx` is synced with `nginx_logs` in the repository root.

## Usage

It is recommended to run the script in a Docker container, as it is much easier to manage its' configuration.

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
      - CLONE_URL=<clone url>
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

Consider a repository stored at `https://github.com/example/important-repo.git` on the `main` branch. This repository contains the directories `blog`, `docs`, and `.config`.

### Local Directories

Your source directories on your local machine are `/home/example/blog`, `/home/example/data/docs`, `/home/example/.config` respectively. These directories contain files that frequently change and you want to automatically back up changes to your GitHub repository.

### Running the Project

To enable synchronization of these directories, update the environment variables in either in your system, Docker Compose or Docker command as follows:

```sh
  CLONE_URL=git@github.com:example/important-repo.git # Using SSH
  SOURCE_PATHS=/home/example/blog,/home/example/data/docs,/home/example/.config
  TARGET_PATHS=blog,docs,.config
  BRANCH_NAME=main
  SLEEP_TIME=60
  SSH_KEY_PATH=/home/example/.ssh/id_rsa
```

You can choose to use Docker Compose or Docker command-line interface to run the project. Refer to the [Usage](#usage) section for instructions on how to run the script.

## Contributing

Contributions are welcome! Please feel free to submit a pull request with any improvements or additional features.

## License

This project is licensed under the [MIT License](LICENSE).