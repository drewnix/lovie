#!/bin/bash
# Script to create a new LÖVE scene

# Check if scene name is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <scene_name>"
    exit 1
fi

scene_name=$1
scene_file="scenes/${scene_name}.lua"

# Check if scene already exists
if [ -f "$scene_file" ]; then
    echo "Scene already exists: $scene_file"
    exit 1
fi

# Convert to PascalCase
first_char=$(echo "$scene_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
rest=$(echo "$scene_name" | cut -c2-)
pascal="${first_char}${rest}"

# Create the scene file
cat > "$scene_file" << EOF
-- scenes/${scene_name}.lua
-- Description of what this scene demonstrates

local ${pascal} = {
    title = "${pascal}",
    description = "Description of what this scene demonstrates"
}

function ${pascal}.enter()
    -- Called when entering the scene
    -- Initialize variables, load resources, set up the scene
end

function ${pascal}.exit()
    -- Called when leaving the scene
    -- Clean up resources, stop sounds, etc.
end

function ${pascal}.update(dt)
    -- Called every frame with delta time
    -- Update game logic, animations, etc.
end

function ${pascal}.draw()
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Draw title and description
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(${pascal}.title, 0, 20, love.graphics.getWidth(), "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(${pascal}.description, 0, 60, love.graphics.getWidth(), "center")

    -- Draw your scene content here

    -- Reset font and color
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(1, 1, 1)
end

function ${pascal}.keypressed(key)
    -- Handle key presses
end

function ${pascal}.mousepressed(x, y, button)
    -- Handle mouse presses
end

function ${pascal}.mousereleased(x, y, button)
    -- Handle mouse releases
end

return ${pascal}
EOF

echo "Scene created: $scene_file"
echo "Remember to add your new scene to main.lua!"