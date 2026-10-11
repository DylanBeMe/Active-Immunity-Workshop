#!/usr/bin/env bash
# Upload an Active Immunity mod folder to the Steam Workshop with SteamCMD.
#
#   tools/upload_workshop_mod.sh path/to/my-mod [options]
#
# Options:
#   --steam-user NAME     Steam account to upload with (asked for if omitted)
#   --visibility V        private (default for a new item), friends, unlisted, public
#   --title TEXT          Item title (new item default: "name" from manifest.json)
#   --description TEXT    Item description (new item default: "description" from manifest.json)
#   --preview FILE        Preview image, PNG/JPG/GIF under 1 MB
#   --changenote TEXT     What changed in this upload (default: "Update")
#   --steamcmd PATH       SteamCMD executable (default: steamcmd on PATH)
#   --app-id ID           Steam App ID (default: 5023510, Active Immunity)
#
# The first upload creates the item and saves its ID beside the mod folder as
# "<folder>.workshop-id". Later uploads update that item. On updates, title,
# description, visibility and preview are only changed when you pass them, so
# edits made on the item's Steam page are kept.
set -euo pipefail

APP_ID="5023510"
MAX_PREVIEW_BYTES=$((1024 * 1024))

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

mod_dir=""
steam_user=""
visibility=""
title=""
description=""
preview=""
changenote=""
steamcmd="steamcmd"
while (( $# > 0 )); do
  case "$1" in
    -h|--help) usage 0 ;;
    --steam-user|--visibility|--title|--description|--preview|--changenote|--steamcmd|--app-id)
      (( $# >= 2 )) || fail "$1 needs a value."
      case "$1" in
        --steam-user) steam_user="$2" ;;
        --visibility) visibility="$2" ;;
        --title) title="$2" ;;
        --description) description="$2" ;;
        --preview) preview="$2" ;;
        --changenote) changenote="$2" ;;
        --steamcmd) steamcmd="$2" ;;
        --app-id) APP_ID="$2" ;;
      esac
      shift 2 ;;
    -*) fail "Unknown option $1 (see --help)." ;;
    *) [[ -z "$mod_dir" ]] || fail "Only one mod folder at a time."; mod_dir="$1"; shift ;;
  esac
done
[[ -n "$mod_dir" ]] || usage 1

# --- Check the mod folder ----------------------------------------------------
[[ -d "$mod_dir" ]] || fail "Mod folder not found: $mod_dir"
mod_dir="$(cd -- "$mod_dir" && pwd -P)"
manifest="$mod_dir/manifest.json"
[[ -f "$manifest" ]] || fail "No manifest.json in $mod_dir. The folder you upload must contain it at the top level."
[[ "$APP_ID" =~ ^[0-9]+$ ]] || fail "--app-id must be a number."
id_file="$(dirname -- "$mod_dir")/$(basename -- "$mod_dir").workshop-id"

case "${visibility:-}" in
  '') visibility_code="" ;;
  public) visibility_code=0 ;;
  friends) visibility_code=1 ;;
  private) visibility_code=2 ;;
  unlisted) visibility_code=3 ;;
  *) fail "--visibility must be private, friends, unlisted or public." ;;
esac

if [[ -n "$preview" ]]; then
  [[ -f "$preview" ]] || fail "Preview image not found: $preview"
  preview="$(cd -- "$(dirname -- "$preview")" && pwd -P)/$(basename -- "$preview")"
  (( $(wc -c < "$preview") <= MAX_PREVIEW_BYTES )) || fail "The preview image must be under 1 MB."
fi

published_id="0"
if [[ -f "$id_file" ]]; then
  published_id="$(tr -cd '0-9' < "$id_file")"
  [[ -n "$published_id" ]] || fail "$id_file does not contain an item ID. Fix or delete it."
fi

# Reads a top-level string from manifest.json. Python is only used for this;
# without it, pass --title and --description.
manifest_field() {
  command -v python3 >/dev/null || return 0
  python3 - "$manifest" "$1" <<'PY'
import json, sys
try:
    value = json.load(open(sys.argv[1], encoding="utf-8")).get(sys.argv[2], "")
except (OSError, ValueError):
    value = ""
print(value if isinstance(value, str) else "", end="")
PY
}

if [[ "$published_id" == "0" ]]; then
  [[ -n "$title" ]] || title="$(manifest_field name)"
  [[ -n "$description" ]] || description="$(manifest_field description)"
  [[ -n "$title" ]] || fail "No title: pass --title, or set \"name\" in manifest.json."
  [[ -n "$visibility_code" ]] || visibility_code=2
fi
[[ -n "$changenote" ]] || changenote="$([[ "$published_id" == "0" ]] && echo "First release." || echo "Update")"

# --- Validate, when Godot is available ---------------------------------------
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
if command -v godot >/dev/null; then
  echo "Validating $manifest ..."
  godot --headless --path "$repo_root" --script tools/validate_workshop_mod.gd -- "$manifest" ||
    fail "The validator found problems. Fix them before uploading."
else
  echo "Godot not found on PATH; skipping the offline validator (see README, Part 5)."
fi

# --- SteamCMD -----------------------------------------------------------------
command -v "$steamcmd" >/dev/null || [[ -x "$steamcmd" ]] ||
  fail "SteamCMD not found. Install it (README, Part 5) or pass --steamcmd /path/to/steamcmd.sh."
if [[ -z "$steam_user" ]]; then
  read -r -p "Steam account name: " steam_user
fi
[[ -n "$steam_user" ]] || fail "A Steam account name is needed."

# VDF strings: escape backslashes and quotes, keep line breaks as \n.
vdf_escape() { local s="${1//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//$'\r'/}"; printf '%s' "${s//$'\n'/\\n}"; }

# Some SteamCMD launchers split arguments at spaces, so the item file lives in
# a space-free folder. (Spaces inside the file, like the mod path, are fine.)
work_dir="$(mktemp -d /tmp/workshop-upload.XXXXXXXX)"
trap 'rm -rf -- "$work_dir"' EXIT
vdf="$work_dir/item.vdf"
{
  echo '"workshopitem"'
  echo '{'
  printf '\t"appid"\t\t"%s"\n' "$APP_ID"
  printf '\t"publishedfileid"\t"%s"\n' "$published_id"
  printf '\t"contentfolder"\t"%s"\n' "$(vdf_escape "$mod_dir")"
  printf '\t"changenote"\t"%s"\n' "$(vdf_escape "$changenote")"
  [[ -z "$title" ]] || printf '\t"title"\t\t"%s"\n' "$(vdf_escape "$title")"
  [[ -z "$description" ]] || printf '\t"description"\t"%s"\n' "$(vdf_escape "$description")"
  [[ -z "$visibility_code" ]] || printf '\t"visibility"\t"%s"\n' "$visibility_code"
  [[ -z "$preview" ]] || printf '\t"previewfile"\t"%s"\n' "$(vdf_escape "$preview")"
  echo '}'
} > "$vdf"

# Sign in on its own first, so password and Steam Guard prompts are shown
# normally. SteamCMD remembers the login, so the upload below does not ask again.
echo "Signing in to Steam as $steam_user ..."
"$steamcmd" +login "$steam_user" +quit
if [[ "$published_id" == "0" ]]; then
  echo "Creating a new Workshop item ..."
else
  echo "Updating Workshop item $published_id ..."
fi
log="$work_dir/steamcmd.log"
set +e
"$steamcmd" +login "$steam_user" +workshop_build_item "$vdf" +quit 2>&1 | tee "$log"
status=${PIPESTATUS[0]}
set -e
grep -qiE 'ERROR|FAILED' "$log" && fail "SteamCMD reported a problem (see the output above)."
(( status == 0 )) || fail "SteamCMD exited with status $status."

created=false
if [[ "$published_id" == "0" ]]; then
  created=true
  # SteamCMD writes the new ID back into the item file; its output also names it.
  new_id="$(sed -n 's/^[[:space:]]*"publishedfileid"[[:space:]]*"\([0-9]*\)".*/\1/p' "$vdf" | head -n 1)"
  if [[ -z "$new_id" || "$new_id" == "0" ]]; then
    new_id="$(grep -oiE '(publishedfileid|published file id|publishfileid)[^0-9]{0,4}[0-9]{6,}' "$log" | grep -oE '[0-9]{6,}' | tail -n 1 || true)"
  fi
  if [[ -n "$new_id" && "$new_id" != "0" ]]; then
    echo "$new_id" > "$id_file"
    published_id="$new_id"
    echo "Saved the item ID to $id_file; the next upload updates this item."
  else
    echo "Uploaded, but the new item ID could not be read from SteamCMD's output."
    echo "Open the item on Steam, copy the number after 'id=' in its address, and save it in:"
    echo "  $id_file"
    exit 0
  fi
fi
echo "Done: https://steamcommunity.com/sharedfiles/filedetails/?id=$published_id"
if "$created"; then
  echo "New items stay hidden until you accept the Workshop legal agreement on that page."
fi
