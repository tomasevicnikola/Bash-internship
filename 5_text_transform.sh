#!/bin/bash

#This script performs text transformation on input file and write it down on output file
#Usage: ./5_text_transform.sh -i <input file> -o <output_file> [-v | -r | -l | -u | -s <A_WORD> <B_WORD>]
#-v - replaces lowercase charactrs with uppercase and vise versa
#-s - script substitutes <A_WORD> with <B_WORD> in text (case sensitive)
#-r - reverses text lines
#-l - converts all the text to loewr case
#-u - converts all text to upper case

mode=""
input_file=""
output_file=""
a_word=""
b_word=""

while getopts "vs:rlui:o:" opt; do
    case "$opt" in
    v)
        mode="v"
    ;;
    s)
        mode="s"
        a_word="$OPTARG"
        b_word="${!OPTIND}"
        if [[ -z "$b_word" ]]; then
            echo "-s must take two arguments"    
            exit 1
        fi
        OPTIND=$((OPTIND+1))
    ;;
    r)
        mode="r"
    ;;
    l)
        mode="l"
    ;;
    u)
        mode="u"
    ;;
    i)
        input_file="$OPTARG"
    ;;
    o)
        output_file="$OPTARG"
    ;;
    *)
        echo "Usage: ./5_text_transform.sh -i <input file> -o <output_file> [-v | -r | -l | -u | -s <A_WORD> <B_WORD>]"
        exit 1
    ;;
    esac
done


if  [[ -z "$input_file" ]] || [[ -z "$output_file" ]] || [[ -z "$mode" ]]; then
    echo "Usage: ./5_text_transform.sh -i <input file> -o <output_file> [-v | -r | -l | -u | -s <A_WORD> <B_WORD>]"
    exit 1
fi

if ! [[ -e "$input_file" ]]; then
    echo "Input file doesnt exist"
    exit 1
fi

case "$mode" in
    v)
        tr '[:lower:][:upper:]' '[:upper:][:lower:]' < "$input_file" > "$output_file"
    ;;
    s)
        sed "s/$a_word/$b_word/g" < "$input_file" > "$output_file"
    ;;
    r)
        rev < "$input_file" > "$output_file"
    ;;
    l)
        tr '[:upper:]' '[:lower:]' < "$input_file" > "$output_file"
    ;;
    u)
        tr '[:lower:]' '[:upper:]' < "$input_file" > "$output_file"
    ;;
    *)
        echo "Invalid operation"
        exit 1
    ;;
esac

echo "Result written to $output_file"



