{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # GRUB setup
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.device = "/dev/disk/by-id/virtio-13377333";

  networking.hostName = "markv";
  networking.hostId = "8425e349";
  networking.useDHCP = false;
  networking.interfaces.enp1s0.useDHCP = true;
  networking.timeServers = [ "time.cloudflare.com" "2.ee.pool.ntp.org" "2.europe.pool.ntp.org" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 334 ] ++ [ 25 143 465 587 ] ++ [ 4001 ];
    allowedUDPPorts = [ 4001 ];
  };

  console.font = "Lat2-Terminus16";
  console.keyMap = "us";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";

  environment.systemPackages = with pkgs; [
    curl
    htop
    neovim
    tmux
    zsh
    rsync
  ];

  programs.mtr.enable = true;

  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay";
    liveRestore = false;
    listenOptions = [ "/run/docker.sock" "/run/zentria/docker/docker.sock" ];
    daemon.settings = {
      userland-proxy = false;
    };
  };

  # OpenSSH
  services.openssh = {
    enable = true;
    startWhenNeeded = false;

    listenAddresses = [
      {
        addr = "192.19.18.166";
        port = 22;
      }
      {
        addr = "0.0.0.0";
        port = 334;
      }
    ];

    permitRootLogin = "no";
    gatewayPorts = "no";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;

    extraConfig = with config.users; ''
      VersionAddendum teapot

      AllowGroups ${groups.canssh.name} wheel
      Match Group wheel
          AllowAgentForwarding yes
          AllowTcpForwarding yes
          GatewayPorts clientspecified
          PermitTunnel yes
          PasswordAuthentication no
          KbdInteractiveAuthentication no
          PubkeyAuthentication yes

      Match Group ${groups.canssh.name}
          PubkeyAuthentication yes
          PasswordAuthentication yes
          KbdInteractiveAuthentication yes
    '';
  };

  security.sudo.wheelNeedsPassword = false;
  hardware.ksm.enable = true;

  # Shells and users
  programs.zsh.enable = true;

  users = {
    users = {
      mark = {
        description = "Mark V.";
        shell = pkgs.zsh;
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" "proc" ];
        subUidRanges = [{ startUid = 50000; count = 4000; }];
        subGidRanges = [{ startGid = 50000; count = 4000; }];
      };

      # Actually mark
      #minecraft = {
      #  shell = pkgs.bash;
      #  isNormalUser = true;
      #  extraGroups = ["canssh"];
      #};

      #ardi = {
      #  description = "Ardi K.";
      #  shell = pkgs.bash;
      #  isNormalUser = true;
      #  extraGroups = [];#"canssh"];
      #};
      #erik = {
      #  description = "Erik K.";
      #  shell = pkgs.bash;
      #  isNormalUser = true;
      #  extraGroups = []; #"canssh"];

      #  openssh.authorizedKeys.keys = [
      #    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5b3T3FShms52kUl7X+gn6OhC7InAPgeSyN9AogpOPekGM6tk3cc71yWoaypT8zWW2/3PlBbas1VDC/FNzJSd4NuBzUQ7MDVJMPmTLicQjwJAyGV1c+6baTciGCbheX+o/O2lqDTEawSMpcN/OgqhbuQ7t7ow70Kyvcuq615D2cHFisvTOPhzHlCwDfuhSSShzlkCdqvVCiVq2HKfkQ1Uft5FEciSXtCme1l1DhzAK3t3/L8WQ5VSg5WclL7udxeN/I9EEOTR24/PjZ6O/Tharq8brUglW+ZD/lH1kBXItg4W4U5PCAZXTzm5GKNAlB2qJWdj2n/VV/fCsDeWo+kBh erik@iota.local"
      #  ];
      #};
      teetandreas = {
        description = "Teet Andreas S.";
        shell = pkgs.bash;
        isNormalUser = true;
        extraGroups = [ ]; #"canssh"];
      };

      rebane = {
        description = "";
        shell = pkgs.bash;
        isNormalUser = true;
        extraGroups = [ ]; # "canssh" ];

        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3vZShHRvEQr0JQaSUxYeSIR4/cuMlgoQJILt+Z2urXVpufJhwZE2mh4WF28Ue2672Rdw2fy6Sn5ELIsVoy4IqiCTC30KHBXjPGZFB8g6VerbPseeU4oRtRtAfOOv6E/nAta6/ZnpA/wDaZnCXWMTMHra1/c20kanQsfzRQGvBvK8SexiTyALrYiXBaixDxnAeL8djyIYAX7Ux9G/dz0HrGTdirE7dpr9KosSGXb3zAth9oZ1RFTvySGChvcgeImZlNwv9Mtal3tROmQ8/UVX6+KVtQTcYEgeFnqaRyz4t3Voficf3TiFTWmlBGITWtFlDPHQCdEgxCufkNkbEEmMpW22Uq/cU0vrUDv9IsTgPPnhfxlg90RkTuBrGfw45oH2lM7vPUavhRaTGr/rcbEjp4o28Y/kEU3wqNtQ2+MmkRjVpSR7UxcMEYdNA/cUiux0B6Pe5h0bGjUMSjz8sPtAIeUmtVecqFaO+CrFr1GUaa8aExye9le2O4fbuDG94jL0+h+W8FgRKPVtNmi/ed99nkYsFSgSOA3KIUgku1EDqzhRK1ijDyi+t+7nKg0G/XNHAfwHYk0DN/+KhIuXV1MHXqSv1xrosXRvkIvHCH7xZFaJyl2BVC9DU/oJGYnv++xMJtL1sepq+y5czzjSWcb71svkBjAr2paiSRKxkThR7iw== Rebane@Graphy"
        ];
      };
    };
    groups = {
      canssh = { };
    };
  };

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.00"; # Did you read the comment?
}

# vim: ft=nix:et:sw=2:sts=2
