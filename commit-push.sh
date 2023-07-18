#!/bin/sh

if [ -z "$CLONE_URL" ]; then
  echo "Error: CLONE_URL environment variable is not defined."
  exit 1
fi

SLEEP_TIME=${SLEEP_TIME:-60}
BRANCH_NAME=${BRANCH_NAME:-main}


# Setup SSH Agent
mkdir -p /home/watcher/.ssh/ /etc/sshpk/
cp /etc/sshpk/* /home/watcher/.ssh/
chmod 600 /home/watcher/.ssh/*
eval $(ssh-agent -s) && echo -e "\n" | cat /home/watcher/.ssh/id_rsa - | ssh-add -

git clone "$CLONE_URL" /home/watcher/repo

cd /home/watcher/repo

git checkout "$BRANCH_NAME"

while true; do
  FILES=$(git diff --name-only)
  NUMBER=$(git diff --name-only | wc -l)

  if [ "$NUMBER" -ne "0" ]; then
    git add .
    git commit -m "Automated commit: Updated $NUMBER file(s)" -m "$FILES"
    git push origin "$BRANCH_NAME"
  fi

  sleep "$SLEEP_TIME"
done