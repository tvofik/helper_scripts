# 1) Add theses USERS:
  # - cafnauto
  # - pamrecon
  # - pamadmin
# 2) Set password of users to non-expiring
# 3) Create or set login profile to /home/pamrecon/.bash_profile
# Then add this command to profile - sudo sudosh

#!/bin/bash
# user="exampleuser"
# ad_group="exampleAdmins@example.local"

REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F: '/region/ {print $2}' | sed 's/[\" ,]//g'}

users=("cafnauto" "pamadmin" "pamrecon")

for user in ${users[@]}; do
  # Check if local user exisit
  if id -u "$user" >/dev/null 2>&1; then
      echo "$user exists"
      # Check if user is part of admin group
      if id -nG "$user" | grep -qw wheel; then
          echo "$user belongs to the admin group"
      else
          echo "$user does not belong to the admin group"
          echo "Adding $user to the admin group"
          sudo usermod $user -aG wheel
      fi
  else
      echo "$user does not exist"
      echo "Creating $user..."
      password=$(aws ssm get-parameters --names $user --with-decryption --query "Parameters[].Value" --region $REGION --output text)
      sudo useradd $user -p $password -G wheel > /dev/null 2>&1
  fi

  if [[ $user == "pamrecon" ]]; then
    # check if the /home/$user/.bash_profile exisit
    if [[ -e /home/$user/.bash_profile ]]; then
      sudo echo "sudo sudosh" >> /home/$user/.bash_profile
    else
      sudo touch /home/$user/.bash_profile && sudo echo "sudo sudosh" >> /home/$user/.bash_profile
    fi
  fi
done



# for user in ${users[@]}; do
#   echo $user
# done
