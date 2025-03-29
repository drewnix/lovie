#\!/bin/bash
# Script to remove a scene and update the configuration

# Check if scene name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <scene_name>"
    exit 1
fi

scene_name=$1
scene_file="scenes/${scene_name}.lua"
config_file="config/scenes.lua"

# Check if scene exists
if [ \! -f "$scene_file" ]; then
    echo "Scene does not exist: $scene_file"
    exit 1
fi

# Remove the scene file
rm "$scene_file"
echo "Removed scene file: $scene_file"

# Update the config file to remove the scene entry
if [ -f "$config_file" ]; then
    # Create a temporary file
    temp_file=$(mktemp)

    # Filter out lines containing the scene name from sceneCategories
    awk -v scene="$scene_name" '
        /sceneCategories = {/,/}/{
            if ($0 ~ scene " =") {
                # Skip this line
                next
            }
        }
        # Print all other lines
        { print }
    ' "$config_file" > "$temp_file"

    # Filter out lines containing the scene name from sceneColors
    temp_file2=$(mktemp)
    awk -v scene="$scene_name" '
        /sceneColors = {/,/}/{
            if ($0 ~ scene " =") {
                # Skip this line
                next
            }
        }
        # Print all other lines
        { print }
    ' "$temp_file" > "$temp_file2"

    # Replace the original file
    mv "$temp_file2" "$config_file"
    rm -f "$temp_file"

    echo "Removed scene from configuration file"
fi

echo "Scene '$scene_name' has been completely removed."
