#!/bin/bash

# Made with https://nattdf.streamlit.app/
# Not Another 'Things To Do'! - Initial System Setup Shell Script Builder for Fedora Workstation


# System Upgrade
color_echo "blue" "Performing system upgrade... This may take a while..."
dnf upgrade -y


# Customization
# Install Microsoft Windows fonts (core)
color_echo "yellow" "Installing Microsoft Fonts (core)..."
dnf install -y curl cabextract xorg-x11-font-utils fontconfig
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
color_echo "green" "Microsoft Fonts (core) installed successfully."


# Custom Script
# Custom user-defined commands
echo "Created with ❤️ for Open Source"
