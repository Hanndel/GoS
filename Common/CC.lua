function IsCCable(Unit)
	if NoCCables[GetNetworkID(Unit)] ~= GetNetworkID(Unit) then
		return true
	end
end

NoCCables = {}
Buffs = {4, 15, 17}

OnUpdateBuff(function(Object,buffProc) 
	if Buffs[buffProc.Type] ~= Buffs then
		table.insert(NoCCables, GetNetworkID(Object))
	end
end)

OnRemoveBuff(function(Object,buffProc)
	if Buffs[buffProc.Type] ~= Buffs  then
		table.remove(NoCCables, GetNetworkID(Object))
	end
end)
