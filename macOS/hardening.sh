#!/bin/bash
#create write protect important file ( even root can NOT modify / delete file ). Need to boot recovery to delete/modufy it
chflags schg /path/to/file

#hibernation settings
sudo pmset -a destroyfvkeyonstandby 1
sudo pmset -a hibernatemode 25
sudo pmset -a powernap 0
sudo pmset -a standby 0
sudo pmset -a standbydelay 0
sudo pmset -a autopoweroff 0

#firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

#disable captive portal to prevent MitM
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

#clean sensitive metadata
sudo rm -rfv "~/Library/LanguageModeling/*" "~/Library/Spelling/*" "~/Library/Suggestions/*"
sudo chmod -R 000 ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions
sudo chflags -R uchg ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions

#disable ssh access
sudo systemsetup -setremotelogin off
sudo systemsetup -f -setremotelogin off

#misc security
sudo defaults write com.apple.screensaver askForPassword -int 1
sudo defaults write com.apple.screensaver askForPasswordDelay -int 0
sudo defaults write com.apple.finder AppleShowAllFiles -bool true

#unhide folder
sudo chflags nohidden /path/to/file

#show all hidden files
defaults write com.apple.finder AppleShowAllFiles YES; killall Finder

#show extensions
sudo defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#disable to save to cloud
sudo defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

#no bonjur multicast
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool YES

#update software
softwareupdate -i -a && rm -rf /var/root/mil
sudo reboot