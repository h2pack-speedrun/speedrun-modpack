# Speedrun Modpack

Shell repo for the Speedrun modpack. Contains all module submodules, the coordinator, and the shared Framework/Lib.

## Structure

```
speedrun-modpack/
├── adamant-ModpackSpeedrunCore/   # Coordinator: pack identity, config, profiles
├── adamant-ModpackFramework/      # Shared UI, discovery, hash, HUD
├── adamant-ModpackLib/            # Shared utilities
├── Setup/                         # Deploy scripts
└── Submodules/                    # Game modules (one repo each)
```

## Setup

```bash
git clone --recurse-submodules https://github.com/h2pack-speedrun/speedrun-modpack.git
python Setup/deploy/deploy_all.py
```

Requires Python 3 and r2modman with a profile named `h2-dev`. On Windows, run `Setup/win.bat` as Administrator. On Linux/macOS, run `sudo ./Setup/lin.sh`.

## Releasing

Use the **Release All** workflow (`Actions → Release All`) to publish a new version across all modules.

## Architecture

See [h2-modular-modpack](https://github.com/h2-modpack/h2-modular-modpack) for full architecture documentation (Framework, Lib, staging pattern, hash pipeline).
