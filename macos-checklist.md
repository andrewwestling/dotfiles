# macOS settings checklist

A click-through list of the system settings I change on a fresh Mac, captured
from my MacBook Air on 2026-08-28. There is deliberately **no script** — a
previous `macos.sh` was removed (commit `a92d0d5`) because scripted `defaults
write` values didn't reliably apply and needed logout/reboot/`killall` dances to
half-take. Do these by hand in System Settings.

Each item lists the GUI path and, in parentheses, the underlying `defaults`
key/value for reference if you want to spot-check with `defaults read`.

## System Settings

### General > Appearance
- Appearance: **Light** _(NSGlobalDomain `AppleInterfaceStyle` unset)_

### Desktop & Dock
- **Automatically hide and show the Dock: on** _(com.apple.dock `autohide = 1`)_
- **Show suggested and recent apps in Dock: off** _(com.apple.dock `show-recents = 0`)_
- Everything else (size, magnification, position, minimise effect) left at default.

### Keyboard
- **Key repeat rate: Fast** (second-fastest notch) _(NSGlobalDomain `KeyRepeat = 2`)_
- **Delay until repeat: short** (second-shortest notch) _(NSGlobalDomain `InitialKeyRepeat = 15`)_
- Keyboard > **Text Input > Edit…** — turn all of these **off**:
  - Capitalise words automatically _(`NSAutomaticCapitalizationEnabled = 0`)_
  - Add full stop with double-space _(`NSAutomaticPeriodSubstitutionEnabled = 0`)_
  - Use smart quotes and dashes _(`NSAutomaticQuoteSubstitutionEnabled = 0`, `NSAutomaticDashSubstitutionEnabled = 0`)_

### Trackpad / Mouse
- Trackpad > Point & Click > **Tap to click: off** _(com.apple.AppleMultitouchTrackpad `Clicking = 0`)_
- Trackpad > Scroll & Zoom > **Natural scrolling: off** _(NSGlobalDomain `com.apple.swipescrolldirection = 0`)_

  Note: on the iMac's Magic Mouse this is the same "Natural scrolling" toggle
  under Mouse.

### Control Centre / Menu bar
- Clock > **Show seconds: on** _(com.apple.menuextra.clock `ShowSeconds = 1`)_

## Spotlight search results

I've trimmed Spotlight's result categories heavily (no PDFs, images, movies,
music, presentations, spreadsheets, source code, executables, Xcode files, etc.
— basically files/folders/apps/system settings only). Rebuilding that by
clicking ~20 checkboxes in System Settings > Spotlight is tedious and the
underlying `DisabledUTTypes` list has entries with no checkbox, so this one is
captured as a plist:

[`macos/com.apple.Spotlight.plist`](macos/com.apple.Spotlight.plist) — holds
only `DisabledUTTypes` (categories switched off) and `EnabledPreferenceRules`
(categories left on). Volatile keys (window position, engagement counters, FTE
flags) were stripped.

To apply on a fresh Mac:

```zsh
defaults import com.apple.Spotlight ~/Code/dotfiles/macos/com.apple.Spotlight.plist
killall Spotlight            # relaunches the menu-bar agent so it re-reads prefs
sudo mdutil -E /             # optional: rebuild the index
```

Then open System Settings > Spotlight once to confirm the "Search results"
checkboxes match what you want, and adjust any that macOS re-enabled.

This is `defaults import` (whole-domain replace + `killall`), which sticks far
more reliably than the per-key `defaults write` calls that got `macos.sh`
deleted — but still verify in the GUI afterwards.

## Finder

With a Finder window focused:
- View > **Show Path Bar** _(com.apple.finder `ShowPathbar = 1`)_
- View > **Show Status Bar** _(com.apple.finder `ShowStatusBar = 1`)_
- View > **as List** (default view style) _(com.apple.finder `FXPreferredViewStyle = Nlsv`)_
- Finder > Settings > Advanced > **When performing a search: Search the Current Folder**
  _(com.apple.finder `FXDefaultSearchScope = SCcf`)_
- Finder > Settings > General > **New Finder windows show: (whatever "All My Files"/Recents maps to)**
  _(com.apple.finder `NewWindowTarget = PfAF`)_
- Finder > Settings > General — **Show these on the desktop: Hard disks, External disks**
  _(com.apple.finder `ShowHardDrivesOnDesktop = 1`, `ShowExternalHardDrivesOnDesktop = 1`)_

## Not captured (decide fresh on the iMac)

- Displays arrangement / scaling
- Screenshot save location and format (left at defaults here)
- Hot corners
- Login items beyond what `brew` casks add
- Notification settings per-app

## Related manual steps

These live in [README.md](README.md), not here:
- Computer name (System Settings > General > About / Sharing)
- 1Password, iCloud, Fastmail, Mac App Store sign-in, SSH agent
