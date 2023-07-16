#!/bin/bash -u

# variables neede dof the script to work
version=/proc/version
green='\033[1;32m'
brown='\033[1;33m'
blue='\033[1;34m'
NC='\033[0m' # No Color

function debian_update() {
    echo -e "${blue}Checking updates...${NC}"
    sudo apt update
    echo -e "${green}Checking for updates done...${NC}"
    echo -e "${brown}Installing updates (if applicable)...${NC}"
    sudo apt upgrade
    echo -e "${green}Installing updates done...${NC}"
}

function rhel_update() {
    echo -e "${blue}Checking and installing updates...${NC}"
    sudo dnf update
    echo -e "${green}Checking and installing updates done...${NC}"
}

function suse_update() {
    echo -e "${blue}Checking and installing updates...${NC}"
    sudo zypper update
    echo -e "${green}Checking and installing updates done...${NC}"
}

function debian_install() {
    sudo apt "${state}" "${package}"
}

function rhel_install() {
    sudo dnf "${state}" "${package}"
}

function suse_install() {
    sudo zypper "${state}" "${package}"
}

function distro_check() {
    # If statement to check which distro is used
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null; then
        debian_update
    elif grep -iE '(red had)' "${version}" > /dev/null ; then
        rhel_update
    elif grep -iE '(suse)' "${version}" > /dev/null ; then
        suse_update
    else
        echo "Why you being difficult?"
        echo "Do your shit manually"
    fi
}

function input_check() {
    if [[ "${1}" == "install" || "${1}" == "remove" ]] ; then
        state="${1}"
        package="${2}"
        debian_install "${state}" "${package}"
    elif [[ "${2}" == "install" || "${2}" == "remove" ]] ; then
        state="${2}"
        package="${1}"
        debian_install "${state}" "${package}"
    else
        echo "One of the arguments passed needs to be \"install\" or \"remove\""
        exit 1
    fi
}

if [[ $# -eq 0 ]] ; then
    distro_check
elif [[ $# -eq 2 ]] ; then
    input_check "${1}" "${2}"
else
    echo "You need either 0 arguments, or 2 and more"
    exit 1
fi
