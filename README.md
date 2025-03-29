# Lövie - LÖVE Framework Demo Collection

Lövie (pronounced like "love-ee") is an interactive showcase various demos I am using as reference as I create games.

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

Lövie currently includes the following demos:

- **Basic Drawing**: Demonstrates fundamental drawing operations (shapes, colors, lines)
- **Animations**: Various animation techniques including tweening and transforms
- **Physics**: Showcases Box2D physics integration with interactive objects
- **Particles**: Visual effects using LÖVE's particle system
- **Audio**: Sound generation and manipulation techniques
- **Documentation**: Guide to creating your own scenes and extending the framework

More demos are being added regularly. Check the roadmap for planned additions.

## Building and Development

A Makefile is included for common tasks:

```
make run          # Run the project
make package      # Create a .love file for distribution
make clean        # Clean up temporary files
make new-scene    # Create a new scene template
```

## Roadmap

See the [ROADMAP.md](ROADMAP.md) file for the planned demo additions and features.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
