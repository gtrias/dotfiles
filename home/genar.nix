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

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    # Built-in Python/Ruby providers (home-manager flipped these defaults to
    # false in this rev; LazyVim's LSPs + several plugins need them).
    withPython3 = true;
    withRuby = true;
    # Self-contained LazyVim bootstrap: on first `nvim` launch it clones
    # lazy.nvim + installs the full LazyVim plugin set under
    # ~/.local/share/nvim/lazy; on later launches it just loads them.
    # Catppuccin is LazyVim's default colorscheme. (Embedded as initLua so no
    # separate tracked file is needed by the flake.)
    initLua = ''
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
          vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
          vim.fn.getchar()
          os.exit(1)
        end
      end
      vim.opt.rtp:prepend(lazypath)
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "
      require("lazy").setup({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        },
        defaults = { lazy = false, version = false },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = { enabled = true, notify = false },
        performance = {
          rtp = {
            disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
          },
        },
      })
    '';
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
  #   3 — Neovim: done (LazyVim via programs.neovim.initLua above). Optional:
  #        withNodeJs for JS/TS LSPs (lazy-dev/mason can also install them).
  #   4 — Catppuccin palette for gnome-terminal (extraConfig).
}
