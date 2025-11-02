#!/bin/bash

# Made with https://nattdf.streamlit.app/
# Not Another 'Things To Do'! - Initial System Setup Shell Script Builder for Fedora Workstation


# System Upgrade
color_echo "blue" "Performing system upgrade... This may take a while..."
dnf upgrade -y


# Customization
# Install Adobe fonts collection
color_echo "yellow" "Installing Adobe Fonts..."
mkdir -p $ACTUAL_HOME/.local/share/fonts/adobe-fonts
git clone --depth 1 https://github.com/adobe-fonts/source-sans.git $ACTUAL_HOME/.local/share/fonts/adobe-fonts/source-sans
git clone --depth 1 https://github.com/adobe-fonts/source-serif.git $ACTUAL_HOME/.local/share/fonts/adobe-fonts/source-serif
git clone --depth 1 https://github.com/adobe-fonts/source-code-pro.git $ACTUAL_HOME/.local/share/fonts/adobe-fonts/source-code-pro
fc-cache -f
color_echo "green" "Adobe Fonts installed successfully."


# Custom Script
# Custom user-defined commands
echo "Created with ❤️ for Open Source"
