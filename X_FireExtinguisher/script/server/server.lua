-- Framework Variables
local ESX, QBCore = nil, nil
local FrameworkInitialized = false

-- Player Cooldown Tracking
local PlayerCooldowns = {}

-- Framework Detection & Initialization
Citizen.CreateThread(function()
    -- Initialize framework using our new framework detection system
    local frameworkType = Framework.Initialize()
    
    if frameworkType == 'esx' then
        if Config.ESXVersion == 'new' then
            -- New ESX uses exports
            while ESX == nil do
                ESX = exports['es_extended']:getSharedObject()
                
                if ESX == nil then
                    print('X_FireExtinguisher: Waiting for ESX (new version)...')
                    Citizen.Wait(500)
                end
            end
            --print('X_FireExtinguisher: ESX framework (new version) initialized')
        else
            -- Old ESX uses events
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
                
                if ESX == nil then
                    --print('X_FireExtinguisher: Waiting for ESX (old version)...')
                    Citizen.Wait(500)
                end
            end
            --print('X_FireExtinguisher: ESX framework (old version) initialized')
        end
        FrameworkInitialized = true
    elseif frameworkType == 'qbcore' then
        while QBCore == nil do
            -- Check for QBCore via export (preferred method)
            if GetResourceState('qb-core') == 'started' then
                QBCore = exports['qb-core']:GetCoreObject()
            end
            -- Fallback to event-based method
            if QBCore == nil then
                TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            end
            if QBCore == nil then
                --print('X_FireExtinguisher: Waiting for QBCore...')
                Citizen.Wait(500)
            end
        end
        --print('X_FireExtinguisher: QBCore framework detected and initialized')
        FrameworkInitialized = true
    else
        --print('X_FireExtinguisher: Framework not configured properly!')
    end
end)

-- Check if player has the item
local function HasItem(source, itemName)
    local src = source
    
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local item = xPlayer.getInventoryItem(itemName)
            return item and item.count and item.count > 0
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local item = Player.Functions.GetItemByName(itemName)
            return item ~= nil and item.amount > 0
        end
    end
    
    return false
end

-- Add item to player's inventory
local function AddItem(source, itemName, count)
    local src = source
    
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if Config.UseItem then
                xPlayer.addInventoryItem(itemName, count)
            else
                -- Give weapon directly
                xPlayer.addWeapon(itemName, 4500)
            end
            return true
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            if Config.UseItem then
                Player.Functions.AddItem(itemName, count)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
            else
                -- Give weapon directly using QBCore method
                Player.Functions.AddItem(itemName, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'add')
                
                -- Also give ammo for QBCore players
                -- Wait a moment to ensure the weapon is added first
                Citizen.Wait(100)
                TriggerClientEvent('xfire:giveAmmo', src, itemName, 4500)
            end
            return true
        end
    end
    
    return false
end

-- Remove item from player's inventory
local function RemoveItem(source, itemName, count)
    local src = source
    
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if Config.UseItem then
                xPlayer.removeInventoryItem(itemName, count)
            else
                -- Remove weapon directly
                xPlayer.removeWeapon(itemName)
            end
            return true
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            if Config.UseItem then
                Player.Functions.RemoveItem(itemName, count)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')
            else
                -- Remove weapon directly using QBCore method
                Player.Functions.RemoveItem(itemName, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], 'remove')
            end
            return true
        end
    end
    
    return false
end

-- Check player cooldown
local function CheckCooldown(source)
    -- If cooldowns are disabled, always return true (no cooldown)
    if not Config.UseCooldown then return true end
    
    local src = source
    local identifier
    
    -- Get player identifier based on framework
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            identifier = Player.PlayerData.citizenid
        end
    end
    
    -- If we couldn't get an identifier, allow action
    if not identifier then return true end
    
    -- Check if player has a cooldown
    if PlayerCooldowns[identifier] then
        local timeLeft = PlayerCooldowns[identifier] - os.time()
        
        -- If cooldown has expired, remove it and allow action
        if timeLeft <= 0 then
            PlayerCooldowns[identifier] = nil
            return true
        end
        
        -- Otherwise, return the time left
        return false, timeLeft
    end
    
    -- No cooldown found for player, allow action
    return true
end

-- Set player cooldown
local function SetCooldown(source)
    -- If cooldowns are disabled, do nothing
    if not Config.UseCooldown then return end
    
    local src = source
    local identifier
    
    -- Get player identifier based on framework
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            identifier = Player.PlayerData.citizenid
        end
    end
    
    -- If we couldn't get an identifier, do nothing
    if not identifier then return end
    
    -- Set cooldown for player
    PlayerCooldowns[identifier] = os.time() + Config.CooldownTime
end

-- Clear player cooldown (e.g., when player disconnects)
local function ClearCooldown(source)
    local src = source
    local identifier
    
    -- Get player identifier based on framework
    if Framework.Type == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif Framework.Type == 'qbcore' and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            identifier = Player.PlayerData.citizenid
        end
    end
    
    -- If we couldn't get an identifier, do nothing
    if not identifier then return end
    
    -- Clear cooldown for player
    PlayerCooldowns[identifier] = nil
end

-- Handle player disconnect to clean up cooldowns
AddEventHandler('playerDropped', function()
    ClearCooldown(source)
end)

-- Function to send server-side notifications
local function NotifyServer(source, message, notifyType)
    if Config.NotifyFunctions and Config.NotifyFunctions.ServerNotify then
        -- Use the custom function from config
        Config.NotifyFunctions.ServerNotify(source, message, notifyType)
    else
        -- Fallback to basic notification
        TriggerClientEvent('xfire:displayNotification', source, nil, message, notifyType)
    end
end

RegisterNetEvent('xfire:toggleExtinguisher')
AddEventHandler('xfire:toggleExtinguisher', function()
    local source = source
    local item = Config.ItemName
    local count = 1
    
    -- Check cooldown first
    local canUse, timeLeft = CheckCooldown(source)
    
    if not canUse then
        -- Player is on cooldown
        local message = string.format(XTranslate('cooldown_msg'), timeLeft)
        NotifyServer(source, message, 'error')
        return
    end

    if HasItem(source, item) then
        TriggerClientEvent('xfire:returnExtinguisher', source)
        RemoveItem(source, item, count)
        NotifyServer(source, XTranslate('remfire1'), 'info')
    else
        TriggerClientEvent('xfire:giveExtinguisher', source)
        AddItem(source, item, count)
        NotifyServer(source, XTranslate('success2'), 'success')
    end
    
    -- Set cooldown after action
    SetCooldown(source)
end)

-- Event to check player cooldown status from client
RegisterNetEvent('xfire:checkCooldown')
AddEventHandler('xfire:checkCooldown', function()
    local source = source
    local canUse, timeLeft = CheckCooldown(source)
    
    -- Send result back to client
    TriggerClientEvent('xfire:cooldownStatus', source, canUse, timeLeft or 0)
end) 