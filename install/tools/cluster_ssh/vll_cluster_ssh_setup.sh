#!/usr/bin/env bash

read -s -p "Password: " PW
echo
read -p "Cluster username (same on all nodes): " CLUSTER_USER

# 1. Generate the shared keypair (skip if it already exists)
if [ ! -f ~/.ssh/vll_cluster_key ]; then
  ssh-keygen -t ed25519 -f ~/.ssh/vll_cluster_key -N ""
fi

# 2. Build ~/.ssh/config locally, one block per host, matching your pattern
CONFIG_FILE=~/.ssh/config
> "$CONFIG_FILE"   # WARNING: this wipes any existing ~/.ssh/config — back it up first if needed

for h in v{1..25}; do
  ip=$(ssh -G "$h" | awk '/^hostname / {print $2}')
  cat >> "$CONFIG_FILE" <<EOF
Host $h
    HostName $ip
    User $CLUSTER_USER
    IdentityFile ~/.ssh/vll_cluster_key
    StrictHostKeyChecking accept-new
EOF
done
chmod 600 "$CONFIG_FILE"

# 3. Collect every node's host key (by name and by IP)
KNOWN_HOSTS_FILE=~/.ssh/cluster_known_hosts
> "$KNOWN_HOSTS_FILE"
for h in v{1..25}; do
  ip=$(ssh -G "$h" | awk '/^hostname / {print $2}')
  ssh-keyscan -H "$h"  >> "$KNOWN_HOSTS_FILE" 2>/dev/null
  ssh-keyscan -H "$ip" >> "$KNOWN_HOSTS_FILE" 2>/dev/null
done

# 4. Push key, known_hosts, and config to every node
for h in v{1..25}; do
  echo "=== $h ==="
  sshpass -p "$PW" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/vll_cluster_key.pub "$h"

  sshpass -p "$PW" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    ~/.ssh/vll_cluster_key ~/.ssh/vll_cluster_key.pub "$KNOWN_HOSTS_FILE" "$CONFIG_FILE" "$h:~/.ssh/"

  sshpass -p "$PW" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$h" \
    "cat ~/.ssh/cluster_known_hosts >> ~/.ssh/known_hosts && \
     chmod 600 ~/.ssh/known_hosts ~/.ssh/vll_cluster_key ~/.ssh/config && \
     rm -f ~/.ssh/cluster_known_hosts"
done

unset PW
echo "Done. Test with: ssh v5 hostname (from any node)"
