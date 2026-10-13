{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  networking.hostName = "vm";
  system.stateVersion = "25.05";

  # 8 cores / 4 GB / 1920x1080, GTK display, tablet + keyboard
  virtualisation.memorySize = 4096;
  virtualisation.cores = 8;
  virtualisation.resolution = { x = 1920; y = 1080; };
  virtualisation.qemu.options = [
    "-display gtk"
    "-device virtio-vga"
    "-device usb-tablet"
    "-device usb-kbd"
  ];
  virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
  ];

  # Better VM integration
  services.spice-vdagentd.enable = true;
  boot.kernelModules = [ "uinput" "evdev" "virtio_gpu" ];

  # Display: GNOME desktop + gdm + auto-login (replaces knoopx's greetd + niri-session)
  services.displayManager.gdm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "genar";
  };
  services.desktopManager.gnome.enable = true;

  users.users.genar = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "audio" "video" "input" ];
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
