{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Nix Services
  nix.gc.automatic  = true;
  nix.gc.dates  = "03:00";
  nix.optimise = {
    automatic = true;
    dates = [ "03:30" ];
  };
  nix.settings.experimental-features = [ "nix-command" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;


  # Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];




  # Battery Charge Limit
  systemd.services.battery-charge-limit = {
    description = "Set battery charge limit";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT1/charge_control_end_threshold'";
    };
  };



  # Networking + Bluetooth
  networking.hostName = "CrescentLibrary";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  hardware.bluetooth.enable = true;


  # Timezone
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };



  # X11
  # services.xserver.enable = true;
  # services.xserver.excludePackages = [ pkgs.xterm ];



  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };



  # Touchpad
  services.libinput.enable = true;



  # Users
  users.users.adeline = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
  };


  # Virtualisation
  # virtualisation.libvirtd.enable = true;
  # boot.kernelModules = [ "kvm-amd" ];


  # Packages
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
  # programs.steam.enable = true;
  # services.syncthing.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    fastfetch
    neovim
    firefox-esr
  ];



  # Desktop Environment
  hardware.graphics.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    extraPackages = with pkgs; [
      foot
      fuzzel
      swaybg
      swaylock
      brightnessctl
      playerctl
      waybar
      bluetui
      cliphist
      wl-clipboard
      mako
    ];
  };

  environment.sessionVariables = {
    SWAY_UNSUPPORTED_GPU = "1";
  };


  # System Services
  services.power-profiles-daemon.enable = true;


  # OS Version
  system.stateVersion = "26.05";

}
