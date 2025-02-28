#!/bin/bash

# Get parameters from environment variables
USER_NAME=${USER_NAME}
USER_PASSWORD=${USER_PASSWORD}
SSH_PUB=${SSH_PUB}
GIT_NAME=${GIT_NAME}
GIT_EMAIL=${GIT_EMAIL}
APT_PACKAGES=${APT_PACKAGES}
PYTHON_PACKAGES=${PYTHON_PACKAGES}

# Check if required environment variables are set
if [ -z "${USER_NAME}" ]; then
    echo "Error: USER_NAME is required."
    exit 1
fi

if [ -z "${USER_PASSWORD}" ]; then
    echo "Error: USER_PASSWORD is required."
    exit 1
fi

if [ -z "${GIT_NAME}" ]; then
    echo "Error: GIT_NAME is required."
    exit 1
fi

if [ -z "${GIT_EMAIL}" ]; then
    echo "Error: GIT_EMAIL is required."
    exit 1
fi

# Create new user and set password
useradd -m -s /bin/bash ${USER_NAME}
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd

# Add user to sudo group
usermod -aG sudo ${USER_NAME}

# Create .ssh directory and set permissions
mkdir -p /home/${USER_NAME}/.ssh
echo "${SSH_PUB}" >> /home/${USER_NAME}/.ssh/authorized_keys
chmod 600 /home/${USER_NAME}/.ssh/authorized_keys
chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/.ssh


# Configure git
sudo -u ${USER_NAME} git config --global user.name "${GIT_NAME}"
sudo -u ${USER_NAME} git config --global user.email "${GIT_EMAIL}"

# Install APT packages
if [ -n "${APT_PACKAGES}" ]; then
    echo "Installing APT packages: ${APT_PACKAGES}"
    sudo -u ${USER_NAME} bash -c "sudo apt-get update && sudo apt-get install -y ${APT_PACKAGES}"
fi

# Install Python modules
if [ -n "${PYTHON_PACKAGES}" ]; then
    echo "Installing Python packages: ${PYTHON_PACKAGES}"
    sudo -u ${USER_NAME} bash -c "pip install ${PYTHON_PACKAGES}"
fi

# Start SSH service
exec /usr/sbin/sshd -D