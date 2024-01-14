
local scaleform = RequestScaleformMovie("DIGISCANNER")
local inScaleform = false
local ped = PlayerPedId()
local targetCoords = vector3(0,0,0)
local params = {}
local sfpos = {
    x = 0.1,
    y = 0.24,
    width = 0.21,
    height = 0.51,
}
local wait, blip
local sfcolors = {
    red = {r = 255, g = 10, b = 10},
    yellow = {r = 255, g = 209, b = 67},
    lightblue = {r = 67, g = 200, b = 255},
    green = {r = 0, g = 255, b = 80}

}

local function ScaleformMethod(sf, name, data)
    BeginScaleformMovieMethod(sf, name)
        for _,v in ipairs(data or {}) do
            if name == "SET_DISTANCE" then
                PushScaleformMovieMethodParameterFloat(v)
            else
                PushScaleformMovieMethodParameterInt(v)
            end
        end
    PopScaleformMovieFunctionVoid()
end

local sfbars = {
    {dist = 500, bars = 30.0, wait = 7000},
    {dist = 400, bars = 40.0, wait = 6000},
    {dist = 300, bars = 50.0, wait = 5000},
    {dist = 150, bars = 60.0, wait = 4000},
    {dist = 80, bars = 70.0, wait = 3000},
    {dist = 40, bars = 80.0, wait = 2000},
    {dist = 10, bars = 90.0, wait = 1000},
    {dist = 0, bars = 100.0, wait = 500},
}

local function SetScaleformColor(bar, dot)
    if not inScaleform then return end
    ScaleformMethod(scaleform, "SET_COLOUR", {bar.r,bar.g,bar.b,dot.r,dot.g,dot.b})
end

local function Flashing(dat)
    if dat == true then
        ScaleformMethod(scaleform, "flashOn")
    else
        ScaleformMethod(scaleform, "flashOff")
    end
end

local function TriggerEvents()
    inScaleform = false
    local params = params
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
    if params.event then
        if params.isServer then
            TriggerServerEvent(params.event, params.args)
        elseif params.isCommand then
            ExecuteCommand(params.event)
        elseif params.isAction then
            params.event(params.args)
        else
            TriggerEvent(params.event, params.args)
        end
    end

end


local function SetupScaleform(scaleformRequest, Buttons)
    scaleform = RequestScaleformMovie(scaleformRequest)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)
    for i = 1,#Buttons do
        PushScaleformMovieFunction(scaleform, Buttons[i].type)
        if Buttons[i].int then PushScaleformMovieFunctionParameterInt(Buttons[i].int) end
        if Buttons[i].keyIndex then
                for _, v in pairs(Buttons[i].keyIndex) do
                    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, v, true))
                end
        end
        if Buttons[i].name then
            BeginTextCommandScaleformString("STRING")
            AddTextComponentScaleform(Buttons[i].name)
            EndTextCommandScaleformString()
        end
        if Buttons[i].type == 'SET_BACKGROUND_COLOUR' then
            for u = 1,4 do
                PushScaleformMovieFunctionParameterInt(80)
            end
        end
        PopScaleformMovieFunctionVoid()
    end
    return scaleform
end

local form = nil
local function UpdateBars(dist)
    if not scaleform then return end
    
    for i=1, #sfbars do
        if dist > sfbars[i].dist then
            wait = sfbars[i].wait
            ScaleformMethod(scaleform, "SET_DISTANCE", {sfbars[i].bars})
            break
        end
    end

    if dist < 2.0 then
        wait = 250
        SetScaleformColor(sfcolors.green, sfcolors.green)
        Flashing(true)
        if IsControlJustPressed(0, params.interact.interactKey) then
            TriggerEvents()
        end
        DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
    end
end

local function HeadingCheck(playerCoords, playerHeading, targetCoordsToCheck)
    local x = targetCoordsToCheck.x - playerCoords.x
    local y = targetCoordsToCheck.y - playerCoords.y

    local targetHeading = GetHeadingFromVector_2d(x, y)
    return math.abs(playerHeading - targetHeading) < 20
end

CreateThread(function ()
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
end)

local function InitiateDigiScanner()
    ped = PlayerPedId()
    if not inScaleform then
        inScaleform = true
        local data = 0
        local playerCoords = GetEntityCoords(ped)
        local playerHeading = GetEntityHeading(ped)
        local dist = #(playerCoords - targetCoords)
        if HeadingCheck(playerCoords, playerHeading, targetCoords) then
            SetScaleformColor(sfcolors.lightblue, sfcolors.yellow)
        else
            SetScaleformColor(sfcolors.red, sfcolors.red)
        end

        UpdateBars(dist)
        inScaleform = true
        if not IsNamedRendertargetRegistered('digiscanner') then
            RegisterNamedRendertarget('digiscanner', 0)
        end
        LinkNamedRendertarget(GetWeapontypeModel(joaat('weapon_digiscanner')))

        if IsNamedRendertargetRegistered('digiscanner') then
            data = GetNamedRendertargetRenderId('digiscanner')
        end

        

        while inScaleform do
            SetTextRenderId(data)
            DrawScaleformMovie(scaleform, sfpos.x, sfpos.y, sfpos.width, sfpos.height, 100, 100, 100, 255, 0)
            SetTextRenderId(1)

            if IsPlayerFreeAiming(PlayerId()) then
                playerCoords = GetEntityCoords(ped)
                playerHeading = GetEntityHeading(ped)
                
                if HeadingCheck(playerCoords, playerHeading, targetCoords) then
                    SetScaleformColor(sfcolors.lightblue, sfcolors.yellow)
                else
                    SetScaleformColor(sfcolors.red, sfcolors.red)
                end

                dist = #(playerCoords - targetCoords)

                UpdateBars(dist)
            end

            if inScaleform == false then
                break
            end
            Wait(1)
        end
    else
        inScaleform = false
        EndScaleformMovieMethodReturn()
    end
end

CreateThread(function()
    local sleep = 1000
    while true do
        if inScaleform then
            if GetSelectedPedWeapon(ped) == joaat('weapon_digiscanner') then   
                if IsPlayerFreeAiming(PlayerId()) then
                    local c = GetEntityCoords(ped)
                    PlaySoundFromCoord(-1, "IDLE_BEEP", c.x,c.y,c.z, 'EPSILONISM_04_SOUNDSET', true, 5.0, false)
                end
                Wait(wait)
                sleep = 0
            else
                sleep = 5000
            end
            
        end
        Wait(sleep)

    end
end)

local function SetupDigiScanner(vector3, parameters)
    params = {}
    if vector3 and parameters then
        if not parameters.interact then
            parameters.interact = {
                interactMessage = "Interact",
                interactKey = 38,
            }
        end
        form = SetupScaleform("instructional_buttons", {
            {type = "CLEAR_ALL"},
            {type = "SET_CLEAR_SPACE", int = 200},
            {type = "SET_DATA_SLOT", name = parameters.interact.interactMessage, keyIndex = {parameters.interact.interactKey}, int = 0},
            {type = "DRAW_INSTRUCTIONAL_BUTTONS"},
            {type = "SET_BACKGROUND_COLOUR"},
        })
        params = parameters
        targetCoords = vector3
        if parameters.blip then
            blip = AddBlipForCoord(vector3)
            SetBlipSprite(blip, parameters.blip.sprite)
            SetBlipDisplay(blip, parameters.blip.display)
            if parameters.blip.scale then
                SetBlipScale(blip, parameters.blip.scale)
            end
            SetBlipColour(blip, parameters.blip.color)
            if parameters.blip.opacity then
                SetBlipAlpha(blip, parameters.blip.opacity)
            end
            if parameters.blip.text then
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(parameters.blip.text)
                EndTextCommandSetBlipName(blip)
            end
        end
        InitiateDigiScanner()
    else
        print('these variables must be defined.')
    end
end

exports('SetupDigiScanner', SetupDigiScanner)

local function DoAPrint(args)
    print('Good Job Pengu! '..args['bin'])
end

RegisterCommand('tsf', function ()
    exports['pengu_digiscanner']:SetupDigiScanner(vector3(331.2, -1490.94, 29.27), {
        event = DoAPrint,
        isAction = true,
        args = {['bin'] = 'lol'},
        blip = {
            text = "Surprise Location",
            sprite = 9,
            display = 2,
            scale = 0.7,
            color = 2,
            opacity = 65,
        },
        interact = {
            interactKey = 38,
            interactMessage = 'View Print',
        }
    })
end)
