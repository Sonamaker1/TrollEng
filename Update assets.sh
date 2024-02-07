# What this does: Deletes assets folder and copies the assets from the compiled build
cp -r ./export/release/linux/bin/assets/ ./assets2
[ -d "./assets2" ] && (rm -r ./assets && mv assets2 assets) || echo "Error: Directory does not exist."
