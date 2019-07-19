{ config, pkgs, callPackage, ... }: 
{
    networking.networkmanager.enable = true;
    
    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];

    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    environment.systemPackages = with pkgs; [
    # curl 
    # net-tools
    # openvpn
    # wireshark # packet sniffing / analyzing
    # wakeonlan
    # nmap
    # whois
    # arp-scan # arp discovery
    ];

}

