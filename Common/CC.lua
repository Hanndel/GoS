function IsCCable(Unit)
	NoCCables = {}
	local CCable = GetNetworkID(Unit)

	if NoCCables[GetNetworkID(Unit)] ~= CCable then
		return true
	end
end

OnUpdateBuff(function(Object,buffProc)
	if GetNetWorkID(Object) == CCable then
		if buffProc.Type == 4 or buffProc.Type == 15 or buffProc.Type == 17 then
			table.insert(NoCCables, GetNetworkID(Object))
		end
	end
end)

OnRemoveBuff(function(Object,buffProc)
	if GetNetWorkID(Object) == CCable then
		if buffProc.Type == 4 or buffProc.Type == 15 or buffProc.Type == 17 then
			table.remove(NoCCables, GetNetworkID(Object))
		end
	end
end)
