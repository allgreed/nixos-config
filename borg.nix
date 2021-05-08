{ config, pkgs, callPackage, ... }: 
let 
  homeExcludes = [
    # for now
    ".config/Rambox/"
    ".arduino15"

    # caches
    ".cache"
    ".kube/cache"

    # easily rebuildable
    ".vim"
    "*/node_modules"
    "*/bower_components"
    "*/_build"
    "*/.tox"
    "*/venv"
    "*/.venv"
    "*/__pycache__"
    "*/.pytest_cache"
    ".config/spotify/"

    # keys
    "Keys"
    ".serverauth.*"
    ".Xauthority"
    ".esd_auth"
    ".pki"

    # should be regularely cleaned
    "Downloads"

    # nothing of value
    ".zoom"
    ".mozilla" # all the settings via home-manager
    ".config/Microsoft/"
    ".config/google-chrome/"
  ];
  excludesWithPath = path: excludes: map (x: path + "/" + x) excludes;
  borgbackupMonitor = { config, pkgs, lib, ... }: with lib; {
    key = "borgbackupMonitor";
    _file = "borgbackupMonitor";
    config.systemd.services = {
      # TODO: uncomment and make sure it does what I want
      #"notify-problems@" = {
        #enable = true;
        #serviceConfig.User = "danbst";
        #environment.SERVICE = "%i";
        #script = ''
          #export $(cat /proc/$(${pkgs.procps}/bin/pgrep "gnome-session" -u "$USER")/environ |grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          #${pkgs.libnotify}/bin/notify-send -u critical "$SERVICE FAILED!" "Run journalctl -u $SERVICE for details"
        #'';
      #};
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        # TODO: uncomment and make sure it does what I want

        #unitConfig.OnFailure = "notify-problems@%i.service";
        # TODO: add sleep 1 instead of busy loop
        # TODO: use the backup host -> I don't actually care about google.com
        #/run/current-system/sw/bin/ssh
        preStart = lib.mkBefore ''
          until /run/wrappers/bin/ping google.com -c1 -q >/dev/null; do /run/current-system/sw/bin/sleep 1; done
        '';
      }
    );
  };
in 
{
  imports = [
    borgbackupMonitor
  ];
  services.borgbackup.jobs = {
    home = rec {
      encryption.mode = "repokey";
      encryption.passCommand = "/run/current-system/sw/bin/sh /home/allgreed/Keys/remote-backup";
      environment.BORG_RSH = "ssh -F /home/allgreed/.ssh/config";
      environment.BORG_RELOCATED_REPO_ACCESS_IS_OK="yes";
      extraCreateArgs = "--verbose --stats --checkpoint-interval 600 --exclude-caches";
      repo = "ssh://remote-backup/data/backups/sarah";
      startAt = "daily";
      user = "allgreed";
      paths = "/home/allgreed";
      exclude = excludesWithPath paths homeExcludes;
      readWritePaths = [
        "/var/state/borgjobs"
      ];
      postCreate = ''
        echo 
        mkdir -p /var/state/borgjobs/home/last
        echo "$archiveName" > /var/state/borgjobs/home/last/archive
        date --utc +%s > /var/state/borgjobs/home/last/time
      '';
    };
  };
  environment.etc."borgjobs/home/borgignore" = {
    # TODO: that's actually exclude from above (the second arg)
    text = builtins.concatStringsSep "\n" (excludesWithPath "/home/allgreed" homeExcludes);
    mode = "0444";
  };
}
