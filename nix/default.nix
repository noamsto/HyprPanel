{ inputs
, pkgs
, system
, stdenv
, lib
, writeShellScriptBin
, bun
, dart-sass
, fd
, accountsservice
, btop
, pipewire
, bluez
, bluez-tools
, grimblast
, gpu-screen-recorder
, networkmanager
, brightnessctl
, matugen
, swww
, python3
, gnome
}:
let
  ags = inputs.ags.packages.${system}.default.override {
    extraPackages = [ accountsservice ];
  };

  pname = "hyprpanel";
  config = stdenv.mkDerivation {
    inherit pname;
    version = "latest";
    src = ./.;

    buildPhase = ''
      ${bun}/bin/bun build ./main.ts \
        --outfile main.js \
        --external "resource://*" \
        --external "gi://*"
    '';

    installPhase = ''
      mkdir $out
      cp -r assets $out
      cp -r scss $out
      cp -r widget $out
      cp -r services $out
      cp -f main.js $out/config.js
    '';
  };
in
{
  desktop = {
    inherit config;
    script = writeShellScriptBin pname ''
      export PATH=$PATH:${lib.makeBinPath [dart-sass fd btop pipewire bluez bluez-tools grimblast gpu-screen-recorder brightnessctl gnome.gnome-bluetooth python3]}
            ${ags}/bin/ags -b hyprpanel -c ${config}/config.js $@
    '';
  };
}
