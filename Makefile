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
.PHONY: all run clean package help new-scene

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
	@if [ -z "$(name)" ]; then \
		echo "Usage: make new-scene name=your_scene_name"; \
		exit 1; \
	fi; \
	./scripts/create_scene.sh "$(name)"

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
	@echo "  make run                        - Run the LÖVE project"
	@echo "  make package                    - Create a .love file for distribution"
	@echo "  make clean                      - Clean temporary files"
	@echo "  make windows                    - Create a Windows executable (Windows only)"
	@echo "  make new-scene name=scene_name  - Create a new scene template"
	@echo "  make check-love                 - Check if LÖVE is installed"
	@echo "  make help                       - Display this help message"
	@echo ""
	@echo "Current detected OS: $(DETECTED_OS)"
	@echo "LÖVE executable: $(LOVE_EXECUTABLE)"