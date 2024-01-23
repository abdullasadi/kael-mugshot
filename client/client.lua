local QBCore = exports[Config.Core]:GetCoreObject()

CreateThread(function()
    print("^1Kael^7-^1Mugshot ^7| ^5Made ^2By ^6Kael ^3& ^4FM")
    exports[Config.Target]:AddBoxZone('Mugshottarget', vector3(Config.TargetLoc.x, Config.TargetLoc.y, Config.TargetLoc.z), 0.1, 0.3, {
        name = "PoliceMugshot",
        heading = 0,
        debugPoly = Config.Debug,
        minZ = 22.97,
        maxZ = 26.97,
    }, {
        options = {
            {  
                event = "kael-mugshot:Client:mugshotinput",
                icon = "fas fa-clipboard-list",
                label = "Take Shot",
                job = Config.PoliceJobName,
            },
        },
        distance = 1.5
    })
end)

RegisterNetEvent("kael-mugshot:Client:mugshotinput", function()
    local picture = exports[Config.Input]:ShowInput({
        header = "Mugshot Input",
        submitText = "Take Mugshot",
        inputs = {
            {
                text = "Citizen ID (#)",
                name = "citizenid",
                type = "text",
                isRequired = true,
            },
        },
    })
    TriggerServerEvent("kael-mugshot:server:takemugshot", picture.citizenid)
end)

RegisterNetEvent("kael-mugshot:client:takemugshot", function(officer)
	local InProgress = true
	local PlayerPed = PlayerPedId()
	local SuspectCoods = GetEntityCoords(PlayerPed)
	local PlayerData = QBCore.Functions.GetPlayerData()
	local CitizenId = PlayerData.citizenid
	local Name = PlayerData.charinfo.firstname.. " ".. PlayerData.charinfo.lastname
	local DOB = PlayerData.charinfo.birthdate    
    local ScaleformBoard = LoadScale("mugshot_board_01")
    local RenderHandle = CreateRenderModel("ID_Text", "prop_police_id_text")
	CreateThread(function()
        while RenderHandle do
            HideHudAndRadarThisFrame()
            SetTextRenderId(RenderHandle)
            Set_2dLayer(4)
            SetScriptGfxDrawBehindPausemenu(1)
            DrawScaleformMovie(ScaleformBoard, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
            SetScriptGfxDrawBehindPausemenu(0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            SetScriptGfxDrawBehindPausemenu(1)
            SetScriptGfxDrawBehindPausemenu(0)
            Wait(0)
        end
    end)
	Wait(250)
	BeginScaleformMovieMethod(ScaleformBoard, 'SET_BOARD')
    PushScaleformMovieMethodParameterString(Config.BoardHeader)
    PushScaleformMovieMethodParameterString(Name)
    PushScaleformMovieMethodParameterString(CitizenId)
    PushScaleformMovieMethodParameterString(DOB)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(math.random(000, 999))
    PushScaleformMovieFunctionParameterInt(116)
    EndScaleformMovieMethod()
	local MugCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
	SetCamCoord(MugCam, Config.CameraPos.pos)
    SetCamRot(MugCam, Config.CameraPos.rotation, 2)
    RenderScriptCams(1, 0, 0, 1, 1)
    Wait(250)
	CreateThread(function()
        FreezeEntityPosition(PlayerPed, true)
        SetPauseMenuActive(false)
        while InProgress do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true)
            EnableControlAction(0, 46, true)
            Wait(0)
        end
    end)
	SetEntityCoords(PlayerPed, Config.MugShotCoords)
	SetEntityHeading(PlayerPed, Config.MugShotHeading)
	LoadModel("prop_police_id_board")
	LoadModel("prop_police_id_text")
	local Board = CreateObject("prop_police_id_board", SuspectCoods, true, true, false)
	local BoardOverlay = CreateObject("prop_police_id_text", SuspectCoods, true, true, false)
	AttachEntityToEntity(BoardOverlay, Board, -1, 4103, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
	SetModelAsNoLongerNeeded("prop_police_id_board")
	SetModelAsNoLongerNeeded("prop_police_id_text")
    SetCurrentPedWeapon(PlayerPed, "weapon_unarmed", 1)
	ClearPedWetness(PlayerPed)
	ClearPedBloodDamage(PlayerPed)
	AttachEntityToEntity(Board, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 2, 1)	
	LoadAnimDict("mp_character_creation@lineup@male_a")
	TaskPlayAnim(PlayerPed, "mp_character_creation@lineup@male_a", "loop_raised", 8.0, 8.0, -1, 49, 0, false, false, false)
    Wait(1000)
	QBCore.Functions.TriggerCallback('kael-mugshot:server:GetWebhook', function(Hook)
        if Hook then
            exports['screenshot-basic']:requestScreenshotUpload(tostring(Hook), 'files[]', {encoding = 'jpg'}, function(data)
                local Response = json.decode(data)
                local imageURL = Response.attachments[1].url
				TriggerServerEvent('kael-mugshot:server:MugLog', officer, imageURL)
            end)
        end
    end)
    Wait(5000)
	DestroyCam(MugCam, 0)
    RenderScriptCams(0, 0, 1, 1, 1)
    SetFocusEntity(PlayerPed)
    ClearPedTasksImmediately(PlayerPed)
    FreezeEntityPosition(PlayerPed, false)
    DeleteObject(Board)
    DeleteObject(BoardOverlay)
    RenderHandle = nil
	InProgress = false
end)

function LoadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(0)
    end
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

function LoadScale(scalef)
	local handle = RequestScaleformMovie(scalef)
    while not HasScaleformMovieLoaded(handle) do
        Wait(0)
    end
	return handle
end

function CreateRenderModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end
	return handle
end