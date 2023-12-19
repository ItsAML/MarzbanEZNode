if command -v apt &> /dev/null; then
    if ! command -v python3 &> /dev/null; then
        echo "Python3 is not installed."
        sudo apt-get update
        sudo apt-get install python3
    fi
    
    if ! command -v pip &> /dev/null; then
        echo "pip is not installed."
        sudo apt-get install python3-pip
    fi
elif command -v yum &> /dev/null; then
    if ! command -v python3 &> /dev/null; then
        echo "Python3 is not installed."
        sudo yum install python3
    fi
    
    if ! command -v pip &> /dev/null; then
        echo "pip is not installed."
        sudo yum install python3-pip
    fi
else
    echo "Your package manager is not supported. Please install Python3 or Pip manually."
    # Instructions for manual installation
fi

required_libraries=("requests" "paramiko")

for lib in "${required_libraries[@]}"; do
    if ! python3 -c "import $lib" &> /dev/null; then
        echo "$lib is not installed."
        # Install the missing library using pip
        sudo pip install "$lib"
    fi
done

curl -sSL https://raw.githubusercontent.com/ItsAML/MarzbanEZNode/main/curlscript.py | python3 -