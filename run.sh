#!/bin/bash

if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed."
    sudo apt update
    sudo apt install python3 -y
fi

if ! command -v pip &> /dev/null; then
    echo "pip is not installed."
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
install_library_apt() {
    local package_name="python3-$1"
    sudo apt install "$package_name" -y
}

required_libraries=("paramiko==3.3.1" "requests==2.31.0")

for lib in "${required_libraries[@]}"; do
    # Split the string to get the library name for checking
    lib_name=$(echo "$lib" | cut -d '=' -f 1)
    
    if ! check_library "$lib_name"; then
        sudo pip install "$lib" || install_library_apt "$lib_name"
    else
        echo "$lib is already installed."
    fi
done

# Saving Script into > curlscript.py
curl -sSL https://raw.githubusercontent.com/ItsAML/MarzbanEZNode/main/curlscript.py > curlscript.py
# Running previously saved script
python3 curlscript.py
# (OPTIONAL) removing script
rm curlscript.py