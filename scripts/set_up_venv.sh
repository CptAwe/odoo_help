# Set up the virtual environment
# 
# Accepts as input:
# 1. The parent directory of the odoo source code
#      The community code should be in the 'odoo' subfolder
#      The enterprise code should be in the 'enterprise' subfolder
# 2. The directory of the project of interest
# 

# This should be relative to the project's directory
odoo_dir="$1"
odoo_community_dir="$odoo_dir/13.0/odoo/"
odoo_enterprise_dir="$odoo_dir/13.0/enterprise/"

project_python_command="python3.7"
project_dir="$2"

# Find all the requirements.txt files
declare -a requirement_files_dirs
readarray -d '' requirement_files_dirs < <(find "$odoo_community_dir" "$odoo_enterprise_dir" "$project_dir" -type f -name "requirements.txt" -print0)

# Create the .venv folder in the project's base dir
echo -n "[INFO] Creating $project_python_command virtual environment "
eval  "cd \"$project_dir\" && $project_python_command -m venv .venv"
echo "[DONE]"

echo "[SETUP] Activating virtual environment and upgrading pip"
eval "source \"$project_dir.venv/bin/activate\""
# eval "pip install pip --upgrade"# It is not always a good thing
echo "[DONE]"

echo "[INFO] Started Installing requirements: "
for requirement_file in "${requirement_files_dirs[@]}"
do
    echo "[INSTALL] Installing from $requirement_file"
    eval "pip install -r $requirement_file"
    exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "[ERROR] The pip installation encountered an error"
        break
    fi
done


echo "[DONE]"
