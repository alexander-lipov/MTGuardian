#!/bin/bash

# Set variables
GITHUB_REPO="https://github.com/Greendq/MTGuardian"
INSTALL_DIR="/home/ubuntu/scripts"
RC_LOCAL_PATH="/etc/rc.local"

# Default configuration values
DEFAULT_MT_CORE_DIR="/full/path/to/mt/"
DEFAULT_MT_CORE_ARGS="--no-update"
DEFAULT_MT_CORE_SERVER_NAME="My super server with IPv4:123.456.789.123"
DEFAULT_TG_API_TOKEN="0000000000:AABBBBBBBBBBCCCCCCCCDDDDDDDFFFFFFFF"
DEFAULT_TG_CHAT_ID="-1234567890123"

# Function to handle errors
error_check() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

echo "Starting MTGuardian Setup Wizard..."

# Step 1: Downloading Files
echo "Downloading necessary files from GitHub..."
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR
git clone $GITHUB_REPO .
error_check "Failed to download files. Check your internet connection and the repository URL."

# Step 2: Editing rc.local
echo "Configuring rc.local to start MTGuardian on boot..."
if [ -f $RC_LOCAL_PATH ]; then
    cp $RC_LOCAL_PATH ${RC_LOCAL_PATH}.backup
    error_check "Failed to backup existing rc.local."
fi

echo "/bin/su -s /bin/bash ubuntu -c '/usr/bin/screen -dmS MTGuardian bash -c \"$INSTALL_DIR/MTGuardian; exec bash\"'" | sudo tee $RC_LOCAL_PATH
echo "exit 0" | sudo tee -a $RC_LOCAL_PATH
sudo chown root:root $RC_LOCAL_PATH
sudo chmod 700 $RC_LOCAL_PATH
error_check "Failed to update rc.local."

# Step 3: Configuring MTGuardian.settings
echo "Configuring MTGuardian.settings..."
read -p "Enter the full path to MT core directory (default: $DEFAULT_MT_CORE_DIR): " mt_core_dir
mt_core_dir=${mt_core_dir:-$DEFAULT_MT_CORE_DIR}
read -p "Enter MT core arguments (default: $DEFAULT_MT_CORE_ARGS): " mt_core_args
mt_core_args=${mt_core_args:-$DEFAULT_MT_CORE_ARGS}
read -p "Enter your server name (default: $DEFAULT_MT_CORE_SERVER_NAME): " mt_core_server_name
mt_core_server_name=${mt_core_server_name:-$DEFAULT_MT_CORE_SERVER_NAME}
read -p "Enter your Telegram bot API token (default: $DEFAULT_TG_API_TOKEN): " tg_api_token
tg_api_token=${tg_api_token:-$DEFAULT_TG_API_TOKEN}
read -p "Enter your Telegram chat ID (default: $DEFAULT_TG_CHAT_ID): " tg_chat_id
tg_chat_id=${tg_chat_id:-$DEFAULT_TG_CHAT_ID}

# Update settings file
sed -i "s|^MT_CORE_DIR=.*|MT_CORE_DIR='$mt_core_dir'|" MTGuardian.settings
sed -i "s|^MT_CORE_ARGS=.*|MT_CORE_ARGS='$mt_core_args'|" MTGuardian.settings
sed -i "s|^MT_CORE_SERVER_NAME=.*|MT_CORE_SERVER_NAME='$mt_core_server_name'|" MTGuardian.settings
sed -i "s|^TG_API_TOKEN=.*|TG_API_TOKEN='$tg_api_token'|" MTGuardian.settings
sed -i "s|^TG_CHAT_ID=.*|TG_CHAT_ID='$tg_chat_id'|" MTGuardian.settings

# Step 4: Setting permissions
chmod 700 MTGuardian
error_check "Failed to set permissions for MTGuardian."

echo "Setup completed successfully. MTGuardian is configured to run on boot."
