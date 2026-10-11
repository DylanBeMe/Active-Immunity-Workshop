# Example Workshop Mod — Spore Lancer Starter Pack

This folder is a complete, working Active Immunity Workshop item. Copy it,
rename it, and edit `manifest.json` to build your own mod.

It demonstrates, using no external image or sound files:

- A custom enemy (`enemy_definitions`) built on the built-in `fungus_basic`
  enemy, with its own attack pattern.
- A custom playable cell (`cell_definitions`) built on `t_helper`, with a
  damage-buff special and its own description.
- A custom projectile pattern (`projectile_patterns`) used by the new enemy.
- An opening wave override (`wave_overrides`) that mixes the new enemy into
  wave 1.
- New upgrades (`upgrades`), including one that uses `echo_chance` and
  `special_damage_mult`, and Spore Orbit, a secondary weapon (`orbit_count_add`).
- Spore Halo, an evolution of Spore Orbit (`evolves_from`), offered once Spore
  Orbit is maxed.
- Echoing Spores, a synergy (`synergies`) that switches on when Spore Orbit and
  Cascade Echo are both maxed.
- Spore Season, a run modifier (`run_modifiers`) players can switch on in the
  custom-run picker.
- Two player-facing settings (`settings`) with a cog menu in the Mod Manager,
  each pointing at a value already present in `content`.

Because it uses no scripts, scenes, or programs — only data — it is safe by
construction, and small enough to also be offered through the game's
temporary multiplayer host-content transfer (see the main [README](../../README.md)).

## Validate it

From the repository root:

```text
godot --headless --path . --script tools/validate_workshop_mod.gd -- examples/example-mod/manifest.json
```

You should see:

```text
Workshop package is valid: Spore Lancer Starter Pack
Canonical manifest content hash: <hash>
Active multiplayer source hash: computed in-game from enabled source IDs and configured normalized content.
```

## Publish it

1. Zip or point a Steam Workshop upload tool at this folder, with
   `manifest.json` at the top level.
2. Upload it to the Active Immunity Workshop.
3. Subscribe to your own item, then **REFRESH** and enable it in the
   in-game Mod Manager.
4. To iterate, edit `manifest.json`, re-upload, let Steam download the
   update, and **REFRESH** again.

See the main [README](../../README.md) for the full mod format reference.
