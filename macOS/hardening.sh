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
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

#prevent built-in software as well as code-signed, downloaded software from being whitelisted automatically
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
sudo pkill -HUP socketfilterfw

#Kernel level packet filtering

echo 'wifi = "en0"' >> pf.rules 
echo 'ether = "en7"' >> pf.rules
echo 'set block-policy drop' >> pf.rules
echo 'set fingerprints "/etc/pf.os"' >> pf.rules
echo 'set ruleset-optimization basic' >> pf.rules
echo 'set skip on lo0' >> pf.rules
echo 'scrub in all no-df' >> pf.rules
echo 'table <blocklist> persist' >> pf.rules
echo 'block in log' >> pf.rules
echo 'block in log quick from no-route to any' >> pf.rules
echo 'block log on $wifi from { <blocklist> } to any' >> pf.rules
echo 'block log on $wifi from any to { <blocklist> }' >> pf.rules
echo 'antispoof quick for { $wifi $ether }' >> pf.rules
echo 'pass out proto tcp from { $wifi $ether } to any keep state' >> pf.rules
echo 'pass out proto udp from { $wifi $ether } to any keep state' >> pf.rules
echo 'pass out proto icmp from $wifi to any keep state' >> pf.rules

sudo pfctl -e -f pf.rules
sudo pfctl -t blocklist -T add x.x.x.x/xx y.y.y.y

#homebrew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#use dnscrypt
brew install dnscrypt-proxy
brew info dnscrypt-proxy
sudo nano /usr/local/etc/dnscrypt-proxy.toml
sudo brew services restart dnscrypt-proxy

#check dnscrypt
sudo lsof +c 15 -Pni UDP:5355

#disable all other, non-dnscrypt DNS traffic
block drop quick on !lo0 proto udp from any to any port = 53
block drop quick on !lo0 proto tcp from any to any port = 53

#prevent upstream queries for unqualified names, and block entire top-level domain names
brew install dnsmasq --with-dnssec
curl -o dnsmasq.conf https://raw.githubusercontent.com/drduh/config/master/dnsmasq.conf
sudo nano dnsmasq.conf
sudo brew services start dnsmasq
sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1

#check dnsmasq
scutil --dns | head

#disable launchdaemons
sudo launchctl unload -w /System/Library/LaunchDaemons/daemon

#disable captive portal to prevent MitM
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false

#clean sensitive metadata
sudo rm -rfv "~/Library/LanguageModeling/*" "~/Library/Spelling/*" "~/Library/Suggestions/*"
sudo chmod -R 000 ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions
sudo chflags -R uchg ~/Library/LanguageModeling ~/Library/Spelling ~/Library/Suggestions

#disable ssh access
sudo systemsetup -setremotelogin off
sudo systemsetup -f -setremotelogin off

#demoting an account
dscl . -read /Users/<username> GeneratedUID
sudo dscl . -delete /Groups/admin GroupMembership <username>
sudo dscl . -delete /Groups/admin GroupMembers <GeneratedUID>

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

#run commands when login/logout
defaults write com.apple.loginwindow LoginBook /path/to/script
defaults write com.apple.loginwindow LogoutBook /path/to/script

#setting a firmware password prevents from starting up from any device
sudo firmwarepasswd -setpasswd -setmode command

#verify the firmware password
sudo firmwarepasswd -verify

#update software
softwareupdate -i -a && rm -rf /var/root/mil
sudo reboot