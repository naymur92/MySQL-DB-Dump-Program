#!/bin/bash

read -p "Enter MySQL username: " USER
read -s -p "Enter MySQL password (leave blank for default): " PASSWORD
echo
read -p "Enter MySQL hostname (leave blank for default): " HOSTNAME
read -p "Enter MySQL port (leave blank for default): " PORT

# filename for database names
DATABASE_FILE="databases.txt"

# directory for dumped files
DUMP_DIR="dumped_files"

if [ ! -f "$DATABASE_FILE" ]; then
    echo "Database file $DATABASE_FILE not found!"
    exit 1
fi

mkdir -p "$DUMP_DIR"

databases=()
while IFS= read -r db || [[ -n "$db" ]]; do
    db=$(echo "$db" | tr -d '[:space:]')
    
    if [ -n "$db" ]; then
        databases+=("$db")
    fi
done < "$DATABASE_FILE"

for db in "${databases[@]}"
do
    echo "Dumping database: $db"
    
    if [ -z "$db" ]; then
        echo "Skipping empty database name"
        continue
    fi

    
    CMD=("mysqldump" "-u" "$USER")
    
    if [ -n "$PASSWORD" ]; then
        CMD+=("-p$PASSWORD")
    fi

    if [ -n "$HOSTNAME" ]; then
        CMD+=("-h" "$HOSTNAME")
    fi

    if [ -n "$PORT" ]; then
        CMD+=("-P" "$PORT")
    fi

    CMD+=("--databases" "$db")

    EXPORT_TO="$DUMP_DIR/$db.sql"

    "${CMD[@]}" > "$EXPORT_TO"

    if [ $? -eq 0 ]; then
        echo "Database $db dumped successfully to $EXPORT_TO"
    else
        echo "Error dumping database $db"
    fi
done

