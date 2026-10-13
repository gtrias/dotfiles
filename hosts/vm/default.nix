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

  # sshd so the 2222->22 forward is meaningful; key-only, host key authorized
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvjD+20/vAXvvlMgeCxXvbxpMJrBKOqcVZPG2InIRPw5lVBUmxI/RwKSxR03pZJwie8k+zQgc7siuFZyIKKt16684Oqbzy+12bwUf7YgR1HY6ovEnILixseYunpU1uz3IGQGxcN6ck6uxo1mJ29u6fLDJNblihE2vU+eRWlc8bLCnqdfnZXmzBboV0Zwy+w7JhUZsAsnXktiXpF0IdX271SH5FArs03BvwshtHZDwcu7q6DtfXa3N7XCVYy8hpz6O4+snTBhyFYMKUC1ve0vg4FfFG8ckIYS2nmia3vQUQo9L+L0q1mXYyb4E5f/ns5lfTNArgG2iYRrequrcMF6kp host@kelymaster"
    ];
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
