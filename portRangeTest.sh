#!/bin/bash -u

# variables neede dof the script to work
red='\033[1;91m'
NC='\033[0m' # No Color

read -rp "What is the port number? " port
read -rp "How many ports in a row do you need openned? " portRange

function applicationCreation() {
    for (( portNum = 0 ; portNum <= "${2}" ; portNum++ )) ; do
        newPort=$(("${1}" + "$portNum"))
        echo set applications application "${3^^}"-"${newPort}" protocol "${3}" destination-port "${newPort}"
        #echo ${newPort}
    done
}

function doubleApplicationCreation() {
    for proto in "${@}" ; do
        applicationCreation "${port}" "${portRange}" "${proto,,}"
    done
}

function protocolCheck() {
    read -rp "Is this a TCP or a UDP protocol? (TCP/UDP/Both) " protoType
    case "${protoType,,}" in
        tcp | udp)
            applicationCreation "${port}" "${portRange}" "${protoType,,}"
            ;;
        both)
            doubleApplicationCreation tcp udp
            ;;
        *)
            echo -e "${red}You have to choose one of the provided options!!!${NC}"
            protocolCheck
    esac
}

protocolCheck