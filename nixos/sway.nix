{ config, lib, pkgs, ... }:

{
  # Display Mananger
  services.displayManager.ly.enable = true;
 
  # Window Manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    git
    curl
    fastfetch
    htop
    neovim
    foot
    rofi
    brightnessctl
    playerctl
    waybar
    bluetui
    cliphist
    wl-clipboard
    mako
    nnn
  ];

  # System Services
  services.power-profiles-daemon.enable = true;
  
  # Environment Variables
  environment.variables = { 
    SWAY_UNSUPPORTED_GPU = "true";
  };
}
