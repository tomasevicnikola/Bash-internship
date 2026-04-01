#!/bin/bash


while getopts "s:i:o:" opt; do
    case "$opt" in
    s)
        shift_val="$OPTARG"
    ;;
    i)
        input_file="$OPTARG"
    ;;
    o)
        output_file="$OPTARG" 
    ;;
    *)
        echo "Usage is ./4_caeserchipher.sh -s <shift> -i <input file> -o <output file>"
        exit 1
    ;;
    esac

done

if [ -z "$shift_val" ] || [ -z "$input_file" ] || [ -z "$output_file" ]; then
    echo "Usage is ./4_caeserchipher.sh -s <shift> -i <input file> -o <output file>"
    exit 1
fi

if ! [[ "$shift_val" =~ ^-?[0-9]+$ ]]; then
    echo "Shift must be an integer"
    exit 1
fi

shift_val=$((shift_val % 26))
if [ "$shift_val" -lt 0 ]; then
    shift_val=$((shift_val + 26))
fi

if ! [[ -e "$input_file" ]]; then
    echo "Input file doesent exist"
    exit 1
fi

lower="abcdefghijklmnopqrstuvwxyz"
upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

shifted_lower="${lower:$shift_val}${lower:0:$shift_val}"
shifted_upper="${upper:$shift_val}${upper:0:$shift_val}"

tr "$lower$upper" "$shifted_lower$shifted_upper" < "$input_file" > "$output_file"

echo "Shifted content written to '$output_file'"

