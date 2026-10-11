# Active Immunity — Workshop Modding Docs

This is the public modding documentation for **Active Immunity**, a Godot 4
top-down bullet-hell game with an immune-system theme. It is hosted here so it
can be linked directly from the game's Mods screen and its Steam store page.

This repository does not contain the game. Apart from the one validation file
the game itself uses (see [License](#license)), it has no game source code. It has:

- This guide, covering how to play with Workshop mods and how to make one.
- [`examples/example-mod/`](examples/example-mod/), a complete, working
  example mod you can copy and edit.
- [`tools/validate_workshop_mod.gd`](tools/validate_workshop_mod.gd), an
  optional offline checker that catches mistakes before you upload.
- [`AGENTS.md`](AGENTS.md), instructions for AI coding assistants, so an LLM
  can help you build a mod (see [Making a mod with an AI assistant](#making-a-mod-with-an-ai-assistant)).

You do not need to be a programmer, and you do not need the game's source
code or any game-development software to make a mod. A mod is a single text
file called `manifest.json`, optionally next to a few images and sound files.

---

## Part 1 — Playing with mods

### Turning a mod on

1. Start Steam and start Active Immunity.
2. From the main menu choose **MODS**.
3. Choose **OPEN WORKSHOP**. The Steam overlay opens on the Active Immunity
   Workshop page.
4. Subscribe to the items you want.
5. Return to the game and choose **REFRESH**.
6. Each installed item appears in the list with a toggle. Turn on the ones
   you want to play with.

Steam has to be running. Without it the game cannot see your subscriptions
and the Mod Manager will say `STEAM OFFLINE // WORKSHOP UNAVAILABLE`.

If an item shows as still downloading, give Steam a moment and press
**REFRESH** again.

### Mod settings

Some mods expose options — how many enemies a wave spawns, how big a
projectile ring is, and so on. If a mod has any, a cog button appears next to
its toggle.

Your choices are saved per mod and follow you through Steam Cloud. A mod
author cannot use settings to add new behaviour, only to change a number or a
true/false value they already put in the mod, and the result is re-checked
against all the normal safety limits.

### Are mods safe?

Yes, by design. A Workshop item is **data only**. The game never runs code,
scripts, scenes, or programs from a Workshop item. Everything a mod can do is
picking from a fixed list of values the game already knows how to handle, and
every one of those values is range-checked before it is used. The worst a
broken or malicious mod can do is fail to load.

### Mods and achievements

**Any run played with a mod enabled is kept separate from your normal
progress.**

While at least one valid mod is on:

- Steam achievements cannot be unlocked. The ACHIEVEMENTS button on the main
  menu is switched off and says why.
- Modded runs record into separate modded statistics, Tokens, and Complement
  progression.
- Your normal statistics, Tokens, Complement tree, and Steam Cloud saves are
  not touched.

Turn every mod off and your normal progression and achievements come
straight back, exactly as you left them.

### Playing together

Two things can happen in a multiplayer lobby:

- **Everyone is subscribed to the same mods.** Nothing to do. The game
  compares what each player has and starts.
- **The host has content a joining player does not.** The joining player is
  offered a one-off download of just the host's settings text. You must
  approve it. It is checked again on your machine, used only for that
  session, and thrown away afterwards. It never changes what you have
  subscribed to.

Sounds and images are **not** included in that transfer, because only text is
sent. If a host's mod replaces a sound or a texture, subscribe to the item
yourself to see and hear it.

A player cannot ready up until their content matches the host's exactly.

---

## Part 2 — Making a mod

### What a mod looks like

A mod is a folder. At the top of it sits a file named exactly
`manifest.json`. Anything else — images, sounds — lives in that same folder,
in subfolders if you like.

```text
my-mod/
  manifest.json
  audio/
    wave_clear.ogg
  assets/
    bacteria_basic.png
```

`manifest.json` is a text file. Write it in any plain-text editor: Notepad,
TextEdit, Notepad++, VS Code. It is written in JSON, a simple format built
from `"names": values` inside curly braces. If you have never written JSON,
copy the example below and change the values.

Two rules catch most beginners:

- Every item in a list needs a comma after it **except the last one**.
- Text goes in `"double quotes"`, numbers do not.

If the game says your manifest is not valid JSON, paste it into any free
online JSON checker to find the exact spot.

### The smallest working mod

```json
{
  "name": "Tougher Opening",
  "author": "Your Name",
  "version": "1.0.0",
  "description": "Wave one hits a lot harder.",
  "content": {
    "wave_overrides": {
      "1": {
        "interval": 0.18,
        "pools": [
          {"enemy": "bacteria_basic", "count": 50}
        ]
      }
    }
  }
}
```

`name` and `content` are required. `content` cannot be empty — an item with
nothing in it is rejected. `author`, `version`, and `description` are
optional text.

`name` must be 1–128 characters.

- `author` may be at most 128 characters after leading and trailing
  whitespace is removed.
- `version` defaults to `1.0` when omitted; when supplied, it must be 1–64
  characters after leading and trailing whitespace is removed.
- `description` may be at most 2,048 characters.

Do **not** add `format_version` or `schema_version`, and do not add scripts,
scenes, or programs. The format is deliberately one JSON file.

### A larger example

[`examples/example-mod/`](examples/example-mod/) in this repository is a
complete, working item you can copy and edit. It adds a custom enemy, a
custom playable cell, a projectile pattern, a wave override, upgrades
including a secondary weapon and its evolution, a synergy and a run
modifier, using no external files at all.

Here is a manifest using most of what is available:

```json
{
  "name": "Example Challenge Pack",
  "author": "Workshop Author",
  "version": "1.0.0",
  "description": "A harder opening sequence.",
  "content": {
    "wave_overrides": {
      "1": {
        "interval": 0.18,
        "pools": [
          {"enemy": "bacteria_basic", "count": 50},
          {"enemy": "bacteria_spinner", "count": 12}
        ]
      }
    },
    "rules": {
      "max_wave": 30,
      "enemy_health_per_extra_player": 0.25,
      "spawn_volume_per_extra_player": 0.15,
      "boss_base_health_multiplier": 2.5
    },
    "campaign_waves": {
      "26": {
        "interval": 0.12,
        "pools": [
          {"enemy": "prion_basic", "count": 80},
          {"enemy": "virus_basic", "count": 90}
        ]
      },
      "30": {
        "boss": true,
        "boss_id": "custom_boss",
        "overrides": {"boss_name": "Custom Final Response"}
      }
    },
    "bosses": {
      "custom_boss": {
        "base": "tumor",
        "name": "Custom Final Response",
        "overrides": {
          "hp_scale": 1.3,
          "boss_name": "Custom Final Response",
          "visual_color": "#ff6680",
          "bullet_color": "#ff3355"
        }
      }
    },
    "upgrades": {
      "antibody_reserve": {
        "name": "Antibody Reserve",
        "description": "+10% bullet damage",
        "rarity": 1,
        "max_level": 5,
        "effect": {"damage_mult": 1.1}
      }
    },
    "sfx": {
      "recipes": {
        "enemy_death": {
          "waveform": "noise",
          "freq_start": 1200,
          "freq_end": 180,
          "duration": 0.3,
          "volume": 0.35
        }
      },
      "files": {
        "wave_clear": {"file": "audio/wave_clear.ogg", "volume": 0.8}
      }
    },
    "enemy_overrides": {
      "bacteria_basic": {"max_health": 36, "bullet_damage": 12}
    },
    "cell_overrides": {
      "macrophage": {"color": "#ff9b57"}
    },
    "cosmetics": {
      "enemies": {
        "bacteria_basic": {
          "visual_color": "#ff6680",
          "bullet_color": "#ff3355",
          "texture": "assets/bacteria_basic.png"
        }
      },
      "cells": {
        "macrophage": {"color": "#ffbd72", "texture": "assets/macrophage.png"}
      }
    }
  }
}
```

### Making a mod with an AI assistant

You can build a mod by describing it to an AI coding assistant such as
Claude Code, Codex, Cursor, or GitHub Copilot.

1. Download or clone this repository and open the folder in your assistant.
2. Describe what you want, for example: *"Make a mod that adds a fast
   virus enemy that fires spirals and puts 30 of them in wave 3."*
3. Let it run the offline validator (see [Part 5](#offline-validator)) and
   fix anything it reports.
4. Upload the folder it made and test it in game as described in Part 5.

[`AGENTS.md`](AGENTS.md) tells the assistant the rules: start from the
example mod, use only fields this guide documents, check ranges against the
game's own validation code, and validate before calling anything done. Most
assistants read it automatically; Claude Code reads it through
[`CLAUDE.md`](CLAUDE.md). If yours does not, tell it to read `AGENTS.md`
first.

An assistant cannot test the mod inside the game for you — only you can,
through a Workshop subscription.

---

## Part 3 — What you can change

Everything below goes inside `content`.

### Waves and the campaign

- `wave_overrides` — replaces the enemies and spawn interval of chosen
  built-in waves.
- `campaign_waves` — replaces chosen waves and can extend the campaign past
  wave 25.
- `max_wave` — changes the last campaign wave. Also accepted inside `rules`.
- A normal wave takes `interval` (or `spawn_interval`) and `pools`. Each pool
  names an `enemy` and a positive `count`.
- `duration` sets the wave timer in seconds.
- A boss wave takes `boss: true` and a `boss_id`.

Pool `weight`, wave `name`, and `miniboss` are accepted so older mods keep
loading, but the game currently ignores them — pool counts decide what spawns.
The game still scales those counts the way it scales its own waves: x0.9
after wave 5, +15% for every 10 waves (up to +75%, spawned proportionally
faster so the wave still fits its timer), plus active run modifiers and extra
players.

`scenario_waves`, `scenarios`, and `scenario` are likewise accepted and
checked, but nothing in the game selects named scenarios yet.

**Built-in enemy IDs:** `bacteria_basic`, `bacteria_spinner`, `virus_basic`,
`fungus_basic`, `cancer_basic`, `parasite_basic`, `prion_basic`,
`parasite_toxoplasma`, `amoeba_naegleria`, `allergen_pollen`,
`virus_nanovirus`, `fungus_spore`, `cancer_fragment`, `parasite_larva`,
`prion_shard`.

**Built-in boss IDs:** `anthrax`, `hydra`, `colossus`, `broodmother`,
`cathedral`, `tumor`, `corona`, `filovirus`, `plague`, `deathcap`,
`nanovirus` (their longer built-in names also work).

### Multiplayer difficulty

Inside `rules`:

- `enemy_health_per_extra_player` — extra enemy health per additional
  player.
- `spawn_volume_per_extra_player` — extra spawn volume per additional
  player. The game caps the result at twice the base value no matter what
  you set.
- `boss_base_health_multiplier` — minimum boss health multiplier. The game
  enforces a floor of `2.5`.

### Changing existing enemies

`enemy_overrides`, keyed by enemy ID:

- `max_health`, `move_speed`, `contact_damage`, `score_value`
- `shoot_interval`, `bullet_speed`, `bullet_damage`
- `bullet_color`, `visual_color`, `visual_radius`
- `radial_bullet_count`, `aimed_spread_count`
- `attack_pattern`, `enemy_shape`, `aimed_spread_angle`,
  `radial_rotation_speed`, `spiral_spin_speed`, `projectile_pattern`
- `minion_interval`, `minion_spawn_count`
- `boss_pattern` and `boss_base_health_multiplier` where the target is a boss

### Changing existing cells

`cell_overrides`, keyed by cell ID. The six built-in cells are
`natural_killer`, `t_helper`, `b_cell`, `macrophage`, `neutrophil`,
`dendritic`.

- `max_health`, `hitbox_radius`, `move_speed`, `bullet_speed`,
  `bullet_damage`, `fire_rate`, `fire_pattern`, `special_cooldown_time`
- `special_radius`, `special_damage`, `special_duration`,
  `special_bullet_count`, `special_multiplier`, `special_type`,
  `special_description`
- `special_type`, one of `radial_burst`, `nova`, `dash`, `damage_buff`,
  `opsonize` (radial burst that marks pathogens within `special_radius` to take
  `special_multiplier` damage for `special_duration` seconds) or `net` (a trap of
  `special_radius` that lasts `special_duration` seconds, destroys enemy bullets
  and deals `special_damage` every half second)
- `color`
- `bullet_shape`, one of `circle`, `dagger`, `orb`, `antibody`, `dart`,
  `shard`, `blob`

### New enemies

`enemy_definitions` creates new enemy IDs on top of a built-in enemy's
behaviour. You can then use them in wave pools.

```json
"enemy_definitions": {
  "spore_lancer": {
    "base": "fungus_basic",
    "name": "Spore Lancer",
    "overrides": {
      "attack_pattern": "aimed_spread",
      "aimed_spread_count": 5,
      "projectile_pattern": "spore_ring"
    }
  }
}
```

### New playable cells

`cell_definitions` creates new cells on top of a built-in cell. They show up
in character select and in the multiplayer lobby.

```json
"cell_definitions": {
  "memory_cell": {
    "base": "t_helper",
    "name": "Memory Cell",
    "overrides": {
      "fire_pattern": "spread3",
      "special_type": "damage_buff",
      "special_duration": 8.0,
      "special_description": "Memory Cascade - boosts outgoing damage for 8s."
    }
  }
}
```

### New bosses

`bosses` (or `boss_definitions` — same thing) builds a boss on a built-in
boss base, chosen with `base` or `base_id`. The definition's name becomes the
boss's in-game name.

Override fields: `hp_scale`, `contact_scale`, `score_value`, `boss_name`,
`visual_color`, `bullet_color`, `boss_base_health_multiplier`,
`shoot_interval`, `bullet_speed`, `bullet_damage`, `visual_radius`,
`radial_bullet_count`, `aimed_spread_count`, `aimed_spread_angle`,
`radial_rotation_speed`, `spiral_spin_speed`, `attack_pattern`,
`boss_pattern`, `projectile_pattern`, `minion_interval`,
`minion_spawn_count`.

`boss_overrides` at the top level applies those same fields to a boss by ID
without replacing the wave it appears in — handy for tweaking the standard
miniboss and final boss.

`description`, `phases`, and `icon_color` are accepted but currently unused.

New bosses cannot introduce new attack code; patterns choose from built-in
behaviour.

### Projectile patterns

`projectile_patterns` defines enemy bullet patterns. Types: `aimed`,
`radial`, `spread`, `spiral`, `ring`. You can set count, spread, spin,
rotation offset, speed multiplier, and damage multiplier, then point an
enemy at one with the `projectile_pattern` override.

### New upgrades

`upgrades` adds choices to the level-up pool. IDs are automatically namespaced
per Workshop item, so two mods can safely use the same name.

Each upgrade needs a `name` and an `effect`. Optional fields:

- `description`: card text (default empty).
- `rarity`: `0` Common to `4` Legendary (default `0`).
- `max_level`: how many times it can be taken (default `1`).
- `category`, `icon_color`, `weight`: card grouping, accent colour and how
  often it is offered compared with built-in upgrades.
- `evolves_from`: makes it an **evolution**. Name one of your own upgrades or a
  built-in one (for example `"piercing"`). It is only offered once that upgrade
  is at its maximum level, and it does not take a build slot.
- `special_types`: only offer it to cells whose special is one of these, for
  example `["net"]` or `["radial_burst", "opsonize"]`.

```json
"upgrades": {
  "t_cell_swarm": {
    "name": "T-Cell Swarm",
    "description": "Two antibodies orbit you and a mine drops every few seconds.",
    "rarity": 2,
    "max_level": 2,
    "effect": {"orbit_count_add": 2, "mine_level_add": 1}
  },
  "swarm_ascendant": {
    "name": "Swarm Ascendant",
    "rarity": 4,
    "evolves_from": "t_cell_swarm",
    "effect": {"orbit_hit_interval_mult": 0.5, "volley_opsonize": true}
  }
}
```

Every effect the built-in upgrades use is available. Number effects are added
together across ranks and upgrades; `_mult` effects multiply. Whole-number
effects (ranks, counts) must be written without decimals.

**Offense**

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `bounce_add` | 0 to 16 | Extra targets each shot ricochets to. |
| `bullet_speed_mult` | 0.25 to 2.0 | Multiplies bullet speed. |
| `damage_mult` | 0.25 to 2.0 | Multiplies shot damage (1.2 = +20%). |
| `death_explosion_damage` | 0.0 to 100000.0 | Damage of that burst. |
| `death_explosion_radius` | 0.0 to 2000.0 | Radius of the burst a killed enemy explodes into. |
| `execute_threshold_add` | 0.0 to 0.5 | Hits instantly kill enemies below this health fraction (bosses at a third of it). |
| `extra_projectiles` | 0 to 16 | Extra forward shots per volley. |
| `fire_rate_mult` | 0.25 to 2.0 | Multiplies the time between shots; below 1 fires faster. |
| `flank_projectiles_add` | 0 to 16 | Extra wide side shots per volley. |
| `fork_add` | 0 to 3 | Pairs of rounds a shot splits into on its first hit. |
| `graze_damage_stack_add` | 0.0 to 1.0 | Extra damage per graze stack (3 s, up to 10 stacks). |
| `homing_add` | 0.0 to 1.0 | How strongly shots steer towards enemies. |
| `kill_damage_scale_add` | 0.0 to 0.1 | Extra damage per 25 kills this run, up to 30 steps. |
| `low_hp_damage_bonus` | 0.0 to 3.0 | Extra damage while wounded. |
| `low_hp_threshold` | 0.01 to 1.0 | Health fraction below which the cell counts as wounded (default 0.3). |
| `momentum_bullet_speed_scale` | 0.0 to 3.0 | Extra bullet speed scaling with movement speed. |
| `momentum_damage_scale` | 0.0 to 3.0 | Extra damage scaling with movement speed. |
| `momentum_firerate_scale` | 0.0 to 3.0 | Extra fire rate scaling with movement speed. |
| `pierce_add` | 0 to 16 | Enemies each shot passes through. |
| `range_damage_bonus_add` | 0.0 to 5.0 | Extra damage a shot reaches after flying a while (0.15 = +15%). |
| `stationary_damage_bonus` | 0.0 to 3.0 | Extra damage while standing still. |

**Weapons**

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `auto_volley_add` | 0 to 8 | Lysozyme Volley rank: rounds per automatic homing volley (2 + rank). |
| `mine_blast_mult` | 0.25 to 4.0 | Multiplies mine blast radius and damage. |
| `mine_level_add` | 0 to 8 | Cytokine Mines rank: more mines, faster drops, bigger blasts. |
| `orbit_count_add` | 0 to 8 | Orbiting Antibodies rank: first rank gives 2 antibodies, each extra rank 1 more. |
| `orbit_hit_interval_mult` | 0.1 to 4.0 | Multiplies the time between antibody strikes on the same enemy. |
| `orbit_momentum_scale` | 0.0 to 10.0 | Antibodies spin faster the faster you move. |
| `spore_chance_add` | 0.0 to 1.0 | Chance per kill to release a homing spore. |
| `volley_interval_mult` | 0.1 to 4.0 | Multiplies the time between volleys. |

**Special**

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `echo_chance` | 0.0 to 1.0 | Chance the special fires twice. |
| `graze_charge_mult` | 0.1 to 10.0 | Multiplies how much each graze refunds of the special cooldown. |
| `special_cd_mult` | 0.25 to 2.0 | Multiplies special cooldown. |
| `special_clear_radius_add` | 0.0 to 1000.0 | Using the special erases enemy bullets in this radius. |
| `special_damage_mult` | 0.25 to 3.0 | Multiplies special damage (also the Dendritic buff). |
| `special_duration_bonus` | 0.0 to 30.0 | Extra seconds for NETs, opsonin marks and damage buffs. |
| `special_radial_bullets_add` | 0 to 16 | Extra bullets for radial and opsonize specials. |
| `special_radius_mult` | 0.25 to 3.0 | Multiplies special radius (nova, NET, opsonize, Macrophage dash distance). |

**Defense**

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `damage_reduce` | 0.25 to 2.0 | Multiplies damage taken; below 1 takes less. |
| `death_explosion_heal` | 0.0 to 100.0 | Healing each death burst gives you. |
| `heal_on_kill` | 0.0 to 100.0 | HP healed for kills within the heal radius. |
| `heal_radius` | 1.0 to 2000.0 | Radius for kill healing (sets the value; the last one applied wins). |
| `healing_mult` | 0.25 to 3.0 | Multiplies all healing received. |
| `healing_orb_chance` | 0.0 to 1.0 | Chance a dying enemy drops a 10 HP vesicle. |
| `healing_pickup_mult` | 0.25 to 3.0 | Multiplies healing from pickups. |
| `invincibility_time_add` | 0.0 to 2.0 | Extra seconds of immunity after a hit. |
| `low_hp_regen_mult` | 0.25 to 5.0 | Multiplies regeneration while wounded. |
| `max_health_add` | 0.0 to 1000.0 | Adds max HP. |
| `max_health_mult` | 0.5 to 2.0 | Multiplies max HP. |
| `mutagen_add` | 0 to 1 | 1 = Mutagen: a random strong buff each wave, but +15% damage taken. |
| `regen_interval` | 0.1 to 300.0 | Seconds between regeneration ticks (the shortest wins). |
| `regen_rate` | 0.0 to 100.0 | HP healed per regeneration tick. |
| `shield_interval` | 0.1 to 300.0 | Seconds for a hit-absorbing shield to recharge (the shortest wins). |
| `shield_interval_mult` | 0.1 to 4.0 | Multiplies shield recharge time. |
| `speed_mult` | 0.25 to 2.0 | Multiplies movement speed. |
| `stationary_regen_interval_mult` | 0.25 to 2.0 | Multiplies regeneration interval while standing still. |
| `stationary_shield_interval_mult` | 0.25 to 2.0 | Multiplies shield recharge time while standing still. |

**Utility**

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `extra_enemy_spawns` | 0 to 420 | Extra enemies in every non-boss wave. |
| `intermission_time_add` | 0.0 to 300.0 | Extra seconds between waves. |
| `luck_add` | 0.0 to 1.0 | Raises the odds of Rare and better upgrades being offered. |
| `xp_gain_mult` | 0.25 to 3.0 | Multiplies XP gained. |
| `xp_magnet_mult` | 0.25 to 3.0 | Multiplies XP pickup radius. |
| `xp_orb_lifetime_add` | 0.0 to 60.0 | Extra seconds XP orbs stay on the floor. |

**Switches** (write `true` or `false`)

| Effect | What it does |
| --- | --- |
| `bounce_keeps_pierce` | Ricocheting shots keep their remaining pierce. |
| `moving_frenzy_damage_cancel` | Moving cancels the damage penalty of Frenzy-style damage_mult on the same upgrade. |
| `split_homing_targets` | Homing shots in one volley pick different targets. |
| `volley_opsonize` | Lysozyme Volley rounds apply the B Cell mark (3 s, +20% damage taken). |
An effect name that is not on these lists, a value outside its allowed range, or
a switch written as a number makes the game reject the whole item (`upgrade <id>
has an unsupported effect`, `... is out of range` or `... must be true or
false`), so check spellings against these tables.

### New synergies

`synergies` adds combinations that switch on when every upgrade in the recipe is
at its maximum level, like the built-in ones. A recipe lists 2 to 4 upgrades:
your own, built-in ones, or a mix. IDs are namespaced per item, the same as
upgrades.

```json
"synergies": {
  "swarm_lance": {
    "name": "Swarm Lance",
    "description": "Orbiters and piercing rounds feed each other.",
    "requires": ["t_cell_swarm", "piercing"],
    "effect": {"execute_threshold_add": 0.05, "bounce_keeps_pierce": true}
  }
}
```

`name`, `requires` and `effect` are required, and `description` is optional.
The effect uses the same tables as upgrades. The description is also the
Lexicon's hint before the synergy has been found, so describe the pairing
without naming the upgrades.

### Run modifiers

`run_modifiers` adds optional rules to the custom-run picker, next to the
built-in ones such as Double Waves and Low Gravity. Players switch them on
before a run; several can be on at once, and their effects combine with each
other and with the built-in ones (multipliers multiply, `_add` effects add).

```json
"run_modifiers": {
  "fever": {
    "name": "Fever",
    "description": "Pathogens move 25% faster, but you hit 20% harder.",
    "effects": {"enemy_speed_multiplier": 1.25, "player_damage_multiplier": 1.2}
  }
}
```

`name`, `description` and `effects` are required. Daily challenges never use
Workshop modifiers, so every player's daily stays the same run; seed codes do
carry them, so a code only works for players with the same mod.

| Effect | Allowed values | What it does |
| --- | --- | --- |
| `enemy_count_multiplier` | 0.25 to 2.0 | Multiplies enemies per non-boss wave. |
| `enemy_health_multiplier` | 0.25 to 4.0 | Multiplies enemy and boss health. |
| `enemy_speed_multiplier` | 0.25 to 2.5 | Multiplies enemy movement speed. |
| `enemy_bullet_speed_multiplier` | 0.25 to 2.5 | Multiplies enemy bullet speed. |
| `fragment_health_multiplier` | 0.25 to 4.0 | Multiplies Complement fragment durability. |
| `healing_multiplier` | 0.0 to 3.0 | Multiplies all healing (0 = no healing). |
| `healing_pickup_multiplier` | 0.0 to 3.0 | Multiplies healing from pickups. |
| `player_damage_multiplier` | 0.25 to 4.0 | Multiplies all player damage. |
| `max_health_multiplier` | 0.25 to 3.0 | Multiplies the cell's max HP. |
| `fire_rate_multiplier` | 0.25 to 2.0 | Multiplies the time between shots; below 1 fires faster. |
| `special_cooldown_multiplier` | 0.25 to 3.0 | Multiplies special cooldown. |
| `special_damage_multiplier` | 0.25 to 4.0 | Multiplies special damage. |
| `damage_buff_duration_multiplier` | 0.25 to 4.0 | Multiplies damage-buff duration. |
| `xp_gain_multiplier` | 0.25 to 4.0 | Multiplies XP from pickups. |
| `xp_reward_multiplier` | 0.25 to 4.0 | Multiplies XP from completed encounters. |
| `intermission_multiplier` | 0.25 to 4.0 | Multiplies the time between waves. |
| `score_multiplier` | 0.25 to 4.0 | Multiplies score. |
| `heal_on_kill_add` | 0.0 to 50.0 | HP healed per nearby kill. |
| `projectile_count_add` | 0 to 8 | Extra forward shots per volley (whole number). |

Token rewards are not available to mods.

### Sounds

`sfx.recipes` replaces the game's generated sounds for these events:
`player_hit`, `player_death`, `enemy_hit`, `enemy_death`,
`enemy_death_boss`, `special_cast`, `boss_phase_shift`, `level_up`,
`xp_pickup`, `wave_clear`, `wave_start`, `evolution`, `graze_charge`,
`ui_hover`, `ui_click`, `ui_back`.

A recipe sets waveform, frequency range, duration, envelope, volume,
optional filter sweep or cutoff, and cooldown. Waveforms: `sine`, `square`,
`saw`, `triangle`, `noise`. When `filter_sweep` is off, `filter_cutoff` acts
as a fixed low-pass.

`sfx.files` replaces those same events with your own `.wav`, `.ogg`, or
`.mp3` from inside your mod folder.

### Colours and textures

`cosmetics.enemies.<enemy_id>` and `cosmetics.cells.<cell_id>` take colour
overrides and a `texture` pointing at an image in your mod folder.

Paths must stay inside your folder — absolute paths and `../` are rejected.

### Mod settings

Add a `settings` list at the top level of the manifest (next to `name`, not
inside `content`) to give players a cog menu.

Each setting needs `id`, `label`, `type`, `default`, and `target`. `target`
is the path to an existing value inside `content`, written as a list of key
names and list positions.

Types:

- `boolean` — a true/false value.
- `integer` — whole numbers, with `min`, `max`, and a positive `step`.
- `number` — decimals, with `min`, `max`, and a positive `step`.
- `choice` — a `default` plus an `options` list of 1–32 values of the same
  type.

```json
"settings": [
  {
    "id": "opening_spore_count",
    "label": "Opening Spore Count",
    "type": "integer",
    "default": 8,
    "min": 4,
    "max": 40,
    "step": 4,
    "target": ["wave_overrides", "1", "pools", 0, "count"]
  }
]
```

A setting can only replace a value that already exists. It cannot add new
fields or behaviour, and the result is validated again afterwards.

---

## Part 4 — Limits

| Thing | Limit |
| --- | --- |
| `manifest.json` | 512 KiB |
| Whole item | 16 MiB |
| Files in an item | 2,048 |
| Folder depth | 16 below the item root |
| Any one image or sound | 4 MiB |
| Image formats | PNG, JPG/JPEG, WEBP, SVG |
| Image size | 4,096 pixels per side, 16 megapixels |
| Audio formats | WAV, OGG, MP3 |
| Audio length | 10 seconds |
| `author` | 128 characters after trimming |
| `version` | 1–64 characters after trimming |
| `description` | 2,048 characters |

Whole numbers may be written `5` or `5.0`; `5.5` where a whole number is
expected is rejected.

An oversized or unreadable image or sound falls back to the original game
asset rather than breaking the mod.

Every item entry must be a regular file or directory. Symlinked files and
directories, including nested ones, are rejected.

### When several mods are on at once

Mods are combined in ascending Workshop item ID order. If two mods change
the same thing, the one with the higher item ID wins.

---

## Part 5 — Testing and publishing

The game loads mods **only from your Steam Workshop subscriptions**. There
is no in-game publishing tool and no folder you can drop a mod into to test
it locally, so the loop is:

1. Upload your mod folder as a **private** Workshop item with the upload
   script below.
2. Subscribe to your own item.
3. **REFRESH** in the Mod Manager and enable it.
4. To change something, edit `manifest.json`, run the upload script again,
   let Steam download the update, and **REFRESH** again.

### One-time setup: SteamCMD

The upload scripts use **SteamCMD**, Valve's free command-line Steam client.
You sign in with your own Steam account, which must own Active Immunity.

- **Windows:** download
  [steamcmd.zip](https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip),
  unzip it to `C:\steamcmd`, and run `C:\steamcmd\steamcmd.exe` once so it can
  update itself. Type `quit` when it shows `Steam>`. The script looks there
  automatically.
- **Linux:** install the `steamcmd` package from your distribution (on
  Debian and Ubuntu it is in the `non-free` / `multiverse` repositories), or
  download
  [steamcmd_linux.tar.gz](https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz),
  unpack it to `~/steamcmd` and pass `--steamcmd ~/steamcmd/steamcmd.sh`.

Valve's [SteamCMD page](https://developer.valvesoftware.com/wiki/SteamCMD)
has more detail. If [Godot 4.7](https://godotengine.org/download) is on your
`PATH`, the scripts also run the offline validator before every upload.

### Uploading with the script

Run these from this repository's folder. `mods/my-mod` is your mod folder,
the one with `manifest.json` directly inside it.

**Linux:**

```text
tools/upload_workshop_mod.sh mods/my-mod --steam-user YOUR_STEAM_NAME
```

**Windows** (PowerShell; Windows blocks scripts unless you pass
`-ExecutionPolicy Bypass`):

```text
powershell -ExecutionPolicy Bypass -File tools\upload_workshop_mod.ps1 -ModFolder mods\my-mod -SteamUser YOUR_STEAM_NAME
```

On Windows you can also leave out `-ModFolder` and `-SteamUser`; the script
asks for them.

The first time, Steam asks for your password and a Steam Guard code. The
script then:

1. validates the mod, when Godot is available;
2. creates a new **private** Workshop item, titled and described from the
   `name` and `description` in your `manifest.json`;
3. saves the item's ID **next to** your mod folder, as
   `mods/my-mod.workshop-id`.

Keep that `.workshop-id` file. Running the script again **updates** the same
item instead of creating a new one; delete the file only if you really want
a second, separate item.

Then open the link the script prints. New items stay hidden until you accept
the **Steam Workshop legal agreement** on that page. Subscribe to the item,
and test it in game.

| Linux | Windows | What it does |
| --- | --- | --- |
| `--changenote "..."` | `-ChangeNote "..."` | What changed; shown in the item's change notes. |
| `--visibility V` | `-Visibility V` | `private` (default for new items), `friends`, `unlisted` or `public`. |
| `--title "..."` | `-Title "..."` | Item title. |
| `--description "..."` | `-Description "..."` | Item description. |
| `--preview FILE` | `-Preview FILE` | Preview image: PNG, JPG or GIF, under 1 MB. |
| `--steamcmd PATH` | `-SteamCmd PATH` | Where SteamCMD is, if the script cannot find it. |

When you update an item, the title, description, visibility and preview only
change if you pass them, so anything you edited on the item's Steam page
stays as it is.

**Everything in the mod folder is uploaded**, so keep only `manifest.json`
and the images and sounds it uses in there. Keep notes, drafts and the
`.workshop-id` file outside it.

When your mod is ready for everyone, switch it to **public** on its Workshop
page, or upload with `--visibility public` (Windows: `-Visibility public`).

### Offline validator

This repository includes a self-contained offline checker that validates a
mod folder before you upload it — you only need a free copy of the
[Godot 4.7 engine](https://godotengine.org/download), not the game itself:

```text
godot --headless --path . --script tools/validate_workshop_mod.gd -- path/to/manifest.json
```

It checks the JSON, every referenced file, symlinks, and all the size
limits. It prints a **canonical manifest content hash** for the normalized
content using the manifest's default settings. That is useful for seeing
whether content changed, but it is not the active multiplayer source hash.
In game, the active multiplayer source hash covers every enabled source
identifier and its normalized content after the player's active settings
are applied; that is the hash clients must match. The validator cannot
check anything about Steam itself. This is entirely optional — the game
performs the same checks when it loads your item and tells you what is
wrong.

Try it now against the bundled example:

```text
godot --headless --path . --script tools/validate_workshop_mod.gd -- examples/example-mod/manifest.json
```

---

## Part 6 — When something goes wrong

An item that fails to load stays visible in the Mod Manager but cannot be
turned on, and shows the reason. Here is what each message means.

| Message | What to do |
| --- | --- |
| `Missing manifest.json.` | The file must sit at the very top of the item, and be named exactly `manifest.json`. |
| `manifest.json is not valid JSON.` | A typo — usually a missing comma, a trailing comma, or a missing quote or brace. Paste it into an online JSON checker. |
| `Manifest is missing content.` | Add a `content` object. An item with no content is rejected. |
| `Manifest content must be an object.` | `content` has to be `{ ... }`, not a list or text. |
| `Manifest name is missing or too long.` | Add a `name` of 1–128 characters. |
| `name/author/version/description must be a string.` | Wrap the value in double quotes. |
| `Invalid Workshop content: ...` | The rest of the message names the offending field. Usually a misspelled ID or a number outside the allowed range. |
| `Invalid mod settings: ...` | A setting is malformed, or its `target` does not point at a value that exists in `content`. |
| `Mod settings produce invalid content: ...` | A setting's range lets a player pick a value the content rules reject. Tighten its `min`/`max`. |
| `Could not apply mod settings.` | A `target` path does not match the shape of your content. |
| `Workshop item exceeds the 16 MiB size limit.` | Shrink or remove assets. |
| `manifest.json exceeds the 512 KiB size limit.` | Trim the manifest. |
| `Could not read manifest.json.` | The file could not be opened — re-upload the item. |
| `Steam did not provide an install directory.` / `Downloading or waiting for Steam to install this item.` | Steam has not finished installing. Wait, then **REFRESH**. |
| `Workshop install directory is unsafe.` | The installed folder is a symlink. Unsubscribe, delete any leftover folder, and resubscribe. |

Other things worth knowing:

- **My achievements are switched off.** That is deliberate whenever any
  valid mod is enabled. Turn them all off to restore normal play.
- **My custom sound or texture is not used.** Check the file is inside the
  mod folder, that the path in the manifest matches, and that it is within
  the format and size limits. Anything out of bounds silently falls back to
  the original.
- **A friend cannot join my modded lobby.** They must accept the
  host-content offer, or subscribe to the same items. Sounds and images are
  never sent — those always need a subscription.
- **My item is rejected with `unsupported effect`.** An upgrade uses an
  effect name that is not on the list above. Check the spelling.

---

## Repository layout

```text
README.md                            This guide.
LICENSE                              What you may do with this repository.
AGENTS.md                            Instructions for AI coding assistants.
CLAUDE.md                            Points Claude Code at AGENTS.md.
examples/example-mod/                A complete, working example mod.
  manifest.json
  README.md
tools/validate_workshop_mod.gd       Offline validator entry point.
tools/upload_workshop_mod.sh         Upload script for Linux (Part 5).
tools/upload_workshop_mod.ps1        Upload script for Windows (Part 5).
src/progression/workshop_content_registry.gd
                                      Validation logic shared with the game.
project.godot                        Minimal project so the validator can run.
```

`tools/` and `src/` mirror the validation code from the game's own source
tree so the checker's results always match what the game does at load time.
This repository does not contain the game itself.

## License

This repository is **not open source**. See [`LICENSE`](LICENSE) for the
full terms; in short:

- **The example mod** is yours to copy, change and publish as your own mod,
  no credit needed.
- **The upload scripts** may be used, changed and shared for publishing
  Active Immunity mods.
- **The docs** are for making Active Immunity mods, alone or with an AI
  assistant.
- **The validator and `workshop_content_registry.gd`** may be run to check
  Active Immunity mods, but not redistributed or reused in other software.
  The registry is the game's own validation file, shared so the checker
  agrees with the game.

## Questions and bug reports

Open an issue on this repository. Include your `manifest.json` and the exact
error message shown by the Mod Manager or the offline validator.
