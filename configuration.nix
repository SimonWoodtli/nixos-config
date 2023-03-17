# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# Variables:
let
  user="xnasero";
in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

# Bootloader
  boot = {
    # Get latest Kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # Use AMD GPU Module
    initrd.kernelModules = ["amdgpu"];
    loader = {
      timeout = 1;
      systemd-boot = {
        enable = true;
        configurationLimit = 5; # only keep 5 generations
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };
# NixOS settings
  system = {    
    autoUpgrade = { # Enable Auto Upgrade software
      enable = true;
      channel = "https://nixos.org/channels/nixos-22.11";
    };
    stateVersion = "22.11";
  };
# XDG Compliant
  use-xdg-base-directories = true

## 
  nix = {     # Nix Package Manager settings
    settings.auto-optimise-store = true; # Optimise syslinks
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d"; # Delete packages that are unused and older than 10d
    };
  };

# Networking
  networking = {
    hostName = "skynet"; # Define your hostname.
    networkmanager.enable = true;  # Enable networking
  # enable/config networking interfaces don't have to be in hardware-configuration, you can also write them here
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
# Time zone and internationalisation
  time.timeZone = "America/Chicago"; # Set your time zone.
  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties.
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkbOptions in tty.
  };

# Xserver
  services.xserver = {
    enable = true; # Enable the X11 windowing system.
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "30"
        Option "OffTime" "0"
    '';
  };

# Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    #xkbOptions = {
    #  "eurosign:e";
    #  "caps:escape" # map caps to escape.
    #};
  };

# Enable CUPS to print documents.
  services.printing.enable = true;

# Enable sound with pipewire.
  sound = {
    enable = true;
    #mediaKeys.enable = true;
  };
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

# If you use pipewire you cannot use this too
# Enable Bluetooth
#  hardware.bluetooth = {
#    enable = true;
#    hsphfpd.enable = true; # HSP & HFP daemon
#    settings = {
#      General = {
#        Enable = "Source,Sink,Media,Socket";
#      };
#    };
#  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

# Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${user}";
    extraGroups = [ "wheel" "video" "camera" "audio" "lp" "networkmanager" "scanner" "kvm" "libvirtd" ];
    shell = pkgs.bash;  # default shell
    # Packages only for specific user installed:
    packages = with pkgs; [
      brave
      gnome.gnome-terminal
    ];
  };

# Security
  security = {
    sudo.wheelNeedsPassword = false;
  };
# Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "${user}";
# Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;


# Programs that run as a daemon/server are better to be installed with services.packagename.enable = true; that would install the program but also set it up automatically as a running service. Otherwise you need to do that manually.
# List packages installed in system profile. To search, run:
  # $ nix search wget

# Packages systemwide installed:
  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    killall
    usbutils
    pciutils
  ];
# Enable unfree software
  nixpkgs.config.allowUnfree = true; # Allow proprietary software

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

## Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };

environment = {
  variables = {
    TERMINAL = "alacritty";
    EDITOR = "vim";
    VISUAL = "vim";
  };

# Flatpak
  flatpak.enable = true;
  xdg.portal = {   # Required for flatpak
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

fonts.fonts = with pkgs; [ # Fonts
  source-code-pro
  font-awesome
  corefonts
  (nerdfonts.override {
    fonts = [
      "FiraCode"
    ];
  })
];
    


# SSH
  #openssh = {
  #  enable = true;
  #  allowSFTP = true;
  #};
  #sshd.enable = true;



  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
}
