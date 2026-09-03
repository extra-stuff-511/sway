{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Nix Services
  nix.gc.automatic  = true;
  nix.gc.dates  = "03:00";

  # VM Guest
  #services.spice-vdagentd.enable = true;
  #services.xserver.videoDrivers = [ "modesetting" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;



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



  # Networking
  networking.hostName = "CrescentLibrary";
  networking.networkmanager.enable = true;



  # Timezone
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_GB.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };



  # X11
  #services.xserver.enable = true;
  #services.xserver.excludePackages = [ pkgs.xterm ];



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
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = [ "kvm-amd" ];



  # Packages
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;
  services.syncthing.enable = true;

  environment.systemPackages = with pkgs; [
    git
    openssh
    curl
    wget
    fastfetch
    neovim
    firefox-esr
    timeshift
  ];



  # Desktop Environment
  hardware.graphics.enable = true;
  security.polkit.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    extraPackages = with pkgs; [
      foot
      fuzzel
      mako
      swaylock
      swayidle
      swaybg
      grim
      slurp
      wl-clipboard
      brightnessctl
      waybar
      swayosd
      cliphist
      libnotify
      bluetui
      lf
      imv
      zathura
      moc
      swappy
    ];
  };



  # Services
  services.openssh.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;


  system.stateVersion = "26.05";

}
