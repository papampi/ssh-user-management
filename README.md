# User Management Bash Script

This is a Bash script that provides basic user management functionality for a Linux system. The script can be used to list existing regular user accounts with a home directory and SSH access, add a new user account, remove an existing user account, and set up the `badvpn-udpgw` system-wide.

## Usage

To use the script, you need to have root privileges. You can run the script by executing the following command:

```bash
sudo ./user-management.sh [OPTION] [USERNAME] [PASSWORD]
```

The script takes three optional arguments:

- `-l` or `--list`: Lists all existing regular user accounts with a home directory and SSH access.
- `-a` or `--add`: Adds a new user account. This option requires you to specify a username and a password.
- `-r` or `--remove`: Removes an existing user account. This option requires you to specify a username.
- `-b` or `--badvpn`: Sets up `badvpn-udpgw` system-wide.

Use the `usage` function to print a help message with usage instructions and examples.

## Functionality

### List existing user accounts

The `-l` option lists all existing regular user accounts with a home directory and SSH access. The script uses `awk` to parse the `/etc/passwd` file and filter out users that don't meet the criteria.

### Add a new user account

The `-a` option adds a new user account with the specified username and password. The script creates a new user with the provided username and home directory, sets the password for the user, and prompts the user to set an expiry date for the account. If an expiry date is set, the script adds a cron job to remove the user and the home directory on the specified date.

### Remove an existing user account

The `-r` option removes an existing user account with the specified username. The script first kills the user's SSH session and then removes the user account and the home directory. If the home directory still exists after removing the user account, the script also removes the home directory.

### Set up badvpn-udpgw system-wide

The `-b` option sets up `badvpn-udpgw` system-wide. The script checks if `badvpn-udpgw` is already installed and prompts the user to overwrite/update it if necessary. The user is then prompted to enter a port number for `badvpn-udpgw`. The script downloads and configures `badvpn-udpgw` and starts it in a detached screen session. The user is also asked if they want `badvpn-udpgw` to start at reboot. If the user answers yes, the script adds a cron job to start `badvpn-udpgw` at reboot.

## Dependencies

The script requires the `screen` package to be installed. If `screen` is not installed, the script prompts the user to install it.

## Examples

### List all existing users
To list all existing regular user accounts with a home directory and SSH access, enter the following command:

`sudo ./user-management.sh --list`

### Add a new user
To add a new user with the username `john` and the password `password123`, enter the following command:

`sudo ./user-management.sh --add john password123`

### Remove a user
To remove the user `john`, enter the following command:

`sudo ./user-management.sh --remove john`


## Notes

- This script must be run as root.
- When adding a new user, the script creates a home directory for the user at `/home/username`.
- When removing a user, the script deletes the user's home directory and all its contents.
- When adding a new user, you can optionally set an expiry date for the user. If an expiry date is set, the user and home directory will be automatically removed on the specified date.
- The script prompts you for confirmation before removing a user.
- The script does not validate the strength of the password when adding a new user. It is recommended to use a strong password.
- This script was created for educational purposes and should be used with caution in a production environment.

## License

This script is licensed under the [MIT License](LICENSE).
