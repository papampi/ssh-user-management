# User Management Script

This script allows you to manage user accounts on a Linux system. You can list existing users with a home directory and SSH access, add new users with a specified username and password, and remove existing users.

## Usage

To run the script, open a terminal and navigate to the directory where the `user-management.sh` file is located. Then, enter the following command:

`sudo ./user-management.sh [OPTION] [USERNAME] [PASSWORD]`

Replace `[OPTION]` with one of the following:

- `-l` or `--list`: List all existing regular user accounts with a home directory and SSH access.
- `-a` or `--add`: Add a new user account. You must specify a username and password.
- `-r` or `--remove`: Remove an existing user account. You must specify a username.

Replace `[USERNAME]` and `[PASSWORD]` with the desired username and password when adding a new user.

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
