#!/bin/bash

#This script performs matematical operations on sequence of numbers
#Usage: ./2_operations.sh -o (*,%,+,-) -n num1 num2 num3,... -d
#-o - is for operation (*,%,+,-)
#-n - is for list of numbers
#-d - enables debug output

debug=false
operation=""
numbers=()

while getopts "o:n:d" opt; do 
    case "$opt" in
        o)
            operation="$OPTARG"
        ;;
        n)
            numbers+=("$OPTARG")

            while [[ $OPTIND -le $# ]]; do
                arg="${!OPTIND}"

                if [[ "$arg" == -* ]]; then
                    break
                fi

                numbers+=("$arg")
                ((OPTIND++))
            done
        ;;
        d)
            debug=true
        ;;
        *)
             echo "Unknown option: $1"
            exit 1
        ;;
     esac
done


if [[ -z "$operation" ]]; then
    echo "Please provide an operation"
    exit 1
fi

if [[ "${#numbers[@]}" -lt 2 ]]; then
    echo "Please provide at least 2 numbers"
    exit 1
fi

result="${numbers[0]}"

for ((i=1; i<${#numbers[@]}; i++));do
    case "$operation" in
    +)
        result=$((result + numbers[i]))
    ;;
    -)
        result=$((result - numbers[i]))         
    ;;
    \*)
        result=$((result * numbers[i]))
    ;;
    %)
        result=$((result % numbers[i]))
    ;;
    *)
        echo "Invalid operation"
        echo "NOTE: if u want to use * operation type it like this \*"
        exit 1
    ;;
    esac
done



if [[ "$debug" == "true" ]]; then
      echo "User: $(whoami)"
      echo "Script: 2_operations.sh"
      echo "Operation: $operation"
      echo "Numbers: ${numbers[*]}"
 fi

 echo "Result: $result"
