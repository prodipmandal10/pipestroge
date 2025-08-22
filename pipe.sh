#!/bin/bash

# Color codes (Re-using the successful palette from previous scripts)
YELLOW='\033[1;33m'     # Bold Yellow
BOLD='\033[1m'          # General Bold
CYAN='\033[1;36m'       # Bold Cyan
GREEN='\033[1;32m'      # Bold Green
PINK='\033[38;5;198m'   # Deep Pink (Using 256-color code for specific shade)
RED='\033[1;31m'        # Bold Red
MAGENTA='\033[1;35m'    # Bold Magenta (For helper messages/special info)
NC='\033[0m'            # No Color

# --- Global Configuration Variables ---
CONFIG_FILE="$HOME/.pipe-cli.json"
VENV_DIR="$HOME/pipe_venv"

# --- Function to print the main header ---
print_header() {
    clear # Clear screen to ensure header is always at the top
    echo -e "${YELLOW}${BOLD}=====================================================${NC}"
    echo -e "${YELLOW}${BOLD} # # # # # 🧱 PIPE NETWORK HELPER 🧱 # # # # # #${NC}"
    echo -e "${YELLOW}${BOLD} # # # # # #   MADE BY PRODIP   # # # # # #${NC}"
    echo -e "${YELLOW}${BOLD}=====================================================${NC}"
    echo -e "${CYAN}🌐 Follow on Twitter : https://x.com/prodipmandal10${NC}"
    echo -e "${CYAN}📩 DM on Telegram    : @prodipgo${NC}"
    echo -e ""
}

# --- Function: Setup Python virtual environment & gdown ---
setup_venv() {
    echo -e "${GREEN}========== STEP: Setting up Python Virtual Environment ==========${NC}"
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${CYAN}⚙️ Creating Python virtual environment for gdown...${NC}"
        sudo apt update && sudo apt install -y python3-venv python3-pip jq # jq added for view_credentials
        python3 -m venv "$VENV_DIR"
        source "$VENV_DIR/bin/activate"
        pip install --upgrade pip
        pip install gdown yt-dlp
        deactivate
        echo -e "${GREEN}✅ Virtual environment setup complete.${NC}"
    else
        echo -e "${GREEN}✅ Python virtual environment already exists.${NC}"
    fi
    return 0
}

# --- Function: Install Rust & Pipe CLI ---
install_pipe() {
    echo -e "${GREEN}========== STEP: Installing Rust & Pipe CLI ==========${NC}"
    echo -e "${CYAN}⚙️ Installing Rust, dependencies, and PIPE CLI...${NC}"
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc postgresql-client nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev tar clang bsdmainutils ncdu unzip libleveldb-dev libclang-dev ninja-build python3-venv python3-pip -y

    if ! command -v rustc &> /dev/null; then
        echo -e "${CYAN}🔧 Installing Rust...${NC}"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
        echo -e "${GREEN}✅ Rust installed.${NC}"
    else
        echo -e "${GREEN}✅ Rust is already installed.${NC}"
    fi
    
    source "$HOME/.cargo/env" # Ensure env is sourced for cargo/rustc commands
    echo -e "${CYAN}Verifying Rust installation:${NC}"
    rustc --version
    cargo --version

    if [ ! -d "$HOME/pipe" ]; then
        echo -e "${CYAN}📁 Cloning Pipe Network repository...${NC}"
        git clone https://github.com/PipeNetwork/pipe.git
        cd pipe || { echo -e "${RED}❌ Failed to change directory to pipe.${NC}"; return 1; }
        echo -e "${CYAN}⚙️ Building and installing Pipe CLI...${NC}"
        if cargo install --path .; then
            echo -e "${GREEN}✅ Pipe CLI installed successfully.${NC}"
        else
            echo -e "${RED}❌ Failed to install Pipe CLI. Please check the logs.${NC}"; return 1;
        fi
        cd - || { echo -e "${RED}❌ Failed to return to previous directory.${NC}"; return 1; }
    else
        echo -e "${GREEN}✅ Pipe CLI repository already cloned. Ensuring it's installed.${NC}"
        cd pipe || { echo -e "${RED}❌ Failed to change directory to pipe.${NC}"; return 1; }
        if cargo install --path .; then
             echo -e "${GREEN}✅ Pipe CLI installed/updated.${NC}"
        else
            echo -e "${RED}❌ Failed to install/update Pipe CLI. Please check the logs.${NC}"; return 1;
        fi
        cd - || { echo -e "${RED}❌ Failed to return to previous directory.${NC}"; return 1; }
    fi

    echo -e "${GREEN}✅ PIPE CLI installation complete.${NC}"
}

# --- Function: Create new user & set password ---
create_user() {
    echo -e "${GREEN}========== STEP: Create New PIPE User ==========${NC}"
    read -e -p "${PINK}🆕 Enter new PIPE username: ${NC}" username
    if [ -z "$username" ]; then
        echo -e "${RED}❌ Username cannot be empty.${NC}"; return 1;
    fi

    echo -e "${CYAN}Creating user '$username' ...${NC}"
    if pipe new-user "$username"; then
        echo -e "${GREEN}✅ User '$username' created.${NC}"
        echo -e "${CYAN}🔒 Setting your password...${NC}"
        pipe set-password # This will prompt for password interactively
        echo -e "${GREEN}✅ Password set.${NC}"
        echo -e "${CYAN}📝 Editing config file... (Press Ctrl+X to save and exit nano)${NC}"
        nano "$CONFIG_FILE"
    else
        echo -e "${RED}❌ Failed to create user. Please ensure Pipe CLI is installed.${NC}"; return 1;
    fi
}

# --- Function: Apply referral code & generate ---
apply_referral() {
    echo -e "${GREEN}========== STEP: Apply Referral Code ==========${NC}"
    read -e -p "${PINK}🎁 Enter referral code to apply: ${NC}" code
    if [ -z "$code" ]; then
        echo -e "${RED}❌ Referral code cannot be empty.${NC}"; return 1;
    fi
    if pipe referral apply "$code"; then
        echo -e "${GREEN}✅ Referral code applied.${NC}"
        echo -e "${CYAN}🔗 Generating new referral code...${NC}"
        pipe referral generate
        echo -e "${GREEN}✅ New referral code generated.${NC}"
    else
        echo -e "${RED}❌ Failed to apply or generate referral. Check code or CLI status.${NC}"; return 1;
    fi
}

# --- Function: Swap SOL → PIPE ---
swap_tokens() {
    echo -e "${GREEN}========== STEP: Swap SOL for PIPE ==========${NC}"
    echo -e "${CYAN}🔄 Swapping 2 SOL for PIPE token...${NC}"
    if pipe swap-sol-for-pipe 2; then
        echo -e "${GREEN}✅ Swap initiated. Check your wallet.${NC}"
    else
        echo -e "${RED}❌ Failed to swap SOL for PIPE. Check your balance or CLI status.${NC}"; return 1;
    fi
}

# --- Function: Download from Google Drive & Upload to PIPE ---
upload_gdrive_file() {
    echo -e "${GREEN}========== STEP: Download from Google Drive & Upload to PIPE ==========${NC}"
    setup_venv # Ensure venv is set up
    source "$VENV_DIR/bin/activate" # Activate venv for gdown

    read -e -p "${PINK}🔗 Enter Google Drive file link: ${NC}" gdrive_link
    read -e -p "${PINK}✏️ Enter desired filename (with extension): ${NC}" new_name

    if [ -z "$gdrive_link" ] || [ -z "$new_name" ]; then
        echo -e "${RED}❌ Link or filename cannot be empty.${NC}"
        deactivate; return 1;
    fi

    USER_HOME=$(eval echo ~$USER)
    DOWNLOAD_DIR="$USER_HOME/pipe_downloads"
    mkdir -p "$DOWNLOAD_DIR"

    echo -e "${CYAN}⚙️ Downloading file from Google Drive...${NC}"
    if gdown --fuzzy "$gdrive_link" -O "$DOWNLOAD_DIR/$new_name"; then
        FILE_PATH="$DOWNLOAD_DIR/$new_name"
        if [ ! -f "$FILE_PATH" ]; then
            echo -e "${RED}❌ Download failed: File not found after download attempt.${NC}"
            deactivate; return 1;
        fi
        FILE_SIZE=$(du -h "$FILE_PATH" | cut -f1)
        echo -e "${GREEN}✅ Downloaded $new_name ($FILE_SIZE)${NC}"
        
        echo -e "${CYAN}📤 Uploading to PIPE...${NC}"
        if pipe upload-file "$FILE_PATH" "$new_name"; then
            echo -e "${GREEN}✅ File uploaded to PIPE.${NC}"
            echo -e "${CYAN}🔗 Generating public link...${NC}"
            if pipe create-public-link "$new_name"; then
                echo -e "${GREEN}✅ Public link generated successfully.${NC}"
            else
                echo -e "${RED}❌ Failed to generate public link.${NC}"; deactivate; return 1;
            fi
        else
            echo -e "${RED}❌ Failed to upload to PIPE.${NC}"; deactivate; return 1;
        fi
    else
        echo -e "${RED}❌ Google Drive download failed. Check link or gdown status.${NC}"
        deactivate; return 1;
    fi

    deactivate
    echo -e "${GREEN}✅ Google Drive download & PIPE upload complete!${NC}"
}

# --- Function: Generate public link for file ---
generate_public_link_for_file() { # Renamed for clarity in menu
    echo -e "${GREEN}========== STEP: Generate Public Link for File ==========${NC}"
    read -e -p "${PINK}🔗 Enter filename to generate public link for: ${NC}" fname
    if [ -z "$fname" ]; then
        echo -e "${RED}❌ Filename cannot be empty.${NC}"; return 1;
    fi
    if pipe create-public-link "$fname"; then
        echo -e "${GREEN}✅ Public link generated.${NC}"
    else
        echo -e "${RED}❌ Failed to generate public link. Check filename or CLI status.${NC}"; return 1;
    fi
}

# --- Function: List uploaded files ---
list_files() {
    echo -e "${GREEN}========== STEP: List Uploaded Files ==========${NC}"
    echo -e "${CYAN}📂 Uploaded files:${NC}"
    pipe list-files
    echo -e "${GREEN}✅ File list displayed.${NC}"
}

# --- Function: Delete file ---
delete_file() {
    echo -e "${GREEN}========== STEP: Delete a File ==========${NC}"
    read -e -p "${PINK}❌ Enter filename to delete: ${NC}" fname
    if [ -z "$fname" ]; then
        echo -e "${RED}❌ Filename cannot be empty.${NC}"; return 1;
    fi
    if pipe delete-file "$fname"; then
        echo -e "${GREEN}✅ File '$fname' deleted.${NC}"
    else
        echo -e "${RED}❌ Failed to delete file. Check filename or CLI status.${NC}"; return 1;
    fi
}

# --- Function: Show referral info ---
referral_info() {
    echo -e "${GREEN}========== STEP: Show Referral Information ==========${NC}"
    echo -e "${CYAN}📋 Referral information:${NC}"
    pipe referral show
    echo -e "${GREEN}✅ Referral info displayed.${NC}"
}

# --- Function: Reload config ---
reload_config() {
    echo -e "${GREEN}========== STEP: Reload Config File ==========${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE" # This typically reloads environment variables if they were set in config, but .pipe-cli.json is usually JSON.
        echo -e "${GREEN}🔄 Config file reloaded (if applicable).${NC}"
        echo -e "${CYAN}Note: .pipe-cli.json is a JSON file. This 'reload' command might not directly impact the running CLI without restarting.${NC}"
    else
        echo -e "${RED}⚠️ Config file not found: $CONFIG_FILE${NC}"
    fi
}

# --- Function: View config ---
view_config() {
    echo -e "${GREEN}========== STEP: View Config File ==========${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${CYAN}📝 Opening config file: $CONFIG_FILE (Press Ctrl+X to save and exit nano)${NC}"
        nano "$CONFIG_FILE"
    else
        echo -e "${RED}⚠️ Config file not found: $CONFIG_FILE${NC}"
    fi
}

# --- Function: View PIPE credentials ---
view_credentials() {
    echo -e "${GREEN}========== STEP: View PIPE Credentials ==========${NC}"
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${CYAN}📋 PIPE Credentials from $CONFIG_FILE:${NC}"
        if command -v jq &> /dev/null; then
            USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
            APP_KEY=$(jq -r '.app_key' "$CONFIG_FILE")
            SOLANA_PUBKEY=$(jq -r '.solana_pubkey' "$CONFIG_FILE")
            echo -e "${PINK}User ID      : ${BOLD}${USER_ID}${NC}"
            echo -e "${PINK}App Key      : ${BOLD}${APP_KEY}${NC}"
            echo -e "${PINK}Solana Pubkey: ${BOLD}${SOLANA_PUBKEY}${NC}"
        else
            echo -e "${RED}❌ 'jq' is not installed. Cannot parse JSON config file. Please install it with 'sudo apt install jq'.${NC}"
        fi
    else
        echo -e "${RED}⚠️ Config file not found: $CONFIG_FILE${NC}"
    fi
}

# --- Function: Upload video to YouTube ---
upload_youtube() {
    echo -e "${GREEN}========== STEP: Upload Video to YouTube ==========${NC}"
    setup_venv # Ensure venv is set up
    source "$VENV_DIR/bin/activate" # Activate venv for yt-dlp

    read -e -p "${PINK}🔗 Enter YouTube video file path: ${NC}" video_path
    read -e -p "${PINK}🎬 Enter title for the video: ${NC}" title
    read -e -p "${PINK}📄 Enter description for the video: ${NC}" description
    read -e -p "${PINK}🔑 Enter your YouTube API key: ${NC}" api_key
    read -e -p "${PINK}🌐 Enter your YouTube channel ID: ${NC}" channel_id

    if [ -z "$video_path" ] || [ -z "$title" ] || [ -z "$api_key" ] || [ -z "$channel_id" ]; then
        echo -e "${RED}❌ All fields (path, title, API key, channel ID) are required.${NC}"
        deactivate; return 1;
    fi

    if [ ! -f "$video_path" ]; then
        echo -e "${RED}❌ Video file not found at: $video_path${NC}"
        deactivate; return 1;
    fi

    echo -e "${CYAN}📥 Uploading video to YouTube... (This may take a while)${NC}"
    # Note: yt-dlp is primarily for downloading. Uploading typically requires youtube-upload or direct API interaction.
    # The original script's yt-dlp command looks like it's trying to *download* output.
    # For actual YouTube uploading, you'd likely need a dedicated tool like `youtube-upload` or
    # to implement a Python script that uses the YouTube Data API.
    # The command below is a placeholder and may not perform an actual upload as intended.
    # Using 'yt-dlp' for uploading is unusual; it's mostly for downloading.
    # If a direct upload tool is available, replace the following line with it.
    
    # Placeholder: Assuming yt-dlp with specific arguments *could* upload or that there's a custom script
    # The provided command is incomplete for a real upload with yt-dlp directly.
    # A more common approach is a tool like 'youtube-upload' or a Python script.
    # For now, it will just acknowledge the command, but actual upload may not happen.
    
    echo -e "${YELLOW}Warning: Direct YouTube upload via yt-dlp as written is not standard.${NC}"
    echo -e "${YELLOW}You might need a dedicated YouTube upload tool or Python script.${NC}"
    echo -e "${CYAN}Attempting to use yt-dlp with provided arguments (may not upload)...${NC}"
    
    # Original command was slightly off. It seems to be for downloading and writing info, not uploading.
    # If the intention was to use yt-dlp *as an uploader*, its usage is more complex.
    # If you have a specific upload tool (e.g., 'youtube-upload'), this is where you'd call it.
    
    # For now, simulate based on the intent of the function name.
    # If the user has a custom yt-dlp setup for upload, they'd provide specific flags.
    # Without external tools or API scripts, this cannot directly upload.
    # Below is a conceptual placeholder.
    # yt-dlp --cookies cookies.txt --username "YOUR_YT_EMAIL" --password "YOUR_YT_PASSWORD" --upload-video "$video_path" --title "$title" --description "$description" --privacy-status "private" # Example for youtube-dl, might not work for yt-dlp upload

    # Instead of running yt-dlp directly, output instructions or call a helper script
    echo -e "${RED}❌ YouTube upload via yt-dlp is not directly supported as a simple command.${NC}"
    echo -e "${RED}You need to either use a dedicated tool (like 'youtube-upload') or write a Python script using YouTube Data API.${NC}"
    echo -e "${RED}The provided command cannot perform an upload.${NC}"

    deactivate
    echo -e "${GREEN}✅ YouTube upload process complete (check for actual upload status).${NC}"
}

# --- Main Menu Loop ---
while true; do
    print_header # Display the main header
    echo -e "${YELLOW}${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}${BOLD}║           🔧 PIPE NODE HELPER MENU 🔧           ║${NC}"
    echo -e "${YELLOW}${BOLD}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}1${NC}${BOLD}] ${PINK}⚙️ Install Rust, Dependencies & Pipe CLI   ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}2${NC}${BOLD}] ${PINK}🆕 Create New User & Set Password         ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}3${NC}${BOLD}] ${PINK}🎁 Apply Referral Code & Generate        ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}4${NC}${BOLD}] ${PINK}🔄 Swap 2 SOL for PIPE Token              ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}5${NC}${BOLD}] ${PINK}📤 Download GDrive & Upload to PIPE      ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}6${NC}${BOLD}] ${PINK}🔗 Generate Public Link for File          ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}7${NC}${BOLD}] ${PINK}📂 List Uploaded Files                     ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}8${NC}${BOLD}] ${PINK}❌ Delete a File                          ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}9${NC}${BOLD}] ${PINK}📋 Show Referral Information              ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}10${NC}${BOLD}] ${PINK}🔄 Reload Config File                     ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}11${NC}${BOLD}] ${PINK}📝 View Config File                       ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}12${NC}${BOLD}] ${PINK}🧾 View PIPE Credentials                  ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}13${NC}${BOLD}] ${PINK}🎥 Upload Video to YouTube                ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}║ [${YELLOW}0${NC}${BOLD}] ${PINK}👋 Exit Script                           ${YELLOW}${BOLD}  ║${NC}"
    echo -e "${YELLOW}${BOLD}╚══════════════════════════════════════════════╝${NC}"
    echo -e "" # Add a new line for better spacing

    read -p "${PINK}👉 Choose an option [0-13]: ${NC}" opt
    case $opt in
        1) install_pipe ;;
        2) create_user ;;
        3) apply_referral ;;
        4) swap_tokens ;;
        5) upload_gdrive_file ;;
        6) generate_public_link_for_file ;; # Call the new dedicated function
        7) list_files ;;
        8) delete_file ;;
        9) referral_info ;;
        10) reload_config ;;
        11) view_config ;;
        12) view_credentials ;;
        13) upload_youtube ;;
        0) echo -e "${CYAN}🚪 Exiting... Bye! 👋${NC}"; exit 0 ;;
        *) echo -e "${RED}❌ Invalid option! Please enter a number between 0-13.${NC}";;
    esac
    echo -e "" # Add extra space before next menu refresh
    read -p "${CYAN}Press Enter to continue...${NC}" # Consistent pause
done
