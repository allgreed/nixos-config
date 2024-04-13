{ pkgs, ... }: 
let 
  homeExcludes = [
    # for now
    ".config/Rambox/"
    ".arduino15"

    # caches
    ".cache"
    ".kube/cache"
    # via doas find /home/allgreed/ -name "CACHEDIR.TAG" | grep -v .pytest_cache | grep -v .cache
    # I'm paranoid, so don't want to go down the --exclude-caches road
    # https://bford.info/cachedir/
    # this is a great idea, but should IMO be more paranoid by default and have a --yolo switch
    # so I'd see issuance of a warning if a cache is to be backed up, so that the operator can add it
    # to the exclude list
    "Projects/doas-deauthenticate/target/"
    ".dvdcss"

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

    # should be regularely cleaned - and is quite easily rebuildable
    # since I can re-download things if I had downloaded them once
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
      "notify-problems@" = {
        enable = true;
        serviceConfig.User = "allgreed";
        environment.SERVICE = "%i";
        # TODO: later - how retarded is this? o.0
        # TODO: get rid of /run/current-system/sw/bin/
        script = ''
          export $(/run/current-system/sw/bin/cat /proc/$(/run/current-system/sw/bin/pgrep "xinit" -u "$USER")/environ | grep -z '^DBUS_SESSION_BUS_ADDRESS=')
          /run/current-system/sw/bin/dunstify -a borgbackup-service "backup failed" "$SERVICE and needs to be retriggered manually" -u 2
        '';
      };
    } // flip mapAttrs' config.services.borgbackup.jobs (name: value:
      nameValuePair "borgbackup-job-${name}" {
        unitConfig.OnFailure = "notify-problems@%i.service";
        # there was something something wanting network target, not sure if that's better
        # or wasn't chosen because is somewhat problematique
        preStart = let
          target = builtins.elemAt (strings.splitString ":" value.repo) 0;
          ssh = "${pkgs.openssh}/bin/ssh";
          sleep = "${pkgs.coreutils}/bin/sleep";
        in 
        lib.mkBefore ''
          echo checking connectivity to ${target}...
          until ${ssh} ${target} exit >/dev/null 2>&1; do ${sleep} 1; done
          echo got it!
        '';
      }
    );
  };
  homeJobTemplate = rec {
      user = "allgreed";
      paths = "/home/allgreed";
      exclude = excludesWithPath paths homeExcludes;
      environment.BORG_RSH = "ssh -F /home/allgreed/.ssh/config";
      encryption = {
        mode = "repokey"; 
        passCommand = "${pkgs.bash}/bin/bash /home/allgreed/Keys/remote-backup";
      };
      startAt = "daily";
      archiveBaseName = "sarah-home";
      persistentTimer = true;
      extraCreateArgs = let 
        checkpointMinutes = 5;
        secondsInMinutes = 60;
      in "--verbose --stats --checkpoint-interval ${toString (secondsInMinutes * checkpointMinutes)}";
      # 5 minutes should be enough for reliability on slow, spotty connections  or with large backups
      # and to not casue problems on fast, incremental ones
  };
in 
{
  imports = [
    borgbackupMonitor
  ];
  services.borgbackup.jobs = {
    home = homeJobTemplate // {
      # TODO: later - mk borg user, maybe even nixos anywhere xD
      #environment.BORG_RELOCATED_REPO_ACCESS_IS_OK="yes";
      repo = "root@remote-backup:.";
    };
    home2 = homeJobTemplate // {
      # maaaybe drop the repokey and just don't encrypt on borg level once the actual drives are encrytped locally
      repo = "borg@local-backup:.";
      prune.keep = {
        within = "7d";
        weekly = 4;
        # this is beyond my ZFS snapshots
        monthly = -1; 
      };
    };
  };
}
