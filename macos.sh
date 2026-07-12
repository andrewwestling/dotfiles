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

echo "==> Keyboard: Caps Lock -> No Action (per connected keyboard)"
# System Settings stores this per keyboard as vendorid-productid; detect and map all.
# Src 30064771129 = Caps Lock, Dst 30064771072 = No Action.
hidutil list --matching '{"DeviceUsagePage":1,"DeviceUsage":6}' 2>/dev/null \
  | awk '$1 ~ /^0x/ {print $1"-"$2}' | sort -u | while read -r ids; do
  vid=$((${ids%-*})) pid=$((${ids#*-}))
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${vid}-${pid}-0" -array \
    '<dict><key>HIDKeyboardModifierMappingDst</key><integer>30064771072</integer><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer></dict>'
  echo "    mapped keyboard ${vid}-${pid}"
done

echo "==> Restarting Dock, Finder, SystemUIServer"
killall Dock Finder SystemUIServer 2>/dev/null || true

echo "==> Done. Some settings apply after logout."
