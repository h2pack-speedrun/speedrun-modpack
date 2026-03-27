# Speedrun Modpack

Shell repo for the Speedrun modpack. Contains all module submodules, the coordinator, and the shared Framework/Lib.

## Structure

```
speedrun-modpack/
├── adamant-ModpackSpeedrunCore/              # Coordinator: pack identity, config, profiles
├── adamant-modpack-Framework/ # Shared UI, discovery, hash, HUD
├── adamant-modpack-Lib/       # Shared utilities
├── Setup/                     # Deploy scripts
└── Submodules/                # Game modules (one repo each)
```

## Setup

```bash
git clone --recurse-submodules https://github.com/h2pack-speedrun/speedrun-modpack.git
python Setup/deploy_all.py
```

## Releasing

Use the **Release All** workflow (`Actions → Release All`) to publish a new version across all modules.
