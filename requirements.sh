#!/bin/sh
xcode-select --install
sudo xcodebuild -license
sudo softwareupdate --install-rosetta --agree-to-license

# Define the Homebrew path line
homebrew_path_line='export PATH="/opt/homebrew/bin:$PATH"'

# Check if Homebrew is in the PATH
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -eq 0 ]; then
    echo "Homebrew installed successfully."
  else
    echo "Homebrew installation failed."
    exit 1
  fi
else
  echo "Homebrew is already installed."
fi

# Add Homebrew path to .zshrc if it doesn't already exist
if ! grep -Fxq "$homebrew_path_line" "$HOME/.zshrc"; then
  echo "$homebrew_path_line" >> "$HOME/.zshrc"
  echo "Homebrew path added to .zshrc."
else
  echo "Homebrew path already exists in .zshrc."
fi

# Reload .zshrc to ensure Homebrew is available in the session
source ~/.zshrc

# Find the Python 3 binary path
python_path=$(which python3)

# Check if Python 3 is installed
if [ -z "$python_path" ]; then
  echo "Python 3 is not installed or not found in PATH."
  exit 1
fi

# Extract the Python version directory for site-packages (e.g., 3.9)
python_version=$($python_path -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')

# Define the Python path line
python_path_line="export PATH=\"\$HOME/Library/Python/$python_version/bin:\$PATH\""

# Add Python path to .zshrc if it doesn't already exist
if ! grep -Fxq "$python_path_line" "$HOME/.zshrc"; then
  echo "$python_path_line" >> "$HOME/.zshrc"
  echo "Python path added to .zshrc for Python $python_version."
else
  echo "Python path already exists in .zshrc for Python $python_version."
fi

# Reload .zshrc to ensure the new Python path is active
source ~/.zshrc

# Define the pip command based on the detected Python version
pip_command="$python_path -m pip"

# Upgrade pip for the detected Python version
echo "Upgrading pip for Python $python_version..."
$pip_command install --upgrade pip

# Install Ansible using the upgraded pip
echo "Installing Ansible..."
$pip_command install ansible
