#!/bin/bash

# Script for finding and deleting ISO images in Proxmox VE
# The script finds all ISOs across all storages, displays them
# and offers to delete each image individually or all at once

# Colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Get list of all storages
echo "Getting Proxmox VE storage list..."
storages=$(pvesm status | grep -v "Removable\|Status\|------" | awk '{print $1}')

if [ -z "$storages" ]; then
    print_message "$RED" "No storages found. Make sure you have permissions to execute the pvesm command."
    exit 1
fi

# Create a temporary file to store found ISOs
temp_file=$(mktemp)

# Function to write ISO information to file
get_isos() {
    local storage=$1
    # Get list of ISO images on the storage
    print_message "$BLUE" "Searching for ISO images on storage $storage..."
    
    # Get list of ISO images
    isos=$(pvesm list "$storage" | grep -i "\.iso" | awk '{print $1 "|" $2 "|" $3 "|" $4}')
    
    if [ -n "$isos" ]; then
        echo "$isos" | while IFS= read -r line; do
            echo "$storage|$line" >> "$temp_file"
        done
    fi
}

# Search for ISOs on all storages
for storage in $storages; do
    get_isos "$storage"
done

# Check if any ISOs were found
if [ ! -s "$temp_file" ]; then
    print_message "$YELLOW" "No ISO images found on any storage."
    rm "$temp_file"
    exit 0
fi

# Create a counter for numbering ISO images
count=1

# Display found ISOs
print_message "$GREEN" "=== Found ISO images ==="
while IFS= read -r line; do
    storage=$(echo "$line" | cut -d'|' -f1)
    volid=$(echo "$line" | cut -d'|' -f2)
    format=$(echo "$line" | cut -d'|' -f3)
    size=$(echo "$line" | cut -d'|' -f4)
    name=$(echo "$volid" | cut -d':' -f2)
    
    printf "${BLUE}%3d${NC}) Storage: ${GREEN}%s${NC}, Name: ${YELLOW}%s${NC}, Size: ${BLUE}%s${NC}\n" "$count" "$storage" "$name" "$size"
    count=$((count + 1))
done < "$temp_file"
echo ""

# Ask user if they want to delete ISOs
while true; do
    print_message "$YELLOW" "Do you want to delete the found ISO images? (yes/no): "
    read -r answer < /dev/tty
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]' | xargs)
    
    if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
        break
    elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
        print_message "$RED" "Operation cancelled."
        rm "$temp_file"
        exit 0
    else
        print_message "$RED" "Please answer 'yes' or 'no'."
    fi
done

# Ask user about deletion mode
while true; do
    print_message "$YELLOW" "Deletion mode:"
    echo "1) Delete each ISO separately (ask confirmation for each)"
    echo "2) Delete all found ISOs without additional prompts"
    print_message "$YELLOW" "Select mode (1/2): "
    read -r mode < /dev/tty
    mode=$(echo "$mode" | xargs)
    
    if [ "$mode" = "1" ] || [ "$mode" = "2" ]; then
        break
    else
        print_message "$RED" "Please enter either 1 or 2."
    fi
done

# Delete ISOs
count=0
total=$(wc -l < "$temp_file")

# Read ISO lines from the file and process them
cat "$temp_file" | while IFS= read -r line; do
    count=$((count + 1))
    storage=$(echo "$line" | cut -d'|' -f1)
    volid=$(echo "$line" | cut -d'|' -f2)
    name=$(echo "$volid" | cut -d':' -f2)
    
    if [ "$mode" = "1" ]; then
        while true; do
            print_message "$YELLOW" "Delete ISO '$name' from storage '$storage'? ($count/$total) (yes/no): "
            read -r confirm < /dev/tty
            confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]' | xargs)
            
            if [ "$confirm" = "yes" ] || [ "$confirm" = "y" ]; then
                print_message "$BLUE" "Deleting $volid..."
                if pvesm free "$volid"; then
                    print_message "$GREEN" "ISO '$name' successfully deleted."
                else
                    print_message "$RED" "Error deleting ISO '$name'."
                fi
                break
            elif [ "$confirm" = "no" ] || [ "$confirm" = "n" ]; then
                print_message "$BLUE" "Skipping ISO '$name'."
                break
            else
                print_message "$RED" "Please answer 'yes' or 'no'."
            fi
        done
    else
        print_message "$BLUE" "Deleting $volid... ($count/$total)"
        if pvesm free "$volid"; then
            print_message "$GREEN" "ISO '$name' successfully deleted."
        else
            print_message "$RED" "Error deleting ISO '$name'."
        fi
    fi
done

# Remove temporary file
rm "$temp_file"

print_message "$GREEN" "Operation completed."
