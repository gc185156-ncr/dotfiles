#!/usr/bin/env bash

# Generates .desktop entries for all installed Steam games with box art for
# the icons to be used with a specifically configured Rofi launcher

SCRIPT_DIR=$(dirname $(realpath $0))

# Change to your steam library
STEAM_ROOT=/data/games/steam
APP_PATH=$HOME/.local/share/applications/steam

# Fetch all Steam library folders.
steam-libraries() {
	echo "$STEAM_ROOT"

	# Additional library folders are recorded in libraryfolders.vdf
	libraryfolders=$STEAM_ROOT/steamapps/libraryfolders.vdf
	if [ -e "$libraryfolders" ]; then
		awk -F\" '/^[[:space:]]*"[[:digit:]]+"/ {print $4}' "$libraryfolders"
	fi
}

# Generate the contents of a .desktop file for a Steam game.
# Expects appid, title, and box art file to be given as arguments
env-entry() {
	cat <<EOF
GAME_ID="$1"
GAME_NAME="$2"
EOF
}

rm -rf $APP_PATH
mkdir -p "$APP_PATH"

for library in $(steam-libraries); do
	# All installed Steam games correspond with an appmanifest_<appid>.acf file
	for manifest in "$library"/steamapps/appmanifest_*.acf; do
		appid=$(basename "$manifest" | tr -dc "[0-9]")
		title=$(awk -F\" '/"name"/ {print $4}' "$manifest" | tr -d "™®")
		entry=$APP_PATH/${title}.env
		# checking for boxart and other criteria
		if echo "$title" | grep -qe "Soundtrack"; then
			continue
		fi

		if echo "$title" | grep -qe "Proton"; then
			continue
		fi

		if echo "$title" | grep -qe "Runtime"; then
			continue
		fi

		# Uncomment for verbose generation
		# echo -e "Generating $entry\t($title)"
		env-entry "$appid" "$title" >"$entry"
	done
done

cd $APP_PATH && eval $(cat "$(ls -1 | sed -e 's/\.env$//' | fzf --border=sharp --color fg:#ebdbb2,bg:#1d2021,hl:#d79921,fg+:#689d6a,bg+:#282828,hl+:#fabd2f,info:#83a598,prompt:#bdae93,spinner:#b16286,pointer:#689d6a,marker:#fe8019,header:#665c54).env")

steam-runtime steam://rungameid/$GAME_ID | xargs lnch
