#!/bin/bash

# Get absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to create .muxthm file for a theme
create_muxthm() {
    local theme_dir="$1"
    local theme_name=$(basename "$theme_dir")
    local output_file="${SCRIPT_DIR}/${theme_name}.muxthm"
    
    # Skip if not a theme directory
    if [ ! -d "$theme_dir" ] || [[ "$theme_name" != Aurora* ]]; then
        return
    fi
    
    echo "Creating .muxthm for $theme_name"
    
    # Create temporary directory for theme packaging
    local temp_dir=$(mktemp -d)
    cp -r "$theme_dir"/* "$temp_dir/"
    
    # Remove any existing .muxthm file
    if [ -f "$output_file" ]; then
        rm "$output_file"
    fi
    
    # Create the new .muxthm file
    cd "$temp_dir"
    if zip -r "$output_file" ./* ; then
        echo "Created ${theme_name}.muxthm successfully"
        # Verify the file exists and has content
        if [ -f "$output_file" ] && [ -s "$output_file" ]; then
            echo "Verified ${theme_name}.muxthm was created properly"
            # Ensure proper permissions
            chmod 644 "$output_file"
        else
            echo "Error: ${theme_name}.muxthm was not created properly"
        fi
    else
        echo "Error creating ${theme_name}.muxthm"
    fi
    cd "$SCRIPT_DIR"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Process each theme directory
for theme_dir in "${SCRIPT_DIR}"/Aurora*/; do
    if [ -d "$theme_dir" ]; then
        create_muxthm "$theme_dir"
    fi
done

# Verify final results
echo -e "\nVerifying created .muxthm files:"
ls -l "${SCRIPT_DIR}"/*.muxthm 