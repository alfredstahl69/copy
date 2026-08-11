{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-diskseq/1"; # Wird von disko-install überschrieben
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "2G"; # Auf 2 GB erweitert für mehrere NixOS-Generierungen
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
                extraArgs = [ "-n" "NIXOS_BOOT" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-L" "NIXOS_ROOT" ];
                subvolumes = {
                  "/rootfs" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "/home/user" = { };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # Btrfs Subvolume für eine echte 4GB Swapfile
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "4G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
