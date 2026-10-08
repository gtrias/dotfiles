# Design — `nixos-config` VM Scaffold (Sub-project 1)

Date: 2026-10-08
Status: approved
Repo: `github.com/gtrias/dotfiles` (to be renamed `nixos-config` at the user's convenience; old URL redirects)

## 1. Problem

The repo at `~/dotfiles` has stopped serving its owner. It is a 2020-era fork of
anishathalye's dotbot template: everything is vendored as git submodules
(oh-my-zsh **and** prezto, neobundle vim **and** nvim, bash-it, powerline fonts,
dotbot+pyyaml), two window managers coexist (i3 + awesome) plus polybar, and the
last commit was 2024-02-13. On a modern system it is broken, heavy, and no longer
reproducible.

The owner wants a **NixOS + flakes + home-manager** personal operating system,
not "dotfiles". The goal is to share one configuration across several machines:

| Host         | Role                                  |
|--------------|---------------------------------------|
| `vm`         | QEMU iteration sandbox (this sub-project) |
| `kelycube`   | real machine (later)                   |
| `kelymaster` | this box, native install (later)       |
| `slimbook`   | laptop (later)                         |

Work is iterative over several days; the VM is the proving ground before flashing
a USB and installing natively.

Inspiration studied: **knoopx/nix** ("kOS" — the NixOS/flake/home-manager model
adopted) and **elboletaire/dotfiles** (classic bash-install model, used only as a
reference for what a clean non-Nix tree looks like; not followed).

## 2. Locked decisions

| Decision            | Choice                                                        |
|---------------------|---------------------------------------------------------------|
| OS                  | NixOS + flakes, `nixos-unstable` channel                     |
| Path                | VM scaffold first → iterate over days → flash USB native      |
| Desktop environment | GNOME (kept) — `xdg-desktop.gnome` + gdm                      |
| Login               | **auto-login** as `genar` (no greetd/tuigreet)                |
| Shell               | Bash (for now; one-line home-manager change to switch later)  |
| Terminal emulator   | GNOME Terminal                                                |
| Editor              | Neovim — port existing `init.lua` (sub-project 3)             |
| Theme               | Catppuccin, unified across GNOME / nvim / terminal (full pass = sub-project 4) |
| Dev toolchains (VM) | None on day one; Node.js added in sub-project 3, others later |
| User                | `genar`                                                       |
| Project name        | `nixos-config`                                                |

## 3. Decomposition (this spec = sub-project 1 only)

| # | Sub-project        | Contents                                                                                     | When        |
|---|--------------------|----------------------------------------------------------------------------------------------|-------------|
| 1 | **VM scaffold**    | flake, `hosts/vm`, GNOME + gdm + auto-login, user `genar`, bash, GNOME Terminal, Catppuccin base. **This spec.** | day 1 |
| 2 | Core system        | users, networking, Nix config, fonts, base packages; populate `modules/nixos`                | days 2–3  |
| 3 | home-manager stack | bash hardening, Neovim port, Node.js, more                                                   | days 3–4  |
| 4 | Theming pass       | Catppuccin fully unified (GNOME/nvim/terminal/icons/accents)                                  | later     |
| 5 | Real hosts         | `hosts/{kelymaster,kelycube,slimbook}` + hardware/GPU/per-host overlays                       | after VM  |
| 6 | Installer          | disko + bootable USB for native flash                                                        | last      |

## 4. Architecture

Shared-base + per-host-override: every host imports the same `modules/` + `home/`;
each `hosts/<machine>/` adds only its differences (hostname, display, hardware).
Change a shared setting once and it is identical on all machines.

```
nixos-config/
├─ flake.nix              # inputs: nixpkgs (nixos-unstable) + home-manager
│                         # nixosConfigurations.vm ; packages.x86_64-linux.default = the VM
├─ flake.lock
├─ README.md             # rewritten: build/run the VM + sub-project roadmap
├─ docs/superpowers/specs/   # this document and later sub-project specs
├─ hosts/
│  └─ vm/
│     ├─ default.nix     # qemu modules, gdm + gnome + auto-login, user, 8c/4g/1080p, 2222→22
│     └─ overlays.nix    # per-host overlays (empty now; grows)
├─ home/
│  └─ genar.nix         # shared home-manager: bash, gnome-terminal, catppuccin base
├─ modules/
│  ├─ nixos/            # shared NixOS base (spine now; populated in sub-2)
│  └─ home/             # shared home-manager base (spine now)
├─ lib/                  # shared helpers (spine now)
└─ legacy/               # all pre-Nix content, archived (see §6)
```

### 4.1 `flake.nix`

Minimal, two inputs. No `mkNixosModules` helper or `pkgs` indirection yet — those
arrive in sub-project 2 once `modules/nixos` has content.

```nix
{
  description = "nixos-config — personal NixOS system (kelycube, kelymaster, slimbook, vm)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    let
      inherit (inputs) nixpkgs home-manager;
      system = "x86_64-linux";
      specialArgs = inputs // { inherit inputs; };   # flake inputs visible to modules

      mkHost = hostModule:
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.genar = import ./home/genar.nix;
            }
            hostModule
          ];
        };

      vm = mkHost ./hosts/vm;
    in {
      nixosConfigurations.vm = vm;
      packages.${system} = {
        default = vm.config.system.build.vm;   # `nix run .`
      };
    };
}
```

Scaling note: sub-project 5 adds
`nixosConfigurations.kelymaster = mkHost ./hosts/kelymaster;` etc. — no flake
restructure needed.

### 4.2 `hosts/vm/default.nix`

Adapts the knoopx VM template (qemu-guest + qemu-vm profiles, 8 cores / 4 GB /
1920×1080, GPU-accelerated virtio display, USB tablet+keyboard, spice agent,
`forwardPorts` 2222→22) but replaces knoopx's `greetd → niri-session` with
**GNOME + gdm + auto-login**:

```nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  networking.hostName = "vm";
  system.stateVersion = "25.05";

  virtualisation.memorySize = 4096;
  virtualisation.cores = 8;
  virtualisation.resolution = { x = 1920; y = 1080; };
  virtualisation.qemu.options = [
    "-vga none"
    "-device virtio-vga-gl"
    "-display gtk,gl=on"
    "-device usb-tablet"
    "-device usb-kbd"
  ];
  virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
  ];

  services.spice-vdagentd.enable = true;
  boot.kernelModules = [ "uinput" "evdev" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];

  # Display: GNOME (replaces knoopx's greetd + niri-session)
  services.desktopManager.gnome.enable = true;
  services.xdg-desktop.gnome.enable = true;
  services.desktopManager.gnome.autoLogin = { enable = true; user = "genar"; };

  users.users.genar = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "audio" "video" "input" ];
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
```

The VM's own `nix` is configured (in sub-project 2) to flake-import the local
repo so that editing `hosts/vm` and running `sudo nixos-rebuild switch` inside
the VM rebuilds against the code being edited — the core of the multi-day
iteration loop.

### 4.3 `home/genar.nix`

Minimal on day one; grows in sub-projects 3–4:

```nix
{ config, pkgs, lib, ... }:
{
  home.username = "genar";
  home.homeDirectory = "/home/genar";
  stateVersion = "25.05";

  programs.bash.enable = true;
  programs.git.enable = true;

  programs.gnome-terminal.enable = true;
  # programs.gnome-terminal.extraConfig = { ... catppuccin palette ... };  # sub-project 4

  # Neovim (init.lua port) + Node.js: sub-project 3
}
```

## 5. Prerequisites (one-time, on the kelymaster host)

The box is CachyOS (Arch-based), 16 cores / 31 GB RAM — sufficient. Both `nix`
and `qemu`/OVMF are **not yet installed** on this box (checked), so day one
starts with:

- `sudo pacman -S qemu edk2-ovmf` (+ optionally `virt-manager`)
- Nix 2.28+ in **single-user** mode via the official installer
- `~/.config/nix/nix.conf`: `experimental-features = nix-command flakes`

## 6. Repo conversion (one commit)

The repo becomes a clean Nix tree; pre-Nix content is **archived, not deleted**:

1. `git rm` all submodule gitlinks (oh-my-zsh, prezto, neobundle.vim,
   spf13/snippets, bash-it, dotbot, powerline/fonts, sshconf,
   scripts/compile-vim-with-lua.sh) and drop `.gitmodules`
2. `git mv` the remaining old trees (`zsh/ vim/ nvim/ i3/ polybar/ awesomewm/
   bash/ dotbot/ fonts/ flexget/ mc/ ruby/ scripts/ bin/ environment/
   shells-common/ editorconfig/ gitsemverconf/ git/ install install.conf.yaml
   README.md LICENSE.md`) into `legacy/`
3. Add the new skeleton (§4): `flake.nix`, `hosts/vm/{default,overlays}.nix`,
   `home/genar.nix`, empty `modules/{nixos,home}/` + `lib/` spines, rewritten
   `README.md`
4. New `.gitignore`: `result`, `result-*`, `#*#`, `.*.suspended`

`legacy/nvim/` and `legacy/zsh/zshrc` are reference material for sub-project 3's
port. No sensitive material moves: this repo holds **no private keys** (they live
in the private `gitlab.com/gtrias/sshconf` submodule, which is removed from
tracking; the local key files stay on disk untouched).

## 7. Verification (definition of done for sub-project 1)

1. `nix flake check` passes — flake parses and evaluates cleanly
2. `nix build .#nixosConfigurations.vm.config.system.build.vm` builds the VM image
3. `nix run .#default` boots the VM → GNOME desktop, **auto-logged in as `genar`**
4. Inside the VM: `echo $SHELL` → bash; `gnome-terminal` launches; `git --version` works
5. `sudo nixos-rebuild switch` works from inside the VM (iteration loop proven)

## 8. Out of scope (later sub-projects)

Real-host modules (kelycube/kelymaster/slimbook), hardware/GPU config, full
Catppuccin theming pass, Neovim port, Node.js and other toolchains, installer
ISO / disko / USB, network-manager tuning, `mkNixosModules`/`lib/` growth.
