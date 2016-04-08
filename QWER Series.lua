require "OpenPredict"

local ChampTable =
	{
	["Kindred"] = true,
	["Zyra"] = true,
	}

Callback.Add("Load", function()
	if ChampTable[GetObjectName(myHero)] then
		_G[GetObjectName(myHero)]()
	else
		PrintChat(GetObjectName(myHero).." Is not supported!")
	end
	if GetObjectName(myHero) == "Kindred" then
		require('MapPositionGOS')
	end
	Start()
end)

local ver = "0.1"

class "Start"

function Start:__init()
	PrintChat("Welcome "..GetUser().." to QWER Series!")
	PrintChat(GetObjectName(myHero).." Loaded!")
	function AutoUpdate(data)
    	if tonumber(data) > tonumber(ver) then
        	PrintChat("New version found! " .. data)
        	PrintChat("Downloading update, please wait...")
        	DownloadFileAsync("https://raw.githubusercontent.com/Hanndel/GoS/master/QWER%20Series.lua", SCRIPT_PATH .. "QWER Series.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
   		else
        	PrintChat("No updates found!")
   		end
	end
	GetWebResultAsync("https://raw.githubusercontent.com/Hanndel/GoS/master/QWER%20Series.version", AutoUpdate)
end


class "Zyra"

function Zyra:__init()
	self.Spells = 
	{
		[-3] = { delay = 0.5, speed = 1900, width = 70, range = 1500 },
		[0] = { delay = 0.7, speed = math.huge, width = 70, range = 800, radius = 220, mana = function() return 70+5*GetCastLevel(myHero, 0) end},
		[2] = { delay = 0.25, speed = 1150, width = 70, range = 1100, mana = function() return 65+5*GetCastLevel(myHero, 2) end},
		[3] = { delay = 1, speed = math.huge, width = 500, range = 700, radius = 500, mana = function() return 80+20*GetCastLevel(myHero, 3) end}
	}
	self.Dmg = 
	{
		[-3] = function() return 80+20*GetLevel(myHero) end,
		[0] = function(Unit) return CalcDamage(myHero, Unit, 0, 35+GetCastLevel(myHero, 0)*35+GetBonusAP(myHero)*0.65) end,
		[2] = function(Unit) return CalcDamage(myHero, Unit, 0, 25+GetCastLevel(myHero, 2)*35+GetBonusAP(myHero)*0.50) end,
		[3] = function(Unit) return CalcDamage(myHero, Unit, 0, 95*GetCastLevel(myHero, 3)*85+GetBonusAP(myHero)*0.70) end,
	}
	self.QPoint = nil
	self.EPoint = nil
	self.Ignite = nil
	if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
		self.Ignite = SUMMONER_1
	elseif GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
		self.Ignite = SUMMONER_2
	else
		self.Ignite = nil
	end
	self.Target = nil
	self.DebuffTable = {5, 8, 11, 21, 22, 24, 28, 29, 30}
	self.IsTargetFucked = false

self.Menu = MenuConfig("Zyra", "Zyra")

self.Menu:Menu("C", "Combo")
self.Menu.C:Boolean("Q", "Use Q", true)
self.Menu.C:Boolean("W", "Use W", true)
self.Menu.C:Boolean("E", "Use E", true)
self.Menu.C:Boolean("R", "Use R", true)
self.Menu.C:Slider("ER", "Enemies to R", 3, 0, 5)
self.Menu.C:Boolean("P", "Use Passive", true)

self.Menu:Menu("H", "Harass")
self.Menu.H:Boolean("Q", "Use Q", true)
self.Menu.H:Boolean("E", "Use E", true)

self.Menu:Menu("LC", "LaneClear")
self.Menu.LC:Boolean("Q", "Use Q", true)
self.Menu.LC:Boolean("E", "Use E", true)

self.Menu:Menu("KS", "KillSteal")
self.Menu.KS:Boolean("Q", "Use Q", true)
self.Menu.KS:Boolean("E", "Use E", true)
self.Menu.KS:Boolean("R", "Use R", true)
if self.Ignite ~= nil then
self.Menu.KS:Boolean("IG", "Use Ignite", true)
end

self.Menu:Menu("SO", "Seed Options")
self.Menu.SO:Boolean("QS", "Logic Q Seeds?", true)
self.Menu.SO:SubMenu("QSM", "No logic seeds Q")
self.Menu.SO.QSM:Slider("QSM", "Seeds to use in Q?", 1, 1, 2)
self.Menu.SO.QSM:Slider("DTS", "Distance to 2 seeds", 1, 500, 850)
self.Menu.SO.QSM:Info("a", "Desactivate Logic Q Seeds")
self.Menu.SO:Boolean("ES", "Logic E Seeds?", true)
self.Menu.SO:SubMenu("ESM", "No logic seeds E")
self.Menu.SO.ESM:Slider("ESM", "Seeds to use in E?", 1, 1, 2)
self.Menu.SO.ESM:Info("a", "Desactivate Logic E Seeds")

self.Menu:Menu("Orb", "Hotkeys")
self.Menu.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
self.Menu.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
self.Menu.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

self.Menu:Menu("HC", "Hit chance")
self.Menu.HC:Slider("Q", "Q Predict", 20, 1, 100)
self.Menu.HC:Slider("E", "E Predict", 20, 1, 100)
self.Menu.HC:Slider("R", "R Predict", 20, 1, 100)
self.Menu.HC:Slider("P", "P Predict", 20, 1, 100)

self.Menu:Menu("D", "Draw")
--[[self.Menu.D:SubMenu("DD", "Draw Damage")
self.Menu.D.DD:Boolean("D", "Draw?", true)
self.Menu.D.DD:Boolean("DQ", "Draw Q dmg", true)
self.Menu.D.DD:Boolean("DE", "Draw E dmg", true)
self.Menu.D.DD:Boolean("DR", "Draw R dmg", true)]]
self.Menu.D:SubMenu("DR", "Draw Range")
self.Menu.D.DR:Boolean("D", "Draw?", true)
self.Menu.D.DR:Boolean("DQ", "Draw Q range", true)
self.Menu.D.DR:Boolean("DE", "Draw E range", true)
self.Menu.D.DR:Boolean("DR", "Draw R range", true)
self.Menu.D.DR:Slider("DH", "Quality", 155, 1, 475)

self.Menu:Menu("M", "Misc")
self.Menu.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})
self.Menu.M:DropDown("S", "Skin", 1, {"Classic", "Wildire", "Haunted", "Skt", "Off"})


OnTick(function(myHero) self:Tick() end)
OnDraw(function(myHero) self:Draw() end)
OnProcessSpellComplete(function(Object, spellProc) self:OnProcComplete(Object, spellProc) end)
OnUpdateBuff(function(Object, buff) self:Onupdate(Object, buff) end)
OnRemoveBuff(function(Object, buff) self:Onremove(Object, buff) end)

end

function Zyra:Tick()
	self.Target = GetCurrentTarget()
	if not IsDead(myHero) then
		if self.Menu.Orb.C:Value() then
			self:Combo(self.Target)
		elseif self.Menu.Orb.H:Value() then
			self:Harass(self.Target)
		elseif self.Menu.Orb.LC:Value() then
			self:LaneClear()
		end
		if self:Passiveup() then
			self:CastP(self.Target)
		end
		self:Ks()
		self:Autolvl()
	end
end

function Zyra:Draw()
	--[[if self.Menu.D.DR.D:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
		local Qdmg = self.Dmg[0](enemy)
		local Edmg = self.Dmg[2](enemy)
		local Rdmg = self.Dmg[3](enemy)
		local Tdmg = Qdmg + Edmg + Rdmg
		if Tdmg < GetCurrentHP(enemy) then
			if self.Menu.D.DD.DQ:Value() and ValidTarget(enemy, 800) and Ready(0) then
				DrawDmgOverHpBar(enemy,GetCurrentHP(enemy),0,Qdmg,GoS.Red)
			end
			if self.Menu.D.DD.DE:Value() and ValidTarget(enemy, 1100) and Ready(2) then
				DrawDmgOverHpBar(enemy,GetCurrentHP(enemy),0,Edmg,GoS.Blue)
			end
			if self.Menu.D.DD.DR:Value() and ValidTarget(enemy, 700) and Ready(3) then
				DrawDmgOverHpBar(enemy,GetCurrentHP(enemy),0,Rdmg,GoS.Pink)
			end
		else 
			DrawText("Killiable!",12,enemy.x,enemy.y,GoS.White)
		end
	end]]
	if self.Menu.D.DR.D:Value() then
		if self.Menu.D.DR.DQ:Value() and Ready(0) then
			DrawCircle(GetOrigin(myHero), 800, 1, self.Menu.D.DR.DH:Value(), GoS.Red)
		end

		if self.Menu.D.DR.DE:Value() and Ready(2) then
			DrawCircle(GetOrigin(myHero), 1100, 1, self.Menu.D.DR.DH:Value(), GoS.Blue)
		end

		if self.Menu.D.DR.DR:Value() and Ready(3) then
			DrawCircle(GetOrigin(myHero), 700, 1, self.Menu.D.DR.DH:Value(), GoS.Pink)
		end
	end
	self:SkinChanger()
end

function Zyra:Combo(Target)
	if self.Menu.C.Q:Value() then
		self:CastQ(Target)
	end
	if self.Menu.C.E:Value() then
		self:CastE(Target)
	end
	if self.Menu.C.R:Value() then
		self:CastR(Target)
	end
end

function Zyra:Harass(Target)
	if self.Menu.C.Q:Value() then
		self:CastQ(Target)
	end
	if self.Menu.C.E:Value() then
		self:CastE(Target)
	end
end

function Zyra:LaneClear()
	for _, mobs in pairs(minionManager.objets) do
		if ValidTarget(mob, 850) then
			if self.Menu.LC.Q:Value() and Ready(0) then
				CastSkillShot(0, GetOrigin(mob))
			end
			if self.Menu.LC.E:Value() and Ready(2)  then
				CastSkillShot(2, GetOrigin(mob))
			end
		end
	end
end

function Zyra:Ks()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local P = GetPrediction(enemy, self.Spells[-3])
		local Q = GetCircularAOEPrediction(enemy, self.Spells[0])
		local E = GetPrediction(enemy, self.Spells[2])
		local R = GetCircularAOEPrediction(enemy, self.Spells[3])
		if self.Menu.KS.Q:Value() and Ready(0) and ValidTarget(enemy, 800) and Q.hitChance >= (self.Menu.HC.Q:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[0](enemy) then
			CastSkillShot(0, Q.castPos)
		end

		if self.Menu.KS.E:Value() and Ready(2)  and ValidTarget(enemy, 1100) and E.hitChance >= (self.Menu.HC.E:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[2](enemy) then
			CastSkillShot(2, E.castPos)
		end

		if self.Menu.KS.Q:Value() and Ready(0) and ValidTarget(enemy, 800) and Ready(2) and self.Menu.KS.E:Value() and Q.hitChance >= (self.Menu.HC.Q:Value())/100 and E.hitChance >= (self.Menu.HC.E:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[0](enemy)+self.Dmg[2](enemy) then
			CastSkillShot(2, E.castPos)
			DelayAction(function() CastSkillShot(_Q, Q.castPos) end, GetDistance(enemy)/1500)
		end

		if self.Ignite ~= nil then
			if Ready(self.Ignite) and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*3 <= 50+GetLevel(myHero)*20 then
				CastTargetSpell(enemy, self.Ignite)
			end
		end

		if self:Passiveup() and Ready(0) and ValidTarget(enemy, 1400) and GetCurrentHP(enemy) <= self.Dmg[-3](enemy) and self.Menu.C.P:Value() and PPred >= (self.Menu.HC.P:Value())/100 then
			CastSkillShot(0, P.castPos)
		end
	end
end

function Zyra:CastP(Unit)
	local P = GetCircularAOEPrediction(Unit, self.Spells[-3])
	if self:Passiveup() then
		if Ready(0) and P.hitChance >= (self.Menu.HC.P:Value())/100 and P then
			CastSkillShot(0, P.castPos)
		end
	end
end

function Zyra:CastQ(Unit)
	local Q = GetCircularAOEPrediction(Unit, self.Spells[0])
	if Ready(0) and ValidTarget(Unit, 800) and not ECast and Q.hitChance >= (self.Menu.HC.Q:Value())/100 and Q then
		CastSkillShot(0, Q.castPos)
		QCast = true
		DelayAction(function() QCast = false end, 0.5)
	end
end

function Zyra:CastW(Point, Spell)
	local q = 0
	local e = 0
	if self.IsTargetFucked and Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and self.Menu.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)
		
	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) >= self.Menu.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and self.Menu.SO.QS:Value() then
		CastSkillShot(1, Point)

	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) <= self.Menu.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and self.Menu.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and self.Menu.SO.QS:Value() == false then
		CastSkillShot(1, Point)
		q = q+1
		DelayAction(function()	
			if q < self.Menu.SO.QSM.QSM:Value() then
				CastSkillShot(1, Point)
				q = q+1
				if q == self.Menu.SO.QSM.QSM:Value() then
					q = 0
				end
			else
				q = 0
			end
		end, 0.5)
	end

	if Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and self.Menu.SO.ES:Value() then
		CastSkillShot(1, Point)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and self.Menu.SO.ES:Value() == false then
		CastSkillShot(1, Point)
		e = e+1
		DelayAction(function()	
			if e < self.Menu.SO.ESM.ESM:Value() then
				CastSkillShot(1, Point)
				e = e+1
				if e == self.Menu.SO.ESM.ESM:Value() then
					e = 0
				end
			else
				e = 0
			end
		end, 0.5)
	end
end

function Zyra:CastE(Unit)
	local E = GetPrediction(Unit, self.Spells[2])
	if Ready(2) and ValidTarget(Unit, 1100) and not QCast and E.hitChance >= (self.Menu.HC.E:Value())/100 and E then
		CastSkillShot(2, E.castPos)
		ECast = true
		DelayAction(function() ECast = false end, GetDistance(self.Target)/self.Spells[3].speed)
	end
end

function Zyra:CastR(Unit)
	local R = GetCircularAOEPrediction(Unit, self.Spells[3])
	if Ready(3) and ValidTarget(Unit, 700) and R.hitChance >= (self.Menu.HC.R:Value())/100 and EnemiesAround(myHero, 1000) <= 2 and R then
		CastSkillShot(3, R.castPos)
	elseif Ready(3) and ValidTarget(Unit, 700) and EnemiesAround(myHero, 1000) >= 2 then
		local BestRPos, BestRHit = self:BestRPos()
		if BestRPos and BestRHit >= self.Menu.C.ER:Value() then
			CastSkillShot(3, BestRPos)
		end
	end
end

function Zyra:Autolvl()
	if self.Menu.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) == 1 then
			if self.Menu.M.AL:Value() == 1 then Deftlevel = { _Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W }
			elseif self.Menu.M.AL:Value() == 2 then Deftlevel = { _E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W }
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(1, 2)) --kappa
		end
	end
end

function Zyra:SkinChanger()
	if self.Menu.M.S:Value() ~= 5 then 
		HeroSkinChanger(myHero, self.Menu.M.S:Value() - 1)
	elseif self.Menu.M.S:Value() == 5 then
		HeroSkinChanger(myHero, 0)
	end
end

function Zyra:OnProcComplete(Object, spellProc)
	local EPos = nil
	if Object == myHero then
		if self.Menu.Orb.C:Value() then
			if spellProc.name == GetCastName(myHero, 0) then
				self:CastW(spellProc.endPos, GetCastName(myHero, 0))
			elseif spellProc.name == GetCastName(myHero, 2) then
				if self.Menu.Orb.C:Value() and self.Target.range < GetCastRange(myHero, 1) then
					EPos = GetOrigin(myHero) + Vector(Vector(spellProc.endPos) - Vector(spellProc.startPos)):normalized()*GetDistance(self.Target)
					self:CastW(EPos, GetCastName(myHero, 2))
				end
			end
		elseif self.Menu.Orb.LC:Value() then
			if spellProc.name == GetCastName(myHero, 0) then
				CastSkillShot(1, spellProc.endPos)
				DelayAction(function() CastSkillShot(1, spellProc.endPos) end, 0.5)
			end
		end
	end
end

function Zyra:Onupdate(Object, buffProc)
	if Object.Name == self.Target.Name then 
		for i, buffs in pairs(self.DebuffTable) do
			if buffProc.Type == buffs then
				self.IsTargetFucked = true
			end
		end
	end
end

function Zyra:Onremove(Object, buffProc)
	if Object.Name == self.Target.Name then 
		for i, buffs in pairs(self.DebuffTable) do
			if buffProc.Type == buffs then
				self.IsTargetFucked = false
			end
		end
	end
end

function Zyra:Passiveup()
	if GetCastName(myHero, 0) == GetCastName(myHero, 1) then
		return true
	end
end

function Zyra:BestRPos() -- Modded from Inspired lib
	local BestRPos 
	local BestRHit = 0
	for i, enemies in pairs(GetEnemyHeroes()) do
		if GetOrigin(enemies) ~= nil and ValidTarget(enemies, 700) then
		local hit = EnemiesAround(GetOrigin(enemies), 500)
			if hit > BestHit and GetDistance(enemies) < 700 then
				BestHit = hit
				BestPos = Vector(enemies)
				if BestHit == #GetEnemyHeroes() then
					break
				end
			end
		end
	end
	return BestRPos, BestRHit
end

class "Kindred"

function Kindred:__init()
	self.Spells = {
	[0] = {range = 500, dash = 340, mana = 35},
	[1] = {range = 800, duration = 8, mana = 40},
	[2] = {range = 500, mana = 70, mana = 70},
	[3] = {range = 500, mana = 100},
	}
	Dmg = 
	{
	[0] = function(Unit) return CalcDamage(myHero, Unit, 30+30*GetCastLevel(myHero, 0)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20) end,
	[1] = function(Unit) return CalcDamage(myHero, Unit, 20+5*GetCastLevel(myHero, 1)+0.40*(GetBaseDamage(myHero) + GetBonusDmg(myHero))+0.40*self:PassiveDmg(Unit)) end,
	[2] = function(Unit) 	if GetTeam(Unit) == MINION_JUNGLE then
					return CalcDamage(myHero, Unit, math.max(300,30+30*GetCastLevel(myHero, 2)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+GetMaxHP(Unit)*0.05))
				else 
					return CalcDamage(myHero, Unit, 30+30*GetCastLevel(myHero, 2)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+GetMaxHP(Unit)*0.05)
				end
		  end,
	}
	self.BaseAS = GetBaseAttackSpeed(myHero)
	self.AAPS = self.BaseAS*GetAttackSpeed(myHero)
	self.WolfAA = self.Spells[1].duration*self.AAPS
	basePos = Vector(0,0,0)
	if GetTeam(myHero) == 100 then
		basePos = Vector(415,182,415)
	else
		basePos = Vector(14302,172,14387.8)
	end
	self.Recalling = false
	self.Farsight = false
	self.Passive = 0
	OnTick(function(myHero) self:Tick() end)
	OnDraw(function(myHero) self:Draw() end)
	OnProcessSpellComplete(function(unit, spell) self:OnProcComplete(unit, spell) end)
	OnProcessSpell(function(unit, spell) self:OnProc(unit, spell) end)
	self.Flash = (GetCastName(myHero, SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil)) -- Ty Platy
	self.target = nil

	self.Menu:Menu("Combo", "Combo")
	self.Menu.Combo:Boolean("Q", "Use Q", true)
	self.Menu.Combo:Boolean("W", "Use W", true)
	self.Menu.Combo:Boolean("E", "Use E", true)
	self.Menu.Combo:Boolean("QE", "Gapcloser", true)

	self.Menu:Menu("JunglerClear", "JunglerClear")
	self.Menu.JunglerClear:Boolean("Q", "Use Q", true)
	self.Menu.JunglerClear:Boolean("W", "Use W", true)
	self.Menu.JunglerClear:Boolean("E", "Use E", true)
	self.Menu.JunglerClear:Slider("MM", "Mana manager", 50, 1, 100)

	self.Menu:Menu("LaneClear", "LaneClear")
	self.Menu.LaneClear:Boolean("Q", "Use Q", true)
	self.Menu.LaneClear:Boolean("W", "Use W", true)
	self.Menu.LaneClear:Boolean("E", "Use E", true)
	self.Menu.LaneClear:Slider("MM", "Mana manager", 50, 1, 100)

	self.Menu:Menu("Orb", "Hotkeys")
	self.Menu.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
	self.Menu.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
	self.Menu.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	self.Menu:Menu("Misc", "Misc")
	self.Menu.Misc:DropDown("AL", "Priority", 1, {"Q-E-W","Q-E-W lv3 E","Q-W-E","Q-W-E lv3 E", "Off"})
	self.Menu.Draw:DropDown("S", "Select skin", 1, {"Classic", "ShadowFire", "Off"})
	self.Menu.Misc:Boolean("B", "Buy Farsight", true)
	self.Menu.Misc:KeyBinding("FQ", "Flash-Q", string.byte("T"))
	self.Menu.Misc:Key("WP", "Jumps", string.byte("G"))

	self.Menu:Menu("ROptions", "R Options")
	self.Menu.ROptions:Boolean("R", "Use R?", true)
	self.Menu.ROptions:Slider("EA", "Enemies around", 3, 1, 5)
	self.Menu.ROptions:Boolean("RU", "Use R on urself", true)

	self.Menu:Menu("QOptions", "Q Options")
	self.Menu.QOptions:Boolean("QC", "AA reset Combo", true)
	self.Menu.QOptions:Boolean("QL", "AA reset LaneClear", true)
	self.Menu.QOptions:Boolean("QJ", "AA reset JunglerClear", true)
	self.Menu.QOptions:Boolean("C", "Cancel animation?", false)

	self.Menu:Menu("D", "Draw")
	--[[self.Menu.D:SubMenu("DD", "Draw Damage")
	self.Menu.D.DD:Boolean("D", "Draw?", true)
	self.Menu.D.DD:Boolean("DQ", "Draw Q dmg", true)
	self.Menu.D.DD:Boolean("DE", "Draw E dmg", true)
	self.Menu.D.DD:Boolean("DR", "Draw R dmg", true)]]
	self.Menu.D:SubMenu("DR", "Draw Range")
	self.Menu.D.DR:Boolean("D", "Draw?", true)
	self.Menu.D.DR:Boolean("DQ", "Draw Q range", true)
	self.Menu.D.DR:Boolean("DW", "Draw W range", true)
	self.Menu.D.DR:Boolean("DE", "Draw E range", true)
	self.Menu.D.DR:Boolean("DR", "Draw R range", true)
	self.Menu.D.DR:Slider("DH", "Quality", 155, 1, 475)

	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			self.Menu.ROptions:Boolean("Pleb"..GetObjectName(allies), "Use R on "..GetObjectName(allies), true)
		end
	end, 0.001)
end

function Kindred:Tick()
	if not IsDead(myHero) then
	
		GetReady()
		self.target = GetCurrentTarget()

		if self.Menu.Orb.C:Value() then
			self:Combo(self.Target)
		elseif self.Menu.Orb.LC:Value() then
			self:LaneClear()
		end

		self:AutoR()
		if self.Menu.Misc.FQ:Value() then
			if Ready(0) and Ready(Flash) and self.Menu.Combo.Q:Value() then  
				CastSkillShot(Flash, GetMousePos()) 
					DelayAction(function() CastSkillShot(0, GetMousePos()) end, 1)					  
			end
		end
		if self.Menu.Misc.WP:Value() then
			if self:WallBetween(GetOrigin(myHero), GetMousePos(),  self.Spells[0].dash) and Ready(0) then
				CastSkillShot(0, GetMousePos())
			end
		end
		self.Passive = GetBuffData(myHero,"kindredmarkofthekindredstackcounter").Stacks
		if self.Menu.Misc.B:Value() then
			if not self.Farsight and GetLevel(myHero) >= 9 and GetDistance(myHero,basePos) < 550 then
				BuyItem(3363)
				self.Farsight = true
			end
		end
		self:Autolvl()
	end
end

function Kindred:Draw()
	if self.Menu.D.DD.D:Value() then
		if self.Menu.D.DR.DQ:Value() and Ready(0) then
			DrawCircle(GetOrigin(myHero), self.Spells[0].range, 1, self.Menu.D.DR.DH:Value(), GoS.Red)
		end

		if self.Menu.D.DR.DW:Value() and Ready(1) then
			DrawCircle(GetOrigin(myHero), self.Spells[1].range, 1, self.Menu.D.DR.DH:Value(), GoS.Blue)
		end

		if self.Menu.D.DR.DE:Value() and Ready(2) then
			DrawCircle(GetOrigin(myHero), self.Spells[2].range, 1, self.Menu.D.DR.DH:Value(), GoS.Pink)
		end
			if self.Menu.D.DR.DR:Value() and Ready(3) then
			DrawCircle(GetOrigin(myHero), self.Spells[3].range, 1, self.Menu.D.DR.DH:Value(), GoS.White)
		end
	end
	self:SkinChanger()
end

function Kindred:Combo(Unit)
local AfterQ = GetOrigin(myHero) +(Vector(GetMousePos()) - GetOrigin(myHero)):normalized()*self.Spells[0].dash

	if Ready(2) and Ready(0) and self.Menu.Combo.QE:Value() and GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450 then
		CastSkillShot(0, GetMousePos())
			DelayAction(function() CastTargetSpell(Unit, 2) end, 1)
	end
	if Ready(0) and self.Menu.Combo.Q:Value() and ValidTarget(Unit, self.Spells[0].range) and self.Menu.QOptions.QC:Value() == false or (GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450)  then
    	CastSkillShot(0, GetMousePos()) 
	end
	if Ready(1) and self.Menu.Combo.W:Value() and ValidTarget(Unit, self.Spells[1].range) then 
		CastSpell(1)
	end
	if Ready(2) and self.Menu.Combo.E:Value() and ValidTarget(Unit, self.Spells[2].range) then 
		CastTargetSpell(Unit, 2)
	end
end

function Kindred:LaneClear()
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	local WMana = (self.Spells[1].mana*100)/GetMaxMana(myHero)
	local EMana = (self.Spells[2].mana*100)/GetMaxMana(myHero)
	for _, mob in pairs(minionManager.objects) do	
		if GetTeam(mob) == MINION_JUNGLE then
			if self.Menu.QOptions.QJ:Value() == false and Ready(0) and self.Menu.JunglerClear.Q:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) and (GetPercentMP(myHero)- QMana) >= self.Menu.JunglerClear.MM:Value() then 
				CastSkillShot(0, GetMousePos())
			end
			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and IsTargetable(mob) and self.Menu.JunglerClear.W:Value() and (GetPercentMP(myHero)- WMana) >= self.Menu.JunglerClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then
   				CastSpell(1)
    		end
    		if Ready(2) and ValidTarget(mob, self.Spells[2].range) and self.Menu.JunglerClear.E:Value() and (GetPercentMP(myHero)- EMana) >= self.Menu.JunglerClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
   				CastTargetSpell(mob, 2)
   			end
  	 	end
		if GetTeam(mob) == MINION_ENEMY then
			if self.Menu.QOptions.QL:Value() == false and Ready(0) and self.Menu.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= self.Menu.LaneClear.MM:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) then 
				CastSkillShot(0, GetMousePos())
			end
			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and self.Menu.LaneClear.W:Value() and (GetPercentMP(myHero)- WMana) >= self.Menu.LaneClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then 
				CastSpell(1)
			end
			if Ready(2) and ValidTarget(mob, self.Spells[2].range) and self.Menu.LaneClear.E:Value() and (GetPercentMP(myHero)- EMana) >= self.Menu.LaneClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
				CastTargetSpell(mob, 2)
			end
		end
	end
end

function Kindred:AutoR()
	if self.Menu.ROptions.R:Value() and not self.Recalling and not IsDead(myHero) and Ready(1) then
		for i, allies in pairs(GetAllyHeroes()) do
			if GetPercentHP(allies) <= 20 and self.Menu.ROptions["Pleb"..GetObjectName(allies)] and not IsDead(allies) and GetDistance(allies) <= self.Spells[3].range and EnemiesAround(allies, 1500) >= self.Menu.ROptions.EA:Value() then
				CastTargetSpell(myHero, 3)
			end
		end
		if GetPercentHP(myHero) <= 20 and self.Menu.ROptions.RU:Value() and EnemiesAround(myHero, 1500) >= self.Menu.ROptions.EA:Value() then
			CastTargetSpell(myHero, 3)
		end
	end
end

function Kindred:Autolvl()
	if self.Menu.Misc.AL:Value() ~= 5 then 
  		if GetLevelPoints(myHero) >= 1 then
 			if self.Menu.Misc.AL:Value() == 1 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif self.Menu.Misc.AL:Value() == 3 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
 			elseif self.Menu.Misc.AL:Value() == 2 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif self.Menu.Misc.AL:Value() == 4 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    		end 
  			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500, 2000))
  		end 
  	end
end

function Kindred:SkinChanger()
	if self.Menu.M.S:Value() ~= 5 then 
		HeroSkinChanger(myHero, self.Menu.M.S:Value() - 1)
	elseif self.Menu.M.S:Value() == 5 then
		HeroSkinChanger(myHero, 0)
	end
end

function Kindred:OnProcComplete(unit, spell)
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			if Mode == "LaneClear" then 
				for _, mob in pairs(minionManager.objects) do	
					if self.Menu.QOptions.QL:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_ENEMY and self.Menu.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= self.Menu.LaneClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos())
					end
					if self.Menu.QOptions.QJ:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_JUNGLE and self.Menu.JunglerClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= self.Menu.JunglerClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos()) 
					end
				end
			elseif Mode == "Combo" then
				if self.Menu.QOptions.QC:Value() and Ready(0) and self.Menu.Combo.Q:Value() and ValidTarget(self.target, 500) then
    				CastSkillShot(0, GetMousePos()) 
				end
			end
		end
	end
end

function Kindred:OnProc(unit, spell)
	if unit == myHero and spell.name == "KindredQ" and self.Menu.QOptions.C:Value() then
		DelayAction(function() CastEmote(EMOTE_DANCE) end, .001)
	end
end

function Kindred:OnUpdate(unit, buff)
	if unit == myHero then
		if buff.Name == "recall" or buff.Name == "OdinRecall" then
			self.Recalling = true
		end
		--[[if buff.Name == "kindredmarkofthekindredstackcounter" then
			self.Passive = self.Passive + buff.Stacks
		end]]
	end
end

function Kindred:OnRemove(unit, buff)
	if unit == myHero and buff.Name == "recall" or buff.Name == "OdinRecall" then
		self.Recalling = false
	end
end

function Kindred:PassiveDmg(unit)
	if self.Passive ~= 0 then
		local PassiveDmg = self.Passive * 1.25
		if GetTeam(unit) == MINION_JUNGLE then
			return CalcDamage(myHero, unit, math.max(75+10*self.Passive, GetCurrentHP(unit)*(PassiveDmg/100)))
		else
			return CalcDamage(myHero, unit, GetCurrentHP(unit)*(PassiveDmg/100))
		end
	else return 0
	end
end

function Kindred:TotalHp(range, pos)
	local hp = 0
	for _, mob in pairs(minionManager.objects) do
		if not IsDead(mob) and IsTargetable(mob) and (GetTeam(mob) == MINION_JUNGLE or GetTeam(mob) == MINION_ENEMY) and GetDistance(mob, pos) <= range then
			hp = hp + GetCurrentHP(mob)
		end
	end
	return hp
end

function Kindred:WallBetween(p1, p2, distance) --p1 and p2 are Vectors3d

	local Check = p1 + (Vector(p2) - p1):normalized()*distance/2
	local Checkdistance = p1 +(Vector(p2) - p1):normalized()*distance
	
	if MapPosition:inWall(Check) and not MapPosition:inWall(Checkdistance) then
		return true
	end
end
