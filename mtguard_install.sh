#!/bin/bash

# Set variables
GITHUB_REPO="https://github.com/alexander-lipov/MTGuardian"
INSTALL_DIR="/home/ubuntu/MT/MTGuard/"

# Default configuration values
DEFAULT_MT_CORE_DIR="$INSTALL_DIR"
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

# Step 1: Prepare Installation Directory
echo "Preparing installation directory..."
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
    error_check "Failed to create installation directory."
else
    echo "Directory already exists. Proceeding with setup..."
fi

cd $INSTALL_DIR
error_check "Failed to change to installation directory."

# Step 2: Downloading Files
echo "Downloading necessary files from GitHub..."
git clone $GITHUB_REPO .
error_check "Failed to download files. Check your internet connection and the repository URL."

# Step 3: Editing rc.local
echo "Configuring rc.local to start MTGuardian on boot..."
RC_LOCAL_PATH="/etc/rc.local"
if [ -f $RC_LOCAL_PATH ]; then
    cp $RC_LOCAL_PATH ${RC_LOCAL_PATH}.backup
    error_check "Failed to backup existing rc.local."
fi

echo "/bin/su -s /bin/bash ubuntu -c '/usr/bin/screen -dmS MTGuardian bash -c \"$INSTALL_DIR/MTGuardian; exec bash\"'" | sudo tee $RC_LOCAL_PATH
echo "exit 0" | sudo tee -a $RC_LOCAL_PATH
sudo chown root:root $RC_LOCAL_PATH
sudo chmod 700 $RC_LOCAL_PATH
error_check "Failed to update rc.local."

# Step 4: Configuring MTGuardian.settings
echo "Configuring MTGuardian.settings..."
read -p "Enter the full path to MT core directory (default: $DEFAULT_MT_CORE_DIR): " mt_core_dir
mt_core_dir=${mt_core_dir:-$DEFAULT_MT_CORE_DIR}
read -p "Enter MT core arguments (default: $DEFAULT_MT_CORE_ARGS): " mt_core_args
mt_core_args=${mt_core_args:-$DEFAULT_MT_CORE_ARGS}
read -p "Enter your server name (default: $DEFAULT_MT_CORE_SERVER_NAME): " mt_core_server_name
mt_core_server_name=${mt_core_server_name:-$DEFAULT_MT_CORE_SERVER_NAME}
read -p "Enter your Telegram bot API token (default: Skip with 8): " tg_api_token
tg_api_token=${tg_api_token:-$DEFAULT_TG_API_TOKEN}
read -p "Enter your Telegram chat ID (default: Skip with 8): " tg_chat_id
tg_chat_id=${tg_chat_id:-$DEFAULT_TG_CHAT_ID}

# Update settings file
sed -i "s|^MT_CORE_DIR=.*|MT_CORE_DIR='$mt_core_dir'|" MTGuardian.settings
sed -i "s|^MT_CORE_ARGS=.*|MT_CORE_ARGS='$mt_core_args'|" MTGuardian.settings
sed -i "s|^MT_CORE_SERVER_NAME=.*|MT_CORE_SERVER_NAME='$mt_core_server_name'|" MTGuardian.settings

# Check if user opted to skip TG configuration
if [[ "$tg_api_token" == "8" || "$tg_chat_id" == "8" ]]; then
    echo "Skipping Telegram configuration."
else
    sed -i "s|^TG_API_TOKEN=.*|TG_API_TOKEN='$tg_api_token'|" MTGuardian.settings
    sed -i "s|^TG_CHAT_ID=.*|TG_CHAT_ID='$tg_chat_id'|" MTGuardian.settings
fi

# Step 5: Setting permissions
chmod 700 MTGuardian
error_check "Failed to set permissions for MTGuardian."

# Step 6: Check MTCore Status and Restart/Start
echo "Checking MTCore process..."
if pgrep -f "$mt_core_dir/MTCore" > /dev/null; then
    read -p "MTCore is currently running. Would you like to restart it? (y/n): " confirm_restart
    if [[ "$confirm_restart" == "y" ]]; then
        pkill -f "$mt_core_dir/MTCore"
        sleep 1
        "$mt_core_dir/MTCore" $mt_core_args &
        echo "MTCore has been restarted."
    else
        echo "MTCore restart skipped."
    fi
else
    read -p "MTCore is not running. Would you like to start it? (y/n): " confirm_start
    if [[ "$confirm_start" == "y" ]]; then
        "$mt_core_dir/MTCore" $mt_core_args &
        if [ $? -eq 0 ]; then
            echo "MTCore has been started successfully."
        else
            echo "Failed to start MTCore."
        fi
    else
        echo "MTCore start skipped."
    fi
fi

# Step 7: Final Countdown before completing setup
echo "Finalizing setup in 30 seconds..."
for i in {30..1}; do
    echo -ne "$i seconds remaining...\r"
    sleep 1
done

echo "Setup completed successfully. MTGuardian is configured to run on boot."
echo "If you want to support the further development of this script please donate to the TRC20 wallet: TCgJDoL6qFj6NaQjqirycmqSTXoQqqZ1E3"
