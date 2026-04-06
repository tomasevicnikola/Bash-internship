#!/bin/bash

create_db() {
    local db_name="$2"

    if [[ -z "$db_name" ]]; then
       echo "Error: Missing database name!"
       echo "Usage: ./database.sh create_db <db_name>"
       exit 1
    fi

    db_file="${db_name}.txt"

    if [[ -e "$db_file" ]]; then
       echo  "Error: Database already exists!"  
       exit 1
    fi

    touch "$db_file"
    echo "Database $db_file created!"
}

create_table() {
    local db_name="$2"
    local table_name="$3"
    shift 3
    local fields=("$@")

    if [[ -z "$db_name" ]] || [[ -z "$table_name" ]] || [[ ${#fields[@]} -eq 0 ]]; then
        echo "Error: Missing database name or table name or fields"
        echo "Usage: ./database.sh create_table <db_name> <table_name> <field1> [field2] [field3] [field4]"
        exit 1
    fi
    
    if [[ ${#fields[@]} -gt 4 ]]; then
        echo "Error: Maximum number of fields is 4"
        exit 1
   fi
    
   db_file="${db_name}.txt"

   if ! [[ -e "$db_file" ]]; then
        echo "Error: Database name doesnt exist"
        exit 1
   fi

   if grep -q "^TABLE $table_name$" "$db_file"; then
        echo "Error: table already exist"
        exit 1
   fi

   local header="**"
   for field in "${fields[@]}"; do
        if [ ${#field} -gt 7 ]; then
            echo "Error: Max 7 characters in the field"
            exit 1
        fi

        header="$header$(printf " %-7s" "$field")"
   done
   header="$header**"

   {
          echo "TABLE $table_name"
          echo "$header"
          echo "ENDTABLE"
          echo
   } >> "$db_file"

   echo "Table '$table_name' created!"
}

insert_data(){
     local db_name="$2"
     local table_name="$3"
     shift 3
     local values=("$@")

     if [[ -z "$db_name" ]] || [[ -z "$table_name" ]]; then
          echo "Error: Missing database name or table name"
          echo "Usage: ./database.sh insert_data <db_name> <table_name> <value1> [value2] [value3] [value4]"
          exit 1
     fi

     local db_file="${db_name}.txt"

     if ! [[ -e "$db_file" ]]; then
          echo "Error: Database doesnt exists"
          exit 1
     fi

     if ! grep -q "^TABLE $table_name$" "$db_file"; then
          echo "Table doesnt exists"
          exit 1
     fi

     header_line=$(grep -A1 "^TABLE $table_name$" "$db_file" | tail -1)
 
    fields_count=0
    i=2
    while [ $i -lt $((${#header_line} - 2)) ]; do
          fields_count=$((fields_count + 1))
          i=$((i + 8))
    done
 
    if [[ ${#values[@]} -ne "$fields_count" ]]; then
        echo "Error: Expected $fields_count fields"
        exit 1
    fi
 
    row="**"
    for value in "${values[@]}"; do
        if [ ${#value} -gt 7 ]; then
            echo "Error: Value '$value' is too long max 7 characters"
            exit 1
        fi
        row="$row$(printf " %-7s" "$value")"
    done
    row="$row**"
 
    sed -i '' "/^TABLE $table_name$/,/^ENDTABLE$/ s/^ENDTABLE$/$row\nENDTABLE/" "$db_file"
 
    echo "Data inserted into '$table_name'"
}
 
select_data() {
    local db_name="$2"
    local table_name="$3"
 
    if [[ -z "$db_name" ]] || [[ -z "$table_name" ]]; then
        echo "Error: Missing database name or table name"
        echo "Usage: echo ./database.sh select_data <db_name> <table_name>"
        exit 1
    fi
 
    db_file="${db_name}.txt"
 
    if [[ ! -e "$db_file" ]]; then
        echo "Error: Database doesnt exist"
        exit 1
    fi
 
    if ! grep -q "^TABLE $table_name$" "$db_file"; then
        echo "Error: table doesnt exist"
        exit 1
    fi

    sed -n -e "/^TABLE $table_name$/,/^ENDTABLE$/ {" -e "/^TABLE/d" -e "/^ENDTABLE/d" -e "p" -e "}" "$db_file"
}
 
delete_data() {
    local db_name="$2"
    local table_name="$3"
    local condition="$4"

    if [[ -z "$db_name" ]] || [[ -z "$table_name" ]] || [[ -z "$condition" ]]; then
        echo "Error: Missing database name, table name or condition"
        echo "Usage: ./database.sh delete_data <db_name> <table_name> field=value"
        exit 1
    fi

    local db_file="${db_name}.txt"

    if [[ ! -e "$db_file" ]]; then
        echo "Error: Database doesnt exist"
        exit 1
    fi

    if ! grep -q "^TABLE $table_name$" "$db_file"; then
        echo "Error: Table doesnt exist"
        exit 1
    fi

    field_name="${condition%=*}"
    field_value="${condition#*=}"

    if [[ "$field_name" = "$condition" ]] || [[ "$condition" == *" "* ]]; then
        echo "Error: Condition must be like field=value"
        exit 1
    fi

    header_line=$(grep -A1 "^TABLE $table_name$" "$db_file" | tail -1)

    field_pos=-1
    current_col=0
    i=2

    while [ $i -lt $((${#header_line} - 2)) ]; do
        cell="${header_line:$i:8}"
        cell=$(echo "$cell" | xargs)

            if [ "$cell" = "$field_name" ]; then
                field_pos=$current_col
                break
            fi
            current_col=$((current_col + 1))

        i=$((i + 8))
    done

    if [[ $field_pos -eq -1 ]]; then
        echo "Error: Field doesnt exist"
        exit 1
    fi

    col_pos=$((3 + field_pos * 8))
    temp_file="temp_${table_name}.txt"

    in_table=0
    is_header=0
    while read -r line; do
        if [ "$line" = "TABLE $table_name" ]; then
            in_table=1
            echo "$line"
            continue
        fi

        if [[ "$in_table" = 1 ]] && [[ "$line" = "ENDTABLE" ]]; then
            in_table=0
            is_header=0
            echo "$line"
            continue
        fi

        if [[ "$in_table" = 1 ]] && [[ "$is_header" = 0 ]]; then
            is_header=1
            echo "$line"
            continue
        fi

        if [[ "$in_table" = 1 ]]; then
            cell="${line:$col_pos:7}"
            cell=$(echo "$cell" | xargs)
            if [ "$cell" = "$field_value" ]; then
                continue
            fi
        fi

        echo "$line"
    done < "$db_file" > "$temp_file"

    mv "$temp_file" "$db_file"

    echo "Matching rows deleted from '$table_name'"
}
 
if [ $# -lt 1 ]; then
    echo "Error: missing command"
    echo "Usage:"
    echo "./database.sh create_db <db_name>"
    echo "./database.sh create_table <db_name> <table_name> <field1> [field2] [field3] [field4]"
    echo "./database.sh insert_data <db_name> <table_name> <value1> [value2] [value3] [value4]"
    echo "./database.sh select_data <db_name> <table_name>"
    echo "./database.sh delete_data <db_name> <table_name> field=value"
    echo "./database.sh help"
    exit 1
fi
 
case "$1" in
    create_db)
        create_db "$@"
        ;;
    create_table)
        create_table "$@"
        ;;
    insert_data)
        insert_data "$@"
        ;;
    select_data)
        select_data "$@"
        ;;
    delete_data)
        delete_data "$@"
        ;;
     help)
        echo "Available commands:"
        echo "  create_db    - creates a new database"
        echo "  create_table - creates a new table in database"
        echo "  insert_data  - inserts a row into table"
        echo "  select_data  - displays all rows from table"
        echo "  delete_data  - deletes rows matching condition"
        echo ""
        echo "Usage:"
        echo "  ./database.sh create_db <db_name>"
        echo "  ./database.sh create_table <db_name> <table_name> <field1> [field2] [field3] [field4]"
        echo "  ./database.sh insert_data <db_name> <table_name> <value1> [value2] [value3] [value4]"
        echo "  ./database.sh select_data <db_name> <table_name>"
        echo "  ./database.sh delete_data <db_name> <table_name> \"field=value\""
    ;;
    *)
        echo "Error: Invalid command"
        echo "Available commands: help, create_db, create_table, insert_data, select_data, delete_data"
        exit 1
        ;;
esac
