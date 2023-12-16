{ config, pkgs, ... }: 
let
in
{
  environment.systemPackages = with pkgs; [
    autojump
  ];
  systemd.services.autojump-purge = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      User = "allgreed";
    };
    script = ''
        export PATH=$PATH:/run/current-system/sw/bin
        # I need to convince autojump that I know what I'm doing
        AUTOJUMP_SOURCED=1 autojump --purge
    '';
  };
  systemd.timers.autojump-purge = {
    wantedBy = [ "timers.target" ];
    partOf = [ "autojump-purge.service" ];
    timerConfig = {
      OnCalendar = "*-*-* 0:00:00";
      Unit = "autojump-purge.service";
    };
  };
}
