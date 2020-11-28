function PlayUrl(name_, url_, volume_, loop_, options)
    if disableMusic then return end
    local volume = GetProfileSetting(306) / 10 * volume_
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = 0,
        y = 0,
        z = 0,
        dynamic = false,
        volume = volume,
        loop = loop_ or false,
    })

    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end

    soundInfo[name_].volume = volume
    soundInfo[name_].url = url_
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
    soundInfo[name_].isDynamic = false

    globalOptionsCache[name_] = options or { }
end

exports('PlayUrl', PlayUrl)

function PlayUrlPos(name_, url_, volume_, pos, loop_, options)
    if disableMusic then return end
    local volume = GetProfileSetting(306) / 10 * volume_
    SendNUIMessage({
        status = "url",
        name = name_,
        url = url_,
        x = pos.x,
        y = pos.y,
        z = pos.z,
        dynamic = true,
        volume = volume,
        loop = loop_ or false,
    })
    if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end

    soundInfo[name_].volume = volume
    soundInfo[name_].url = url_
    soundInfo[name_].position = pos
    soundInfo[name_].id = name_
    soundInfo[name_].playing = true
    soundInfo[name_].loop = loop_ or false
    soundInfo[name_].isDynamic = true

    globalOptionsCache[name_] = options or { }
end

exports('PlayUrlPos', PlayUrlPos)

function PlayUrlEntity(name_, url_, volume_, nt, loop_, options)
    if disableMusic then return end
    if soundInfo[name_] then
        for i=1,#soundInfo[name_].entitys,1 do
            if soundInfo[name_].entitys[i] == nt then
                return
            end
        end
        table.insert(soundInfo[name_].entitys,nt)
        soundInfo[name_].timeoutsent[nt] = 10000
    else
        local ntentity = nt
        local entity = -1
        local pos = vector3(0,0,-200)
        if NetworkDoesNetworkIdExist(ntentity) then
            entity = NetworkGetEntityFromNetworkId(ntentity)
            if DoesEntityExist(entity) then
                pos = GetEntityCoords(entity)
            end
        end
        local volume = GetProfileSetting(306) / 10 * volume_
        if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
        if soundInfo[name_].entitys == nil then soundInfo[name_].entitys = {}; table.insert(soundInfo[name_].entitys,nt) end
        soundInfo[name_].volume = volume
        soundInfo[name_].url = url_
        soundInfo[name_].position = pos
        soundInfo[name_].timeoutsent = {}
        soundInfo[name_].timeoutsent[nt] = 10000
        soundInfo[name_].id = name_
        soundInfo[name_].playing = true
        soundInfo[name_].loop = loop_ or false
        soundInfo[name_].isDynamic = true
        SendNUIMessage({
            status = "url",
            name = name_,
            url = url_,
            x = pos.x,
            y = pos.y,
            z = pos.z,
            dynamic = true,
            volume = volume,
            loop = loop_ or false,
        })
        globalOptionsCache[name_] = options or { }
        Citizen.CreateThread(function()
            local name = name_
            while true do
                Citizen.Wait(100)
                if soundInfo[name] == nil then
                    break
                end
                local plusproche = { dist = 100, pos = nil }
                local ppos = GetEntityCoords(GetPlayerPed(-1))
                for i=1,#soundInfo[name].entitys,1 do
                    local ntentity = soundInfo[name].entitys[i]
                    local entity = -1
                    if NetworkDoesNetworkIdExist(ntentity) then
                        entity = NetworkGetEntityFromNetworkId(ntentity)
                        if DoesEntityExist(entity) then
                            local pos = GetEntityCoords(entity)
                            local dist = GetDistanceBetweenCoords(pos, ppos, true)
                            if dist < plusproche.dist then
                                plusproche.dist = dist
                                plusproche.pos = pos
                            end
                        end
                    end
                end
                if plusproche.pos then
                    SendNUIMessage({
                        status = "soundPosition",
                        name = name,
                        x = plusproche.pos.x,
                        y = plusproche.pos.y,
                        z = plusproche.pos.z,
                    })
                    soundInfo[name].position = plusproche.pos
                    soundInfo[name].id = name
                else
                    for k,v in pairs(soundInfo[name].timeoutsent) do
                        soundInfo[name].timeoutsent[k] = soundInfo[name].timeoutsent[k]-1
                        if v <= 0 then
                            for i=1,#soundInfo[name].entitys,1 do
                                if soundInfo[name].entitys[i] == k then
                                    table.remove(soundInfo[name].entitys, i)
                                    soundInfo[name].timeoutsent[k] = nil
                                    break
                                end
                            end
                        end
                    end
                    if next(soundInfo[name].entitys) == nil then
                        soundInfo[name] = nil
                        break
                        break
                    end
                end
            end
        end)
    end
end

exports('PlayUrlEntity', PlayUrlEntity)

function TextToSpeechEntity(name_, lang_, text_, nt_, volume_, loop_, options_)
    if disableMusic then return end
    local name,lang,text,nt,volume,loop,options = name_, lang_, text_, nt_, volume_, loop_, options_
    
    -- Citizen.CreateThread(function()
        -- Citizen.Wait(0)
        -- while true do
            -- local url = string.format("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s&total=1&idx=0&client=tw-ob", text_, lang_)
            -- local created = false
            -- local timeout = 30
            -- local entity = NetworkGetEntityFromNetworkId(tonumber(nt))
            -- if DoesEntityExist(entity) then
                -- local pos = GetEntityCoords(entity)
                -- if soundInfo[name] == nil and not created then
                    -- local volume_ = GetProfileSetting(306) / 10 * volume
                    -- PlayUrlPos(name, url, volume_, pos, loop, options)
                    -- created = true
                    -- Citizen.Wait(50)
                -- else
                    -- Citizen.Wait(50)
                    -- SendNUIMessage({
                        -- status = "soundPosition",
                        -- name = name,
                        -- x = pos.x,
                        -- y = pos.y,
                        -- z = pos.z,
                    -- })
                    -- soundInfo[name].position = pos
                    -- soundInfo[name].id = name
                -- end
            -- else
                -- Citizen.Wait(1000)
                -- timeout = timeout - 1
                -- if (soundInfo[name] == nil and created) or timeout < 0 then
                    -- soundInfo[name_] = nil
                    -- break
                -- end
            -- end
        -- end
    -- end)
    
    local url = string.format("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s&total=1&idx=0&client=tw-ob", text_, lang_)
    if soundInfo[name_] then
        for i=1,#soundInfo[name_].entitys,1 do
            if soundInfo[name_].entitys[i] == nt then
                return
            end
        end
        table.insert(soundInfo[name_].entitys,nt)
        soundInfo[name_].timeoutsent[nt] = 10000
    else
        local ntentity = nt
        local entity = -1
        if NetworkDoesNetworkIdExist(ntentity) then
            entity = NetworkGetEntityFromNetworkId(ntentity)
        end
        local pos = vector3(0,0,-200)
        if DoesEntityExist(entity) then
            pos = GetEntityCoords(entity)
        end
        local volume = GetProfileSetting(306) / 10 * volume_
        if soundInfo[name_] == nil then soundInfo[name_] = getDefaultInfo() end
        if soundInfo[name_].entitys == nil then soundInfo[name_].entitys = {}; table.insert(soundInfo[name_].entitys,nt) end
        soundInfo[name_].volume = volume
        soundInfo[name_].url = url
        soundInfo[name_].position = pos
        soundInfo[name_].timeoutsent = {}
        soundInfo[name_].timeoutsent[nt] = 10000
        soundInfo[name_].id = name_
        soundInfo[name_].playing = true
        soundInfo[name_].loop = loop_ or false
        soundInfo[name_].isDynamic = true
        SendNUIMessage({
            status = "url",
            name = name_,
            url = url,
            x = pos.x,
            y = pos.y,
            z = pos.z,
            dynamic = true,
            volume = volume,
            loop = loop_ or false,
        })
        globalOptionsCache[name_] = options or { }
        Citizen.CreateThread(function()
            local name = name_
            while true do
                Citizen.Wait(100)
                if soundInfo[name] == nil then
                    break
                end
                local plusproche = { dist = 100, pos = nil }
                local ppos = GetEntityCoords(GetPlayerPed(-1))
                for i=1,#soundInfo[name].entitys,1 do
                    local ntentity = soundInfo[name].entitys[i]
                    local entity = -1
                    if NetworkDoesNetworkIdExist(ntentity) then
                        entity = NetworkGetEntityFromNetworkId(ntentity)
                    end
                    if DoesEntityExist(entity) then
                        local pos = GetEntityCoords(entity)
                        local dist = GetDistanceBetweenCoords(pos, ppos, true)
                        if dist < plusproche.dist then
                            plusproche.dist = dist
                            plusproche.pos = pos
                        end
                    else
                    end
                end
                if plusproche.pos then
                    SendNUIMessage({
                        status = "soundPosition",
                        name = name,
                        x = plusproche.pos.x,
                        y = plusproche.pos.y,
                        z = plusproche.pos.z,
                    })
                    soundInfo[name].position = plusproche.pos
                    soundInfo[name].id = name
                else
                    for k,v in pairs(soundInfo[name].timeoutsent) do
                        soundInfo[name].timeoutsent[k] = soundInfo[name].timeoutsent[k]-1
                        if v <= 0 then
                            for i=1,#soundInfo[name].entitys,1 do
                                if soundInfo[name].entitys[i] == k then
                                    table.remove(soundInfo[name].entitys, i)
                                    soundInfo[name].timeoutsent[k] = nil
                                    break
                                end
                            end
                        end
                    end
                    if next(soundInfo[name].entitys) == nil then
                        soundInfo[name] = nil
                        break
                        break
                    end
                end
            end
        end)
    end
end

exports('TextToSpeechEntity', TextToSpeechEntity)

function TextToSpeech(name_, lang, text, volume_, loop_, options)
    if disableMusic then return end
    local url = string.format("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s&total=1&idx=0&client=tw-ob", text, lang)
    local volume = GetProfileSetting(306) / 10 * volume_
    PlayUrl(name_, url, volume, loop_, options)
end

exports('TextToSpeech', TextToSpeech)

function TextToSpeechPos(name_, lang, text, volume_, pos, loop_, options)
    if disableMusic then return end
    local url = string.format("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s&total=1&idx=0&client=tw-ob", text, lang)
    local volume = GetProfileSetting(306) / 10 * volume_
    PlayUrlPos(name_, url, volume, pos, loop_, options)
end

exports('TextToSpeechPos', TextToSpeechPos)
