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
- **BRANCH_NAME**: The branch to which changes should be pushed. Default is 'main'.

To start the directory watcher, run:

```
docker run -d \
  -e CLONE_URL=<clone-url> \
  -e SOURCE_PATHS=<source-paths> \
  -e TARGET_PATHS=<target-paths> \
  -e BRANCH_NAME=<branch-name> \
  -e SLEEP_TIME=<sleep-time> \
  -v /mnt:/mnt \
  watcher
```

Replace `<clone-url>`, `<source-paths>`, `<target-paths>`, `<branch-name>`, `<sleep-time>` with your values. The `-v /mnt:/mnt` argument should be adjusted according to where you have the directories you want to watch on your host machine. The left hand side is the host directory and the right hand side is the corresponding directory in the docker container.

## Contributing

Contributions to improve this script are welcome. Please feel free to open a PR or issue in the repository.

## License

This project is released under the MIT License. See the file LICENSE for more details.