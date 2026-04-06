# 7_database.sh - Database Service

A bash script that simulates a basic database using plain text files. Each database is stored as a `.txt` file and can contain multiple tables with fixed-width columns.

## Usage

```bash
./7_database.sh <command> [arguments]
./7_database.sh help
```

---

## Database Structure

Data is stored in plain text files with the `.txt` extension. Each table looks like this:

```
TABLE persons
** id      name    height  age    **
** 0       Igor    180     36     **
** 1       Pyotr   178     25     **
ENDTABLE
```

- Each row is wrapped in `**`
- Each cell is exactly 8 characters wide (1 space + 7 characters for the value)
- Maximum 4 fields per table
- Maximum 7 characters per field or value
- Tables are separated by an empty line

---

## Commands

---

### create_db

Creates a new database file.

```bash
./7_database.sh create_db <db_name>
```

#### How it works
- Takes database name as argument and creates an empty `.txt` file with that name using `touch`

#### Error handling
- Exits if database name is missing
- Exits if database already exists

---

### create_table

Creates a new table inside an existing database.

```bash
./7_database.sh create_table <db_name> <table_name> <field1> [field2] [field3] [field4]
```

#### How it works
- Takes table name and field names as arguments
- Builds a header row by padding each field name to 7 characters using `printf " %-7s"`
- Writes `TABLE <name>`, the header row, and `ENDTABLE` into the database file

#### Error handling
- Exits if database name, table name or fields are missing
- Exits if more than 4 fields are provided
- Exits if database does not exist
- Exits if table already exists
- Exits if any field name exceeds 7 characters

---

### insert_data

Inserts a new row of data into an existing table.

```bash
./7_database.sh insert_data <db_name> <table_name> <value1> [value2] [value3] [value4]
```

#### How it works
- Reads the header line of the table using `grep -A1` to get the line right after `TABLE <name>`
- Counts the number of fields by walking through the header 8 characters at a time
- Builds a new row by padding each value to 7 characters using `printf " %-7s"`
- Uses `sed -i ''` to find `ENDTABLE` inside the table range and replaces it with the new row followed by `ENDTABLE`

#### Why sed
- `sed -i ''` lets us insert a line before `ENDTABLE` in one command without manually managing a temp file
- Note: `sed -i ''` syntax is macOS specific, on Linux it would be `sed -i`

#### Error handling
- Exits if database name or table name is missing
- Exits if database or table does not exist
- Exits if number of values does not match number of fields
- Exits if any value exceeds 7 characters

---

### select_data

Displays all rows from a table including the header.

```bash
./7_database.sh select_data <db_name> <table_name>
```

#### How it works
- Uses `sed -n` with a range pattern to find lines between `TABLE <name>` and `ENDTABLE`
- Deletes the `TABLE` and `ENDTABLE` marker lines
- Prints only the header and data rows

#### Error handling
- Exits if database name or table name is missing
- Exits if database or table does not exist

---

### delete_data

Deletes all rows from a table that match a given condition.

```bash
./7_database.sh delete_data <db_name> <table_name> "field=value"
```

#### How it works
- Splits the condition into `field_name` and `field_value` using bash string operators `%%=*` and `#*=`
- Reads the header line and walks through it 8 characters at a time to find which column the field is in
- Calculates the exact character position of that column in each data row using `col_pos=$((3 + field_pos * 8))`
- Reads the database file line by line, skips the header row, and for each data row extracts the cell at that position and compares it to the value
- Rows that match are skipped, all other lines are written to a temp file
- Replaces the original file with the temp file

#### Why temp file
- You cannot delete a line from the middle of a file directly in bash
- The only safe way is to read the whole file, skip matching rows, and write everything else to a new file
- `sed` was considered but it cannot do positional column matching so `while read` + temp file was the only option

#### Error handling
- Exits if database name, table name or condition is missing
- Exits if database or table does not exist
- Exits if condition has no `=` sign or contains spaces
- Exits if field does not exist in the table

---

### help

Displays all available commands and their usage.

```bash
./7_database.sh help
```

---

## Example

```bash
./7_database.sh create_db example_db
./7_database.sh create_table example_db persons id name age
./7_database.sh insert_data example_db persons 1 John 25
./7_database.sh insert_data example_db persons 2 Mark 30
./7_database.sh select_data example_db persons
./7_database.sh delete_data example_db persons "name=Mark"
./7_database.sh select_data example_db persons
```
