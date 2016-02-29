function IsCCable(Unit)
	if NoCCables[GetNetworkID(Unit)] ~= GetNetworkID(Unit) then
		return true
	end
end

local Buffs = {}
Buffs[4] = true
Buffs[15] = true
Buffs[17] = true
local NoCCables = {}

OnUpdateBuff(function(Object,buffProc)
	if Buffs[buffProc.type] then
		table.insert(NoCCables, GetNetworkID(Object))
	end
end)

OnRemoveBuff(function(Object,buffProc)
	if Buffs[buffProc.type] then
		table.remove(NoCCables, GetNetworkID(Object))
	end
end)
