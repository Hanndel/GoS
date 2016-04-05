if GetObjectName(GetMyHero()) ~= "Zyra" then return end

require("Inspired")
require("OpenPredict")

local ZyraM = MenuConfig("Zyra", "Zyra")

ZyraM:Menu("C", "Combo")
ZyraM.C:Boolean("Q", "Use Q", true)
ZyraM.C:Boolean("W", "Use W", true)
ZyraM.C:Boolean("E", "Use E", true)
ZyraM.C:Boolean("R", "Use R", true)
ZyraM.C:Slider("ER", "Enemies to R", 3, 0, 5)
ZyraM.C:Boolean("P", "Use Passive", true)
ZyraM.C:Slider("HP", "%Hp to ignore seeds", 20, 1, 100)

ZyraM:Menu("LC", "LaneClear")
ZyraM.LC:Boolean("Q", "Use Q", true)
ZyraM.LC:Boolean("E", "Use E", true)

ZyraM:Menu("KS", "Kill Steal")
ZyraM.KS:Boolean("Q", "Use Q", true)
ZyraM.KS:Boolean("E", "Use E", true)
if Ignite ~= nil then
ZyraM.KS:Boolean("IG", "Use Ignite", true)
end

ZyraM:Menu("HC", "Hit chance")
ZyraM.HC:Slider("Q", "Q Predict", 20, 1, 100)
ZyraM.HC:Slider("E", "E Predict", 20, 1, 100)
ZyraM.HC:Slider("R", "R Predict", 20, 1, 100)
ZyraM.HC:Slider("P", "P Predict", 20, 1, 100)

ZyraM:Menu("D", "Draw")
ZyraM.D:Boolean("Q", "Draw Q", true)
ZyraM.D:Boolean("E", "Draw E", true)
ZyraM.D:Boolean("R", "Draw R", true)
ZyraM.D:Boolean("P", "Draw P", true)
ZyraM.D:Slider("HQ", "Quality", 4, 1, 8)

ZyraM:Menu("M", "Misc")
ZyraM.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})
ZyraM.M:DropDown("S", "Skin", 1, {"Classic", "Wildire", "Haunted", "Skt", "Off"})

local P = { delay = 0.5, speed = 1900, width = 70, range = 1500 }
local Q = { delay = 0.7, speed = math.huge, width = 70, range = 800, radius = 220 }
local E = { delay = 0.25, speed = 1150, width = 70, range = 1100 }
local R = { delay = 1, speed = math.huge, width = 500, range = 700, radius = 500 }

local EPoint = nil
local ECast = false
local QCast = false
local PTest = TargetSelector(1400, TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
local QTest = TargetSelector(800, TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
local ETest = TargetSelector(1100, TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
local RTest = TargetSelector(700, TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
local Rip = false

OnDraw(function(myHero)

	if ZyraM.M.S:Value() ~= 5 then 
		HeroSkinChanger(myHero, ZyraM.M.S:Value() - 1)
	elseif ZyraM.M.S:Value() == 5 then
		HeroSkinChanger(myHero, 0)
	end

	if ZyraM.D.Q:Value() then
		DrawCircle(GetOrigin(myHero), 800, 1, ZyraM.D.HQ:Value(), GoS.Pink)
	end

	if ZyraM.D.E:Value() then
		DrawCircle(GetOrigin(myHero), 1100, 1, ZyraM.D.HQ:Value(), GoS.Red)
	end

	if ZyraM.D.R:Value() then
		DrawCircle(GetOrigin(myHero), 1100, 1, ZyraM.D.HQ:Value(), GoS.Blue)
	end

	if ZyraM.D.P:Value() then
		DrawCircle(GetOrigin(myHero), 1475, 1, ZyraM.D.HQ:Value(), GoS.Yellow)
	end
end)

OnTick(function(myHero)
	local PTarget = QTest:GetTarget()
	local QTarget = QTest:GetTarget()
	local ETarget =	ETest:GetTarget()
	local RTarget = RTest:GetTarget()
	local target = GetCurrentTarget()

	if IOW:Mode() == "Combo" then
		if IsReady(_Q) and not ECast and ZyraM.C.Q:Value() then
			local pI = GetCircularAOEPrediction(QTarget, Q)
			if pI and pI.hitChance >= (ZyraM.HC.Q:Value())/100 then
				CastSkillShot(_Q, pI.castPos)
			end
		end

		if IsReady(_E) --[[and (not IsReady(_Q) or ZyraM.C.Q:Value() == false)]] and not QCast and ZyraM.C.E:Value() then
			local pI = GetPrediction(ETarget, E)
			if pI and pI.hitChance >= (ZyraM.HC.E:Value())/100 then
				CastSkillShot(_E, pI.castPos)
			end
		end

		if IsReady(_R) and ZyraM.C.R:Value() then
			local pI = GetCircularAOEPrediction(RTarget, R)
			if pI and pI.hitChance >= (ZyraM.HC.R:Value())/100 and EnemiesAround(pI.castPos, 500) >= ZyraM.C.ER:Value() then
				CastSkillShot(_R, pI.castPos)
			end
		end
	end

	for _, enemy in pairs(GetEnemyHeroes()) do
		if not IsDead(enemy) then
			if ZyraM.KS.Q:Value() and IsReady(_Q) and ValidTarget(enemy, 800) and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < CalcDamage(myHero, enemy, 0, 35+GetCastLevel(myHero, _Q)*35+GetBonusAP(myHero)*0.65) then
				local pI = GetCircularAOEPrediction(enemy, Q)
				if pI and pI.hitChance >= (ZyraM.HC.Q:Value())/100 then
					CastSkillShot(_Q, pI.castPos)
				end
			end

			if ZyraM.KS.E:Value() and IsReady(_E)  and ValidTarget(enemy, 1100) and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < CalcDamage(myHero, enemy, 0, 25+GetCastLevel(myHero, _E)*35+GetBonusAP(myHero)*0.50) then
				local pI = GetPrediction(enemy, E)
				if pI and pI.hitChance >= (ZyraM.HC.E:Value())/100 then
					CastSkillShot(_E, pI.castPos)
				end
			end

			if ZyraM.KS.Q:Value() and IsReady(_Q) and ValidTarget(enemy, 800) and IsReady(_E) and ZyraM.KS.E:Value() and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < CalcDamage(myHero, enemy, 0, 35+GetCastLevel(myHero, _Q)*35+GetBonusAP(myHero)*0.65 + 25+GetCastLevel(myHero, _E)*35+GetBonusAP(myHero)*0.50) then
				local pE = GetPrediction(enemy, E)
				local pQ = GetCircularAOEPrediction(enemy, Q)
				if pE and pQ and pQ.hitChance >= (ZyraM.HC.Q:Value())/100 and pE.hitChance >= (ZyraM.HC.E:Value())/100 then
					CastSkillShot(_E, pE.castPos)
						DelayAction(function() CastSkillShot(_Q, pQ.castPos) end, GetDistance(enemy)/1150+0.5)
				end
			end

			if Ignite ~= nil then
				if IsReady(Ignite) and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*5 <= 50+GetLevel(myHero)*20 then
					CastTargetSpell(enemy, Ignite)
				end
			end

			if Rip and IsReady(_Q) and ValidTarget(enemy, 1400) and GetCurrentHP(enemy) <= 80+20*GetLevel(myHero) and ZyraM.C.P:Value() then
				local pI = GetPrediction(enemy, P)
				if pI and pI.hitChance >= (ZyraM.HC.P:Value())/100 then
					CastSkillShot(_Q, pI.castPos)
			end
		end
	end

	if Rip and IsReady(_Q) and ValidTarget(PTarget, 1400) and ZyraM.C.P:Value() then
		local pI = GetPrediction(PTarget, R)
		if pI and pI.hitChance >= (ZyraM.HC.P:Value())/100 then
			CastSkillShot(_Q, pI.castPos)
		end
	end

	if IOW:Mode() == "LaneClear" then
		for _, mob in pairs(minionManager.objects) do
			if GetTeam(mob) == MINION_ENEMY then
				if ValidTarget(mob, 1100) and not QCast and IsReady(_E) and ZyraM.LC.E:Value() then
					CastSkillShot(_E, GetOrigin(mob))
				end

				if ValidTarget(mob, 800) and not ECast and IsReady(_Q) and ZyraM.LC.Q:Value() then
					CastSkillShot(_Q, GetOrigin(mob))
				end
			end

			if GetTeam(mob) == MINION_JUNGLE then
				if ValidTarget(mob, 1100) and not QCast and IsReady(_E) and ZyraM.LC.E:Value() then
					CastSkillShot(_E, GetOrigin(mob))
				end

				if ValidTarget(mob, 800) and not ECast and IsReady(_Q) and ZyraM.LC.Q:Value() then
					CastSkillShot(_Q, GetOrigin(mob))
				end
			end
		end
	end

	if ZyraM.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) == 1 then
			if ZyraM.M.AL:Value() == 1 then Deftlevel = { _Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W }
			elseif ZyraM.M.AL:Value() == 2 then Deftlevel = { _E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W }
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(0.5, 2)) --kappa
		end
	end 
end)

OnProcessSpell(function(Object,spellProc)
	local ETarget =	ETest:GetTarget()
	local target = GetCurrentTarget
	if Object == myHero then
		if spellProc.name == "ZyraQFissure" and IsReady(_W) and ZyraM.C.W:Value() and GetPercentHP(myHero) >= ZyraM.C.HP:Value() then
			CastSkillShot(_W, spelProc.endPos)
				QCast = true
				DelayAction(function()QCast = false end, 1)
		end

		if spellProc.name == "ZyraGraspingRoots" and IsReady(_W) and ZyraM.C.W:Value() and GetPercentHP(myHero) >= ZyraM.C.HP:Value()then
			if GetDistance(ETarget) > 800 or not ValidTarget(ETarget, 800) then
				EPoint = GetOrigin(myHero) + Vector(spellProc.endPos - spellProc.startPos):normalized()*750+math.random(0,50)
			elseif GetDistance(ETarget) < 800 then
				EPoint = GetOrigin(myHero) + Vector(Vector(spellProc.endPos) - Vector(spellProc.startPos)):normalized()*GetDistance(ETarget)
			end
			CastSkillShot(_W, EPoint)
				ECast = true
				DelayAction(function()ECast = false end, 1.5)
		end
	end
end)

OnUpdateBuff(function(Object,buffProc)
	if Object == myHero and buffProc.Name == "zyrapqueenofthorns" then
		Rip = true
	end
end)

OnRemoveBuff(function(Object,buffProc)
	if Object == myHero and buffProc.Name == "zyrapqueenofthorns" then
		Rip = false
	end
end)

AddGapcloseEvent(_E, 1100)

PrintChat("By Hanndel, Have Fun!")
