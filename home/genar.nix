{ config, pkgs, lib, ... }:
{
  home.username = "genar";
  home.homeDirectory = "/home/genar";
  stateVersion = "25.05";

  programs.bash.enable = true;
  programs.bash.interactiveShellInit = ''
    # Migrate useful aliases from legacy/zsh/zshrc and legacy/shells-common here.
  '';

  programs.git.enable = true;

  programs.gnome-terminal.enable = true;

  # Later sub-projects:
  #   3 — Neovim (port legacy/nvim/init.lua) + Node.js
  #   4 — Catppuccin palette for gnome-terminal (extraConfig)
}
