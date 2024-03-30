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
    echo -e "${green}Finished installing new packages...${NC}"
    exit 0
}

function pkg_update_arch() {
    echo -e "${blue}Installing new packages...${NC}"
    echo -e "${cyan}${pkg} -Syyu${NC}"
    sudo "${pkg}" -Syyu
    echo -e "${green}Finished installing new packages...${NC}"
    exit 0
    }

function distpkg_manager() {
    echo -e "${blue}Installing new packages...${NC}"
    echo -e "${cyan}${distpkg} ${@}${NC}"
    sudo "${distpkg}" "${@}"
    echo -e "${green}Finished installing new packages...${NC}"
    exit 0
}

function input_check() {
    case "${1,,}" in
        install | remove)
            if package_check $(echo "${2}" | grep -Eoi '(rpm|deb)$') ; then
                distpkg_manager "${@}"
            else
                pkg_manager "${@}"
            fi
            ;;
        autoremove)
            echo -e "${yellow}WARNING: autoremove doesn't take any arquments!!${NC}"
            echo -e "${green}We have remove the arquments and will run autoremove anyways.${NC}"
            pkg_manager "${1}"
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
            exit 0
            ;;
        remove)
            echo -e "${cyan}${pkg} -R ${@:2}${NC}"
            sudo "${pkg}" -R "${@:2}"
            exit 0
            ;;
        search)
            echo -e "${cyan}${pkg} -Q ${@:2}${NC}"
            sudo "${pkg}" -Q "${@:2}"
            exit 0
            ;;
        update)
            echo -e "${yellow}WARNING: Update doesn't take any arquments!!${NC}"
            echo -e "${green}We have remove the arquments and will run the updates anyways.${NC}"
            sudo "${pkg}" -Syyu
            exit 0
            ;;
        *)
            echo -e "${red}ERROR: First argument needs to be \"search\", \"install\", or \"remove\"!!!${NC}"
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
    esac
}

function distro_check() {
    # If statement to check which distro is used
    if grep -iE '(debian|ubuntu)' "${version}" > /dev/null ; then
        if sudo apt list --installed nala 2> /dev/null | grep -i installed > /dev/null ; then
            pkg="nala"
        else
            echo -e "${cyan}Installing nala since it is better than apt.${NC}"
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

function pkg_options() {
    echo -e "Valid options are\n1. install\n2. remove\n3. autoremove."
    echo -e "For Install and Remove, you need to add package names as well"
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
        echo -e "${red}ERROR: You can't run this script with one argument on Arch based Distros.${NC}"
        echo -e "${green}USAGE: $0 [option] [argument]${NC}"
        exit 1
    elif [[ "${1,,}" -eq "autoremove" ]] ; then
        sudo "${pkg}" "${1,,}"
    else
        echo -e "${red}ERROR: Not a valid option!!${NC}"
        pkg_options
    fi
elif [[ $# -ge 2 ]] ; then
    if grep -iE '(archlinux)' "${version}" > /dev/null ; then
        input_check_arch "${@}"
    else
        input_check "${@}"
    fi
else
    echo -e "${red}ERROR: You need either zero, or two or more option for the script.${NC}"
    echo -e "${green}USAGE: $0 [option] [argument]{$NC}"
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
