#!/bin/bash -u

# variables neede dof the script to work
version=/proc/version
red='\033[1;91m'
green='\033[1;92m'
yellow='\033[1;93m'
blue='\033[1;94m'
cyan='\033[1;96m'
NC='\033[0m' # No Color

function pkg_update() {
    echo -e "${blue}Checking and installing updates...${NC}"
    echo -e "${cyan}${pkg} update${NC}"
    sudo "${pkg}" update
    echo -e "${green}Checking and installing updates done...${NC}"
}

function pkg_update_deb() {
    echo -e "${blue}Checking for updates...${NC}"
    echo -e "${cyan}${pkg} update${NC}"
    sudo "${pkg}" update
    echo -e "${yellow}installing updates...${NC}"
    echo -e "${cyan}${pkg} upgrade${NC}"
    sudo "${pkg}" upgrade
    echo -e "${green}installing updates done...${NC}"
}

function pkg_manager() {
    echo -e "${blue}Installing new packages...${NC}"
    echo -e "${cyan}${pkg} ${@}${NC}"
    sudo "${pkg}" "${@}"
    echo -e "${green}Installing new packages done...${NC}"
    exit 0
}

function pkg_update_arch() {
    echo -e "${blue}Installing new packages...${NC}"
    echo -e "${cyan}${pkg} -Syyu${NC}"
    sudo "${pkg}" -Syyu
    echo -e "${green}Installing new packages done...${NC}"
    exit 0
    }

function distpkg_manager() {
    echo -e "${blue}Installing new packages...${NC}"
    echo -e "${cyan}${distpkg} ${@}${NC}"
    sudo "${distpkg}" "${@}"
    echo -e "${green}Installing new packages done...${NC}"
    exit 0
}

function input_check() {
    case "${1,,}" in
        install | remove)
            pkg_manager "${@}"
            ;;
        autoremove)
            pkg_manager "${1}"
            ;;
        --install | --remove)
            package_check $(echo "${2}" | grep -Eoi '(rpm|deb)$')
            distpkg_manager "${@}"
            ;;
        *)
            echo -e "${red}ERROR: First argument needs to be \"autoremove\", \"install\", or \"remove\"!!!${NC}"
            exit 2
    esac
}

function input_check_arch() {
    case "${1,,}" in
        install)
            echo -e "${cyan}${pkg} -Syy ${@:2}${NC}"
            sudo "${pkg}" -Syy "${@:2}"
            ;;
        remove)
            echo -e "${cyan}${pkg} -R ${@:2}${NC}"
            sudo "${pkg}" -R "${@:2}"
            ;;
        search)
            echo -e "${cyan}${pkg} -Q ${@:2}${NC}"
            sudo "${pkg}" -Q "${@:2}"
            ;;
        update)
            echo -e "${yellow}WARNING: Update doesn't take any arquments!!${NC}"
            echo -e "${green}We have remove the arquments and will run the updates instead${NC}"
            sudo "${pkg}" -Syyu
            ;;
        *)
            echo -e "${red}ERROR: First argument needs to be \"autoremove\", \"install\", or \"remove\"!!!${NC}"
            exit 2
    esac
}

function package_check() {
    case "${1,,}" in
        rpm)
            distpkg="rpm"
            ;;
        deb)
            distpkg="dpkg"
            ;;
        *)
            echo -e "${red}ERROR: For single arguemnts, you need an RPM or a DEB package!!!${NC}"
            exit 2
    esac
}

function distro_check() {
    # If statement to check which distro is used
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null ; then
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
    elif grep -iE '(archlinux)' "${version}" > /dev/null ; then
        pkg="pacman"
    else
        echo "Why you being difficult?"
        echo "Do your shit manually."
        exit 0
    fi
}

distro_check

if [[ $# -eq 0 ]] ; then
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null ; then
        pkg_update_deb
    elif grep -iE '(archlinux)' "${version}" > /dev/null ; then
        pkg_update_arch
    else
        pkg_update
    fi
elif [[ $# -eq 1 ]] ; then
    if grep -iE '(archlinux)' "${version}" > /dev/null ; then
        echo "ERROR: You can't run this script with one argument on Arch based Distros"
        echo "USAGE: $0 [option] [argument]"
        exit 1
    elif [[ "${1,,}" -eq "autoremove" ]] ; then
        sudo "${pkg}" "${1,,}"
    fi
elif [[ $# -ge 2 ]] ; then
    if grep -iE '(archlinux)' "${version}" > /dev/null ; then
        input_check_arch "${@}"
    else
        input_check "${@}"
    fi
else
    echo "ERROR: You need either zero, or two or more option for the script."
    echo "USAGE: $0 [option] [argument]+"
    exit 1
fi

# checking for Flatpak
function flatpakCheck() {
    echo -e "${blue}would you like to check for flatpack udpates? (Yes/No)${NC} -- ${cyan}Default is YES${NC}"
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