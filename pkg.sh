#!/bin/bash -u

# variables neede dof the script to work
version=/proc/version
red='\033[1;91m'
green='\033[1;92m'
yellow='\033[1;93m'
blue='\033[1;94m'
cyan='\033[1;96m'
NC='\033[0m' # No Color

# function pkg_autoremove() {
#     echo -e "${blue}Removing unused packages...${NC}"
#     sudo "${pkg}" "${1}"
#     echo -e "${green}Removing unused packages done...${NC}"
#     exit 0
# }

function pkg_update() {
    echo -e "${blue}Checking and installing updates...${NC}"
    sudo "${pkg}" update
    echo -e "${green}Checking and installing updates done...${NC}"
}

function pkg_update_deb() {
    echo -e "${blue}Checking for updates...${NC}"
    sudo "${pkg}" update
    echo -e "${yellow}installing updates...${NC}"
    sudo "${pkg}" upgrade
    echo -e "${green}installing updates done...${NC}"
}

function pkg_manager() {
    echo -e "${blue}Installing new packages...${NC}"
    sudo "${pkg}" "${@}"
    echo -e "${green}Installing new packages done...${NC}"
    exit 0
}

function input_check() {
    case "${1,,}" in
        autoremove | install | remove)
            pkg_manager "${@}"
            ;;
        *)
            echo -e "${red}ERROR: First argument needs to be \"autoremove\", \"install\", or \"remove\"!!!${NC}"
            exit 2
    esac
}

function distro_check() {
    # If statement to check which distro is used
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null; then
        if sudo apt list --installed nala 2> /dev/null | grep -i installed > /dev/null ; then
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

distro_check

if [[ $# -eq 0 ]] ; then
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null; then
        pkg_update_deb
    else
        pkg_update
    fi
elif [[ $# -ge 1 ]] ; then
    input_check "${@}"
# elif [[ $# -ge 2 ]] ; then
#     input_check "${@}"
    ## Loop to go through all arguments and assign it to a different variable
    ## Thanks ChatGPT
    # i=1
    # for arg in "$@" ; do
    #     declare "arg${i}"="${arg}"
    #     echo "${i} ${arg}"
    #     ((i++))
    # done
else
    echo "ERROR: You need either zero or two option for the script."
    echo "USAGE: $0 [argument]"
    exit 1
fi

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

flatpakCheck