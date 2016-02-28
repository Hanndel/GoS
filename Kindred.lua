if GetObjectName(GetMyHero()) ~="Kindred" then return end

require('Inspired')
require('MapPositionGOS')
local KindredM = MenuConfig("Kindred", "Kindred")

KindredM:Menu("Combo", "Combo")
KindredM.Combo:Boolean("Q", "Use Q", true)
KindredM.Combo:Boolean("W", "Use W", true)
KindredM.Combo:Boolean("E", "Use E", true)
KindredM.Combo:Boolean("QE", "Gapcloser", true)

KindredM:Menu("JunglerClear", "JunglerClear")
KindredM.JunglerClear:Boolean("Q", "Use Q", true)
KindredM.JunglerClear:Boolean("W", "Use W", true)
KindredM.JunglerClear:Boolean("E", "Use E", true)

KindredM:Menu("LaneClear", "LaneClear")
KindredM.LaneClear:Boolean("Q", "Use Q", true)
KindredM.LaneClear:Boolean("W", "Use W", true)
KindredM.LaneClear:Boolean("E", "Use E", true)

KindredM:Menu("Misc", "Misc")
KindredM.Misc:DropDown("AL", "Priority", 1, {"Q-E-W","Q-E-W lv3 E","Q-W-E","Q-W-E lv3 E", "Off"})
KindredM.Misc:Boolean("B", "Buy Farsight", true)
KindredM.Misc:KeyBinding("FQ", "Flash-Q", string.byte("T"))
KindredM.Misc:Key("WP", "Jumps", string.byte("G"))

KindredM:Menu("Items", "Items Usage")
KindredM.Items:Boolean("Botrk", "Use Botrk", true)
KindredM.Items:Slider("BotrkS", "%Hp to use", 50, 1, 100)
KindredM.Items:Boolean("Youmu", "Use Youmu", true)
KindredM.Items:Boolean("Bilge", "Use Bilgewater", true)

KindredM:Menu("ROptions", "R Options")
KindredM.ROptions:Boolean("R", "Use R", true)
KindredM.ROptions:Slider("UR", "Enemies >=", 2, 1, 5)

KindredM:Menu("QOptions", "Q Options")
KindredM.QOptions:Boolean("QC", "AA reset Combo", true)
KindredM.QOptions:Boolean("QL", "AA reset LaneClear", true)
KindredM.QOptions:Boolean("QJ", "AA reset JunglerClear", true)
KindredM.QOptions:Boolean("C", "Cancel animation?", false)

KindredM:Menu("Draw", "Draw")
KindredM.Draw:DropDown("S", "Select skin", 1, {"Classic", "ShadowFire", "Off"})
KindredM.Draw:Boolean("Q", "Draw Q", true)
KindredM.Draw:Boolean("W", "Draw W", true)
KindredM.Draw:Boolean("E", "Draw E", true)
KindredM.Draw:Boolean("R", "Draw R", true)
KindredM.Draw:Slider("HQ", "Circles Quality", 4, 1, 8)
LoadIOW()


local basePos = Vector(0,0,0)
if GetTeam(myHero) == 100 then
	basePos = Vector(415,182,415)
else
	basePos = Vector(14302,172,14387.8)
end
local Recalling = false
local Farsight = false 

names = {"SRU_Gromp", "SRU_Blue", "SRU_Murkwolf", "SRU_Razorbeak", "SRU_Red", "SRU_Krug", "Sru_Crab"}

OnDraw(function(myHero)

	if KindredM.Draw.S:Value() ~= 3 then		
		HeroSkinChanger(myHero, KindredM.Draw.S:Value() - 1)
	elseif KindredM.Draw.S:Value() == 3 then		
		HeroSkinChanger(myHero, 0)
	end
	if KindredM.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), 340, 1, KindredM.Draw.HQ:Value(), GoS.Blue)
		--DrawCircle(Vector3D, radius, width, quality, color)
	end
	if KindredM.Draw.W:Value() and IsReady(_W) then
		DrawCircle(GetOrigin(myHero), 950, 1, KindredM.Draw.HQ:Value(), GoS.Black)
	end
	if KindredM.Draw.E:Value() and IsReady(_E) then
		DrawCircle(GetOrigin(myHero), 500, 1, KindredM.Draw.HQ:Value(), GoS.Green)
	end
	if KindredM.Draw.R:Value() and IsReady(_R) then
		DrawCircle(GetOrigin(myHero), 500, 1, KindredM.Draw.HQ:Value(), GoS.Yellow)
	end
end)


OnTick(function(myHero)
	
local target = GetCurrentTarget()
local AfterQ = GetOrigin(myHero) +(Vector(GetMousePos()) - GetOrigin(myHero)):normalized()*340
	if KindredM.Misc.FQ:Value() then
		if IsReady(_Q) and IsReady(Flash) and KindredM.Combo.Q:Value() then  
			CastSkillShot(Flash, GetMousePos()) 
				DelayAction(function() CastSkillShot(_Q, GetMousePos()) end, 1)					  
		end
	end

	if IOW:Mode() == "Combo" then  
		if IsReady(_E) and IsReady(_Q) and KindredM.Combo.QE:Value() and GetDistance(target) > 500 and GetDistance(AfterQ, target) <= 450 then
			IOW.attacksEnabled = false
			CastSkillShot(_Q, GetMousePos())
				DelayAction(function() CastTargetSpell(target, _E) end, 1)
			IOW.attacksEnabled = true
		end
		if IsReady(_Q) and KindredM.Combo.Q:Value() and ValidTarget(target, 500) and KindredM.QOptions.QC:Value() == false or (GetDistance(target) > 500 and GetDistance(AfterQ, target) <= 450)  then
    		CastSkillShot(_Q, GetMousePos()) 
		end
		if IsReady(_W) and KindredM.Combo.W:Value() and ValidTarget(target, 800) then 
			CastSpell(_W)
		end
		if IsReady(_E) and KindredM.Combo.E:Value() and ValidTarget(target, 500) then 
			CastTargetSpell(target, _E)
		end
		if GetItemSlot(myHero,3142) > 0 and KindredM.Items.Youmu:Value() and ValidTarget(target, 1000) and IsReady(GetItemSlot(myHero,3142)) then
			CastSpell(GetItemSlot(myHero,3142))
		end
		if GetItemSlot(myHero,3144) > 0 and KindredM.Items.Bilge:Value() and ValidTarget(target, 550) and IsReady(GetItemSlot(myHero,3144)) then
			CastTargetSpell(target, GetItemSlot(myHero,3144))
		end
		if GetItemSlot(myHero,3153) > 0 and KindredM.Items.Botrk:Value() and ValidTarget(target, 550) and GetPercentHP(myHero) < KindredM.Items.Botrk:Value() and IsReady(GetItemSlot(myHero,3153)) then
			CastTargetSpell(target, GetItemSlot(myHero,3153))
		end

	end 

	if IOW:Mode() == "LaneClear" then 
		for _, mob in pairs(minionManager.objects) do	
			if GetTeam(mob) == MINION_JUNGLE then
				if KindredM.QOptions.QJ:Value() == false and IsReady(_Q) and KindredM.LaneClear.Q:Value() and ValidTarget(mob, 500) then 
					CastSkillShot(_Q, GetMousePos())
				end
				for _, Drei in pairs(names) do
					if not IsDead(mob) and GetObjectName(mob) == Drei and GetCurrentHP(mob) > CalcDamage(myHero, mob, (GetBaseDamage(myHero) + GetBonusDmg(myHero))*2, 0) + CalcDamage(myHero, mob, 30+GetCastLevel(myHero, _Q)*30+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20, 0) then 
						if IsReady(_W) and ValidTarget(mob, 800) and IsTargetable(mob) and KindredM.JunglerClear.W:Value() then 
    						CastSpell(_W)
    					end
    					if IsReady(_E) and ValidTarget(mob, 500) and KindredM.JunglerClear.E:Value() then 
    						CastTargetSpell(mob, _E)
	    				end
	    			end
    			end
			end 
			if GetTeam(mob) == MINION_ENEMY then
				if KindredM.QOptions.QL:Value() == false and IsReady(_Q) and KindredM.LaneClear.Q:Value() and ValidTarget(mob, 500)then 
					CastSkillShot(_Q, GetMousePos())
				end
				if IsReady(_W) and ValidTarget(mob, 800) and KindredM.LaneClear.W:Value() then 
					CastSpell(_W)
				end
				if IsReady(_E) and ValidTarget(mob, 500) and KindredM.LaneClear.E:Value() then 
					CastTargetSpell(mob, _E)
				end 
		    end 
		end 
	end

	if KindredM.ROptions.R:Value() and not Recalling and not IsDead(myHero) and IsReady(_R) then
		for _, allie in pairs(GetAllyHeroes()) do
			if not IsDead(allie) and GetPercentHP(allie) <= 20 and EnemiesAround(GetOrigin(allie), 1000) >= KindredM.ROptions.UR:Value() and not IsDead(allie) then
				if GetDistance(allie) <= 400 then
					CastTargetSpell(allie, _R)		
				elseif GetDistance(allie) <= 500  then
					CastTargetSpell(myHero, _R)
				end
			end	
		end
		if GetPercentHP(myHero) <= 20  and EnemiesAround(GetOrigin(myHero), 1000) >= KindredM.ROptions.UR:Value() then
			CastTargetSpell(myHero, _R)
		end

	end

	if KindredM.Misc.AL:Value() ~= 5 then 
  		if GetLevelPoints(myHero) >= 1 then
 			if KindredM.Misc.AL:Value() == 1 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif KindredM.Misc.AL:Value() == 3 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
 			elseif KindredM.Misc.AL:Value() == 2 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif KindredM.Misc.AL:Value() == 4 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    		end 
  			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500, 2000))
  		end 
  	end

	if KindredM.Misc.B:Value() then
		if not Farsight and GetLevel(myHero) >= 9 and GetDistance(myHero,basePos) < 550 then
			BuyItem(3363)
			Farsight = true
		end
	end

	if KindredM.Misc.WP:Value() then
		if WallBetween(GetOrigin(myHero), GetMousePos(),  340) then
			CastSkillShot(_Q, GetMousePos())
		end
	end
end)

OnProcessSpellComplete(function(unit, spell)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			if IOW:Mode() == "LaneClear" then 
				for _, mob in pairs(minionManager.objects) do	
					if KindredM.QOptions.QL:Value() then
						if GetTeam(mob) == MINION_ENEMY then 
							if IsReady(_Q) and KindredM.LaneClear.Q:Value() and ValidTarget(mob, 500) then 
								CastSkillShot(_Q, GetMousePos())
							end
						end
					end

					if KindredM.QOptions.QJ:Value() then
						if GetTeam(mob) == MINION_JUNGLE then
							if IsReady(_Q) and KindredM.JunglerClear.Q:Value() and ValidTarget(mob, 500) then 
								CastSkillShot(_Q, GetMousePos()) 
							end
						end
					end
				end
			end

			if KindredM.QOptions.QC:Value() then
				if IOW:Mode() == "Combo" then
					if IsReady(_Q) and  KindredM.Combo.Q:Value() then 
    					CastSkillShot(_Q, GetMousePos()) 
					end
				end
			end
		end
	end
end)

OnProcessSpell(function(unit, spell)
	if unit == myHero and spell.name == "KindredQ" and KindredM.QOptions.C:Value() then
		DelayAction(function() CastEmote(EMOTE_DANCE) end, 0.1)
	end
end)

OnUpdateBuff(function(unit,buff)
	if unit == myHero and buff.Name == "recall" or buff.Name == "OdinRecall" then
		Recalling = true
	end
end)

OnRemoveBuff(function(unit,buff)
	if unit == myHero and buff.Name == "recall" or buff.Name == "OdinRecall" then
		Recalling = false
	end
end)

function WallBetween(p1, p2, distance) --p1 and p2 are Vectors3d

	local Check = p1 + (Vector(p2) - p1):normalized()*distance/2
	local Checkdistance = p1 +(Vector(p2) - p1):normalized()*distance
	
	if MapPosition:inWall(Check) and not MapPosition:inWall(Checkdistance) then
		return true
	end
end

PrintChat("By Hanndel, Have Fun!")
