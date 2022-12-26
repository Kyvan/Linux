#!/bin/bash -u

function add() {
    sum=$(awk "BEGIN {print $1 + $2; exit}")
    echo -e "\e[34mresults is: \e[0m$sum"
}

function subtract() {
    sum=$(awk "BEGIN {print $1 - $2; exit}")
    echo -e "\e[31mresults is: \e[0m$sum"
}

function numberChecker() {
    echo "$1" | grep -E "^\-?[0-9]+\.?[0-9]*$"
}

function menu1() {
    echo -e "   \e[1mMenu 1"
    echo -e "\e[0mC) Calculation"
    echo -e "\e[0mX) Exit"
    read -rp "What option would you like to choose?$(echo -e '\n> ')" menu1Option
    echo "You chose: $menu1Option"
    sleep 3
    clear
    case ${menu1Option,,} in
        c)
            menu2
            ;;
        x)
            exit 
            ;;
        *)
            echo "Invalid input. Please enter option from menu"
            menu2
            ;;
        esac
}

function menu2() {
    echo -e "   \e[1mMenu 2"
    echo -e "\e[0mX) Exit"
    read -rp "What's the first number?$(echo -e '\n> ' )" menu2Option
    echo "You chose: $menu2Option"
    sleep 3
    clear
    if [[ ${menu2Option^^} == "X" ]] ; then
            exit
    elif  [[ "$(numberChecker $menu2Option)" != '' ]] ; then
        menu3
    else
        echo "Invalid input. Please enter option from menu" ; menu2
    fi
}

function menu3() {
    echo -e "   \e[1mMenu 3"
    echo -e "\e[0m+) Add"
    echo -e "\e[0m-) Subtract"
    echo -e "\e[0mX) Exit"
    read -rp "What option would you like to choose?$(echo -e '\n> ')" menu3Option
    echo "You chose: $menu3Option"
    sleep 3
    clear
    case $menu3Option in
        x | X)
            exit
            ;;
        + | -)
            menu4
            ;;
        *)
            echo "Invalid input. Please enter option from menu" ; menu3
    esac
}

function menu4() {
    echo -e "   \e[1mMenu 4"
    echo -e "\e[0mX) Exit"
    read -rp "What's the second number?$(echo -e '\n> ' )" menu4Option
    echo "You chose: $menu4Option"
    sleep 3
    clear
    if [[ ${menu2Option,,} == "x" ]] ; then
            exit
    elif [[ "$(numberChecker $menu4Option)" != '' ]] ; then
        if [[ "$menu3Option" == "+" ]] ; then
            add "$menu2Option" "$menu4Option"
        else
            subtract "$menu2Option" "$menu4Option"
        fi
    else
        echo "Invalid input. Please enter option from menu" ; menu4
    fi
}

if [[ $# -eq 3 ]] ; then
    if [[ $2 == "+" ]] ; then
        clear ; add $1 $3
    elif [[ $2 == "-" ]] ; then
        clear ; subtract $1 $3
    else
        clear ; echo "Wrong option provided" ; exit 1
    fi
elif [[ $# -eq 0 ]] ; then
    clear ; menu1
else
    clear ; echo "You need either no options or three"
    echo "Please run the script again with the correct number of options"
fi