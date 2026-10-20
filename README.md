# godot-flake

Official Godot 4.7.2 editor Linux binary from [godot-builds](https://github.com/godotengine/godot-builds), wrapped in an FHS environment with the display/audio runtime libraries (X11, Wayland, fontconfig, ALSA, PulseAudio), a desktop entry, and the official icon. Nothing gets compiled.

Run:

```
nix run github:Matko802/godot-flake
```

NixOS module:

```nix
inputs.godot-flake = {
  url = "github:Matko802/godot-flake";
};
```

```nix
environment.systemPackages = [
  inputs.godot-flake.packages.x86_64-linux.default
];
```

To bump the version, change `version` in `flake.nix` along with the sha512 of the matching release zip.
