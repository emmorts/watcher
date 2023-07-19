# Check environment variable
checkEnvironmentVariable() {
  if [ -z "$1" ]; then
    echo "Error: $2 environment variable is not defined."
    exit 1
  fi
}

# Check environment variables
checkEnvironmentVariable "$CLONE_URL" "CLONE_URL"
checkEnvironmentVariable "$SOURCE_PATHS" "SOURCE_PATHS"
checkEnvironmentVariable "$TARGET_PATHS" "TARGET_PATHS"

# Convert the comma-separated strings into arrays
IFS=',' read -r -a source_paths <<< "$SOURCE_PATHS"
IFS=',' read -r -a target_paths <<< "$TARGET_PATHS"

# Check both arrays have the same number of elements
if [ "${#source_paths[@]}" -ne "${#target_paths[@]}" ]; then
  echo "Error: SOURCE_PATHS and TARGET_PATHS should have the same number of elements."
  exit 1
fi

# Set variables
SLEEP_TIME=${SLEEP_TIME:-60}
BRANCH_NAME=${BRANCH_NAME:-main}
GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-watcher@noreply.localhost}
GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-Watcher}
TARGET_DIR=/home/watcher/repo

echo "Starting script..."

# Initialize
setupGitConfigs
setupSshAgent
cloneOrPullRepository
checkoutBranch

# Start monitoring
monitorDirectories

# Wrapper functions
setupGitConfigs() {
  echo "Setting up git configuration..."
  git config --global user.email "$GIT_AUTHOR_EMAIL"
  git config --global user.name "$GIT_AUTHOR_NAME"
}

setupSshAgent() {
  echo "Setting up SSH Agent..."
  
  mkdir -p /home/watcher/.ssh/ /etc/sshpk/
  echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/watcher/.ssh/config
  cp /etc/sshpk/* /home/watcher/.ssh/
  chmod 600 /home/watcher/.ssh/*

  echo "Starting the SSH agent..."
  eval $(ssh-agent -s) && echo -e "\n" | cat /home/watcher/.ssh/id_rsa - | ssh-add -
}

cloneOrPullRepository() {
  echo "Pulling or cloning the repository..."
  git -C "$TARGET_DIR" pull origin $BRANCH_NAME || git clone "$CLONE_URL" "$TARGET_DIR"
}

checkoutBranch() {
  cd $TARGET_DIR
  echo "Checking out $BRANCH_NAME branch..."
  git checkout "$BRANCH_NAME"
}

monitorDirectories() {
  while true; do
    syncDirectories
    pullLatestChanges
    sleepUntilNextCheck
  done
}

syncDirectories() {
  for index in "${!source_paths[@]}";
  do
    local source_path="${source_paths[index]}"
    local target_path="$TARGET_DIR/${target_paths[index]}"
  
    echo "Checking for differences between $source_path and $target_path..."
    
    if ! diff -qr "$source_path" "$target_path" > /dev/null;
    then
      syncDirectoryChanges "$source_path" "$target_path"
    else
      echo "No changes detected."
    fi
  done
}

syncDirectoryChanges() {
  local source_path="$1"
  local target_path="$2"

  # Copy new content
  cp -R "$source_path/"* "$target_path"

  # Add, commit and push changes
  git add .
  local changed_files=$(git diff --name-only HEAD)
  local file_count=$(echo "$changed_files" | wc -l)

  # Commit
  git commit -m "watcher: detected $file_count file changes" -m "Modified files: $changed_files"

  # Push changes
  if git push origin "$BRANCH_NAME"; then
    echo "Changes successfully pushed to $BRANCH_NAME at $(date)"
  else
    handlePushError
  fi
}

handlePushError() {
  echo "Error: Failed to push changes to $BRANCH_NAME at $(date)"
  echo "Performing hard reset..."
  git fetch origin $BRANCH_NAME
  git reset --hard origin/$BRANCH_NAME
}

pullLatestChanges() {
  echo "Pulling latest changes from $BRANCH_NAME..."
  git pull -q origin "$BRANCH_NAME"
}

sleepUntilNextCheck() {
  echo "Next check in $SLEEP_TIME seconds at $(date --date='now + '$SLEEP_TIME' seconds')."
  sleep "$SLEEP_TIME"
}