RegisterCommand('ping', function(source, args, rawCommand)
	if args[1] ~= nil then
        if args[1]:lower() == 'accept' then
            TriggerClientEvent('qb_ping:client:AcceptPing', source)
        elseif args[1]:lower() == 'reject' then
            TriggerClientEvent('qb_ping:client:RejectPing', source)
        else
            local tSrc = tonumber(args[1])
            if source ~= tSrc then
                TriggerClientEvent('qb_ping:client:SendPing', tSrc, GetPlayerName(tSrc), source)
            else
                TriggerClientEvent('QBCore:Notify', source, "You cannot ping yourself", "error")
            end
        end
    end
end, false)

RegisterServerEvent('qb_ping:server:SendPingResult')
AddEventHandler('qb_ping:server:SendPingResult', function(id, result)
	if result == 'accept' then
		TriggerClientEvent('QBCore:Notify', "Your ping has been accepted", "success")
	elseif result == 'reject' then
		TriggerClientEvent('QBCore:Notify', "Your ping has been rejected", "error")
	elseif result == 'timeout' then
		TriggerClientEvent('QBCore:Notify', "Your ping was not accepted in time", "error")
	elseif result == 'unable' then
		TriggerClientEvent('QBCore:Notify', "They were unable to recive your ping", "error")
	elseif result == 'received' then
		TriggerClientEvent('QBCore:Notify', "You sent out a ping", "success")
	end
end)