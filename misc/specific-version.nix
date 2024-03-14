# TODO: attribute authorship
# TODO: some channel numbers potentialy? missing, guess this could be more dynamic
#{ channels ? [ "23.05" "22.11" "21.05" "20.03" "19.09" "19.03" "18.03" "17.03" "16.03" "15.09" "14.12" "14.04" ]
# I'm low on disk space, don't want to risk garbage collect now, it should be in those two
{ channels ? [ "22.11" "22.05" "21.11" "21.05" ]
, attrs ? builtins.attrNames (import <nixpkgs> {})
, system ? builtins.currentSystem
, args ? { inherit system; }
}: let

  getSet = channel: (import (builtins.fetchTarball "channel:nixos-${builtins.toString channel}") args).pkgs;

  getPkg = name: channel: let
    pkgs = getSet channel;
    pkg = pkgs.${name};
    version = (builtins.parseDrvName pkg.name).version;
  in if builtins.hasAttr name pkgs && pkg ? name then {
    name = version;
    value = pkg;
  } else null;

in builtins.listToAttrs (map (name: {
  inherit name;
  value = builtins.listToAttrs
    (builtins.filter (x: x != null)
      (map (getPkg name) channels));
}) attrs)
