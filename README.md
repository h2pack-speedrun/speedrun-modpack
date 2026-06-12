# Speedrun Modpack

Shell repo for the Speedrun modpack. Contains the coordinator, shared Lib/runtime tooling submodules, and the game-module submodules for this pack.

## Structure

```text
speedrun-modpack/
|- adamantSpeedrun-Speedrun_Modpack/ # Coordinator: pack identity, config, profiles
|- adamant-ModpackLib/               # Shared module and modpack runtime
|- ModpackTools/                     # Pack maintenance scripts
'- Submodules/                       # Game modules (one repo each)
```

## Local Development

```bash
git clone --recurse-submodules https://github.com/h2pack-speedrun/speedrun-modpack.git
ModpackTools/run ModpackTools/local_deploy/deploy_all.py
```

On Windows Command Prompt or PowerShell, use `ModpackTools\run.bat` instead of
`ModpackTools/run`. The launcher picks an available Python 3 command
(`python3`, `python`, or `py -3`).

For the full new-pack workflow, use
[ModpackBootstrap Getting Started](https://github.com/h2-modpack/ModpackBootstrap/blob/main/docs/GETTING_STARTED.md).

## Releasing

Use the **Release All** workflow (`Actions -> Release All`) to publish a new version across all modules.

## Shared Docs

Use the stable repo-root entrypoints for shared docs:

- [ModpackLib README.md](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/README.md)
- [Modpack Coordinator Guide](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/modpack-authors/COORDINATOR_GUIDE.md)
- [Module Authoring Guide](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/module-authors/MODULE_AUTHORING.md)
- [Hot Reload Architecture](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/lib-contributors/HOT_RELOAD_ARCHITECTURE.md)
- [Known Limitations](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/references/KNOWN_LIMITATIONS.md)

This shell repo should only document pack-specific structure and composition.
