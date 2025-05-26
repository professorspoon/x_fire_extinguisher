-- Framework detection and initialization
Framework = {}

-- Auto-detect the server framework
Framework.Detect = function()
    -- Check for ESX
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    -- Check for QBCore
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    else
        -- Fallback to default if detection fails
        return 'esx'
    end
end

-- Initialize framework based on config setting
Framework.Initialize = function()
    local frameworkType = Config.Framework
    
    -- Handle auto-detection
    if frameworkType == 'auto' then
        frameworkType = Framework.Detect()
    end
    
    -- Handle qbox as qbcore (they use same resource name)
    if frameworkType == 'qbox' then
        frameworkType = 'qbcore'
    end
    
    -- Store the actual framework type to use throughout the script
    Framework.Type = frameworkType
    
    return frameworkType
end 