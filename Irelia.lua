if GetObjectName(GetMyHero()) ~= "Irelia" then return end

require('Inspired')
require('OpenPredict')

local IreliaM = MenuConfig("Irelia", "Irelia")

local Ignite = nil
	if GetCastName(myHero, 5) == "summonerdot" or GetCastName(myHero, 6) == "summonerdot" then
		Ignite = true
	end


IreliaM:Menu("C","Combo")
IreliaM.C:Boolean("Q", "Use Q", true)
IreliaM.C:Boolean("W", "Use W", true)
IreliaM.C:DropDown("E", "Use E", 1, {"Always", "Stun", "Off"})
IreliaM.C:Boolean("R", "Use R", true)
IreliaM.C:Boolean("GP", "Gapcloser Q-E", true)
IreliaM.C:Boolean("H", "Use Hydra/Tia...", true)
IreliaM.C:Slider("HP", "HP to spam ult", 50, 1, 100)

IreliaM:Menu("LC", "LaneClear")
IreliaM.LC:Boolean("Q", "Use Q", true)
IreliaM.LC:Boolean("W", "Use W", true)
IreliaM.LC:Boolean("E", "Use E", true)
IreliaM.LC:Boolean("R", "Use R", true)
IreliaM.LC:Boolean("H", "Use Hydra/Tia...", true)
IreliaM.LC:Slider("MP", "MP Manager", 50, 1, 1000)

IreliaM:Menu("JC", "JunglerClear")
IreliaM.JC:Boolean("Q", "Use Q", true)
IreliaM.JC:Boolean("W", "Use W", true)
IreliaM.JC:Boolean("E", "Use E", true)
IreliaM.JC:Boolean("H", "Use Hydra/Tia...", true)
IreliaM.JC:Slider("MP", "MP Manager", 50, 1, 1000)

IreliaM:Menu("KS", "Kill Steal")
IreliaM.KS:Boolean("Q", "Use Q", true)
IreliaM.KS:Boolean("E", "Use E", true)
IreliaM.KS:Boolean("R", "Use R", true)
if Ignite ~= nil then
IreliaM.KS:Boolean("IG", "Use Ignite", true)
end

IreliaM:Menu("HC", "Hit chance")
IreliaM.HC:Slider("R", "R Predict", 20, 1, 100)

IreliaM:Menu("M", "Misc")
IreliaM.M:DropDown("AL", "Auto LvL", 1, {"W-E-Q", "W-Q-E", "Off"})

IreliaM:Menu("D", "Draws")
IreliaM.D:DropDown("Sk", "SkinChanger", 1, {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostbutt", "Lotus"})
IreliaM.D:Boolean("Q", "Q Range", true)
IreliaM.D:Boolean("E", "E Range", true)
IreliaM.D:Boolean("R", "R Range", true)
IreliaM.D:Slider("HQ", "Circles Quality", 4, 1, 8)
LoadIOW()

local WBuff = false
local WEndBuff = 0
local trinity = false
local target = GetCurrentTarget()
local R = {delay = 0.250, speed = 1700, width = 25, range = 1000}

OnDraw(function(myHero)
	if IreliaM.D.Sk:Value() ~= 1 then
    	HeroSkinChanger(GetMyHero(), IreliaM.D.Sk:Value()-1)
    elseif IreliaM.D.Sk:Value() == 1 then
    	HeroSkinChanger(GetMyHero(), 0)
    end
    if IreliaM.D.Q:Value() then
    	DrawCircle(GetOrigin(myHero), 650, 1, IreliaM.D.HQ:Value(), GoS.Blue)
    end
    if IreliaM.D.E:Value() then
    	DrawCircle(GetOrigin(myHero), 200, 1, IreliaM.D.HQ:Value(), GoS.Red)
    end
    if IreliaM.D.R:Value() then
    	DrawCircle(GetOrigin(myHero), 1000, 1, IreliaM.D.HQ:Value(), GoS.Yellow)
    end
end)

OnTick(function(myHero)
	local WTimer = WEndBuff - GetGameTimer()
	if IOW:Mode() == "Combo" then 
		if IsReady(_Q) and IsReady(_E) and IreliaM.C.GP:Value() then
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) ~= GetTeam(myHero) and GetDistance(mob, target) < 425 and (GetCurrentHP(mob) < OpDmg("Q", mob) or GetCurrentHP(mob) < OpDmg("Q", mob) + OpDmg("W") and WBuff and WTimer > 0) then
					CastTargetSpell(mob, _Q)
						DelayAction(function() CastTargetSpell(target, _E) end, 0.1)
				end
			end
		end

		if IsReady(_Q) and ValidTarget(target, 650) and IreliaM.C.Q:Value() and  WBuff and WTimer < 1 then
			CastTargetSpell(target, _Q)

		elseif  IsReady(_Q) and (not IsReady(_E) or IreliaM.C.E:Value() ~= 3) and IreliaM.C.Q:Value() and ValidTarget(target, 650) and GetDistance(target) > 425 then
			CastTargetSpell(target, _Q)
		end

		if IsReady(_W) and ValidTarget(target, 425) and IreliaM.C.W:Value() then
			CastSpell(_W)
		end

		if IsReady(_E) and ValidTarget(target, 425) and IreliaM.C.E:Value() ~= 3 and GetDistance(target) > GetRange(myHero) then
			CastTargetSpell(target, _E)
		end
		local Trinity = GetItemSlot(myHero, 3078)
		local Sheen = GetItemSlot(myHero, 3057)
		if IsReady(_R) and (Trinity > 0 and IsReady(Trinity) or Sheen > 0 and IsReady(Sheen) and not trinity) and ValidTarget(target, GetRange(myHero)) and GetPercentHP(myHero) > IreliaM.C.HP:Value() then
			local pI = GetPrediction(target, R)
			if pI and pI.hitChance >= (IreliaM.HC.R:Value())/100 then
				CastSkillShot(_R, pI.castPos)
			end

		elseif IsReady(_R) and ValidTarget(target, GetRange(myHero)) and (GetPercentHP(myHero) < IreliaM.C.HP:Value() or not Trinity > 0 and not Sheen > 0)  then
			local pI = GetPrediction(target, R)
			if pI and pI.hitChance >= (IreliaM.HC.R:Value())/100 then
				CastSkillShot(_R, pI.castPos)
			end
		end
	end

	if IOW:Mode() == "LaneClear" then
		for _, mob in pairs(minionManager.objects) do
			if GetTeam(mob) == MINION_ENEMY and GetPercentMP(myHero) > IreliaM.LC.MP:Value() then
				if IsReady(_Q) and ValidTarget(mob, 650) and IreliaM.LC.Q:Value() and GetCurrentHP(mob) <= OpDmg("Q", mob) then
					CastTargetSpell(mob, _Q)

				elseif IsReady(_Q) and ValidTarget(mob, 650) and IreliaM.LC.Q:Value() and GetCurrentHP(mob) <= OpDmg("Q", mob) + OpDmg("W") and WBuff and WTimer > 0 then
					CastTargetSpell(mob, _Q)
				end

				if IsReady(_W) and ValidTarget(mob, 200) and IreliaM.LC.W:Value() then 
					CastSpell(_W)
				end

				if IsReady(_R) and ValidTarget(mob, 1000) and IreliaM.LC.R:Value() then
					local pI = GetPrediction(mob, R)
					if pI and pI.hitChance >= (IreliaM.HC.R:Value())/100 then
						CastSkillShot(_R, pI.castPos)
					end
				end
			end

			if GetTeam(mob) == MINION_JUNGLE and GetPercentMP(myHero) > IreliaM.JC.MP:Value() then
				if IsReady(_Q) and ValidTarget(mob, 650) and IreliaM.JC.Q:Value() and GetCurrentHP(mob) <= OpDmg("Q", mob) then
					CastTargetSpell(mob, _Q)

				elseif IsReady(_Q) and ValidTarget(mob, 650) and IreliaM.JC.Q:Value() and GetCurrentHP(mob) <= OpDmg("Q", mob) + OpDmg("W") and WBuff and WTimer > 0 then
					CastTargetSpell(mob, _Q)

				elseif IsReady(_Q) and ValidTarget(mob, 650) and IreliaM.JC.Q:Value() and WBuff and WTimer < 0.5 then
					CastTargetSpell(mob, _Q)
				end

				if IsReady(_W) and ValidTarget(mob, 200) and IreliaM.JC.W:Value() then 
					CastSpell(_W)
				end
			end
		end
	end
	if IreliaM.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) >= 1 then
			if IreliaM.M.AL:Value() == 1 then Deftlevel = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			elseif IreliaM.M.AL:Value() == 2 then Deftlevel = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(1, 2)) --kappa
		end
	end 

	for _, enemy in pairs(GetEnemyHeroes()) do
		if IreliaM.KS.Q:Value() and IsReady(_Q) and ValidTarget(enemy, 650) and GetCurrentHP(enemy) < OpDmg("Q", enemy) then
			CastTargetSpell(enemy, _Q)

		elseif IreliaM.KS.Q:Value() and IsReady(_Q) and IsReady(_W) and ValidTarget(enemy, 650) and GetCurrentHP(enemy) < OpDmg("Q", enemy) + OpDmg("W") then
			CastSpell(_W)
				DelayAction(function() CastTargetSpell(enemy, _Q)end, 0.1)

		elseif IreliaM.KS.Q:Value() and IsReady(_Q) and ValidTarget(enemy, 650) and WBuff and GetCurrentHP(enemy) < OpDmg("Q", enemy) + OpDmg("W") then
			CastTargetSpell(enemy, _Q)

		elseif IreliaM.KS.Q:Value() and IreliaM.KS.E:Value() and IsReady(_Q) and IsReady(_E) and ValidTarget(enemy, 425) and WBuff and GetCurrentHP(enemy) < OpDmg("Q", enemy) + OpDmg("W") + OpDmg("E", enemy) then
			CastTargetSpell(enemy, _E)
				DelayAction(function() CastTargetSpell(enemy, _Q)end, 0.3)

		elseif IreliaM.KS.Q:Value() and IreliaM.KS.E:Value() and IsReady(_Q) and IsReady(_E) and ValidTarget(enemy, 425) and GetCurrentHP(enemy) < OpDmg("Q", enemy) + OpDmg("E", enemy) then
			CastTargetSpell(enemy, _E)
				DelayAction(function() CastTargetSpell(enemy, _Q)end, 0.3)
		end

		if IreliaM.KS.E:Value() and IsReady(_E) and ValidTarget(enemy, 425) and GetCurrentHP(enemy) < OpDmg("E", enemy) then
			CastTargetSpell(enemy, _E)
		end

		if IreliaM.KS.R:Value() and IsReady(_R) and ValidTarget(enemy, 425) and GetCurrentHP(enemy) < OpDmg("R", enemy) then
			local pI = GetPrediction(enemy, R)
			if pI and pI.hitChance >= (IreliaM.HC.R:Value())/100 then
				CastSkillShot(_R, pI.castPos)
			end	
		end

		if IsReady(5) and GetCastName(myHero, 5) == "summonerdot" and IreliaM.KS.IG:Value() and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*5 < OpDmg("IG") then
			CastTargetSpell(enemy, 5)
		elseif IsReady(6) and GetCastName(myHero, 6) == "summonerdot" and IreliaM.KS.IG:Value() and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*5 < OpDmg("IG") then
			CastTargetSpell(enemy, 5)
		end
	end
end)


OnProcessSpellComplete(function(unit, spell)
	if unit == myHero then
		if IOW:Mode() == "Combo" then
			if spell.name:lower():find("attack") then
				if IsReady(_E) and ValidTarget(target, 425) and IreliaM.C.E:Value() == 2 and GetPercentHP(myHero) < GetPercentHP(target) then
					CastTargetSpell(target, _E)
				elseif IsReady(_E) and ValidTarget(target, 425) and IreliaM.C.E:Value() == 1 then
					CastTargetSpell(target, _E)
				end

				local Titannic = GetItemSlot(myHero, 3748)
				if not IsReady(_E) and ValidTarget(target, 200) and Titannic > 0 and IsReady(Titannic) and Irelia.C.H:Value() then
					CastSpell(Titannic)
				end
			end

			local Tiamat = GetItemSlot(myHero, 3077) 
			local Hydra = GetItemSlot(myHero, 3074)
			if spell.name == "IreliaEquilibriumStrike" and Tiamat > 0 and IsReady(Tiamat) and Irelia.C.H:Value() then
				CastSpell(Tiamat)
			elseif spell.name == "IreliaEquilibriumStrike" and Hydra > 0 and IsReady(Hydra) and Irelia.C.H:Value() then
				CastSpell(Hydra)
			end
		end

		if IOW:Mode() == "LaneClear" then
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_ENEMY then
					if spell.name:lower():find("attack") then
						if IsReady(_E) and ValidTarget(mob, 425) and IreliaM.LC.E:Value() then
							CastTargetSpell(mob, _E)
						end
					end

					local Titannic = GetItemSlot(myHero, 3748)
					if not IsReady(_E) and ValidTarget(target, 200) and Titannic > 0 and IsReady(Titannic) and Irelia.LC.H:Value() then
						CastSpell(Titannic)
					end

					local Tiamat = GetItemSlot(myHero, 3077) 
					local Hydra = GetItemSlot(myHero, 3074)
					if spell.name == "IreliaEquilibriumStrike" and Tiamat > 0 and IsReady(Tiamat) and Irelia.LC.H:Value() then
						CastSpell(Tiamat)
					elseif spell.name == "IreliaEquilibriumStrike" and Hydra > 0 and IsReady(Hydra) and Irelia.LC.H:Value() then
						CastSpell(Hydra)
					end
				end

				if GetTeam(mob) == MINION_JUNGLE then
					if spell.name:lower():find("attack") then
						if IsReady(_E) and ValidTarget(mob, 425) and IreliaM.JC.E:Value() then
							CastTargetSpell(mob, _E)
						end
					end

					local Titannic = GetItemSlot(myHero, 3748)
					if not IsReady(_E) and ValidTarget(target, 200) and Titannic > 0 and IsReady(Titannic) and Irelia.JC.H:Value() then
						CastSpell(Titannic)
					end

					local Tiamat = GetItemSlot(myHero, 3077) 
					local Hydra = GetItemSlot(myHero, 3074)
					if spell.name == "IreliaEquilibriumStrike" and Tiamat > 0 and IsReady(Tiamat) and Irelia.JC.H:Value() then
						CastSpell(Tiamat)
					elseif spell.name == "IreliaEquilibriumStrike" and Hydra > 0 and IsReady(Hydra) and Irelia.JC.H:Value() then
						CastSpell(Hydra)
					end
				end
			end
		end
	end
end)

OnUpdateBuff(function(Object,buffProc)
	if Object == myHero then
		if buffProc.Name == "ireliahitenstylecharged" then
			WEndBuff = buffProc.ExpireTime
			WBuff = true
		end

		if buffProc.Name == "sheen" then
			trinity = true
		end
	end
end)

OnRemoveBuff(function(Object,buffProc)
	if Object == myHero then
		if buffProc.Name == "ireliahitenstylecharged" then
			WBuff = false
		end

		if buffProc.Name == "sheen" then
			trinity = false
		end
	end
end)

function OpDmg(Slot, Unit)
	local Unit = Unit or nil
	local APdmg = 0
	local ADdmg = 0
	local Truedmg = 0

	if Slot = "IG" then 
		Truedmg =50+GetLevel(myHero)*20
	elseif Slot = "Q" then
		ADdmg = 20+GetCastLevel(myHero, _Q)*30-30 + (GetBonusDmg(myHero) + GetBaseDamage(myHero))
	elseif Slot = "W" then
		Truedmg = 15*GetCastLevel(myHero, _W)
	elseif Slot = "E" then
		APdmg = 30+GetCastLevel(myHero, _E)*50 + GetBonusAP(myHero)*0.5
	elseif Slot = "R" then
		ADdmg = 40+GetCastLevel(myHero, _R)*40 + GetBonusAP(myHero)*0.5 + GetBonusDmg(myHero)*0.6)
	end
	return CalcDamage(myHero, Unit, ADdmg, APdmg) + Truedmg
end	
