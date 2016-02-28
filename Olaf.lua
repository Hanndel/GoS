if GetObjectName(GetMyHero()) ~= "Olaf" then return end

require("Inspired")
require("OpenPredict")

local OlafM = MenuConfig("Olaf", "Olaf")

OlafM:Menu("C", "Combo")
OlafM.C:Boolean("Q", "Use Q", true)
OlafM.C:Boolean("W", "Use W", true)
OlafM.C:Boolean("E", "Use E", true)
OlafM.C:Boolean("R", "Use R", true)
OlafM.C:Slider("CQ", "Catch Q if <", 200, 100, 1000)
OlafM.C:Slider("RA", "R if enemies >=" 2, 1, 5)

OlafM:Menu("LC", "LaneClear")
OlafM.LC:Boolean("Q", "Use Q", true)
OlafM.LC:Boolean("W", "Use W", true)
OlafM.LC:Boolean("E", "Use E", true)

OlafM:Menu("JC", "JunglerClear")
OlafM.JC:Boolean("Q", "Use Q", true)
OlafM.JC:Boolean("W", "Use W", true)
OlafM.JC:Boolean("E", "Use E", true)

OlafM:Menu("KS", "Kill Steal")
OlafM.KS:Boolean("Q", "Use Q", true)
OlafM.KS:Boolean("E", "Use E", true)
if Ignite ~= nil then
OlafM.KS:Boolean("IG", "Use Ignite", true)
end

OlafM:Menu("HC", "Hit chance")
OlafM.HC:Slider("Q", "Q Predict", 20, 1, 100)

OlafM:Menu("D", "Draw")
OlafM.D:Boolean("Q", "Draw Q", true)
OlafM.D:Boolean("E", "Draw E", true)
OlafM.D:Boolean("R", "Draw R", true)
OlafM.D:Boolean("P", "Draw P", true)
OlafM.D:Slider("HQ", "Quality", 4, 1, 8)

OlafM:Menu("M", "Misc")
OlafM.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})

local Q = { delay = 0.25, speed = 1600, width = 90, range = 1000 }
local Fucked = false

OnTick(function(myHero)
	local target = GetCurrentTarget()
	if not IsDead(myHero) then
		Combo(target)
		Ks()
		LaneClear()
		PickUp()
		AutoR()
		AutoLvL()
	end
end)

function Combo(Unit)
	if IOW:Mode() == "Combo" then
		if ValidTarget(Unit, 1000) and IsReady(_Q) and OlafM.C.Q:Value() then
			local pI = GetPrediction(Unit, Q)
			if pI and pI.hitChance >= (OlafM.HC.Q:Value())/100 then
				CastSkillShot(_Q, pI.castPos)
			end
		end

		if ValidTarget(Unit, 325) and IsReady(_E) and OlafM.C.E:Value() then
			CastTargetSpell(Unit, _E)
		end

		if ValidTarget(Unit, 500) and IsReady(_W) and OlafM.C.W:Value() then
			CastSpell(_W)
		end
	end
end

function Ks()
	for _, Enemies in pairs(GetEnemyHeroes()) do
		if ValidTarget(Enemies, 375) and IsReady(_Q) and IsReady(_E) and OlafM.KS.Q:Value() and OlafM.KS.E:Value() and GetCurrentHP(Enemies) < CalcDamage(myHero, Enemies, 45+GetCastLevel(myHero, _Q)*45 + GetBonusDmg(myHero), 0) + 45+GetCastLevel(myHero, _E)*45+(GetBonusDmg(myHero) + GetBaseDamage(myHero)*0.40) then
			CastSkillShot(_Q, GetOrigin(Enemies))
				DelayAction(function() CastTargetSpell(Enemies, _E) end, GetDistance(Enemies)/1600)
		end

		if ValidTarget(Enemies, 1000) and IsReady(_Q) and GetCurrentHP(Enemies) < CalcDamage(myHero, Enemies, 45+GetCastLevel(myHero, _Q)*45 + GetBonusDmg(myHero), 0) then
			local pI = GetPrediction(Enemies, Q)
			if pI and pI.hitChance >= (OlafM.HC.Q:Value())/100 then
				CastSkillShot(_Q, pI.castPos)
			end
		end

		if ValidTarget(Enemies, 325) and IsReady(_E) and OlafM.KS.E:Value() and GetCurrentHP(Enemies) < 45+GetCastLevel(myHero, _E)*45+(GetBonusDmg(myHero) + GetBaseDamage(myHero)*0.40) then
			CastTargetSpell(Enemies, _E)
		end

		if Ignite ~= nil then
			if IsReady(Ignite) and OlafM.KS.IG:Value() and ValidTarget(Enemies, 500) and GetCurrentHP(Enemies)+GetHPRegen(Enemies)*5 <= 50+GetLevel(myHero)*20 then
				CastTargetSpell(Enemies, Ignite)
			end
		end
	end
end

names = {"SRU_Gromp", "SRU_Blue", "SRU_Murkwolf", "SRU_Razorbeak", "SRU_Red", "SRU_Krug", "Sru_Crab"}

function LaneClear()
	if IOW:Mode() == "LaneClear" then
		for _, mob in pairs(minionManager.objects) do
			if GetTeam(mob) == MINION_ENEMY then
				if ValidTarget(mob, 1000) and IsReady(_Q) and OlafM.LC.Q:Value() then
					local pI = GetPrediction(mob, Q)
					if pI and pI.hitChance >= (OlafM.HC.Q:Value())/100 then
						CastSkillShot(_Q, pI.castPos)
					end
				end
				if ValidTarget(mob, GetRange(myHero)) and IsReady(_W) and OlafM.LC.W:Value() and GetPercentHP(myHero) < 50 then
					CastSpell(_W)
				end

				if ValidTarget(mob, 375) and IsReady(_E) and OlafM.LC.E:Value() and GetPercentHP(myHero) > 50 then
					CastTargetSpell(_E)
				end
			end

			if GetTeam(mob) == MINION_JUNGLE then
				for _, Drei in pairs(names) do
					if not IsDead(mob) and GetObjectName(mob) == Drei and GetCurrentHP(mob) >  CalcDamage(myHero, Enemies, 45+GetCastLevel(myHero, _Q)*45 + GetBonusDmg(myHero), 0) + 45+GetCastLevel(myHero, _E)*45+(GetBonusDmg(myHero) + GetBaseDamage(myHero)*0.40) then
						if ValidTarget(mob, 1000) and IsReady(_Q) and OlafM.JC.Q:Value() then
						local pI = GetPrediction(mob, Q)
							if pI and pI.hitChance >= (OlafM.HC.Q:Value())/100 then
								CastSkillShot(_Q, pI.castPos)
							end
						end
				
						if ValidTarget(mob, GetRange(myHero)) and OlafM.JC.W:Value() and IsReady(_W) then
							CastSpell(_W)
						end

						if ValidTarget(mob, 375) and IsReady(_E) and OlafM.JC.E:Value() then
							CastTargetSpell(_E)
						end
					end
				end
			end
		end
	end
end

Axes = {}

function PickUp()
	if not IOW.isWindingUp then
		for _, kappa in pairs(Axes) do
			local Axe = GetOrigin(kappa)
			if IOW:Mode() == "Combo" or IOW:Mode() == "LaneClear" then
				if GetDistance(Axe) < OlafM.C.CQ:Value() then
						IOW.forcePos = Axe
					else
						IOW.forcePos = nil
				end
	        else
	        	IOW.forcePos = nil
	        end
		end
	end
end

function AutoLvL()
	if OlafM.M.AL:Value() ~= 3 then 
  		if GetLevelPoints(myHero) >= 1 then
 			if OlafM.M.AL:Value() == 1 then Deftlevel = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif OlafM.M.AL:Value() == 2 then Deftlevel = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
    		end 
  			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500, 2000))
  		end 
  	end
end

function AutoR()
	if Fucked and IsReady(_R) and EnemiesAround(myHero, 1000) >= OlafM.C.RA:Value()
		CastSpell(_R)
	elseif GetPercentHP(myHero) < 30 and IsReady(_R) then
		CastSpell(_R)
	end
end

OnUpdateBuff(function(Object, buffProc)
	if Object == myHero and buffProc.Type == 5 or buffProc.Type == 9 or buffProc.Type == 5 then
		Fucked = true
	end
end)

OnRemoveBuff(function(Object, buffProc)
	if Object == myHero and buffProc.Type == 5 or buffProc.Type == 9 or buffProc.Type == 5 then
		Fucked = false
	end
end)

OnCreateObj(function(Object)
	if GetObjectBaseName(Object) == "olaf_axe_trigger.troy"  then
		table.insert(Axes, Object)
	end
end)

OnDeleteObj(function(Object)
	if GetObjectBaseName(Object) == "olaf_axe_trigger.troy" then
		table.remove(Axes, 1)
	end
end)

PrintChat("By Hanndel, "..GetObjectName(GetMyHero())" Loaded!")
