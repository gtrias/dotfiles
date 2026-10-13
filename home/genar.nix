{ config, pkgs, lib, ... }:
{
  home.username = "genar";
  home.homeDirectory = "/home/genar";
  home.stateVersion = "25.05";

  programs.bash.enable = true;
  programs.bash.initExtra = ''
    # Migrate useful aliases from legacy/zsh/zshrc and legacy/shells-common here.
  '';

  programs.git.enable = true;

  programs.gnome-terminal = {
    enable = true;
    # Profile keys MUST be UUIDs and exactly one must be default = true
    # (home-manager's module does lib.head over the default-marked profiles).
    profile."061d5d28-0cf1-4a6b-a390-125de256de41" = {
      default = true;
      visibleName = "default";
      # Catppuccin palette goes here in sub-project 4.
    };
  };

  # Later sub-projects:
  #   3 — Neovim (port legacy/nvim/init.lua) + Node.js
  #   4 — Catppuccin palette for gnome-terminal (extraConfig)
}
