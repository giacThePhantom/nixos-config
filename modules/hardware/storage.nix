# Secondary drives. Mounted on first access (automount) so they never slow
# down or block boot; `nofail` keeps booting if one is unplugged.
{
  flake.modules.nixos.storage =
    let
      common = [
        "nofail"
        "noatime"
        "x-systemd.automount"
        "x-systemd.idle-timeout=10min" # unmount (and let the HDD spin down) when idle
      ];
      # ntfs3: the in-kernel NTFS driver, much faster than ntfs-3g (FUSE).
      # NTFS has no Unix owners, so files appear as yours.
      ntfs = common ++ [
        "uid=1000"
        "gid=100"
        "dmask=022"
        "fmask=133"
      ];
    in
    {
      # Drives by UUID or label: sda/sdb/sdc can swap between boots
      fileSystems."/mnt/data" = {
        device = "/dev/disk/by-uuid/CC8EDE358EDE17B2"; # NTFS "Data", 1.8T
        fsType = "ntfs3";
        options = ntfs;
      };

      # 1 TB Seagate HDD, formatted with `mkfs.ext4 -L data2` (docs/11:
      # "A new drive"); the root of an ext4 drive belongs to root until you
      # chown it
      fileSystems."/mnt/data2" = {
        device = "/dev/disk/by-label/data2";
        fsType = "ext4";
        options = common;
      };

      fileSystems."/mnt/fast" = {
        device = "/dev/disk/by-uuid/0e7d16cc-44b8-4e94-8d43-dc18b0d9d5f4"; # ext4 "fast_data", 149G
        fsType = "ext4";
        options = common;
      };
    };
}
