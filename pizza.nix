{ config, pkgs, callPackage, ... }: 
{
  # because it's non-free, got it? ^^ 
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "spotify"
    "spotify-unwrapped"

    "brgenml1lpr"

    "google-chrome"

    "zoom-us"
    "zoom"
    "faac" # for zoom
  ];
}
