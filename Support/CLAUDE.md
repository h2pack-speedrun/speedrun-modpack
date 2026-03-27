# Speedrun Modpack — AI Assistant Context

## Project Structure

This is a **Hades 2 speedrun modpack** organized as a shell repo with git submodules under the `h2pack-speedrun` GitHub org.

```
speedrun-modpack/
├── adamant-ModpackSpeedrunCore/  # Coordinator: packId="speedrun", windowTitle="Speedrun", config, profiles
├── adamant-ModpackFramework/     # Reusable library: discovery, hash, HUD, UI (org: h2-modpack)
├── adamant-ModpackLib/           # Shared utilities: backup, field types, state mgmt (org: h2-modpack)
├── Setup/                        # Deploy + scaffold + migrate scripts (submodule: h2-modpack/Setup)
│   ├── deploy/
│   │   ├── deploy_all.py         # Full deploy (assets + manifests + symlinks + hooks)
│   │   ├── deploy_links.py
│   │   ├── deploy_manifests.py
│   │   ├── deploy_assets.py
│   │   ├── deploy_hooks.py
│   │   └── deploy_common.py
│   ├── scaffold/
│   │   ├── new_module.py         # Scaffold a new module repo from h2-modpack-template
│   │   ├── new_pack.py           # Scaffold a new shell repo
│   │   └── register_submodules.py  # Sync .gitmodules with Submodules/ folders (--prune to remove orphans)
│   └── migrate/
│       ├── transfer_repos.py     # Transfer repos between GitHub orgs, outputs repos.txt
│       ├── rewire.py             # Update .gitmodules URLs + git submodule sync
│       └── bulk_add.py           # Add submodules from repos.txt
├── Submodules/
│   └── adamant-*/                # 34 standalone modules (each its own repo under h2pack-speedrun)
├── Support/
│   ├── CLAUDE.md                 # This file
│   └── ai_handshake.md           # Session transfer template
└── .github/workflows/
    ├── release-all.yaml          # Orchestrates releases across all repos
    ├── update-submodules.yaml    # Daily submodule pointer sync
    └── luacheck.yaml             # Lua linting on push/PR to main
```

## Architecture

See `h2-modular-modpack/ARCHITECTURE.md` for the full system overview (Framework, Lib, staging pattern, hash pipeline).

### Layer overview

| Layer | Repo | Role |
|---|---|---|
| Coordinator | `adamant-ModpackSpeedrunCore` | Owns: packId, windowTitle, defaultProfiles, config.lua |
| Framework | `adamant-ModpackFramework` | Discovery, hash, HUD, UI. Exposes `Framework.init(params)`, `getRenderer`, `getMenuBar` |
| Lib | `adamant-ModpackLib` | Shared utilities used by Framework and all modules |
| Modules | `Submodules/adamant-*` | Standalone mods. Opt in via `public.definition.modpack = "speedrun"` |

### Coordinator (adamant-ModpackSpeedrunCore)

~50 lines. Sets `PACK_ID = "speedrun"`, `windowTitle = "Speedrun"`. Registers GUI callbacks once in `modutil.once_loaded.game` and delegates to Framework:

```lua
local Framework = mods['adamant-ModpackFramework']
rom.gui.add_imgui(Framework.getRenderer(PACK_ID))
rom.gui.add_to_menu_bar(Framework.getMenuBar(PACK_ID))
loader.load(init, init)
```

### Modules

- Each module declares `public.definition` with `modpack = "speedrun"` (set by `new_module.py`)
- Framework discovers modules by scanning `rom.mods` for `modpack = "speedrun"`
- `lib.isCoordinated("speedrun")` — true when coordinator is running
- `lib.isEnabled(config, "speedrun")` — checks module's Enabled AND coordinator's ModEnabled

### Module types
- **Regular**: flat `config.Enabled` + optional inline options (checkbox/dropdown/radio)
- **Special**: `special = true`, own sidebar tab, `stateSchema` for hashing, staging table

### Key technical details
- **Lua 5.1** runtime (Hades 2 engine), 32-bit integers only
- **Config hash**: key-value canonical string (`_v=1|ModId=1|ModId.configKey=val`), only non-default values encoded. 12-char base62 fingerprint on HUD.
- **Staging pattern**: plain Lua tables mirror Chalk config. UI reads/writes staging only. Chalk written only on `SyncToConfig()`.
- **`public = Framework` does NOT work** — ENVY holds a reference to the original `public` table.
- **Lib mod ID**: `mods['adamant-ModpackLib']`

## Orgs

- `h2pack-speedrun` — this pack's coordinator + all module repos
- `h2-modpack` — Framework, Lib, Setup, h2-modpack-template, h2-modular-modpack (infrastructure, shared)

## Current Modules (34)

adamant-BraidFix, adamant-CardioTorchFix, adamant-CharybdisBehavior, adamant-CorrosionFix,
adamant-DisableArachnePity, adamant-DisableSeleneBeforeBoon, adamant-EscalatingFigLeaf,
adamant-ETFix, adamant-ExtraDoseFix, adamant-FamiliarDelayFix, adamant-FirstHammer,
adamant-ForceArachne, adamant-ForceMedea, adamant-GGGFix, adamant-KBMEscape,
adamant-MiniBossEncounterFix, adamant-OmegaCastFix, adamant-PoseidonWavesFix,
adamant-PreventEchoScam, adamant-SecondStageChanneling, adamant-SeleneFix,
adamant-ShimmeringFix, adamant-ShowLocation, adamant-SkipDeathCutscene,
adamant-SkipDialogue, adamant-SkipGemBossReward, adamant-SkipRunEndCutscene,
adamant-SpawnLocation, adamant-SpeedrunTimer, adamant-StagedOmegaFix,
adamant-SufferingFix, adamant-SurfaceStructure, adamant-TidalRingFix, adamant-VictoryScreen

## Common Tasks

### Add a new module
```bash
python Setup/scaffold/new_module.py \
  --name MyModName \
  --pack-id speedrun \
  --namespace adamant \
  --org h2pack-speedrun
```
Creates GitHub repo `h2pack-speedrun/MyModName`, clones into `Submodules/adamant-MyModName`, fills PACK_ID, registers as submodule.

### Local deploy
```bash
python Setup/deploy/deploy_all.py
python Setup/deploy/deploy_all.py --overwrite   # regenerate manifests
```

### Release
Use **Actions → Release All** on the shell repo. Mass releases must end in `.0` (e.g. `1.2.0`). Hotfixes use patch > 0 and require `--modules` filter.

### Sync submodule list
```bash
python Setup/scaffold/register_submodules.py           # add any new Submodules/ folders
python Setup/scaffold/register_submodules.py --prune   # also remove orphaned entries
```

## CI/CD

- **Luacheck** on shell repo (push/PR to main)
- **Release**: per-repo `release.yaml`, shell repo `release-all.yaml` orchestrates all
- **Submodule sync**: daily midnight UTC cron

## Tech Stack

- Lua 5.1 (Hades 2 engine), 32-bit integers
- LuaUnit tests (Framework + Lib), Luacheck linting (all repos)
- Thunderstore packaging (tcli), r2modman mod manager (`h2-dev` profile)
- GitHub Actions CI (luacheck, release, submodule sync)

## User Preferences

- Namespace: `adamant` / org: `h2pack-speedrun` (pack), `h2-modpack` (infra)
- Concise responses, no emoji unless asked
- Ask before going deep on complex or uncertain tasks
