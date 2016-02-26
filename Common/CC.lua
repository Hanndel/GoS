function IsCCable(Unit)
	local CCable = GetNetworkID(Unit)

	if NoCCables[GetNetworkID(Unit)] ~= CCable then
		return true
	end
end

Buffs = {4, 15, 17}
NoCCables = {}
OnUpdateBuff(function(Object,buffProc)
	for i, buff in pairs(Buffs)
		if GetNetWorkID(Object) == CCable then
			if buffProc.Type == buff  then
				table.insert(NoCCables, GetNetworkID(Object))
			end
		end
	end
end)

OnRemoveBuff(function(Object,buffProc)
	for i, buff in pairs(Buffs)
		if GetNetWorkID(Object) == CCable then
			if buffProc.Type == buff  then
				table.remove(NoCCables, GetNetworkID(Object))
			end
		end
	end
end)
