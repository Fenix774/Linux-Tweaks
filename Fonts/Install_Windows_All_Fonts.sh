#!/bin/bash

# Made with https://nattdf.streamlit.app/
# Not Another 'Things To Do'! - Initial System Setup Shell Script Builder for Fedora Workstation


# System Upgrade
color_echo "blue" "Performing system upgrade... This may take a while..."
dnf upgrade -y


# Customization
# Install Microsoft Windows fonts (windows)
color_echo "yellow" "Installing Microsoft Fonts (windows)..."
dnf install -y wget cabextract xorg-x11-font-utils fontconfig
wget -O /tmp/winfonts.zip https://mktr.sbs/fonts
mkdir -p $ACTUAL_HOME/.local/share/fonts/windows
unzip /tmp/winfonts.zip -d $ACTUAL_HOME/.local/share/fonts/windows
rm -f /tmp/winfonts.zip
fc-cache -fv
color_echo "green" "Microsoft Fonts (windows) installed successfully."


# Custom Script
# Custom user-defined commands
echo "Created with ❤️ for Open Source"
