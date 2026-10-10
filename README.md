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
lua tests/smoke.lua
ModpackTools/run ModpackTools/local_test/all.py
ModpackTools/run ModpackTools/local_deploy/deploy_all.py
```

Commit CI only runs the shell smoke script. Local deploy runs that same smoke preflight before writing to the live profile. Release All checks platform dependency edges and verifies selected child repos have successful CI for the exact release branch commits before dispatching child releases.

When adding or removing module submodules, use the registration tool so
`.gitmodules` and coordinator dependencies stay aligned. Smoke derives its
module roster from `.gitmodules`.

```bash
ModpackTools/run ModpackTools/new_module/register_submodules.py
ModpackTools/run ModpackTools/new_module/register_submodules.py --prune
```

On Windows Command Prompt or PowerShell, use `ModpackTools\run.bat` instead of
`ModpackTools/run`. The launcher picks an available Python 3 command
(`python3`, `python`, or `py -3`).

For the full new-pack workflow, use
[ModpackBootstrap Getting Started](https://github.com/h2-modpack/ModpackBootstrap/blob/main/docs/GETTING_STARTED.md).

## Releasing

Use the **Release All** workflow (`Actions -> Release All`) to publish the pack.
Leave `tag` blank and each repo gets its own version from its conventional commits since its last tag; repos with nothing to release are skipped, the coordinator is bumped and pins every module, and the plan is shown before anything is dispatched. Use `is-dry-run` to preview it, `versions` (`LiveSplit=6.0.0`) to override a repo, `modules` to limit the run, or `tag` for a single lockstep version.
The workflow releases each child at its release branch head, validates platform dependency edges, requires successful child CI before dispatching, and commits the updated submodule pointers back to the shell afterwards.

## Shared Docs

Use the stable repo-root entrypoints for shared docs:

- [ModpackLib README.md](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/README.md)
- [Modpack Coordinator Guide](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/modpack-authors/COORDINATOR_GUIDE.md)
- [Module Authoring Guide](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/module-authors/MODULE_AUTHORING.md)
- [Hot Reload Architecture](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/lib-contributors/HOT_RELOAD_ARCHITECTURE.md)
- [Known Limitations](https://github.com/h2-modpack/adamant-ModpackLib/blob/main/docs/references/KNOWN_LIMITATIONS.md)

This shell repo should only document pack-specific structure and composition.
