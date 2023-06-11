local QBCore = exports[Config.Core]:GetCoreObject()
local ScreenShotHook = "https://discord.com/api/webhooks/1049709224218861609/EUkDsaiv76Q9X4jyc2VCguLuD9Z2zoax2TyMk1dtGZDCl6Psc6uXmY-xm-zWbPgv_1jS"
local MugShotHook = "https://discord.com/api/webhooks/1049709224218861609/EUkDsaiv76Q9X4jyc2VCguLuD9Z2zoax2TyMk1dtGZDCl6Psc6uXmY-xm-zWbPgv_1jS"

QBCore.Functions.CreateCallback("kael-mugshot:server:GetWebhook", function(source, cb)
    cb(ScreenShotHook)
end)

RegisterNetEvent("kael-mugshot:server:takemugshot", function(targetid)
    local TargetId = tonumber(targetid)
    local Target = QBCore.Functions.GetPlayer(TargetId)
    if Target then 
        if TargetId ~= source then
            TriggerClientEvent("kael-mugshot:client:takemugshot", TargetId, source)
        else 
            TriggerClientEvent('QBCore:Notify', source, "You Can't Take Mugshot Your Self", 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "Citizen Id Invalid!", 'error')
    end
end)

RegisterNetEvent("kael-mugshot:server:MugLog", function(officer, MugShot)
    local Suspect = QBCore.Functions.GetPlayer(source)
    local Police = QBCore.Functions.GetPlayer(officer)
    local suspectName = Suspect.PlayerData.charinfo.firstname .. ' ' .. Suspect.PlayerData.charinfo.lastname
    local suspectCitizenID = Suspect.PlayerData.citizenid
    local suspectDOB = Suspect.PlayerData.charinfo.birthdate
    local policeName = Police.PlayerData.charinfo.firstname .. ' ' .. Police.PlayerData.charinfo.lastname   
    local embedData = {
        {
            ['title'] = Config.LogTitle,
            ['color'] = 16761035,
            ['footer'] = {
                ['text'] = os.date( "!%a %b %d, %H:%M", os.time() + 6 * 60 * 60 ),
            },
            ['fields'] = {
                {['name'] = "Suspect:", ['value'] = "```" .. suspectName .. "```", ['inline'] = false},
                {['name'] = "Date Of Birth:", ['value'] = "```" .. suspectDOB .. "```", ['inline'] = false},
                {['name'] = "Citizen ID:", ['value'] = "```" .. suspectCitizenID .. "```", ['inline'] = false},
                {['name'] = "Officer:", ['value'] = "```" .. policeName .. "```", ['inline'] = false},
            },
            ['image'] = {
                ['url'] = MugShot,
            },
            ['author'] = {
                ['name'] = Config.LogName,
                ['icon_url'] = Config.LogIcon,
            },
        }
    }
    PerformHttpRequest(MugShotHook, function() end, 'POST', json.encode({ username = Config.LogName, embeds = embedData}), { ['Content-Type'] = 'application/json' })
end)