extends RefCounted
class_name WorkshopContentRegistry

## Validation and normalization for the current Workshop content schema. This class only deals
## with JSON-compatible data; it never loads or instantiates user content.

const MAX_RULE_VALUE := 1000000.0
const MAX_SUPPORTED_CAMPAIGN_WAVE := 75
const MAX_WAVE_NUMBER := MAX_SUPPORTED_CAMPAIGN_WAVE
const MAX_CAMPAIGN_CONTENT_BYTES := 48 * 1024
const MAX_WAVE_SPAWNS := 250
const MAX_WAVE_POOLS := 64
const MAX_UPGRADE_LEVEL := 10
const MAX_SFX_DURATION := 10.0
const MAX_SFX_FILE_LENGTH := 200
const MAX_ASSET_PATH_DEPTH := 16
const MAX_NETWORK_SOURCES := 64
const MAX_MOD_SETTINGS := 32
const MAX_MOD_SETTING_OPTIONS := 32
const IMAGE_FILE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]

const CONTENT_SECTIONS := [
	"rules", "max_wave", "wave_overrides", "campaign_waves", "scenario_waves", "campaign", "scenarios", "scenario",
	"bosses", "boss_definitions", "boss_overrides", "upgrades", "sfx", "sfx_recipes", "sfx_files",
	"enemy_overrides", "cell_overrides", "cosmetics", "enemy_definitions", "cell_definitions",
	"projectile_patterns", "synergies", "run_modifiers",
]
const SFX_WAVEFORMS := ["sine", "square", "saw", "triangle", "noise"]
const SFX_FILE_EXTENSIONS := ["wav", "ogg", "mp3"]
const BUILTIN_ENEMIES := ["bacteria_basic", "bacteria_spinner", "virus_basic", "fungus_basic", "cancer_basic", "parasite_basic", "prion_basic", "parasite_toxoplasma", "amoeba_naegleria", "allergen_pollen", "virus_nanovirus", "fungus_spore", "cancer_fragment", "parasite_larva", "prion_shard"]
const BUILTIN_CELLS := ["natural_killer", "t_helper", "b_cell", "macrophage", "neutrophil", "dendritic"]
const BUILTIN_BOSSES := ["anthrax", "hydra", "colossus", "broodmother", "cathedral", "tumor", "corona", "filovirus", "plague", "deathcap", "nanovirus", "anthrax_prime", "viral_hydra", "fungal_colossus", "parasitic_broodmother", "prion_cathedral", "tumor_boss"]
const ATTACK_PATTERNS := ["aimed", "radial", "spiral", "aimed_spread", "boss_cycle"]
const BOSS_PATTERNS := ["generic", "anthrax", "hydra", "colossus", "broodmother", "cathedral", "tumor", "nanovirus", "corona", "filovirus", "plague", "deathcap"]
const ENEMY_SHAPES := ["generic", "rod", "spiky", "mushroom", "blob", "fragment", "boss", "parasite", "larva", "prion", "prion_shard", "tumor", "corona", "filament", "plague", "deathcap", "toxo", "amoeba", "pollen", "nano", "nano_prime", "hydra"]
const CELL_FIRE_PATTERNS := ["single", "spread3"]
const CELL_SPECIAL_TYPES := ["radial_burst", "nova", "dash", "damage_buff", "opsonize", "net"]
const PROJECTILE_PATTERN_TYPES := ["aimed", "radial", "spread", "spiral", "ring"]
const UPGRADE_EFFECT_RANGES := {
	"fire_rate_mult": [0.25, 2.0],
	"damage_mult": [0.25, 2.0],
	"speed_mult": [0.25, 2.0],
	"bullet_speed_mult": [0.25, 2.0],
	"damage_reduce": [0.25, 2.0],
	"invincibility_time_add": [0.0, 2.0],
	"special_cd_mult": [0.25, 2.0],
	"extra_projectiles": [0, 16],
	"pierce_add": [0, 16],
	"bounce_add": [0, 16],
	"homing_add": [0.0, 1.0],
	"heal_on_kill": [0.0, 100.0],
	"heal_radius": [1.0, 2000.0],
	"healing_mult": [0.25, 3.0],
	"healing_pickup_mult": [0.25, 3.0],
	"xp_magnet_mult": [0.25, 3.0],
	"regen_rate": [0.0, 100.0],
	"regen_interval": [0.1, 300.0],
	"shield_interval": [0.1, 300.0],
	"special_damage_mult": [0.25, 3.0],
	"special_radius_mult": [0.25, 3.0],
	"echo_chance": [0.0, 1.0],
	"xp_gain_mult": [0.25, 3.0],
	"max_health_add": [0.0, 1000.0],
	"max_health_mult": [0.5, 2.0],
	"stationary_damage_bonus": [0.0, 3.0],
	"momentum_damage_scale": [0.0, 3.0],
	"low_hp_damage_bonus": [0.0, 3.0],
	"momentum_firerate_scale": [0.0, 3.0],
	"death_explosion_radius": [0.0, 2000.0],
	"death_explosion_damage": [0.0, 100000.0],
	"extra_enemy_spawns": [0, MAX_WAVE_SPAWNS],
	"intermission_time_add": [0.0, 300.0],
	"low_hp_threshold": [0.01, 1.0],
	"death_explosion_heal": [0.0, 100.0],
	"stationary_shield_interval_mult": [0.25, 2.0],
	"luck_add": [0.0, 1.0],
	"stationary_regen_interval_mult": [0.25, 2.0],
	"healing_orb_chance": [0.0, 1.0],
	"xp_orb_lifetime_add": [0.0, 60.0],
	"low_hp_regen_mult": [0.25, 5.0],
	"momentum_bullet_speed_scale": [0.0, 3.0],
	"special_radial_bullets_add": [0, 16],
	"flank_projectiles_add": [0, 16],
	"fork_add": [0, 3],
	# Secondary weapons, their evolution multipliers and play-style effects.
	"orbit_count_add": [0, 8],
	"mine_level_add": [0, 8],
	"auto_volley_add": [0, 8],
	"orbit_hit_interval_mult": [0.1, 4.0],
	"mine_blast_mult": [0.25, 4.0],
	"volley_interval_mult": [0.1, 4.0],
	"graze_damage_stack_add": [0.0, 1.0],
	"range_damage_bonus_add": [0.0, 5.0],
	"execute_threshold_add": [0.0, 0.5],
	"special_clear_radius_add": [0.0, 1000.0],
	"kill_damage_scale_add": [0.0, 0.1],
	"spore_chance_add": [0.0, 1.0],
	"mutagen_add": [0, 1],
	"shield_interval_mult": [0.1, 4.0],
	"graze_charge_mult": [0.1, 10.0],
	"orbit_momentum_scale": [0.0, 10.0],
	"special_duration_bonus": [0.0, 30.0],
}
const UPGRADE_INTEGER_EFFECTS := [
	"extra_projectiles", "pierce_add", "bounce_add", "extra_enemy_spawns", "special_radial_bullets_add",
	"flank_projectiles_add", "fork_add", "orbit_count_add", "mine_level_add", "auto_volley_add", "mutagen_add",
]
## Switches rather than amounts: true turns the behaviour on.
const UPGRADE_BOOLEAN_EFFECTS := ["bounce_keeps_pierce", "split_homing_targets", "moving_frenzy_damage_cancel", "volley_opsonize"]
## Built-in upgrade ids a mod may evolve from or name in a synergy recipe. Kept
## here rather than read from the game so the standalone validator works too;
## a test checks it against the game's upgrade library.
const BUILTIN_UPGRADES := [
	"ability_focus", "ability_haste", "ability_mastery", "adrenal_graze", "adrenaline", "antibody_orbit",
	"antigen_residue", "apoptosis_signal", "berserker", "cellular_renewal", "chain_lysis", "chemotaxis",
	"complement_halo", "compound_interest", "crossfire_protocol", "cytokine_minefield", "cytokine_mines",
	"cytokine_overdrive", "cytokine_primer", "cytokine_shock", "cytotoxic_payload", "echo", "extended_breather",
	"field_triage", "flanking_response", "forked_rounds", "frenzy", "glass_cannon", "granuloma",
	"hitchhiker_spores", "homing", "hyperplasia", "immune_memory", "lucky", "lysing_rounds", "lysozyme_barrage",
	"lysozyme_volley", "macropinocytosis", "membrane_repair", "momentum", "multi_shot", "mutagen",
	"needle_response", "nova_power", "overcharge", "phagocytosis", "phoenix_protocol", "piercing",
	"power_shot", "prismatic_cascade", "quick_hands", "quickening", "rapid_fire", "regen", "reinforcement_signal",
	"ricochet", "salvaged_vesicles", "shield", "signal_aperture", "stillness", "swift", "thick_skin",
	"vitality", "volatile_lysis", "xp_magnet",
]
const MAX_SYNERGY_REQUIREMENTS := 4
## Run modifier effects a mod may use: everything the built-in modifiers,
## contracts and milestones feed into a run, except Token rewards, which stay
## out of mods' reach. Multipliers combine by multiplying, *_add by adding.
const RUN_MODIFIER_EFFECT_RANGES := {
	"enemy_count_multiplier": [0.25, 2.0],
	"enemy_health_multiplier": [0.25, 4.0],
	"enemy_speed_multiplier": [0.25, 2.5],
	"enemy_bullet_speed_multiplier": [0.25, 2.5],
	"fragment_health_multiplier": [0.25, 4.0],
	"healing_multiplier": [0.0, 3.0],
	"healing_pickup_multiplier": [0.0, 3.0],
	"player_damage_multiplier": [0.25, 4.0],
	"max_health_multiplier": [0.25, 3.0],
	"fire_rate_multiplier": [0.25, 2.0],
	"special_cooldown_multiplier": [0.25, 3.0],
	"special_damage_multiplier": [0.25, 4.0],
	"damage_buff_duration_multiplier": [0.25, 4.0],
	"xp_gain_multiplier": [0.25, 4.0],
	"xp_reward_multiplier": [0.25, 4.0],
	"intermission_multiplier": [0.25, 4.0],
	"score_multiplier": [0.25, 4.0],
	"heal_on_kill_add": [0.0, 50.0],
	"projectile_count_add": [0, 8],
}
const RUN_MODIFIER_INTEGER_EFFECTS := ["projectile_count_add"]

static func validate_content(content: Variant) -> Dictionary:
	if typeof(content) != TYPE_DICTIONARY:
		return _invalid("content must be an object")

	for raw_key in content.keys():
		if typeof(raw_key) != TYPE_STRING or not CONTENT_SECTIONS.has(String(raw_key)):
			return _invalid("unsupported content section: %s" % String(raw_key))
		if _contains_forbidden_key(content[raw_key]):
			return _invalid("content contains a forbidden data key")

	var normalized: Dictionary = {}
	if content.has("rules"):
		var rules_result := _normalize_rules(content["rules"])
		if not bool(rules_result["valid"]):
			return rules_result
		normalized["rules"] = rules_result["value"]

	if content.has("max_wave"):
		if not _is_int_in_range(content["max_wave"], 1, MAX_WAVE_NUMBER):
			return _invalid("max_wave must be an integer from 1 to %d" % MAX_WAVE_NUMBER)
		normalized["max_wave"] = int(content["max_wave"])

	var wave_overrides_result := _normalize_wave_table(content.get("wave_overrides", {}), "wave_overrides")
	if not bool(wave_overrides_result["valid"]):
		return wave_overrides_result
	if not wave_overrides_result["value"].is_empty():
		normalized["wave_overrides"] = wave_overrides_result["value"]

	var campaign_table: Dictionary = {}
	for section_name in ["campaign_waves", "campaign"]:
		if not content.has(section_name):
			continue
		var campaign_result := _normalize_wave_table(_extract_waves(content[section_name]), section_name)
		if not bool(campaign_result["valid"]):
			return campaign_result
		_merge_last_wins(campaign_table, campaign_result["value"])
	if not campaign_table.is_empty():
		if var_to_bytes(campaign_table).size() > MAX_CAMPAIGN_CONTENT_BYTES:
			return _invalid("campaign content exceeds the %d-byte run recipe budget" % MAX_CAMPAIGN_CONTENT_BYTES)
		normalized["campaign_waves"] = campaign_table

	var scenarios: Dictionary = {}
	for section_name in ["scenario_waves", "scenarios", "scenario"]:
		if not content.has(section_name):
			continue
		var scenarios_result := _normalize_scenarios(content[section_name], section_name)
		if not bool(scenarios_result["valid"]):
			return scenarios_result
		_merge_nested_last_wins(scenarios, scenarios_result["value"])
	if not scenarios.is_empty():
		normalized["scenario_waves"] = scenarios

	var bosses_result := _normalize_boss_sections(content)
	if not bool(bosses_result["valid"]):
		return bosses_result
	for key in bosses_result["value"]:
		normalized[key] = bosses_result["value"][key]
	var boss_reference_result := _validate_boss_references(normalized)
	if not bool(boss_reference_result["valid"]):
		return boss_reference_result

	var enemy_definitions_result := _normalize_enemy_definitions(content.get("enemy_definitions", {}))
	if not bool(enemy_definitions_result["valid"]):
		return enemy_definitions_result
	if not enemy_definitions_result["value"].is_empty():
		normalized["enemy_definitions"] = enemy_definitions_result["value"]

	var cell_definitions_result := _normalize_cell_definitions(content.get("cell_definitions", {}))
	if not bool(cell_definitions_result["valid"]):
		return cell_definitions_result
	if not cell_definitions_result["value"].is_empty():
		normalized["cell_definitions"] = cell_definitions_result["value"]

	var projectile_patterns_result := _normalize_projectile_patterns(content.get("projectile_patterns", {}))
	if not bool(projectile_patterns_result["valid"]):
		return projectile_patterns_result
	if not projectile_patterns_result["value"].is_empty():
		normalized["projectile_patterns"] = projectile_patterns_result["value"]

	var upgrades_result := _normalize_upgrades(content.get("upgrades", {}))
	if not bool(upgrades_result["valid"]):
		return upgrades_result
	if not upgrades_result["value"].is_empty():
		normalized["upgrades"] = upgrades_result["value"]
	if content.has("run_modifiers"):
		var modifiers_result := _normalize_run_modifiers(content["run_modifiers"])
		if not bool(modifiers_result["valid"]):
			return modifiers_result
		if not modifiers_result["value"].is_empty():
			normalized["run_modifiers"] = modifiers_result["value"]
	if content.has("synergies"):
		var synergies_result := _normalize_synergies(content["synergies"], upgrades_result["value"])
		if not bool(synergies_result["valid"]):
			return synergies_result
		if not synergies_result["value"].is_empty():
			normalized["synergies"] = synergies_result["value"]

	var sfx_result := _normalize_sfx_sections(content)
	if not bool(sfx_result["valid"]):
		return sfx_result
	for key in sfx_result["value"]:
		normalized[key] = sfx_result["value"][key]

	if content.has("enemy_overrides"):
		var enemy_overrides_result := _normalize_enemy_override_table(content["enemy_overrides"])
		if not bool(enemy_overrides_result["valid"]):
			return enemy_overrides_result
		normalized["enemy_overrides"] = enemy_overrides_result["value"]
	if content.has("cell_overrides"):
		var cell_overrides_result := _normalize_cell_override_table(content["cell_overrides"])
		if not bool(cell_overrides_result["valid"]):
			return cell_overrides_result
		normalized["cell_overrides"] = cell_overrides_result["value"]
	if content.has("cosmetics"):
		var cosmetics_result := _normalize_cosmetics(content["cosmetics"])
		if not bool(cosmetics_result["valid"]):
			return cosmetics_result
		normalized["cosmetics"] = cosmetics_result["value"]

	if not _has_effective_content(normalized):
		return _invalid("content must define at least one non-empty value")
	return {"valid": true, "value": normalized, "errors": []}

## Validates manifest-level settings that replace a bounded scalar in normalized content.
## Applying the values is followed by normal content validation, so settings cannot widen
## the data-only content contract.
static func validate_mod_settings(value: Variant, normalized_content: Dictionary) -> Dictionary:
	if typeof(value) != TYPE_ARRAY or value.size() > MAX_MOD_SETTINGS:
		return _invalid("settings must contain at most %d entries" % MAX_MOD_SETTINGS)
	var settings: Array = []
	var setting_ids: Dictionary = {}
	for raw_setting in value:
		if typeof(raw_setting) != TYPE_DICTIONARY:
			return _invalid("each setting must be an object")
		var setting: Dictionary = raw_setting
		var allowed_keys := ["id", "label", "description", "type", "default", "target", "min", "max", "step", "options"]
		for raw_key in setting:
			if not allowed_keys.has(String(raw_key)):
				return _invalid("unsupported setting key: %s" % String(raw_key))
		var setting_id := String(setting.get("id", ""))
		if not is_safe_id(setting_id) or setting_ids.has(setting_id):
			return _invalid("setting IDs must be unique safe identifiers")
		var label := String(setting.get("label", "")).strip_edges()
		if label.is_empty() or label.length() > 96:
			return _invalid("setting %s needs a label of 1-96 characters" % setting_id)
		var description := String(setting.get("description", ""))
		if description.length() > 256:
			return _invalid("setting %s description is too long" % setting_id)
		var setting_type := String(setting.get("type", ""))
		if not ["boolean", "integer", "number", "choice"].has(setting_type) or not setting.has("default"):
			return _invalid("setting %s has an invalid type or no default" % setting_id)
		var target: Array = _normalize_mod_setting_target(setting.get("target", null))
		if target.is_empty():
			return _invalid("setting %s has an invalid target" % setting_id)
		var target_value: Variant = _get_mod_setting_target(normalized_content, target)
		if typeof(target_value) == TYPE_NIL:
			return _invalid("setting %s targets a missing content value" % setting_id)
		var normalized := {
			"id": setting_id,
			"label": label,
			"description": description,
			"type": setting_type,
			"default": setting["default"],
			"target": target,
		}
		match setting_type:
			"boolean":
				if typeof(setting["default"]) != TYPE_BOOL or typeof(target_value) != TYPE_BOOL:
					return _invalid("setting %s must target a boolean" % setting_id)
			"integer", "number":
				if not setting.has("min") or not setting.has("max") or not setting.has("step"):
					return _invalid("numeric setting %s needs min, max, and step" % setting_id)
				var is_integer := setting_type == "integer"
				var bounds_valid := _is_int_in_range(setting["min"], -int(MAX_RULE_VALUE), int(MAX_RULE_VALUE)) and _is_int_in_range(setting["max"], -int(MAX_RULE_VALUE), int(MAX_RULE_VALUE)) and _is_int_in_range(setting["step"], 1, int(MAX_RULE_VALUE)) if is_integer else _is_number_in_range(setting["min"], -MAX_RULE_VALUE, MAX_RULE_VALUE) and _is_number_in_range(setting["max"], -MAX_RULE_VALUE, MAX_RULE_VALUE) and _is_number_in_range(setting["step"], 0.000001, MAX_RULE_VALUE)
				if not bounds_valid or float(setting["min"]) >= float(setting["max"]):
					return _invalid("numeric setting %s has invalid bounds" % setting_id)
				normalized["min"] = int(setting["min"]) if is_integer else float(setting["min"])
				normalized["max"] = int(setting["max"]) if is_integer else float(setting["max"])
				normalized["step"] = int(setting["step"]) if is_integer else float(setting["step"])
				var value_result := validate_mod_setting_value(normalized, setting["default"])
				if not bool(value_result.get("valid", false)) or (typeof(target_value) != TYPE_INT and typeof(target_value) != TYPE_FLOAT):
					return _invalid("numeric setting %s has an invalid default or target" % setting_id)
				normalized["default"] = value_result["value"]
			"choice":
				var options: Variant = setting.get("options", null)
				if typeof(options) != TYPE_ARRAY or options.is_empty() or options.size() > MAX_MOD_SETTING_OPTIONS:
					return _invalid("choice setting %s needs 1-%d options" % [setting_id, MAX_MOD_SETTING_OPTIONS])
				var default_result := _normalize_choice_setting_value(setting["default"], target_value)
				if not bool(default_result.get("valid", false)):
					return _invalid("choice setting %s has an invalid default or target" % setting_id)
				var normalized_options: Array = []
				for raw_option in options:
					var option_result := _normalize_choice_setting_value(raw_option, target_value)
					if not bool(option_result.get("valid", false)) or option_result["value"] in normalized_options:
						return _invalid("choice setting %s has invalid options" % setting_id)
					normalized_options.append(option_result["value"])
				if default_result["value"] not in normalized_options:
					return _invalid("choice setting %s has an invalid default or target" % setting_id)
				normalized["default"] = default_result["value"]
				normalized["options"] = normalized_options
		settings.append(normalized)
		setting_ids[setting_id] = true
	return {"valid": true, "value": settings, "errors": []}

static func resolve_mod_settings(definitions: Array, saved_values: Variant = {}) -> Dictionary:
	var result: Dictionary = {}
	var saved: Dictionary = saved_values if typeof(saved_values) == TYPE_DICTIONARY else {}
	for raw_definition in definitions:
		if typeof(raw_definition) != TYPE_DICTIONARY:
			continue
		var definition: Dictionary = raw_definition
		var setting_id := String(definition.get("id", ""))
		var candidate: Variant = saved.get(setting_id, definition.get("default", null))
		var value_result := validate_mod_setting_value(definition, candidate)
		result[setting_id] = value_result.get("value", definition.get("default", null)) if bool(value_result.get("valid", false)) else definition.get("default", null)
	return result

static func validate_mod_setting_value(definition: Dictionary, value: Variant) -> Dictionary:
	var setting_type := String(definition.get("type", ""))
	match setting_type:
		"boolean":
			if typeof(value) == TYPE_BOOL:
				return {"valid": true, "value": value, "errors": []}
		"integer":
			if _is_int_in_range(value, int(definition.get("min", 1)), int(definition.get("max", 0))):
				var integer_value := int(value)
				if posmod(integer_value - int(definition["min"]), int(definition.get("step", 1))) == 0:
					return {"valid": true, "value": integer_value, "errors": []}
		"number":
			if _is_number_in_range(value, float(definition.get("min", 1.0)), float(definition.get("max", 0.0))):
				var number_value := float(value)
				var step := float(definition.get("step", 0.0))
				if step > 0.0 and is_equal_approx((number_value - float(definition["min"])) / step, round((number_value - float(definition["min"])) / step)):
					return {"valid": true, "value": number_value, "errors": []}
		"choice":
			var options: Variant = definition.get("options", [])
			if typeof(options) == TYPE_ARRAY:
				for option in options:
					if typeof(option) == typeof(value) and option == value:
						return {"valid": true, "value": value, "errors": []}
	return _invalid("setting value is invalid")

static func apply_mod_settings(content: Dictionary, definitions: Array, values: Dictionary) -> Dictionary:
	var configured := content.duplicate(true)
	for raw_definition in definitions:
		if typeof(raw_definition) != TYPE_DICTIONARY:
			return _invalid("setting definition is malformed")
		var definition: Dictionary = raw_definition
		var setting_id := String(definition.get("id", ""))
		var value_result := validate_mod_setting_value(definition, values.get(setting_id, definition.get("default", null)))
		if not bool(value_result.get("valid", false)) or not _set_mod_setting_target(configured, definition.get("target", []), value_result["value"]):
			return _invalid("setting %s could not be applied" % setting_id)
	return {"valid": true, "value": configured, "errors": []}

static func _is_setting_scalar(value: Variant) -> bool:
	return typeof(value) in [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING]

static func _normalize_choice_setting_value(value: Variant, target_value: Variant) -> Dictionary:
	if typeof(target_value) == TYPE_INT and _is_int_in_range(value, -int(MAX_RULE_VALUE), int(MAX_RULE_VALUE)):
		return {"valid": true, "value": int(value), "errors": []}
	if typeof(target_value) == TYPE_FLOAT and _is_number_in_range(value, -MAX_RULE_VALUE, MAX_RULE_VALUE):
		return {"valid": true, "value": float(value), "errors": []}
	if _is_setting_scalar(value) and typeof(value) == typeof(target_value):
		return {"valid": true, "value": value, "errors": []}
	return _invalid("choice setting value is invalid")

static func _normalize_mod_setting_target(value: Variant) -> Array:
	if typeof(value) != TYPE_ARRAY or value.is_empty() or value.size() > 8:
		return []
	var target: Array = []
	for raw_segment in value:
		if typeof(raw_segment) == TYPE_STRING and is_safe_id(raw_segment):
			target.append(raw_segment)
		elif _is_int_in_range(raw_segment, 0, 1024):
			target.append(int(raw_segment))
		else:
			return []
	return target

static func _get_mod_setting_target(content: Dictionary, target: Variant) -> Variant:
	if typeof(target) != TYPE_ARRAY or target.is_empty() or target.size() > 8:
		return null
	var current: Variant = content
	for raw_segment in target:
		if typeof(current) == TYPE_DICTIONARY:
			if typeof(raw_segment) != TYPE_STRING or not current.has(raw_segment):
				return null
			current = current[raw_segment]
		elif typeof(current) == TYPE_ARRAY:
			if typeof(raw_segment) != TYPE_INT or int(raw_segment) < 0 or int(raw_segment) >= current.size():
				return null
			current = current[int(raw_segment)]
		else:
			return null
	return current

static func _set_mod_setting_target(content: Dictionary, target: Variant, value: Variant) -> bool:
	if typeof(target) != TYPE_ARRAY or target.is_empty() or target.size() > 8:
		return false
	var current: Variant = content
	for index in target.size():
		var segment: Variant = target[index]
		var is_last: bool = index == target.size() - 1
		if typeof(current) == TYPE_DICTIONARY:
			if typeof(segment) != TYPE_STRING or not current.has(segment):
				return false
			if is_last:
				current[segment] = value
				return true
			current = current[segment]
		elif typeof(current) == TYPE_ARRAY:
			if typeof(segment) != TYPE_INT or int(segment) < 0 or int(segment) >= current.size():
				return false
			if is_last:
				current[int(segment)] = value
				return true
			current = current[int(segment)]
		else:
			return false
	return false

static func namespace_upgrade_id(namespace_id: String, upgrade_id: String) -> String:
	return "%s:%s" % [namespace_id, upgrade_id]

static func canonical_json(value: Variant) -> String:
	return JSON.stringify(_canonicalize(value))

static func content_hash(value: Variant) -> String:
	return canonical_json(value).sha256_text()

static func is_safe_id(value: Variant, max_length: int = 64) -> bool:
	if typeof(value) != TYPE_STRING:
		return false
	var text := String(value)
	if text.is_empty() or text.length() > max_length:
		return false
	for character in text:
		var code := character.unicode_at(0)
		var is_ascii_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		var is_digit := code >= 48 and code <= 57
		if not (is_ascii_letter or is_digit or character == "_" or character == "-" or character == ":" or character == "."):
			return false
	return true

static func is_safe_relative_path(value: Variant) -> bool:
	return _is_safe_asset_relative_path(value, SFX_FILE_EXTENSIONS)

static func is_safe_texture_path(value: Variant) -> bool:
	return _is_safe_asset_relative_path(value, IMAGE_FILE_EXTENSIONS)

static func _is_safe_asset_relative_path(value: Variant, extensions: Array) -> bool:
	if typeof(value) != TYPE_STRING:
		return false
	var path := String(value).replace("\\", "/")
	if path.is_empty() or path.length() > MAX_SFX_FILE_LENGTH or path.begins_with("/") or path.contains(":"):
		return false
	var components := path.split("/", true)
	if components.is_empty() or components.size() > MAX_ASSET_PATH_DEPTH:
		return false
	for component in components:
		if component.is_empty() or component == "." or component == ".." or component.length() > 255:
			return false
		for character in component:
			var code := character.unicode_at(0)
			if code < 32 or code == 127:
				return false
	return extensions.has(path.get_extension().to_lower())

static func _normalize_rules(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY or not _validate_json_data(value):
		return _invalid("rules must be a data object")
	var normalized: Dictionary = value.duplicate(true)
	for raw_key in value.keys():
		var key := String(raw_key)
		if not is_safe_id(key):
			return _invalid("invalid rules key: %s" % key)
		if key == "max_wave" and not _is_int_in_range(value[raw_key], 1, MAX_WAVE_NUMBER):
			return _invalid("rules.max_wave must be an integer from 1 to %d" % MAX_WAVE_NUMBER)
		if key == "max_wave":
			normalized[key] = int(value[raw_key])
		if key in ["enemy_health_per_extra_player", "spawn_volume_per_extra_player"] and not _is_number_in_range(value[raw_key], 0.0, 10.0):
			return _invalid("rules.%s must be between 0 and 10" % key)
		if key == "boss_base_health_multiplier" and not _is_number_in_range(value[raw_key], 2.5, 10.0):
			return _invalid("rules.boss_base_health_multiplier must be between 2.5 and 10")
	return {"valid": true, "value": normalized, "errors": []}

static func _validate_boss_references(content: Dictionary) -> Dictionary:
	var definitions: Dictionary = content.get("boss_definitions", {})
	for section_name in ["wave_overrides", "campaign_waves"]:
		var table: Variant = content.get(section_name, {})
		var result := _validate_boss_reference_table(table, definitions, section_name)
		if not bool(result["valid"]):
			return result
	var scenarios: Variant = content.get("scenario_waves", {})
	if scenarios is Dictionary:
		for scenario_id in scenarios:
			var scenario_table: Variant = scenarios[scenario_id]
			var result := _validate_boss_reference_table(scenario_table, definitions, "scenario_waves.%s" % String(scenario_id))
			if not bool(result["valid"]):
				return result
	return {"valid": true, "value": {}, "errors": []}

static func _validate_boss_reference_table(table: Variant, definitions: Dictionary, path: String) -> Dictionary:
	if typeof(table) != TYPE_DICTIONARY:
		return {"valid": true, "value": {}, "errors": []}
	for raw_wave in table:
		var wave: Variant = table[raw_wave]
		if typeof(wave) != TYPE_DICTIONARY or not wave.has("boss_id"):
			continue
		var boss_id := String(wave["boss_id"])
		if not BUILTIN_BOSSES.has(boss_id) and not definitions.has(boss_id):
			return _invalid("%s.%s references an unknown boss: %s" % [path, String(raw_wave), boss_id])
	return {"valid": true, "value": {}, "errors": []}

static func _normalize_enemy_override_table(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("enemy_overrides must be a data object")
	var result: Dictionary = {}
	for raw_id in value:
		var enemy_id := String(raw_id)
		if not is_safe_id(enemy_id):
			return _invalid("invalid enemy override id: %s" % enemy_id)
		var override_result := _normalize_enemy_overrides(value[raw_id], enemy_id)
		if not bool(override_result["valid"]):
			return override_result
		result[enemy_id] = override_result["value"]
	return {"valid": true, "value": result, "errors": []}

static func _normalize_cell_override_table(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("cell_overrides must be a data object")
	var result: Dictionary = {}
	for raw_id in value:
		var cell_id := String(raw_id)
		if not is_safe_id(cell_id):
			return _invalid("invalid cell override id: %s" % cell_id)
		var override_result := _normalize_cell_overrides(value[raw_id], cell_id)
		if not bool(override_result["valid"]):
			return override_result
		result[cell_id] = override_result["value"]
	return {"valid": true, "value": result, "errors": []}

static func _normalize_cosmetics(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("cosmetics must be a data object")
	var result: Dictionary = {}
	for raw_category in value:
		var category := String(raw_category)
		if category not in ["enemies", "cells"] or typeof(value[raw_category]) != TYPE_DICTIONARY:
			return _invalid("cosmetics supports enemies and cells only")
		var category_result: Dictionary = {}
		for raw_id in value[raw_category]:
			var item_id := String(raw_id)
			if not is_safe_id(item_id) or typeof(value[raw_category][raw_id]) != TYPE_DICTIONARY:
				return _invalid("invalid cosmetic id: %s" % item_id)
			var item: Dictionary = value[raw_category][raw_id]
			var normalized_item: Dictionary = {}
			for raw_key in item:
				var key := String(raw_key)
				var allowed_keys := ["texture", "color"] if category == "cells" else ["texture", "visual_color", "bullet_color"]
				if not allowed_keys.has(key):
					return _invalid("unsupported cosmetic key: %s" % key)
				if key == "texture":
					if not is_safe_texture_path(item[raw_key]):
						return _invalid("invalid cosmetic texture path: %s" % item_id)
				elif not _valid_color(item[raw_key]):
					return _invalid("invalid cosmetic color: %s" % item_id)
				normalized_item[key] = item[raw_key]
			category_result[item_id] = normalized_item
		result[category] = category_result
	return {"valid": true, "value": result, "errors": []}

static func _normalize_wave_table(value: Variant, section_name: String) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY and _looks_like_wave(value):
		value = {"1": value}
	if typeof(value) == TYPE_ARRAY:
		var by_number: Dictionary = {}
		for index in value.size():
			var wave_result := _normalize_wave(value[index], "%s[%d]" % [section_name, index])
			if not bool(wave_result["valid"]):
				return wave_result
			by_number[str(index + 1)] = wave_result["value"]
		return {"valid": true, "value": by_number, "errors": []}
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("%s must be an array or wave object" % section_name)

	var result: Dictionary = {}
	for raw_number in value.keys():
		var number_text := String(raw_number)
		if not number_text.is_valid_int() or not _is_int_in_range(int(number_text), 1, MAX_WAVE_NUMBER):
			return _invalid("%s has an invalid wave number" % section_name)
		var wave_result := _normalize_wave(value[raw_number], "%s.%s" % [section_name, number_text])
		if not bool(wave_result["valid"]):
			return wave_result
		result[number_text] = wave_result["value"]
	return {"valid": true, "value": result, "errors": []}

static func _normalize_scenarios(value: Variant, section_name: String) -> Dictionary:
	if typeof(value) == TYPE_ARRAY:
		var default_result := _normalize_wave_table(value, "%s.default" % section_name)
		if not bool(default_result["valid"]):
			return default_result
		return {"valid": true, "value": {"default": default_result["value"]}, "errors": []}
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("%s must be an object or array" % section_name)

	if value.has("waves"):
		var scenario_id := String(value.get("id", "default"))
		if not is_safe_id(scenario_id):
			return _invalid("%s has an invalid scenario id" % section_name)
		var single_result := _normalize_wave_table(value["waves"], "%s.%s" % [section_name, scenario_id])
		if not bool(single_result["valid"]):
			return single_result
		return {"valid": true, "value": {scenario_id: single_result["value"]}, "errors": []}

	var result: Dictionary = {}
	for raw_id in value.keys():
		var scenario_id := String(raw_id)
		if not is_safe_id(scenario_id):
			return _invalid("%s has an invalid scenario id" % scenario_id)
		var scenario_value: Variant = value[raw_id]
		# Validation runs twice (raw manifest, then the settings-applied copy), so
		# the already-normalised {"1": {...}} table must round-trip. Treating any
		# dictionary without a "waves" key as the table itself keeps it idempotent;
		# reading "waves" with a {} default silently emptied every scenario.
		var waves_value: Variant = scenario_value["waves"] if typeof(scenario_value) == TYPE_DICTIONARY and scenario_value.has("waves") else scenario_value
		var scenario_result := _normalize_wave_table(waves_value, "%s.%s" % [section_name, scenario_id])
		if not bool(scenario_result["valid"]):
			return scenario_result
		result[scenario_id] = scenario_result["value"]
	return {"valid": true, "value": result, "errors": []}

static func _normalize_wave(value: Variant, path: String) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY or not _validate_json_data(value):
		return _invalid("%s must be a data object" % path)
	var allowed := ["interval", "spawn_interval", "pools", "duration", "boss", "boss_id", "miniboss", "overrides", "boss_overrides", "name"]
	for raw_key in value.keys():
		if not allowed.has(String(raw_key)):
			return _invalid("unsupported wave key: %s" % String(raw_key))

	var result: Dictionary = {}
	var interval_value: Variant = value.get("interval", value.get("spawn_interval", null))
	if interval_value != null:
		if not _is_number_in_range(interval_value, 0.04, 5.0):
			return _invalid("%s interval must be between 0.04 and 5.0" % path)
		result["interval"] = float(interval_value)

	if value.has("duration"):
		if not _is_number_in_range(value["duration"], 0.1, 300.0):
			return _invalid("%s duration is out of range" % path)
		result["duration"] = float(value["duration"])

	if value.has("pools"):
		if typeof(value["pools"]) != TYPE_ARRAY or value["pools"].size() > MAX_WAVE_POOLS:
			return _invalid("%s pools must contain at most %d entries" % [path, MAX_WAVE_POOLS])
		var pools: Array = []
		for raw_pool in value["pools"]:
			if typeof(raw_pool) != TYPE_DICTIONARY:
				return _invalid("%s contains an invalid pool" % path)
			for pool_key in raw_pool.keys():
				if not ["enemy", "count", "weight"].has(String(pool_key)):
					return _invalid("unsupported pool key: %s" % String(pool_key))
			var enemy_id := String(raw_pool.get("enemy", ""))
			if not is_safe_id(enemy_id) or not _is_int_in_range(raw_pool.get("count", 0), 1, MAX_WAVE_SPAWNS):
				return _invalid("%s contains an invalid pool" % path)
			var pool := {"enemy": enemy_id, "count": int(raw_pool["count"])}
			if raw_pool.has("weight"):
				if not _is_number_in_range(raw_pool["weight"], 0.0, 100000.0):
					return _invalid("%s pool weight is out of range" % path)
				pool["weight"] = float(raw_pool["weight"])
			pools.append(pool)
		result["pools"] = pools

	var boss_id := ""
	if value.has("boss"):
		var boss_value: Variant = value["boss"]
		if typeof(boss_value) == TYPE_STRING:
			boss_id = String(boss_value)
		elif typeof(boss_value) != TYPE_BOOL:
			return _invalid("%s boss must be a boolean or id" % path)
		result["boss"] = true if typeof(boss_value) == TYPE_STRING else bool(boss_value)
	if value.has("boss_id"):
		boss_id = String(value["boss_id"])
		result["boss"] = true
	if not boss_id.is_empty():
		if not is_safe_id(boss_id):
			return _invalid("%s has an invalid boss id" % path)
		result["boss_id"] = boss_id
	if value.has("miniboss"):
		if typeof(value["miniboss"]) != TYPE_BOOL:
			return _invalid("%s miniboss must be boolean" % path)
		result["miniboss"] = value["miniboss"]

	for override_key in ["overrides", "boss_overrides"]:
		if not value.has(override_key):
			continue
		if not _validate_boss_overrides(value[override_key], path):
			return _invalid("%s.%s must be a data object" % [path, override_key])
		result["overrides"] = value[override_key].duplicate(true)

	if value.has("name"):
		if typeof(value["name"]) != TYPE_STRING or String(value["name"]).length() > 128:
			return _invalid("%s name is invalid" % path)
		result["name"] = String(value["name"])

	if result.get("boss", false) == false and not result.has("pools"):
		return _invalid("%s needs pools or a boss" % path)
	return {"valid": true, "value": result, "errors": []}

static func _normalize_boss_sections(content: Dictionary) -> Dictionary:
	var definitions: Dictionary = {}
	for section_name in ["bosses", "boss_definitions"]:
		if not content.has(section_name):
			continue
		var section_result := _normalize_boss_definitions(content[section_name], section_name)
		if not bool(section_result["valid"]):
			return section_result
		_merge_last_wins(definitions, section_result["value"])

	var overrides: Dictionary = {}
	if content.has("boss_overrides"):
		if typeof(content["boss_overrides"]) != TYPE_DICTIONARY:
			return _invalid("boss_overrides must be an object")
		for raw_id in content["boss_overrides"].keys():
			var boss_id := String(raw_id)
			if not is_safe_id(boss_id):
				return _invalid("invalid boss override id: %s" % boss_id)
			var raw_override: Variant = content["boss_overrides"][raw_id]
			if typeof(raw_override) == TYPE_DICTIONARY and raw_override.has("overrides"):
				raw_override = raw_override["overrides"]
			if not _validate_boss_overrides(raw_override, boss_id):
				return _invalid("invalid boss override: %s" % boss_id)
			overrides[boss_id] = raw_override.duplicate(true)

	var result: Dictionary = {}
	if not definitions.is_empty():
		result["boss_definitions"] = definitions
	if not overrides.is_empty():
		result["boss_overrides"] = overrides
	return {"valid": true, "value": result, "errors": []}

static func _normalize_boss_definitions(value: Variant, section_name: String) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("%s must be an object" % section_name)
	var result: Dictionary = {}
	for raw_id in value.keys():
		var boss_id := String(raw_id)
		if not is_safe_id(boss_id):
			return _invalid("invalid boss id: %s" % boss_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid boss definition: %s" % boss_id)
		var normalized: Dictionary = {}
		for raw_key in definition.keys():
			var key := String(raw_key)
			if not ["base", "base_id", "enemy", "boss_id", "name", "description", "overrides", "phases", "icon_color"].has(key):
				return _invalid("unsupported boss definition key: %s" % key)
			if key in ["base", "base_id", "enemy", "boss_id"]:
				if not is_safe_id(definition[raw_key]):
					return _invalid("invalid boss base id: %s" % boss_id)
				if not BUILTIN_BOSSES.has(String(definition[raw_key])):
					return _invalid("boss %s needs a built-in boss base" % boss_id)
				normalized[key] = String(definition[raw_key])
			elif key in ["name", "description"]:
				if typeof(definition[raw_key]) != TYPE_STRING or String(definition[raw_key]).length() > 256:
					return _invalid("invalid boss text: %s" % boss_id)
				normalized[key] = String(definition[raw_key])
			elif key == "icon_color":
				if not _valid_color(definition[raw_key]):
					return _invalid("invalid boss color: %s" % boss_id)
				normalized[key] = definition[raw_key]
			elif key == "phases":
				if typeof(definition[raw_key]) != TYPE_ARRAY or definition[raw_key].size() > 32 or not _validate_json_data(definition[raw_key]):
					return _invalid("invalid boss phases: %s" % boss_id)
				normalized[key] = definition[raw_key].duplicate(true)
			else:
				if not _validate_boss_overrides(definition[raw_key], boss_id):
					return _invalid("invalid boss overrides: %s" % boss_id)
				normalized["overrides"] = definition[raw_key].duplicate(true)
		result[boss_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _normalize_enemy_definitions(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("enemy_definitions must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var enemy_id := String(raw_id)
		if not is_safe_id(enemy_id) or enemy_id in BUILTIN_ENEMIES:
			return _invalid("invalid custom enemy id: %s" % enemy_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid enemy definition: %s" % enemy_id)
		var base_id := String(definition.get("base", ""))
		if not BUILTIN_ENEMIES.has(base_id):
			return _invalid("enemy %s needs a built-in base" % enemy_id)
		for key in definition.keys():
			if not ["base", "name", "description", "icon_color", "overrides"].has(String(key)):
				return _invalid("unsupported enemy definition key: %s" % String(key))
		var normalized := {"base": base_id}
		if definition.has("name"):
			if typeof(definition["name"]) != TYPE_STRING or String(definition["name"]).strip_edges().is_empty() or String(definition["name"]).length() > 128:
				return _invalid("enemy %s has an invalid name" % enemy_id)
			normalized["name"] = String(definition["name"]).strip_edges()
		if definition.has("description"):
			if typeof(definition["description"]) != TYPE_STRING or String(definition["description"]).length() > 512:
				return _invalid("enemy %s has an invalid description" % enemy_id)
			normalized["description"] = String(definition["description"])
		if definition.has("icon_color"):
			if not _valid_color(definition["icon_color"]):
				return _invalid("enemy %s has an invalid icon color" % enemy_id)
			normalized["icon_color"] = definition["icon_color"]
		var override_result := _normalize_enemy_overrides(definition.get("overrides", {}), enemy_id)
		if not bool(override_result["valid"]):
			return override_result
		if not override_result["value"].is_empty():
			normalized["overrides"] = override_result["value"]
		result[enemy_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _normalize_enemy_overrides(value: Variant, enemy_id: String = "enemy") -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY or not _validate_json_data(value):
		return _invalid("%s overrides must be a data object" % enemy_id)
	var allowed := [
		"max_health", "move_speed", "contact_damage", "score_value", "shoot_interval", "bullet_speed", "bullet_damage",
		"bullet_color", "visual_color", "visual_radius", "radial_bullet_count", "aimed_spread_count", "minion_interval",
		"minion_spawn_count", "boss_pattern", "boss_base_health_multiplier", "attack_pattern", "enemy_shape",
		"projectile_pattern", "radial_rotation_speed", "spiral_spin_speed", "aimed_spread_angle",
	]
	var normalized: Dictionary = {}
	for key in value.keys():
		var key_name := String(key)
		if not allowed.has(key_name):
			return _invalid("unsupported enemy override key: %s" % key_name)
		if key_name in ["bullet_color", "visual_color"] and not _valid_color(value[key]):
			return _invalid("invalid enemy color: %s" % key_name)
		if key_name == "attack_pattern" and (typeof(value[key]) != TYPE_STRING or not ATTACK_PATTERNS.has(String(value[key]))):
			return _invalid("invalid enemy attack pattern")
		if key_name == "enemy_shape" and (typeof(value[key]) != TYPE_STRING or not ENEMY_SHAPES.has(String(value[key]))):
			return _invalid("invalid enemy shape")
		if key_name == "boss_pattern" and (typeof(value[key]) != TYPE_STRING or not BOSS_PATTERNS.has(String(value[key]))):
			return _invalid("invalid enemy boss pattern")
		if key_name == "projectile_pattern" and not is_safe_id(value[key]):
			return _invalid("invalid enemy projectile pattern")
		normalized[key_name] = value[key]
	if value.has("shoot_interval") and not _is_valid_shoot_interval(value["shoot_interval"]):
		return _invalid("invalid enemy shoot interval")
	var numeric_error := _validate_field_ranges(value, {
		"max_health": [1.0, MAX_RULE_VALUE], "move_speed": [0.0, 2000.0],
		"contact_damage": [0.0, MAX_RULE_VALUE], "score_value": [0.0, 1000000.0],
		"bullet_speed": [0.0, 2000.0],
		"bullet_damage": [0.0, 16000.0], "visual_radius": [4.0, 160.0],
		"radial_bullet_count": [3.0, 32.0], "aimed_spread_count": [1.0, 32.0],
		"minion_interval": [0.2, 30.0], "minion_spawn_count": [1.0, 8.0],
		"boss_base_health_multiplier": [2.5, 10.0], "radial_rotation_speed": [-20.0, 20.0],
		"spiral_spin_speed": [-20.0, 20.0], "aimed_spread_angle": [1.0, 90.0],
	}, ["score_value", "radial_bullet_count", "aimed_spread_count", "minion_spawn_count"], enemy_id)
	if not numeric_error.is_empty():
		return _invalid(numeric_error)
	return {"valid": true, "value": normalized, "errors": []}

static func _normalize_cell_definitions(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("cell_definitions must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var cell_id := String(raw_id)
		if not is_safe_id(cell_id) or cell_id in BUILTIN_CELLS:
			return _invalid("invalid custom cell id: %s" % cell_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid cell definition: %s" % cell_id)
		var base_id := String(definition.get("base", ""))
		if not BUILTIN_CELLS.has(base_id):
			return _invalid("cell %s needs a built-in base" % cell_id)
		for key in definition.keys():
			if not ["base", "name", "description", "archetype", "icon_color", "overrides"].has(String(key)):
				return _invalid("unsupported cell definition key: %s" % String(key))
		var normalized := {"base": base_id}
		for text_key in ["name", "description", "archetype"]:
			if definition.has(text_key):
				if typeof(definition[text_key]) != TYPE_STRING or String(definition[text_key]).length() > 256:
					return _invalid("cell %s has invalid %s" % [cell_id, text_key])
				normalized[text_key] = String(definition[text_key])
		if definition.has("icon_color"):
			if not _valid_color(definition["icon_color"]):
				return _invalid("cell %s has an invalid icon color" % cell_id)
			normalized["icon_color"] = definition["icon_color"]
		var override_result := _normalize_cell_overrides(definition.get("overrides", {}), cell_id)
		if not bool(override_result["valid"]):
			return override_result
		if not override_result["value"].is_empty():
			normalized["overrides"] = override_result["value"]
		result[cell_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _normalize_cell_overrides(value: Variant, cell_id: String = "cell") -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY or not _validate_json_data(value):
		return _invalid("%s overrides must be a data object" % cell_id)
	var allowed := [
		"max_health", "hitbox_radius", "move_speed", "bullet_speed", "bullet_damage", "bullet_shape", "fire_rate",
		"fire_pattern", "special_cooldown_time", "special_type", "special_bullet_count", "special_radius",
		"special_damage", "special_duration", "special_multiplier", "special_description", "color",
	]
	var normalized: Dictionary = {}
	for key in value.keys():
		var key_name := String(key)
		if not allowed.has(key_name):
			return _invalid("unsupported cell override key: %s" % key_name)
		if key_name == "bullet_shape" and (typeof(value[key]) != TYPE_STRING or not ["circle", "dagger", "orb", "antibody", "dart", "shard", "blob"].has(String(value[key]))):
			return _invalid("invalid cell bullet shape")
		if key_name == "fire_pattern" and (typeof(value[key]) != TYPE_STRING or not CELL_FIRE_PATTERNS.has(String(value[key]))):
			return _invalid("invalid cell fire pattern")
		if key_name == "special_type" and (typeof(value[key]) != TYPE_STRING or not CELL_SPECIAL_TYPES.has(String(value[key]))):
			return _invalid("invalid cell special type")
		if key_name == "special_description" and (typeof(value[key]) != TYPE_STRING or String(value[key]).length() > 512):
			return _invalid("invalid cell special description")
		if key_name == "color" and not _valid_color(value[key]):
			return _invalid("invalid cell color")
		normalized[key_name] = value[key]
	var numeric_error := _validate_field_ranges(value, {
		"max_health": [1.0, MAX_RULE_VALUE], "hitbox_radius": [0.1, 100.0],
		"move_speed": [0.0, 1000.0], "bullet_speed": [0.0, 10000.0],
		"bullet_damage": [0.0, MAX_RULE_VALUE], "fire_rate": [0.01, 60.0],
		"special_cooldown_time": [0.01, 300.0], "special_bullet_count": [1.0, 64.0],
		"special_radius": [0.0, 2000.0], "special_damage": [0.0, MAX_RULE_VALUE],
		"special_duration": [0.0, 300.0], "special_multiplier": [0.0, 100.0],
	}, ["special_bullet_count"], cell_id)
	if not numeric_error.is_empty():
		return _invalid(numeric_error)
	return {"valid": true, "value": normalized, "errors": []}

static func _normalize_projectile_patterns(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("projectile_patterns must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var pattern_id := String(raw_id)
		if not is_safe_id(pattern_id):
			return _invalid("invalid projectile pattern id: %s" % pattern_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid projectile pattern: %s" % pattern_id)
		var pattern_type := String(definition.get("type", ""))
		if not PROJECTILE_PATTERN_TYPES.has(pattern_type):
			return _invalid("invalid projectile pattern type: %s" % pattern_id)
		var allowed := ["type", "count", "spread_degrees", "spin_speed", "speed_mult", "damage_mult", "offset_degrees"]
		for key in definition.keys():
			if not allowed.has(String(key)):
				return _invalid("unsupported projectile pattern key: %s" % String(key))
		var normalized: Dictionary = definition.duplicate(true)
		normalized["type"] = pattern_type
		if definition.has("count") and not _is_int_in_range(definition["count"], 1, 64):
			return _invalid("projectile pattern count is out of range: %s" % pattern_id)
		for key in ["spread_degrees", "spin_speed", "speed_mult", "damage_mult", "offset_degrees"]:
			if definition.has(key) and not _is_number_in_range(definition[key], -1000.0, 1000.0):
				return _invalid("projectile pattern value is out of range: %s" % pattern_id)
		result[pattern_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _normalize_upgrades(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("upgrades must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var upgrade_id := String(raw_id)
		if not is_safe_id(upgrade_id) or upgrade_id.contains(":"):
			return _invalid("upgrade ids must be simple, namespacable ids: %s" % upgrade_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid upgrade definition: %s" % upgrade_id)
		if typeof(definition.get("name", null)) != TYPE_STRING or String(definition["name"]).strip_edges().is_empty() or String(definition["name"]).length() > 128:
			return _invalid("upgrade %s needs a name" % upgrade_id)
		if typeof(definition.get("description", "")) != TYPE_STRING or String(definition.get("description", "")).length() > 512:
			return _invalid("upgrade %s has invalid description" % upgrade_id)
		if not _is_int_in_range(definition.get("rarity", 0), 0, 4):
			return _invalid("upgrade %s rarity is out of range" % upgrade_id)
		if not _is_int_in_range(definition.get("max_level", 1), 1, MAX_UPGRADE_LEVEL):
			return _invalid("upgrade %s max_level is out of range" % upgrade_id)
		var effect: Variant = definition.get("effect", {})
		var effect_error := _effect_error("upgrade %s" % upgrade_id, effect)
		if not effect_error.is_empty():
			return _invalid(effect_error)
		var normalized: Dictionary = definition.duplicate(true)
		normalized["name"] = String(definition["name"]).strip_edges()
		normalized["description"] = String(definition.get("description", ""))
		normalized["rarity"] = int(definition.get("rarity", 0))
		normalized["max_level"] = int(definition.get("max_level", 1))
		normalized["effect"] = effect.duplicate(true)
		if definition.has("category"):
			if typeof(definition["category"]) != TYPE_STRING or String(definition["category"]).length() > 64:
				return _invalid("upgrade %s has invalid category" % upgrade_id)
		if definition.has("icon_color") and not _valid_color(definition["icon_color"]):
			return _invalid("upgrade %s has invalid icon_color" % upgrade_id)
		if definition.has("weight") and not _is_number_in_range(definition["weight"], 0.0, 100000.0):
			return _invalid("upgrade %s weight is out of range" % upgrade_id)
		# An evolution names the upgrade it grows from: one of this item's own
		# upgrades, or a built-in one. It is offered once that upgrade is maxed.
		if definition.has("evolves_from"):
			var base: Variant = definition["evolves_from"]
			if typeof(base) != TYPE_STRING or not (value.has(String(base)) or String(base) in BUILTIN_UPGRADES) or String(base) == upgrade_id:
				return _invalid("upgrade %s evolves_from must name another upgrade in this item or a built-in upgrade" % upgrade_id)
		if definition.has("special_types"):
			var special_types: Variant = definition["special_types"]
			if typeof(special_types) != TYPE_ARRAY or special_types.is_empty() or special_types.size() > CELL_SPECIAL_TYPES.size():
				return _invalid("upgrade %s special_types must be a non-empty list" % upgrade_id)
			for special_type in special_types:
				if typeof(special_type) != TYPE_STRING or not CELL_SPECIAL_TYPES.has(String(special_type)):
					return _invalid("upgrade %s has an unknown special type: %s" % [upgrade_id, str(special_type)])
		result[upgrade_id] = normalized
	return {"valid": true, "value": result, "errors": []}

## Shared by upgrades and synergies. Returns an empty string when valid.
static func _effect_error(owner: String, effect: Variant) -> String:
	if typeof(effect) != TYPE_DICTIONARY or effect.is_empty() or effect.size() > UPGRADE_EFFECT_RANGES.size() + UPGRADE_BOOLEAN_EFFECTS.size():
		return "%s effect must be a non-empty object" % owner
	for effect_key in effect.keys():
		var effect_name := String(effect_key)
		if effect_name in UPGRADE_BOOLEAN_EFFECTS:
			if typeof(effect[effect_key]) != TYPE_BOOL:
				return "%s effect %s must be true or false" % [owner, effect_name]
			continue
		if not UPGRADE_EFFECT_RANGES.has(effect_name):
			return "%s has an unsupported effect: %s" % [owner, effect_name]
		var bounds: Array = UPGRADE_EFFECT_RANGES[effect_name]
		var valid_effect := _is_int_in_range(effect[effect_key], int(bounds[0]), int(bounds[1])) if effect_name in UPGRADE_INTEGER_EFFECTS else _is_number_in_range(effect[effect_key], float(bounds[0]), float(bounds[1]))
		if not valid_effect:
			return "%s effect %s is out of range" % [owner, effect_name]
	return ""

## Run modifiers appear in the custom-run picker beside the built-in ones.
static func _normalize_run_modifiers(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("run_modifiers must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var modifier_id := String(raw_id)
		if not is_safe_id(modifier_id) or modifier_id.contains(":"):
			return _invalid("run modifier ids must be simple, namespacable ids: %s" % modifier_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid run modifier definition: %s" % modifier_id)
		for key in definition.keys():
			if not ["name", "description", "effects"].has(String(key)):
				return _invalid("run modifier %s has an unsupported field: %s" % [modifier_id, String(key)])
		if typeof(definition.get("name", null)) != TYPE_STRING or String(definition["name"]).strip_edges().is_empty() or String(definition["name"]).length() > 128:
			return _invalid("run modifier %s needs a name" % modifier_id)
		if typeof(definition.get("description", null)) != TYPE_STRING or String(definition["description"]).strip_edges().is_empty() or String(definition["description"]).length() > 512:
			return _invalid("run modifier %s needs a description" % modifier_id)
		var effects: Variant = definition.get("effects", null)
		if typeof(effects) != TYPE_DICTIONARY or effects.is_empty() or effects.size() > RUN_MODIFIER_EFFECT_RANGES.size():
			return _invalid("run modifier %s effects must be a non-empty object" % modifier_id)
		for effect_key in effects.keys():
			var effect_name := String(effect_key)
			if not RUN_MODIFIER_EFFECT_RANGES.has(effect_name):
				return _invalid("run modifier %s has an unsupported effect: %s" % [modifier_id, effect_name])
			var bounds: Array = RUN_MODIFIER_EFFECT_RANGES[effect_name]
			var valid_effect := _is_int_in_range(effects[effect_key], int(bounds[0]), int(bounds[1])) if effect_name in RUN_MODIFIER_INTEGER_EFFECTS else _is_number_in_range(effects[effect_key], float(bounds[0]), float(bounds[1]))
			if not valid_effect:
				return _invalid("run modifier %s effect %s is out of range" % [modifier_id, effect_name])
		result[modifier_id] = {
			"name": String(definition["name"]).strip_edges(),
			"description": String(definition["description"]).strip_edges(),
			"effects": Dictionary(effects).duplicate(true),
		}
	return {"valid": true, "value": result, "errors": []}

## Synergies complete when every listed upgrade is at its maximum rank. A
## recipe may name this item's own upgrades and built-in ones.
static func _normalize_synergies(value: Variant, upgrades: Dictionary) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("synergies must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var synergy_id := String(raw_id)
		if not is_safe_id(synergy_id) or synergy_id.contains(":"):
			return _invalid("synergy ids must be simple, namespacable ids: %s" % synergy_id)
		var definition: Variant = value[raw_id]
		if typeof(definition) != TYPE_DICTIONARY or not _validate_json_data(definition):
			return _invalid("invalid synergy definition: %s" % synergy_id)
		for key in definition.keys():
			if not ["name", "description", "requires", "effect"].has(String(key)):
				return _invalid("synergy %s has an unsupported field: %s" % [synergy_id, String(key)])
		if typeof(definition.get("name", null)) != TYPE_STRING or String(definition["name"]).strip_edges().is_empty() or String(definition["name"]).length() > 128:
			return _invalid("synergy %s needs a name" % synergy_id)
		if typeof(definition.get("description", "")) != TYPE_STRING or String(definition.get("description", "")).length() > 512:
			return _invalid("synergy %s has invalid description" % synergy_id)
		var requires: Variant = definition.get("requires", null)
		if typeof(requires) != TYPE_ARRAY or requires.size() < 2 or requires.size() > MAX_SYNERGY_REQUIREMENTS:
			return _invalid("synergy %s requires must list 2-%d upgrades" % [synergy_id, MAX_SYNERGY_REQUIREMENTS])
		var seen: Dictionary = {}
		for required in requires:
			if typeof(required) != TYPE_STRING or not (upgrades.has(String(required)) or String(required) in BUILTIN_UPGRADES) or seen.has(String(required)):
				return _invalid("synergy %s requires an unknown or repeated upgrade: %s" % [synergy_id, str(required)])
			seen[String(required)] = true
		var effect_error := _effect_error("synergy %s" % synergy_id, definition.get("effect", {}))
		if not effect_error.is_empty():
			return _invalid(effect_error)
		result[synergy_id] = {
			"name": String(definition["name"]).strip_edges(),
			"description": String(definition.get("description", "")),
			"requires": requires.duplicate(),
			"effect": Dictionary(definition["effect"]).duplicate(true),
		}
	return {"valid": true, "value": result, "errors": []}

static func _normalize_sfx_sections(content: Dictionary) -> Dictionary:
	var recipes: Dictionary = {}
	var files: Dictionary = {}
	var sources: Array = []
	if content.has("sfx"):
		if typeof(content["sfx"]) != TYPE_DICTIONARY:
			return _invalid("sfx must be an object")
		for key in content["sfx"].keys():
			if not ["recipes", "files"].has(String(key)):
				return _invalid("unsupported sfx key: %s" % String(key))
		sources.append(content["sfx"])
	if content.has("sfx_recipes"):
		sources.append({"recipes": content["sfx_recipes"]})
	if content.has("sfx_files"):
		sources.append({"files": content["sfx_files"]})

	for source in sources:
		if source.has("recipes"):
			var recipes_result := _normalize_sfx_recipes(source["recipes"])
			if not bool(recipes_result["valid"]):
				return recipes_result
			_merge_last_wins(recipes, recipes_result["value"])
		if source.has("files"):
			var files_result := _normalize_sfx_files(source["files"])
			if not bool(files_result["valid"]):
				return files_result
			_merge_last_wins(files, files_result["value"])

	var result: Dictionary = {}
	if not recipes.is_empty():
		result["sfx_recipes"] = recipes
	if not files.is_empty():
		result["sfx_files"] = files
	return {"valid": true, "value": result, "errors": []}

static func _normalize_sfx_recipes(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("sfx recipes must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var event_id := String(raw_id)
		if not is_safe_id(event_id):
			return _invalid("invalid sfx event id: %s" % event_id)
		var recipe: Variant = value[raw_id]
		if typeof(recipe) != TYPE_DICTIONARY or not _validate_json_data(recipe):
			return _invalid("invalid sfx recipe: %s" % event_id)
		var allowed := ["waveform", "freq_start", "freq_end", "duration", "attack", "decay", "sustain_level", "release", "volume", "filter_sweep", "filter_cutoff", "cooldown"]
		for key in recipe.keys():
			if not allowed.has(String(key)):
				return _invalid("unsupported sfx recipe key: %s" % String(key))
		var normalized: Dictionary = recipe.duplicate(true)
		var defaults := {
			"waveform": "sine",
			"freq_start": 440.0,
			"freq_end": 440.0,
			"duration": 0.12,
			"attack": 0.002,
			"decay": 0.06,
			"sustain_level": 0.0,
			"release": 0.02,
			"volume": 0.25,
		}
		for default_key in defaults:
			if not normalized.has(default_key):
				normalized[default_key] = defaults[default_key]
		if recipe.has("waveform"):
			if typeof(recipe["waveform"]) != TYPE_STRING or not SFX_WAVEFORMS.has(String(recipe["waveform"])):
				return _invalid("invalid waveform: %s" % event_id)
			normalized["waveform"] = String(recipe["waveform"])
		for key in ["freq_start", "freq_end", "filter_cutoff"]:
			if recipe.has(key) and not _is_number_in_range(recipe[key], 20.0, 20000.0):
				return _invalid("invalid frequency in sfx recipe: %s" % event_id)
		for key in ["duration", "attack", "decay", "release"]:
			if recipe.has(key) and not _is_number_in_range(recipe[key], 0.0, MAX_SFX_DURATION):
				return _invalid("invalid envelope in sfx recipe: %s" % event_id)
		for key in ["sustain_level", "volume"]:
			if recipe.has(key) and not _is_number_in_range(recipe[key], 0.0, 1.0):
				return _invalid("invalid level in sfx recipe: %s" % event_id)
		if recipe.has("cooldown") and not _is_number_in_range(recipe["cooldown"], 0.0, MAX_SFX_DURATION):
			return _invalid("invalid cooldown in sfx recipe: %s" % event_id)
		if recipe.has("filter_sweep") and typeof(recipe["filter_sweep"]) != TYPE_BOOL:
			return _invalid("invalid filter_sweep in sfx recipe: %s" % event_id)
		result[event_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _normalize_sfx_files(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return _invalid("sfx files must be an object")
	var result: Dictionary = {}
	for raw_id in value.keys():
		var event_id := String(raw_id)
		if not is_safe_id(event_id):
			return _invalid("invalid sfx file event id: %s" % event_id)
		var raw_file: Variant = value[raw_id]
		var file_path := ""
		var definition: Dictionary = {}
		if typeof(raw_file) == TYPE_STRING:
			file_path = String(raw_file)
		elif typeof(raw_file) == TYPE_DICTIONARY:
			definition = raw_file
			file_path = String(raw_file.get("file", raw_file.get("path", "")))
			for key in raw_file.keys():
				if not ["file", "path", "volume", "pitch_scale"].has(String(key)):
					return _invalid("unsupported sfx file key: %s" % String(key))
		else:
			return _invalid("invalid sfx file: %s" % event_id)
		if not is_safe_relative_path(file_path):
			return _invalid("sfx file path is not a safe audio path: %s" % event_id)
		var normalized := {"file": file_path}
		if definition.has("volume"):
			if not _is_number_in_range(definition["volume"], 0.0, 1.0):
				return _invalid("sfx file volume is out of range: %s" % event_id)
			normalized["volume"] = float(definition["volume"])
		if definition.has("pitch_scale"):
			if not _is_number_in_range(definition["pitch_scale"], 0.4, 2.5):
				return _invalid("sfx file pitch_scale is out of range: %s" % event_id)
			normalized["pitch_scale"] = float(definition["pitch_scale"])
		result[event_id] = normalized
	return {"valid": true, "value": result, "errors": []}

static func _extract_waves(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY and value.has("waves"):
		return value["waves"]
	return value

static func _looks_like_wave(value: Dictionary) -> bool:
	for key in ["interval", "spawn_interval", "pools", "duration", "boss", "boss_id"]:
		if value.has(key):
			return true
	return false

static func _validate_json_data(value: Variant, depth: int = 0) -> bool:
	if depth > 12:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL:
			return true
		TYPE_INT, TYPE_FLOAT:
			return is_finite(float(value)) and absf(float(value)) <= MAX_RULE_VALUE
		TYPE_STRING:
			return String(value).length() <= 2048
		TYPE_ARRAY:
			if value.size() > 512:
				return false
			for item in value:
				if not _validate_json_data(item, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			if value.size() > 512:
				return false
			for key in value.keys():
				if typeof(key) != TYPE_STRING or _is_forbidden_key(String(key)) or not _validate_json_data(value[key], depth + 1):
					return false
			return true
		_:
			return false

static func _has_effective_content(value: Variant) -> bool:
	match typeof(value):
		TYPE_DICTIONARY:
			for child in value.values():
				if _has_effective_content(child):
					return true
			return false
		TYPE_ARRAY:
			for child in value:
				if _has_effective_content(child):
					return true
			return false
		TYPE_NIL:
			return false
	return true

static func _contains_forbidden_key(value: Variant, depth: int = 0) -> bool:
	if depth > 12:
		return true
	if typeof(value) == TYPE_DICTIONARY:
		for key in value.keys():
			if typeof(key) != TYPE_STRING or _is_forbidden_key(String(key)) or _contains_forbidden_key(value[key], depth + 1):
				return true
	elif typeof(value) == TYPE_ARRAY:
		for item in value:
			if _contains_forbidden_key(item, depth + 1):
				return true
	return false

static func _is_forbidden_key(key: String) -> bool:
	return ["script", "scene", "native", "resource", "code", "call", "load", "instantiate", "preload", "class_name", "script_path", "scene_path"].has(key.to_lower())

static func _valid_color(value: Variant) -> bool:
	if typeof(value) == TYPE_STRING:
		var text := String(value).strip_edges()
		if text.is_empty() or text.length() > 64:
			return false
		var fallback := Color(-1.0, -1.0, -1.0, -1.0)
		var parsed := Color.from_string(text, fallback)
		return parsed.r >= 0.0 and parsed.g >= 0.0 and parsed.b >= 0.0 and parsed.a >= 0.0
	if typeof(value) == TYPE_ARRAY:
		if value.size() < 3 or value.size() > 4:
			return false
		for channel in value:
			if not _is_number_in_range(channel, 0.0, 1.0):
				return false
		return true
	return false

static func _validate_boss_overrides(value: Variant, _path: String) -> bool:
	if typeof(value) != TYPE_DICTIONARY or not _validate_json_data(value):
		return false
	var allowed := [
		"hp_scale", "contact_scale", "score_value", "boss_name", "visual_color", "bullet_color",
		"boss_base_health_multiplier", "shoot_interval", "bullet_speed", "bullet_damage", "visual_radius",
		"radial_bullet_count", "aimed_spread_count", "aimed_spread_angle", "radial_rotation_speed",
		"spiral_spin_speed", "attack_pattern", "boss_pattern", "projectile_pattern", "minion_interval",
		"minion_spawn_count",
	]
	for raw_key in value.keys():
		var key := String(raw_key)
		if not allowed.has(key):
			return false
		match key:
			"hp_scale", "contact_scale":
				if not _is_number_in_range(value[raw_key], 0.01, 10.0):
					return false
			"score_value":
				if not _is_int_in_range(value[raw_key], 0, 1000000):
					return false
			"boss_name":
				if typeof(value[raw_key]) != TYPE_STRING or String(value[raw_key]).length() > 128:
					return false
			"visual_color", "bullet_color":
				if not _valid_color(value[raw_key]):
					return false
			"attack_pattern":
				if typeof(value[raw_key]) != TYPE_STRING or not ATTACK_PATTERNS.has(String(value[raw_key])):
					return false
			"boss_pattern":
				if typeof(value[raw_key]) != TYPE_STRING or not BOSS_PATTERNS.has(String(value[raw_key])):
					return false
			"projectile_pattern":
				if not is_safe_id(value[raw_key]):
					return false
	if value.has("shoot_interval") and not _is_valid_shoot_interval(value["shoot_interval"]):
		return false
	var numeric_error := _validate_field_ranges(value, {
		"boss_base_health_multiplier": [2.5, 10.0],
		"bullet_speed": [0.0, 2000.0], "bullet_damage": [0.0, 16000.0],
		"visual_radius": [4.0, 160.0], "radial_bullet_count": [3.0, 32.0],
		"aimed_spread_count": [1.0, 32.0], "aimed_spread_angle": [1.0, 90.0],
		"radial_rotation_speed": [-20.0, 20.0], "spiral_spin_speed": [-20.0, 20.0],
		"minion_interval": [0.2, 30.0], "minion_spawn_count": [1.0, 8.0],
	}, ["score_value", "radial_bullet_count", "aimed_spread_count", "minion_spawn_count"], _path)
	return numeric_error.is_empty()

static func _is_int_in_range(value: Variant, minimum: int, maximum: int) -> bool:
	if typeof(value) == TYPE_INT:
		return int(value) >= minimum and int(value) <= maximum
	if typeof(value) == TYPE_FLOAT:
		var number := float(value)
		return is_finite(number) and is_equal_approx(number, round(number)) and number >= minimum and number <= maximum
	return false

static func _is_number_in_range(value: Variant, minimum: float, maximum: float) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	var number := float(value)
	return is_finite(number) and number >= minimum and number <= maximum

static func _is_valid_shoot_interval(value: Variant) -> bool:
	return _is_number_in_range(value, 0.05, 20.0) or (typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) == 0.0)

static func _validate_field_ranges(value: Dictionary, ranges: Dictionary, integer_fields: Array, context: String) -> String:
	for raw_key in ranges.keys():
		var key := String(raw_key)
		if not value.has(key):
			continue
		var bounds: Array = ranges[raw_key]
		var valid := _is_int_in_range(value[key], int(bounds[0]), int(bounds[1])) if integer_fields.has(key) else _is_number_in_range(value[key], float(bounds[0]), float(bounds[1]))
		if not valid:
			return "%s.%s is out of range or has the wrong type" % [context, key]
	return ""

static func _merge_last_wins(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		target[key] = source[key]

static func _merge_nested_last_wins(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		if not target.has(key):
			target[key] = {}
		var nested: Dictionary = target[key]
		_merge_last_wins(nested, source[key])

static func _canonicalize(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY:
		var keys: Array = value.keys()
		keys.sort()
		var result: Dictionary = {}
		for key in keys:
			result[String(key)] = _canonicalize(value[key])
		return result
	if typeof(value) == TYPE_ARRAY:
		var array: Array = []
		for item in value:
			array.append(_canonicalize(item))
		return array
	return value

static func _invalid(message: String) -> Dictionary:
	return {"valid": false, "value": {}, "errors": [message]}
