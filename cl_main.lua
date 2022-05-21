-- QBCore 
local QBCore = exports['qb-core']:GetSharedObject()

local pendingPing = nil
local isPending = false

function AddBlip(bData)
    pendingPing.blip = AddBlipForCoord(bData.x, bData.y, bData.z)
    SetBlipSprite(pendingPing.blip, bData.id)
    SetBlipAsShortRange(pendingPing.blip, true)
    SetBlipScale(pendingPing.blip, bData.scale)
    SetBlipColour(pendingPing.blip, bData.color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(bData.name)
    EndTextCommandSetBlipName(pendingPing.blip)
    SetBlipFlashes(pendingPing.blip, true)

    pendingPing.count = 0
end

function TimeoutBlip()
    Citizen.CreateThread(function()
        while pendingPing ~= nil do
            if pendingPing.count ~= nil then
                if pendingPing.count >= Config.BlipDuration then
                    RemoveBlip(pendingPing.blip)
                    pendingPing = nil
                else
                    pendingPing.count = pendingPing.count + 1
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

RegisterNetEvent('qb_ping:client:SendPing')
AddEventHandler('qb_ping:client:SendPing', function(sender, senderId)
    if pendingPing == nil then
        pendingPing = {}
        pendingPing.id = senderId
        pendingPing.name = sender

        TriggerServerEvent('qb_ping:server:SendPingResult', pendingPing.id, 'received')
        QBCore.Functions.Notify('You have been sent a ping to accept do /ping accept', 'success',5000)

        Citizen.CreateThread(function()
            isPending = true
            local count = 0
            while isPending do
                count = count + 1
                if count >= Config.Timeout and isPending then
                    QBCore.Functions.Notify('Ping Timed Out', 'error',5000)
                    TriggerServerEvent('qb_ping:server:SendPingResult', pendingPing.id, 'timeout')
                    pendingPing = nil
                    isPending = false
                end
                Citizen.Wait(1000)
            end
        end)
    else
        QBCore.Functions.Notify('Someone attempted to ping you', 'ping',5000)
        TriggerServerEvent('qb_ping:server:SendPingResult', senderId, 'unable')
    end
end)

RegisterNetEvent('qb_ping:client:AcceptPing')
AddEventHandler('qb_ping:client:AcceptPing', function()
    if isPending then
        local pos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(pendingPing.id)), false)
        local playerBlip = { name = pendingPing.name, color = Config.BlipColor, id = Config.BlipIcon, scale = Config.BlipScale, x = pos.x, y = pos.y, z = pos.z }
        AddBlip(playerBlip)
        TimeoutBlip()
        QBCore.Functions.Notify('Their location has been displayed on your GPS', 'success',5000)
        TriggerServerEvent('qb_ping:server:SendPingResult', pendingPing.id, 'accept')
        isPending = false
    else
        QBCore.Functions.Notify('You have no pending pings', 'error',5000)
    end
end)

RegisterNetEvent('qb_ping:client:RejectPing')
AddEventHandler('qb_ping:client:RejectPing', function()
    if pendingPing ~= nil then
        QBCore.Functions.Notify('Rejected ping', 'error',5000)
        TriggerServerEvent('qb_ping:server:SendPingResult', pendingPing.id, 'reject')
        pendingPing = nil
        isPending = false
    else
        QBCore.Functions.Notify('You have no pending pings', 'error',5000)
    end
end)

RegisterNetEvent('qb_ping:client:RemovePing')
AddEventHandler('qb_ping:client:RemovePing', function()
    if pendingPing ~= nil then
        RemoveBlip(pendingPing.blip)
        pendingPing = nil
        QBCore.Functions.Notify('Player ping removed', 'error',5000)
    else
        QBCore.Functions.Notify('You have no player ping', 'error',5000)
    end
end)

Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/ping [Paypal]", "Ping their location");
    TriggerEvent("chat:addSuggestion", "/ping reject", "Reject ping");
    TriggerEvent("chat:addSuggestion", "/ping accept","Accept ping");
    end)
