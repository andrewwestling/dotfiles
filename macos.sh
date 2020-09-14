# ✅ Set computer name (as done via System Preferences → Sharing)
#sudo scutil --set ComputerName "Name Here"
#sudo scutil --set HostName "name-here"
#sudo scutil --set LocalHostName "name-here"
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "name-here"

# ✅ Login Window text
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "RETURN TO: Andrew M Westling | a@andrewwestling.com"

# ✅ Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# ✅ Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ✅ Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ✅ Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# ✅ Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# 🚫(didn't work) Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ✅ Disable “natural” (Lion-style) scrolling (requires restart)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ✅ Set a blazingly fast keyboard repeat rate (requires restart)
defaults write NSGlobalDomain KeyRepeat -int 10
defaults write NSGlobalDomain InitialKeyRepeat -int 30

# ✅ Disable press-and-hold for keys in favor of key repeat (requires restart)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

###############################################################################
# Finder                                                                      #
###############################################################################

# ✅ Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# ✅ Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# ✅ Enable snap-to-grid for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# ✅ Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 100" ~/Library/Preferences/com.apple.finder.plist

# ✅ Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 80" ~/Library/Preferences/com.apple.finder.plist

# ✅ Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ✅ Show internal drives on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# ✅ Set default Finder window location to root
defaults write com.apple.finder NewWindowTarget -string "PfLo" && \
defaults write com.apple.finder NewWindowTargetPath -string "file:///"

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# ✅ Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# ✅ Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Wipe all (default) app icons from the Dock
# This is only really useful when setting up a new Mac, or if you don’t use
# the Dock to launch apps.
defaults write com.apple.dock persistent-apps -array

# 🚫(didn't work) Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1

# ✅ Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# ✅ Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
# ✅ Top left screen corner (none)
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
# ✅ Top right screen corner (none)
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
# ✅ Bottom left screen corner → Disable screen saver
defaults write com.apple.dock wvous-bl-corner -int 6
defaults write com.apple.dock wvous-bl-modifier -int 0
# ✅ Bottom right screen corner → Start screen saver
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0

###############################################################################
# Spotlight                                                                   #
###############################################################################

# 🚫(didn't work) Change indexing order and disable some search results
defaults write com.apple.spotlight orderedItems -array \
'{ enabled = 1; name = APPLICATIONS;}' \
'{ enabled = 0; name = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
'{ enabled = 1; name = "MENU_CONVERSION";}' \
'{ enabled = 1; name = "MENU_EXPRESSION";}' \
'{ enabled = 0; name = "MENU_DEFINITION";}' \
'{ enabled = 1; name = "SYSTEM_PREFS";}' \
'{ enabled = 0; name = DOCUMENTS;}' \
'{ enabled = 1; name = DIRECTORIES;}' \
'{ enabled = 0; name = PRESENTATIONS;}' \
'{ enabled = 0; name = SPREADSHEETS;}' \
'{ enabled = 0; name = PDF;}' \
'{ enabled = 0; name = MESSAGES;}' \
'{ enabled = 0; name = CONTACT;}' \
'{ enabled = 0; name = "EVENT_TODO";}' \
'{ enabled = 0; name = IMAGES;}' \
'{ enabled = 0; name = BOOKMARKS;}' \
'{ enabled = 0; name = MUSIC;}' \
'{ enabled = 0; name = MOVIES;}' \
'{ enabled = 0; name = FONTS;}' \
'{ enabled = 0; name = "MENU_OTHER";}'


###############################################################################
# Messages                                                                    #
###############################################################################

# ✅ Disable smart quotes as it’s annoying for messages that contain code
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# ✅ Disable continuous spell checking
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false
