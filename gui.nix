{ config, pkgs, lib, callPackage, ... }: 
{
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw  ???? --- what does this do?? xD

  fonts.packages = with pkgs; [
    source-code-pro
    #font-awesome-ttf
    # FIXME: how is it called now? ^
    # serif
    crimson # just nice
    ferrum  # more like fantasy or fancy wild west
    junicode # medival
    # snas
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
      # TODO: refactor!
      range = lib.lists.range;
      imap1 = lib.lists.imap1;
      pipe = lib.trivial.pipe;
      at1 = l: i: builtins.elemAt l (i - 1); # complements imap1
      baseButtonMapping = range 1 8; # so 1=1, 2=2, etc.
      disableButton = button: mapping: imap1(i: v: if i == button then 0 else v) mapping;
      swapButtons = a: b: mapping: imap1(i: v: if i == a || i == b then (if i == a then at1 mapping b else at1 mapping a) else v) mapping;
      theButtonMapping = pipe baseButtonMapping [
        # the southpaws reswap
        (swapButtons 1 3)
        # 8 is really anoying with this mouse (upper side button) as Firefox interprets it as "history back" and that screws up long forms if pressed accidentally and then you have to fill that fucking form agaINIHATEFILLINGFORMS
        (disableButton 8)
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
        dmenu
        # FIXME: fix the patches!
        # TODO: also apply the same patches to the nm-util, can I just override? :D
        #(dmenu.overrideAttrs (oldAttrs: rec {
          #patches = [
            #(fetchpatch {
              #url = "https://tools.suckless.org/dmenu/patches/solarized/dmenu-solarized-light-5.0.diff";
              #sha256 = "0dwzf8aj8lvfqggb1lb1ds0r021dppxayg9gkrvr3004pgc0zwnq";
            #})
            #(fetchpatch {
              #url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
              #sha256 = "0clczp17zwkxy1qhy0inqjplxpq4mgaf4vvfvn063hk733r4i7rn";
            #})
            #(fetchpatch {
              #url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.0.diff";
              #sha256 = "16aqbyp3mg2cgnm8dysbdgcdhh3r6k2fsw1cxzrkka22hvi73paa";
            #})
            #(fetchpatch {
              #url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-4.9.diff";
              #sha256 = "000fkg4dcr2vrpd442f2v6ycmmxdml781ziblzx5rxvvyclsryfd";
            #})
          #];
        #}))
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
        #workrave
        #FIXME: fix this!!!
        ];
      };
  };

  # fix for Workrave not persisting settings
  # FIXME: FIX THIS HOW IS IT CALLED NOW?
  # TODO: should this be together in a module maybe?
  #services.dbus.packages = with pkgs; [ gnome3.dconf ];
}

