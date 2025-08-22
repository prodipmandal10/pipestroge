#!/bin/bash

# -------------------------
# Welcome Banner
# -------------------------
clear
echo -e "\e[1;32m"
echo "======================================================"
echo "           🧱 PIPE NETWORK (MADE BY PRODIP)           "
echo "======================================================"
echo -e "\e[0m"
echo -e "🌐 Follow on Twitter : \e[1;34mhttps://x.com/prodipmandal10\e[0m"
echo -e "📩 DM on Telegram    : \e[1;35m@prodipgo\e[0m"
echo "------------------------------------------------------"
sleep 3

# =========================
# PIPE Network Helper Script
# =========================

CONFIG_FILE="$HOME/.pipe-cli.json"
VENV_DIR="$HOME/pipe_venv"
PIPE_PATH_SCRIPT="$HOME/set_pipe_path.sh"

# -------------------------
# Function: Setup Python virtual environment & gdown
# -------------------------
setup_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        echo "⚙️ Creating Python virtual environment for gdown..."
        sudo apt update && sudo apt install -y python3-venv python3-pip
        python3 -m venv "$VENV_DIR"
        source "$VENV_DIR/bin/activate"
        pip install --upgrade pip
        pip install gdown
        deactivate
        echo "✅ Virtual environment setup complete."
    fi
}

# -------------------------
# Function: Install Rust & Pipe CLI
# -------------------------
install_pipe() {
    echo "⚙️ Installing Rust, dependencies, and PIPE CLI..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc postgresql-client nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev tar clang bsdmainutils ncdu unzip libleveldb-dev libclang-dev ninja-build python3-venv python3-pip -y
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    # Setup PATH in a separate script, not .bashrc directly
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' > "$PIPE_PATH_SCRIPT"
    echo "🛡️ PATH setup script created at $PIPE_PATH_SCRIPT"
    source "$PIPE_PATH_SCRIPT"

    rustc --version
    cargo --version

    git clone https://github.com/PipeNetwork/pipe.git
    cd pipe || return
    cargo install --path .
    cd - || return

    echo "✅ Installation complete."
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Set Pipe CLI PATH manually
# -------------------------
set_pipe_path() {
    if [ -f "$PIPE_PATH_SCRIPT" ]; then
        source "$PIPE_PATH_SCRIPT"
        echo "✅ Pipe CLI PATH activated for current session."
    else
        echo "⚠️ PATH setup script not found, creating now..."
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' > "$PIPE_PATH_SCRIPT"
        source "$PIPE_PATH_SCRIPT"
        echo "✅ Created and activated PATH for current session."
    fi
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Create new user & set password
# -------------------------
create_user() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
    read -p "🆕 Enter new PIPE username: " username
    pipe new-user "$username"
    echo "🔒 Set your password:"
    pipe set-password
    echo "📝 Editing config file..."
    nano "$CONFIG_FILE"
    echo "✅ User created, now displaying credentials..."
    view_credentials
}

# -------------------------
# Function: Apply referral code & generate
# -------------------------
apply_referral() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
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
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
    echo "🔄 Swapping 2 SOL for PIPE token..."
    pipe swap-sol-for-pipe 2
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Download & Upload multiple Google Drive files
# -------------------------
upload_multiple_gdrive_files() {
    if ! command -v gdown &> /dev/null; then
        setup_venv
    fi
    source "$VENV_DIR/bin/activate"

    USER_HOME=$(eval echo ~$USER)
    DOWNLOAD_DIR="$USER_HOME/pipe_downloads"
    mkdir -p "$DOWNLOAD_DIR"

    declare -a links
    declare -a names

    echo "🔢 Enter up to 5 Google Drive file links. Press Enter to skip remaining."

    for i in {1..5}; do
        read -p "🔗 Link #$i: " link
        if [ -z "$link" ]; then
            break
        fi
        links+=("$link")
        read -p "✏️ Desired filename for Link #$i (with extension): " fname
        names+=("$fname")
    done

    if [ ${#links[@]} -eq 0 ]; then
        echo "❌ No links provided, returning to menu."
        deactivate
        read -p "Press Enter to continue..."
        return
    fi

    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        deactivate
        read -p "Press Enter to continue..."
        return
    fi

    for idx in "${!links[@]}"; do
        echo "⚙️ Downloading file #$((idx+1)) from Google Drive..."
        gdown --fuzzy "${links[$idx]}" -O "$DOWNLOAD_DIR/${names[$idx]}"
        FILE_PATH="$DOWNLOAD_DIR/${names[$idx]}"

        if [ ! -f "$FILE_PATH" ]; then
            echo "❌ Download failed for ${names[$idx]}"
            continue
        fi

        FILE_SIZE=$(du -h "$FILE_PATH" | cut -f1)
        echo "✅ Downloaded ${names[$idx]} ($FILE_SIZE)"

        echo "📤 Uploading ${names[$idx]} to PIPE..."
        pipe upload-file "$FILE_PATH" "${names[$idx]}"
        echo "🔗 Generating public link for ${names[$idx]}..."
        pipe create-public-link "${names[$idx]}"
        echo "---------------------------------------"
    done

    deactivate
    echo "✅ All provided files processed."
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Generate public link for a file
# -------------------------
generate_public_link() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
    read -p "Enter filename to generate link: " fname
    pipe create-public-link "$fname"
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: List uploaded files
# -------------------------
list_files() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
    echo "📂 Uploaded files (pipe list-uploads):"
    pipe list-uploads
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Delete file
# -------------------------
delete_file() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
    read -p "❌ Enter filename to delete: " fname
    pipe delete-file "$fname"
    read -p "Press Enter to continue..."
}

# -------------------------
# Function: Show referral info
# -------------------------
referral_info() {
    if ! command -v pipe &> /dev/null; then
        echo "❗ 'pipe' CLI not found! Please activate PATH via option 14."
        read -p "Press Enter to continue..."
        return
    fi
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
# Function: View PIPE credentials
# -------------------------
view_credentials() {
    if [ -f "$CONFIG_FILE" ]; then
        echo "📋 PIPE Credentials:"
        USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
        APP_KEY=$(jq -r '.app_key' "$CONFIG_FILE")
        SOLANA_PUBKEY=$(jq -r '.solana_pubkey' "$CONFIG_FILE")
        echo "User ID      : $USER_ID"
        echo "App Key      : $APP_KEY"
        echo "Solana Pubkey: $SOLANA_PUBKEY"
    else
        echo "⚠️ Config file not found."
    fi
    read -p "Press Enter to continue..."
}

# -------------------------
# Main Menu Loop
# -------------------------
while true; do
    clear
    echo -e "\e[1;34m========= 🔧 PIPE NODE HELPER MENU 🔧 =========\e[0m"
    echo -e "\e[1;33m 1. ⚙️  Install Rust, dependencies and Pipe CLI\e[0m"
    echo -e "\e[1;36m 2. 🆕  Create new user and set password\e[0m"
    echo -e "\e[1;35m 3. 🎁  Apply referral code and generate\e[0m"
    echo -e "\e[1;32m 4. 🔄  Swap 2 SOL for PIPE token\e[0m"
    echo -e "\e[1;35m 5. 📤  Download & Upload multiple Google Drive files\e[0m"
    echo -e "\e[1;36m 6. 🔗  Generate public link for file\e[0m"
    echo -e "\e[1;33m 7. 📂  List uploaded files (pipe list-uploads)\e[0m"
    echo -e "\e[1;31m 8. ❌  Delete a file\e[0m"
    echo -e "\e[1;36m 9. 📋  Show referral information\e[0m"
    echo -e "\e[1;34m10. 🔄  Reload config file\e[0m"
    echo -e "\e[1;33m11. 📝  View config file\e[0m"
    echo -e "\e[1;32m12. 🚪  Exit script\e[0m"
    echo -e "\e[1;36m13. 🧾  View PIPE credentials\e[0m"
    echo -e "\e[1;36m14. 🛡️  Set PATH for pipe CLI\e[0m"
    echo -e "\e[1;31m15. 🚪  Exit script\e[0m"
    echo -e "\e[1;34m===============================================\e[0m"

    read -p "👉 Choose an option [1-15]: " opt
    case $opt in
        1) install_pipe ;;
        2) create_user ;;
        3) apply_referral ;;
        4) swap_tokens ;;
        5) upload_multiple_gdrive_files ;;
        6) generate_public_link ;;
        7) list_files ;;
        8) delete_file ;;
        9) referral_info ;;
        10) reload_config ;;
        11) view_config ;;
        12) echo "🚪 Exiting... Bye!"; exit 0 ;;
        13) view_credentials ;;
        14) set_pipe_path ;;
        15) echo "🚪 Exiting... Bye!"; exit 0 ;;
        *) echo -e "\e[1;31m❌ Invalid option! Please enter 1-15.\e[0m"; read -p "Press Enter to continue..." ;;
    esac
done
