#!/bin/sh

if [ -z "$CLONE_URL" ]; then
  echo "Error: CLONE_URL environment variable is not defined."
  exit 1
fi

SLEEP_TIME=${SLEEP_TIME:-60}
BRANCH_NAME=${BRANCH_NAME:-main}

TARGET_DIR=/home/watcher/repo

# Setup SSH Agent
mkdir -p /home/watcher/.ssh/ /etc/sshpk/
echo -e "Host *\n\tStrictHostKeyChecking no\n" > /home/watcher/.ssh/config
cp /etc/sshpk/* /home/watcher/.ssh/
chmod 600 /home/watcher/.ssh/*
eval $(ssh-agent -s) && echo -e "\n" | cat /home/watcher/.ssh/id_rsa - | ssh-add -

git -C "$TARGET_DIR" pull origin $BRANCH_NAME || git clone "$CLONE_URL" "$TARGET_DIR"

cd $TARGET_DIR

git checkout "$BRANCH_NAME"

while true; do
  if ! diff -qr /mnt/blog /home/watcher/repo/blog; then
    echo "Differences detected, updating the repository..."
    
    cp -R /mnt/blog/* /home/watcher/repo/blog/

    git add .
    git commit -m "Committing at $(date): changes detected."

    if git push origin "$BRANCH_NAME"; then
      echo "Changes pushed to $BRANCH_NAME at $(date)"  
    else
      echo "Error: Failed to push changes to $BRANCH_NAME at $(date)"
    fi
  else
    echo "No changes detected."
  fi
  
  git pull origin "$BRANCH_NAME"

  echo "Next check in $SLEEP_TIME seconds."
  sleep "$SLEEP_TIME"
done