# Speedrun Modpack

Shell repo for the Speedrun modpack. Contains all module submodules, the coordinator, and the shared Framework/Lib.

## Structure

```
speedrun-modpack/
├── adamantSpeedrun-Speedrun_Modpack/ # Coordinator: pack identity, config, profiles
├── adamant-ModpackFramework/      # Shared UI, discovery, hash, HUD
├── adamant-ModpackLib/            # Shared utilities and module runtime
├── ModpackTools/                  # Scaffold and deploy helpers
└── Submodules/                    # Game modules (one repo each)
```

## Local Development

```bash
git clone --recurse-submodules https://github.com/h2pack-speedrun/speedrun-modpack.git
python ModpackTools/deploy/deploy_all.py
```

Requires Python 3 and r2modman with a profile named `h2-dev`. Creating local symlinks may require Administrator permissions on Windows or `sudo` on Linux/macOS.

## Shared Docs

Use the stable repo-root entrypoints for shared docs:

- [ModpackFramework README.md](https://github.com/h2-modpack/adamant-ModpackFramework/blob/main/README.md)
- [ModpackLib README.md](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/README.md)

This shell repo should only document pack-specific structure and composition.

## Releasing

Use the **Release All** workflow in GitHub Actions to publish a new version across the shell and submodules.
