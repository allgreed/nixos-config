{ config, pkgs, callPackage, ... }: 
{
    nixpkgs.config.allowUnfree = true; # for rambox and virtualbox oracle extension pack

    environment.systemPackages = with pkgs; [
        python27
        python3

        htop
        tmux # terminal multiplexer
        ranger # file exploler

        manpages

        dotfiles

        direnv
        vimHugeX
        hexcurse

        python37Packages.click # mostly for caching

        xorg.xev
        xorg.xmodmap
        xcape
        xclip
        scrot
        conky
        imagemagick

        pavucontrol

        evince
        vlc
        mpv
        gnome3.eog # TODO: drop in favour of feh?
        gimp

        workrave
        redshift

        arandr
        powertop

        screenkey # displays pressed keys, cool for presentations

        rxvt_unicode
        #urxvt_font_size # TODO: how to make this work?

        graphviz

        unzip # TODO: vs unzipNLS?

        mkpasswd

        firefox
        rambox

        gnumake # build / script automation
        expect # interactive script automation utility
        git
        ansible 

        jq # manipulate JSON

        dnsutils
        wavemon
        sshfs
        dhcp
        # curl 
        # net-tools
        # openvpn
        # wireshark # packet sniffing / analyzing
        # wakeonlan
        # nmap
        # whois
        # arp-scan # arp discovery
    
        # pip ptpython # improved Python shell
        # pip pygments-style-solarized # colorscheme
        # pip pirate-get # command line for the pirate bay
    ];
}

