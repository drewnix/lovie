# Makefile for Lövie LÖVE Framework Demo Collection
# This Makefile provides commands for running, packaging, and managing your LÖVE project

# Configuration
PROJECT_NAME := lovie
LOVE_VERSION := 11.4
LOVE_PATH ?= love

# Detect OS for platform-specific commands
ifeq ($(OS),Windows_NT)
	DETECTED_OS := Windows
	ZIP_COMMAND := powershell -command "Compress-Archive -Path \"*\" -DestinationPath \"$(PROJECT_NAME).zip\" -Force"
	LOVE_EXECUTABLE := $(LOVE_PATH).exe
	RM_COMMAND := powershell -command "Remove-Item"
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		DETECTED_OS := Linux
		ZIP_COMMAND := zip -r $(PROJECT_NAME).zip * -x "*.zip" -x "*.love" -x "*.git*" -x "Makefile"
		LOVE_EXECUTABLE := $(LOVE_PATH)
		RM_COMMAND := rm -f
	endif
	ifeq ($(UNAME_S),Darwin)
		DETECTED_OS := macOS
		ZIP_COMMAND := zip -r $(PROJECT_NAME).zip * -x "*.zip" -x "*.love" -x "*.git*" -x "Makefile"
		LOVE_EXECUTABLE := $(LOVE_PATH)
		RM_COMMAND := rm -f
	endif
endif

# Main targets
.PHONY: all run clean package help

# Default target runs the help command
all: help

# Run the LÖVE project
run:
	@echo "Starting $(PROJECT_NAME) with LÖVE..."
	$(LOVE_EXECUTABLE) .

# Clean temporary files
clean:
	@echo "Cleaning up temporary files..."
	$(RM_COMMAND) $(PROJECT_NAME).love
	$(RM_COMMAND) $(PROJECT_NAME).zip
	@echo "Cleanup complete."

# Create a .love file for distribution
package: clean
	@echo "Packaging $(PROJECT_NAME).love file..."
	$(ZIP_COMMAND)
	mv $(PROJECT_NAME).zip $(PROJECT_NAME).love
	@echo "Package created: $(PROJECT_NAME).love"

# Create a Windows executable (for Windows only)
windows: package
ifeq ($(DETECTED_OS),Windows)
	@echo "Creating Windows executable..."
	copy /b "$(LOVE_EXECUTABLE)" + "$(PROJECT_NAME).love" "$(PROJECT_NAME).exe"
	@echo "Windows executable created: $(PROJECT_NAME).exe"
else
	@echo "This command only works on Windows systems."
endif

# Create a new empty scene template
new-scene:
	@read -p "Enter scene name (lowercase, use underscores for spaces): " scene_name; \
	scene_file=scenes/$${scene_name}.lua; \
	if [ -f $$scene_file ]; then \
		echo "Scene already exists: $$scene_file"; \
	else \
		echo "Creating new scene: $$scene_file"; \
		cat > $$scene_file << EOF \
-- scenes/$${scene_name}.lua\
-- Description of what this scene demonstrates\
\
local $${scene_name^} = {\
    title = "$${scene_name^}",\
    description = "Description of what this scene demonstrates"\
}\
\
function $${scene_name^}.enter()\
    -- Called when entering the scene\
    -- Initialize variables, load resources, set up the scene\
end\
\
function $${scene_name^}.exit()\
    -- Called when leaving the scene\
    -- Clean up resources, stop sounds, etc.\
end\
\
function $${scene_name^}.update(dt)\
    -- Called every frame with delta time\
    -- Update game logic, animations, etc.\
end\
\
function $${scene_name^}.draw()\
    -- Draw background\
    love.graphics.setColor(0.2, 0.2, 0.3)\
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())\
    \
    -- Draw title and description\
    love.graphics.setColor(1, 1, 1)\
    love.graphics.setFont(love.graphics.newFont(24))\
    love.graphics.printf($${scene_name^}.title, 0, 20, love.graphics.getWidth(), "center")\
    \
    love.graphics.setFont(love.graphics.newFont(16))\
    love.graphics.printf($${scene_name^}.description, 0, 60, love.graphics.getWidth(), "center")\
    \
    -- Draw your scene content here\
    \
    -- Reset font and color\
    love.graphics.setFont(love.graphics.newFont(12))\
    love.graphics.setColor(1, 1, 1)\
end\
\
function $${scene_name^}.keypressed(key)\
    -- Handle key presses\
end\
\
function $${scene_name^}.mousepressed(x, y, button)\
    -- Handle mouse presses\
end\
\
function $${scene_name^}.mousereleased(x, y, button)\
    -- Handle mouse releases\
end\
\
return $${scene_name^}\
EOF\
		echo "Remember to add your new scene to main.lua!"; \
	fi

# Check if LÖVE is installed
check-love:
	@echo "Checking for LÖVE installation..."
	@if command -v $(LOVE_EXECUTABLE) > /dev/null; then \
		echo "LÖVE is installed: $$($(LOVE_EXECUTABLE) --version)"; \
	else \
		echo "LÖVE is not installed or not found in PATH."; \
		echo "Please install LÖVE from https://love2d.org/"; \
	fi

# Display help information
help:
	@echo "Lövie LÖVE Framework Demo Collection - Makefile commands:"
	@echo ""
	@echo "  make run          - Run the LÖVE project"
	@echo "  make package      - Create a .love file for distribution"
	@echo "  make clean        - Clean temporary files"
	@echo "  make windows      - Create a Windows executable (Windows only)"
	@echo "  make new-scene    - Create a new scene template"
	@echo "  make check-love   - Check if LÖVE is installed"
	@echo "  make help         - Display this help message"
	@echo ""
	@echo "Current detected OS: $(DETECTED_OS)"
	@echo "LÖVE executable: $(LOVE_EXECUTABLE)"
