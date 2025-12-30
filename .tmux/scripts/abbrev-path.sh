#!/bin/bash
# Abbreviate path like fish: ~/projects/myproject -> ~/p/myproject

path="${1:-$PWD}"

# Replace home with ~
path="${path/#$HOME/\~}"

# If path is short enough, return as-is
if [ ${#path} -le 20 ]; then
    echo "$path"
    exit 0
fi

# Abbreviate middle directories (keep first char only)
IFS='/' read -ra parts <<< "$path"
result=""
last_idx=$((${#parts[@]} - 1))

for i in "${!parts[@]}"; do
    if [ $i -eq 0 ]; then
        result="${parts[0]}"
    elif [ $i -eq $last_idx ]; then
        result="${result}/${parts[$i]}"
    else
        # Abbreviate to first char
        result="${result}/${parts[$i]:0:1}"
    fi
done

echo "$result"
