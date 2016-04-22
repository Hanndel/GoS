local Output = io.open(SCRIPT_PATH.."PositionsXYZ.txt", "a+")


local TablePos = {}--Positions here, separe them as a normal table :nod:

function GetPos(pos)
	if pos then
		local PosX = pos.x 
		local PosY = pos.y
		local PosZ = pos.z
		Output:write(string.format("Pos X: %s,Pos Y: %s, PosZ: %s", PosX, PosY, PosZ),"\n")
		Output:write("\n")
	end
end


OnWndMsg(function(msg, wParam)
	if msg == 513 then
		for k, i in pairs(TablePos) do
			GetPos(i)
		end
		print("writing "..#TablePos.." positions, please, wait")
	end
end)
