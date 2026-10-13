# nixos-config

My personal NixOS system — one configuration shared across my machines via a
[Nix flake](https://flake.nix) + [home-manager](https://github.com/nix-community/home-manager).

| Host         | What it is                          | Status |
|--------------|-------------------------------------|--------|
| `vm`         | QEMU iteration sandbox              | done (sub-project 1) |
| `kelymaster` | this box — native install           | sub-project 5/6 |
| `kelycube`   | real machine                        | sub-project 5 |
| `slimbook`   | laptop                              | sub-project 5 |

Shared base (`modules/`, `home/`) + per-host overrides (`hosts/<machine>/`).
Change a shared setting once and it applies to every machine.

## Requirements

- [Nix](https://nixos.org/nix/) 2.28+ with flakes enabled
  (`experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`)
- A display (the VM opens a GTK window)

## Run the VM

```bash
nix run .#default
```

First run builds the VM image (a long, one-time download from the
`nixos-unstable` cache). After that, `nix build` is incremental.

Rebuild after editing, then re-run:

```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
nix run .#default
```

Evaluate everything without building:

```bash
nix flake check
```

## Roadmap

1. **VM scaffold** (this) — flake + `hosts/vm` booting GNOME as `genar`
2. Core system — users, networking, nix config, fonts; populate `modules/nixos`;
   in-VM `nixos-rebuild` (VM flake-imports this repo)
3. home-manager stack — bash hardening, Neovim (port of `legacy/nvim`), Node.js
4. Theming pass — Catppuccin across GNOME / nvim / terminal
5. Real hosts — `hosts/{kelymaster,kelycube,slimbook}` + hardware/GPU
6. Installer — disko + bootable USB for the native install

`legacy/` holds the pre-Nix configuration (archived, for reference while porting).
