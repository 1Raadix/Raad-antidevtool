function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

local function sendToDiscord(source, message, color, identifier)
    local name = GetPlayerName(source) or "Unknown"
    if not color then
        color = Config.ColorMessage
    end
    
    local sendD = {
        {
            ["color"] = color,
            ["title"] = message,
            ["description"] = "`Player`: **"..name.."**\nSteam: **"..identifier.steam.."**\nDiscord: **"..identifier.discord.."**\nFivem: **"..identifier.license.."**",
            ["footer"] = {
                ["text"] = "© Raad | Hipe Development - "..os.date("%x %X %p")
            },
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Hipe Dev - Anti nui_devtools", embeds = sendD}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent(GetCurrentResourceName())
AddEventHandler(GetCurrentResourceName(), function()
    local _source = source
    local identifier = ExtractIdentifiers(_source)
    local identifierDb = Config.ExtendedVersionV1Final and identifier.license or identifier.steam
    if Config.CheckMethod == 'steam' then
        local isAllowed = false
        
        if #Config.AllowList > 0 then
            for _, v in pairs(Config.AllowList) do
                if v == identifierDb then
                    isAllowed = true
                    break
                end
            end
        end
        if not isAllowed then
            sendToDiscord(_source, Config.DiscordMessage, Config.ColorMessage, identifier)
            DropPlayer(_source, Config.KickMessage)
        end

    elseif Config.CheckMethod == 'SQL' then
        MySQL.Async.fetchAll("SELECT group FROM users WHERE identifier = @identifier", {['@identifier'] = identifierDb}, function(results) 
            if results and results[1] then
                if results[1].group ~= 'admin' and results[1].group ~= 'superadmin' then
                    sendToDiscord(_source, Config.DiscordMessage, Config.ColorMessage, identifier)
                    DropPlayer(_source, Config.KickMessage)
                end
            else
                sendToDiscord(_source, Config.DiscordMessage, Config.ColorMessage, identifier)
                DropPlayer(_source, Config.KickMessage)
            end
        end)
    elseif Config.CheckMethod == 'none' then
        sendToDiscord(_source, Config.DiscordMessage, Config.ColorMessage, identifier)
        DropPlayer(_source, Config.KickMessage)
    end
end)