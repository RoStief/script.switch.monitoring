import xbmcaddon
import xbmc
import os

addon       = xbmcaddon.Addon()
addonname   = addon.getAddonInfo('name')

os.system('systemd-run bash /storage/scripts/shutdown_kodi.sh')
xbmc.executebuiltin('Quit')
