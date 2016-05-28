if GetObjectName(myHero) ~= "Jhin" then return end
require "OpenPredict"

local Combo = false
local target = nil
local W = {speed = 5000, width = 40, range = 2250, delay = 0.750}

local MainMenu = MenuConfig("Jhin", "Jhin")

MainMenu:DropDown("C", "Choose ur combo", 1 ,{"aa-q-w-e", "aa-w-e-q"})

OnTick(function(myHero)
	if target ~= nil then
		if Combo then
			if MainMenu.C:Value() == 1 then
				if Ready(0) and ValidTarget(target, 550) then
					CastTargetSpell(target, 0)
				end

				if not Ready(0) and Ready(1) and ValidTarget(target, 2500) then
					local WPred = GetPrediction(target, W)
					if WPred and WPred.hitChance*100 > 20 then
						CastSkillShot(1, WPred)
					end
				end

				if not Ready(0) and not Ready(1) and Ready(2) and ValidTarget(target, 750) then
					CastSkillShot(2, GetOrigin(target))
				end
			elseif MainMenu.C:Value() == 2 then
				if Ready(1) and ValidTarget(target, 2500) then
					local WPred = GetPrediction(target, W)
					if WPred and WPred.hitChance*100 > 20 then
						CastSkillShot(1, WPred)
					end
				end

				if not Ready(1) and Ready(2) and ValidTarget(target, 750) then
					CastSkillShot(2, GetOrigin(target))
				end	

				if not Ready(1) and not Ready(2) and Ready(0) and ValidTarget(target, 550) then
					CastTargetSpell(target, 0)
				end
			end
		else
			if Ready(1) and ValidTarget(target, 2500) then
				local WPred = GetPrediction(target, W)
				if WPred and WPred.hitChance*100 > 20 then
					CastSkillShot(1, WPred)
				end
			end
		end

		if not Ready(0) and not Ready(1) and not Ready(2) then
			target = nil
		end
	end

	if target == nil then
		Combo = false
	end
	print(Combo)
	print(target)
end)

OnProcessSpellComplete(function(unit, spell)
	if unit == myHero and spell.name:lower():find("attack") then
		Combo = true
	end
end)

OnWndMsg(function(msg,wParam)
	if msg == 516 then
		for k, v in ipairs(GetEnemyHeroes()) do
			if GetDistance(GetMousePos(), v) < 100 then
				target = v
				if GetDistance(v) <= GetRange(myHero) then
					AttackUnit(v)
				end
			else
				if target ~= nil then
					target = nil
				end
			end
		end
	end
end)
