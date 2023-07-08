#!/bin/bash

# Function to print usage instructions
function usage {
  echo "Usage: ./user-management.sh [OPTION] [USERNAME] [PASSWORD] "
  echo ""
  echo "Options:"
  echo "  -l, --list      List all existing regular user accounts with a home directory and SSH access"
  echo "  -a, --add       Add a new user account"
  echo "  -r, --remove    Remove an existing user account"
  echo "  -b, --badvpn    Set up badvpn-udpgw system-wide"
  echo ""
  echo "Usage examples:"
  echo "  ./user-management.sh -l"
  echo "  ./user-management.sh -a john secret"
  echo "  ./user-management.sh -r jane"
  echo "  ./user-management.sh -b"
  echo ""
}

# Function to setup badvpn
function setup_badvpn {
  # Check if badvpn-udpgw already exists
  if command -v badvpn-udpgw &>/dev/null; then
    read -p "badvpn-udpgw already exists. Do you want to overwrite/update it? (y/n): " overwrite_badvpn

    if [[ $overwrite_badvpn == "y" || $overwrite_badvpn == "Y" ]]; then
      prompt_badvpn_port
    else
      echo "Skipping badvpn-udpgw setup."
    fi
  else
    prompt_badvpn_port
  fi
}

# Function to prompt for badvpn-udpgw port and start setup
function prompt_badvpn_port {
  # Prompt user for the badvpn-udpgw port
  read -p "Enter the port for badvpn-udpgw (1024-65535): " port

  # Validate port range
  if ! [[ $port =~ ^[0-9]+$ ]] || [[ $port -lt 1024 || $port -gt 65535 ]]; then
    echo "Invalid port number. Port must be within the range of 1024 to 65535."
    return
  fi

  # Download and configure badvpn-udpgw
  wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/daybreakersx/premscript/master/badvpn-udpgw64"
  chmod +x /usr/bin/badvpn-udpgw
  screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port

  echo "badvpn-udpgw is set up system-wide on port $port"

  # Ask user if they want badvpn-udpgw to start at reboot
  read -p "Do you want badvpn-udpgw to start at reboot? (y/n): " start_at_reboot

  if [[ $start_at_reboot == "y" || $start_at_reboot == "Y" ]]; then
    # Check if the @reboot entry for badvpn-udpgw exists in crontab
    if ! crontab -l | grep -q "@reboot screen -AmdS badvpn badvpn-udpgw"; then
      # Add the @reboot entry for badvpn-udpgw to crontab
      (crontab -l ; echo "@reboot screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port") | crontab -

      echo "Added badvpn-udpgw @reboot entry to crontab"
    else
      echo "The @reboot entry for badvpn-udpgw already exists in crontab"
    fi
  fi
}

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Check if screen is installed and prompt the user to install it if it's missing
if ! command -v screen >/dev/null 2>&1; then
  read -p "The 'screen' package is not installed. Do you want to install it now? (y/n): " install_screen
  if [[ $install_screen == "y" || $install_screen == "Y" ]]; then
    sudo apt-get update
    sudo apt-get install -y screen
  else
    echo "Error: The 'screen' package is required but not installed. Aborting."
    exit 1
  fi
fi

# Parse command line arguments
if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case $1 in
  -l|--list)
    # List all existing regular user accounts with a home directory and SSH access
    awk -F':' '{ if($6 ~ /^\/home/ && $7 != "/sbin/nologin" && $3 >= 1000) print $1 }' /etc/passwd
    ;;
  -a|--add)
    # Add a new user account
    if [[ $# -ne 3 ]]; then
      echo "Error: You must specify a username and password to add."
      usage
      exit 1
    fi
    username=$2
    password=$3

    # Create user with provided username and home directory
    useradd_command="useradd $username -m -d /home/$username -s /bin/true"
    sudo $useradd_command

    # Set password for new user
    passwd_command="passwd $username"
    sudo chpasswd <<< "$username:$password"

    # Show new username and password
    echo "New user created:"
    echo "Username: $username"
    echo "Password: $password"

    # Ask user if they want to set an expiry date for the user
    read -p "Do you want to set an expiry date for the user? (y/n): " set_expiry

    if [[ $set_expiry == "y" || $set_expiry == "Y" ]]; then
      # Prompt user for expiry date
      read -p "Enter expiry date (YYYY-MM-DD): " expiry_date

      # Add cron job to remove user and home directory on expiry date
      cron_command="userdel -rfRZ $username ; pkill -u $username sshd"
      (crontab -l ; echo "0 0 $expiry_date * * $cron_command") | crontab -

      echo "User and home directory will be removed on $expiry_date"
    else
      echo "Expiry date not set"
    fi
    ;;
  -r|--remove)
    # Remove an existing user account
    if [[ $# -ne 2 ]]; then
      echo "Error: You must specify a username to remove."
      usage
      exit 1
    fi
    username=$2
    # Kill user ssh session and remove the user
    sudo pkill -u $username sshd
    sudo userdel -rfRZ  $username
    # Check if the user's home folder still exists and remove it if necessary
    if [ -d "/home/$username" ]; then
      echo "Removing the user's home folder: /home/$username"
      sudo rm -rf "/home/$username"
    fi
    ;;
  -b|--badvpn)
    # Set up badvpn-udpgw system-wide
    setup_badvpn
    ;;
  *)
    echo "Error: Invalid option."
    usage
    exit 1
    ;;
esac
