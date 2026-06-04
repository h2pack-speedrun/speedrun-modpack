# Speedrun Modpack — AI Assistant Context

## Project Structure

This is a **Hades 2 speedrun modpack** organized as a shell repo with git submodules under the `h2pack-speedrun` GitHub org.

```
speedrun-modpack/
├── adamant-ModpackSpeedrunCore/  # Coordinator: packId="speedrun", windowTitle="Speedrun", config, profiles
├── adamant-ModpackFramework/     # Reusable library: discovery, hash, HUD, UI (org: h2-modpack)
├── adamant-ModpackLib/           # Shared utilities: backup, field types, state mgmt (org: h2-modpack)
├── ModpackTools/                        # Local deploy, module creation, release helpers
│   ├── local_deploy/
│   │   ├── deploy_all.py         # Full local deploy (assets + manifests + symlinks + hooks)
│   │   └── steps/                # Deploy implementation modules
│   ├── new_module/
│   │   ├── create.py             # Create a new module repo from ModpackModuleTemplate
│   │   ├── register_submodules.py  # Sync .gitmodules with Submodules/ folders (--prune to remove orphans)
│   │   └── coordinator_deps.py   # Sync coordinator dependency block
│   └── github/
│       └── release_all.py        # Dispatch pack-wide release workflows
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

- Each module declares `public.definition` with `modpack = "speedrun"` (set by `create.py`)
- Framework discovers modules by scanning `rom.mods` for `modpack = "speedrun"`
- `lib.isCoordinated("speedrun")` — true when coordinator is running
- `lib.isEnabled(config, "speedrun")` — checks module's Enabled AND coordinator's ModEnabled

### Module types
- **Regular**: flat `config.Enabled` + optional inline options (checkbox/dropdown/radio). Options support a `tooltip` field rendered on hover.
- **Special**: `special = true`, own sidebar tab, `stateSchema` for hashing, staging table
- **Bundle**: multiple behaviors merged into one module using the self-registering pattern (see `Support/submodule_merger.md`). Each `src/behaviors/*.lua` file appends to three module-global tables declared in `main.lua`: `apply_fns` `{ key, fn }`, `hook_fns` (plain functions), `option_fns` (option descriptors).

### Key technical details
- **Lua 5.1** runtime (Hades 2 engine), 32-bit integers only
- **Config hash**: key-value canonical string (`_v=1|ModId=1|ModId.configKey=val`), only non-default values encoded. 12-char base62 fingerprint on HUD.
- **Staging pattern**: plain Lua tables mirror Chalk config. UI reads/writes staging only. Chalk written only on `SyncToConfig()`.
- **`public = Framework` does NOT work** — ENVY holds a reference to the original `public` table.
- **Lib mod ID**: `mods['adamant-ModpackLib']`

## Orgs

- `h2pack-speedrun` — this pack's coordinator + all module repos
- `h2-modpack` — Framework, Lib, ModpackTools, ModpackModuleTemplate, h2-modular-modpack (infrastructure, shared)

## Current Modules (8)

### Bundle modules — self-registering behavior pattern, see `Support/submodule_merger.md`
- **adamant-BugFixesBoons** — BraidFix, CardioTorchFix, ETFix, OmegaCastFix, PoseidonWavesFix, SecondStageChanneling, ShimmeringFix
- **adamant-BugFixesEncounters** — CorrosionFix, FamiliarDelayFix, GGGFix, MiniBossEncounterFix, SufferingFix
- **adamant-BugFixesWeapons** — ExtraDoseFix, SeleneFix, StagedOmegaFix, TidalRingFix
- **adamant-RunModsNPCs** — DisableArachnePity, DisableSeleneBeforeBoon, ForceArachne, ForceMedea, PreventEchoScam
- **adamant-RunModsWorld** — CharybdisBehavior, EscalatingFigLeaf, SkipGemBossReward, SurfaceStructure
- **adamant-QoL** — KBMEscape, ShowLocation, SkipDeathCutscene, SkipDialogue, SkipRunEndCutscene, SpawnLocation, VictoryScreen

### Standalone modules
- **adamant-FirstHammer**
- **adamant-SpeedrunTimer**

## Common Tasks

### Add a new module
```bash
python ModpackTools/new_module/create.py \
  --package-id My_Module \
  --title "My Module"
```
Creates a GitHub repo under the pack org, clones into `Submodules/`, fills module identity, and registers it as a submodule.

### Local deploy
```bash
python ModpackTools/local_deploy/deploy_all.py
python ModpackTools/local_deploy/deploy_all.py --overwrite   # regenerate manifests
```

### Release
Use **Actions → Release All** on the shell repo. Mass releases must end in `.0` (e.g. `1.2.0`). Hotfixes use patch > 0 and require `--modules` filter.

### Sync submodule list
```bash
python ModpackTools/new_module/register_submodules.py           # add any new Submodules/ folders + sync coordinator deps
python ModpackTools/new_module/register_submodules.py --prune   # also remove orphaned entries + sync coordinator deps
```
Also updates the managed `# -- submodules-start -- / # -- submodules-end --` block in the coordinator module's `thunderstore.toml` with the current submodule set and their versions.

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
