fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name "X_FireExtinguisher"
author 'X1' -- Discord: x_1_tate | Team:FiveWorldDevelopment | Discord: https://discord.gg/2vgzWxvpsm
description 'Pick up Fire Extinguischers from everywhere'
version '1.0.1'

shared_script {
  'configuration/config.lua',
  'configuration/translation.lua',
  'script/shared/*.lua'
}

client_scripts {
  'script/client/*.lua',
}
  
server_scripts {
  'script/server/*.lua',
}

escrow_ignore {
  'configuration/config.lua',
  'configuration/translation.lua',
}
