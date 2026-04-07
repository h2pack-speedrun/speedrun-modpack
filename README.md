# Speedrun Modpack

Shell repo for the Speedrun modpack. Contains all module submodules, the coordinator, and the shared Framework/Lib.

## Structure

```
speedrun-modpack/
├── adamant-Speedrun_Core/         # Coordinator: pack identity, config, profiles
├── adamant-ModpackFramework/      # Shared UI, discovery, hash, HUD
├── adamant-ModpackLib/            # Shared utilities and module runtime
├── Setup/                         # Scaffold and deploy helpers
└── Submodules/                    # Game modules (one repo each)
```

## Setup

```bash
git clone --recurse-submodules https://github.com/h2pack-speedrun/speedrun-modpack.git
python Setup/deploy/deploy_all.py
```

Requires Python 3 and r2modman with a profile named `h2-dev`. On Windows, run `Setup/win.bat` as Administrator. On Linux/macOS, run `sudo ./Setup/lin.sh`.

## Shared Docs

Use the stable repo-root entrypoints for shared docs:

- [ModpackFramework README.md](https://github.com/h2-modpack/adamant-ModpackFramework/blob/main/README.md)
- [ModpackLib README.md](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/README.md)

This shell repo should only document pack-specific structure and composition.

## Releasing

Use the **Release All** workflow in GitHub Actions to publish a new version across the shell and submodules.
