
# 1 check if server is domain joined or not and echo the status out
# 2 check if local user exist on server
#   - if user already exist, do nothing
#   - if user does not exist, create user with its password. retrieve password from SSM parameter store.
# 3 check if domain user exist on server.
#   - if user already exist, do nothing.
#   - if user does not exist, create user with its password. Retrieve password from SSM parameter store.

#!/bin/bash
user="exampleuser"
# Check if part of domain
if [[ $(realm --name-only list) ]]; then
    echo "Server is part of domain"
else
    echo "Server is NOT part of domain"
fi

if id -u "$user" >/dev/null 2>&1; then
    echo "$user exists"
else
    echo "$user does not exist"
    password=$(aws ssm get-parameters --names $user --with-decryption --query "Parameters[].Value" --output text)
    sudo useradd $user -p $password > /dev/null 2>&1
fi
