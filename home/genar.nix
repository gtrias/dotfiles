{ config, pkgs, lib, inputs, ... }:
{
  home.username = "genar";
  home.homeDirectory = "/home/genar";
  home.stateVersion = "25.05";

  programs.bash.enable = true;
  programs.bash.initExtra = ''
    # Migrate useful aliases from legacy/zsh/zshrc and legacy/shells-common here.
  '';

  programs.git.enable = true;

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type file --hidden --follow --exclude .git";
  };

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

  # Zen Browser (youwen5/zen-browser-flake): prebuilt upstream binary wrapped
  # via wrapFirefox, auto-updated upstream. Shared home => every host that
  # imports this config gets it (vm today; kelymaster/slimbook in sub-project 5).
  #
  # Terminal QoL: fast search/list (ripgrep + fd), JSON (jq), highlighted
  # output (bat), and a TUI resource monitor (btop). Fzf is wired via
  # programs.fzf above so it installs the binary AND the shell keybindings.
  home.packages = with pkgs; [
    ripgrep fd jq bat btop
    jetbrains-mono
    noto-fonts-color-emoji
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Later sub-projects:
  #   3 — Neovim (port legacy/nvim/init.lua) + Node.js
  #   4 — Catppuccin palette for gnome-terminal (extraConfig)
}
