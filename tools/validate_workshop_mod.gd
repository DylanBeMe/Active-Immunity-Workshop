extends SceneTree

const WorkshopContentRegistry = preload("res://src/progression/workshop_content_registry.gd")

# Keep these limits in lockstep with WorkshopManager so authors get the same
# result before upload that an installed Workshop item gets at runtime.
const MAX_MANIFEST_BYTES := 512 * 1024
const MAX_WORKSHOP_ITEM_BYTES := 16 * 1024 * 1024
const MAX_WORKSHOP_ITEM_FILES := 2048
const MAX_WORKSHOP_DIRECTORY_DEPTH := 16
const MAX_TEXTURE_FILE_BYTES := 4 * 1024 * 1024
const MAX_TEXTURE_DIMENSION := 4096
const MAX_TEXTURE_PIXELS := 16 * 1024 * 1024
const MAX_AUDIO_FILE_BYTES := 4 * 1024 * 1024
const MAX_AUDIO_DURATION := 10.0
const MAX_MOD_AUTHOR_LENGTH := 128
const MAX_MOD_VERSION_LENGTH := 64
const MAX_MOD_DESCRIPTION_LENGTH := 2048
const IMAGE_FILE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]
const AUDIO_FILE_EXTENSIONS := ["wav", "ogg", "mp3"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var arguments := OS.get_cmdline_user_args()
	if arguments.size() != 1:
		print("Usage: godot --headless --path . --script tools/validate_workshop_mod.gd -- path/to/manifest.json")
		quit(2)
		return

	var manifest_path := String(arguments[0])
	if not FileAccess.file_exists(manifest_path):
		_fail("Workshop manifest was not found: %s" % manifest_path)
		return
	var item_directory := manifest_path.get_base_dir()
	var package_errors := _validate_package_limits(item_directory)
	if not package_errors.is_empty():
		_fail_many(package_errors)
		return

	var manifest_size := _get_file_size(manifest_path)
	if manifest_size <= 0 or manifest_size > MAX_MANIFEST_BYTES:
		_fail("manifest.json must be between 1 byte and %d KiB" % (MAX_MANIFEST_BYTES / 1024))
		return
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		_fail("Workshop manifest could not be opened: %s" % manifest_path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("manifest.json must contain a JSON object")
		return

	var manifest: Dictionary = parsed
	if typeof(manifest.get("name")) != TYPE_STRING:
		_fail("manifest.name must be a string")
		return
	var name := String(manifest.get("name", "")).strip_edges()
	if name.is_empty() or name.length() > 128:
		_fail("Workshop manifest needs a name of 1-128 characters")
		return
	for metadata_key in ["author", "version", "description"]:
		if manifest.has(metadata_key) and typeof(manifest[metadata_key]) != TYPE_STRING:
			_fail("manifest.%s must be a string" % metadata_key)
			return
	var author := String(manifest.get("author", "UNKNOWN AUTHOR")).strip_edges()
	var version := String(manifest.get("version", "1.0")).strip_edges()
	var description := String(manifest.get("description", ""))
	if author.length() > MAX_MOD_AUTHOR_LENGTH:
		_fail("manifest.author must be at most %d characters" % MAX_MOD_AUTHOR_LENGTH)
		return
	if version.is_empty() or version.length() > MAX_MOD_VERSION_LENGTH:
		_fail("manifest.version must be from 1 to %d characters" % MAX_MOD_VERSION_LENGTH)
		return
	if description.length() > MAX_MOD_DESCRIPTION_LENGTH:
		_fail("manifest.description must be at most %d characters" % MAX_MOD_DESCRIPTION_LENGTH)
		return
	var content: Variant = manifest.get("content", null)
	if typeof(content) != TYPE_DICTIONARY:
		_fail("manifest.content must be an object")
		return
	var result: Dictionary = WorkshopContentRegistry.validate_content(content)
	if not bool(result.get("valid", false)):
		_fail_many(result.get("errors", []))
		return
	var settings_result: Dictionary = WorkshopContentRegistry.validate_mod_settings(manifest.get("settings", []), result["value"])
	if not bool(settings_result.get("valid", false)):
		_fail_many(settings_result.get("errors", []))
		return
	var setting_values: Dictionary = WorkshopContentRegistry.resolve_mod_settings(settings_result["value"])
	var configured_result: Dictionary = WorkshopContentRegistry.apply_mod_settings(result["value"], settings_result["value"], setting_values)
	if not bool(configured_result.get("valid", false)):
		_fail_many(configured_result.get("errors", []))
		return
	result = WorkshopContentRegistry.validate_content(configured_result["value"])
	if not bool(result.get("valid", false)):
		_fail_many(result.get("errors", []))
		return

	var asset_errors := _validate_referenced_assets(result["value"], item_directory)
	if not asset_errors.is_empty():
		_fail_many(asset_errors)
		return

	print("Workshop package is valid: %s" % name)
	print("Canonical manifest content hash: %s" % WorkshopContentRegistry.content_hash(result["value"]))
	print("Active multiplayer source hash: computed in-game from enabled source IDs and configured normalized content.")
	quit(0)

func _validate_package_limits(item_directory: String) -> Array[String]:
	var result := {"bytes": 0, "files": 0, "errors": []}
	var parent := DirAccess.open(item_directory.get_base_dir())
	if parent == null:
		return ["Could not read Workshop item parent directory: %s" % item_directory.get_base_dir()]
	if parent.is_link(item_directory.get_file()):
		return ["Workshop item directory must not be a symlink: %s" % item_directory]
	_measure_directory(item_directory, 0, result)
	var errors: Array[String] = []
	for error in result["errors"]:
		errors.append(String(error))
	var file_count := int(result["files"])
	var byte_count := int(result["bytes"])
	if file_count > MAX_WORKSHOP_ITEM_FILES:
		errors.append("Workshop item has %d files; the limit is %d" % [file_count, MAX_WORKSHOP_ITEM_FILES])
	if byte_count > MAX_WORKSHOP_ITEM_BYTES:
		errors.append("Workshop item is %.2f MiB; the limit is %d MiB" % [float(byte_count) / 1024.0 / 1024.0, MAX_WORKSHOP_ITEM_BYTES / 1024 / 1024])
	return errors

func _measure_directory(directory_path: String, depth: int, result: Dictionary) -> void:
	if depth > MAX_WORKSHOP_DIRECTORY_DEPTH:
		result["errors"].append("Workshop item directory depth exceeds %d" % MAX_WORKSHOP_DIRECTORY_DEPTH)
		return
	var directory := DirAccess.open(directory_path)
	if directory == null:
		result["errors"].append("Could not read Workshop item directory: %s" % directory_path)
		return
	directory.include_hidden = true
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var path := directory_path.path_join(entry)
		if not _is_safe_directory_entry(entry):
			result["errors"].append("Unsafe Workshop directory entry: %s" % entry)
		elif directory.is_link(entry):
			result["errors"].append("Workshop item must not contain symlinks: %s" % path)
		elif directory.current_is_dir():
			_measure_directory(path, depth + 1, result)
		else:
			result["files"] = int(result["files"]) + 1
			var file_size := _get_file_size(path)
			if file_size < 0:
				result["errors"].append("Could not read Workshop item file: %s" % path)
			else:
				result["bytes"] = int(result["bytes"]) + file_size
		entry = directory.get_next()
	directory.list_dir_end()

func _validate_referenced_assets(content: Dictionary, item_directory: String) -> Array[String]:
	var errors: Array[String] = []
	var cosmetics: Variant = content.get("cosmetics", {})
	if typeof(cosmetics) == TYPE_DICTIONARY:
		for category in cosmetics:
			var category_assets: Variant = cosmetics[category]
			if typeof(category_assets) != TYPE_DICTIONARY:
				continue
			for asset_id in category_assets:
				var definition: Variant = category_assets[asset_id]
				if typeof(definition) == TYPE_DICTIONARY and definition.has("texture"):
					_validate_texture_asset(String(definition["texture"]), item_directory, errors)

	var sfx_files: Variant = content.get("sfx_files", {})
	if typeof(sfx_files) == TYPE_DICTIONARY:
		for event_id in sfx_files:
			var definition: Variant = sfx_files[event_id]
			if typeof(definition) == TYPE_DICTIONARY:
				_validate_audio_asset(String(definition.get("file", "")), item_directory, errors)
	return errors

func _validate_texture_asset(relative_path: String, item_directory: String, errors: Array[String]) -> void:
	if not WorkshopContentRegistry.is_safe_texture_path(relative_path):
		errors.append("Texture path is not a safe supported image path: %s" % relative_path)
		return
	var path := item_directory.path_join(relative_path)
	if not FileAccess.file_exists(path):
		errors.append("Referenced texture is missing: %s" % relative_path)
		return
	var size := _get_file_size(path)
	if size <= 0 or size > MAX_TEXTURE_FILE_BYTES:
		errors.append("Texture %s must be between 1 byte and %d MiB" % [relative_path, MAX_TEXTURE_FILE_BYTES / 1024 / 1024])
		return
	var extension := relative_path.get_extension().to_lower()
	if not IMAGE_FILE_EXTENSIONS.has(extension):
		errors.append("Texture has an unsupported image type: %s" % relative_path)
		return
	var bytes := FileAccess.get_file_as_bytes(path)
	var dimensions := _get_texture_dimensions(bytes, extension)
	if dimensions.x <= 0 or dimensions.y <= 0:
		errors.append("Texture is not a readable %s image: %s" % [extension, relative_path])
		return
	if dimensions.x > MAX_TEXTURE_DIMENSION or dimensions.y > MAX_TEXTURE_DIMENSION:
		errors.append("Texture %s exceeds the %d pixel per-side limit" % [relative_path, MAX_TEXTURE_DIMENSION])
		return
	if dimensions.x * dimensions.y > MAX_TEXTURE_PIXELS:
		errors.append("Texture %s exceeds the %d megapixel limit" % [relative_path, MAX_TEXTURE_PIXELS / 1024 / 1024])
		return
	var image := Image.new()
	var load_error := image.load(path)
	if load_error != OK or image.is_empty() or image.get_width() != dimensions.x or image.get_height() != dimensions.y:
		errors.append("Texture could not be decoded as declared: %s" % relative_path)

func _validate_audio_asset(relative_path: String, item_directory: String, errors: Array[String]) -> void:
	if not WorkshopContentRegistry.is_safe_relative_path(relative_path):
		errors.append("Audio path is not a safe supported audio path: %s" % relative_path)
		return
	var path := item_directory.path_join(relative_path)
	if not FileAccess.file_exists(path):
		errors.append("Referenced audio is missing: %s" % relative_path)
		return
	var size := _get_file_size(path)
	if size <= 0 or size > MAX_AUDIO_FILE_BYTES:
		errors.append("Audio %s must be between 1 byte and %d MiB" % [relative_path, MAX_AUDIO_FILE_BYTES / 1024 / 1024])
		return
	var extension := relative_path.get_extension().to_lower()
	if not AUDIO_FILE_EXTENSIONS.has(extension):
		errors.append("Audio has an unsupported type: %s" % relative_path)
		return
	var stream: AudioStream = null
	match extension:
		"wav":
			stream = AudioStreamWAV.load_from_file(path)
		"ogg":
			stream = AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			stream = AudioStreamMP3.load_from_file(path)
	if stream == null:
		errors.append("Audio could not be decoded as declared: %s" % relative_path)
		return
	var duration := stream.get_length()
	if not is_finite(duration) or duration <= 0.0 or duration > MAX_AUDIO_DURATION:
		errors.append("Audio %s must be longer than 0 and at most %.0f seconds" % [relative_path, MAX_AUDIO_DURATION])

func _get_texture_dimensions(bytes: PackedByteArray, extension: String) -> Vector2i:
	match extension:
		"png":
			if bytes.size() >= 24 and bytes.slice(0, 8) == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]) and bytes.slice(12, 16).get_string_from_ascii() == "IHDR":
				return Vector2i(_read_u32_be(bytes, 16), _read_u32_be(bytes, 20))
		"jpg", "jpeg":
			return _jpeg_dimensions(bytes)
		"webp":
			return _webp_dimensions(bytes)
		"svg":
			return _svg_dimensions(bytes)
	return Vector2i.ZERO

func _jpeg_dimensions(bytes: PackedByteArray) -> Vector2i:
	if bytes.size() < 4 or bytes[0] != 0xff or bytes[1] != 0xd8:
		return Vector2i.ZERO
	var index := 2
	while index + 8 < bytes.size():
		if bytes[index] != 0xff:
			index += 1
			continue
		while index < bytes.size() and bytes[index] == 0xff:
			index += 1
		if index >= bytes.size():
			break
		var marker := int(bytes[index])
		index += 1
		if marker == 0xd8 or marker == 0xd9 or (marker >= 0xd0 and marker <= 0xd7):
			continue
		if index + 2 > bytes.size():
			break
		var segment_length := _read_u16_be(bytes, index)
		if segment_length < 2 or index + segment_length > bytes.size():
			break
		if marker in [0xc0, 0xc1, 0xc2, 0xc3, 0xc5, 0xc6, 0xc7, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf] and segment_length >= 8:
			return Vector2i(_read_u16_be(bytes, index + 5), _read_u16_be(bytes, index + 3))
		index += segment_length
	return Vector2i.ZERO

func _webp_dimensions(bytes: PackedByteArray) -> Vector2i:
	if bytes.size() < 30 or bytes.slice(0, 4).get_string_from_ascii() != "RIFF" or bytes.slice(8, 12).get_string_from_ascii() != "WEBP":
		return Vector2i.ZERO
	var chunk_type := bytes.slice(12, 16).get_string_from_ascii()
	if chunk_type == "VP8X":
		return Vector2i(_read_u24_le(bytes, 24) + 1, _read_u24_le(bytes, 27) + 1)
	if chunk_type == "VP8 " and bytes.size() >= 30 and bytes.slice(23, 26) == PackedByteArray([0x9d, 0x01, 0x2a]):
		return Vector2i(_read_u16_le(bytes, 26) & 0x3fff, _read_u16_le(bytes, 28) & 0x3fff)
	if chunk_type == "VP8L" and bytes.size() >= 25 and bytes[20] == 0x2f:
		return Vector2i(1 + int(bytes[21]) + ((int(bytes[22]) & 0x3f) << 8), 1 + (int(bytes[22]) >> 6) + (int(bytes[23]) << 2) + ((int(bytes[24]) & 0x0f) << 10))
	return Vector2i.ZERO

func _svg_dimensions(bytes: PackedByteArray) -> Vector2i:
	var text := bytes.get_string_from_utf8()
	var svg_start := text.to_lower().find("<svg")
	if svg_start < 0 or svg_start > 4096:
		return Vector2i.ZERO
	var opening_tag_end := text.find(">", svg_start)
	if opening_tag_end < 0 or opening_tag_end - svg_start > 4096:
		return Vector2i.ZERO
	var opening_tag := text.substr(svg_start, opening_tag_end - svg_start + 1)
	var size_regex := RegEx.new()
	if size_regex.compile("(?i)\\b(width|height)\\s*=\\s*['\\\"]?\\s*([0-9]+(?:\\.[0-9]+)?)\\s*(?:px)?") != OK:
		return Vector2i.ZERO
	var dimensions := {}
	for match in size_regex.search_all(opening_tag):
		dimensions[String(match.get_string(1)).to_lower()] = int(roundf(float(match.get_string(2))))
	if dimensions.has("width") and dimensions.has("height"):
		return Vector2i(int(dimensions["width"]), int(dimensions["height"]))
	var view_box_regex := RegEx.new()
	if view_box_regex.compile("(?i)\\bviewbox\\s*=\\s*['\\\"]?\\s*[-0-9.]+\\s+[-0-9.]+\\s+([0-9]+(?:\\.[0-9]+)?)\\s+([0-9]+(?:\\.[0-9]+)?)") != OK:
		return Vector2i.ZERO
	var view_box := view_box_regex.search(opening_tag)
	if view_box == null:
		return Vector2i.ZERO
	return Vector2i(int(roundf(float(view_box.get_string(1)))), int(roundf(float(view_box.get_string(2)))))

func _read_u16_be(bytes: PackedByteArray, offset: int) -> int:
	return (int(bytes[offset]) << 8) | int(bytes[offset + 1])

func _read_u16_le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8)

func _read_u24_le(bytes: PackedByteArray, offset: int) -> int:
	return int(bytes[offset]) | (int(bytes[offset + 1]) << 8) | (int(bytes[offset + 2]) << 16)

func _read_u32_be(bytes: PackedByteArray, offset: int) -> int:
	return (int(bytes[offset]) << 24) | (int(bytes[offset + 1]) << 16) | (int(bytes[offset + 2]) << 8) | int(bytes[offset + 3])

func _get_file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var size := file.get_length()
	file.close()
	return size

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

func _fail_many(errors: Array) -> void:
	for error in errors:
		push_error(String(error))
	quit(1)

func _is_safe_directory_entry(entry: String) -> bool:
	if entry.is_empty() or entry == "." or entry == ".." or entry.length() > 255 or entry.contains("/") or entry.contains("\\"):
		return false
	for character in entry:
		var code := character.unicode_at(0)
		if code < 32 or code == 127:
			return false
	return true
