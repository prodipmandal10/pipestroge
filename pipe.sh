#!/bin/bash

CONFIG_FILE="$HOME/.pipe-cli.json"

install_dependencies() {
    echo "Installing Rust, dependencies, and PIPE CLI..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl iptables build-essential git wget lz4 jq make gcc postgresql-client nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev tar clang bsdmainutils ncdu unzip libleveldb-dev libclang-dev ninja-build -y
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env
    rustc --version
    cargo --version
    git clone https://github.com/PipeNetwork/pipe.git
    cd pipe || return
    cargo install --path .
    cd - || return
    echo "Installation complete."
    read -p "Press Enter to continue..."
}

new_user_and_password() {
    read -p "Enter new PIPE username: " username
    pipe new-user "$username"
    echo "Set your password:"
    pipe set-password
    echo "Editing config file..."
    nano "$CONFIG_FILE"
}

referral_apply_generate() {
    read -p "Enter referral code to apply: " code
    pipe referral apply "$code"
    pipe referral generate
    echo "Referral code applied and generated."
    read -p "Press Enter to continue..."
}

swap_sol_to_pipe() {
    echo "Swapping 2 SOL for PIPE token..."
    pipe swap-sol-for-pipe 2
    read -p "Press Enter to continue..."
}

upload_file() {
    read -p "Enter full file path to upload: " file_path
    read -p "Enter file name to save as: " file_name
    pipe upload-file "$file_path" "$file_name"
    read -p "Press Enter to continue..."
}

generate_public_link() {
    read -p "Enter uploaded file name to create public link: " file_name
    pipe create-public-link "$file_name"
    read -p "Press Enter to continue..."
}

list_uploaded_files() {
    pipe list-files
    read -p "Press Enter to continue..."
}

delete_file() {
    read -p "Enter file name to delete: " file_name
    pipe delete-file "$file_name"
    read -p "Press Enter to continue..."
}

show_referral_info() {
    pipe referral show
    read -p "Press Enter to continue..."
}

reload_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo "Config file reloaded."
    else
        echo "Config file not found at $CONFIG_FILE"
    fi
    read -p "Press Enter to continue..."
}

view_config() {
    if [ -f "$CONFIG_FILE" ]; then
        nano "$CONFIG_FILE"
    else
        echo "Config file not found at $CONFIG_FILE"
        read -p "Press Enter to continue..."
    fi
}

exit_script() {
    echo "Exiting... Bye!"
    exit 0
}

while true; do
    clear
    echo "==========================================="
    echo "           MADE BY PRODIP"
    echo "==========================================="
    echo "============== PIPE MENU ==============="
    echo "1. Install Rust, dependencies and Pipe CLI"
    echo "2. Create new user and set password"
    echo "3. Apply referral code and generate"
    echo "4. Swap 2 SOL for PIPE token"
    echo "5. Upload a file"
    echo "6. Generate public link for file"
    echo "7. List uploaded files"
    echo "8. Delete a file"
    echo "9. Show referral information"
    echo "10. Reload config file"
    echo "11. View config file"
    echo "12. Exit script"
    echo "==========================================="
    read -p "Enter choice [1-12]: " choice

    case $choice in
        1) install_dependencies ;;
        2) new_user_and_password ;;
        3) referral_apply_generate ;;
        4) swap_sol_to_pipe ;;
        5) upload_file ;;
        6) generate_public_link ;;
        7) list_uploaded_files ;;
        8) delete_file ;;
        9) show_referral_info ;;
        10) reload_config ;;
        11) view_config ;;
        12) exit_script ;;
        *) echo "Invalid choice! Please enter 1-12." ; read -p "Press Enter to continue..." ;;
    esac
done
