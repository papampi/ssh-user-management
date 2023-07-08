#!/bin/bash

# Function to print usage instructions
function usage {
  echo "Usage: ./user-management.sh [OPTION] [USERNAME] [PASSWORD] "
  echo ""
  echo "Options:"
  echo "  -l, --list      List all existing regular user accounts with a home directory and SSH access"
  echo "  -a, --add       Add a new user account"
  echo "  -r, --remove    Remove an existing user account"
  echo ""
}

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
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
        cron_command="userdel -r $username"
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
    deluser $username
    # Check if the user's home folder still exists and remove it if necessary
    if [ -d "/home/$username" ]; then
      echo "Removing the user's home folder: /home/$username"
      sudo rm -rf "/home/$username"
    fi
    ;;
  *)
    echo "Error: Invalid option."
    usage
    exit 1
    ;;
esac
