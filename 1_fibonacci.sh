#!/bin/bash

#This scrip calculates fibonacci number for a given n



function fib(){
    local n=$1

    if [[ "$n" -eq 0 ]]; then
        echo 0
    elif [[ "$n" -eq 1 ]]; then
        echo 1
    else 
        local x=0
        local y=1
        local temp

        for (( i=2; i<=n; i++ )); do
            temp=$((x+y))
            x=$y
            y=$temp
        done
        
        echo "$y"
    fi
    
}


if [[ -z "$1" ]]; then
	echo "Please enter a number as an argument"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
	echo "Please enter a non negative intiger as a number"
    exit 1
fi

result=$(fib "$1")

echo "Fibonacci number for a given number is: $result"


