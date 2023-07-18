# Check if CLONE_URL is set
if [ -z "$CLONE_URL" ]; then
  echo "Error: CLONE_URL environment variable is not defined."
  exit 1
fi

# Set sleep time and branch name (defaulted if not supplied)
SLEEP_TIME=${SLEEP_TIME:-60}
BRANCH_NAME=${BRANCH_NAME:-main}

echo "Starting script with CLONE_URL=$CLONE_URL, SLEEP_TIME=$SLEEP_TIME, BRANCH_NAME=$BRANCH_NAME"

# Setting up git configuration
echo "Setting up git configuration..."
git config --global user.email "watcher@noreply.stropus.dev"
git config --global user.name "Watcher"

# Define the target directory
TARGET_DIR=/home/watcher/repo

# Setup SSH Agent
echo "Setting up SSH Agent..."
mkdir -p /home/watcher/.ssh/ /etc/sshpk/
echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/watcher/.ssh/config
cp /etc/sshpk/* /home/watcher/.ssh/
chmod 600 /home/watcher/.ssh/*

# Start the ssh agent
echo "Starting the SSH agent..."
eval $(ssh-agent -s) && echo -e "\n" | cat /home/watcher/.ssh/id_rsa - | ssh-add -

# Pulling or cloning the repository
echo "Pulling or cloning the repository..."
git -C "$TARGET_DIR" pull origin $BRANCH_NAME || git clone "$CLONE_URL" "$TARGET_DIR"

# Change working directory to repo
cd $TARGET_DIR

# Checkout specified branch
echo "Checking out $BRANCH_NAME branch..."
git checkout "$BRANCH_NAME"

# Main loop
while true; do
  echo "Checking for differences between /mnt/blog and /home/watcher/repo/blog..."

  # Check for differences and take action
  if ! diff -qr /mnt/blog /home/watcher/repo/blog > /dev/null; then
    echo "Differences detected, updating the repository..."
    
    # Copy new content from /mnt/blog to /home/watcher/repo/blog
    cp -R /mnt/blog/* /home/watcher/repo/blog/

    # Add, commit and push changes
    git add .
    
    # Get changed files and their count
    CHANGED_FILES=$(git diff --name-only HEAD)
    FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

    # Form the commit message
    COMMIT_MSG="watcher: detected $FILE_COUNT file changes\n\nModified files: $CHANGED_FILES"

    git commit -m "$COMMIT_MSG"

    if git push origin "$BRANCH_NAME"; then
      echo "Changes successfully pushed to $BRANCH_NAME at $(date)"  
    else
      echo "Error: Failed to push changes to $BRANCH_NAME at $(date)"

      echo "Performing hard reset..."
      git fetch origin $BRANCH_NAME && git reset --hard origin/$BRANCH_NAME
    fi
  else
    echo "No changes detected between /mnt/blog and /home/watcher/repo/blog."
  fi
  
  echo "Pulling latest changes from $BRANCH_NAME..."
  git pull origin "$BRANCH_NAME"

  echo "Next check in $SLEEP_TIME seconds at $(date --date='now + '$SLEEP_TIME' seconds')."
  sleep "$SLEEP_TIME"
done