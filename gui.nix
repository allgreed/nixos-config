{ config, pkgs, lib, callPackage, ... }: 
{
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

  fonts.packages = with pkgs; [
    source-code-pro
    font-awesome
    ### serif
    crimson # just nice
    ferrum  # more like fantasy or fancy wild west
    junicode # medival
    ### snas
    f5_6 # round edges futuristic
    jost # just nice

    # TODO: fix terminal fonts so that lsd can be used
    # note: nerfdfonts don't help here
    # (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
  ];

  services.xserver = {
    enable = true;

    autorun = false;
    displayManager = {
      startx.enable = true;
      defaultSession = "none+i3";
    };

    # should make the touchpad work, but it doesn't
    # but maybe that's a HW issue on Sarah, dunno lol
    libinput.enable = true;

    # I handle southpaws at the Xmodmap level (so that it's portable and works also on non-Nixos systems)
    # however some mouses have buttons switched in hardware, so I need to unswitch them to switch them again
    inputClassSections = 
    let
      inherit (lib) range pipe genAttrs attrValues;

      baseButtonMapping = genAttrs (map toString (range 1 8)) (x: x);  # so { 1=1, 2=2 }, etc.

      disableButton = button: mapping: mapping // { "${toString button}" = "0"; };
      swapButtons = a: b: m: 
        let
          a' = toString a;
          b' = toString b;
        in
          m // { "${a'}" = m."${b'}"; "${b'}" = m."${a'}"; };

      theButtonMapping = pipe baseButtonMapping [
        # the southpaws reswap
        (swapButtons 1 3)
        # 8 is really anoying with this mouse (upper side button) as Firefox interprets it
        # as "history back" and that screws up long forms if pressed accidentally
        (disableButton 8)
        attrValues
        toString
      ];
    in
    [
    ''
      Identifier      "Evoluent Southpaws Vertical Mouse"
      MatchProduct    "Kingsis Peripherals Evoluent VerticalMouse 4 Left"
      MatchIsPointer  "on"
      Option          "ButtonMapping" "${theButtonMapping}"
    ''
    ];

    layout = "pl";
    xkbOptions = "caps:ctrl_modifier";

    desktopManager = {
        xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        feh
        # TODO: does this look like fun? 
        # https://github.com/Shizcow/dmenu-rs
        dmenu  # note: this is patched in an overlay
        # TODO: move this overlay here?
        i3lock-color
        i3blocks
        networkmanager_dmenu
        networkmanagerapplet
        dunst

        # TODO: move this to a `package` stanza
        xorg.xwininfo
        brightnessctl
        acpilight # this is needed for `xbacklight` - for reporting
        xorg.xev
        xorg.xmodmap
        xcape
        xclip
        escrotum
        scrot # for locking, because escrotum is too slow :c
        conky
        numlockx
        redshift
        unclutter
        screenkey # displays pressed keys, cool for presentations
        rxvt_unicode
        pasystray
        parcellite
        workrave

        # TODO: call package or something? make it work
        # TODO: now link this to the launcher script
        # TODO: contribute this to nixpkgs
        #stdenv.mkDerivation rec {
          #pname = "i3blocks-contrib";
          ## not sure if there really is a versioning shcheme since it's a collection of scripts
          #version = "9d66d81da8d521941a349da26457f4965fd6fcbd";

          #src = fetchFromGitHub {
            #owner = "vivien";
            #repo = pname;
            #rev = version;
            #hash = "sha256-iY9y3zLw5rUIHZkA9YLmyTDlgzZtIYAwWgHxaCS1+PI=";
          #};

          #meta = with lib; {
            #description = "Set of scripts (a.k.a. blocklets) for i3blocks, contributed by the community";
            #homepage = "https://github.com/vivien/i3blocks-contrib";
            #license = licenses.gpl3;
            ## but... the scripts themselves may be more permissive
            #platforms = with platforms; freebsd ++ linux;
          #};
        #}
      ];
    };
  };

  # fix for Workrave not persisting settings
  # TODO: actually - is this still relevant?
  programs.dconf.enable = true;
}
