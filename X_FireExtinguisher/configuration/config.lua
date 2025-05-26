Config = {}

-- Framework Configuration
Config.Framework = 'auto' -- Options: 'auto', 'esx', 'qbcore', 'qbox'
Config.ESXVersion = 'new' -- Options: 'new', 'old' (new uses exports, old uses events)


Config.FireExtinguiserModels = {
    -875057463,
    -171327159,
    -1980225301,
    -666581633,
    -1610165324
} 

-- Item Configuration
-- Recommended: ESX-false | QBCore-true, but depending on your inventory system, you may need to change this
Config.UseItem = false -- If true, will give item; if false, will give weapon directly
Config.ItemName = 'WEAPON_FIREEXTINGUISHER' -- Item name in inventory or weapon hash

-- Cooldown Configuration
Config.UseCooldown = true -- Enable/disable cooldown system
Config.CooldownTime = 30 -- Cooldown time in seconds

-- Notification Functions (Customizable)
-- These functions can be modified directly to use any notification system
Config.NotifyFunctions = {
    -- Server-side notification function
    ServerNotify = function(source, message, notifyType)
        -- Check for X_HUD_Notify first
        if GetResourceState('X_HUD_Notify') == 'started' then
            exports['X_HUD_Notify']:NotifyPlayer(source, message, notifyType or 'info', 5000)
            return
        end
        
        -- Fallback implementation (framework-dependent)
        if Framework and Framework.Type == 'esx' then
            -- ESX Notification
            TriggerClientEvent('esx:showNotification', source, message, notifyType or 'info', 5000)
        elseif Framework and Framework.Type == 'qbcore' then
            -- QB-Core Notification
            TriggerClientEvent('QBCore:Notify', source, message, notifyType or 'primary', 5000)
        end
        
        -- You can customize this function to use any notification system, for example:
        -- TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = notifyType, text = message })
        -- TriggerClientEvent('okokNotify:Alert', source, "LiveInvader", message, 5000, notifyType)
    end,
    
    -- Client-side notification function
    ClientNotify = function(message, notifyType)
        -- Check for X_HUD_Notify first
        if GetResourceState('X_HUD_Notify') == 'started' then
            exports['X_HUD_Notify']:Notify(message, notifyType or 'info', 5000)
            return
        end
        
        -- Fallback implementation (framework-dependent)
        if Framework and Framework.Type == 'esx' then
            -- ESX Notification
            ESX.ShowNotification(message)
        elseif Framework and Framework.Type == 'qbcore' then
            -- QB-Core Notification
            QBCore.Functions.Notify(message, notifyType or 'primary', 5000)
        end
        
        -- You can customize this function to use any notification system, for example:
        -- exports['mythic_notify']:DoHudText(notifyType, message)
        -- exports['okokNotify']:Alert("LiveInvader", message, 5000, notifyType)
    end
}

-- Text UI Functions (Customizable)
-- These functions can be modified to use any Text UI system
Config.TextUIFunctions = {
    -- Show Text UI
    Show = function(key, message)
        -- Check for X_HUD_TextUI export first
        if GetResourceState('X_HUD_TextUI') == 'started' then
            exports['X_HUD_TextUI']:Show(key, message)
            return
        end
        
        -- Default implementation (framework-dependent)
        if Framework and Framework.Type == 'esx' then
            if GetResourceState('esx_textui') == 'started' then
                -- ESX TextUI doesn't process ~INPUT_CONTEXT~ so we need to replace it manually
                local formattedMessage = message
                if string.find(message, "~INPUT_CONTEXT~") then
                    formattedMessage = message:gsub("~INPUT_CONTEXT~", "E")
                end
                -- Use export instead of direct ESX access
                exports['esx_textui']:TextUI(formattedMessage)
            else
                -- Legacy ESX_ShowHelpNotification
                TriggerEvent('esx:showHelpNotification', message)
            end
        elseif Framework and Framework.Type == 'qbcore' then
            -- QB-Core DrawText
            exports['qb-core']:DrawText(message, 'left')
        end
        
        -- You can customize this function to use any TextUI system, for example:
        -- exports['okokTextUI']:Open(message, 'darkblue', 'left')
        -- TriggerEvent('cd_drawtextui:ShowUI', 'show', message)
    end,
    
    -- Hide Text UI
    Hide = function()
        -- Check for X_HUD_TextUI export first
        if GetResourceState('X_HUD_TextUI') == 'started' then
            exports['X_HUD_TextUI']:Hide()
            return
        end
        
        -- Default implementation (framework-dependent)
        if Framework and Framework.Type == 'esx' then
            if GetResourceState('esx_textui') == 'started' then
                -- Use export instead of direct ESX access
                exports['esx_textui']:HideUI()
            end
        elseif Framework and Framework.Type == 'qbcore' then
            -- QB-Core HideText
            exports['qb-core']:HideText()
        end
        
        -- You can customize this function to use any TextUI system, for example:
        -- exports['okokTextUI']:Close()
        -- TriggerEvent('cd_drawtextui:HideUI')
    end
}