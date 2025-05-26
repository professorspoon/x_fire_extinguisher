local models = Config.FireExtinguiserModels
local isNearExtinguisher = false
local textDisplayed = false
local lastExtinguisherObject = nil

-- Cooldown tracking
local onCooldown = false
local cooldownEndTime = 0
local cooldownCheckTime = 0

-- Performance optimization
local nearbyExtinguishers = {}
local lastScanTime = 0
local scanInterval = 2000 -- Scan for extinguishers every 2 seconds
local playerLastPos = vector3(0,0,0)
local hasPlayerMoved = false
local SCAN_DISTANCE = 10.0 -- Distance to scan for extinguishers
local INTERACTION_DISTANCE = 2.0 -- Distance for interaction
local FIRE_EXTINGUISHER_HASH = GetHashKey(Config.ItemName)

-- Framework Variables
local ESX, QBCore = nil, nil
local PlayerData = {}
local frameworkInitialized = false

-- Initialize framework
Citizen.CreateThread(function()
    while true do
        if Framework and Framework.Type then
            -- Framework has been detected on server-side
            if Framework.Type == 'esx' then
                -- ESX initialization
                if Config.ESXVersion == 'new' then
                    -- New ESX uses exports
                    ESX = exports['es_extended']:getSharedObject()
                else
                    -- Old ESX uses events
                    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                end
                
                -- Set up ESX event handlers once initialized
                if ESX then
                    -- Get initial player data
                    PlayerData = ESX.GetPlayerData()
                    
                    -- Update player data when it changes
                    RegisterNetEvent('esx:playerLoaded')
                    AddEventHandler('esx:playerLoaded', function(xPlayer)
                        PlayerData = xPlayer
                    end)
                    
                    RegisterNetEvent('esx:setJob')
                    AddEventHandler('esx:setJob', function(job)
                        PlayerData.job = job
                    end)
                    
                    break -- Exit the loop once initialized
                end
            elseif Framework.Type == 'qbcore' then
                -- QBCore initialization
                QBCore = exports['qb-core']:GetCoreObject()
                
                -- Set up QBCore event handlers once initialized
                if QBCore then
                    -- Get initial player data
                    PlayerData = QBCore.Functions.GetPlayerData()
                    
                    -- Update player data when it changes
                    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
                    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
                        PlayerData = QBCore.Functions.GetPlayerData()
                    end)
                    
                    RegisterNetEvent('QBCore:Client:OnJobUpdate')
                    AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
                        PlayerData.job = job
                    end)
                    
                    break -- Exit the loop once initialized
                end
            end
        end
        
        Citizen.Wait(500)
    end
end)

-- Client notification function
function NotifyClient(message, notifyType)
    if Config.NotifyFunctions and Config.NotifyFunctions.ClientNotify then
        -- Use the custom function from config
        Config.NotifyFunctions.ClientNotify(message, notifyType)
    else
        -- Fallback to basic notification
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, true)
    end
end

-- Function to show Text UI
function ShowTextUI(key, message)
    if not textDisplayed then
        textDisplayed = true
        
        -- Use a pcall to catch any errors that might occur with TextUI
        local success = pcall(function()
            if Config.TextUIFunctions and Config.TextUIFunctions.Show then
                Config.TextUIFunctions.Show(key, message)
            else
                -- Fallback to basic help text
                BeginTextCommandDisplayHelp('STRING')
                AddTextComponentSubstringPlayerName(message)
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
        end)
        
        -- If there was an error, use the basic help text instead
        if not success then
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(message)
            EndTextCommandDisplayHelp(0, false, true, -1)
            print('X_FireExtinguisher: Error in TextUI Show function, using fallback method')
        end
    end
end

-- Function to hide Text UI
function HideTextUI()
    if textDisplayed then
        textDisplayed = false
        
        -- Use a pcall to catch any errors that might occur with TextUI
        local success = pcall(function()
            if Config.TextUIFunctions and Config.TextUIFunctions.Hide then
                Config.TextUIFunctions.Hide()
            end
        end)
        
        -- Log any error but continue
        if not success then
            print('X_FireExtinguisher: Error in TextUI Hide function')
        end
    end
end

-- Force hide TextUI when needed
function ForceHideTextUI()
    textDisplayed = false
    
    -- Use a pcall to catch any errors that might occur with TextUI
    pcall(function()
        if Config.TextUIFunctions and Config.TextUIFunctions.Hide then
            Config.TextUIFunctions.Hide()
        end
    end)
end

-- Function to check if player is on cooldown
function IsOnCooldown()
    -- If cooldowns are disabled, never on cooldown
    if not Config.UseCooldown then return false end
    
    local currentTime = GetGameTimer() / 1000 -- Convert to seconds
    
    -- If we have a cached cooldown that's still valid
    if onCooldown and currentTime < cooldownEndTime then
        return true
    end
    
    -- If we recently checked with the server and weren't on cooldown
    if not onCooldown and (currentTime - cooldownCheckTime) < 5 then
        return false
    end
    
    -- We need fresh data, but limit checks to once every second
    if (currentTime - cooldownCheckTime) > 1 then
        cooldownCheckTime = currentTime
        TriggerServerEvent('xfire:checkCooldown')
    end
    
    return onCooldown
end

-- Check if player has moved significantly (for optimization)
function HasPlayerMovedSignificantly(coords, threshold)
    threshold = threshold or 1.0
    local distance = #(coords - playerLastPos)
    return distance > threshold
end

-- Scan for nearby extinguishers and cache them
function ScanForExtinguishers(playerCoords)
    nearbyExtinguishers = {}
    
    -- Use a for loop with numeric indexing for performance
    for i = 1, #models do
        local model = models[i]
        local object = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, SCAN_DISTANCE, model, false, false, false)
        
        if DoesEntityExist(object) then
            -- Make sure the object is not attached to the player or any other ped
            if not IsEntityAttachedToAnyPed(object) then
                local objCoords = GetEntityCoords(object)
                local distance = #(playerCoords - objCoords)
                table.insert(nearbyExtinguishers, {object = object, coords = objCoords, distance = distance})
            end
        end
    end
    
    -- Sort by distance for optimization
    table.sort(nearbyExtinguishers, function(a, b) 
        return a.distance < b.distance 
    end)
    
    return #nearbyExtinguishers > 0
end

-- Receive cooldown status from server
RegisterNetEvent('xfire:cooldownStatus')
AddEventHandler('xfire:cooldownStatus', function(canUse, timeLeft)
    local currentTime = GetGameTimer() / 1000 -- Convert to seconds
    onCooldown = not canUse
    
    if onCooldown then
        cooldownEndTime = currentTime + timeLeft
    else
        cooldownEndTime = 0
    end
end)

-- Extinguisher detection thread (less frequent)
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        -- Check if player has moved enough to re-scan
        hasPlayerMoved = HasPlayerMovedSignificantly(coords, 3.0)
        if hasPlayerMoved or (GetGameTimer() - lastScanTime) > scanInterval then
            ScanForExtinguishers(coords)
            playerLastPos = coords
            lastScanTime = GetGameTimer()
        end
        
        Citizen.Wait(scanInterval / 2) -- Scan at half the interval rate
    end
end)

-- Main UI and interaction thread
Citizen.CreateThread(function()
    local waitTime = 1000
    
    while true do
        -- Start with longer wait time for efficiency
        waitTime = 1000
        
        local playerPed = PlayerPedId()
        
        -- Check player state - hide UI if player is dead or in a vehicle
        if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
            if isNearExtinguisher or textDisplayed then
                isNearExtinguisher = false
                ForceHideTextUI()
            end
            Citizen.Wait(1000) -- Longer wait when player can't interact
        else
            -- Check if player is already holding a fire extinguisher
            local isHoldingExtinguisher = GetSelectedPedWeapon(playerPed) == FIRE_EXTINGUISHER_HASH
            
            -- Check if player is on cooldown
            local playerOnCooldown = IsOnCooldown()
            
            -- If player is holding an extinguisher or on cooldown, hide UI and don't detect objects
            if isHoldingExtinguisher or playerOnCooldown then
                if isNearExtinguisher then
                    isNearExtinguisher = false
                    HideTextUI()
                end
                waitTime = 1000
            else
                -- If we have nearby extinguishers, only then do closer checking
                if #nearbyExtinguishers > 0 then
                    local coords = GetEntityCoords(playerPed)
                    local closestExtinguisher = nil
                    local closestDistance = INTERACTION_DISTANCE + 1.0 -- Initialize beyond interaction range
                    
                    -- Check the closest few extinguishers (optimization)
                    local checkCount = math.min(3, #nearbyExtinguishers) -- Only check up to 3 closest
                    for i = 1, checkCount do
                        local extinguisher = nearbyExtinguishers[i]
                        if DoesEntityExist(extinguisher.object) then
                            -- Update distance calculation
                            local objCoords = GetEntityCoords(extinguisher.object)
                            local distance = #(coords - objCoords)
                            
                            if distance < closestDistance then
                                closestExtinguisher = extinguisher.object
                                closestDistance = distance
                                lastExtinguisherObject = extinguisher.object
                            end
                        end
                    end
                    
                    -- Hysteresis for UI - show at 1.8, hide at 2.2
                    if closestExtinguisher and closestDistance < 1.8 then
                        waitTime = 0 -- Only use 0 wait when very close and interactive
                        
                        -- Only show TextUI when not already shown
                        if not isNearExtinguisher then
                            isNearExtinguisher = true
                            ShowTextUI('E', "Press ~INPUT_CONTEXT~ to " .. XTranslate('helptext'))
                        end
                        
                        -- Check if E key is pressed (only if not on cooldown)
                        if IsControlJustPressed(0, 38) then -- E key
                            TriggerServerEvent('xfire:toggleExtinguisher')
                            -- Hide UI temporarily while action is processing
                            HideTextUI()
                            Citizen.Wait(500) -- Small delay to prevent spam
                        end
                    elseif not closestExtinguisher or closestDistance > 2.2 then
                        -- Hide TextUI when moving away from extinguisher
                        if isNearExtinguisher then
                            isNearExtinguisher = false
                            HideTextUI()
                        end
                        
                        if closestDistance < 5.0 then
                            waitTime = 500 -- Medium wait if somewhat close
                        else
                            waitTime = 1500 -- Longer wait if far away
                        end
                    end
                end
            end
        end

        Citizen.Wait(waitTime)
    end
end)

-- Safety mechanism: Hide TextUI on resource stop to prevent UI sticking
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ForceHideTextUI()
    end
end)

-- Safety mechanism: Hide TextUI when player enters vehicle
AddEventHandler('baseevents:enteredVehicle', function()
    if isNearExtinguisher or textDisplayed then
        isNearExtinguisher = false
        ForceHideTextUI()
    end
end)

-- Safety mechanism: Hide TextUI when player dies
AddEventHandler('baseevents:onPlayerDied', function()
    if isNearExtinguisher or textDisplayed then
        isNearExtinguisher = false
        ForceHideTextUI()
    end
end)

-- Handle events from server
RegisterNetEvent('xfire:giveExtinguisher')
AddEventHandler('xfire:giveExtinguisher', function()
    -- Animation
    local dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
    local anim = 'machinic_loop_mechandplayer'
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(2000) -- Short animation time
    ClearPedTasks(PlayerPedId())
    
    -- Auto-equip the fire extinguisher
    local FIRE_EXTINGUISHER_HASH = GetHashKey(Config.ItemName)
    
    -- Give the weapon if player doesn't have it yet (for immediate selection)
    if not HasPedGotWeapon(PlayerPedId(), FIRE_EXTINGUISHER_HASH, false) then
        GiveWeaponToPed(PlayerPedId(), FIRE_EXTINGUISHER_HASH, 4500, false, true)
    end
    
    -- Select the fire extinguisher
    SetCurrentPedWeapon(PlayerPedId(), FIRE_EXTINGUISHER_HASH, true)
    
    -- Hide UI since player now has the extinguisher equipped
    if isNearExtinguisher then
        isNearExtinguisher = false
        HideTextUI()
    end
    
    -- Reset extinguisher detection
    ScanForExtinguishers(GetEntityCoords(PlayerPedId()))
end)

RegisterNetEvent('xfire:returnExtinguisher')
AddEventHandler('xfire:returnExtinguisher', function()
    -- Animation
    local dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@'
    local anim = 'machinic_loop_mechandplayer'
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end
    
    TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    Citizen.Wait(1000) -- Short animation time
    ClearPedTasks(PlayerPedId())
    
    -- Reset extinguisher detection after returning
    ScanForExtinguishers(GetEntityCoords(PlayerPedId()))
end)

RegisterNetEvent('xfire:displayNotification')
AddEventHandler('xfire:displayNotification', function(title, description, type)
    -- Use the custom notification function
    NotifyClient(description, type)
end)

-- Event to give ammo for weapons in QBCore
RegisterNetEvent('xfire:giveAmmo')
AddEventHandler('xfire:giveAmmo', function(weaponName, ammoCount)
    local playerPed = PlayerPedId()
    local weaponHash = GetHashKey(weaponName)
    
    -- Make sure player has the weapon before giving ammo
    if HasPedGotWeapon(playerPed, weaponHash, false) then
        AddAmmoToPed(playerPed, weaponHash, ammoCount)
    else
        -- Try to give the weapon first if player doesn't have it
        GiveWeaponToPed(playerPed, weaponHash, 0, false, true)
        -- Then add ammo
        AddAmmoToPed(playerPed, weaponHash, ammoCount)
    end
end) 