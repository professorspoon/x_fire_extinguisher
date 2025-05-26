# X_FireExtinguisher

A FiveM resource that allows players to pick up and use fire extinguishers found throughout the map.

## Features

- Pick up any fire extinguisher found in the game world
- Optimized performance with minimal resource usage
- Support for ESX and QBCore frameworks
- Automatic weapon selection after picking up extinguisher
- Cooldown system to prevent abuse
- Customizable notifications and TextUI
- Multi-language support

## Installation

1. Download the resource
2. Place it in your server's resources folder
3. Add `ensure X_FireExtinguisher` to your server.cfg
4. Configure the settings in `configuration/config.lua` to your liking

## Configuration

The script is highly configurable through the `configuration/config.lua` file:

- Framework selection (ESX or QBCore)
- ESX version (new or old)
- Cooldown settings
- Customizable notification functions
- TextUI integration

## Usage

Players simply need to approach a fire extinguisher in the game world and:

1. A prompt will appear on screen
2. Press the interaction key (default: E) to pick up the extinguisher
3. The extinguisher will be automatically equipped

## Requirements

- ESX or QBCore framework (depending on configuration)