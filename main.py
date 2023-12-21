import requests
import logging
import json
import paramiko
from config import *

# Configure logging
logging.basicConfig(level=logging.INFO)

# Create a reusable session
session = requests.Session()

def get_access_token(username, password):
    use_protocol = 'https' if HTTPS else 'http'
    url = f'{use_protocol}://{DOMAIN}:{PORT}/api/admin/token'
    data = {
        'username': username,
        'password': password
    }

    try:
        response = session.post(url, data=data)
        response.raise_for_status()
        access_token = response.json()['access_token']
        logging.info(".:Logged in Successfully:.")
        return access_token
    except requests.exceptions.RequestException as e:
        logging.error(f'Error occurred while obtaining access token: {e}')
        return None

def get_cert(access_token):
    use_protocol = 'https' if HTTPS else 'http'
    url = f'{use_protocol}://{DOMAIN}:{PORT}/api/node/settings'
    headers = {
        'accept': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    try:
        response = session.get(url, headers=headers)
        response.raise_for_status()
        cert = response.json()
        return cert["certificate"]
    except requests.exceptions.RequestException as e:
        logging.error(f'Error occurred while retrieving certificate: {e}')
        return None
    
def add_node(access_token, server_ip):
    use_protocol = 'https' if HTTPS else 'http'
    url = f'{use_protocol}://{DOMAIN}:{PORT}/api/node'
    node_information = {
        "name": f"{server_ip} - github.com/itsAML",
        "address": f"{server_ip}",
        "port": 62050,
        "api_port": 62051,
        "add_as_new_host": True if ADD_AS_HOST else False,
        "usage_coefficient": 1
    }
    node_json_information = json.dumps(node_information)
    headers = {
        'accept': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    try:
        response = session.post(url, node_json_information, headers=headers)
        response.raise_for_status()
        return print("Node Added Successfully")
    except requests.exceptions.RequestException as e:
        logging.error(f'Error occurred while adding node: {e}')
        return None

# Certificate information
access_token = get_access_token(USERNAME, PASSWORD)
cert_info = get_cert(access_token)


# Commands to execute
commands = [
    'sudo ufw disable',
    'curl -fsSL https://get.docker.com | sh',
    '[ -d Marzban-node ] && rm -r Marzban-node',
    'git clone https://github.com/Gozargah/Marzban-node',
    'cd Marzban-node && docker compose up -d && docker compose down && rm docker-compose.yml',
    f'sudo echo "{cert_info}" > /var/lib/marzban-node/ssl_client_cert.pem',
    'cd Marzban-node && sudo echo \'services:\n  marzban-node:\n    image: gozargah/marzban-node:latest\n    restart: always\n    network_mode: host\n    environment:\n      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"\n      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"\n      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"\n    volumes:\n      - /var/lib/marzban-node:/var/lib/marzban-node\' > docker-compose.yml && docker compose up -d'
]

# Establish SSH connection
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    client.connect(SERVER_IP, port=SERVER_PORT, username=SERVER_USER, password=SERVER_PASSWORD, timeout=4)

    # Execute commands
    for command in commands:
        stdin, stdout, stderr = client.exec_command(command)
        exit_status = stdout.channel.recv_exit_status()
        if exit_status == 0:
            print(f"Command '{command}' executed successfully.")
        else:
            print(f"Command '{command}' failed with exit status {exit_status}.")
finally:
    client.close()

try:
    print("Adding Node To The Panel:")
    add_node(access_token, SERVER_IP)
except Exception as e:
    pass

# github.com/itsAML
# @YoAML in Telegram
