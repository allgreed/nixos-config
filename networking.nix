{ config, pkgs, callPackage, ... }: 
{
  networking.networkmanager = {
    enable = true;
    dns = "dnsmasq";
  };

  services.dnsmasq = {
    enable = true;

    servers = [
      # TODO: inform me if the query had to be resolved by backup and actually enable backup
      "195.10.195.195"
      "194.36.144.87"
      "91.217.137.37"
      "94.247.43.254"

      # backup
      #"1.1.1.1"
      #"8.8.8.8"
    ];

    extraConfig = ''
      cache-size=10000
      local-ttl=3600
      no-resolv
      no-poll
    '';

    resolveLocalQueries = true;
  };
    
  # Open ports in the firewall.
  # jellyfin
   networking.firewall.allowedTCPPorts = [ 8096 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}

