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

## Shared Docs

The shared architecture and authoring contract live in the upstream repos:

- [ModpackFramework COORDINATOR_GUIDE.md](https://github.com/h2-modpack/ModpackFramework/blob/main/COORDINATOR_GUIDE.md)
- [ModpackFramework HASH_PROFILE_ABI.md](https://github.com/h2-modpack/ModpackFramework/blob/main/HASH_PROFILE_ABI.md)
- [ModpackLib MODULE_AUTHORING.md](https://github.com/h2-modpack/ModpackLib/blob/main/MODULE_AUTHORING.md)
- [ModpackLib API.md](https://github.com/h2-modpack/ModpackLib/blob/main/API.md)
- [ModpackLib FIELD_TYPES.md](https://github.com/h2-modpack/ModpackLib/blob/main/FIELD_TYPES.md)

This shell repo should only document pack-specific structure and composition.

## Releasing

Use the **Release All** workflow in GitHub Actions to publish a new version across the shell and submodules.
