#!/bin/bash

# Check and install Python 3 if not installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Installing..."
    sudo apt update
    sudo apt install python3 -y
fi

# Check and install pip if not installed
if ! command -v pip &> /dev/null; then
    echo "pip is not installed. Installing..."
    sudo apt install python3-pip -y || {
        echo "Installing pip via alternative method..."
        wget -qO- https://bootstrap.pypa.io/get-pip.py | sudo python3 -
    }
fi

# Function to check if a Python library is installed
check_library() {
    python3 -c "import $1" &> /dev/null
}

# Function to install library using apt if pip install fails
install_library() {
    local package_name="python3-$1"
    echo "Installing $1..."
    sudo apt install "$package_name" -y || sudo pip install "$1"
}

# Function to upgrade library using pip if upgrade fails
upgrade_library() {
    echo "Upgrading $1..."
    sudo pip install --upgrade "$1" || sudo apt install "python3-$1" -y
}

# List of required Python libraries
required_libraries=("paramiko" "requests")

# Loop through libraries and install or upgrade
for lib in "${required_libraries[@]}"; do
    if ! check_library "$lib"; then
        install_library "$lib"
    else
        echo "$lib is already installed."
    fi
done

# Upgrade specific libraries with fallback
upgrade_library "requests"
upgrade_library "urllib3"

# Download and run Python script from remote repository
curl -sSL https://raw.githubusercontent.com/ItsAML/MarzbanEZNode/main/curlscript.py > curlscript.py
python3 curlscript.py

# (OPTIONAL) Remove downloaded script
rm curlscript.py
