local Output = io.open(SCRIPT_PATH.."PositionsXYZ.txt", "a+")

function GetPos()
		local PosX = myHero.pos.x 
		local PosY = myHero.pos.y
		local PosZ = myHero.pos.z
		local MPosX = GetMousePos().x 
		local MPosY = GetMousePos().y
		local MPosZ = GetMousePos().z
	Output:write(string.format("myHero Pos X: %s, myHero Pos Y: %s, myHero Pos Z: %s", PosX, PosY, PosZ),"\n")
	Output:write(string.format("Mouse Pos X: %s, Mouse Pos Y: %s, Mouse Pos Z: %s", MPosX, MPosY, MPosZ),"\n")	
	Output:write("\n")
end


OnWndMsg(function(msg, wParam)
	if msg == 513 then
		GetPos()
		print"writing positions, please, wait"
		print"done!, press F6x2"
	end
end)
