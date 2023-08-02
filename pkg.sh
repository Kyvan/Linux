#!/bin/bash -u

# variables neede dof the script to work
version=/proc/version
green='\033[1;32m'
brown='\033[1;33m'
cyan='\033[1;36m'
blue='\033[1;34m'
NC='\033[0m' # No Color

function pkg_update() {
    echo -e "${blue}Checking and installing updates...${NC}"
    sudo "${pkg}" update
    echo -e "${green}Checking and installing updates done...${NC}"
}

function pkg_update_deb() {
    echo -e "${blue}Checking for updates...${NC}"
    sudo "${pkg}" update
    echo -e "${brown}installing updates...${NC}"
    sudo "${pkg}" upgrade
    echo -e "${green}installing updates done...${NC}"
}

function pkg_install() {
    echo -e "${blue}Installing new packages...${NC}"
    sudo "${pkg}" "${1}" "${2}"
    echo -e "${green}Installing new packages done...${NC}"
}

function input_check() {
    if [[ "${1}" == "install" || "${1}" == "remove" ]] ; then
        state="${1}"
        package="${2}"
        pkg_install "${state}" "${package}"
    elif [[ "${2}" == "install" || "${2}" == "remove" ]] ; then
        state="${2}"
        package="${1}"
        pkg_install "${state}" "${package}"
    else
        echo "ERROR: One of the arguments passed needs to be \"install\" or \"remove\"."
        exit 1
    fi
}

function distro_check() {
    # If statement to check which distro is used
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null; then
        if sudo apt list --installed nala | grep -i installed ; then
            pkg="nala"
        else
            echo -e "${cyan}Installing nala since it is better than apt${NC}"
            sudo apt install -y nala
            pkg="nala"
        fi
    elif grep -iE '(red hat)' "${version}" > /dev/null ; then
        pkg="dnf"
    elif grep -iE '(suse)' "${version}" > /dev/null ; then
        pkg="zypper"
    else
        echo "Why you being difficult?"
        echo "Do your shit manually."
    fi
}

# checking for Flatpak
function flatpakCheck() {
    echo -e "${blue}would you like to check for flatpack udpates? (YES/Y/no/n)${NC} -- ${cyan}Default is YES${NC}"
    read -r flatAnswer 
    case "${flatAnswer,,}" in
        y | yes | '')
            flatpak update
            ;;
        n | no)
            exit 0
            ;;
        *)
            echo "Please answer with either \"Y\", \"YES\", \"NO\",  and \"N\"!!!!!!"
            flatpakCheck
            ;;
    esac
}

distro_check

if [[ $# -eq 0 ]] ; then
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null ; then
        pkg_update_deb
    else
        pkg_update
    fi
elif [[ $# -eq 2 ]] ; then
    input_check "${1}" "${2}"
else
    echo "ERROR: You need either zero or two option for the script."
    echo "USAGE: $0 [argument]"
    exit 1
fi

flatpakCheck