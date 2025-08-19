#!/bin/bash

# =========================
# PIPE Network Helper Script (Ready-to-Run with GDrive Download)
# =========================
# MADE BY PRODIP
# =========================

CONFIG_FILE="$HOME/.pipe-cli.json"

# -------------------------
# Function: Install Rust & Pipe CLI
# -------------------------
install_pipe() {
    echo "⚙️ Installing Rust, dependencies, and PIPE CLI..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc postgresql-client nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev tar clang bsdmainutils ncdu unzip libleveldb-dev libclang-dev ninja-build python3-pip -y
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    rustc --version
    cargo --version

    git clone https://github.com/PipeNetwork/pipe.git
    cd pipe || return
    cargo install --path .
    cd - || return

    # Install gdown
    pip3 install gdown

    echo "✅ Installation complete."
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Create new user & set password
# -------------------------
create_user() {
    read -p "🆕 Enter new PIPE username: " username
    pipe new-user "$username"
    echo "🔒 Set your password:"
    pipe set-password
    echo "📝 Editing config file..."
    nano "$CONFIG_FILE"
}

# -------------------------
# Function: Apply referral code & generate
# -------------------------
apply_referral() {
    read -p "🎁 Enter referral code to apply: " code
    pipe referral apply "$code"
    pipe referral generate
    echo "✅ Referral applied & generated."
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Swap SOL → PIPE
# -------------------------
swap_tokens() {
    echo "🔄 Swapping 2 SOL for PIPE token..."
    pipe swap-sol-for-pipe 2
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Upload file (Auto GDrive Download & Upload)
# -------------------------
upload_file() {
    echo "📤 Google Drive File Download & Upload to PIPE"

    USER_HOME=$(eval echo ~$USER)
    DOWNLOAD_DIR="$USER_HOME/pipe_downloads"
    mkdir -p "$DOWNLOAD_DIR"

    # Install gdown if missing
    if ! command -v gdown &>/dev/null; then
        echo "⚙️ Installing gdown..."
        pip3 install gdown
    fi

    # Ask for Google Drive link
    read -p "🔗 Enter Google Drive file link: " GDRIVE_LINK

    # Ask for desired filename
    read -p "📝 Enter filename to save (with extension, e.g., video.mp4): " FILE_NAME

    FILE_PATH="$DOWNLOAD_DIR/$FILE_NAME"

    # Download file using gdown
    echo "⬇️ Downloading from Google Drive..."
    gdown "$GDRIVE_LINK" -O "$FILE_PATH"

    # Check file size
    FILE_SIZE=$(du -m "$FILE_PATH" | cut -f1)
    echo "✅ Downloaded $FILE_NAME ($FILE_SIZE MB)"

    # Upload & generate public link
    echo "📤 Uploading to PIPE..."
    pipe upload-file "$FILE_PATH" "$FILE_NAME"
    echo "🔗 Generating public link..."
    pipe create-public-link "$FILE_NAME"

    echo "✅ Done!"
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: List uploaded files
# -------------------------
list_files() {
    echo "📂 Uploaded files:"
    pipe list-files
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Delete file
# -------------------------
delete_file() {
    read -p "❌ Enter filename to delete: " fname
    pipe delete-file "$fname"
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Show referral info
# -------------------------
referral_info() {
    echo "📋 Referral information:"
    pipe referral show
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Reload config
# -------------------------
reload_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo "🔄 Config file reloaded."
    else
        echo "⚠️ Config file not found."
    fi
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: View config
# -------------------------
view_config() {
    if [ -f "$CONFIG_FILE" ]; then
        nano "$CONFIG_FILE"
    else
        echo "⚠️ Config file not found."
        read -p "Press Enter to continue..."
    fi
}

# -------------------------
# Main Menu Loop
# -------------------------
while true; do
    clear
    echo -e "\e[1;34m====== PIPE NODE HELPER ======\e[0m"
    echo -e "\e[1;33m1. ⚙️ Install Rust, dependencies and Pipe CLI\e[0m"
    echo -e "\e[1;33m2. 🆕 Create new user and set password\e[0m"
    echo -e "\e[1;33m3. 🎁 Apply referral code and generate\e[0m"
    echo -e "\e[1;33m4. 🔄 Swap 2 SOL for PIPE token\e[0m"
    echo -e "\e[1;33m5. 📤 Upload a file (GDrive download)\e[0m"
    echo -e "\e[1;33m6. 🔗 Generate public link for file\e[0m"
    echo -e "\e[1;33m7. 📂 List uploaded files\e[0m"
    echo -e "\e[1;33m8. ❌ Delete a file\e[0m"
    echo -e "\e[1;33m9. 📋 Show referral information\e[0m"
    echo -e "\e[1;33m10. 🔄 Reload config file\e[0m"
    echo -e "\e[1;33m11. 📝 View config file\e[0m"
    echo -e "\e[1;33m12. 🚪 Exit script\e[0m"
    echo -e "\e[1;34m==============================\e[0m"

    read -p "Choose an option [1-12]: " opt
    case $opt in
        1) install_pipe ;;
        2) create_user ;;
        3) apply_referral ;;
        4) swap_tokens ;;
        5) upload_file ;;
        6) echo "Enter filename to generate link:"; read fname; pipe create-public-link "$fname"; read -p "Press Enter to continue..." ;;
        7) list_files ;;
        8) delete_file ;;
        9) referral_info ;;
        10) reload_config ;;
        11) view_config ;;
        12) echo "🚪 Exiting... Bye!"; echo "MADE BY PRODIP"; exit 0 ;;
        *) echo -e "\e[1;31m❌ Invalid option! Please enter 1-12.\e[0m"; read -p "Press Enter to continue..." ;;
    esac
done
