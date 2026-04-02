# Submodule Merger Plan

**Goal**: Reduce 34 standalone modules to 8 by merging modules that share the same `category` + `group`
into a single module. Each behavior lives in its own file under `src/behaviors/` and is loaded via
`import()` (ENVY), keeping things easy to move around later.

---

## Current Module Breakdown by Group

| Category | Group | Modules | Count |
|---|---|---|---|
| Bug Fixes | Boons & Hammers | BraidFix, CardioTorchFix, ETFix, OmegaCastFix, PoseidonWavesFix, SecondStageChanneling, ShimmeringFix | 7 |
| Bug Fixes | NPC & Encounters | CorrosionFix, FamiliarDelayFix, GGGFix, MiniBossEncounterFix, SufferingFix | 5 |
| Bug Fixes | Weapons & Attacks | ExtraDoseFix, SeleneFix, StagedOmegaFix, TidalRingFix | 4 |
| Run Modifiers | NPCs & Routing | DisableArachnePity, DisableSeleneBeforeBoon, ForceArachne, ForceMedea, PreventEchoScam | 5 |
| Run Modifiers | World & Combat Tweaks | CharybdisBehavior, EscalatingFigLeaf, SkipGemBossReward, SurfaceStructure | 4 |
| QoL | QoL | KBMEscape, ShowLocation, SkipDeathCutscene, SkipDialogue, SkipRunEndCutscene, SpawnLocation, VictoryScreen | 7 |
| Run Modifiers | Hammers | FirstHammer | 1 (special) |
| QoL | QoL | SpeedrunTimer | keep standalone (complex timer logic) |

---

## Proposed New Modules (34 → 8)

| New Module | Category | Group | Absorbs |
|---|---|---|---|
| `adamant-BugFixesBoons` | Bug Fixes | Boons & Hammers | 7 modules |
| `adamant-BugFixesEncounters` | Bug Fixes | NPC & Encounters | 5 modules |
| `adamant-BugFixesWeapons` | Bug Fixes | Weapons & Attacks | 4 modules |
| `adamant-RunModsNPCs` | Run Modifiers | NPCs & Routing | 5 modules |
| `adamant-RunModsWorld` | Run Modifiers | World & Combat Tweaks | 4 modules |
| `adamant-QoL` | QoL | QoL | 7 modules (no SpeedrunTimer) |
| `adamant-FirstHammer` | Run Modifiers | Hammers | no change (special=true) |
| `adamant-SpeedrunTimer` | QoL | QoL | no change (standalone) |

---

## Architecture: Self-Registering Behaviors

Each behavior file is fully self-contained. It appends to three module-global tables that are
declared in `main.lua` before any `import` calls:

- `apply_fns`  — sequence of `{ key=string, fn=function }`, called on apply, gated on `config[key]`
- `hook_fns`   — sequence of functions, called once on load to register game hooks
- `option_fns` — sequence of option descriptors, drives the Framework UI options list

These three tables are independent. A behavior can register in any combination of them.
Adding, removing, or moving a behavior between bundles requires only:
1. Moving the file
2. Adding/removing one `import` line in `main.lua`

Nothing else in `main.lua` ever needs to change.

### File structure (example: BugFixesBoons)

```
Submodules/adamant-BugFixesBoons/src/
├── main.lua
├── config.lua
└── behaviors/
    ├── BraidFix.lua
    ├── CardioTorchFix.lua
    ├── ETFix.lua
    ├── OmegaCastFix.lua
    ├── PoseidonWavesFix.lua
    ├── SecondStageChanneling.lua
    └── ShimmeringFix.lua
```

### main.lua layout

```lua
local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
lib = rom.mods['adamant-ModpackLib']

config = chalk.auto('config.lua')
public.config = config

backup, revert = lib.createBackupSystem()

-- Behavior registration tables — populated by each behaviors/*.lua file via import().
-- Each behavior file may append to any of these independently:
--   apply_fns : sequence of { key=string, fn=function }  — called on apply, gated on config[key]
--   hook_fns  : sequence of functions                    — called once on load to register hooks
--   option_fns: sequence of option descriptors           — drives the Framework UI options list
apply_fns  = {}
hook_fns   = {}
option_fns = {}

local PACK_ID = "speedrun"

import 'behaviors/BehaviorA.lua'
import 'behaviors/BehaviorB.lua'
-- one line per behavior, order controls UI display order

public.definition = {
    modpack      = PACK_ID,
    id           = "BundleName",
    name         = "Display Name",
    category     = "Category",
    group        = "Group",
    tooltip      = "...",
    default      = true,
    dataMutation = true,
    options      = option_fns,
}

local function apply()
    for _, b in ipairs(apply_fns) do
        if config[b.key] and b.fn then b.fn() end
    end
end

local function registerHooks()
    for _, fn in ipairs(hook_fns) do fn() end
end

public.definition.apply = apply
public.definition.revert = revert

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config, public.definition.modpack) then apply() end
        if public.definition.dataMutation and not lib.isCoordinated(public.definition.modpack) then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, revert)
---@diagnostic disable-next-line: redundant-parameter
rom.gui.add_to_menu_bar(uiCallback)
```

### Behavior file convention

Each file registers itself into whichever tables it needs. Use `table.insert` for all three.
`apply_fns` and `hook_fns` are independent — a behavior with no hooks simply omits `hook_fns`.

```lua
-- behaviors/BehaviorA.lua  (apply only)
table.insert(option_fns, { type = "checkbox", configKey = "BehaviorA", label = "Behavior A", default = true })
table.insert(apply_fns,  { key = "BehaviorA", fn = function()
    -- apply logic here
end })

-- behaviors/BehaviorB.lua  (apply + hook)
table.insert(option_fns, { type = "checkbox", configKey = "BehaviorB", label = "Behavior B", default = true })
table.insert(apply_fns,  { key = "BehaviorB", fn = function()
    -- apply logic here
end })

table.insert(hook_fns, function()
    modutil.mod.Path.Wrap("SomeGameFunction", function(baseFunc, ...)
        if not config.BehaviorB or not lib.isEnabled(config, public.definition.modpack) then
            return baseFunc(...)
        end
        -- hook logic here
        return baseFunc(...)
    end)
end)
```

### config.lua layout

```lua
return {
    Enabled    = true,
    DebugMode  = false,
    BehaviorA  = true,
    BehaviorB  = true,
    -- one key per behavior, all default true
}
```

### .luacheckrc — exclude behaviors/

Behavior files use game globals (`TraitData`, `WeaponSets`, etc.) not known to Luacheck.
Add `src/behaviors/*.lua` to `exclude_files`:

```lua
exclude_files = { "src/main.lua", "src/main_special.lua", "src/behaviors/*.lua" }
```

### Globals available to behavior files

`main.lua` declares these as module globals before importing, so all behavior files share them:
- `config`   — Chalk config table
- `backup`   — backup function from `lib.createBackupSystem()`
- `revert`   — revert function from `lib.createBackupSystem()`
- `lib`      — `mods['adamant-ModpackLib']`
- `modutil`  — `mods['SGG_Modding-ModUtil']`
- `public`   — ENVY module public table (needed for `public.definition.modpack` in hook guards)
- `apply_fns`, `hook_fns`, `option_fns` — registration tables

---

## Step-by-Step Execution Plan

Run once per bundle, in any order. Each bundle is independent.

### Step 1 — Scaffold
```bash
python Setup/scaffold/new_module.py \
  --name BugFixesBoons \
  --pack-id speedrun \
  --namespace adamant \
  --org h2pack-speedrun
```
Repeat for each bundle name.

### Step 2 — Update .luacheckrc
Add `"src/behaviors/*.lua"` to `exclude_files` in the scaffolded `.luacheckrc`.

### Step 3 — Read source modules
For each module being merged, read `src/main.lua` and note:
- The apply() body
- The registerHooks() body (if any)
- Any module-level locals/helpers needed by those functions

### Step 4 — Write behavior files
For each source module, create `src/behaviors/<Name>.lua`:
- `table.insert(option_fns, ...)` — checkbox with configKey = original module name
- `table.insert(apply_fns, { key=..., fn=function() ... end })` — apply body verbatim
- `table.insert(hook_fns, function() ... end)` — hook body verbatim, if the module had hooks
- Keep any module-level locals as `local` — they're file-scoped and won't collide
- Hook guards: use `config.<key>` AND `lib.isEnabled(config, public.definition.modpack)`

### Step 5 — Write main.lua and config.lua
- Copy the main.lua template above verbatim, fill in id/name/category/group/tooltip
- config.lua: `Enabled = true` plus one key per behavior, all `true`

### Step 6 — Commit and push
```bash
cd Submodules/adamant-<Bundle>
git add src/ .luacheckrc
git commit -m "feat: merge <N> modules into <Bundle>"
git push
```

### Step 7 — Deploy and verify
```bash
python Setup/deploy/deploy_all.py --overwrite
```
Load in r2modman (`h2-dev` profile). Toggle each behavior independently and confirm it works.

### Step 8 — Deprecate source modules
For each absorbed module:
- Archive the GitHub repo: `gh repo archive h2pack-speedrun/<RepoName>`
- Remove its entry from `.gitmodules` and delete its `Submodules/` folder
- Run `python Setup/scaffold/register_submodules.py --prune`

### Step 9 — Final deploy + release
```bash
python Setup/deploy/deploy_all.py --overwrite
# Actions → Release All — use a .0 version (mass release)
```

---

## Bundle Checklist

- [x] `adamant-BugFixesBoons` — 7 behaviors
- [ ] `adamant-BugFixesEncounters` — 5 behaviors
- [ ] `adamant-BugFixesWeapons` — 4 behaviors
- [ ] `adamant-RunModsNPCs` — 5 behaviors
- [ ] `adamant-RunModsWorld` — 4 behaviors
- [ ] `adamant-QoL` — 7 behaviors (KBMEscape, ShowLocation, SkipDeathCutscene, SkipDialogue, SkipRunEndCutscene, SpawnLocation, VictoryScreen)
- [ ] `adamant-FirstHammer` — no change (special=true)
- [ ] `adamant-SpeedrunTimer` — no change (standalone)

---

## Risk Notes

- **Hook guards**: always gate on both `config.<key>` AND `lib.isEnabled(config, pack)` in hooks.
  The first guards the per-behavior toggle; the second guards the module-level Enabled flag.
- **Callback timing**: all source modules use `modutil.once_loaded.game` + `loader.load`. The
  bundle uses the same pattern — no timing changes needed.
- **Scope**: behavior file locals are file-scoped via `local`. No collision risk between files.
- **Hash compatibility break**: key names change (`Enabled` → per-behavior key). Document in
  release notes. Old r2modman profiles will reset to defaults for affected modules.
- **Moving behaviors later**: move the file, update the `import` line and config.lua key.
  Nothing else changes.
