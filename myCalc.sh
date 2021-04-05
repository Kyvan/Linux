#!/bin/bash -u

menu2Option=' '
menu3Option=' '

function add() {
    echo -e "\e[34mresults is: \e[1m$(($1 + $2))"
}

function subtract() {
    echo -e "\e[31mresults is: \e[1m$(($1 - $2))"
}

function menu1() {
    echo -e "   \e[1mMenu 1"
    echo -e "\e[0mC) Calculation"
    echo -e "\e[0mX) Exit"
    read -r menu1Option
    menuChecker $menu1Option
}

function menu2() {
    echo -e "   \e[1mMenu 2"
    echo -e "\e[0mX) Exit"
    read -rp "What's the first number?$(echo -e '\n> ')" menu2Option
    menuChecker $menu2Option
}

function menu3() {
    echo -e "   \e[1mMenu 3"
    echo -e "\e[0m+) Add"
    echo -e "\e[0m-) Subtract"
    echo -e "\e[0mX) Exit"
    read -r menu3Option
    menuChecker $menu3Option
}

function menuChecker() {
    case $1 in
        c | C)
            if [[ "$1" == "$menu2Option" ]] ; then
                sleep 3
                clear
                echo "Wrong option, please choose again"
                menu2
            elif [[ "$1" == "$menu3Option" ]] ; then
                sleep 3
                clear
                echo "Wrong option, please choose again"
                menu3
            else
                sleep 3
                clear
                menu2
            fi
            ;;
        x | X)
            sleep 3
            clear
            exit
            ;;
        + | -)
            sleep 3
            clear
            read -rp "What's the second number$(echo -e '\n> ')" secondNumber
            while [[ ! "$secondNumber" == [0-9]* ]] ; do
                if [[ "{$secondNumber,,}" == "x" ]] ; then
                    exit
                fi
                sleep 3
                clear
                echo "Wrong option, please choose again"
                echo -e "\e[0mX) Exit"
                read -rp "What's the second number?$(echo -e '\n> ')" secondNumber
            done
            sleep 3
            clear
            if [[ "$1" == "+" ]] ; then
                add $menu2Option $secondNumber
            else
                subtract $menu2Option $secondNumber
            fi    
        ;;
        [[:digit:]]*)
            sleep 3
            clear
            if [[ $1 == $menu1Option ]] ; then
                echo "Wrong option, please choose again"
                menu1
            elif [[ "$1" == "$menu3Option" ]] ; then
                echo "Wrong option, please choose again"
                menu3
            else
                menu3
            fi
        ;;
        *)
            sleep 3
            clear
            echo "Invalid input. Please enter option from menu"
            if [[ "$1" == "$menu1Option" ]] ; then 
                menu1
            elif [[ "$1" == "$menu2Option" ]] ; then
                menu2
            else
                menu3
                fi
        ;;
    esac
}

if [[ $# -eq 3 ]] ; then
    if [[ $2 == "+" ]] ; then
        clear
        add $1 $3
    elif [[ $2 == "-" ]] ; then
        clear
        subtract $1 $3
    else
        clear
        echo "Wrong option provided"
        exit 1
    fi
elif [[ $# -eq 0 ]] ; then
    clear
    menu1
else
    clear
    echo "You need either no options or three"
    echo "Please run the script again with the correct number of options"
fi