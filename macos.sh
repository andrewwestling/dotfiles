#!/usr/bin/env zsh
# macOS defaults — run manually: ./macos.sh
# Conservative starter set; prune or extend as needed.
# Most changes need a logout (or `killall Dock`/`killall Finder`, done below).
set -euo pipefail

echo "==> Keyboard: fast key repeat, short delay"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "==> Finder: show all extensions, path bar, status bar"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

echo "==> Finder: search current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "==> Dock: autohide"
defaults write com.apple.dock autohide -bool true

echo "==> Screenshots: save to ~/Desktop/Screenshots"
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"

echo "==> Trackpad: disable natural scrolling, set tracking speed"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

echo "==> Keyboard: Caps Lock -> No Action (Apple keyboards only)"
# System Settings stores this per keyboard as vendorid-productid.
# Apple vendor IDs: 0x5ac (internal keyboard), 0x4c (Magic Keyboard).
# Src 30064771129 = Caps Lock, Dst 30064771072 = No Action.
hidutil list --matching '{"DeviceUsagePage":1,"DeviceUsage":6}' 2>/dev/null \
  | awk '$1 == "0x5ac" || $1 == "0x4c" {print $1"-"$2}' | sort -u | while read -r ids; do
  vid=$((${ids%-*})) pid=$((${ids#*-}))
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${vid}-${pid}-0" -array \
    '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771072</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'
  echo "    mapped keyboard ${vid}-${pid}"
done

echo "==> Dock: replace default icons with my layout"
# Requires dockutil (in the Brewfile). Apps not installed yet are skipped.
if command -v dockutil >/dev/null 2>&1; then
  dock_apps=(
    "/System/Applications/Utilities/Activity Monitor.app"
    "/Applications/Linear.app"
    "/Applications/Cursor.app"
    "/Applications/Conductor.app"
    "/Applications/1Password.app"
    "/System/Applications/Contacts.app"
    "/Applications/Plinky.app"
    "/System/Applications/Calendar.app"
    "/Applications/Slack.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Photos.app"
    "/Applications/Brave Browser.app"
    "/Applications/Claude.app"
    "/System/Applications/FindMy.app"
    "/System/Applications/Messages.app"
    "/Applications/Codex.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/MacWhisper.app"
    "/Applications/Steam.app"
    "/Applications/Ghostty.app"
    "/Applications/GitHub Desktop.app"
    "/Applications/Obsidian.app"
    "/Applications/Spotify.app"
    "/System/Applications/VoiceMemos.app"
  )
  dockutil --remove all --no-restart >/dev/null
  for app in "${dock_apps[@]}"; do
    [[ -e "$app" ]] && dockutil --add "$app" --no-restart >/dev/null || echo "    (skipping $app — not installed)"
  done
  dockutil --add "/Applications" --view grid --display folder --no-restart >/dev/null
  dockutil --add "$HOME/Downloads" --view fan --display stack --no-restart >/dev/null
else
  echo "    dockutil not installed; skipping (brew install dockutil)"
fi

echo "==> Restarting Dock, Finder, SystemUIServer"
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "==> Done. Some settings apply after logout."
