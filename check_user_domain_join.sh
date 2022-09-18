# 1 check if server is domain joined or not and echo the status out
# 2 check if local user exist on server
#   - if user already exist, check if it is in the wheel group.
#   - if user does not exist, create user with its password. retrieve password from SSM parameter store. check if it is in the whell group.
# 3 check if domain user is in sudoer file on server. (check if domain user is in sudoer file)
#   - if user already exist, do nothing.
#   - if user does not exist, add it.

#!/bin/bash
user="exampleuser"
ad_group="exampleAdmins@example.local"

# Check if realm is installed
if ! command -v realm &> /dev/null; then
    echo "Install Realm"
    # sudo yum -y install sssd realmd krb5-workstation samba-common-tools adcli oddjob oddjob-mkhomedir
fi

# Check if part of domain
if [[ $(realm --name-only list) ]]; then
    echo "Server is part of domain"
else
    echo "Server is NOT part of domain"
fi

# Check if local user exisits
if id -u "$user" >/dev/null 2>&1; then
    echo "$user exists"
    # Check if user is part of wheel group
    if id -nG "$user" | grep -qw wheel; then
        echo "$user belongs to the wheel group"
    else
        echo "$user does not belong to the wheel group"
        echo "Adding $user to the wheel group"
        sudo usermod $user -aG wheel
    fi
else
    echo "$user does not exist"
    echo "Creating $user..."
    password=$(aws ssm get-parameters --names $user --with-decryption --query "Parameters[].Value" --output text)
    sudo useradd $user -p $password -G wheel > /dev/null 2>&1
fi

# Check if AD Group is in sudoer files
if sudo grep -q $ad_group /etc/sudoers; then
    echo "$ad_group is in sudoer file"
else
    echo "$ad_group is not is sudoer file"
    echo "Adding $ad_group to the sudoer file..."
    sudo sed -i "s|^%wheel.*$|&\n%$ad_group        ALL=(ALL)       ALL|" /etc/sudoers;
fi
