# Lövie - LÖVE Framework Demo Collection

Lövie (pronounced like "love-ee") is an interactive showcase of LÖVE framework features and techniques, organized into categories for easy reference when creating games.

## Getting Started

### Prerequisites

- [LÖVE](https://love2d.org/) version 11.4 or later

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/drewnix/lovie.git
   ```

2. Run the project with LÖVE:
   ```
   cd lovie
   love .
   ```

Alternatively, you can download a release and run it directly.

## Available Demos

Lövie is organized into categories with various demos:

### Basics
- **Basic Drawing**: Demonstrates fundamental drawing operations (shapes, colors, lines)
- **Documentation**: Guide to creating your own scenes and extending the framework

### Graphics
- **Animations**: Various animation techniques including tweening and transforms
- **Particles**: Visual effects using LÖVE's particle system
- **Shaders**: GLSL shader examples and effects

### Audio & Input
- **Audio**: Sound generation and manipulation techniques

### Systems
- **Physics**: Showcases Box2D physics integration with interactive objects
- **Camera Systems**: Different camera behaviors and effects
- **Resolution Management**: Handle different screen sizes and resolutions

More demos are being added regularly. Check the roadmap for planned additions or add your own scenes using the tools described below.

## Building and Development

A Makefile is included for common tasks:

```
make run                                      # Run the project
make package                                  # Create a .love file for distribution
make clean                                    # Clean up temporary files
make new-scene name=scene_name category=Type  # Create a new scene in specified category
make remove-scene name=scene_name             # Remove a scene
```

### Adding New Scenes

Lövie includes a dynamic scene loading system that makes it easy to add new demonstrations:

1. Use the `make new-scene` command to create a scene template:
   ```
   make new-scene name=my_cool_feature category="Graphics"
   ```

2. This creates a new scene file in the `scenes` directory and registers it in the configuration.

3. Edit the new scene file to implement your demonstration.

4. Run the project, and your scene will automatically appear in the menu under the specified category.

### Scene Categories

Scenes are organized into categories for easier navigation:

- **Basics**: Fundamental LÖVE features and documentation
- **Graphics**: Visual effects, animations, and rendering techniques
- **Audio & Input**: Sound and user interaction examples
- **Systems**: Architecture and management systems
- **Debug**: Testing and diagnostic tools

You can add your own categories by editing the `config/scenes.lua` file.

## Architecture

### Dynamic Scene Loading

Lövie now features a dynamic scene loading system:

- Scenes are loaded automatically from the `scenes/` directory
- Scene configuration is managed in `config/scenes.lua`
- New scenes can be added without modifying `main.lua`
- The menu system organizes scenes by category
- Multi-column layout with scrolling for handling many scenes

### User Interface

- Responsive menu adapts to window size
- Multi-column layout shows more scenes at once
- Scene filtering with search functionality
- Categorized scene organization
- Visual styling with category colors

## Roadmap

See the [ROADMAP.md](ROADMAP.md) file for the planned demo additions and features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Create a new scene using `make new-scene`
2. Implement your feature or demonstration
3. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
