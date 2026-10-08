# SoundByte
A basic sound manager module for Roblox.

## Dependencies
This resource is **dependant** on the [Nevermore](https://github.com/Quenty/NevermoreEngine) framework. It will not work without it.

## Features
Stores sounds as ModuleScripts to simplify sound loading within your game, save memory, and allow for further functionality such as sound settings.

## Usage
Example:
```luau
    local SoundByte = require("SoundByte");
    local sound = SoundByte.new("SwordSwing1");
    sound:Play();
```
The library also allows for furthur functionality such as:
```luau
    local SoundByte = require("SoundByte");

    local Player = game:GetService("Players").LocalPlayer;
    SoundByte.new("SwordSwing1"):PlayOnceAtVector3(Player.Character.Head.Position); -- Plays the sound once at the player's position, and cleans itself up afterwards.
    local waterfall_part = workspace:FindFirstChild("WaterfallPart");
    local waterfall_sound = SoundByte.new("WaterfallLoop1");
    waterfall_sound:LoopAtInstance(waterfall_part);
```
It's recommended to read through the script for a full understanding of each method.

## Sound setting customization
SoundByte also supports the ability to register sound categories and change their specific volume.
Example:
```luau
    local SoundSettings = require("SoundByteSettings");
    -- Add categories
    SoundSettings:AddCategory("SFX");
    SoundSettings:AddCategory("Music");
    -- Set category volume: (Default 50)
    SoundSettings.Settings["SFX"]:SetVolume(25); -- Every sound with the Category "SFX" will now play at half volume. (Setting the number to 0.5 will also work, although it is recommended to work with a scale of 1-100, with 50 being the default)
```

## Installation
SoundByte supports [Nevermore's](https://github.com/Quenty/NevermoreEngine) npm package installation method. 

Simply type ```npm install @gandalfwisdom/soundbyte``` in your CLI on your project to install.