# `nixos-config` VM Scaffold — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the stale dotbot dotfiles repo at `~/dotfiles` into `nixos-config` and boot a working NixOS VM (GNOME, auto-login as `genar`, bash, GNOME Terminal, Catppuccin base) from a flake, with the pre-Nix content archived to `legacy/`.

**Architecture:** A minimal two-input flake (`nixpkgs` + `home-manager`) with a `mkHost` helper that stacks home-manager over one host module. `hosts/vm` adapts knoopx's QEMU-VM template, swapping their `greetd → niri-session` for **GNOME + gdm + auto-login**. `home/genar.nix` is the shared home-manager config. This is sub-project 1 of 6 (VM scaffold); the `modules/` + `lib/` spines and in-VM `nixos-rebuild` are deferred to sub-project 2.

**Tech Stack:** NixOS (nixos-unstable), flakes, home-manager, GNOME (gdm), QEMU, Nix. Host is CachyOS (Arch-based), 16 cores / 31 GB RAM.

**Refinements vs. the approved spec** (neither changes an approved decision):
- **Display**: use `virtio-vga` + `-display gtk` (reliable first boot) instead of the spec's knoopx-inherited `virtio-vga-gl` + `-display gtk,gl=on` (tuned for niri's GL path, adds black-screen risk for a first GNOME boot). GL acceleration is a sub-project-2 enhancement.
- **Prereqs**: the NixOS VM uses nixpkgs' qemu + OVMF from the nix store, so the host only needs `nix` (+ `qemu` as a fallback). `edk2-ovmf` is not required.
- **In-VM `nixos-rebuild`** (spec §7.5) is delivered in **sub-project 2** (which configures the VM's nix to flake-import the repo, per spec §4.2). Sub-project 1 proves the **host-side** edit→build→run loop instead.

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `flake.nix` | Create | Flake: `nixpkgs` + `home-manager` inputs, `mkHost` helper, `nixosConfigurations.vm`, `packages.x86_64-linux.default` = the VM |
| `flake.lock` | Generated | Lock for flake inputs (created by `nix flake update`) |
| `hosts/vm/default.nix` | Create | The VM: QEMU modules, GNOME + gdm + auto-login, user `genar`, 8c/4g/1080p, 2222→22 |
| `hosts/vm/overlays.nix` | Create | Stub (`[]`) — per-host overlays, wired in by the sub-project-2 `mkNixosModules` helper |
| `home/genar.nix` | Create | Shared home-manager: bash, git, GNOME Terminal (Node/Neovim/theming in later sub-projects) |
| `README.md` | Rewrite | Replaces the dotbot template README with nixos-config build/run + roadmap |
| `.gitignore` | Rewrite | Nix build artifacts; excludes vendored frameworks under `legacy/` |
| `.gitmodules` | Delete | All submodules removed |
| `legacy/` | Create (moved) | Pre-Nix content archived: `nvim/ zsh/ i3/ polybar/ mc/ git/ bin/ scripts/ ruby/ environment/ shells-common/ editorconfig/ flexget/ gitsemverconf/ bash/ awesomewm/` (vendored submodule checkouts excluded via `.gitignore`) |
| old top-level dirs | Delete from tracking | `dotbot/` (submodule), `fonts/` (submodule), `install`, `install.conf.yaml`, `LICENSE.md` |

Verification model: this is NixOS config, not unit-testable code. The "tests" are the Nix evaluation/build/boot chain: `nix flake check` (evaluates) → `nix build` (builds the VM image) → `nix run` (boots the VM) → inside-VM checks. Each task commits on green.

---

### Task 1: Host prerequisites (Nix + QEMU on CachyOS)

**Files:** host system (no repo files). Installs Nix with flakes enabled and QEMU (fallback only; the flake supplies its own qemu/OVMF).

- [ ] **Step 1: Install Nix and QEMU via pacman**

Run:
```bash
sudo pacman -S --needed nix qemu
```
Expected: packages install; a `nix-daemon` (or `nix`) systemd unit is created.

- [ ] **Step 2: Enable flakes for the current user**

Run:
```bash
mkdir -p ~/.config/nix
grep -qxF 'experimental-features = nix-command flakes' ~/.config/nix/nix.conf 2>/dev/null || \
  printf '%s\n' 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
cat ~/.config/nix/nix.conf
```
Expected: the file now contains exactly `experimental-features = nix-command flakes`.

- [ ] **Step 3: Ensure the Nix daemon is running (multi-user, Arch default)**

Run:
```bash
sudo systemctl enable --now nix-daemon 2>/dev/null || sudo systemctl enable --now nix 2>/dev/null || true
systemctl list-units --all | grep -i nix || true
```
Expected: a nix daemon unit is active (name may be `nix-daemon.service` or `nix.service`). If neither exists, the pacman package may not auto-start it — check `systemctl --failed` and start the correct one.

- [ ] **Step 4: Verify Nix works with flakes**

Run:
```bash
nix --version
printf '%s\n' '{ outputs = { }: { }; }' > /tmp/empty.flake.nix
nix flake show "file:///tmp/empty.flake.nix"
rm -f /tmp/empty.flake.nix
```
Expected: `nix --version` prints a version; `nix flake show` succeeds (proves flakes + a working daemon/store). This is the gate — if it fails, do not proceed.

- [ ] **Step 5: Verify QEMU binary (fallback) and CPU virtualization**

Run:
```bash
qemu-system-x86_64 --version | head -1
egrep -c '(vmx|svm)' /proc/cpuinfo
```
Expected: a QEMU version line; the last command prints a non-zero count (hardware virtualization available — makes the VM fast). (A zero count means no KVM; the VM still runs, just slower — note it and continue.)

- [ ] **Step 6: No commit (host-only step).** Proceed to Task 2.

---

### Task 2: Create the flake skeleton and get it to evaluate

**Files:**
- Create: `flake.nix`
- Create: `hosts/vm/default.nix`
- Create: `hosts/vm/overlays.nix`
- Create: `home/genar.nix`
- Generated: `flake.lock`

- [ ] **Step 1: Write `flake.nix`**

Create `flake.nix`:
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

  outputs =
    inputs:
    let
      inherit (inputs) nixpkgs home-manager;
      system = "x86_64-linux";
      specialArgs = inputs // { inherit inputs; };

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
    in
    {
      nixosConfigurations.vm = vm;
      packages.${system} = {
        default = vm.config.system.build.vm;
      };
    };
}
```

- [ ] **Step 2: Write `hosts/vm/default.nix`**

Create `hosts/vm/default.nix`:
```nix
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
  services.xdg-desktop.gnome.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.gnome.autoLogin = {
    enable = true;
    user = "genar";
  };

  users.users.genar = {
    isNormalUser = true;
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "audio" "video" "input" ];
  };

  nixpkgs.hostPlatform.system = "x86_64-linux";
}
```

- [ ] **Step 3: Write `hosts/vm/overlays.nix` (stub for sub-project 2)**

Create `hosts/vm/overlays.nix`:
```nix
# Per-host nixpkgs overlays for the vm host.
# Wired in by the sub-project-2 mkNixosModules helper (which imports this file
# if present). Empty for now.
[]
```

- [ ] **Step 4: Write `home/genar.nix`**

Create `home/genar.nix`:
```nix
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
```

- [ ] **Step 5: Fetch inputs (generate `flake.lock`)**

Run:
```bash
cd ~/dotfiles
nix flake update
```
Expected: fetches `nixpkgs` (nixos-unstable) + `home-manager`, writes `flake.lock`. Network download; may take a minute.

- [ ] **Step 6: Evaluate the flake (the "test")**

Run:
```bash
nix flake check
```
Expected: PASS — no evaluation errors. If it reports a module option error (e.g. a typo'd option name), fix the offending option in `hosts/vm/default.nix` or `home/genar.nix` and re-run until clean. Common first-boot gotchas: `services.desktopManager.gnome.autoLogin` (valid), `services.xdg-desktop.gnome` (valid), `programs.gnome-terminal` (valid in home-manager).

- [ ] **Step 7: Commit**

```bash
git add flake.nix flake.lock hosts/vm/default.nix hosts/vm/overlays.nix home/genar.nix
git commit -m "feat: nixos-config flake skeleton + vm host + home/genar (evaluates)"
```

---

### Task 3: Build the VM image

**Files:** none (build step). Produces the NixOS VM image derivation.

- [ ] **Step 1: Build the VM (first build is large — expect a long download + assemble)**

Run:
```bash
cd ~/dotfiles
nix build .#nixosConfigurations.vm.config.system.build.vm
```
Expected: a long build (mostly pulling prebuilt nixos-unstable packages from the cache + assembling the VM image). On 16 cores with the nixos-unstable binary cache this is typically ~10–40 min and a multi-GB download. Let it finish. It is normal for this to be the slowest step of sub-project 1.

- [ ] **Step 2: Confirm the result exists**

Run:
```bash
ls -la result/bin/run-qemu.sh 2>/dev/null || readlink -f result
```
Expected: a `result` symlink into the nix store; the VM derivation contains a `run-qemu.sh` launcher. If `nix build` errored, read the error, fix the module, and rebuild.

- [ ] **Step 3: Commit (locks the built configuration state)**

```bash
git add -A
git commit -m "chore: VM image builds green (nix build .#...build.vm)"
```
(Committing here is optional if nothing changed on disk; `git add -A` will be a no-op if only the store changed. It exists to give a clean checkpoint before the boot test.)

---

### Task 4: Boot the VM and verify the desktop

**Files:** none (runtime verification). This is the core integration test of sub-project 1.

- [ ] **Step 1: Boot the VM**

Run (foreground — a GTK window opens; leave the terminal free or run in a background job):
```bash
cd ~/dotfiles
nix run .#default
```
Expected: a QEMU GTK window opens, the VM boots, gdm auto-logs-in as `genar`, and the **GNOME desktop** appears. First boot may take a couple of minutes after the window appears.

- [ ] **Step 2: If the desktop does not appear, apply the fallbacks in order (re-run `nix run .#default` after each)**

Troubleshooting ladder (edit `hosts/vm/default.nix`, rebuild with `nix build .#nixosConfigurations.vm.config.system.build.vm`, then re-run):
1. **Black/blank window** → the Wayland session may not be reaching the GPU. Force X11: add `services.xserver.enable = true;` and set `services.desktopManager.gnome.autoLogin.session = "gnome";`. Rebuild + re-run.
2. **Still blank** → simplify the GPU: replace `"-device virtio-vga"` with `"-device qxl-vga"` (software, most compatible) and keep `services.xserver.enable = true;`. Rebuild + re-run.
3. **Window opens but no login/desktop** → confirm `services.desktopManager.gnome.autoLogin = { enable = true; user = "genar"; };` and `services.xdg-desktop.gnome.enable = true;` are both present.

- [ ] **Step 3: Open a terminal and check the shell + tools (inside the VM's GNOME Terminal)**

Once at the GNOME desktop, open **GNOME Terminal** (from the app grid / Activities) and run:
```bash
echo "SHELL=$SHELL"
which bash gnome-terminal git
git --version
```
Expected: `SHELL=/run/current-system/sw/bin/bash` (or similar bash path); all three `which` paths resolve; `git --version` prints a version.

- [ ] **Step 4: Verify the forwarded SSH port (host side)**

From the HOST terminal (not the VM), with the VM running:
```bash
ssh -p 2222 -o ConnectTimeout=5 -o StrictHostKeyChecking=no genar@127.0.0.1 'echo ssh-forward-ok' 2>&1 | tail -1
```
Expected: either `ssh-forward-ok` (ssh enabled + key accepted) or an auth prompt / `Permission denied` — both prove the 2222→22 forward is live. (A `Connection refused` means the port forward or sshd isn't up; check `virtualisation.forwardPorts` and that `services.openssh.enable = true;` if you need it — sshd is off by default, so auth-prompt/refused-but-listening is the expected day-one state.)

- [ ] **Step 5: Close the VM window (stop the VM), then commit a note**

```bash
git commit --allow-empty -m "chore: VM boots to GNOME, auto-login genar, bash + gnome-terminal verified"
```
(Empty commit records the verified milestone; no files change.)

---

### Task 5: Prove the host-side iteration loop

**Files:** `hosts/vm/default.nix` (temporary probe, then reverted). Spec §7.5's in-VM `nixos-rebuild` is sub-project 2; this proves the host-side edit→build→run loop that sub-project 1 actually delivers.

- [ ] **Step 1: Add a visible probe to the config**

In `hosts/vm/default.nix`, temporarily set the host name to a probe value. Change:
```nix
  networking.hostName = "vm";
```
to:
```nix
  networking.hostName = "vm-probe";
```

- [ ] **Step 2: Rebuild and boot, confirm the change took effect**

Run:
```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
nix run .#default
```
Expected: after boot, inside the VM run `hostname` → prints `vm-probe`. This proves an edit to `hosts/vm` flows through build→run (the iteration loop).

- [ ] **Step 3: Revert the probe**

Revert `networking.hostName` back to `"vm"`, then rebuild:
```bash
nix build .#nixosConfigurations.vm.config.system.build.vm
```

- [ ] **Step 4: Commit**

```bash
git add hosts/vm/default.nix
git commit -m "chore: verify host-side edit→build→run iteration loop (probe reverted)"
```

---

### Task 6: Rewrite README and .gitignore

**Files:**
- Modify: `README.md`
- Modify: `.gitignore`

- [ ] **Step 1: Rewrite `README.md`**

Replace the entire dotbot-template README with:
````markdown
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
````

- [ ] **Step 2: Rewrite `.gitignore`**

Replace `.gitignore` with:
```gitignore
# Nix build artifacts
result
result-*
#*#
.*.suspended
.direnv

# Vendored framework checkouts kept on disk under legacy/ but not committed
legacy/dotbot/
legacy/fonts/
legacy/zsh/oh-my-zsh/
legacy/zsh/prezto/
legacy/bash/bash-it/
legacy/vim/neobundle.vim/
legacy/vim/snippets/
legacy/sshconf/
legacy/awesomewm/powerarrow/
legacy/awesomewm/awesome-config/
legacy/scripts/compile-vim-with-lua.sh/
```

- [ ] **Step 3: Commit**

```bash
git add README.md .gitignore
git commit -m "docs: rewrite README for nixos-config; .gitignore for Nix + legacy vendor dirs"
```

---

### Task 7: Archive pre-Nix content to `legacy/` (drop submodules)

**Files:** reorganizes the whole repo. Run each sub-step, then one commit. This is the riskiest task — it restructures the tree — so it runs *after* the VM is proven (Tasks 2–5). If anything looks wrong, `git reset --hard HEAD~1` restores the pre-archive tree (the VM files are already committed in earlier tasks).

- [ ] **Step 1: Remove all submodule gitlinks and drop `.gitmodules`**

Run:
```bash
cd ~/dotfiles
git rm --cached \
  dotbot \
  fonts/fonts \
  zsh/oh-my-zsh \
  zsh/prezto \
  vim/neobundle.vim \
  vim/snippets \
  ruby/rbenv \
  bash/bash-it \
  awesomewm/powerarrow \
  zsh/prezto \
  sshconf \
  awesomewm/awesome-config \
  scripts/compile-vim-with-lua.sh 2>/dev/null
git rm -f .gitmodules
```
Expected: gitlinks removed from the index (the on-disk checkouts remain as plain, now-untracked directories). Some paths may already be absent — `2>/dev/null` and `|| true`-style tolerance means a not-found path is skipped, not fatal. Verify with:
```bash
git ls-files --stage | grep ' 160000 ' || echo "no gitlinks remain"
```
Expected: `no gitlinks remain`.

- [ ] **Step 2: Move the user's pre-Nix config trees into `legacy/`**

Run:
```bash
mkdir -p legacy
for d in \
  zsh vim nvim i3 polybar awesomewm bash dotbot fonts flexget \
  mc ruby scripts bin environment shells-common editorconfig \
  gitsemverconf git
do
  [ -e "$d" ] && git mv "$d" "legacy/$d"
done
# single files
for f in install install.conf.yaml LICENSE.md; do
  [ -e "$f" ] && git mv "$f" "legacy/$f"
done
```
Expected: `legacy/` now contains the pre-Nix trees; the vendored submodule dirs came along on disk but are untracked. `README.md` is intentionally left at the root (Task 6 already rewrote it).

- [ ] **Step 3: Stage the archived user config (vendor dirs are gitignored, so they stay out)**

Run:
```bash
git add legacy/
git status --short | sed -n '1,40p'
```
Expected: `git status` shows the `legacy/...` user-config files as added/staged and the vendored dirs (e.g. `legacy/dotbot/`, `legacy/zsh/oh-my-zsh/`) as **ignored** (not listed as untracked additions). If a vendored dir shows up as a huge untracked blob, the `.gitignore` pattern for it is missing — add it in Task 6's `.gitignore` and re-stage.

- [ ] **Step 4: Sanity-check the tree, then commit**

Run:
```bash
ls -1
echo "--- legacy/ ---"
ls -1 legacy/
git add -A
git commit -m "refactor: archive pre-Nix dotbot content to legacy/; drop all submodules"
```
Expected: root now shows the clean `nixos-config` layout (`flake.nix flake.lock hosts/ home/ legacy/ README.md .gitignore` plus any `modules/`/`lib/` spines if added). The commit moves everything into `legacy/` and removes the submodule wiring.

---

### Task 8: Final verification and push

**Files:** none (verification + optional push).

- [ ] **Step 1: Full clean re-evaluation**

Run:
```bash
nix flake check
```
Expected: PASS (the archive in Task 7 did not break evaluation — the flake doesn't reference `legacy/`).

- [ ] **Step 2: Confirm the repo layout is the clean nixos-config tree**

Run:
```bash
git ls-files | sed 's|/.*||' | sort -u
```
Expected: top-level tracked entries are `flake.nix`, `flake.lock`, `hosts`, `home`, `legacy`, `README.md`, `.gitignore`, `docs` (the specs/plans). No `zsh/`, `vim/`, `nvim/`, `i3/`, `dotbot/`, `.gitmodules` at the root.

- [ ] **Step 3: Boot once more to confirm the archive didn't disturb the working VM**

Run:
```bash
nix run .#default
```
Expected: the GNOME VM still boots and auto-logs in as `genar`. Close the window when done.

- [ ] **Step 4: Push to origin (your call)**

The GitHub repo is still named `dotfiles` (`origin` = `github.com/gtrias/dotfiles`). Pushing is safe (new commits on `master`). You may rename the GitHub repo to `nixos-config` afterward (GitHub auto-redirects the old URL) — that's a manual step in the GitHub UI, not a command here.
```bash
git push origin master
```
Expected: `master` updated on origin. (Skip if you don't want to push yet.)

- [ ] **Step 5: Record sub-project 1 as done**

```bash
git commit --allow-empty -m "milestone: sub-project 1 (nixos-config VM scaffold) complete"
```

---

## Self-Review

**1. Spec coverage.** Spec §4.1 `flake.nix` → Task 2. §4.2 `hosts/vm` → Task 2. §4.3 `home/genar` → Task 2. §5 prerequisites → Task 1. §6 repo conversion → Tasks 6–7. §7 verification: (1) `nix flake check` → Tasks 2/8; (2) `nix build` → Task 3; (3) `nix run` boots to auto-logged-in GNOME → Task 4; (4) inside-VM bash/gnome-terminal/git → Task 4 Step 3; (5) in-VM `nixos-rebuild` → **moved to sub-project 2** (spec §4.2 already defers it); sub-project 1 proves the host-side loop in Task 5 instead. §8 out-of-scope items are all excluded. No spec requirement is dropped — only §7.5 is re-homed to the sub-project the spec itself assigns it to.

**2. Placeholder scan.** No "TBD"/"implement later" as action items. The only forward references are explicit, named sub-projects (Node.js, Neovim, Catppuccin, real hosts, installer) already scoped in the spec's decomposition — not placeholders for this plan's work. `hosts/vm/overlays.nix` is a deliberate, commented stub for the sub-project-2 helper, not an unfinished piece of this plan.

**3. Type/name consistency.** `mkHost` used identically in `flake.nix` (Task 2). `home-manager.users.genar = import ./home/genar.nix` matches the created `home/genar.nix`. `pkgs.bash` (Task 2 host module) matches `programs.bash.enable` (Task 2 home). `services.desktopManager.gnome.autoLogin.user = "genar"` matches `users.users.genar` and `home.username = "genar"`. The probe in Task 5 edits only `networking.hostName` and reverts it — no naming drift. Display options (`-display gtk`, `-device virtio-vga`) are consistent between Task 2 and the Task 4 fallback ladder (which only swaps the `-device` and toggles `services.xserver.enable`).
