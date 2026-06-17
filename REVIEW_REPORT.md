# Tmux Configuration Review Report

Review date: 2026-06-02

## Scope

Reviewed the repository-level tmux configuration, split config files in `config/`, the installer in `setup.sh`, and tmuxinator session definitions in `tor_sessions/`.

## Overall Assessment

The project has a clear structure: a small root `tmux.conf` delegates into `~/.tmux/config/tmux.conf`, which then sources key bindings, theme, plugin declarations, and status bar configuration. The day-to-day tmux options are mostly reasonable for a personal Linux workstation.

The largest problems are install safety, plugin consistency, and portability. The current setup is likely to work only on the original machine or a very similar Linux desktop, and the installer can remove existing tmux configuration without confirmation.

## High Priority Findings

### 1. `setup.sh` deletes all matching user tmux files

Location: `setup.sh:5`

```sh
sudo rm -rf /home/$(logname)/.tmux*
```

This removes `~/.tmux`, `~/.tmux.conf`, `~/.tmuxinator`, and any other path matching `.tmux*`. It is a destructive install step and can erase unrelated user configuration or session definitions.

Recommendation:

- Replace this with explicit backup logic.
- Avoid `sudo` for files under the target user's home directory.
- Only remove symlinks created by this project, and only after checking their targets.

### 2. Plugin declarations and installed plugin repositories do not match

Locations:

- `config/plugins.conf:6-11`
- `setup.sh:21-31`

The config declares these plugins through TPM:

- `tmux-plugins/tmux-mem-cpu-load`
- `tmux-plugins/tmux-network-speed`
- `tmux-plugins/tmux-fzf-pane-switch`
- `tmux-plugins/tmux-current-pane-hostname`

The installer clones different repositories for several of them:

- `dornenkrone/tmux-mem-cpu-load.git`
- `minhdanh/tmux-network-speed.git`
- `Kristijan/tmux-fzf-pane-switch.git`
- `dornenkrone/my_currentpanehostname.tmux.git`

This can cause TPM install/update behavior to diverge from the manually cloned plugin code. It also makes plugin troubleshooting harder because the configured owner/name is not the same as the installed source.

Recommendation:

- Choose one plugin installation model: TPM-managed installs or manual cloning.
- If using TPM, keep only TPM declarations and let `<prefix> + I` install them.
- If manually cloning, make declarations match the actual repository names or document why each fork is required.

### 3. The installer clones plugins that are not enabled

Locations:

- `setup.sh:21`, `setup.sh:23-25`
- `config/plugins.conf:12-13`

The installer clones `tmux2k`, `tmux-fuzzback`, `tmux-resurrect`, and `tmux-continuum`, but these are not enabled in the active plugin file. This wastes install time and increases failure surface, especially because the script runs with `set -e`.

Recommendation:

- Remove unused clones from `setup.sh`, or enable the corresponding plugins.
- Keep optional plugins in comments with clear installation instructions.

### 4. Hardcoded network interface conflicts between files

Locations:

- `config/tmux.conf:8`
- `config/plugins.conf:20`

`config/tmux.conf` sets `@network_speed_interface` to `en`, then `config/plugins.conf` sets it to `eno1`. Because `plugins.conf` is sourced before the later global options in `config/tmux.conf`, the final value is likely `en`.

That value may not match real network device names such as `eno1`, `eth0`, `wlan0`, or `enp*`, so the status bar may show no network speed.

Recommendation:

- Keep the option in one place only.
- Prefer making it configurable through an environment variable or a documented local override file.

## Medium Priority Findings

### 5. Root `tmux.conf` depends on an installed symlink layout

Location: `tmux.conf:2`

The root file sources `~/.tmux/config/tmux.conf`. This works after `setup.sh` has created symlinks, but it does not work directly from a repository checkout.

Recommendation:

- Either document that `setup.sh` must be run first, or make the root config source repository-relative paths where possible.
- Consider making `tmux.conf` the actual source of truth and symlink it to `~/.tmux.conf`.

### 6. `default-terminal` should probably be `tmux-256color`

Location: `config/tmux.conf:21`

The config uses:

```tmux
set -g default-terminal xterm-256color
```

For modern tmux, `tmux-256color` is usually a better default when the host terminfo database supports it. `xterm-256color` often works, but it is less precise inside tmux.

Recommendation:

- Use `tmux-256color` on systems with terminfo support.
- Keep true color overrides, or move to `terminal-features` for newer tmux versions if compatibility allows.

### 7. Clipboard command assumes Linux X11 and `xclip`

Location: `config/tmux.conf:27`

Copy mode pipes through:

```tmux
xclip -selection clipboard
```

This fails on systems without `xclip`, on Wayland-only setups without XWayland clipboard support, and on macOS.

Recommendation:

- Detect clipboard tools in the installer or use a small wrapper script.
- Consider `wl-copy` for Wayland and `pbcopy` for macOS.
- Keep `tmux-yank` as the primary clipboard integration if it covers the target environment.

### 8. Status bar depends on plugin binaries being present

Location: `config/status_bar.conf:46`

The status bar executes:

```tmux
~/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load
```

If the plugin is missing or fails to compile, the status bar command will fail every second because `status-interval` is `1`.

Recommendation:

- Increase `status-interval` unless per-second updates are necessary.
- Guard external commands with a small script or a conditional check.
- Avoid manually hardcoding plugin executable paths when a plugin-provided format is available.

## Low Priority Findings

### 9. Session definitions contain duplicate tmuxinator names

Locations:

- `tor_sessions/project.yml:2`
- `tor_sessions/Project.yml:2`
- `tor_sessions/pinn.yml:3`
- `tor_sessions/rl.yml:3`

`project.yml` and `Project.yml` both define `name: project`. `pinn.yml` and `rl.yml` both define `name: pinn`. This can cause confusion when starting sessions and makes it harder to know which file owns a session.

Recommendation:

- Rename sessions so file names and `name:` fields match.
- Remove case-only duplicates unless both are intentionally needed.

### 10. Session files are highly machine-specific

Examples:

- `tor_sessions/bulletbot.yml:4`
- `tor_sessions/pinn.yml:50`
- `tor_sessions/report.yml:4`
- `tor_sessions/rosanto.yml:4`

Most sessions assume local project directories, conda environments, `nvim`, `htop`, and `nvitop`. That is fine for a private workstation setup, but fragile for reuse.

Recommendation:

- Document prerequisites.
- Split personal session files from reusable examples.
- Keep a minimal `example.yml` that works on a clean machine.

### 11. Minor spelling and naming inconsistencies

Examples:

- `setup.sh:47`: `custumized`
- `tor_sessions/bulletbot.yml:60`: `temrinal`
- `tor_sessions/rl.yml:84`: `sys_montor`
- `tor_sessions/rosanto.yml:49`: `preception`

These are not functional blockers, but they reduce readability.

## Configuration Strengths

- The config is modular and easy to navigate.
- Prefix, pane navigation, and resize bindings are simple and consistent.
- Mouse mode, vi copy mode, large history, base index `1`, and true color support are sensible personal defaults.
- Status bar construction with `set -ag` is cleaner than one long status string.
- The project includes session templates for common workflows.

## Suggested Remediation Order

1. Make `setup.sh` non-destructive and remove unnecessary `sudo`.
2. Decide whether TPM or manual cloning owns plugin installation.
3. Fix plugin repository names and remove unused plugin clones.
4. Move machine-specific values, especially network interface and shell path, into a local override file.
5. Rename duplicate tmuxinator sessions.
6. Add a short README with install steps, prerequisites, key bindings, and known platform assumptions.

## Recommended Target Structure

```text
tmux.conf
config/
  key_binding.conf
  themes.conf
  plugins.conf
  status_bar.conf
  local.conf.example
tor_sessions/
  example.yml
  personal/
setup.sh
README.md
```

`local.conf.example` can document machine-specific values such as:

```tmux
set -g default-shell /bin/zsh
set -g @network_speed_interface 'eno1'
```

Then the main config can source `~/.tmux/config/local.conf` only if it exists.

## Verification Notes

- `tmux -V` reports `tmux 3.5a` in this environment.
- No live tmux reload was performed, to avoid changing the user's active tmux session.
- Network access was not used, so external plugin repository existence was reviewed by comparing configured names with installer clone URLs rather than fetching remote metadata.
