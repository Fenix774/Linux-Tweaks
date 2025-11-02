#!/bin/bash

# Made with https://nattdf.streamlit.app/
# Not Another 'Things To Do'! - Initial System Setup Shell Script Builder for Fedora Workstation


# System Upgrade
color_echo "blue" "Performing system upgrade... This may take a while..."
dnf upgrade -y


# Customization
# Install Google fonts collection
color_echo "yellow" "Installing Google Fonts..."
wget -O /tmp/google-fonts.zip https://github.com/google/fonts/archive/main.zip
mkdir -p $ACTUAL_HOME/.local/share/fonts/google
unzip /tmp/google-fonts.zip -d $ACTUAL_HOME/.local/share/fonts/google
rm -f /tmp/google-fonts.zip
fc-cache -fv
color_echo "green" "Google Fonts installed successfully."


# Custom Script
# Custom user-defined commands
echo "Created with ❤️ for Open Source"
