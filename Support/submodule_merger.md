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

## Architecture: File-per-Behavior with import()

Each merged module keeps each behavior in its own file under `src/behaviors/`. The framework
already uses this pattern (ENVY's `import()` loads files relative to `src/`, sharing scope).
This means behaviors can be moved between bundles later by moving one file and updating the imports.

### File structure (example: BugFixesBoons)

```
Submodules/adamant-BugFixesBoons/src/
├── main.lua                          # config, definition, apply/revert — imports behaviors
└── behaviors/
    ├── BraidFix.lua                  # BraidFix_apply(), BraidFix_revert()
    ├── CardioTorchFix.lua            # CardioTorchFix_apply(), CardioTorchFix_revert()
    ├── ETFix.lua
    ├── OmegaCastFix.lua
    ├── PoseidonWavesFix.lua
    ├── SecondStageChanneling.lua
    └── ShimmeringFix.lua
```

### Behavior file convention

Each file in `behaviors/` defines two functions named `<BehaviorName>_apply()` and
`<BehaviorName>_revert()`, plus any module-level locals it needs. Using a prefixed naming
convention avoids collisions between behavior files sharing the same `import()` scope.

```lua
-- src/behaviors/BraidFix.lua
local braid_state = nil   -- prefix locals to avoid collisions

function BraidFix_apply()
    -- original BraidFix apply() body
end

function BraidFix_revert()
    -- original BraidFix revert() body
end
```

### main.lua layout

```lua
mods['SGG_Modding-ENVY'].auto()

local config = chalk.auto('config.lua')

-- Import all behaviors (each defines <Name>_apply / <Name>_revert in shared scope)
import 'behaviors/BraidFix.lua'
import 'behaviors/CardioTorchFix.lua'
import 'behaviors/ETFix.lua'
import 'behaviors/OmegaCastFix.lua'
import 'behaviors/PoseidonWavesFix.lua'
import 'behaviors/SecondStageChanneling.lua'
import 'behaviors/ShimmeringFix.lua'

public.definition = {
    name     = "BugFixesBoons",
    modpack  = "speedrun",
    category = "Bug Fixes",
    group    = "Boons & Hammers",
    options  = {
        { key = "BraidFix",              label = "Braid Fix",               type = "checkbox" },
        { key = "CardioTorchFix",        label = "Cardio Torch Fix",        type = "checkbox" },
        { key = "ETFix",                 label = "ET Fix",                  type = "checkbox" },
        { key = "OmegaCastFix",          label = "Omega Cast Fix",          type = "checkbox" },
        { key = "PoseidonWavesFix",      label = "Poseidon Waves Fix",      type = "checkbox" },
        { key = "SecondStageChanneling", label = "Second Stage Channeling", type = "checkbox" },
        { key = "ShimmeringFix",         label = "Shimmering Fix",          type = "checkbox" },
    },
}

function public.apply()
    if config.BraidFix             then BraidFix_apply()             end
    if config.CardioTorchFix       then CardioTorchFix_apply()       end
    if config.ETFix                then ETFix_apply()                end
    if config.OmegaCastFix         then OmegaCastFix_apply()         end
    if config.PoseidonWavesFix     then PoseidonWavesFix_apply()     end
    if config.SecondStageChanneling then SecondStageChanneling_apply() end
    if config.ShimmeringFix        then ShimmeringFix_apply()        end
end

function public.revert()
    if config.BraidFix             then BraidFix_revert()             end
    if config.CardioTorchFix       then CardioTorchFix_revert()       end
    if config.ETFix                then ETFix_revert()                end
    if config.OmegaCastFix         then OmegaCastFix_revert()         end
    if config.PoseidonWavesFix     then PoseidonWavesFix_revert()     end
    if config.SecondStageChanneling then SecondStageChanneling_revert() end
    if config.ShimmeringFix        then ShimmeringFix_revert()        end
end
```

### config.lua layout

```lua
-- src/config.lua  (returned table, loaded by chalk.auto)
return {
    BraidFix              = true,
    CardioTorchFix        = true,
    ETFix                 = true,
    OmegaCastFix          = true,
    PoseidonWavesFix      = true,
    SecondStageChanneling = true,
    ShimmeringFix         = true,
}
```

All keys default `true` so everything is on unless the user opts out, matching current behavior
of standalone modules that ship enabled by default.

### Config hash impact
Each config key is included in the canonical hash (only non-default values encoded). Toggling any
individual behavior changes the hash, same semantics as the standalone modules had. However, **key
names change** (e.g. old `Enabled` per-module → new per-behavior key), so existing saved hashes
become invalid. Expected for a mass restructure — document in release notes.

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
Repeat for: `BugFixesEncounters`, `BugFixesWeapons`, `RunModsNPCs`, `RunModsWorld`, `QoL`.

### Step 2 — Read source modules
For each module being merged into this bundle, read `src/main.lua` and note:
- Module-level locals and helpers
- Callback registration timing (`modutil.once_loaded`, `loader.load`, etc.)
- Any `import` calls to sub-files (rare in simple modules)
- `rom.*` APIs used

### Step 3 — Write behavior files
For each source module, create `src/behaviors/<Name>.lua` in the bundle repo:
- Copy the apply/revert body verbatim
- Prefix any module-level locals with the behavior name to avoid scope collisions
- Name the exported functions `<Name>_apply()` and `<Name>_revert()`
- If the source module registers callbacks in a specific loading phase (e.g. `modutil.once_loaded.game`),
  keep that timing — wrap the hook registration inside the `_apply()` function or expose a separate
  `<Name>_register()` function called from the appropriate phase in main.lua

### Step 4 — Write main.lua and config.lua
Follow the layout shown above. Set `definition.category` and `definition.group` to match the bundle.

### Step 5 — Commit and push
```bash
cd Submodules/adamant-<Bundle>
git add src/
git commit -m "feat: merge <N> modules into <Bundle>"
git push
```

### Step 6 — Deploy and verify
```bash
python Setup/deploy/deploy_all.py --overwrite
```
Load in r2modman (`h2-dev` profile). Toggle each behavior independently and confirm it works.

### Step 7 — Deprecate source modules
For each absorbed module:
- Archive the GitHub repo: `gh repo archive h2pack-speedrun/<RepoName>`
- Remove its entry from `.gitmodules` and delete its `Submodules/` folder
- Run `python Setup/scaffold/register_submodules.py --prune`

### Step 8 — Final deploy + release
```bash
python Setup/deploy/deploy_all.py --overwrite
# Actions → Release All — use a .0 version (mass release)
```

---

## Bundle Checklist

- [ ] `adamant-BugFixesBoons` — 7 behaviors
- [ ] `adamant-BugFixesEncounters` — 5 behaviors
- [ ] `adamant-BugFixesWeapons` — 4 behaviors
- [ ] `adamant-RunModsNPCs` — 5 behaviors
- [ ] `adamant-RunModsWorld` — 4 behaviors
- [ ] `adamant-QoL` — 7 behaviors (KBMEscape, ShowLocation, SkipDeathCutscene, SkipDialogue, SkipRunEndCutscene, SpawnLocation, VictoryScreen)
- [ ] `adamant-FirstHammer` — no change (special=true)
- [ ] `adamant-SpeedrunTimer` — no change (standalone)

---

## Risk Notes

- **Scope collisions**: behavior files share the same `import()` scope. Prefix all locals and
  helper functions with the behavior name (e.g. `local braid_state`, `BraidFix_apply`).
- **Callback timing**: if a source module registers a hook inside `modutil.once_loaded.game` vs
  `loader.load`, preserve that phase. Don't flatten all registrations into one callback.
- **Stateful revert**: some modules hold state in a local variable set during apply and read during
  revert. Each behavior file owns its own local for this — they won't collide as long as prefixed.
- **Hash compatibility break**: key names change (`Enabled` → per-behavior key). Document in release
  notes. Old r2modman profiles will reset to defaults for affected modules.
- **Moving behaviors later**: to move a behavior from one bundle to another, move the file and
  update the `import` line + config/options/apply/revert entries in both bundles' main.lua files.
  No other changes needed.
