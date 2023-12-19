if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed."
    sudo apt update
    sudo apt install python3 -y
fi

if ! command -v pip &> /dev/null; then
    echo "pip is not installed."
    sudo apt install python3-pip -y
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
