#!/bin/bash

cd /home/container || exit
sleep 1

# Update Don't Starve Together Server
./steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/container +app_update 343050 +quit

# Backup the Logs
SERVER_LOG_DIR=$(find . -name 'server_log.txt' -printf '%h\n' | sort -u)
if [[ $SERVER_LOG_DIR ]]; then
  cd "$SERVER_LOG_DIR" || exit
  
  mkdir -p backup
  mkdir -p backup/server_log
  mkdir -p backup/server_chat_log
  
  # Delete Log Backups Which Are Older Than 3 Months
  find backup -type f -mtime +90 -delete
  
  CURRENT_DATETIME=$(date +%Y-%m-%d_%H-%M-%S)
  mv server_log.txt backup/server_log/server_log_"${CURRENT_DATETIME}".txt
  mv server_chat_log.txt backup/server_chat_log/server_chat_log_"${CURRENT_DATETIME}".txt
fi

# Get to the Server Executable Directory
cd /home/container/bin || exit

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval "${MODIFIED_STARTUP}"
