{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # --- BOOTLOADER & HARDWARE FIXING ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10; # Verhindert volles /boot
  boot.loader.efi.canTouchEfiVariables = false;     # Verhindert NVRAM-Fehler auf Fremd-PCs

  # Fügt Memtest86+ direkt als Auswahloption ins Bootmenü ein!
  boot.loader.systemd-boot.memtest86.enable = true;

  # --- KERNEL MODULE FÜR USB-C, THUNDERBOLT & NVMe ---
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usb_storage" "uas"
    "sd_mod" "nvme" "thunderbolt" "usbhid" "rtsx_pci_sdmmc"
  ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

  # --- HARDWARE KOMPATIBILITÄT ---
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "modesetting" "fbdev" "amdgpu" "nvidia" "nouveau" ];

  # ZRAM (Arbeitsspeicher-Kompression im RAM, schont USB-NVMe Schreibzyklen)
  zramSwap.enable = true;

  # --- NETZWERK & SYSTEM ---
  networking.hostName = "portable-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  users.users.user = {
    isNormalUser = true;
    description = "Portable Administrator";
    extraGroups = [ "networkmanager" "wheel" "disk" ];
    initialPassword = "nixos";
  };

  # --- COMPREHENSIVE TROUBLESHOOTING TOOLKIT ---
  environment.systemPackages = with pkgs; [
    # Disk & System Diagnostics
    smartmontools   # Festplatten-Gesundheit (smartctl)
    nvme-cli        # NVMe SSD Status & Spezifische Tests
    btrfs-progs     # Btrfs Repairs & Scrubbing
    parted          # Partitionstabellen-Analyse
    gparted         # CLI/TUI Tools für Dateisysteme
    testdisk        # Daten- & Partitions-Wiederherstellung
    ddrescue        # Rettung defekter Datenträger

    # Hardware Specs & Monitoring
    pciutils        # lspci
    usbutils        # lsusb
    lshw            # Komplette Hardware-Auflistung
    dmidecode       # Mainboard, BIOS & RAM-Details
    lm_sensors      # Temperatur- & Spannungssensoren
    ethtool         # Netzwerkkarten-Diagnose
    nvtopPackages.full # GPU-Auslastung (Nvidia, AMD, Intel)
    btop            # Systemmonitor

    # Network Diagnostics
    nmap            # Portscan & Netzwerkanalyse
    iperf3          # Netzwerk-Bandbreitentests
    wirelesstools   # WLAN-Analyse
    tcpdump         # Paket-Sniffer
    iproute2
    dnsutils        # dig, nslookup

    # Core CLI Tools
    git
    curl
    wget
    vim
    htop
  ];

  # Automatisches Aufräumen von alten Kernel-Generierungen
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.11";
}
