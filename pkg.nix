{ config, pkgs, callPackage, ... }: 
{
    environment.systemPackages = with pkgs; [
        python27
        python3

        htop
        tmux # terminal multiplexer
        ranger # file exploler

        dotfiles

        direnv
        vimHugeX
        hexcurse

        xorg.xmodmap
        xcape
        xclip
        scrot
        conky
        imagemagick

        evince
        vlc
        gnome3.eog # TODO: drop in favour of feh?

        workrave
        redshift

        arandr
        screenkey # displays pressed keys, cool for presentations

        rxvt_unicode
        #urxvt_font_size # TODO: how to make this work?

        graphviz

        unzip # TODO: vs unzipNLS?

        mkpasswd

        firefox

        gnumake # build / script automation
        expect # interactive script automation utility
        git
        ansible 

        jq # manipulate JSON

        dnsutils
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

