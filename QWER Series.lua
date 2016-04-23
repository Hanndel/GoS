require "OpenPredict"

local ChampTable =
	{
	["Kindred"] 	= true,
	["Zyra"] 		= true,
	["Poppy"] 		= true,
	["Elise"]	 	= true,
	}

Callback.Add("Load", function()
	Start()
	if ChampTable[GetObjectName(myHero)] then
		_G[GetObjectName(myHero)]()
	else
		PrintChat(GetObjectName(myHero).." Is not supported!")
	end
	if GetObjectName(myHero) == "Kindred" or GetObjectName(myHero) == "Poppy" then
		require('MapPositionGOS')
	end
	TargetSelector()
end)

local ver = "0.94"

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
	local myName = myHero.charName
	MainMenu = MenuConfig("QWER Series", "QWER Series")
		MainMenu:Menu("T", "TargetSelector")
		MainMenu:Menu("Champ", "QWER "..myName)
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


MainMenu.Champ:Menu("C", "Combo")
MainMenu.Champ.C:Boolean("Q", "Use Q", true)
MainMenu.Champ.C:Boolean("W", "Use W", true)
MainMenu.Champ.C:Boolean("E", "Use E", true)
MainMenu.Champ.C:Boolean("R", "Use R", true)
MainMenu.Champ.C:Slider("ER", "Enemies to R", 3, 0, 5)
MainMenu.Champ.C:Boolean("P", "Use Passive", true)

MainMenu.Champ:Menu("H", "Harass")
MainMenu.Champ.H:Boolean("Q", "Use Q", true)
MainMenu.Champ.H:Boolean("E", "Use E", true)

MainMenu.Champ:Menu("LC", "LaneClear")
MainMenu.Champ.LC:Boolean("Q", "Use Q", true)
MainMenu.Champ.LC:Boolean("E", "Use E", true)

MainMenu.Champ:Menu("KS", "KillSteal")
MainMenu.Champ.KS:Boolean("Q", "Use Q", true)
MainMenu.Champ.KS:Boolean("E", "Use E", true)
MainMenu.Champ.KS:Boolean("R", "Use R", true)
if self.Ignite ~= nil then
MainMenu.Champ.KS:Boolean("IG", "Use Ignite", true)
end

MainMenu.Champ:Menu("SO", "Seed Options")
MainMenu.Champ.SO:Boolean("QS", "Logic Q Seeds?", true)
MainMenu.Champ.SO:SubMenu("QSM", "No logic seeds Q")
MainMenu.Champ.SO.QSM:Slider("QSM", "Seeds to use in Q?", 1, 1, 2)
MainMenu.Champ.SO.QSM:Slider("DTS", "Distance to 2 seeds", 1, 500, 850)
MainMenu.Champ.SO.QSM:Info("a", "Desactivate Logic Q Seeds")
MainMenu.Champ.SO:Boolean("ES", "Logic E Seeds?", true)
MainMenu.Champ.SO:SubMenu("ESM", "No logic seeds E")
MainMenu.Champ.SO.ESM:Slider("ESM", "Seeds to use in E?", 1, 1, 2)
MainMenu.Champ.SO.ESM:Info("a", "Desactivate Logic E Seeds")

MainMenu.Champ:Menu("Orb", "Hotkeys")
MainMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
MainMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
MainMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

MainMenu.Champ:Menu("HC", "Hit chance")
MainMenu.Champ.HC:Slider("Q", "Q Predict", 20, 1, 100)
MainMenu.Champ.HC:Slider("E", "E Predict", 20, 1, 100)
MainMenu.Champ.HC:Slider("R", "R Predict", 20, 1, 100)
MainMenu.Champ.HC:Slider("P", "P Predict", 20, 1, 100)

MainMenu.Champ:Menu("D", "Draw")
MainMenu.Champ.D:SubMenu("DR", "Draw Range")
MainMenu.Champ.D.DR:Boolean("D", "Draw?", true)
MainMenu.Champ.D.DR:Boolean("DQ", "Draw Q range", true)
MainMenu.Champ.D.DR:Boolean("DE", "Draw E range", true)
MainMenu.Champ.D.DR:Boolean("DR", "Draw R range", true)
MainMenu.Champ.D.DR:Slider("DH", "Quality", 155, 1, 475)

MainMenu.Champ:Menu("M", "Misc")
MainMenu.Champ.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})
MainMenu.Champ.M:DropDown("S", "Skin", 1, {"Classic", "Wildire", "Haunted", "Skt", "Off"})


OnTick(function(myHero) self:Tick() end)
OnDraw(function(myHero) self:Draw() end)
OnProcessSpellComplete(function(Object, spellProc) self:OnProcComplete(Object, spellProc) end)
OnUpdateBuff(function(Object, buff) self:Onupdate(Object, buff) end)
OnRemoveBuff(function(Object, buff) self:Onremove(Object, buff) end)

end

function Zyra:Tick()
	self.Target = GetCurrentTarget()
	if not IsDead(myHero) then
		if MainMenu.Champ.Orb.C:Value() then
			self:Combo(self.Target)
		elseif MainMenu.Champ.Orb.H:Value() then
			self:Harass(self.Target)
		elseif MainMenu.Champ.Orb.LC:Value() then
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
	if MainMenu.Champ.D.DR.D:Value() then
		if MainMenu.Champ.D.DR.DQ:Value() and Ready(0) then
			DrawCircle(GetOrigin(myHero), 800, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Red)
		end

		if MainMenu.Champ.D.DR.DE:Value() and Ready(2) then
			DrawCircle(GetOrigin(myHero), 1100, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Blue)
		end

		if MainMenu.Champ.D.DR.DR:Value() and Ready(3) then
			DrawCircle(GetOrigin(myHero), 700, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Pink)
		end
	end
	self:SkinChanger()
end

function Zyra:Combo(Target)
	if MainMenu.Champ.C.Q:Value() then
		self:CastQ(Target)
	end
	if MainMenu.Champ.C.E:Value() then
		self:CastE(Target)
	end
	if MainMenu.Champ.C.R:Value() then
		self:CastR(Target)
	end
end

function Zyra:Harass(Target)
	if MainMenu.Champ.C.Q:Value() then
		self:CastQ(Target)
	end
	if MainMenu.Champ.C.E:Value() then
		self:CastE(Target)
	end
end

function Zyra:LaneClear()
	for _, mob in pairs(minionManager.objects) do
		if ValidTarget(mob, 850) then
			if MainMenu.Champ.LC.Q:Value() and Ready(0) then
				CastSkillShot(0, GetOrigin(mob))
			end
			if MainMenu.Champ.LC.E:Value() and Ready(2)  then
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
		if MainMenu.Champ.KS.Q:Value() and Ready(0) and ValidTarget(enemy, 800) and Q.hitChance >= (MainMenu.Champ.HC.Q:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[0](enemy) then
			CastSkillShot(0, Q.castPos)
		end

		if MainMenu.Champ.KS.E:Value() and Ready(2)  and ValidTarget(enemy, 1100) and E.hitChance >= (MainMenu.Champ.HC.E:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[2](enemy) then
			CastSkillShot(2, E.castPos)
		end

		if MainMenu.Champ.KS.Q:Value() and Ready(0) and ValidTarget(enemy, 800) and Ready(2) and MainMenu.Champ.KS.E:Value() and Q.hitChance >= (MainMenu.Champ.HC.Q:Value())/100 and E.hitChance >= (MainMenu.Champ.HC.E:Value())/100 and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < self.Dmg[0](enemy)+self.Dmg[2](enemy) then
			CastSkillShot(2, E.castPos)
			DelayAction(function() CastSkillShot(_Q, Q.castPos) end, GetDistance(enemy)/1500)
		end

		if self.Ignite ~= nil then
			if Ready(self.Ignite) and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*3 <= 50+GetLevel(myHero)*20 then
				CastTargetSpell(enemy, self.Ignite)
			end
		end

		if self:Passiveup() and Ready(0) and ValidTarget(enemy, 1400) and GetCurrentHP(enemy) <= self.Dmg[-3](enemy) and MainMenu.Champ.C.P:Value() and P.hitChance >= (MainMenu.Champ.HC.P:Value())/100 then
			CastSkillShot(0, P.castPos)
		end
	end
end

function Zyra:CastP(Unit)
	local P = GetCircularAOEPrediction(Unit, self.Spells[-3])
	if self:Passiveup() then
		if Ready(0) and P.hitChance >= (MainMenu.Champ.HC.P:Value())/100 and P then
			CastSkillShot(0, P.castPos)
		end
	end
end

function Zyra:CastQ(Unit)
	local Q = GetCircularAOEPrediction(Unit, self.Spells[0])
	if Ready(0) and ValidTarget(Unit, 800) and not ECast and Q.hitChance >= (MainMenu.Champ.HC.Q:Value())/100 and Q then
		CastSkillShot(0, Q.castPos)
		QCast = true
		DelayAction(function() QCast = false end, 0.5)
	end
end

function Zyra:CastW(Point, Spell)
	local q = 0
	local e = 0
	if self.IsTargetFucked and Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and MainMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)
		
	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) >= MainMenu.Champ.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and MainMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)

	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) <= MainMenu.Champ.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and MainMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and MainMenu.Champ.SO.QS:Value() == false then
		CastSkillShot(1, Point)
		q = q+1
		DelayAction(function()	
			if q < MainMenu.Champ.SO.QSM.QSM:Value() then
				CastSkillShot(1, Point)
				q = q+1
				if q == MainMenu.Champ.SO.QSM.QSM:Value() then
					q = 0
				end
			else
				q = 0
			end
		end, 0.5)
	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and MainMenu.Champ.SO.QS:Value() == false then
		while q <= MainMenu.Champ.SO.QSM:Value() do
			CastSkillShot(1, Point)
			q = q+1
			if q == MainMenu.Champ.SO.QSM:Value() then 
				break
			end
		end
		if q == MainMenu.Champ.SO.QSM:Value() then q = 0 end
	end
	if Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and MainMenu.Champ.SO.ES:Value() then
		CastSkillShot(1, Point)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and MainMenu.Champ.SO.ES:Value() == false then
		CastSkillShot(1, Point)
		e = e+1
		DelayAction(function()	
			if e < MainMenu.Champ.SO.ESM.ESM:Value() then
				CastSkillShot(1, Point)
				e = e+1
				if e == MainMenu.Champ.SO.ESM.ESM:Value() then
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
	if Ready(2) and ValidTarget(Unit, 1100) and not QCast and E.hitChance >= (MainMenu.Champ.HC.E:Value())/100 and E then
		CastSkillShot(2, E.castPos)
		ECast = true
		DelayAction(function() ECast = false end, GetDistance(self.Target)/self.Spells[3].speed)
	end
end

function Zyra:CastR(Unit)
	local R = GetCircularAOEPrediction(Unit, self.Spells[3])
	if Ready(3) and ValidTarget(Unit, 700) and R.hitChance >= (MainMenu.Champ.HC.R:Value())/100 and EnemiesAround(myHero, 1000) <= 2 and R then
		CastSkillShot(3, R.castPos)
	elseif Ready(3) and ValidTarget(Unit, 700) and EnemiesAround(myHero, 1000) >= 2 then
		local BestRPos, BestRHit = self:BestRPos()
		if BestRPos and BestRHit >= MainMenu.Champ.C.ER:Value() then
			CastSkillShot(3, BestRPos)
		end
	end
end

function Zyra:Autolvl()
	if MainMenu.Champ.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) >= 1 then
			if MainMenu.Champ.M.AL:Value() == 1 then Deftlevel = { _Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W }
			elseif MainMenu.Champ.M.AL:Value() == 2 then Deftlevel = { _E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W }
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(1, 2)) --kappa
		end
	end
end

function Zyra:SkinChanger()
	if MainMenu.Champ.M.S:Value() ~= 5 then 
		HeroSkinChanger(myHero, MainMenu.Champ.M.S:Value() - 1)
	elseif MainMenu.Champ.M.S:Value() == 5 then
		HeroSkinChanger(myHero, 0)
	end
end

function Zyra:OnProcComplete(Object, spellProc)
	local EPos = nil
	if Object == myHero then
		if MainMenu.Champ.Orb.C:Value() then
			if spellProc.name == GetCastName(myHero, 0) then
				self:CastW(spellProc.endPos, GetCastName(myHero, 0))
			elseif spellProc.name == GetCastName(myHero, 2) then
				if MainMenu.Champ.Orb.C:Value() and self.Target.range < GetCastRange(myHero, 1) then
					EPos = GetOrigin(myHero) + Vector(Vector(spellProc.endPos) - Vector(spellProc.startPos)):normalized()*GetDistance(self.Target)
					self:CastW(EPos, GetCastName(myHero, 2))
				end
			end
		elseif MainMenu.Champ.Orb.LC:Value() then
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
	
	MainMenu.Champ:Menu("Combo", "Combo")
	MainMenu.Champ.Combo:Boolean("Q", "Use Q", true)
	MainMenu.Champ.Combo:Boolean("W", "Use W", true)
	MainMenu.Champ.Combo:Boolean("E", "Use E", true)
	MainMenu.Champ.Combo:Boolean("QE", "Gapcloser", true)

	MainMenu.Champ:Menu("JunglerClear", "JunglerClear")
	MainMenu.Champ.JunglerClear:Boolean("Q", "Use Q", true)
	MainMenu.Champ.JunglerClear:Boolean("W", "Use W", true)
	MainMenu.Champ.JunglerClear:Boolean("E", "Use E", true)
	MainMenu.Champ.JunglerClear:Slider("MM", "Mana manager", 50, 1, 100)

	MainMenu.Champ:Menu("LaneClear", "LaneClear")
	MainMenu.Champ.LaneClear:Boolean("Q", "Use Q", true)
	MainMenu.Champ.LaneClear:Boolean("W", "Use W", true)
	MainMenu.Champ.LaneClear:Boolean("E", "Use E", true)
	MainMenu.Champ.LaneClear:Slider("MM", "Mana manager", 50, 1, 100)

	MainMenu.Champ:Menu("Orb", "Hotkeys")
	MainMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
	MainMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	MainMenu.Champ:Menu("Misc", "Misc")
	MainMenu.Champ.Misc:DropDown("AL", "Priority", 1, {"Q-E-W","Q-E-W lv3 E","Q-W-E","Q-W-E lv3 E", "Off"})
	MainMenu.Champ.Misc:DropDown("S", "Select skin", 1, {"Classic", "ShadowFire", "Off"})
	MainMenu.Champ.Misc:Boolean("B", "Buy Farsight", true)
	MainMenu.Champ.Misc:KeyBinding("FQ", "Flash-Q", string.byte("T"))
	MainMenu.Champ.Misc:Key("WP", "Jumps", string.byte("G"))

	MainMenu.Champ:Menu("ROptions", "R Options")
	MainMenu.Champ.ROptions:Boolean("R", "Use R?", true)
	MainMenu.Champ.ROptions:Slider("EA", "Enemies around", 3, 1, 5)
	MainMenu.Champ.ROptions:Boolean("RU", "Use R on urself", true)

	MainMenu.Champ:Menu("QOptions", "Q Options")
	MainMenu.Champ.QOptions:Boolean("QC", "AA reset Combo", true)
	MainMenu.Champ.QOptions:Boolean("QL", "AA reset LaneClear", true)
	MainMenu.Champ.QOptions:Boolean("QJ", "AA reset JunglerClear", true)
	MainMenu.Champ.QOptions:Boolean("C", "Cancel animation?", false)

	MainMenu.Champ:Menu("D", "Draw")
	MainMenu.Champ.D:SubMenu("DR", "Draw Range")
	MainMenu.Champ.D.DR:Boolean("D", "Draw?", true)
	MainMenu.Champ.D.DR:Boolean("DQ", "Draw Q range", true)
	MainMenu.Champ.D.DR:Boolean("DW", "Draw W range", true)
	MainMenu.Champ.D.DR:Boolean("DE", "Draw E range", true)
	MainMenu.Champ.D.DR:Boolean("DR", "Draw R range", true)
	MainMenu.Champ.D.DR:Slider("DH", "Quality", 155, 1, 475)

	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			MainMenu.Champ.ROptions:Boolean("Pleb"..GetObjectName(allies), "Use R on "..GetObjectName(allies), true)
		end
	end, 0.001)
end

function Kindred:Tick()
	if not IsDead(myHero) then
	
		self.target = CustomTarget

		if MainMenu.Champ.Orb.C:Value() then
			self:Combo(self.target)
			PrintChat(GetObjectName(self.target))
		elseif MainMenu.Champ.Orb.LC:Value() then
			self:LaneClear()
		end

		self:AutoR()
		if MainMenu.Champ.Misc.FQ:Value() then
			if Ready(0) and Ready(Flash) and MainMenu.Champ.Combo.Q:Value() then  
				CastSkillShot(Flash, GetMousePos()) 
					DelayAction(function() CastSkillShot(0, GetMousePos()) end, 1)					  
			end
		end
		if MainMenu.Champ.Misc.WP:Value() then
			if self:WallBetween(GetOrigin(myHero), GetMousePos(),  self.Spells[0].dash) and Ready(0) then
				CastSkillShot(0, GetMousePos())
			end
		end
		self.Passive = GetBuffData(myHero,"kindredmarkofthekindredstackcounter").Stacks
		if MainMenu.Champ.Misc.B:Value() then
			if not self.Farsight and GetLevel(myHero) >= 9 and GetDistance(myHero,basePos) < 550 then
				BuyItem(3363)
				self.Farsight = true
			end
		end
		self:Autolvl()
	end
end

function Kindred:Draw()
	if MainMenu.Champ.D.DR.D:Value() then
		if MainMenu.Champ.D.DR.DQ:Value() and Ready(0) then
			DrawCircle(GetOrigin(myHero), self.Spells[0].range, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Red)
		end

		if MainMenu.Champ.D.DR.DW:Value() and Ready(1) then
			DrawCircle(GetOrigin(myHero), self.Spells[1].range, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Blue)
		end

		if MainMenu.Champ.D.DR.DE:Value() and Ready(2) then
			DrawCircle(GetOrigin(myHero), self.Spells[2].range, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.Pink)
		end
			if MainMenu.Champ.D.DR.DR:Value() and Ready(3) then
			DrawCircle(GetOrigin(myHero), self.Spells[3].range, 1, MainMenu.Champ.D.DR.DH:Value(), GoS.White)
		end
	end
	self:SkinChanger()
end

function Kindred:Combo(Unit)
local AfterQ = GetOrigin(myHero) +(Vector(GetMousePos()) - GetOrigin(myHero)):normalized()*self.Spells[0].dash

	if Ready(2) and Ready(0) and MainMenu.Champ.Combo.QE:Value() and GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450 then
		CastSkillShot(0, GetMousePos())
			DelayAction(function() CastTargetSpell(Unit, 2) end, 1)
	end
	if Ready(0) and MainMenu.Champ.Combo.Q:Value() and ValidTarget(Unit, self.Spells[0].range) and MainMenu.Champ.QOptions.QC:Value() == false or (GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450)  then
    	CastSkillShot(0, GetMousePos()) 
	end
	if Ready(1) and MainMenu.Champ.Combo.W:Value() and ValidTarget(Unit, self.Spells[1].range) then 
		CastSpell(1)
	end
	if Ready(2) and MainMenu.Champ.Combo.E:Value() and ValidTarget(Unit, self.Spells[2].range) then 
		CastTargetSpell(Unit, 2)
	end
end

function Kindred:LaneClear()
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	local WMana = (self.Spells[1].mana*100)/GetMaxMana(myHero)
	local EMana = (self.Spells[2].mana*100)/GetMaxMana(myHero)
	for _, mob in pairs(minionManager.objects) do	
		if GetTeam(mob) == MINION_JUNGLE then
			if MainMenu.Champ.QOptions.QJ:Value() == false and Ready(0) and MainMenu.Champ.JunglerClear.Q:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) and (GetPercentMP(myHero)- QMana) >= MainMenu.Champ.JunglerClear.MM:Value() then 
				CastSkillShot(0, GetMousePos())
			end
			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and IsTargetable(mob) and MainMenu.Champ.JunglerClear.W:Value() and (GetPercentMP(myHero)- WMana) >= MainMenu.Champ.JunglerClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then
   				CastSpell(1)
    		end
    		if Ready(2) and ValidTarget(mob, self.Spells[2].range) and MainMenu.Champ.JunglerClear.E:Value() and (GetPercentMP(myHero)- EMana) >= MainMenu.Champ.JunglerClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
   				CastTargetSpell(mob, 2)
   			end
  	 	end
		if GetTeam(mob) == MINION_ENEMY then
			if MainMenu.Champ.QOptions.QL:Value() == false and Ready(0) and MainMenu.Champ.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= MainMenu.Champ.LaneClear.MM:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) then 
				CastSkillShot(0, GetMousePos())
			end
			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and MainMenu.Champ.LaneClear.W:Value() and (GetPercentMP(myHero)- WMana) >= MainMenu.Champ.LaneClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then 
				CastSpell(1)
			end
			if Ready(2) and ValidTarget(mob, self.Spells[2].range) and MainMenu.Champ.LaneClear.E:Value() and (GetPercentMP(myHero)- EMana) >= MainMenu.Champ.LaneClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
				CastTargetSpell(mob, 2)
			end
		end
	end
end

function Kindred:AutoR()
	if MainMenu.Champ.ROptions.R:Value() and not self.Recalling and not IsDead(myHero) and Ready(1) then
		for i, allies in pairs(GetAllyHeroes()) do
			if GetPercentHP(allies) <= 20 and MainMenu.Champ.ROptions["Pleb"..GetObjectName(allies)] and not IsDead(allies) and GetDistance(allies) <= self.Spells[3].range and EnemiesAround(allies, 1500) >= MainMenu.Champ.ROptions.EA:Value() then
				CastTargetSpell(myHero, 3)
			end
		end
		if GetPercentHP(myHero) <= 20 and MainMenu.Champ.ROptions.RU:Value() and EnemiesAround(myHero, 1500) >= MainMenu.Champ.ROptions.EA:Value() then
			CastTargetSpell(myHero, 3)
		end
	end
end

function Kindred:Autolvl()
	if MainMenu.Champ.Misc.AL:Value() ~= 5 then 
  		if GetLevelPoints(myHero) >= 1 then
 			if MainMenu.Champ.Misc.AL:Value() == 1 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif MainMenu.Champ.Misc.AL:Value() == 3 then Deftlevel = {_W, _Q, _Q, _E, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
 			elseif MainMenu.Champ.Misc.AL:Value() == 2 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
 			elseif MainMenu.Champ.Misc.AL:Value() == 4 then Deftlevel = {_W, _Q, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    		end 
  			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(500, 2000))
  		end 
  	end
end

function Kindred:SkinChanger()
	if MainMenu.Champ.Misc.S:Value() ~= 5 then 
		HeroSkinChanger(myHero, MainMenu.Champ.Misc.S:Value() - 1)
	elseif MainMenu.Champ.Misc.S:Value() == 5 then
		HeroSkinChanger(myHero, 0)
	end
end

function Kindred:OnProcComplete(unit, spell)
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			if MainMenu.Champ.Orb.LC:Value() then 
				for _, mob in pairs(minionManager.objects) do	
					if MainMenu.Champ.QOptions.QL:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_ENEMY and MainMenu.Champ.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= MainMenu.Champ.LaneClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos())
					end
					if MainMenu.Champ.QOptions.QJ:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_JUNGLE and MainMenu.Champ.JunglerClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= MainMenu.Champ.JunglerClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos()) 
					end
				end
			elseif MainMenu.Champ.Orb.C:Value() then
				if MainMenu.Champ.QOptions.QC:Value() and Ready(0) and MainMenu.Champ.Combo.Q:Value() and ValidTarget(self.target, 500) then
    				CastSkillShot(0, GetMousePos()) 
				end
			end
		end
	end
end

function Kindred:OnProc(unit, spell)
	if unit == myHero and spell.name == "KindredQ" and MainMenu.Champ.QOptions.C:Value() then
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

class "Poppy"

function Poppy:__init()

	self.Spells =
				{
				[0] = { range = 430, speed = math.huge, delay = 0.25, width = 100},
				[1] = { range = 400, mana = 50,},
				[2] = { range = 425, push = 300, mana = 70, speed = 1150, delay = 0.25},
				[3] = { range = 425, mana = 100, speed = 1150, delay = 0.25},--475
				}

	self.DashTable = 
				{
				["AAtrox"] 		= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Ahri"] 		= { SpellSlot = 3, type = "Untarget", 	Name = "R"},
				["Akali"] 		= { SpellSlot = 3, type = "Target", 	Name = "R"},
				["Alistar"] 	= { SpellSlot = 1, type = "Target", 	Name = "Q"},
				--["Amumu"] 	= { SpellSlot = }
				--["Aurelion"] 	= { SpellSlot = }
				["Azir"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Braum"] 		= { SpellSlot = 1, type = "Target", 	Name = "W"},
				["Caitlyn"] 	= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Corki"] 		= { SpellSlot = 1, type = "Untarget", 	Name = "W"},
				["Diana"] 		= { SpellSlot = 3, type = "Target", 	Name = "R"},
				["Ekko"]		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Fiora"] 		= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Fizz"]		= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Gnar"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Gragas"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Graves"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Hecarim"] 	= { SpellSlot = 3, type = "Untarget",	Name = "R"},
				["Irelia"] 		= { SpellSlot = 0, type = "Target", 	Name = "Q"},
				--["JarvanIV"] 	= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Jax"] 		= { SpellSlot = 0, type = "Target", 	Name = "Q"},
				["Jayce"] 		= { SpellSlot = 0, type = "Target", 	Name = "Q"},
				["Kalista"] 	= { SpellSlot = 0, type = "Target", 	Name = "Q"},
				["Khazix"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Kindred"] 	= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["LeeSin"] 		= { SpellSlot = 0, type = "Target", 	Name = "Q"},
				["Leona"] 		= { SpellSlot = 2, type = "Target", 	Name = "E"},
				["Lucian"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Malphite"] 	= { SpellSlot = 3, type = "Untarget", 	Name = "R"},
				["Nidalee"] 	= { SpellSlot = 1, type = "Untarget", 	Name = "W"},
				["Nocturne"] 	= { SpellSlot = 3, type = "Target", 	Name = "R"},
				--["Nocturne"]   	= {Spellslot = _R},
				["Pantheon"] 	= { SpellSlot = 1, type = "Target", 	Name = "W"},
				["Quinn"] 		= { SpellSlot = 2, type = "Target", 	Name = "E"},
				["RekSai"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Renekton"] 	= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Riven"] 		= { SpellSlot = 1, type = "Untarget", 	Name = "Q"},
				["Riven"]		= {	SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Sejuani"] 	= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Shen"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Shyvana"] 	= { SpellSlot = 3, type = "Untarget", 	Name = "R"},
				--["Thresh"] 	= { SpellSlot = ?, type = "Target", 	Name = ?},
				["Tristana"] 	= { SpellSlot = 2, type = "Untarget", 	Name = "W"},
				["Tryndamere"] 	= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				["Vayne"] 		= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Vi"] 			= { SpellSlot = 0, type = "Untarget", 	Name = "Q"},
				["Wukong"] 		= { SpellSlot = 2, type = "Target", 	Name = "E"},
				["XinZhao"] 	= { SpellSlot = 2, type = "Target", 	Name = "E"},
				["Yasuo"] 		= { SpellSlot = 2, type = "Target", 	Name = "E"},
				["Zac"] 		= { SpellSlot = 2, type = "Untarget", 	Name = "E"},
				}
	
	self.ChannelTable =
				{
			    ["Caitlyn"]         = { SpellSlot = 3, Name = "R"},
			    ["FiddleSticks"]	= { SpellSlot = 1, Name = "W"},
			    ["FiddleSticks"]	= { SpellSlot = 3, Name = "R"},
			    ["Galio"]           = { SpellSlot = 3, Name = "R"},
			    ["Janna"]           = { SpellSlot = 3, Name = "R"},
				["Jhin"]			= { SpellSlot = 3, Name = "R"},
			    ["Karthus"]         = { SpellSlot = 3, Name = "R"},
			    ["Katarina"]        = { SpellSlot = 3, Name = "R"},
			    ["Lucian"]          = { SpellSlot = 3, Name = "R"},
			    ["Malzahar"]        = { SpellSlot = 3, Name = "R"},
			    ["MissFortune"]     = { SpellSlot = 3, Name = "R"},
			    ["Nunu"]            = { SpellSlot = 3, Name = "R"},                       
			    ["Pantheon"]        = { SpellSlot = 3, Name = "R"},
			    ["Shen"]            = { SpellSlot = 3, Name = "R"},
			    ["TwistedFate"]    	= { SpellSlot = 3, Name = "R"},
			    ["Urgot"]          	= { SpellSlot = 3, Name = "R"},
			    ["Varus"]           = { SpellSlot = 0, Name = "R"},
			    ["Velkoz"]          = { SpellSlot = 3, Name = "R"},
			    ["Warwick"]         = { SpellSlot = 3, Name = "R"},
			    ["Xerath"]        	= { SpellSlot = 3, Name = "R"},
	
				}
	self.Object = nil
	self.Flash = nil
	self.Target = nil
	if GetCastName(myHero, SUMMONER_1):lower():find("summonerflash") then
		self.Flash = SUMMONER_1
	elseif GetCastName(myHero, SUMMONER_2):lower():find("summonerflash") then
		self.Flash = SUMMONER_2
	else
		self.Flash = nil
	end

	MainMenu.Champ:Menu("C", "Combo")
	MainMenu.Champ.C:Boolean("Q", "Use Q", true)
	MainMenu.Champ.C:Boolean("E", "Use E", true)
	MainMenu.Champ.C:Boolean("R", "Use R", true)
	MainMenu.Champ.C:SubMenu("ASC", "Auto Stun ONLY in Combo", true)
	MainMenu.Champ.C.ASC:Boolean("AS", "Auto Stun enable?", true)
	MainMenu.Champ.C:KeyBinding("I", "Insec Flash+E", string.byte("Y"), false) 

	MainMenu.Champ:Menu("H", "Harass")
	MainMenu.Champ.H:Boolean("Q", "Use Q", true)
	MainMenu.Champ.H:Boolean("E", "Use E", true)

	MainMenu.Champ:Menu("LC", "LaneClear")
	MainMenu.Champ.LC:Boolean("Q", "Use Q", true)
	MainMenu.Champ.LC:Slider("MM", "Mana manager", 50, 1, 100)

	MainMenu.Champ:Menu("JC", "JunglerClear")
	MainMenu.Champ.JC:Boolean("Q", "Use Q", true)
	MainMenu.Champ.JC:Boolean("E", "Use E", true)
	MainMenu.Champ.JC:Slider("MM", "Mana manager", 50, 1, 100)


	MainMenu.Champ:Menu("M", "Misc")
	MainMenu.Champ.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})
	MainMenu.Champ.M:DropDown("S", "Skin", 1, {"Classic", "Noxus", "Blacksmith", "Lollipoppy","Ragdoll", "Battle Regalia", "Scarlet Hammer", "Off"})

	MainMenu.Champ:Menu("Orb", "Hotkeys")
	MainMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
	MainMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
	MainMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	MainMenu.Champ:Menu("F", "Fuck Dashes")

	MainMenu.Champ:Menu("ASA", "Auto Stun")
	MainMenu.Champ.ASA:Boolean("AS", "Auto Stun enable?", true)
	MainMenu.Champ.ASA:KeyBinding("T", "Flash-Stun", string.byte("T"), false)

	MainMenu.Champ:Menu("IN", "Interrupt")

	DelayAction(function()
		for _, enemies in pairs(GetEnemyHeroes()) do
			if self.DashTable[GetObjectName(enemies)] then 
				MainMenu.Champ.F:Boolean("Pleb"..GetObjectName(enemies), "Interrupt "..GetObjectName(enemies).." Dash "..self.DashTable[GetObjectName(enemies)].Name, true)
			end
			if self.ChannelTable[GetObjectName(enemies)] then
				MainMenu.Champ.IN:Boolean("Pleb"..GetObjectName(enemies), "Interrupt "..GetObjectName(enemies).." "..self.ChannelTable[GetObjectName(enemies)].Name, true)
			end

			MainMenu.Champ.ASA:Boolean("Pleb"..GetObjectName(enemies), "Auto Stun On "..GetObjectName(enemies), true)
			MainMenu.Champ.C.ASC:Boolean("Pleb"..GetObjectName(enemies), "Auto Stun On "..GetObjectName(enemies), true)
		end
	end, 0.1)

	OnTick(function(myHero) self:Tick(myHero) end)
	OnProcessSpell(function(Object, spellProc) self:OnProc(Object, spellProc) end)
end

function Poppy:Tick(myHero)
	self:Stun()
	self:Insec()
	self:SkinChanger()
	self:Autolvl()
	self.Target = CustomTarget
	if MainMenu.Champ.Orb.C:Value() then
		self:Combo(self.Target)
	end
	if MainMenu.Champ.Orb.H:Value() then
		self:Harass(self.Target)
	end
	if MainMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
	end
end

function Poppy:SkinChanger()
	if MainMenu.Champ.Misc.S:Value() ~= 8 then 
		HeroSkinChanger(myHero, MainMenu.Champ.Misc.S:Value() - 1)
	elseif MainMenu.Champ.Misc.S:Value() == 8 then
		HeroSkinChanger(myHero, 0)
	end
end

function Poppy:Combo(Unit)
	if ValidTarget(Unit, 200) then
		self:UseQ(Unit)
		self:UseE(Unit)
		self:UseR(Unit)
	elseif ValidTarget(Unit, 400) then
		self:UseE(Unit)
		DelayAction(function() self:UseQ(Unit) end, GetDistance(Unit)/self.Spells[2].speed)
		self:UseR(Unit)
	end
end

function Poppy:Harass(Unit)
	if ValidTarget(Unit, GetRange(myHero)) then
		self:UseQ(Unit)
		self:UseE(Unit)
	elseif ValidTarget(Unit, 400) then
		self:UseE(Unit)
		DelayAction(function() self:UseQ(Unit) end, GetDistance(Unit)/self.Spells[2].speed)
	end
end

function Poppy:LaneClear()
	local QMana = (30+5*GetCastLevel(myHero, 0)*100)/GetMaxMana(myHero)
	local EMana = (self.Spells[2].mana*100)/GetMaxMana(myHero)
	for _, mobs in pairs(minionManager.objects) do
		if ValidTarget(mobs, 400) then
			if GetTeam(mobs) == 200 then
				if Ready(0) and MainMenu.Champ.LC.Q:Value() and ValidTarget(mobs, self.Spells[0].range) then
					CastSkillShot(0, GetOrigin(mobs))
				end
			elseif GetTeam(mobs) == 300 then
				local MyPos = GetOrigin(myHero) + Vector(GetOrigin(mobs) - Vector(GetOrigin(myHero))):normalized()*GetDistance(mobs) + Vector(GetOrigin(mobs) - Vector(GetOrigin(myHero))):normalized()*325
				if Ready(0) and MainMenu.Champ.JC.Q:Value() and (GetPercentMP(myHero)- QMana) >= MainMenu.Champ.JC.MM:Value() and ValidTarget(mobs, self.Spells[0].range) then
					CastSkillShot(0, GetOrigin(mobs))
				end
				if Ready(2) and MainMenu.Champ.JC.E:Value() and (GetPercentMP(myHero)- EMana) >= MainMenu.Champ.JC.MM:Value() and MapPosition:inWall(MyPos) and ValidTarget(mobs, self.Spells[2].range) then
						CastTargetSpell(mobs, 2)
				end
			end
		end
	end
end

function Poppy:UseQ(Unit)
	local Q = GetPrediction(Unit, self.Spells[0])
	if Ready(0) and ValidTarget(Unit, self.Spells[0].range) and MainMenu.Champ.C.Q:Value() and Q and Q.hitChance >= 0.20 then
		CastSkillShot(0, Q.castPos)
	end
end

function Poppy:UseE(Unit)
	if Ready(2) and ValidTarget(Unit, self.Spells[2].range) and MainMenu.Champ.C.E:Value() then
		CastTargetSpell(Unit, 2)
	end
end

function Poppy:UseR(Unit)
	local R = GetPrediction(Unit, self.Spells[3])
	if Ready(3) and ValidTarget(Unit, 425) and MainMenu.Champ.C.R:Value() and R and R.hitChance >= 0.20 then
		CastSkillShot(3, GetOrigin(myHero))
		DelayAction(function()
			CastSkillShot2(3, R.castPos)
		end, 0.1)
	end
end

function Poppy:Stun()
	for _, enemies in pairs(GetEnemyHeroes()) do
		local E = GetPrediction(enemies, self.Spells[2])
		local MousePos = GetMousePos()
		local MyPos = GetOrigin(myHero) + Vector(E.castPos - Vector(GetOrigin(myHero))):normalized()*GetDistance(enemies) + Vector(E.castPos - Vector(GetOrigin(myHero))):normalized()*325
		local MyMousePos = MousePos + Vector(E.castPos - Vector(MousePos)):normalized()*GetDistance(enemies, MousePos) + Vector(E.castPos - Vector(MousePos)):normalized()*325
		if ValidTarget(enemies, 400) and Ready(2) then
			if not MainMenu.Champ.ASA.AS:Value() and MainMenu.Champ.C.ASC.AS:Value() and MainMenu.Champ.C.ASC["Pleb"..GetObjectName(enemies)] and MainMenu.Champ.Orb.C:Value() and MapPosition:inWall(MyPos) then
				CastTargetSpell(enemies, 2)
			elseif MainMenu.Champ.ASA.AS:Value() and not MainMenu.Champ.C.ASC.AS:Value() and MainMenu.Champ.ASA["Pleb"..GetObjectName(enemies)] and MapPosition:inWall(MyPos) then
				CastTargetSpell(enemies, 2)
			end
		elseif GetDistance(enemies, MousePos) <= 425 and MapPosition:inWall(MyMousePos) and MainMenu.Champ.ASA.T:Value() and Ready(2) then
			CastSkillShot(self.Flash, MousePos)
			DelayAction(function() CastTargetSpell(enemies, 2) end, 0.1)
		end
	end
end

function Poppy:OnProc(Object, spellProc)
	for i, enemies in pairs(GetEnemyHeroes()) do
		DelayAction(function()
			if self.DashTable[GetObjectName(enemies)] then
				if self.DashTable[GetObjectName(enemies)].type == "Untarget" then
					if spellProc.name == GetCastName(enemies, self.DashTable[GetObjectName(enemies)].SpellSlot) and MainMenu.Champ.F["Pleb"..GetObjectName(enemies)] and (GetDistance(spellProc.endPos) <= self.Spells[1].range or GetDistance(spellProc.startPos) <= self.Spells[1].range) and Ready(1) then
						CastSpell(1)
					end
				elseif self.DashTable[GetObjectName(enemies)].type == "Target" then
					if spellProc.name == GetCastName(enemies, self.DashTable[GetObjectName(enemies)].SpellSlot) and MainMenu.Champ.F["Pleb"..GetObjectName(enemies)] and GetDistance(spellProc.target) <= self.Spells[1].range and Ready(1) then
						CastSpell(1)
					end
				end
			end
			if self.ChannelTable[GetObjectName(enemies)] then
				if spellProc.name == GetCastName(enemies, self.ChannelTable[GetObjectName(enemies)].SpellSlot) and ValidTarget(enemies, 400) and Ready(2) then
					CastTargetSpell(enemies, 2)
				end
			end
		end, 0.0001)
	end
end

function Poppy:Insec()
	for _, enemies in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemies, 400) and Ready(2) and MainMenu.Champ.C.I:Value() then
			local FlashPos = GetOrigin(myHero) + Vector(GetOrigin(enemies)-Vector(GetOrigin(myHero))):normalized()*425
			CastSkillShot(self.Flash, FlashPos)
			DelayAction(function() CastTargetSpell(enemies, 2) end, 0.1)
		end
	end
end

function Poppy:Autolvl()
	if MainMenu.Champ.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) >= 1 then
			if MainMenu.Champ.M.AL:Value() == 1 then Deftlevel = { _Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W }
			elseif MainMenu.Champ.M.AL:Value() == 2 then Deftlevel = { _E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W }
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(1, 2)) --kappa
		end
	end
end


class "Elise"

function Elise:__init()

	self.HSpells =
				{
				[0] = {range = 625},
				[1] = {range = 950},
				[2] = {range = 1075, width = 70, speed = 1450, delay = 0.250}
				}

	self.SSpells =
				{
				[0] = {range = 475},
				[2] = {range = 750},
				}
	self.HDmg =
				{
				[0] = function(Unit) return CalcDamage(myHero, Unit, 0, 5+35*GetCastLevel(myHero, 0)+(GetCurrentHP(Unit)*0.04)/100+0.03*GetBonusAP(myHero)) end,
				[1] = function(Unit) return CalcDamage(myHero, Unit, 0, 20+50*GetCastLevel(myHero, 1)+0.8*GetBonusAP(myHero)) end,
				}
	self.SDmg = 
				{
				[0] = function(Unit) return CalcDamage(myHero, Unit, 0, 20+40*GetCastLevel(myHero, 0)+((GetMaxHP(Unit)-GetCurrentHP(Unit)*0.08)/100+0.03*GetBonusAP(myHero)))  end,
				}

	self.HReady =
			{
			[0] = true,
			[1] = true,
			[2] = true,
			}
	self.SReady =
			{
			[0] = true,
			[1] = true,
			[2] = true,
			}
	self.Spots = 
			{
			{x = 8414, y = 51, z = 2711},
			{x = 7750, y = 54, z = 3979},
			{x = 6969, y = 52, z = 5414},
			{x = 3791, y = 52, z = 6484},
			{x = 3800, y = 52, z = 7953},
			{x = 2121, y = 51, z = 8432},
			{x = 6472, y = 56, z = 12168},
			{x = 7050, y = 56, z = 10881},
			{x = 7850, y = 52, z = 9415},
			{x = 10987, y = 62, z = 8370},
			{x = 10869, y = 51, z = 7034},
			{x = 12654, y = 51, z = 6407},	
			}
	self.Spider = nil
	self.WBuff = nil

	MainMenu.Champ:Menu("C", "Combo")
	MainMenu.Champ.C:Boolean("Q", "Use Human Q in Combo", true)
	MainMenu.Champ.C:Boolean("W", "Use Human W in Combo", true)
	MainMenu.Champ.C:Boolean("SQ", "Use Spider Q in Combo", true)
	MainMenu.Champ.C:Boolean("SW", "Use Spider W in Combo", true)
	MainMenu.Champ.C:Boolean("S", "Use Logic R Combo", true)

	MainMenu.Champ:Menu("JC", "JunglerClear")
	MainMenu.Champ.JC:Boolean("Q", "Use Human Q in JunglerClear", true)
	MainMenu.Champ.JC:Boolean("W", "Use Human W in JunglerClear", true)
	MainMenu.Champ.JC:Boolean("SQ", "Use Spider Q in JunglerClear", true)
	MainMenu.Champ.JC:Boolean("SW", "Use Spider W in JunglerClear", true)
	MainMenu.Champ.JC:Boolean("S", "Use Logic R JunglerClear", true)

	MainMenu.Champ:Menu("KS", "KillSteal")
	MainMenu.Champ.KS:Boolean("Q", "Use Human Q in KillSteal", true)
	MainMenu.Champ.KS:Boolean("W", "Use Human W in KillSteal", true)
	MainMenu.Champ.KS:Boolean("SQ", "Use Spider Q in KillSteal", true)
	MainMenu.Champ.KS:Boolean("SW", "Use Spider W in KillSteal", true)

	MainMenu.Champ:Menu("M", "Misc")
	MainMenu.Champ.M:DropDown("AL", "Autolvl", 1, {"Q-E-W", "E-Q-W", "Off"})

	MainMenu.Champ:Menu("Orb", "Hotkeys")
	MainMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
	MainMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	MainMenu.Champ:Menu("E", "E Options")

	MainMenu.Champ:Menu("HC", "HitChance")
	MainMenu.Champ.HC:Slider("E", "E HitChance", 20, 1, 100)

	DelayAction(function()
		for _, enemies in pairs(GetEnemyHeroes()) do
			MainMenu.Champ.E:Boolean("Pleb"..GetObjectName(enemies), "Use E on "..GetObjectName(enemies), true)
		end
	end, 0.1)

	OnTick(function(myHero) self:Tick(myHero) end)
	OnProcessSpell(function(unit, spellProc) self:OnProc(unit, spellProc) end)
	OnUpdateBuff(function(unit, buffproc) self:OnUpdate(unit, buffproc) end)
	OnRemoveBuff(function(unit, buffproc) self:OnRemove(unit, buffproc) end)
end

function Elise:Tick(myHero)
	if not IsDead(myHero) then
		if MainMenu.Champ.Orb.C:Value() then
			self:Combo(GetCurrentTarget())
		end
		if MainMenu.Champ.Orb.LC:Value() then
			self:LaneClear()
		end
		self:KS()
	end
end

function Elise:Combo(Unit)
	if not self.Spider then
		self:CastQ(Unit)
		self:CastW(Unit)
		self:CastE()
		if not self.Spider and not self.HReady[0] and not self.HReady[1] and (self.HReady[2] or not self.HReady[2]) and self.SReady[0] and self.SReady[1] and Ready(3) then
			CastSpell(3)
		end
	end
	if not self.Spider and not Ready(3) then
		local E = GetPrediction(Unit, self.HSpells[2])
		self:CastQ(Unit)
		self:CastW(Unit)
		if self.HReady[2] and E and E.hitChance >= (MainMenu.Champ.HC.E:Value())/100 and ValidTarget(Unit, self.HSpells[2].range) and not self.Spider then
			CastSkillShot(2, E.castPos)
		end
	end
	if self.Spider and ValidTarget(Unit, self.SSpells[0].range) then
		if self.SReady[0] then
			CastTargetSpell(Unit, 0)
		end
		if self.SReady[1] then
			CastSpell(1)
		end
		if Ready(3) and not self.WBuff and self.HReady[0] and self.HReady[1] and not self.SReady[0] and not self.SReady[1] then
			CastSpell(3)
		end
	end
end

function Elise:LaneClear()
	for k, mobs in pairs(minionManager.objects) do
		if GetTeam(mobs) == 300 and ValidTarget(mobs, self.HSpells[2].range) then
			if self.Spider then
				if self.SReady[1] then
					CastSpell(1)
				end
				if self.SReady[0] then
					CastTargetSpell(mobs, 0)
				end
			end
			if not self.Spider then
				self:CastQ(mobs)
				self:CastW(mobs)
				if not self.Spider and not self.HReady[0] and not self.HReady[1] then
					CastSpell(3)
				end
			end
		elseif GetTeam(mobs) == 200 and ValidTarget(mobs, self.HSpells[2].range) then
			if self.Spider then
				if self.SReady[1] then
					CastSpell(1)
				end
				if self.SReady[0] then
					CastTargetSpell(mobs, 0)
				end
			elseif not self.Spider then
				self:CastQ(mobs)
				self:CastW(mobs)
				if not self.Spider and not self.HReady[0] and not self.HReady[1] then
					CastSpell(3)
				end
			end
		end
	end
end

function Elise:KS()
	for k, enemies in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemies, self.HSpells[0].range) and self.HReady[0] and GetCurrentHP(enemies) <= self.HDmg[0](enemies) then
			self:CastQ(enemies)
		elseif ValidTarget(enemies, self.HSpells[1].range) and self.HReady[1] and GetCurrentHP(enemies) <= self.HDmg[1](enemies) then
			self:CastW(enemies)
		elseif ValidTarget(enemies, self.HSpells[0].range) and self.HReady[0] and self.HReady[1] and GetCurrentHP(enemies) <= self.HDmg[0](enemies) + self.HDmg[1](enemies) then
			self:CastW(enemies)
			DelayAction(function() self:CastW(enemies) end, GetDistance(enemies)/1200)
		elseif ValidTarget(enemies, self.SSpells[0].range) and not self.Spider and self.HReady[0] and self.HReady[1] and self.SReady[0] and Ready(3) and GetCurrentHP(enemies) <= self.HDmg[0](enemies) + self.HDmg[1](enemies) + self.SDmg[0](enemies) then
			self:CastW(enemies)
			self:CastQ(enemies)
			DelayAction(function() CastSpell(3) end, 0.1)
			DelayAction(function() self:CastSQ(enemies) end, 0.3)
		elseif ValidTarget(enemies, self.SSpells[0].range) and self.Spider and self.SReady[0] and GetCurrentHP(enemies) <= self.SDmg[0](enemies) then
			self:CastSQ(enemies)
		end
	end
end

function Elise:CastQ(Unit)
	if self.HReady[0] and ValidTarget(Unit, self.HSpells[0].range) then
		CastTargetSpell(Unit, 0)
	end
end

function Elise:CastW(Unit)
	local W = GetPrediction(Unit, self.HSpells[1])
	if self.HReady[1] and ValidTarget(Unit, self.HSpells[1].range) then
		CastSkillShot(1, W.castPos)
	end
end

function Elise:CastE()
	if not self.Spider then
		for k, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, self.HSpells[2].range) then
				local E = GetPrediction(enemies, self.HSpells[2])
				if MainMenu.Champ.E["Pleb"..GetObjectName(enemies)] and self.HReady[2] and E and E.hitChance >= (MainMenu.Champ.HC.E:Value())/100 and not E:mCollision(1) then
					CastSkillShot(2, E.castPos)
				end
			end
		end
	end
end

function Elise:Autolvl()
	if MainMenu.Champ.M.AL:Value() ~= 3 then
		if GetLevelPoints(myHero) >= 1 then
			if MainMenu.Champ.M.AL:Value() == 1 then Deftlevel = { _Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W }
			elseif MainMenu.Champ.M.AL:Value() == 2 then Deftlevel = { _E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W }
			end
			DelayAction(function() LevelSpell(Deftlevel[GetLevel(myHero)-GetLevelPoints(myHero)+1]) end, math.random(1, 2)) --kappa
		end
	end
end

function Elise:OnProc(unit, spellProc)
	if unit == myHero then
		if spellProc.name == "EliseHumanQ" then
			self.HReady[0] = false
			DelayAction(function() self.HReady[0] = true end, (6*100-GetCDR(myHero))/100)
		elseif spellProc.name == "EliseHumanW" then
			self.HReady[1] = false
			DelayAction(function() self.HReady[1] = true end, (12*100-GetCDR(myHero))/100)
		elseif spellProc.name == "EliseHumanE" then
			self.HReady[2] = false
			DelayAction(function() self.HReady[2] = true end, (15-1*GetCastLevel(myHero, 2)*100-GetCDR(myHero))*100)
		elseif spellProc.name == "EliseSpiderQCast" then
			self.SReady[0] = false
			DelayAction(function() self.SReady[0] = true end, (6*100-GetCDR(myHero))/100)
		elseif spellProc.name == "EliseSpiderW" then
			self.SReady[1] = false
			DelayAction(function() self.SReady[1] = true end, (12*100-GetCDR(myHero))/100)
		elseif spellProc.name == "EliseSpiderEInitial" then
			self.SReady[2] = false
			DelayAction(function() self.SReady[2] = true end, (27-3*GetCastLevel(myHero, 2)*100-GetCDR(myHero))*100)
		end
	end
end

function Elise:OnUpdate(unit, buffproc)
	if unit == myHero then
		if buffproc.Name == "EliseR" then
			self.Spider = true
		end
		if buffproc.Name == "EliseSpiderW" then
			self.WBuff = true
		end
	end
end

function Elise:OnRemove(unit, buffproc)
	if unit == myHero then
		if buffproc.Name == "EliseR" then
			self.Spider = false
		end
		if buffproc.Name == "EliseSpiderW" then
			self.WBuff = false
		end
	end
end

class "TargetSelector"

function TargetSelector:__init()
	CustomTarget = nil
	MainMenu.T:DropDown("ts", "Select Mode", 1, {"Closest", "Closest to mouse", "Most AP", "Most AD", "Lowest Health", "Less Cast"})
	OnTick(function(myHero) self:Tick(myHero) end)
end

function TargetSelector:Targets()
	if MainMenu.T.ts:Value() == 1 then
		local closest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if not closest and enemies then
				closest = enemies
			end
			if GetDistance(enemies) < GetDistance(closest) then
				closest = enemies
			end
		end
		return closest
	elseif MainMenu.T.ts:Value() == 2 then
		local closest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if not closest and enemies then
				closest = enemies
			end
			if GetDistance(enemies, GetMousePos()) <= GetDistance(closest, GetMousePos()) then
				closest = enemies
			end
		end
		return closest
	elseif MainMenu.T.ts:Value() == 3 then
		local MostAp = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if not MostAp and enemies then
			MostAp = enemies
			end
			if GetBonusAP(enemies) > GetBonusAP(MostAp) then
				MostAp = enemies
			end
		end
		return MostAp
	elseif MainMenu.T.ts:Value() == 4 then
		local MostAD = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if not MostAD and enemies then
				MostAD = enemies
			end
			if (GetBaseDamage(enemies) + GetBonusDmg(enemies)) > (GetBaseDamage(MostAD) + GetBonusDmg(MostAD)) then
				MostAD = enemies
			end
		end
		return MostAD
	elseif MainMenu.T.ts:Value() == 5 then
		local Lowest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if not Lowest and enemies then
				Lowest = enemies
			end
			if GetCurrentHP(enemies) > GetCurrentHP(Lowest) then
				Lowest = enemies
			end
		end
		return Lowest
	elseif MainMenu.T.ts:Value() == 6 then
		local LessCast = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			local Dmg = CalcDamage(myHero, enemies, 50, 50)
			if not LessCast and enemies then
				LessCast = enemies
			end
			if GetCurrentHP(enemies)/Dmg > GetCurrentHP(LessCast)/Dmg then
				LessCast = enemies
			end
		end
		return LessCast
	end

end

function TargetSelector:Tick(myHero)
	CustomTarget = self:Targets()
end

