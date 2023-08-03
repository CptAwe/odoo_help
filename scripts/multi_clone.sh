#!/bin/bash

# A simple bash script to clone all the necessary odoo versions,
# both community and enterprise, at the same time
# 
# BEWARE, this scripts opens one new terminal window for each git command
# that stays open until it is closed. Also the parent process waits for the
# child processes to end. You can kill the parent process and the child
# processes will also be killed.
# 
# This is the assumed folder structure:
# ├─ odoo
# |  ├─ 13.0 <odoo version>
# |  |  ├── odoo
# |  |  |   <community edition source code>
# |  |  ├── enterprise
# |  |  |   <enterprise edition source code>
# |  ├─ 14.0 <another odoo version>
# |  |  ├── odoo
# |  |  |   <community edition source code>
# |  |  ├── enterprise
# |  |  |   <enterprise edition source code>
# |  ├─ <etc>
# ├─ Scripts (or whatever name you fancy)
# |  ├─ <where this script is expected to be housed
# 


#### SETTINGS ####
source_code_base_folder="../../odoo/" # The folder to house all the source codes
community_repo_link="https://github.com/odoo/odoo.git" # ssh or https
community_folder_name="odoo" # The name of the folder that houses all the community version code
enterprise_repo_link="git@github.com:odoo/enterprise.git" # ssh only
enterprise_folder_name="enterprise" # The name of the folder that houses all the enterprise version code
terminal_program="terminator -e" # Prefered terminal command to open multiple windows and executes the cloning

additional_git_flags="--depth=1"

declare -A odoo_repo_branches_folders=(
#   branch  | folder
    ["12.0"]=12.0
    ["13.0"]=13.0
    ["14.0"]=14.0
    ["15.0"]=15.0
    ["16.0"]=16.0
)

echo "Started cloning in $PWD"

# Create the folder that all the source code will be housed
mkdir $source_code_base_folder
cd $source_code_base_folder

# Executes a command in a new window which is left open waiting for a key press
# <command>
function command_in_new_window {
    command2execute="$*"
    eval "$terminal_program 'echo "$command2execute" && "$command2execute" && echo "[DONE] Press any key to exit" && "read -r -n1 key"'"
}

# Function to pull the source code from a link
# <branch_name> <source_link> <destination_folder>
function git_clone {
    __branch_name=$1
    __source_link=$2
    __destination_folder=$3

    command="git clone $additional_git_flags -b '$__branch_name' $__source_link $__destination_folder"
    command_in_new_window $command
}

for branch_name in "${!odoo_repo_branches_folders[@]}"; do

    destination_folder_name=${odoo_repo_branches_folders[$branch_name]}

    # Create the specific version folder
    mkdir $destination_folder_name

    #### COMMUNITY EDITION ####
    # Create community edition source code folder
    destination_folder_name_community="$destination_folder_name/$community_folder_name"
    mkdir $destination_folder_name_community
    ## Fetch the source code
    echo "Pulling community edition $branch_name in $destination_folder_name_community"
    git_clone $branch_name $community_repo_link $destination_folder_name_community &


    # #### ENTERPRISE EDITION ####
    # # Create enterprise edition source code folder
    # destination_folder_name_enterprise="$destination_folder_name/$enterprise_folder_name"
    # mkdir $destination_folder_name_enterprise
    # ## Fetch the source code
    # enterprise_command="git clone -b '$branch_name' $enterprise_repo_link:enterprise $destination_folder_name_enterprise"
    # echo "Pulling enterprise edition $branch_name in $destination_folder_name_enterprise"
    # eval $enterprise_command &
    
done

# Wait for all the pulling to complete
wait
echo "[DONE] All child processes should be done"

