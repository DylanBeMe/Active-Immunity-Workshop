# AGENTS.md — Active Immunity Workshop modding

Instructions for AI coding assistants (Claude Code, Codex, Cursor, Copilot,
Aider, and similar) helping someone build a Steam Workshop mod for
**Active Immunity**, a Godot 4 bullet-hell game with an immune-system theme.

The person you are helping is often not a programmer. Explain in plain words,
keep their manifest valid at every step, and run the validator before you say
anything is finished.

## What a mod is

A mod is a folder with a single `manifest.json` at its root, plus optional
images and sounds referenced from that manifest. **It is data only.** The
game never runs scripts, scenes, or programs from a Workshop item, and it
rejects any item that tries.

```text
my-mod/
  manifest.json        required
  assets/*.png         optional textures (png, jpg, jpeg, webp, svg)
  audio/*.ogg          optional sounds (wav, ogg, mp3, max 10 s)
```

## Where the truth lives

Read these before writing or changing a manifest. Do not rely on memory or
on guesses about what "should" exist.

| File | Use it for |
| --- | --- |
| `README.md` | The full author guide. Part 3 lists every section and field; its tables list every upgrade and run-modifier effect with its allowed range. |
| `examples/example-mod/manifest.json` | A complete, valid mod using enemies, cells, projectile patterns, waves, upgrades, an evolution, a synergy, a run modifier, and settings. Copy its shapes. |
| `src/progression/workshop_content_registry.gd` | The validation code the game itself runs. The final word on allowed keys, ID lists, enum values, and numeric ranges. |
| `tools/validate_workshop_mod.gd` | The offline validator. Package limits (sizes, file counts, depth, symlinks) live here. |

When the README and the registry disagree, the registry wins — it is the same
code the game runs. Useful lookups in the registry:

- `CONTENT_SECTIONS` — every top-level key allowed inside `content`.
- `BUILTIN_ENEMIES`, `BUILTIN_CELLS`, `BUILTIN_BOSSES`, `BUILTIN_UPGRADES` —
  valid IDs to reference, use as `base`, evolve from, or name in a synergy.
- `ATTACK_PATTERNS`, `BOSS_PATTERNS`, `ENEMY_SHAPES`, `CELL_FIRE_PATTERNS`,
  `CELL_SPECIAL_TYPES`, `PROJECTILE_PATTERN_TYPES`, `SFX_WAVEFORMS` — enum values.
- `UPGRADE_EFFECT_RANGES`, `UPGRADE_INTEGER_EFFECTS`, `UPGRADE_BOOLEAN_EFFECTS` —
  upgrade and synergy effects.
- `RUN_MODIFIER_EFFECT_RANGES`, `RUN_MODIFIER_INTEGER_EFFECTS` — run modifier effects.
- `_normalize_enemy_overrides`, `_normalize_cell_overrides`,
  `_validate_boss_overrides`, `_normalize_sfx_recipes` — per-field allowed
  keys and ranges for those sections.

## Workflow

1. **Start from the example.** Copy `examples/example-mod/` to a new folder
   (for example `mods/my-mod/`) and edit its `manifest.json`, rather than
   writing a manifest from nothing.
2. **Make one kind of change at a time** and validate after each.
3. **Validate** from the repository root. This needs a Godot 4.7 binary on
   `PATH` (free from godotengine.org), not the game:

   ```text
   godot --headless --path . --script tools/validate_workshop_mod.gd -- mods/my-mod/manifest.json
   ```

   Success prints `Workshop package is valid: <name>`. Anything else is an
   error message naming the offending field; fix it and run again. Exit code
   `0` means valid.
4. **Hand over for in-game testing.** You cannot test in the game yourself.
   The game only loads mods from Steam Workshop subscriptions, so the person
   must upload the folder (private or friends-only while iterating), subscribe
   to it, and press **REFRESH** then enable it in the in-game **MODS** screen.
   Tell them this; do not claim the mod "works in game" from validation alone.
   Point them to the upload scripts in README Part 5
   (`tools/upload_workshop_mod.sh` on Linux, `tools/upload_workshop_mod.ps1`
   on Windows). They sign in to the person's Steam account, so the person runs
   them; do not run them yourself. Keep everything that is not part of the mod,
   including the `<folder>.workshop-id` file the script writes, outside the
   mod folder, because the whole folder is uploaded.

If Godot is not installed, say so and still check the manifest by hand
against the registry. Never report a mod as validated when the validator did
not run.

## Hard rules

These are the mistakes that get an item rejected. Check every one.

- `name` (1–128 chars) and a non-empty `content` object are required.
  `author` (≤128), `version` (1–64) and `description` (≤2,048) are optional
  strings.
- **Never add fields that are not documented.** Unknown keys, effects,
  enum values, or IDs make the game reject the *whole* item. Do not invent
  `format_version`, `schema_version`, `script`, `scene`, or similar.
- **Respect integer fields.** Counts and ranks (`count`, `max_level`,
  `rarity`, `extra_projectiles`, `pierce_add`, `orbit_count_add`,
  `projectile_count_add`, …) must be whole numbers. `5` and `5.0` are fine,
  `5.5` is rejected.
- **Switch effects are `true`/`false`**, never `1`/`0`.
- **Stay inside the allowed range** for every number. Look the range up in
  the README tables or the registry; do not assume.
- **Multipliers are factors, not percentages.** `damage_mult: 1.2` means
  +20%. `fire_rate_mult` multiplies the time *between* shots, so below 1 is
  faster.
- **Write colours** as `"#rrggbb"` or `"#rrggbbaa"` strings.
- **Asset paths** are relative to the mod folder, use forward slashes, and
  never start with `/` or contain `..`. Every referenced file must exist and
  be within the size limits (4 MiB per file, 4,096 px per side, 10 s audio).
- **New definitions build on a built-in base.** `enemy_definitions`,
  `cell_definitions`, and `bosses` take a `base` from the built-in lists and
  then `overrides`. They cannot introduce new behaviour, only recombine
  existing patterns and numbers.
- **IDs** you create may use only ASCII letters, digits, `_`, `-`, `:` and
  `.`, up to 64 characters; stick to lower-case `snake_case`. Upgrade and synergy IDs are namespaced per item automatically,
  so do not prefix them yourself.
- **Evolutions** (`evolves_from`) and **synergy recipes** (`requires`, 2–4
  entries) may only name your own upgrades or IDs in `BUILTIN_UPGRADES`.
- **Settings** go at the top level next to `name`, not inside `content`.
  Each `target` must be the path of a value that already exists in
  `content`, and the full `min`–`max` range must produce valid content.
- Limits: `manifest.json` ≤ 512 KiB, whole item ≤ 16 MiB, ≤ 2,048 files,
  ≤ 16 folders deep, no symlinks.

## Things that look supported but do nothing yet

Accepted for compatibility, ignored by the game. Do not use them to achieve
an effect, and tell the person if they ask for one:

- Wave pool `weight`, wave `name`, and `miniboss`.
- `scenario_waves`, `scenarios`, `scenario`.
- Boss `description`, `phases`, `icon_color`.
- Token rewards from run modifiers (not available to mods at all).

## Behaviour players will notice

Mention these when relevant so nobody is surprised:

- While any mod is enabled, Steam achievements are disabled and the run uses
  separate modded statistics, Tokens, and Complement progression.
- When several mods change the same thing, the one with the higher Workshop
  item ID wins.
- In multiplayer, a host's mods can be transferred to joining players only
  when they are pure data. A mod with its own images or sounds cannot be
  transferred at all: every player must subscribe to it, or the host turns it
  off.

## Do not

- Do not edit anything under `src/` or `tools/`. They mirror the game's own
  validation code; changing them only makes the validator lie.
- Do not tell the person to drop a folder somewhere to "install" it locally.
  There is no local mod folder; Workshop subscription is the only way in.
- Do not paste the person's full manifest back at them after every small
  change — show the part you changed.
