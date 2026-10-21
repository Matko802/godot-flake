{
  description = "Official Godot editor, FHS-wrapped with runtime display libraries";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    version = "4.8-beta1";
    src = pkgs.fetchurl {
      url = "https://github.com/godotengine/godot-builds/releases/download/${version}/Godot_v${version}_linux.x86_64.zip";
      hash = "sha256-GZstag2qOnSmlzVvMcMzR/mX9lJYun3QfKjBEQdXkn0=";
    };
    editor = pkgs.stdenv.mkDerivation {
      pname = "godot-editor";
      inherit version src;
      strictDeps = true;
      nativeBuildInputs = [pkgs.unzip];
      unpackPhase = ''
        unzip $src -d $out
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp $out/Godot_v${version}* $out/bin/godot
        rm $out/Godot_v*
      '';
    };
    icon = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/godotengine/godot/4.0-stable/icon.svg";
      hash = "sha256-HpXm0lorX7jatj2/AxaebcBRiK7sKCkyif0RzqtA5uI=";
    };
    desktop = pkgs.makeDesktopItem {
      name = "godot";
      desktopName = "Godot Engine";
      exec = "godot %f";
      icon = "godot";
      categories = ["Development" "IDE"];
      keywords = ["game engine" "gdscript" "2d" "3d"];
      startupWMClass = "Godot";
    };
  in {
    packages.${system}.default = pkgs.symlinkJoin {
      name = "godot";
      inherit version;
      paths = [(pkgs.buildFHSEnv {
        name = "godot";
        inherit version;
        runScript = "godot";
        targetPkgs = pkgs: [
          editor
          pkgs.freetype
          pkgs.zlib
          pkgs.fontconfig
          pkgs.wayland
          pkgs.libxkbcommon
          pkgs.libGL
          pkgs.alsa-lib
          pkgs.libpulseaudio
          pkgs.dbus
          pkgs.systemd
          pkgs.stdenv.cc.cc.lib
          pkgs.libx11
          pkgs.libxcursor
          pkgs.libxext
          pkgs.libxi
          pkgs.libxinerama
          pkgs.libxrandr
        ];
      })];
      postBuild = ''
        install -Dm444 ${desktop}/share/applications/godot.desktop $out/share/applications/godot.desktop
        install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/godot.svg
      '';
    };

    overlays.default = final: prev: {
      godot-flake = self.packages.${prev.stdenv.hostPlatform.system}.default;
    };
  };
}
