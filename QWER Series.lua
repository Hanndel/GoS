require "OpenPredict"

local ChampTable =
	--Set = {"Kindred", "Zyra", "Poppy", "Elise", "Irelia", "Nidalee", "Riven", "Singed", "Olaf"}
	{
	["Kindred"] 	= true,
	--["Zyra"] 		= true,
	["Poppy"] 		= true,
	["Elise"]	 	= true,
	["Irelia"]		= true,
	["Nidalee"] 	= true,
	["Singed"] 		= true,
	}


Callback.Add("Load", function()
	if ChampTable[GetObjectName(myHero)] then
		Start()
		DickSelector()
		SkinChanger()
		Autolvl()
		_G[GetObjectName(myHero)]()
		if GetObjectName(myHero) ~= "Nidalee" then
			DmgDraw()
		end
		require"Analytics"
		Analytics("QWER-Series","Hanndel")
		if GetCastName(myHero,4):lower():find("summonersmite") or GetCastName(myHero,5):lower():find("summonersmite") then
			AutoSmite()
		end
		PrintChat("Welcome "..GetUser().." to QWER Series!")
		PrintChat(GetObjectName(myHero).." Loaded!")
	else
		PrintChat(GetObjectName(myHero).." Is not supported!")
	end
	if GetObjectName(myHero) == "Kindred" or GetObjectName(myHero) == "Poppy" or GetObjectName(myHero) == "Nidalee" or GetObjectName(myHero) == "Gnar" then
		require('MapPositionGOS')
	end
end)



local ver = "0.5"

class "Start"

function Start:__init()
	if GetUser() ~= "Hanndel" then 
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
	if not FileExist(COMMON_PATH.."Analytics.lua") then
		DownloadFileAsync("https://raw.githubusercontent.com/LoggeL/GoS/master/Analytics.lua", COMMON_PATH .. "Analytics.lua", function() PrintChat("Analytics Downloaded, F6x2!") return end)
	else
		require"Analytics"
	end
	local myName = myHero.charName
	ConfigMenu = MenuConfig("QWER Series", "QWER Series")
		ConfigMenu:Menu("Champ", "QWER "..myName)
end

class "SkinChanger"

function SkinChanger:__init()
	local Table = 
		{
		["Kindred"] 	= {"Classic", "ShadowFire"},
		["Zyra"] 		= {"Classic", "Wildire", "Haunted", "Skt"},
		["Poppy"] 		= {"Classic", "Noxus", "Blacksmith", "Lollipoppy","Ragdoll", "Battle Regalia", "Scarlet Hammer"},
		["Elise"]	 	= {"Classic", "Death Blossom", "Victorious", "Blood Moon"},
		["Irelia"]		= {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostbutt", "Lotus"},
		--["Nidalee"]		= {"Classic", "Snow Bunny", "Leopard", "Hot Maid", "Pharaoh", "Bewitching", "HeadHunter", "Warring Kindomgs", "Challenger"}
		}

	if Table[GetObjectName(myHero)] then
		ConfigMenu:Menu("SK", "Skinchanger")--
			ConfigMenu.SK:DropDown("S", "SkinChanger", 1, Table[GetObjectName(myHero)], function() HeroSkinChanger(myHero, ConfigMenu.SK.S:Value() - 1) end)
	end
end

class "Autolvl"

function Autolvl:__init()
	ConfigMenu:Menu("AL", "Auto Lvl")
		ConfigMenu.AL:DropDown("ALT", "Auto lvl table", 7, {"QWE", "QEW", "WQE", "WEQ", "EWQ", "EQW", "Off"})

	self.Table2 = 
				{
				[1] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E},
				[2] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W},
				[3] = {_W,_Q,_E,_W,_W,_R,_W,_Q,_W,_Q,_R,_Q,_Q,_E,_E,_R,_E,_E},
				[4] = {_W,_E,_Q,_W,_W,_R,_W,_E,_W,_E,_R,_E,_E,_Q,_Q,_R,_Q,_Q},
				[5] = {_E,_W,_Q,_E,_E,_R,_E,_W,_E,_W,_R,_W,_W,_Q,_Q,_R,_Q,_Q},
				[6] = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W},
				}
	OnTick(function(myHero) self:Autolvl(myHero) end)
end

function Autolvl:Autolvl(myHero)
	if ConfigMenu.AL.ALT:Value() ~= 7 then
		if GetLevelPoints(myHero) >= 1 then
			--DelayAction(function() LevelSpell(self.Table2[ConfigMenu.AL.ALT:Value()][GetLevel(myHero) - GetLevelPoints(myHero) + 1]) end, math.random(1, 2))
		end
	end
end

class "AutoSmite"

function AutoSmite:__init()

	self.Mobs = 
	{
		[1] = 	{BaseName = "SRU_Baron", 			Name = "Baron"},
		[2] = 	{BaseName = "SRU_Dragon_Water", 	Name = "Water Drake"},
		[3] = 	{BaseName = "SRU_Dragon_Fire", 		Name = "Fire Drake"},
		[4] = 	{BaseName = "SRU_Dragon_Earth", 	Name = "Earth Drake"},
		[5] = 	{BaseName = "SRU_Dragon_Air", 		Name = "Air Drake"},
		[6] = 	{BaseName = "SRU_Dragon_Elder", 	Name = "Elder Drake"},
		[7] = 	{BaseName = "SRU_RiftHerald", 		Name = "Herald"},
		[8] = 	{BaseName = "Sru_Crab", 			Name = "Crab"},
		[9] = 	{BaseName = "SRU_Blue", 			Name = "Blue"},
		[10] = 	{BaseName = "SRU_Red", 				Name = "Red"}
	}

	self.Smite = nil
	self.SmiteDmgM = {[1] = 390, [2] = 410, [3] = 430, [4] = 450 ,[5] = 480, [6] = 510, [7] = 540, [8] = 570, [9] = 600, [10] = 640, [11] = 680, [12] = 720, [13] = 760, [14] = 800, [15] = 850, [16] = 900, [17] = 950, [18] = 1000}
	self.SmiteHDmg = 20+8*GetLevel(myHero) 
	self.PacketTable = {[110] = true, [99] = true, [257] = true}
	self.SmiteDMG = false
	self.Table = 
	{
		["Poppy"] = 
		{	
			AADmg = function(Unit) return CalcDamage(myHero,Unit,(GetBaseDamage(myHero)+GetBonusDmg(myHero))) end,
			AADelay = function(Unit) return 0 end,
			[0] =
			{
				Range = function(Unit) return 430 end,
				Dmg = function(Unit) return CalcDamage(myHero, Unit, 15 + 20*GetCastLevel(myHero, 0) + GetBonusDmg(myHero)*0.8 + GetMaxHP(Unit)*0.007) end,
				Delay = function(Unit) return 332 + GetLatency() end,
				Cast = function(Unit) CastSkillShot(0, GetOrigin(Unit)) end,
			},
		},

		["Elise"] =
		{
			AADmg = function(Unit) return CalcDamage(myHero,Unit,(GetBaseDamage(myHero)+GetBonusDmg(myHero))) end,
			AADelay = function(Unit) return GetDistance(Unit)/2000 end,
			[0] =
			{
				Dmg = function(Unit) 		if Spider then 
												return CalcDamage(myHero, Unit, 0, 5+35*GetCastLevel(myHero, 0)+(GetCurrentHP(Unit)*0.04)/100+0.03*GetBonusAP(myHero)) 
											else 
												return CalcDamage(myHero, Unit, 0, 20+40*GetCastLevel(myHero, 0)+((GetMaxHP(Unit)-GetCurrentHP(Unit)*0.08)/100+0.03*GetBonusAP(myHero))) 
											end 
										end,

				Delay = function(Unit) 		if Spider then
												return GetDistance(Unit)/1200 + 250 + GetLatency()
											else
												return GetDistance(Unit)/3000 + 250 + GetLatency()
											end
										end,

				Range = function(Unit)		if Spider then
												return 475
											else
												return 625
											end
										end,

				Cast = function(Unit) CastTargetSpell(Unit, 0) end,
			},
		},

		["Kindred"] =
		{
			AADmg = function(Unit) return CalcDamage(myHero,Unit,(GetBaseDamage(myHero)+GetBonusDmg(myHero))) end,
			AADelay = function(Unit) return GetDistance(Unit)/2000 end,
		},

		["Irelia"] =
		{
			AADmg = function(Unit) return CalcDamage(myHero,Unit,(GetBaseDamage(myHero)+GetBonusDmg(myHero))) end,
			AADelay = function(Unit) return 0 end,
			[0] =
			{
				Range = function(Unit) return 650 end,
				Dmg = function(Unit) return CalcDamage(myHero, Unit, -10+30*GetCastLevel(myHero, 0) + (GetBaseDamage(myHero) + GetBonusDmg(myHero))) end,
				Delay = function(Unit) return GetDistance(Unit)/2000 end,
				Cast = function(Unit) CastTargetSpell(Unit, 0) end,
			},

			[2] =
			{
				Range = function(Unit) return 425 end,
				Dmg = function(Unit) return CalcDamage(myHero, Unit, 0, 40+40*GetCastLevel(myHero,_E)+GetBonusAP(myHero)*0.5) end,
				Delay = function(Unit) return 500 + GetLatency() end,
				Cast = function(Unit) CastTargetSpell(Unit, 2) end,
			},
		},

		["Nidalee"] =
		{
			AADmg = function(Unit) return CalcDamage(myHero,Unit,(GetBaseDamage(myHero)+GetBonusDmg(myHero))) end,
			AADelay = function(Unit)	if Human then
											return GetDistance(Unit)/1750
										else
											return 0
										end
									end,
			[0] =
			{
				Range = function(Unit) 	if Human then
											return 650
										else
											return 350
										end
									end,

				Dmg = function(Unit) 	if Human then
											local QHDmg = 42+17.5*GetCastLevel(myHero, 0) + GetBonusAP(myHero)*0.4
											if QHDmg + GetDistance(Unit)/100*QHDmg*0.258 > QHDmg*3 then 
												return CalcDamage(myHero,Unit, 0, QHDmg*3) 
											else 
												return CalcDamage(myHero,Unit, 0, QHDmg + GetDistance(Unit)/100*QHDmg*0.258) 
											end
										else
											local QCDmg = {[1] = 4, [2] = 20, [3] = 50, [4] = 90}
											local QCDmgM = {[1] = 1, [2] = 1.25, [3] = 1.5, [4] = 1.75}
											local Multi = {[1] = 2, [2] = 2.25, [3] = 2.5, [4] = 2.75}
											local Maths = QCDmg[GetCastLevel(myHero, 3)] + (GetBaseDamage(myHero)+GetBonusDmg(myHero))*0.75 + GetBonusAP(myHero)*0.36
											if Maths + Maths*(QCDmgM[GetCastLevel(myHero, 3)] * (GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit)) > Maths*Multi[GetCastLevel(myHero, 3)] then
												return CalcDamage(myHero, Unit, 0, Maths*Multi[GetCastLevel(myHero, 3)])
											else
												return CalcDamage(myHero, Unit, 0, Maths + Maths*(QCDmgM[GetCastLevel(myHero, 3)] * ((GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit)))*1.33)
											end
										end
									end,

				Delay = function(Unit)	if Human then
											return GetDistance(Unit)/1500
										else
											return 220 + GetLatency()
										end
									end,

				Cast = function(Unit)	if Human then
											CastSkillShot(0, GetOrigin(Unit))
										else
											CastSpell(0) DelayAction(function() AttackUnit(Unit) end, 0.1)
										end
									end,
			}
		}
	}


	if GetCastName(myHero,4):lower():find("summonersmite") then
		self.Smite = 4
	elseif GetCastName(myHero,5):lower():find("summonersmite") then
		self.Smite = 5
	else
		self.Smite = nil
	end

	if GetCastName(myHero,4) == "S5_SummonerSmitePlayerGanker" then
		self.SmiteDMG = true
	elseif GetCastName(myHero,5) == "S5_SummonerSmitePlayerGanker" then
		self.SmiteDMG = true
	else
		self.SmiteDmg = false
	end

	ConfigMenu:Menu("AS", "Auto Smite")
		ConfigMenu.AS:Boolean("ASE", "Auto Smite enable", true)
		ConfigMenu.AS:SubMenu("ASM", "Mobs options")
			for i = 1, #self.Mobs do
				ConfigMenu.AS.ASM:Boolean("Pleb"..self.Mobs[i].BaseName, "AutoSmite "..self.Mobs[i].Name, true)
			end
		ConfigMenu.AS:Boolean("ASK", "AutoSmite ks", true)
		ConfigMenu.AS:Boolean("ASQ", "Use Q", true)
		ConfigMenu.AS:Boolean("ASW", "Use W", true)
		ConfigMenu.AS:Boolean("ASEE", "Use E", true)
		ConfigMenu.AS:Boolean("ASA", "AA Smite", true)

	OnProcessPacket(function(Packet) self:Packets(Packet) end)
	OnProcessSpell(function(Object, spellProc) self:OnProc(Object, spellProc) end)
	OnTick(function(myHero) self:Tick(myHero) end)
end

function AutoSmite:Tick(myHero)
	for k, v in ipairs(GetEnemyHeroes()) do
		if GetCurrentHP(v) <= self.SmiteHDmg and ValidTarget(v, 500) and self.SmiteDMG and ConfigMenu.AS.ASK:Value() then
			CastTargetSpell(self.Smite, v)
		end
	end

	if ConfigMenu.AS.ASE:Value() and self.Table[GetObjectName(myHero)] ~= nil then
		for k, i in ipairs(minionManager.objects) do
			for v = 1, #self.Mobs do
				if self.Table[GetObjectName(myHero)][0] ~= nil and ConfigMenu.AS.ASQ:Value() then
					if GetObjectName(i) == self.Mobs[v].BaseName and ConfigMenu.AS.ASM["Pleb"..self.Mobs[v].BaseName]:Value() and GetDistance(i) <= self.Table[GetObjectName(myHero)][0].Range(i) and Ready(0) and Ready(self.Smite) then
						if GetCurrentHP(i) <= self.Table[GetObjectName(myHero)][0].Dmg(i) + self.SmiteDmgM[GetLevel(myHero)] then
							self.Table[GetObjectName(myHero)][0].Cast(i)
							DelayAction(function() CastTargetSpell(i, self.Smite) end, self.Table[GetObjectName(myHero)][0].Delay(i)/1000)
						end
					end
				end

				if self.Table[GetObjectName(myHero)][1] ~= nil and ConfigMenu.AS.ASW:Value() then
					if GetObjectName(i) == self.Mobs[v].BaseName and ConfigMenu.AS.ASM["Pleb"..self.Mobs[v].BaseName]:Value() and GetDistance(i) <= self.Table[GetObjectName(myHero)][0].Range(i) and Ready(1) and Ready(self.Smite) then
						if GetCurrentHP(i) <= self.Table[GetObjectName(myHero)][0].Dmg(i) + self.SmiteDmgM[GetLevel(myHero)] then
							self.Table[GetObjectName(myHero)][0].Cast(i)
							DelayAction(function() CastTargetSpell(i, self.Smite) end, self.Table[GetObjectName(myHero)][0].Delay(i)/1000)
						end
					end
				end

				if self.Table[GetObjectName(myHero)][2] ~= nil and ConfigMenu.AS.ASEE:Value() then
					if GetObjectName(i) == self.Mobs[v].BaseName and ConfigMenu.AS.ASM["Pleb"..self.Mobs[v].BaseName]:Value() and GetDistance(i) <= self.Table[GetObjectName(myHero)][0].Range(i) and Ready(2) and Ready(self.Smite) then
						if GetCurrentHP(i) <= self.Table[GetObjectName(myHero)][0].Dmg(i) + self.SmiteDmgM[GetLevel(myHero)] then
							self.Table[GetObjectName(myHero)][0].Cast(i)
							DelayAction(function() CastTargetSpell(i, self.Smite) end, self.Table[GetObjectName(myHero)][0].Delay(i)/1000)
						end
					end
				end
			end
		end
	end
end

function AutoSmite:OnProc(Object, spellProc)
	if self.Table[GetObjectName(myHero)] ~= nil and Object == myHero then
		if spellProc.name:lower():find("attack") then
			if Ready(self.Smite) then
				for v = 1, #self.Mobs do
					if GetObjectName(spellProc.target) == self.Mobs[v].BaseName and ConfigMenu.AS.ASM["Pleb"..self.Mobs[v].BaseName]:Value() then
						if GetCurrentHP(spellProc.target) <= self.Table[GetObjectName(myHero)].AADmg(spellProc.target) + self.SmiteDmgM[GetLevel(myHero)] then
							DelayAction(function() CastTargetSpell(spellProc.target, self.Smite) end, self.Table[GetObjectName(myHero)].AADelay(spellProc.target) + spellProc.windUpTime)
						end
					end
				end
			end
		end
	end
end

function AutoSmite:Packets(Packet)
	if self.PacketTable[Packet.header] then
		if Packet:Decode4() == GetNetworkID(myHero) then
			if GetCastName(myHero,4) == "S5_SummonerSmitePlayerGanker" then
				self.SmiteDMG = true
			elseif GetCastName(myHero,5) == "S5_SummonerSmitePlayerGanker" then
				self.SmiteDMG = true
			else
				self.SmiteDmg = false
			end
		end
	end
end

class "DickSelector"

function DickSelector:__init()
	self.Table =
	{
		[5] = Set {"Alistar", "Amumu", "Blitzcrank", "Braum", "ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "JarvanIV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac"},
		[4] = Set {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"},
		[3] = Set {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Janna", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nami", "Nidalee", "Riven", "Shaco", "Sona", "Soraka", "TahmKench", "Vladimir", "Yasuo", "Zilean", "Zyra"},
		[2] = Set {"Ahri", "Anivia", "Annie", "Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs", "Taliyah" },
		[1] = Set {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne", "Jhin", },
	}

	ConfigMenu:Menu("T", "TargetSelector")
		ConfigMenu.T:DropDown("ts", "Select Mode", 1, {"Closest", "Closest to mouse", "Most AP", "Most AD", "Lowest Health", "Less Cast", "Priority"}, 
			function() 
				if ConfigMenu.T.ts:Value() == 7 then 
					DelayAction(function() 
						for k, v in ipairs(GetEnemyHeroes()) do
							ConfigMenu.T:Slider(GetObjectName(v), "Priority: "..GetObjectName(v), (self.Table[5][GetObjectName(v)] and 5 or self.Table[4][GetObjectName(v)] and 4 or self.Table[3][GetObjectName(v)] and 3 or self.Table[2][GetObjectName(v)] and 2 or self.Table[1][GetObjectName(v)] and 1 or 1), 1, 5, 1) 
						end
					end, 0.1)
				elseif ConfigMenu.T.ts:Value() ~= 7 then
					print("F6x2")
				end
			end)
end

function DickSelector:Targets(Distance)
	if ConfigMenu.T.ts:Value() == 1 then
		local closest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if not closest and enemies then
					closest = enemies
				end

				if GetDistance(enemies) < GetDistance(closest) then
					closest = enemies
				end
			end
		end
		return closest

	elseif ConfigMenu.T.ts:Value() == 2 then
		local closest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if not closest and enemies then
					closest = enemies
				end

				if GetDistance(enemies, GetMousePos()) <= GetDistance(closest, GetMousePos()) then
					closest = enemies
				end
			end
		end
		return closest

	elseif ConfigMenu.T.ts:Value() == 3 then
		local MostAp = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if not MostAp and enemies then
				MostAp = enemies
				end

				if GetBonusAP(enemies) > GetBonusAP(MostAp) then
					MostAp = enemies
				end
			end
		end
		return MostAp

	elseif ConfigMenu.T.ts:Value() == 4 then
		local MostAD = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if not MostAD and enemies then
					MostAD = enemies
				end

				if (GetBaseDamage(enemies) + GetBonusDmg(enemies)) > (GetBaseDamage(MostAD) + GetBonusDmg(MostAD)) then
					MostAD = enemies
				end
			end
		end
		return MostAD

	elseif ConfigMenu.T.ts:Value() == 5 then
		local Lowest = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if not Lowest and enemies then
					Lowest = enemies
				end

				if GetCurrentHP(enemies) > GetCurrentHP(Lowest) then
					Lowest = enemies
				end
			end
		end
		return Lowest

	elseif ConfigMenu.T.ts:Value() == 6 then
		local LessCast = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemies, Distance) then
				if LessCast == nil and enemies then
					LessCast = enemies
				end

				if GetCurrentHP(enemies)/CalcDamage(myHero, enemies, 50, 50) < GetCurrentHP(LessCast)/CalcDamage(myHero, enemies, 50, 50) then
					LessCast = enemies
				end
			end
		end
		return LessCast

	elseif ConfigMenu.T.ts:Value() == 7 then
		local target = nil
		for _, enemies in pairs(GetEnemyHeroes()) do
			if ConfigMenu.T[GetObjectName(enemies)] then
				if ValidTarget(enemies, Distance) then
					if not target and enemies then
						target = enemies
					end

					if ConfigMenu.T[GetObjectName(target)]:Value() > ConfigMenu.T[GetObjectName(enemies)]:Value() then
						target = enemies
					end
				end
			end
		end
	end
end

class "Zyra"

function Zyra:__init()
	self.Spells = 
	{
		[0] = { delay = 0.7, speed = math.huge, width = 200, range = 800, radius = 420, mana = function() return 70+5*GetCastLevel(myHero, 0) end},
		[2] = { delay = 0.25, speed = 1150, width = 70, range = 1100, mana = function() return 65+5*GetCastLevel(myHero, 2) end},
		[3] = { delay = 1, speed = math.huge, width = 500, range = 700, radius = 500, mana = function() return 80+20*GetCastLevel(myHero, 3) end}
	}
		Dmg = 
	{
		[0] = function(Unit) return CalcDamage(myHero, Unit, 0, 35+GetCastLevel(myHero, 0)*35+GetBonusAP(myHero)*0.65) end,
		[2] = function(Unit) return CalcDamage(myHero, Unit, 0, 25+GetCastLevel(myHero, 2)*35+GetBonusAP(myHero)*0.50) end,
		[3] = function(Unit) return CalcDamage(myHero, Unit, 0, 95+GetCastLevel(myHero, 3)*85+GetBonusAP(myHero)*0.70) end,
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
	self.Seeds = {}


ConfigMenu.Champ:Menu("C", "Combo")
ConfigMenu.Champ.C:Boolean("Q", "Use Q", true)
ConfigMenu.Champ.C:Boolean("W", "Use W", true)
ConfigMenu.Champ.C:Boolean("E", "Use E", true)
ConfigMenu.Champ.C:Boolean("R", "Use R", true)
ConfigMenu.Champ.C:Slider("ER", "Enemies to R", 3, 1, 5)

ConfigMenu.Champ:Menu("H", "Harass")
ConfigMenu.Champ.H:Boolean("Q", "Use Q", true)
ConfigMenu.Champ.H:Boolean("E", "Use E", true)

ConfigMenu.Champ:Menu("LC", "LaneClear")
ConfigMenu.Champ.LC:Boolean("Q", "Use Q", true)
ConfigMenu.Champ.LC:Boolean("E", "Use E", true)
ConfigMenu.Champ.LC:Slider("SLC", "Seeds for LaneClear", 2, 1, 8)

ConfigMenu.Champ:Menu("KS", "KillSteal")
ConfigMenu.Champ.KS:Boolean("Q", "Use Q", true)
ConfigMenu.Champ.KS:Boolean("E", "Use E", true)
ConfigMenu.Champ.KS:Boolean("R", "Use R", true)
if self.Ignite ~= nil then
ConfigMenu.Champ.KS:Boolean("IG", "Use Ignite", true)
end

ConfigMenu.Champ:Menu("SO", "Seed Options")
ConfigMenu.Champ.SO:Boolean("QS", "Logic Q Seeds?", true)
ConfigMenu.Champ.SO:SubMenu("QSM", "No logic seeds Q")
ConfigMenu.Champ.SO.QSM:Slider("QSM", "Seeds to use in Q?", 1, 1, 2)
ConfigMenu.Champ.SO.QSM:Slider("DTS", "Distance to 2 seeds", 1, 500, 850)
ConfigMenu.Champ.SO.QSM:Info("a", "Desactivate Logic Q Seeds")
ConfigMenu.Champ.SO:Boolean("ES", "Logic E Seeds?", true)
ConfigMenu.Champ.SO:SubMenu("ESM", "No logic seeds E")
ConfigMenu.Champ.SO.ESM:Slider("ESM", "Seeds to use in E?", 1, 1, 2)
ConfigMenu.Champ.SO.ESM:Info("a", "Desactivate Logic E Seeds")

ConfigMenu.Champ:Menu("Orb", "Hotkeys")
ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

ConfigMenu.Champ:Menu("HC", "Hit chance")
ConfigMenu.Champ.HC:Slider("Q", "Q Predict", 20, 1, 100)
ConfigMenu.Champ.HC:Slider("E", "E Predict", 20, 1, 100)
ConfigMenu.Champ.HC:Slider("R", "R Predict", 20, 1, 100)

ConfigMenu.Champ:Menu("D", "Draw")
--[[ConfigMenu.Champ.D:SubMenu("DD", "Draw Damage")
ConfigMenu.Champ.D.DD:Boolean("D", "Draw?", true)
ConfigMenu.Champ.D.DD:Boolean("DQ", "Draw Q dmg", true)
ConfigMenu.Champ.D.DD:Boolean("DE", "Draw E dmg", true)
ConfigMenu.Champ.D.DD:Boolean("DR", "Draw R dmg", true)]]
ConfigMenu.Champ.D:SubMenu("DR", "Draw Range")
ConfigMenu.Champ.D.DR:Boolean("D", "Draw?", true)
ConfigMenu.Champ.D.DR:Boolean("DQ", "Draw Q range", true)
ConfigMenu.Champ.D.DR:Boolean("DE", "Draw E range", true)
ConfigMenu.Champ.D.DR:Boolean("DR", "Draw R range", true)
ConfigMenu.Champ.D.DR:Slider("DH", "Quality", 155, 1, 475)



OnTick(function(myHero) self:Tick() end)
OnDraw(function(myHero) self:Draw() end)
OnProcessSpell(function(Object, spellProc) self:OnProc(Object, spellProc) end)
OnUpdateBuff(function(Object, buff) self:Onupdate(Object, buff) end)
OnRemoveBuff(function(Object, buff) self:Onremove(Object, buff) end)
OnCreateObj(function(Object) self:OnCreate(Object) end)
OnDeleteObj(function(Object) self:OnDelete(Object) end)
OnAggro(function(unit, flag) self:OnAggro(unit, flag) end)
end

function Zyra:Tick()
	self.Target = DickSelector:Targets(1000)
	if not IsDead(myHero)then
		if self.Target ~= nil then
			if ConfigMenu.Champ.Orb.C:Value() then
			self:Combo(self.Target)
			end

			if ConfigMenu.Champ.Orb.H:Value() then
				self:Harass(self.Target)
			end
		end

		if ConfigMenu.Champ.Orb.LC:Value() then
			self:LaneClear()
		end
		self:Ks()
	end
	Autolvl:Autolvl(myHero)
end

function Zyra:OnAggro(unit, flag)
	if unit and flag then
		print(unit)
		print(flag)
	end
end

function Zyra:Draw()
	if ConfigMenu.Champ.D.DR.D:Value() then
		if ConfigMenu.Champ.D.DR.DQ:Value() and Ready(0) then
			DrawCircle(GetOrigin(myHero), 800, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Red)
		end

		if ConfigMenu.Champ.D.DR.DE:Value() and Ready(2) then
			DrawCircle(GetOrigin(myHero), 1100, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Blue)
		end

		if ConfigMenu.Champ.D.DR.DR:Value() and Ready(3) then
			DrawCircle(GetOrigin(myHero), 700, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Pink)
		end
	end
end

function Zyra:Combo(Target)
	if ConfigMenu.Champ.C.Q:Value() and (not Ready(2) or not ConfigMenu.Champ.C.E:Value()) then
		self:CastQ(Target)
	end
	if ConfigMenu.Champ.C.E:Value() then
		self:CastE(Target)
	end
	if ConfigMenu.Champ.C.R:Value() then
		self:CastR(Target)
	end
end

function Zyra:Harass(Target)
	if ConfigMenu.Champ.C.Q:Value() then
		self:CastQ(Target)
	end
	if ConfigMenu.Champ.C.E:Value() then
		self:CastE(Target)
	end
end

function Zyra:LaneClear()
	local BestPos, BestHit = self:BestFarmPos(self.Spells[0].range, self.Spells[0].width, self.Seeds)
	for _, mob in pairs(minionManager.objects) do
		if ValidTarget(mob, 850) then
			if ConfigMenu.Champ.LC.Q:Value() and Ready(0) then
				if BestHit >= ConfigMenu.Champ.LC.SLC:Value() and BestPos then
					CastSkillShot(0, BestPos)
				elseif BestHit <= ConfigMenu.Champ.LC.SLC:Value() and BestPos then
					CastSkillShot(0, GetOrigin(mob))
				end
			end
		end

		if ValidTarget(mob, 1100) then
			if ConfigMenu.Champ.LC.E:Value() and Ready(2) then
				CastSkillShot(2, GetOrigin(mob))
			end
		end
	end
end

function Zyra:Ks()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ConfigMenu.Champ.KS.Q:Value() and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < Dmg[0](enemy) then
			self:CastQ(enemy)
		end

		if ConfigMenu.Champ.KS.E:Value() and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < Dmg[2](enemy) then
			self:CastE(enemy)
		end

		if ConfigMenu.Champ.KS.Q:Value() and (GetCurrentHP(enemy)+GetDmgShield(enemy)) < Dmg[0](enemy)+Dmg[2](enemy) then
			self:CastE(enemy)
			DelayAction(function() self:CastQ(enemy) end, GetDistance(enemy)/1500)
		end

		if self.Ignite ~= nil then
			if Ready(self.Ignite) and ValidTarget(enemy, 500) and GetCurrentHP(enemy)+GetHPRegen(enemy)*3 <= 50+GetLevel(myHero)*20 then
				CastTargetSpell(enemy, self.Ignite)
			end
		end
	end
end

function Zyra:CastQ(Unit)
	local Q = GetCircularAOEPrediction(Unit, self.Spells[0])
	if Ready(0) and ValidTarget(Unit, 800) and not ECast and Q.hitChance >= (ConfigMenu.Champ.HC.Q:Value())/100 and Q then
		CastSkillShot(0, Q.castPos)
		QCast = true
		DelayAction(function() QCast = false end, 0.5)
	end
end

function Zyra:CastW(Point, Spell)
	local q = 0
	local e = 0
	if self.IsTargetFucked and Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and ConfigMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)
		
	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) >= ConfigMenu.Champ.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and ConfigMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)

	elseif not self.IsTargetFucked and Ready(0) and ValidTarget(self.Target, 800) and GetDistance(self.Target) <= ConfigMenu.Champ.SO.QSM.DTS:Value() and Spell == GetCastName(myHero, 0) and ConfigMenu.Champ.SO.QS:Value() then
		CastSkillShot(1, Point)
		DelayAction(function() CastSkillShot(1, Point) end, 0.5)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and ConfigMenu.Champ.SO.QS:Value() == false then
		CastSkillShot(1, Point)
		q = q+1
		DelayAction(function()	
			if q < ConfigMenu.Champ.SO.QSM.QSM:Value() then
				CastSkillShot(1, Point)
				q = q+1
				if q == ConfigMenu.Champ.SO.QSM.QSM:Value() then
					q = 0
				end
			else
				q = 0
			end
		end, 0.5)
	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 0) and ConfigMenu.Champ.SO.QS:Value() == false then
		CastSkillShot(1, Point)
		q = q+1
		DelayAction(function()	
			if q < ConfigMenu.Champ.SO.QSM.QSM:Value() then
				CastSkillShot(1, Point)
				q = q+1
				if q == ConfigMenu.Champ.SO.QSM.QSM:Value() then
					q = 0
				end
			else
				q = 0
			end
		end, 0.5)
	end
	if Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and ConfigMenu.Champ.SO.ES:Value() then
		CastSkillShot(1, Point)

	elseif Ready(1) and ValidTarget(self.Target, 800) and Spell == GetCastName(myHero, 2) and ConfigMenu.Champ.SO.ES:Value() == false then
		CastSkillShot(1, Point)
		e = e+1
		DelayAction(function()	
			if e < ConfigMenu.Champ.SO.ESM.ESM:Value() then
				CastSkillShot(1, Point)
				e = e+1
				if e == ConfigMenu.Champ.SO.ESM.ESM:Value() then
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
	if Ready(2) and ValidTarget(Unit, 1100) and not QCast and E.hitChance >= (ConfigMenu.Champ.HC.E:Value())/100 and E then
		CastSkillShot(2, E.castPos)
		ECast = true
		DelayAction(function() ECast = false end, GetDistance(self.Target)/self.Spells[3].speed)
	end
end

function Zyra:CastR(Unit)
	local R = GetCircularAOEPrediction(Unit, self.Spells[3])
	if Ready(3) and ValidTarget(Unit, 700) and R.hitChance >= (ConfigMenu.Champ.HC.R:Value())/100 and EnemiesAround(myHero, 1000) <= 2 and R then
		CastSkillShot(3, R.castPos)
	elseif Ready(3) and ValidTarget(Unit, 700) and EnemiesAround(myHero, 1000) >= 2 then
		local BestRPos, BestRHit = self:BestRPos()
		if BestRPos and BestRHit >= ConfigMenu.Champ.C.ER:Value() then
			CastSkillShot(3, BestRPos)
		end
	end
end

function Zyra:OnProc(Object, spellProc)
	local EPos = nil
	if Object == myHero then
		if ConfigMenu.Champ.Orb.C:Value() and self.Target ~= nil then
			DelayAction(function()
				if spellProc.name == GetCastName(myHero, 0) then
					self:CastW(spellProc.endPos, GetCastName(myHero, 0))
				elseif spellProc.name == GetCastName(myHero, 2) then
					if ConfigMenu.Champ.Orb.C:Value() and self.Spells[2].range < GetCastRange(myHero, 1) then
						EPos = GetOrigin(myHero) + Vector(Vector(spellProc.endPos) - Vector(spellProc.startPos)):normalized()*GetDistance(self.Target)
						self:CastW(EPos, GetCastName(myHero, 2))
					end
				end
			end, 0.1)
		end
	end
end

function Zyra:Onupdate(Object, buffProc)
	if self.Target ~= nil then
		if Object.Name == GetObjectName(self.Target) then 
			for i, buffs in pairs(self.DebuffTable) do
				if buffProc.Type == buffs then
					self.IsTargetFucked = true
				end
			end
		end
	end
end

function Zyra:Onremove(Object, buffProc)
	if self.Target ~= nil then
		if Object.Name == GetObjectName(self.Target) then 
			for i, buffs in pairs(self.DebuffTable) do
				if buffProc.Type == buffs then
					self.IsTargetFucked = false
				end
			end
		end
	end
end

function Zyra:OnCreate(Object)
	if Object and GetObjectBaseName(Object) == "Zyra_Base_W_Seed_Indicator.troy" then
		table.insert(self.Seeds, #self.Seeds+1, Object)
	end
end

function Zyra:OnDelete(Object)
	if Object and GetObjectBaseName(Object) == "Zyra_Base_W_Seed_Indicator.troy" then
		table.remove(self.Seeds, 1)
	end
end

function Zyra:BestRPos() -- Modded from Inspired lib
	local BestRPos 
	local BestRHit = 0
	for i, enemies in pairs(GetEnemyHeroes()) do
		if GetOrigin(enemies) ~= nil and ValidTarget(enemies, 700) then
		local hit = EnemiesAround(GetOrigin(enemies), 500)
			if hit > BestHit and GetDistance(enemies) < 700 then
				BestRHit = hit
				BestRPos = Vector(enemies)
				if BestHit == #GetEnemyHeroes() then
					break
				end
			end
		end
	end
	return BestRPos, BestRHit
end

function Zyra:BestFarmPos() -- Modded from Inspired lib
	--[[local BestPos 
	local BestHit = 0
	for i, object in pairs(self.Seeds) do
		if GetOrigin(object) ~= nil and Object then
			local k = GetOrigin(Object) - Vector(Vector(GetOrigin(myHero)) + Vector(GetOrigin(object))):perpendicular():normalized()*X
			local v = GetOrigin(Object) - Vector(Vector(GetOrigin(myHero)) + Vector(GetOrigin(object))):perpendicular2():normalized()*X
			local w = self:CountObjectsOnLineSegment(K, v, 200?, object)

		end
	end
	return BestPos, BestHit]]
end

function Zyra:CountObjectsOnLineSegment(StartPos, EndPos, width, objects, team)
	local n = 0
	if object ~= nil and object.valid then
		local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(StartPos, EndPos, GetOrigin(object))
		local w = width
		if isOnSegment and GetDistanceSqr(pointSegment, GetOrigin(object)) < w^2 and GetDistanceSqr(StartPos, EndPos) > GetDistanceSqr(StartPos, GetOrigin(object)) then
			n = n + 1
		end
	end
	return n
end


class "Kindred"

function Kindred:__init()
	self.Spells = 
	{
		[0] = {range = 500, dash = 340, mana = 35},
		[1] = {range = 800, duration = 8, mana = 40},
		[2] = {range = 500, mana = 70, mana = 70},
		[3] = {range = 500, mana = 100},
	}
	Dmg = 
	{
		[0] = 	function(Unit) return CalcDamage(myHero, Unit, 35+20*GetCastLevel(myHero, 0)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+5*self.Passive) end,
		[1] = 	function(Unit) 	if GetTeam(Unit) == MINION_ENEMY then
									return CalcDamage(myHero, Unit, 20+5*GetCastLevel(myHero, 1)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.40+self:PassiveDmg(Unit))
								else
									return CalcDamage(myHero, Unit, (20+5*GetCastLevel(myHero, 1)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.40+self:PassiveDmg(Unit)*0.40)*1.5)
								end
				end,
		[2] = 	function(Unit) 	if GetTeam(Unit) == MINION_JUNGLE and CalcDamage(myHero, Unit, 30+30*GetCastLevel(myHero, 2)+(GetBaseDamage(myHero) + GetBonusDmg(myHero))*0.20+GetMaxHP(Unit)*0.05) > 300 then
									return CalcDamage(myHero, Unit, 300)
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
	self.Flash = (GetCastName(myHero, SUMMONER_1):lower():find("summonerflash") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("summonerflash") and SUMMONER_2 or nil)) -- Ty Platy
	self.target = nil
	pos = {pos = nil, pos2 = nil}
	
	ConfigMenu.Champ:Menu("Combo", "Combo")
	ConfigMenu.Champ.Combo:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.Combo:Boolean("W", "Use W", true)
	ConfigMenu.Champ.Combo:Boolean("E", "Use E", true)
	ConfigMenu.Champ.Combo:Boolean("QE", "Gapcloser", true)

	ConfigMenu.Champ:Menu("JunglerClear", "JunglerClear")
	ConfigMenu.Champ.JunglerClear:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.JunglerClear:Boolean("W", "Use W", true)
	ConfigMenu.Champ.JunglerClear:Boolean("E", "Use E", true)
	ConfigMenu.Champ.JunglerClear:Slider("MM", "Mana manager", 50, 1, 100)

	ConfigMenu.Champ:Menu("LaneClear", "LaneClear")
	ConfigMenu.Champ.LaneClear:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.LaneClear:Boolean("W", "Use W", true)
	ConfigMenu.Champ.LaneClear:Boolean("E", "Use E", true)
	ConfigMenu.Champ.LaneClear:Slider("MM", "Mana manager", 50, 1, 100)

	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
	ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
--	ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
	ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	ConfigMenu.Champ:Menu("Misc", "Misc")
	ConfigMenu.Champ.Misc:Boolean("B", "Buy Farsight", true)
	ConfigMenu.Champ.Misc:KeyBinding("FQ", "Flash-Q", string.byte("T"))
	ConfigMenu.Champ.Misc:Key("WP", "Jumps", string.byte("G"))

	ConfigMenu.Champ:Menu("ROptions", "R Options")
	ConfigMenu.Champ.ROptions:Boolean("R", "Use R?", true)
	ConfigMenu.Champ.ROptions:Slider("EA", "Enemies around", 3, 1, 5)
	ConfigMenu.Champ.ROptions:Boolean("RU", "Use R on urself", true)

	ConfigMenu.Champ:Menu("QOptions", "Q Options")
	ConfigMenu.Champ.QOptions:Boolean("QC", "AA reset Combo", true)
	ConfigMenu.Champ.QOptions:Boolean("QL", "AA reset LaneClear", true)
	ConfigMenu.Champ.QOptions:Boolean("QJ", "AA reset JunglerClear", true)

	ConfigMenu.Champ:Menu("D", "Draw")
	--[[ConfigMenu.Champ.D:SubMenu("DD", "Draw Damage")
	ConfigMenu.Champ.D.DD:Boolean("D", "Draw?", true)
	ConfigMenu.Champ.D.DD:Boolean("DQ", "Draw Q dmg", true)
	ConfigMenu.Champ.D.DD:Boolean("DE", "Draw E dmg", true)
	ConfigMenu.Champ.D.DD:Boolean("DR", "Draw R dmg", true)]]
	ConfigMenu.Champ.D:SubMenu("DR", "Draw Range")
	ConfigMenu.Champ.D.DR:Boolean("D", "Draw?", true)
	ConfigMenu.Champ.D.DR:Boolean("DQ", "Draw Q range", true)
	ConfigMenu.Champ.D.DR:Boolean("DW", "Draw W range", true)
	ConfigMenu.Champ.D.DR:Boolean("DE", "Draw E range", true)
	ConfigMenu.Champ.D.DR:Boolean("DR", "Draw R range", true)
	ConfigMenu.Champ.D.DR:Slider("DH", "Quality", 155, 1, 475)

	DelayAction(function()
		for i, allies in pairs(GetAllyHeroes()) do
			ConfigMenu.Champ.ROptions:Boolean("Pleb"..GetObjectName(allies), "Use R on "..GetObjectName(allies), true)
		end
	end, 0.001)
end

function Kindred:Tick()
	if not IsDead(myHero) then
		self.target = DickSelector:Targets(self.Spells[0].range)
		if ConfigMenu.Champ.Orb.C:Value() then
			if self.target ~= nil then
				self:Combo(self.target)
			end
		elseif ConfigMenu.Champ.Orb.LC:Value() then
			self:LaneClear()
		end

		self:AutoR()
		if ConfigMenu.Champ.Misc.FQ:Value() then
			if Ready(0) and Ready(Flash) and ConfigMenu.Champ.Combo.Q:Value() then  
				CastSkillShot(Flash, GetMousePos()) 
					DelayAction(function() CastSkillShot(0, GetMousePos()) end, 1)					  
			end
		end

		self.Passive = GetBuffData(myHero,"kindredmarkofthekindredstackcounter").Stacks
		if ConfigMenu.Champ.Misc.B:Value() then
			if not self.Farsight and GetLevel(myHero) >= 9 and GetDistance(myHero,basePos) < 550 then
				BuyItem(3363)
				self.Farsight = true
			end
		end
		self:Walljump()
	end
end

function Kindred:Draw()
	if not IsDead(myHero) then
		if ConfigMenu.Champ.D.DR.D:Value() then
			if ConfigMenu.Champ.D.DR.DQ:Value() and Ready(0) then
				DrawCircle(GetOrigin(myHero), self.Spells[0].range, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Red)
			end

			if ConfigMenu.Champ.D.DR.DW:Value() and Ready(1) then
				DrawCircle(GetOrigin(myHero), self.Spells[1].range, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Blue)
			end

			if ConfigMenu.Champ.D.DR.DE:Value() and Ready(2) then
				DrawCircle(GetOrigin(myHero), self.Spells[2].range, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.Pink)
			end
				if ConfigMenu.Champ.D.DR.DR:Value() and Ready(3) then
				DrawCircle(GetOrigin(myHero), self.Spells[3].range, 1, ConfigMenu.Champ.D.DR.DH:Value(), GoS.White)
			end
		end
	end
end

function Kindred:Combo(Unit)
local AfterQ = GetOrigin(myHero) +(Vector(GetMousePos()) - GetOrigin(myHero)):normalized()*self.Spells[0].dash

	if Ready(2) and Ready(0) and ConfigMenu.Champ.Combo.QE:Value() and GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450 then
		CastSkillShot(0, GetMousePos())
			DelayAction(function() CastTargetSpell(Unit, 2) end, 1)
	end

	if Ready(0) and ConfigMenu.Champ.Combo.Q:Value() and ValidTarget(Unit, self.Spells[0].range) and ConfigMenu.Champ.QOptions.QC:Value() == false or (GetDistance(Unit) > self.Spells[0].range and GetDistance(AfterQ, Unit) <= 450)  then
    	CastSkillShot(0, GetMousePos()) 
	end

	if Ready(1) and ConfigMenu.Champ.Combo.W:Value() and ValidTarget(Unit, self.Spells[1].range) then 
		CastSpell(1)
	end

	if Ready(2) and ConfigMenu.Champ.Combo.E:Value() and ValidTarget(Unit, self.Spells[2].range) then 
		CastTargetSpell(Unit, 2)
	end
end

function Kindred:LaneClear()
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	local WMana = (self.Spells[1].mana*100)/GetMaxMana(myHero)
	local EMana = (self.Spells[2].mana*100)/GetMaxMana(myHero)
	for _, mob in pairs(minionManager.objects) do	
		if GetTeam(mob) == MINION_JUNGLE then
			if ConfigMenu.Champ.QOptions.QJ:Value() == false and Ready(0) and ConfigMenu.Champ.JunglerClear.Q:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) and (GetPercentMP(myHero)- QMana) >= ConfigMenu.Champ.JunglerClear.MM:Value() then 
				CastSkillShot(0, GetMousePos())
			end

			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and IsTargetable(mob) and ConfigMenu.Champ.JunglerClear.W:Value() and (GetPercentMP(myHero)- WMana) >= ConfigMenu.Champ.JunglerClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then
   				CastSpell(1)
    		end

    		if Ready(2) and ValidTarget(mob, self.Spells[2].range) and ConfigMenu.Champ.JunglerClear.E:Value() and (GetPercentMP(myHero)- EMana) >= ConfigMenu.Champ.JunglerClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
   				CastTargetSpell(mob, 2)
   			end
  	 	end
		if GetTeam(mob) == MINION_ENEMY then
			if ConfigMenu.Champ.QOptions.QL:Value() == false and Ready(0) and ConfigMenu.Champ.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= ConfigMenu.Champ.LaneClear.MM:Value() and ValidTarget(mob, self.Spells[0].range) and GetCurrentHP(mob) >= Dmg[0](mob) then 
				CastSkillShot(0, GetMousePos())
			end

			if Ready(1) and ValidTarget(mob, self.Spells[1].range) and ConfigMenu.Champ.LaneClear.W:Value() and (GetPercentMP(myHero)- WMana) >= ConfigMenu.Champ.LaneClear.MM:Value() and self:TotalHp(self.Spells[1].range, myHero) >= Dmg[1](mob) + ((8/self.AAPS)*CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero)+self:PassiveDmg(mob))) then 
				CastSpell(1)
			end

			if Ready(2) and ValidTarget(mob, self.Spells[2].range) and ConfigMenu.Champ.LaneClear.E:Value() and (GetPercentMP(myHero)- EMana) >= ConfigMenu.Champ.LaneClear.MM:Value() and GetCurrentHP(mob) >= Dmg[2](mob) + (CalcDamage(myHero, mob, GetBaseDamage(myHero) + GetBonusDmg(myHero))*3) then 
				CastTargetSpell(mob, 2)
			end
		end
	end
end

function Kindred:AutoR()
	if ConfigMenu.Champ.ROptions.R:Value() and not self.Recalling and not IsDead(myHero) and Ready(1) then
		for i, allies in pairs(GetAllyHeroes()) do
			if GetPercentHP(allies) <= 20 and ConfigMenu.Champ.ROptions["Pleb"..GetObjectName(allies)]:Value() and not IsDead(allies) and GetDistance(allies) <= self.Spells[3].range and EnemiesAround(allies, 1500) >= ConfigMenu.Champ.ROptions.EA:Value() then
				CastTargetSpell(myHero, 3)
			end
		end

		if GetPercentHP(myHero) <= 20 and ConfigMenu.Champ.ROptions.RU:Value() and EnemiesAround(myHero, 1500) >= ConfigMenu.Champ.ROptions.EA:Value() then
			CastTargetSpell(myHero, 3)
		end
	end
end

function Kindred:OnProcComplete(unit, spell)
	local QMana = (self.Spells[0].mana*100)/GetMaxMana(myHero)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			if ConfigMenu.Champ.Orb.LC:Value() then 
				for _, mob in pairs(minionManager.objects) do	
					if ConfigMenu.Champ.QOptions.QL:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_ENEMY and ConfigMenu.Champ.LaneClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= ConfigMenu.Champ.LaneClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos())
					end

					if ConfigMenu.Champ.QOptions.QJ:Value() and ValidTarget(mob, 500) and GetTeam(mob) == MINION_JUNGLE and ConfigMenu.Champ.JunglerClear.Q:Value() and (GetPercentMP(myHero)- QMana) >= ConfigMenu.Champ.JunglerClear.MM:Value() and Ready(0) then
						CastSkillShot(0, GetMousePos()) 
					end
				end

			elseif ConfigMenu.Champ.Orb.C:Value() and self.target ~= nil then
				if ConfigMenu.Champ.QOptions.QC:Value() and Ready(0) and ConfigMenu.Champ.Combo.Q:Value() and ValidTarget(self.target, 500) then
    				CastSkillShot(0, GetMousePos()) 
				end
			end
		end
	end
end

function Kindred:OnUpdate(unit, buff)
	if unit == myHero then
		if buff.Name == "recall" or buff.Name == "OdinRecall" then
			self.Recalling = true
		end
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

function Kindred:Walljump()
	local V1 = GetMousePos() + Vector(Vector(GetOrigin(myHero)) - Vector(GetMousePos())):normalized()*340
	local V2 = GetMousePos() + Vector(Vector(GetOrigin(myHero)) - Vector(GetMousePos())):normalized()*170
	if ConfigMenu.Champ.Misc.WP:Value() then
		if not MapPosition:inWall(GetMousePos()) and not MapPosition:inWall(V1) and MapPosition:inWall(V2) then
			MoveToXYZ(V1)
			pos[1] = V1
			pos[2] = GetMousePos()
		end
	end

	if pos[1] ~= nil then
		if GetDistance(pos[1]) <= 50 and Ready(0) then
			CastSkillShot(0, pos[2])
		end
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

	ConfigMenu.Champ:Menu("C", "Combo")
	ConfigMenu.Champ.C:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.C:Boolean("E", "Use E", true)
	ConfigMenu.Champ.C:Boolean("R", "Use R", true)
	ConfigMenu.Champ.C:KeyBinding("I", "Insec Flash+E", string.byte("Y"), false) 

	ConfigMenu.Champ:Menu("H", "Harass")
	ConfigMenu.Champ.H:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.H:Boolean("E", "Use E", true)

	ConfigMenu.Champ:Menu("LC", "LaneClear")
	ConfigMenu.Champ.LC:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.LC:Slider("MM", "Mana manager", 50, 1, 100)

	ConfigMenu.Champ:Menu("JC", "JunglerClear")
	ConfigMenu.Champ.JC:Boolean("Q", "Use Q", true)
	ConfigMenu.Champ.JC:Boolean("E", "Use E", true)
	ConfigMenu.Champ.JC:Slider("MM", "Mana manager", 50, 1, 100)

	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
	ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
	ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
	ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	ConfigMenu.Champ:Menu("F", "Fuck Dashes")

	ConfigMenu.Champ:Menu("ASA", "Auto Stun")
	ConfigMenu.Champ.ASA:Boolean("AS", "Auto Stun enable?", true)
	ConfigMenu.Champ.ASA:KeyBinding("T", "Flash-Stun", string.byte("T"), false)

	ConfigMenu.Champ:Menu("IN", "Interrupt")

	DelayAction(function()
		for _, enemies in pairs(GetEnemyHeroes()) do
			if self.DashTable[GetObjectName(enemies)] then 
				ConfigMenu.Champ.F:Boolean("Pleb"..GetObjectName(enemies), "Interrupt "..GetObjectName(enemies).." Dash "..self.DashTable[GetObjectName(enemies)].Name, true)
			end
			if self.ChannelTable[GetObjectName(enemies)] then
				ConfigMenu.Champ.IN:Boolean("Pleb"..GetObjectName(enemies), "Interrupt "..GetObjectName(enemies).." "..self.ChannelTable[GetObjectName(enemies)].Name, true)
			end

			ConfigMenu.Champ.ASA:Boolean("Pleb"..GetObjectName(enemies), "Auto Stun On "..GetObjectName(enemies), true)
		end
	end, 0.1)

	OnTick(function(myHero) self:Tick(myHero) end)
	OnProcessSpell(function(Object, spellProc) self:OnProc(Object, spellProc) end)
end

function Poppy:Tick(myHero)
	self:Stun()
	self:Insec()
	self.Target = DickSelector:Targets(600)
	if self.Target ~= nil then
		if ConfigMenu.Champ.Orb.C:Value() then
			self:Combo(self.Target)
		end

		if ConfigMenu.Champ.Orb.H:Value() then
			self:Harass(self.Target)
		end
	end
	if ConfigMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
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
		if ValidTarget(mobs, 600) then
			if GetTeam(mobs) == 200 then
				if Ready(0) and ConfigMenu.Champ.LC.Q:Value() and ValidTarget(mobs, self.Spells[0].range) then
					CastSkillShot(0, GetOrigin(mobs))
				end
			elseif GetTeam(mobs) == 300 then
				local MyPos = GetOrigin(myHero) + Vector(GetOrigin(mobs) - Vector(GetOrigin(myHero))):normalized()*GetDistance(mobs) + Vector(GetOrigin(mobs) - Vector(GetOrigin(myHero))):normalized()*325
				if Ready(0) and ConfigMenu.Champ.JC.Q:Value() and (GetPercentMP(myHero)- QMana) >= ConfigMenu.Champ.JC.MM:Value() and ValidTarget(mobs, self.Spells[0].range) then
					CastSkillShot(0, GetOrigin(mobs))
				end
				--DrawLine(WorldToScreen(0,myHero).x, WorldToScreen(0,myHero).y, WorldToScreen(0,MyPos).x, WorldToScreen(0,MyPos).y, 1, GoS.Pink)
				if Ready(2) and ConfigMenu.Champ.JC.E:Value() and (GetPercentMP(myHero)- EMana) >= ConfigMenu.Champ.JC.MM:Value() and MapPosition:inWall(MyPos) and ValidTarget(mobs, self.Spells[2].range) then
					CastTargetSpell(mobs, 2)
				end
			end
		end
	end
end

function Poppy:UseQ(Unit)
	local Q = GetPrediction(Unit, self.Spells[0])
	if Ready(0) and ValidTarget(Unit, self.Spells[0].range) and ConfigMenu.Champ.C.Q:Value() and Q and Q.hitChance >= 0.20 then
		CastSkillShot(0, Q.castPos)
	end
end

function Poppy:UseE(Unit)
	if Ready(2) and ValidTarget(Unit, self.Spells[2].range) and ConfigMenu.Champ.C.E:Value() then
		CastTargetSpell(Unit, 2)
	end
end

function Poppy:UseR(Unit)
	local R = GetPrediction(Unit, self.Spells[3])
	if Ready(3) and ValidTarget(Unit, 425) and ConfigMenu.Champ.C.R:Value() and R and R.hitChance >= 0.20 then
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
			if ConfigMenu.Champ.ASA["Pleb"..GetObjectName(enemies)]:Value() and MapPosition:inWall(MyPos) then
				CastTargetSpell(enemies, 2)
			end
		elseif GetDistance(enemies, MousePos) <= 425 and MapPosition:inWall(MyMousePos) and ConfigMenu.Champ.ASA.T:Value() and Ready(2) then
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
					if spellProc.name == GetCastName(enemies, self.DashTable[GetObjectName(enemies)].SpellSlot) and ConfigMenu.Champ.F["Pleb"..GetObjectName(enemies)]:Value() and (GetDistance(spellProc.endPos) <= self.Spells[1].range or GetDistance(spellProc.startPos) <= self.Spells[1].range) and Ready(1) then
						CastSpell(1)
					end
				elseif self.DashTable[GetObjectName(enemies)].type == "Target" then
					if spellProc.name == GetCastName(enemies, self.DashTable[GetObjectName(enemies)].SpellSlot) and ConfigMenu.Champ.F["Pleb"..GetObjectName(enemies)]:Value() and GetDistance(spellProc.target) <= self.Spells[1].range and Ready(1) then
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
		if ValidTarget(enemies, 400) and Ready(2) and ConfigMenu.Champ.C.I:Value() then
			local FlashPos = GetOrigin(myHero) + Vector(GetOrigin(enemies)-Vector(GetOrigin(myHero))):normalized()*425
			CastSkillShot(self.Flash, FlashPos)
			DelayAction(function() CastTargetSpell(enemies, 2) end, 0.1)
		end
	end
end

class "Elise"

function Elise:__init()
	Dmg =
	{
		[0] = function(Unit) return CalcDamage(myHero, Unit, 0, 5+35*GetCastLevel(myHero, 0)+(GetCurrentHP(Unit)*0.04)/100+0.03*GetBonusAP(myHero)) end,
		[1] = function(Unit) return CalcDamage(myHero, Unit, 0, 20+50*GetCastLevel(myHero, 1)+0.8*GetBonusAP(myHero)) end,
		[2] = function(Unit) return CalcDamage(myHero, Unit, 0, 20+40*GetCastLevel(myHero, 0)+((GetMaxHP(Unit)-GetCurrentHP(Unit)*0.08)/100+0.03*GetBonusAP(myHero)))  end,
	}

	self.Spells =
	{
		[0] = {CD = function(myHero) return 	6 								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "EliseHumanQ", 		Timer = 0, Ready = false},
		[1] = {CD = function(myHero) return 	12 								+ 12*GetCDR(myHero) 								end, CDT = 0, Name = "EliseHumanW", 		Timer = 0, Ready = false},
		[2] = {CD = function(myHero) return 	15-GetCastLevel(myHero, 2) 		+ (15-GetCastLevel(myHero, 2))*GetCDR(myHero) 		end, CDT = 0, Name = "EliseHumanE", 		Timer = 0, Ready = false, speed = 1100, width = 55, range = 1600, delay = 0.25},
		[3] = {CD = function(myHero) return 	4								+ 4*GetCDR(myHero) 									end, CDT = 0, Name = "EliseR", 				Timer = 0, Ready = false},
	}

	self.Spells2 =
	{
		[0] = {CD = function(myHero) return 	6 								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "EliseSpiderQCast", 	Timer = 0, Ready = false},
		[1] = {CD = function(myHero) return 	12 								+ 12*GetCDR(myHero) 								end, CDT = 0, Name = "EliseSpiderW", 		Timer = 0, Ready = false},
		[2] = {CD = function(myHero) return 	29-GetCastLevel(myHero, 2)*3 	+ (29-GetCastLevel(myHero, 2)*3)*GetCDR(myHero) 	end, CDT = 0, Name = "EliseSpiderEDescent", Timer = 0, Ready = false},
		[3] = {CD = function(myHero) return 	4								+ 4*GetCDR(myHero) 									end, CDT = 0, Name = "EliseRSpider", 		Timer = 0, Ready = false},
	}

	self.Sprite = 
	{
		[1] 	= 	{FName = "Elise\\Elise_Human_Q.png", 		Sprite = nil,		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Elise_Human_Q.png"},
		[2] 	= 	{FName = "Elise\\Elise_Human_W.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "Elise_Human_W.png"},
		[3] 	= 	{FName = "Elise\\Elise_Human_E.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2		else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "Elise_Human_E.png"},
		[4] 	= 	{FName = "Elise\\Elise_Human_R.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "Elise_Human_R.png"},
		[5] 	= 	{FName = "Elise\\Elise_Human_Q_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Elise_Human_Q_CD.png"},
		[6] 	= 	{FName = "Elise\\Elise_Human_W_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "Elise_Human_W_CD.png"},
		[7] 	= 	{FName = "Elise\\Elise_Human_E_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2	 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "Elise_Human_E_CD.png"},
		[8] 	= 	{FName = "Elise\\Elise_Human_R_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "Elise_Human_R_CD.png"},
		[9] 	= 	{FName = "Elise\\Elise_Spider_Q.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Elise_Spider_Q.png"},
		[10] 	= 	{FName = "Elise\\Elise_Spider_W.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75 	else return GetResolution().x/2-127	end end,		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "Elise_Spider_W.png"},
		[11] 	= 	{FName = "Elise\\Elise_Spider_E.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2	 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "Elise_Spider_E.png"},
		[12] 	= 	{FName = "Elise\\Elise_Spider_R.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "Elise_Spider_R.png"},
		[13] 	= 	{FName = "Elise\\Elise_Spider_Q_CD.png",	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Elise_Spider_Q_CD.png"},
		[14] 	= 	{FName = "Elise\\Elise_Spider_W_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "Elise_Spider_W_CD.png"},
		[15] 	= 	{FName = "Elise\\Elise_Spider_E_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "Elise_Spider_E_CD.png"},
		[16] 	= 	{FName = "Elise\\Elise_Spider_R_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "Elise_Spider_R_CD.png"},
	}

	--[[self.SpellsTable =
	{
		["AatroxE"]=					{charName="Aatrox",					slot=2,		type="Line",		delay=0.25,		range=1075,		radius=35,			speed=1250,				addHitbox=true,			danger=3,			dangerous=false,			proj="AatroxEConeMissile",				killTime=0},
		["AhriOrbofDeception"]=			{charName="Ahri",					slot=0,		type="Line",		delay=0.25,		range=1000,		radius=100,			speed=2500,				addHitbox=true,			danger=2,			dangerous=false,			proj="AhriOrbMissile",					killTime=0},
		["AhriOrbReturn"]=				{charName="Ahri",					slot=0,		type="Line",		delay=0.25,		range=1000,		radius=100,			speed=60,				addHitbox=true,			danger=2,			dangerous=false,			proj="AhriOrbReturn",					killTime=0},
		["AhriSeduce"]=					{charName="Ahri",					slot=2,		type="Line",		delay=0.25,		range=1000,		radius=60,			speed=1550,				addHitbox=true,			danger=3,			dangerous=true,				proj="AhriSeduceMissile",				killTime=0},
		["BandageToss"]=				{charName="Amumu",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=90,			speed=2000,				addHitbox=true,			danger=3,			dangerous=true,				proj="SadMummyBandageToss",				killTime=0},
		["FlashFrost"]=					{charName="Anivia",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=110,			speed=850,				addHitbox=true,			danger=3,			dangerous=true,				proj="FlashFrostSpell",					killTime=0},
		["Volley"]=						{charName="Ashe",					slot=1,		type="Line",		delay=0.25,		range=1250,		radius=60,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="VolleyAttack",					killTime=0},
		["EnchantedCrystalArrow"]=		{charName="Ashe",					slot=3,		type="Line",		delay=0.25,		range=20000,	radius=130,			speed=1600,				addHitbox=true,			danger=5,			dangerous=true,				proj="EnchantedCrystalArrow",			killTime=0},
		["AurelionSolQ"]=				{charName="AurelionSol",			slot=0,		type="Line",		delay=0.25,		range=1500,		radius=180,			speed=850,				addHitbox=true,			danger=2,			dangerous=false,			proj="AurelionSolQMissile",				killTime=0},
		["AurelionSolR"]=				{charName="AurelionSol",			slot=3,		type="Line",		delay=0.3,		range=1420,		radius=120,			speed=4500,				addHitbox=true,			danger=3,			dangerous=true,				proj="AurelionSolRBeamMissile",			killTime=0},
		["BardQ"]=						{charName="Bard",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=1600,				addHitbox=true,			danger=3,			dangerous=true,				proj="BardQMissile",					killTime=0},
		["BardR"]=						{charName="Bard",					slot=3,		type="Circle",		delay=0.5,		range=3400,		radius=350,			speed=2100,				addHitbox=true,			danger=2,			dangerous=false,			proj="BardR",							killTime=1},
		["RocketGrab"]=					{charName="Blitzcrank",				slot=0,		type="Line",		delay=0.25,		range=1050,		radius=70,			speed=1800,				addHitbox=true,			danger=4,			dangerous=true,				proj="RocketGrabMissile",				killTime=0},
		["BrandQ"]=						{charName="Brand",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=60,			speed=1600,				addHitbox=true,			danger=3,			dangerous=true,				proj="BrandQMissile",					killTime=0},
		["BraumQ"]=						{charName="Braum",					slot=0,		type="Line",		delay=0.25,		range=1050,		radius=60,			speed=1700,				addHitbox=true,			danger=3,			dangerous=true,				proj="BraumQMissile",					killTime=0},
		["BraumRWrapper"]=				{charName="Braum",					slot=3,		type="Line",		delay=0.5,		range=1200,		radius=115,			speed=1400,				addHitbox=true,			danger=4,			dangerous=true,				proj="braumrmissile",					killTime=0},
		["CaitlynPiltoverPeacemaker"]=	{charName="Caitlyn",				slot=0,		type="Line",		delay=0.625,	range=1300,		radius=90,			speed=2200,				addHitbox=true,			danger=2,			dangerous=false,			proj="CaitlynPiltoverPeacemaker",		killTime=0},
		["CaitlynEntrapment"]=			{charName="Caitlyn",				slot=2,		type="Line",		delay=0.125,	range=1000,		radius=70,			speed=1600,				addHitbox=true,			danger=1,			dangerous=false,			proj="CaitlynEntrapmentMissile",		killTime=0},
		["CassiopeiaNoxiousBlast"]=		{charName="Cassiopeia",				slot=0,		type="Circle",		delay=0.75,		range=850,		radius=150,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="CassiopeiaNoxiousBlast",			killTime=0.2},
		["CassiopeiaPetrifyingGaze"]=	{charName="Cassiopeia",				slot=3,		type="Cone",		delay=0.6,		range=825,		radius=80,			speed=999999999,		addHitbox=false,		danger=5,			dangerous=true,				proj="CassiopeiaPetrifyingGaze",		killTime=0},
		["Rupture"]=					{charName="Chogath",				slot=0,		type="Circle",		delay=1.2,		range=950,		radius=250,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=false,			proj="Rupture",							killTime=0.45},
		["PhosphorusBomb"]=				{charName="Corki",					slot=0,		type="Circle",		delay=0.3,		range=825,		radius=250,			speed=1000,				addHitbox=true,			danger=2,			dangerous=false,			proj="PhosphorusBombMissile",			killTime=0.35},
		["MissileBarrage"]=				{charName="Corki",					slot=3,		type="Line",		delay=0.2,		range=1300,		radius=40,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="MissileBarrageMissile",			killTime=0},
		["MissileBarrage2"]=			{charName="Corki",					slot=3,		type="Line",		delay=0.2,		range=1500,		radius=40,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="MissileBarrageMissile2",			killTime=0},
		["DariusCleave"]=				{charName="Darius",					slot=0,		type="Circle",		delay=0.75,		range=0,		radius=425 - 50,	speed=999999999,		addHitbox=true,			danger=3,			dangerous=false,			proj="DariusCleave",					killTime=0},
		["DariusAxeGrabCone"]=			{charName="Darius",					slot=2,		type="Cone",		delay=0.25,		range=550,		radius=80,			speed=999999999,		addHitbox=false,		danger=3,			dangerous=true,				proj="DariusAxeGrabCone",				killTime=0},
		["DianaArc"]=					{charName="Diana",					slot=0,		type="Circle",		delay=0.25,		range=895,		radius=195,			speed=1400,				addHitbox=true,			danger=3,			dangerous=true,				proj="DianaArcArc",						killTime=0},
		["DianaArcArc"]=				{charName="Diana",					slot=0,		type="Line",		delay=0.25,		range=895,		radius=195,			speed=1400,				addHitbox=true,			danger=3,			dangerous=true,				proj="DianaArcArc",						killTime=0},
		["InfectedCleaverMissileCast"]=	{charName="DrMundo",				slot=0,		type="Line",		delay=0.25,		range=1050,		radius=60,			speed=2000,				addHitbox=true,			danger=3,			dangerous=false,			proj="InfectedCleaverMissile",			killTime=0},
		["DravenDoubleShot"]=			{charName="Draven",					slot=2,		type="Line",		delay=0.25,		range=1100,		radius=130,			speed=1400,				addHitbox=true,			danger=3,			dangerous=true,				proj="DravenDoubleShotMissile",			killTime=0},
		["DravenRCast"]=				{charName="Draven",					slot=3,		type="Line",		delay=0.4,		range=20000,	radius=160,			speed=2000,				addHitbox=true,			danger=5,			dangerous=true,				proj="DravenR",							killTime=0},
		["EkkoQ"]=						{charName="Ekko",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=1650,				addHitbox=true,			danger=4,			dangerous=true,				proj="ekkoqmis",						killTime=0},
		["EkkoW"]=						{charName="Ekko",					slot=1,		type="Circle",		delay=3.75,		range=1600,		radius=375,			speed=1650,				addHitbox=false,		danger=3,			dangerous=false,			proj="EkkoW",							killTime=1.2},
		["EkkoR"]=						{charName="Ekko",					slot=3,		type="Circle",		delay=0.25,		range=1600,		radius=375,			speed=1650,				addHitbox=true,			danger=3,			dangerous=false,			proj="EkkoR",							killTime=0.2},
		["EliseHumanE"]=				{charName="Elise",					slot=2,		type="Line",		delay=0.25,		range=1100,		radius=55,			speed=1600,				addHitbox=true,			danger=4,			dangerous=true,				proj="EliseHumanE",						killTime=0},
		["EvelynnR"]=					{charName="Evelynn",				slot=3,		type="Circle",		delay=0.25,		range=650,		radius=350,			speed=999999999,		addHitbox=true,			danger=5,			dangerous=true,				proj="EvelynnR",						killTime=0.2},
		["EzrealMysticShot"]=			{charName="Ezreal",					slot=0,		type="Line",		delay=0.25,		range=1200,		radius=60,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="EzrealMysticShotMissile",			killTime=0},
		["EzrealEssenceFlux"]=			{charName="Ezreal",					slot=1,		type="Line",		delay=0.25,		range=1050,		radius=80,			speed=1600,				addHitbox=true,			danger=2,			dangerous=false,			proj="EzrealEssenceFluxMissile",		killTime=0},
		["EzrealTrueshotBarrage"]=		{charName="Ezreal",					slot=3,		type="Line",		delay=1,		range=20000,	radius=160,			speed=2000,				addHitbox=true,			danger=3,			dangerous=true,				proj="EzrealTrueshotBarrage",			killTime=0},
		["FioraW"]=						{charName="Fiora",					slot=1,		type="Line",		delay=0.5,		range=800,		radius=70,			speed=3200,				addHitbox=true,			danger=2,			dangerous=false,			proj="FioraWMissile",					killTime=0},
		["FizzMarinerDoom"]=			{charName="Fizz",					slot=3,		type="Line",		delay=0.25,		range=1300,		radius=120,			speed=1350,				addHitbox=true,			danger=5,			dangerous=true,				proj="FizzMarinerDoomMissile",			killTime=0},
		["GalioResoluteSmite"]=			{charName="Galio",					slot=0,		type="Circle",		delay=0.25,		range=900,		radius=200,			speed=1300,				addHitbox=true,			danger=2,			dangerous=false,			proj="GalioResoluteSmite",				killTime=0.2},
		["GalioRighteousGust"]=			{charName="Galio",					slot=2,		type="Line",		delay=0.25,		range=1200,		radius=120,			speed=1200,				addHitbox=true,			danger=2,			dangerous=false,			proj="GalioRighteousGust",				killTime=0},
		["GnarQ"]=						{charName="Gnar",					slot=0,		type="Line",		delay=0.25,		range=1125,		radius=60,			speed=2500,				addHitbox=true,			danger=2,			dangerous=false,			proj="gnarqmissile",					killTime=0},
		["GnarQReturn"]=				{charName="Gnar",					slot=0,		type="Line",		delay=0,		range=2500,		radius=75,			speed=60,				addHitbox=true,			danger=2,			dangerous=false,			proj="GnarQMissileReturn",				killTime=0},
		["GnarBigQ"]=					{charName="Gnar",					slot=0,		type="Line",		delay=0.5,		range=1150,		radius=90,			speed=2100,				addHitbox=true,			danger=2,			dangerous=false,			proj="GnarBigQMissile",					killTime=0},
		["GnarBigW"]=					{charName="Gnar",					slot=1,		type="Line",		delay=0.6,		range=600,		radius=80,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="GnarBigW",						killTime=0},
		["GnarE"]=						{charName="Gnar",					slot=2,		type="Circle",		delay=0,		range=473,		radius=150,			speed=903,				addHitbox=true,			danger=2,			dangerous=false,			proj="GnarE",							killTime=0.2},
		["GnarBigE"]=					{charName="Gnar",					slot=2,		type="Circle",		delay=0.25,		range=475,		radius=200,			speed=1000,				addHitbox=true,			danger=2,			dangerous=false,			proj="GnarBigE",						killTime=0.2},
		["GragasQ"]=					{charName="Gragas",					slot=0,		type="Circle",		delay=0.25,		range=1100,		radius=275,			speed=1300,				addHitbox=true,			danger=2,			dangerous=false,			proj="GragasQMissile",					killTime=2.5},
		["GragasE"]=					{charName="Gragas",					slot=2,		type="Line",		delay=0,		range=950,		radius=200,			speed=1200,				addHitbox=true,			danger=2,			dangerous=false,			proj="GragasE",							killTime=0},
		["GragasR"]=					{charName="Gragas",					slot=3,		type="Circle",		delay=0.25,		range=1050,		radius=375,			speed=1800,				addHitbox=true,			danger=5,			dangerous=true,				proj="GragasRBoom",						killTime=0.3},
		["GravesQLineSpell"]=			{charName="Graves",					slot=0,		type="Line",		delay=0.25,		range=808,		radius=40,			speed=3000,				addHitbox=true,			danger=2,			dangerous=false,			proj="GravesQLineMis",					killTime=0},
		["GravesChargeShot"]=			{charName="Graves",					slot=3,		type="Line",		delay=0.25,		range=1100,		radius=100,			speed=2100,				addHitbox=true,			danger=5,			dangerous=true,				proj="GravesChargeShotShot",			killTime=0},
		["Heimerdingerwm"]=				{charName="Heimerdinger",			slot=1,		type="Line",		delay=0.25,		range=1500,		radius=70,			speed=1800,				addHitbox=true,			danger=2,			dangerous=false,			proj="HeimerdingerWAttack2",			killTime=0},
		["HeimerdingerE"]=				{charName="Heimerdinger",			slot=2,		type="Circle",		delay=0.25,		range=925,		radius=100,			speed=1200,				addHitbox=true,			danger=2,			dangerous=false,			proj="heimerdingerespell",				killTime=0.3},
		["IllaoiQ"]=					{charName="Illaoi",					slot=0,		type="Line",		delay=0.75,		range=850,		radius=100,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=true,				proj="illaoiemis",						killTime=0},
		["IllaoiE"]=					{charName="Illaoi",					slot=2,		type="Line",		delay=0.25,		range=950,		radius=50,			speed=1900,				addHitbox=true,			danger=3,			dangerous=true,				proj="illaoiemis",						killTime=0},
		["IreliaTranscendentBlades"]=	{charName="Irelia",					slot=3,		type="Line",		delay=0,		range=1200,		radius=65,			speed=1600,				addHitbox=true,			danger=2,			dangerous=false,			proj="IreliaTranscendentBlades",		killTime=0},
		["JannaQ"]=						{charName="Janna",					slot=0,		type="Line",		delay=0.25,		range=1700,		radius=120,			speed=900,				addHitbox=true,			danger=2,			dangerous=false,			proj="HowlingGaleSpell",				killTime=0},
		["JarvanIVDemacianStandard"]=	{charName="JarvanIV",				slot=2,		type="Circle",		delay=0.5,		range=860,		radius=175,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="JarvanIVDemacianStandard",		killTime=1.5},
		["jayceshockblast"]=			{charName="Jayce",					slot=0,		type="Line",		delay=0.25,		range=1300,		radius=70,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="JayceShockBlastMis",				killTime=0},
		["JayceQAccel"]=				{charName="Jayce",					slot=0,		type="Line",		delay=0.25,		range=1300,		radius=70,			speed=2350,				addHitbox=true,			danger=2,			dangerous=false,			proj="JayceShockBlastWallMis",			killTime=0},
		["JhinW"]=						{charName="Jhin",					slot=1,		type="Line",		delay=0.75,		range=2550,		radius=40,			speed=5000,				addHitbox=true,			danger=3,			dangerous=true,				proj="JhinWMissile",					killTime=0},
		["JhinRShot"]=					{charName="Jhin",					slot=3,		type="Line",		delay=0.25,		range=3500,		radius=80,			speed=5000,				addHitbox=true,			danger=3,			dangerous=true,				proj="JhinRShotMis",					killTime=0},
		["JinxW"]=						{charName="Jinx",					slot=1,		type="Line",		delay=0.6,		range=1500,		radius=60,			speed=3300,				addHitbox=true,			danger=3,			dangerous=true,				proj="JinxWMissile",					killTime=0},
		["JinxR"]=						{charName="Jinx",					slot=3,		type="Line",		delay=0.6,		range=20000,	radius=140,			speed=1700,				addHitbox=true,			danger=5,			dangerous=true,				proj="JinxR",							killTime=0},
		["KalistaMysticShot"]=			{charName="Kalista",				slot=0,		type="Line",		delay=0.25,		range=1200,		radius=40,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="kalistamysticshotmis",			killTime=0},
		["KarmaQ"]=						{charName="Karma",					slot=0,		type="Line",		delay=0.25,		range=1050,		radius=60,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="KarmaQMissile",					killTime=0},
		["KarmaQMantra"]=				{charName="Karma",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=80,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="KarmaQMissileMantra",				killTime=0},
		["RiftWalk"]=					{charName="Kassadin",				slot=3,		type="Circle",		delay=0.25,		range=450,		radius=270,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="RiftWalk",						killTime=0.3},
		["KennenShurikenHurlMissile1"]=	{charName="Kennen",					slot=0,		type="Line",		delay=0.125,	range=1050,		radius=50,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="KennenShurikenHurlMissile1",		killTime=0},
		["KhazixW"]=					{charName="Khazix",					slot=1,		type="Line",		delay=0.25,		range=1025,		radius=73,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="KhazixWMissile",					killTime=0},
		["KhazixE"]=					{charName="Khazix",					slot=2,		type="Circle",		delay=0.25,		range=600,		radius=300,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="KhazixE",							killTime=0.2},
		["KogMawQ"]=					{charName="Kogmaw",					slot=0,		type="Line",		delay=0.25,		range=1200,		radius=70,			speed=1650,				addHitbox=true,			danger=2,			dangerous=false,			proj="KogMawQ",							killTime=0},
		["KogMawVoidOoze"]=				{charName="Kogmaw",					slot=2,		type="Line",		delay=0.25,		range=1360,		radius=120,			speed=1400,				addHitbox=true,			danger=2,			dangerous=false,			proj="KogMawVoidOozeMissile",			killTime=0},
		["KogMawLivingArtillery"]=		{charName="Kogmaw",					slot=3,		type="Circle",		delay=1.2,		range=1800,		radius=225,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="KogMawLivingArtillery",			killTime=0.5},
		["LeblancSlide"]=				{charName="Leblanc",				slot=1,		type="Circle",		delay=0,		range=600,		radius=220,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="LeblancSlide",					killTime=0.2},
		["LeblancSlideM"]=				{charName="Leblanc",				slot=3,		type="Circle",		delay=0,		range=600,		radius=220,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="LeblancSlideM",					killTime=0.2},
		["LeblancSoulShackle"]=			{charName="Leblanc",				slot=2,		type="Line",		delay=0.25,		range=950,		radius=70,			speed=1750,				addHitbox=true,			danger=3,			dangerous=true,				proj="LeblancSoulShackle",				killTime=0},
		["LeblancSoulShackleM"]=		{charName="Leblanc",				slot=3,		type="Line",		delay=0.25,		range=950,		radius=70,			speed=1750,				addHitbox=true,			danger=3,			dangerous=true,				proj="LeblancSoulShackleM",				killTime=0},
		["BlindMonkQOne"]=				{charName="LeeSin",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=65,			speed=1800,				addHitbox=true,			danger=3,			dangerous=true,				proj="BlindMonkQOne",					killTime=0},
		["LeonaZenithBlade"]=			{charName="Leona",					slot=2,		type="Line",		delay=0.25,		range=905,		radius=70,			speed=2000,				addHitbox=true,			danger=3,			dangerous=true,				proj="LeonaZenithBladeMissile",			killTime=0},
		["LeonaSolarFlare"]=			{charName="Leona",					slot=3,		type="Circle",		delay=1,		range=1200,		radius=300,			speed=999999999,		addHitbox=true,			danger=5,			dangerous=true,				proj="LeonaSolarFlare",					killTime=0.5},
		["LissandraQ"]=					{charName="Lissandra",				slot=0,		type="Line",		delay=0.25,		range=700,		radius=75,			speed=2200,				addHitbox=true,			danger=2,			dangerous=false,			proj="LissandraQMissile",				killTime=0},
		["LissandraQShards"]=			{charName="Lissandra",				slot=0,		type="Line",		delay=0.25,		range=700,		radius=90,			speed=2200,				addHitbox=true,			danger=2,			dangerous=false,			proj="lissandraqshards",				killTime=0},
		["LissandraE"]=					{charName="Lissandra",				slot=2,		type="Line",		delay=0.25,		range=1025,		radius=125,			speed=850,				addHitbox=true,			danger=2,			dangerous=false,			proj="LissandraEMissile",				killTime=0},
		["LucianQ"]=					{charName="Lucian",					slot=0,		type="Line",		delay=0.5,		range=1300,		radius=65,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="LucianQ",							killTime=0},
		["LucianW"]=					{charName="Lucian",					slot=1,		type="Line",		delay=0.25,		range=1000,		radius=55,			speed=1600,				addHitbox=true,			danger=2,			dangerous=false,			proj="lucianwmissile",					killTime=0},
		["LucianRMis"]=					{charName="Lucian",					slot=3,		type="Line",		delay=0.5,		range=1400,		radius=110,			speed=2800,				addHitbox=true,			danger=2,			dangerous=false,			proj="lucianrmissileoffhand",			killTime=0},
		["LuluQ"]=						{charName="Lulu",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="LuluQMissile",					killTime=0},
		["LuluQPix"]=					{charName="Lulu",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="LuluQMissileTwo",					killTime=0},
		["LuxLightBinding"]=			{charName="Lux",					slot=0,		type="Line",		delay=0.25,		range=1300,		radius=70,			speed=1200,				addHitbox=true,			danger=3,			dangerous=true,				proj="LuxLightBindingMis",				killTime=0},
		["LuxLightStrikeKugel"]=		{charName="Lux",					slot=2,		type="Circle",		delay=0.25,		range=1100,		radius=275,			speed=1300,				addHitbox=true,			danger=2,			dangerous=false,			proj="LuxLightStrikeKugel",				killTime=5.25},
		["LuxMaliceCannon"]=			{charName="Lux",					slot=3,		type="Line",		delay=1,		range=3500,		radius=190,			speed=999999999,		addHitbox=true,			danger=5,			dangerous=true,				proj="LuxMaliceCannon",					killTime=0},
		["UFSlash"]=					{charName="Malphite",				slot=3,		type="Circle",		delay=0,		range=1000,		radius=270,			speed=1500,				addHitbox=true,			danger=5,			dangerous=true,				proj="UFSlash",							killTime=0.4},
		["MalzaharQ"]=					{charName="Malzahar",				slot=0,		type="Line",		delay=0.75,		range=900,		radius=85,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="MalzaharQ",						killTime=0},
		["DarkBindingMissile"]=			{charName="Morgana",				slot=0,		type="Line",		delay=0.25,		range=1300,		radius=80,			speed=1200,				addHitbox=true,			danger=3,			dangerous=true,				proj="DarkBindingMissile",				killTime=0},
		["NamiQ"]=						{charName="Nami",					slot=0,		type="Circle",		delay=0.95,		range=1625,		radius=150,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=true,				proj="namiqmissile",					killTime=0.35},
		["NamiR"]=						{charName="Nami",					slot=3,		type="Line",		delay=0.5,		range=2750,		radius=260,			speed=850,				addHitbox=true,			danger=2,			dangerous=false,			proj="NamiRMissile",					killTime=0},
		["NautilusAnchorDrag"]=			{charName="Nautilus",				slot=0,		type="Line",		delay=0.25,		range=1250,		radius=90,			speed=2000,				addHitbox=true,			danger=3,			dangerous=true,				proj="NautilusAnchorDragMissile",		killTime=0},
		["NocturneDuskbringer"]=		{charName="Nocturne",				slot=0,		type="Line",		delay=0.25,		range=1125,		radius=60,			speed=1400,				addHitbox=true,			danger=2,			dangerous=false,			proj="NocturneDuskbringer",				killTime=0},
		["JavelinToss"]=				{charName="Nidalee",				slot=0,		type="Line",		delay=0.25,		range=1500,		radius=40,			speed=1300,				addHitbox=true,			danger=3,			dangerous=true,				proj="JavelinToss",						killTime=0},
		["OlafAxeThrowCast"]=			{charName="Olaf",					slot=0,		type="Line",		delay=0.25,		range=1000,		radius=105,			speed=1600,				addHitbox=true,			danger=2,			dangerous=false,			proj="olafaxethrow",					killTime=0},
		["OriannasQ"]=					{charName="Orianna",				slot=0,		type="Line",		delay=0,		range=1500,		radius=80,			speed=1200,				addHitbox=true,			danger=2,			dangerous=false,			proj="orianaizuna",						killTime=0},
		["OrianaDissonanceCommand-"]=	{charName="Orianna",				slot=1,		type="Circle",		delay=0.25,		range=0,		radius=255,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="OrianaDissonanceCommand-",		killTime=0.3},
		["OriannasE"]=					{charName="Orianna",				slot=2,		type="Line",		delay=0,		range=1500,		radius=85,			speed=1850,				addHitbox=true,			danger=2,			dangerous=false,			proj="orianaredact",					killTime=0},
		["OrianaDetonateCommand-"]=		{charName="Orianna",				slot=3,		type="Circle",		delay=0.7,		range=0,		radius=410,			speed=999999999,		addHitbox=true,			danger=5,			dangerous=true,				proj="OrianaDetonateCommand-",			killTime=0.5},
		["QuinnQ"]=						{charName="Quinn",					slot=0,		type="Line",		delay=0.313,	range=1050,		radius=60,			speed=1550,				addHitbox=true,			danger=2,			dangerous=false,			proj="QuinnQ",							killTime=0},
		["PoppyQ"]=						{charName="Poppy",					slot=0,		type="Line",		delay=0.5,		range=430,		radius=100,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="PoppyQ",							killTime=0},
		["PoppyRSpell"]=				{charName="Poppy",					slot=3,		type="Line",		delay=0.3,		range=1200,		radius=100,			speed=1600,				addHitbox=true,			danger=3,			dangerous=true,				proj="PoppyRMissile",					killTime=0},
		["RengarE"]=					{charName="Rengar",					slot=2,		type="Line",		delay=0.25,		range=1000,		radius=70,			speed=1500,				addHitbox=true,			danger=3,			dangerous=true,				proj="RengarEFinal",					killTime=0},
		["reksaiqburrowed"]=			{charName="RekSai",					slot=0,		type="Line",		delay=0.5,		range=1625,		radius=60,			speed=1950,				addHitbox=true,			danger=3,			dangerous=false,			proj="RekSaiQBurrowedMis",				killTime=0},
		["rivenizunablade"]=			{charName="Riven",					slot=3,		type="Line",		delay=0.25,		range=1100,		radius=125,			speed=1600,				addHitbox=false,		danger=5,			dangerous=true,				proj="RivenLightsaberMissile",			killTime=0},
		["RumbleGrenade"]=				{charName="Rumble",					slot=2,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="RumbleGrenade",					killTime=0},
		["RumbleCarpetBombM"]=			{charName="Rumble",					slot=3,		type="Line",		delay=0.4,		range=1200,		radius=200,			speed=1600,				addHitbox=true,			danger=4,			dangerous=false,			proj="RumbleCarpetBombMissile",			killTime=0},
		["RyzeQ"]=						{charName="Ryze",					slot=0,		type="Line",		delay=0.25,		range=900,		radius=50,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="RyzeQ",							killTime=0},
		["ryzerq"]=						{charName="Ryze",					slot=0,		type="Line",		delay=0.25,		range=900,		radius=50,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ryzerq",							killTime=0},
		["SejuaniGlacialPrisonStart"]=	{charName="Sejuani",				slot=3,		type="Line",		delay=0.25,		range=1100,		radius=110,			speed=1600,				addHitbox=true,			danger=3,			dangerous=true,				proj="sejuaniglacialprison",			killTime=0},
		["SionE"]=						{charName="Sion",					slot=2,		type="Line",		delay=0.25,		range=800,		radius=80,			speed=1800,				addHitbox=true,			danger=3,			dangerous=true,				proj="SionEMissile",					killTime=0},
		["ShenE"]=						{charName="Shen",					slot=2,		type="Line",		delay=0,		range=650,		radius=50,			speed=1600,				addHitbox=true,			danger=3,			dangerous=true,				proj="ShenE",							killTime=0},
		["ShyvanaFireball"]=			{charName="Shyvana",				slot=2,		type="Line",		delay=0.25,		range=950,		radius=60,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ShyvanaFireballMissile",			killTime=0},
		["ShyvanaTransformCast"]=		{charName="Shyvana",				slot=3,		type="Line",		delay=0.25,		range=1000,		radius=150,			speed=1500,				addHitbox=true,			danger=3,			dangerous=true,				proj="ShyvanaTransformCast",			killTime=0},
		["shyvanafireballdragon2"]=		{charName="Shyvana",				slot=3,		type="Line",		delay=0.25,		range=850,		radius=70,			speed=2000,				addHitbox=true,			danger=3,			dangerous=false,			proj="ShyvanaFireballDragonFxMissile",	killTime=0},
		["SivirQReturn"]=				{charName="Sivir",					slot=0,		type="Line",		delay=0,		range=1250,		radius=100,			speed=1350,				addHitbox=true,			danger=2,			dangerous=false,			proj="SivirQMissileReturn",				killTime=0},
		["SivirQ"]=						{charName="Sivir",					slot=0,		type="Line",		delay=0.25,		range=1250,		radius=90,			speed=1350,				addHitbox=true,			danger=2,			dangerous=false,			proj="SivirQMissile",					killTime=0},
		["SkarnerFracture"]=			{charName="Skarner",				slot=2,		type="Line",		delay=0.25,		range=1000,		radius=70,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="SkarnerFractureMissile",			killTime=0},
		["SonaR"]=						{charName="Sona",					slot=3,		type="Line",		delay=0.25,		range=1000,		radius=140,			speed=2400,				addHitbox=true,			danger=5,			dangerous=true,				proj="SonaR",							killTime=0},
		["SwainShadowGrasp"]=			{charName="Swain",					slot=1,		type="Circle",		delay=1.1,		range=900,		radius=180,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=true,				proj="SwainShadowGrasp",				killTime=0.5},
		["SyndraQ"]=					{charName="Syndra",					slot=0,		type="Circle",		delay=0.6,		range=800,		radius=150,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="SyndraQ",							killTime=0.2},
		["syndrawcast"]=				{charName="Syndra",					slot=1,		type="Circle",		delay=0.25,		range=950,		radius=210,			speed=1450,				addHitbox=true,			danger=2,			dangerous=false,			proj="syndrawcast",						killTime=0.2},
		["syndrae5"]=					{charName="Syndra",					slot=2,		type="Line",		delay=0,		range=950,		radius=100,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="syndrae5",						killTime=0},
		["SyndraE"]=					{charName="Syndra",					slot=2,		type="Line",		delay=0,		range=950,		radius=100,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="SyndraE",							killTime=0},
		["TalonRake"]=					{charName="Talon",					slot=1,		type="Line",		delay=0.25,		range=800,		radius=80,			speed=2300,				addHitbox=true,			danger=2,			dangerous=true,				proj="talonrakemissileone",				killTime=0},
		["TalonRakeReturn"]=			{charName="Talon",					slot=1,		type="Line",		delay=0.25,		range=800,		radius=80,			speed=1850,				addHitbox=true,			danger=2,			dangerous=true,				proj="talonrakemissiletwo",				killTime=0},
		["TahmKenchQ"]=					{charName="TahmKench",				slot=0,		type="Line",		delay=0.25,		range=951,		radius=90,			speed=2800,				addHitbox=true,			danger=3,			dangerous=true,				proj="tahmkenchqmissile",				killTime=0},
		["TaricE"]=						{charName="Taric",					slot=2,		type="Line",		delay=1,		range=750,		radius=100,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=true,				proj="TaricE",							killTime=0},
		["ThreshQ"]=					{charName="Thresh",					slot=0,		type="Line",		delay=0.5,		range=1100,		radius=70,			speed=1900,				addHitbox=true,			danger=3,			dangerous=true,				proj="ThreshQMissile",					killTime=0},
		["ThreshEFlay"]=				{charName="Thresh",					slot=2,		type="Line",		delay=0.125,	range=1075,		radius=110,			speed=2000,				addHitbox=true,			danger=3,			dangerous=true,				proj="ThreshEMissile1",					killTime=0},
		["RocketJump"]=					{charName="Tristana",				slot=1,		type="Circle",		delay=0.5,		range=900,		radius=270,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="RocketJump",						killTime=0.3},
		["slashCast"]=					{charName="Tryndamere",				slot=2,		type="Line",		delay=0,		range=660,		radius=93,			speed=1300,				addHitbox=true,			danger=2,			dangerous=false,			proj="slashCast",						killTime=0},
		["WildCards"]=					{charName="TwistedFate",			slot=0,		type="Line",		delay=0.25,		range=1450,		radius=40,			speed=1000,				addHitbox=true,			danger=2,			dangerous=false,			proj="SealFateMissile",					killTime=0},
		["TwitchVenomCask"]=			{charName="Twitch",					slot=1,		type="Circle",		delay=0.25,		range=900,		radius=275,			speed=1400,				addHitbox=true,			danger=2,			dangerous=false,			proj="TwitchVenomCaskMissile",			killTime=0.3},
		["UrgotHeatseekingLineMissile"]={charName="Urgot",					slot=0,		type="Line",		delay=0.125,	range=1000,		radius=60,			speed=1600,				addHitbox=true,			danger=2,			dangerous=false,			proj="UrgotHeatseekingLineMissile",		killTime=0},
		["UrgotPlasmaGrenade"]=			{charName="Urgot",					slot=2,		type="Circle",		delay=0.25,		range=1100,		radius=210,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="UrgotPlasmaGrenadeBoom",			killTime=0.3},
		["VarusQMissilee"]=				{charName="Varus",					slot=0,		type="Line",		delay=0.25,		range=1800,		radius=70,			speed=1900,				addHitbox=true,			danger=2,			dangerous=false,			proj="VarusQMissile",					killTime=0},
		["VarusE"]=						{charName="Varus",					slot=2,		type="Circle",		delay=1,		range=925,		radius=235,			speed=1500,				addHitbox=true,			danger=2,			dangerous=false,			proj="VarusE",							killTime=1.5},
		["VarusR"]=						{charName="Varus",					slot=3,		type="Line",		delay=0.25,		range=1200,		radius=120,			speed=1950,				addHitbox=true,			danger=3,			dangerous=true,				proj="VarusRMissile",					killTime=0},
		["VeigarBalefulStrike"]=		{charName="Veigar",					slot=0,		type="Line",		delay=0.25,		range=950,		radius=70,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="VeigarBalefulStrikeMis",			killTime=0},
		["VelkozQ"]=					{charName="Velkoz",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=50,			speed=1300,				addHitbox=true,			danger=2,			dangerous=false,			proj="VelkozQMissile",					killTime=0},
		["VelkozQSplit"]=				{charName="Velkoz",					slot=0,		type="Line",		delay=0.25,		range=1100,		radius=55,			speed=2100,				addHitbox=true,			danger=2,			dangerous=false,			proj="VelkozQMissileSplit",				killTime=0},
		["VelkozW"]=					{charName="Velkoz",					slot=1,		type="Line",		delay=0.25,		range=1200,		radius=88,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="VelkozWMissile",					killTime=0},
		["VelkozE"]=					{charName="Velkoz",					slot=2,		type="Circle",		delay=0.5,		range=800,		radius=225,			speed=1500,				addHitbox=false,		danger=2,			dangerous=false,			proj="VelkozEMissile",					killTime=0.5},
		["Vi-q"]=						{charName="Vi",						slot=0,		type="Line",		delay=0.25,		range=1000,		radius=90,			speed=1500,				addHitbox=true,			danger=3,			dangerous=true,				proj="ViQMissile",						killTime=0},
		["Laser"]=						{charName="Viktor",					slot=2,		type="Line",		delay=0.25,		range=1500,		radius=80,			speed=1050,				addHitbox=true,			danger=2,			dangerous=false,			proj="ViktorDeathRayMissile",			killTime=0},
		["xeratharcanopulse2"]=			{charName="Xerath",					slot=0,		type="Line",		delay=0.6,		range=1600,		radius=95,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="xeratharcanopulse2",				killTime=0},
		["XerathArcaneBarrage2"]=		{charName="Xerath",					slot=1,		type="Circle",		delay=0.7,		range=1000,		radius=200,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="XerathArcaneBarrage2",			killTime=0.3},
		["XerathMageSpear"]=			{charName="Xerath",					slot=2,		type="Line",		delay=0.2,		range=1150,		radius=60,			speed=1400,				addHitbox=true,			danger=2,			dangerous=true,				proj="XerathMageSpearMissile",			killTime=0},
		["xerathrmissilewrapper"]=		{charName="Xerath",					slot=3,		type="Circle",		delay=0.7,		range=5600,		radius=130,			speed=999999999,		addHitbox=true,			danger=3,			dangerous=true,				proj="xerathrmissilewrapper",			killTime=0.4},
		["YasuoQ3W"]=					{charName="Yasuo",					slot=0,		type="Line",		delay=0.5,		range=1150,		radius=90,			speed=1500,				addHitbox=true,			danger=3,			dangerous=true,				proj="yasuoq3w",						killTime=0},
		["ZacQ"]=						{charName="Zac",					slot=0,		type="Line",		delay=0.5,		range=550,		radius=120,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="ZacQ",							killTime=0},
		["ZedQ"]=						{charName="Zed",					slot=0,		type="Line",		delay=0.25,		range=925,		radius=50,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZedQMissile",						killTime=0},
		["ZiggsQ"]=						{charName="Ziggs",					slot=0,		type="Circle",		delay=0.25,		range=850,		radius=140,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsQSpell",						killTime=0.2},
		["ZiggsQBounce1"]=				{charName="Ziggs",					slot=0,		type="Circle",		delay=0.25,		range=850,		radius=140,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsQSpell2",					killTime=0.2},
		["ZiggsQBounce2"]=				{charName="Ziggs",					slot=0,		type="Circle",		delay=0.25,		range=850,		radius=160,			speed=1700,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsQSpell3",					killTime=0.2},
		["ZiggsW"]=						{charName="Ziggs",					slot=1,		type="Circle",		delay=0.25,		range=1000,		radius=275,			speed=1750,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsW",							killTime=2.25},
		["ZiggsE"]=						{charName="Ziggs",					slot=2,		type="Circle",		delay=0.5,		range=900,		radius=235,			speed=1750,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsE",							killTime=2.5},
		["ZiggsR"]=						{charName="Ziggs",					slot=3,		type="Circle",		delay=0,		range=5300,		radius=500,			speed=999999999,		addHitbox=true,			danger=2,			dangerous=false,			proj="ZiggsR",							killTime=1.25},
		["ZileanQ"]=					{charName="Zilean",					slot=0,		type="Circle",		delay=0.3,		range=900,		radius=210,			speed=2000,				addHitbox=true,			danger=2,			dangerous=false,			proj="ZileanQMissile",					killTime=1.5},
		["ZyraE"]=						{charName="Zyra",					slot=2,		type="Line",		delay=0.25,		range=1150,		radius=70,			speed=1150,				addHitbox=true,			danger=3,			dangerous=true,				proj="ZyraE",							killTime=0},
	}]]

	self.Color = ARGB(255,255,255,255)
	self.abc = false
	self.Point = nil

	self.Dick = 
	{

		[0] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[1].Sprite ,self.Sprite[1].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[1].Sprite ,self.Sprite[1].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[5].Sprite ,self.Sprite[5].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[5].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
												DrawText(string.format("%.2f", self.Spells[0].Timer), 25, self.Sprite[1].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[5].Sprite ,self.Sprite[5].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[5].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells[0].Timer), 25, self.Sprite[1].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))	
											end
										end end,
		},

		[1] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[2].Sprite ,self.Sprite[2].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[2].Sprite ,self.Sprite[2].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit)	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[6].Sprite ,self.Sprite[6].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[6].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[1].Timer), 25, self.Sprite[2].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[6].Sprite ,self.Sprite[6].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[6].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[1].Timer), 25, self.Sprite[2].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[2] = 
		{
			[true] 	= function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[3].Sprite ,self.Sprite[3].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[3].Sprite ,self.Sprite[3].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[7].Sprite ,self.Sprite[7].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[7].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[2].Timer), 25, self.Sprite[3].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[7].Sprite ,self.Sprite[7].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[7].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[2].Timer), 25, self.Sprite[3].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[3] = 
		{
			[true] 	= function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[4].Sprite ,self.Sprite[4].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[4].Sprite ,self.Sprite[4].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[8].Sprite ,self.Sprite[8].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[8].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[3].Timer), 25, self.Sprite[4].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[8].Sprite ,self.Sprite[8].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[8].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[3].Timer), 25, self.Sprite[4].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,

		},
	}

	self.Dick2 =
	{

		[0] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[9].Sprite ,self.Sprite[9].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[9].Sprite ,self.Sprite[9].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[13].Sprite ,self.Sprite[13].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[13].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[0].Timer), 25, self.Sprite[9].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[13].Sprite ,self.Sprite[13].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[13].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[0].Timer), 25, self.Sprite[9].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[1] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[10].Sprite ,self.Sprite[10].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[10].Sprite ,self.Sprite[10].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)												
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[14].Sprite ,self.Sprite[14].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[14].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells2[1].Timer), 25, self.Sprite[10].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[14].Sprite ,self.Sprite[14].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[14].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells2[1].Timer), 25, self.Sprite[10].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},						
		[2] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[11].Sprite ,self.Sprite[11].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[11].Sprite ,self.Sprite[11].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)												
											end
										end end,

			[false] = function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[15].Sprite ,self.Sprite[15].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[15].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[2].Timer), 25, self.Sprite[11].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[15].Sprite ,self.Sprite[15].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[15].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[2].Timer), 25, self.Sprite[11].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[3] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[12].Sprite ,self.Sprite[12].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[12].Sprite ,self.Sprite[12].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)		
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[16].Sprite ,self.Sprite[16].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[16].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[3].Timer), 25, self.Sprite[12].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[16].Sprite ,self.Sprite[16].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[16].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[3].Timer), 25, self.Sprite[12].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
	}

	self.Stuff =
	{
		["Combo"] =
		{
			[1] =
			{
				[true] = 	function(Unit) 						
								if ConfigMenu.Champ.C.H.Q:Value() then
									self:CastQ(Unit)
								end

								if ConfigMenu.Champ.C.H.W:Value() then
									self:CastW(Unit)
								end

								if ConfigMenu.Champ.C.H.E:Value() then
									self:CastE(Unit)
								end
							end,

				[false] = 	function(Unit)
								if not self.Spells[3].Ready then
									if ConfigMenu.Champ.C.S.Q:Value() then 
										self:CastSQ(Unit)
									end 

									if ConfigMenu.Champ.C.S.W:Value() then 
										self:CastSW(Unit)
									end 
								else 
									CastSpell(3) 
								end 
							end,
			},

			[2] =
			{
				[true] = 	function(Unit)
								if not self.Spells2[3].Ready then
									if ConfigMenu.Champ.C.H.Q:Value() then
										self:CastQ(Unit)
									end

									if ConfigMenu.Champ.C.H.W:Value() then
										self:CastW(Unit)
									end
									self:CastE(Unit)
								else
									CastSpell(3)
								end
							end,

				[false] = 	function(Unit)
								if ConfigMenu.Champ.C.S.Q:Value() then 
									self:CastSQ(Unit) 
								end 

								if ConfigMenu.Champ.C.S.W:Value() then 
									self:CastSW(Unit) 
								end 
							end,

			},

			[3] =
			{
				[true] = 	function(Unit)
								if ConfigMenu.Champ.C.H.Q:Value() then
									self:CastQ(Unit)
								end

								if ConfigMenu.Champ.C.H.W:Value() then
									self:CastW(Unit)
								end

								if ConfigMenu.Champ.C.H.E:Value() then
									self:CastE(Unit)
								end

								if not self.Spells[3].Ready then
									self:CastE(Unit)
								else
									if not self.Spells[0].Ready and not self.Spells[1].Ready and not self.Spells[2].Ready then
										CastSpell(3)
									end
								end
							end,

				[false] = 	function(Unit)
								if ConfigMenu.Champ.C.S.Q:Value() then
									self:CastSQ(Unit)
								end

								if ConfigMenu.Champ.C.S.W:Value() then
									self:CastSW(Unit)
								end

								if self.Spells2[3].Ready then
									if not self.Spells2[0].Ready and self.Spells[0].Ready then
										CastSpell(3)
									end
								end
							end,	
			},		
		},
	}


	Human = true
	self.WBuff = nil
	self.WTable = {}
	self.Point = nil
	self.Unit = nil
	self.aaTimer = 0
	self.aaTimeReady = 0
	self.windUP = 0
	self.baseAS = GetBaseAttackSpeed(myHero)

	ConfigMenu.Champ:Menu("C", "Combo")
		ConfigMenu.Champ.C:SubMenu("H", "Human Combo")
			ConfigMenu.Champ.C.H:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.C.H:Boolean("W", "Use W", true)
			ConfigMenu.Champ.C.H:Boolean("E", "Use W", true)
		ConfigMenu.Champ.C:SubMenu("S", "Spider Combo")
			ConfigMenu.Champ.C.S:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.C.S:Boolean("W", "Use W", true)
		ConfigMenu.Champ.C:DropDown("F", "Choose ur form", 3, {"Human", "Spider", "Both"})		

	ConfigMenu.Champ:Menu("JC", "JunglerClear")
		ConfigMenu.Champ.JC:SubMenu("H", "Human Combo")
			ConfigMenu.Champ.JC.H:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.JC.H:Boolean("W", "Use W", true)
		ConfigMenu.Champ.JC:SubMenu("S", "Spider Combo")
			ConfigMenu.Champ.JC.S:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.JC.S:Boolean("W", "Use W", true)

	ConfigMenu.Champ:Menu("LC", "LaneClear")
		ConfigMenu.Champ.LC:SubMenu("H", "Human Combo")
			ConfigMenu.Champ.LC.H:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.LC.H:Boolean("W", "Use W", true)
		ConfigMenu.Champ.LC:SubMenu("S", "Spider Combo")
			ConfigMenu.Champ.LC.S:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.LC.S:Boolean("W", "Use W", true)

	ConfigMenu.Champ:Menu("KS", "KillSteal")
		ConfigMenu.Champ.KS:Boolean("Q", "Use Human Q in KillSteal", true)
		ConfigMenu.Champ.KS:Boolean("W", "Use Human W in KillSteal", true)
		ConfigMenu.Champ.KS:Boolean("SQ", "Use Spider Q in KillSteal", true)
		ConfigMenu.Champ.KS:Boolean("SW", "Use Spider W in KillSteal", true)

	ConfigMenu.Champ:Menu("D", "Draws")
		ConfigMenu.Champ.D:Boolean("F", "Draw different form CD?", true)
		ConfigMenu.Champ.D:SubMenu("HD", "Human Draws")
			ConfigMenu.Champ.D.HD:Boolean("Q", "Draw Q range", true)
			ConfigMenu.Champ.D.HD:Boolean("W", "Draw W range", true)
			ConfigMenu.Champ.D.HD:Boolean("E", "Draw E range", true)
		ConfigMenu.Champ.D:SubMenu("SD", "Spider Draws")
			ConfigMenu.Champ.D.SD:Boolean("Q", "Draw Q range", true)
			ConfigMenu.Champ.D.SD:Boolean("E", "Draw E range", true)		
		ConfigMenu.Champ.D:Slider("Q", "Quality", 155, 1, 255)
		ConfigMenu.Champ.D:Boolean("DD", "Draw Total Dmg?", true)
      	ConfigMenu.Champ.D:SubMenu("S", "Sprites")
      		ConfigMenu.Champ.D.S:SubMenu("X", "X Pos")
	      		ConfigMenu.Champ.D.S.X:Slider("QX", "PosX", 0, -1000, 1000)
	      	ConfigMenu.Champ.D.S:SubMenu("Y", "Y Pos")
	      		ConfigMenu.Champ.D.S.Y:Slider("QY", "PosX", 0, -1000, 1000)
	      	ConfigMenu.Champ.D.S:Boolean("H", "Horizontal?", true)
	      	ConfigMenu.Champ.D.S:Slider("T", "Move ur time", 0, -50, 50)

	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
		ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
		ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)

	--ConfigMenu.Champ:Menu("E", "E Options")
		--ConfigMenu.Champ.E:SubMenu("SE", "Spider E")

	ConfigMenu.Champ:Menu("HC", "HitChance")
		ConfigMenu.Champ.HC:Slider("E", "E HitChance", 20, 1, 100)
	self:Sprites()
	self:Download()

	--[[DelayAction(function()

		for k, v in pairs(self.SpellsTable) do
			if ConfigMenu.Champ.E.SE[v.charName] then
				local wow = {[0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
					ConfigMenu.Champ.E.SE[v.charName]:Boolean(v.charName, "Evade "..wow[v.slot], true)
			end
		end
	end, 0.001)]]

	OnTick(function(myHero) self:Tick(myHero) end)
	OnDraw(function(myHero) self:Draw(myHero) end)
	OnProcessSpellCast(function(unit, spell) self:OnCast(unit, spell) end)
	--OnProcessSpellComplete(function(Object, spellProc) self:OnProcComplete(Object, spellProc) end)
	--[[OnCreateObj(function(Object) self:OnCreate(Object) end)
	OnDeleteObj(function(Object) self:OnDelete(Object) end)]]
end
--><

function Elise:Sprites()
	for i = 1,16,1 do
		if FileExist(SPRITE_PATH..self.Sprite[i].FName) then
        	self.Sprite[i].Sprite = CreateSpriteFromFile(self.Sprite[i].FName, 1)
		end
	end
end

function Elise:Tick(myHero)
	local target = DickSelector:Targets(1000)
	self:Checks()
	if target and ConfigMenu.Champ.Orb.C:Value() then
		self.Stuff["Combo"][ConfigMenu.Champ.C.F:Value()][Human](target)
	end

	if ConfigMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
	end
end


function Elise:LaneClear()
	for k, Unit in ipairs(minionManager.objects) do
		if GetTeam(Unit) == 200 then 
			if Human then
								if ConfigMenu.Champ.LC.H.Q:Value() then
									self:CastQ(Unit)
								end

								if ConfigMenu.Champ.LC.H.W:Value() then
									self:CastW(Unit)
								end

								if self.Spells[3].Ready and not self.Spells[0].Ready and not self.Spells[1].Ready then
									CastSpell(3)
								end
			else
								if ConfigMenu.Champ.LC.H.Q:Value() then
									self:CastSQ(Unit)
								end

								if ConfigMenu.Champ.LC.H.W:Value() then
									self:CastSW(Unit)
								end

								if self.Spells2[3].Ready and not self.Spells2[0].Ready and not self.WBuff and self.Spells[0].Ready and self.Spells[1].Ready then
									CastSpell(3)
								end
			end
		elseif GetTeam(Unit) == 300 then
			if Human then 
								if ConfigMenu.Champ.JC.H.Q:Value() then
									self:CastQ(Unit)
								end

								if ConfigMenu.Champ.JC.H.W:Value() then
									self:CastW(Unit)
								end

								if self.Spells[3].Ready and not self.Spells[0].Ready and not self.Spells[1].Ready then
									CastSpell(3)
								end
			else 
								if ConfigMenu.Champ.JC.H.Q:Value() then
									self:CastSQ(Unit)
								end

								if ConfigMenu.Champ.JC.H.W:Value() then
									self:CastSW(Unit)
								end

								if self.Spells2[3].Ready and not self.Spells2[0].Ready and not self.WBuff and self.Spells[0].Ready and self.Spells[1].Ready then
									CastSpell(3)
								end
			end
		end
	end
end

function Elise:Draw(myHero)
	if FileExist(SPRITE_PATH..self.Sprite[16].FName) then
		if ConfigMenu.Champ.D.F:Value() then
			for k = 0, 3, 1 do
				if Human then
					self.Dick2[k][self.Spells2[k].Ready](Unit)
				else
					self.Dick[k][self.Spells[k].Ready](Unit)
				end
			end
		end
	end
end

function Elise:Checks()
	if GetCastName(myHero, 0) == "EliseHumanQ" then
		Human = true
	else
		Human = false
	end

	if self.aaTimeReady ~= nil then
		self.aaTimer = self.aaTimeReady - GetGameTimer()
		if self.aaTimer <= 0 then
			self.aaTimer = 0
		end
	end

	for i = 0, 3, 1 do
		self.Spells[i].Timer = self.Spells[i].CDT + self.Spells[i].CD(myHero) - GetGameTimer()
		self.Spells2[i].Timer = self.Spells2[i].CDT + self.Spells2[i].CD(myHero) - GetGameTimer()
		if self.Spells[i].Timer <= 0 then
			self.Spells[i].Ready = true
			self.Spells[i].Timer = 0
		else
			self.Spells[i].Ready = false
		end

		if self.Spells2[i].Timer <= 0 then
			self.Spells2[i].Ready = true
			self.Spells2[i].Timer = 0
		else
			self.Spells2[i].Ready = false
		end

		if GetCastLevel(myHero, i) == 0 then
			self.Spells[i].Ready = false
			self.Spells2[i].Ready = false
		end
	end
end

function Elise:OnCast(unit, spell)
	if unit == myHero then
		for i = 0, 3, 1 do
			if Human then
				if spell.name == self.Spells[i].Name then
					self.Spells[i].CDT = GetGameTimer()
				end
			else
				if spell.name == self.Spells2[i].Name then
					self.Spells2[i].CDT = GetGameTimer()
				end				
			end
		end
	end
end

--[[function Elise:OnProcComplete(Object, spellProc)
	local V1 = nil
	local Unit = nil
	if Object == myHero and not Human then
		if spellProc.name:lower():find("attack") then
			ASDelay = 1/(self.baseAS*GetAttackSpeed(myHero))
			self.windUP = spellProc.windUpTime
			self.aaTimeReady = ASDelay + GetGameTimer() - self.windUP/1000
			--if ConfigMenu.Champ.Orb.LC:Value() then
			self.Unit = spellProc.target
			Unit = spellProc.target
					if self.aaTimer ~= 0 then
						V1 = Unit.pos + Vector(Vector(GetOrigin(myHero)) - Vector(Unit.pos)):normalized()*GetMoveSpeed(myHero)
						self.Point = V1
					else
						V1 = Unit.pos + Vector(Vector(GetOrigin(myHero)) - Vector(Unit.pos)):normalized()*(GetMoveSpeed(myHero)*self.aaTimer)
						self.Point = V1
					end
					self:Orb(false)
					--MoveToXYZ(V1)
					DelayAction(function() self:Orb(true) end, GetDistance(V1)/GetMoveSpeed(myHero))
			--end
		end
	end
end]]

function Elise:KS()
	for k, v in ipairs(GetEnemyHeroes()) do
		if Human then
			if GetCurrentHP(v) <= Dmg[0](v) then
				self:CastQ(v)
			end

			if GetCurrentHP(v) <= Dmg[0](v) + Dmg[1](v) then
				self:CastQ(v)
				self:CastW(v)
			end

			if GetCurrentHP(v) <= Dmg[0](v) + Dmg[1](v) + Dmg[2](v) and self.Spells2[3].Ready then
				self:CastQ(v)
				self:CastW(v)
				DelayAction(function() CastSpell(3) end, 0.1)
				DelayAction(function() self:CastSQ(v) end, 0.2)
			end
		else
			if GetCurrentHP(v) <= Dmg[0](v) then
				self:CastSQ(v)
			end
		end
	end
end

--[[function Elise:Orb(Boolean)
	if _G.IOW then
		IOW.attacksEnabled = Boolean
		IOW.movementEnabled = Boolean
	elseif _G.DAC_Loaded then
		DAC:AttacksEnabled(Boolean)
		DAC:movementEnabled(Boolean)
	elseif _G.AutoCarry_Loaded then
		DACR.attacksEnabled(Boolean)
		DACR.movementEnabled(Boolean)
	elseif _G.PW then
		PW.attacksEnabled = Boolean
		PW.movementEnabled = Boolean
	elseif _G.GoSWalkLoaded then
		GoSWalk:EnableAttack(Boolean)
		GoSWalk:EnableMovement(Boolean)
	end
end]]

function Elise:CastQ(Unit)
	if not Human then return end
	if ValidTarget(Unit, 626) and self.Spells[0].Ready then
		CastTargetSpell(Unit, 0)
	end
end

function Elise:CastW(Unit)
	if not Human then return end
	if ValidTarget(Unit, 950) and self.Spells[1].Ready then
		CastSkillShot(1, GetOrigin(Unit))
	end
end

function Elise:CastE(Unit)
	if not Human then return end
	local EPred = GetPrediction(Unit, self.Spells[2])
	if ValidTarget(Unit, self.Spells[2].range) and self.Spells[2].Ready and EPred and EPred.hitChance >= (ConfigMenu.Champ.HC.E:Value()/100) and not EPred:mCollision(1) then
		CastSkillShot(2, EPred.castPos)
	end
end

function Elise:CastSQ(Unit)
	if Human then return end
	if ValidTarget(Unit, 425) and self.Spells2[0].Ready then
		CastTargetSpell(Unit, 0)
	end	
end

function Elise:CastSW(Unit)
	if Human then return end
	if ValidTarget(Unit, 425) and self.Spells2[1].Ready then
		CastSpell(1)
	end	
end

function Elise:Download()
	for i = 1,16,1 do
		if FileExist(SPRITE_PATH..self.Sprite[i].FName) then self.abc = true return end
		if not DirExists(SPRITE_PATH.."Elise") then
			CreateDir(SPRITE_PATH.."Elise")
		end

		if DirExists(SPRITE_PATH.."Elise") then
			DownloadFileAsync("https://raw.githubusercontent.com/Hanndel/GoS/master/Sprites/Elise/"..self.Sprite[i].Web, SPRITE_PATH .. "Elise\\"..self.Sprite[i].Web, function() PrintChat("Downloading "..self.Sprite[i].Web.." F6x2!") return end)
		end
	end
end

class "Irelia"

function Irelia:__init()
	Dmg =
	{
		[0] = function(Unit) return CalcDamage(myHero, Unit, -10+30*GetCastLevel(myHero, 0) + (GetBaseDamage(myHero) + GetBonusDmg(myHero))) end,
		[1] = function(Unit) return 15*GetCastLevel(myHero, 1) end,
		[2] = function(Unit) return CalcDamage(myHero, Unit, 0, 40+40*GetCastLevel(myHero, 2)*GetBonusAP(myHero)/2) end,
		[3] = function(Unit) return CalcDamage(myHero, Unit, 40+40*GetCastLevel(myHero, 3) + GetBonusDmg(myHero)*0.6 + GetBonusAP(myHero)/2) end,
	}

	self.Spells =
	{
		[0] = {range = 650},
		[1] = {duration = 6},
		[2] = {range = 425},
		[3] = {range = 1000, speed = 1700, delay = 0.250, width = 25},
	}

	self.WBuff = false
	self.WEndBuff = 0
	self.WTimer = nil
	self.Trinity = false
	self.aaTimer = 0
	self.aaTimeReady = 0
	self.windUP = 0
	self.baseAS = GetBaseAttackSpeed(myHero)
	self.Target = nil

	ConfigMenu.Champ:Menu("C", "Combo")
		ConfigMenu.Champ.C:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.C:Boolean("QG", "Gapcloser?", true)
		ConfigMenu.Champ.C:Slider("DG", "Distance after GP", 200, 300, 650)
		ConfigMenu.Champ.C:Boolean("W", "Use W", true)
		ConfigMenu.Champ.C:DropDown("E", "E Mode", 1, {"Always", "Only stun", "Off"})
		ConfigMenu.Champ.C:Boolean("R", "Use R", true)
		ConfigMenu.Champ.C:Slider("HPR", "Hp to spam R", 30, 1, 100)

	ConfigMenu.Champ:Menu("H", "Harass")
		ConfigMenu.Champ.H:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.H:Boolean("QG", "Gapcloser?", true)
		ConfigMenu.Champ.H:Boolean("W", "Use W", true)
		ConfigMenu.Champ.H:DropDown("E", "E Mode", 1, {"Always", "Only stun", "Off"})
	--	ConfigMenu.Champ.H:Slider("M", "Mana for Harass", 50, 1, 100)

	ConfigMenu.Champ:Menu("HC", "Hitchance")
		ConfigMenu.Champ.HC:Slider("R", "R HitChance", 20, 1, 100)

	ConfigMenu.Champ:Menu("F", "Farm")
		ConfigMenu.Champ.F:SubMenu("LH", "LastHit")
			ConfigMenu.Champ.F.LH:Boolean("Q", "Use Q", true)
		--	ConfigMenu.Champ.F.LH:Slider("M", "Mana for LH", 50, 1, 100)
		ConfigMenu.Champ.F:SubMenu("LC", "LaneClear")
			ConfigMenu.Champ.F.LC:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.F.LC:Boolean("W", "Use W", true)
			ConfigMenu.Champ.F.LC:Boolean("E", "Use E", true)
			ConfigMenu.Champ.F.LC:Boolean("R", "Use R", true)
		--	ConfigMenu.Champ.F.LC:Slider("M", "Mana for LC", 50, 1, 100)
		ConfigMenu.Champ.F:SubMenu("JC", "JunglerClear")
			ConfigMenu.Champ.F.JC:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.F.JC:Boolean("W", "Use W", true)
			ConfigMenu.Champ.F.JC:Boolean("E", "Use E", true)
		--	ConfigMenu.Champ.F.JC:Slider("M", "Mana for JC", 50, 1, 100)

	ConfigMenu.Champ:Menu("KS", "KillSteal")
		ConfigMenu.Champ.KS:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.KS:Boolean("W", "Use W", true)
		ConfigMenu.Champ.KS:Boolean("R", "Use R", true)

	ConfigMenu.Champ:Menu("I", "Items")
		ConfigMenu.Champ.I:Boolean("TH", "Use Tiamat/Hydra", true)
		ConfigMenu.Champ.I:Boolean("TI", "Use Titanic Hydra", true)
		ConfigMenu.Champ.I:Boolean("BG", "Use Bilgewhater", true)
		ConfigMenu.Champ.I:Boolean("BO", "Use Botkr", true)
		ConfigMenu.Champ.I:Boolean("YO", "Use Youmu", true)
		ConfigMenu.Champ.I:Boolean("HG", "Use Hextech Gunblade", true)

	ConfigMenu.Champ:Menu("D", "Draws")
		ConfigMenu.Champ.D:Boolean("Q", "Draw Q Range", true)
		ConfigMenu.Champ.D:Boolean("E", "Draw E Range", true)
		ConfigMenu.Champ.D:Boolean("R", "Draw R Range", true)
		ConfigMenu.Champ.D:Slider("DH", "Quality", 155, 1, 475)


	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
		ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
		ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
		ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)
		ConfigMenu.Champ.Orb:KeyBinding("LH", "LastHit", string.byte("X"), false)
		ConfigMenu.Champ.Orb:KeyBinding("Q", "LastHit Q", string.byte("T"), false)
		--ConfigMenu.Champ.Orb:KeyBinding("F", "Flee", string.byte("T"), false)

	OnTick(function(myHero) self:Tick(myHero) end)
	OnDraw(function(myHero) self:Draw(myHero) end)
	OnProcessSpellComplete(function(Object, spellProc) self:OnProcComplete(Object, spellProc) end)
	OnProcessSpell(function(Object, spellProc) self:OnProc(Object, spellProc) end)
	OnUpdateBuff(function(Object, buff) self:OnUpdate(Object, buff) end)
	OnRemoveBuff(function(Object, buff) self:OnRemove(Object, buff) end)

end

function Irelia:Tick(myHero)
	self.WTimer = self.WEndBuff - GetGameTimer()
	self.Target = DickSelector:Targets(1000)

	if self.aaTimeReady ~= nil then
		self.aaTimer = self.aaTimeReady - GetGameTimer()
		if self.aaTimer <= 0 then
			self.aaTimer = 0
		end
	end

	if self.Target ~= nil then
		if ConfigMenu.Champ.Orb.C:Value() then
			self:Combo(self.Target)
		end

		if ConfigMenu.Champ.Orb.H:Value() then
			self:Harass(self.Target)
		end
	end

	if ConfigMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
	end

	if ConfigMenu.Champ.Orb.LH:Value() then
		self:LastHit()
	end
end

function Irelia:Draw(myHero)
	if Ready(0) and ConfigMenu.Champ.D.Q:Value() then
		DrawCircle(GetOrigin(myHero), self.Spells[0].range, 1, ConfigMenu.Champ.D.DH:Value(), GoS.Red)
	end

	if Ready(2) and ConfigMenu.Champ.D.E:Value() then
		DrawCircle(GetOrigin(myHero), self.Spells[2].range, 1, ConfigMenu.Champ.D.DH:Value(), GoS.Blue)
	end

	if Ready(3) and ConfigMenu.Champ.D.R:Value() then
		DrawCircle(GetOrigin(myHero), self.Spells[3].range, 1, ConfigMenu.Champ.D.DH:Value(), GoS.Green)
	end
end

function Irelia:Gapcloser(Unit)
	if ValidTarget(Unit, 1000) then
		for k, v in ipairs(minionManager.objects) do
			if ValidTarget(v, self.Spells[0].range) and GetDistance(v, Unit) <= ConfigMenu.Champ.C.DG:Value() then
				if ConfigMenu.Champ.Orb.C:Value() and ConfigMenu.Champ.C.QG:Value() then
					if GetCurrentHP(v) < Dmg[0](v) and Ready(0) then
						CastTargetSpell(v, 0)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and Ready(0) and Ready(1) then
						CastSpell(1)
						DelayAction(function() CastTargetSpell(v, 0) end, 0.1)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and Ready(0) and self.WBuff then
						CastTargetSpell(v, 0)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[3](v) and Ready(0) and Ready(3) then
						CastSkillShot(3, GetOrigin(v))
						DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[3](v) + Dmg[1] and Ready(0) and Ready(3) and Ready(1) then
						CastSpell(1)
						CastSkillShot(3, GetOrigin(v))
						DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[3](v) + Dmg[1] and Ready(0) and Ready(3) and self.Wbuff then
						CastSkillShot(3, GetOrigin(v))
						DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
					end
				end

				if ConfigMenu.Champ.Orb.H:Value() and ConfigMenu.Champ.H.QG:Value() then
					if GetCurrentHP(v) < Dmg[0](v) and Ready(0) then
						CastTargetSpell(v, 0)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and Ready(0) and Ready(1) then
						CastSpell(1)
						DelayAction(function() CastTargetSpell(v, 0) end, 0.1)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and Ready(0) and self.WBuff then
						CastTargetSpell(v, 0)
					end

					if GetCurrentHP(v) < Dmg[0](v) + Dmg[3](v) and Ready(0) and Ready(3) then
						CastSkillShot(3, GetOrigin(v))
						DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
					end
				end
			else 
				return false
			end
		end
	end
end

function Irelia:Combo(Unit)
	self:Gapcloser(Unit)
	if not self:Gapcloser(Unit) and ValidTarget(Unit, self.Spells[0].range) and Ready(0) and ConfigMenu.Champ.C.Q:Value() then
		CastTargetSpell(Unit, 0)
	end

	if Ready(1) and ValidTarget(Unit, self.Spells[2].range) and ConfigMenu.Champ.C.W:Value() then
		CastSpell(1)
	end

	if Ready(3) and ValidTarget(Unit, self.Spells[3].range) and (GetPercentHP(myHero) > ConfigMenu.Champ.C.HPR:Value() and not self.Trinity or GetPercentHP(myHero) < ConfigMenu.Champ.C.HPR:Value()) and ConfigMenu.Champ.C.R:Value() then
		local RPred = GetPrediction(Unit, self.Spells[3])
		if RPred and RPred.hitChance >= ConfigMenu.Champ.HC.R:Value()/100 then
			CastSkillShot(3, RPred.castPos)
		end
	end
end

function Irelia:Harass(Unit)
	self:Gapcloser(Unit)
	if not self:Gapclose(Unit) and ValidTarget(Unit, self.Spells[0].range) and Ready(0) and ConfigMenu.Champ.H.Q:Value() then
		CastTargetSpell(Unit, 0)
	end

	if Ready(1) and ValidTarget(Unit, self.Spells[2].range) and ConfigMenu.Champ.H.W:Value()then
		CastSpell(1)
	end
end

function Irelia:Items(Unit)
	if ValidTarget(Unit, 500) and GetItemSlot(myHero, 3146) > 0 and Ready(GetItemSlot(myHero, 3146)) then
		CastTargetSpell(GetItemSlot(myHero, 3146), Unit)
	end

	if ValidTarget(Unit, 500) and GetItemSlot(myHero, 3153) > 0 and Ready(GetItemSlot(myHero, 3153)) and GetPercentHP(myHero) < 20 then
		CastTargetSpell(GetItemSlot(myHero, 3153), Unit)
	end

	if ValidTarget(Unit, 500) and GetItemSlot(myHero, 3144) > 0 and Ready(GetItemSlot(myHero, 3144)) then
		CastTargetSpell(GetItemSlot(myHero, 3144), Unit)
	end

	if GetItemSlot(myHero, 3142) > 0 and Ready(GetItemSlot(myHero, 3142)) and GetDistance(Unit)/GetMoveSpeed(myHero)+GetMoveSpeed(myHero)*0.2 < 6 then
		CastSpell(GetItemSlot(myHero, 3142))
	end
end
--><
function Irelia:LastHit()
	for k, v in ipairs(minionManager.objects) do
		if ValidTarget(v, 650) and Ready(0) then
			if GetDistance(v + GetHitBox(v)) > GetRange(myHero) + GetHitBox(myHero) then
				if GetCurrentHP(v) - GetHealthPrediction(v, (GetDistance(v + GetHitBox(v)) - GetRange(myHero) + GetHitBox(myHero))/GetMoveSpeed(myHero) + self.aaTimer) < 1 then
					CastTargetSpell(v, 0)
				end
			else
				if GetCurrentHP(v) - GetHealthPrediction(v, self.aaTimer) < 1 then
					CastTargetSpell(v, 0)
				end
			end
		end
	end
end

function Irelia:LaneClear()
	for k, v in ipairs(minionManager.objects) do
		if GetTeam(v) == 200 then
			if ValidTarget(v, 425) and Ready(1) and ConfigMenu.Champ.F.LC.W:Value() then
				CastSpell(1)
			end

			if ValidTarget(v, 650) and Ready(0) and GetCurrentHP(v) < Dmg[0](v) and ConfigMenu.Champ.F.LC.Q:Value() then
				CastTargetSpell(v, 0)
			end

			if ValidTarget(v, 650) and Ready(0) and self.WBuff and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and ConfigMenu.Champ.F.LC.Q:Value() then
				CastTargetSpell(v, 0)
			end

			if ValidTarget(v, 1000) and Ready(3) and ConfigMenu.Champ.F.LC.R:Value() then
				CastSkillShot(3, GetOrigin(v))
			end

		elseif GetTeam(v) == 300 then
			if ValidTarget(v, 425) and Ready(1) and ConfigMenu.Champ.F.JC.W:Value() then
				CastSpell(1)
			end

			if ValidTarget(v, 650) and Ready(0) and GetCurrentHP(v) < Dmg[0](v) and ConfigMenu.Champ.F.JC.Q:Value() then
				CastTargetSpell(v, 0)
			end

			if ValidTarget(v, 650) and Ready(0) and self.WBuff and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and ConfigMenu.Champ.F.JC.Q:Value() then
				CastTargetSpell(v, 0)
			end		
		end
	end
end

function Irelia:Ks()
	for k, v in ipairs(GetEnemyHeroes()) do
		if ValidTarget(v, 650) and Ready(0) and GetCurrentHP(v) < Dmg[0](v) and ConfigMenu.Champ.KS.Q:Value() then
			CastTargetSpell(v, 0)
		end

		if ValidTarget(v, 650) and Ready(0) and Ready(1) and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and ConfigMenu.Champ.KS.Q:Value() and ConfigMenu.Champ.KS.W:Value() then
			CastSpell(1)
			DelayAction(function() CastTargetSpell(v, 0) end, 0.1)
		end

		if ValidTarget(v, 650) and Ready(0) and self.WBuff and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] and ConfigMenu.Champ.KS.Q:Value() then
			CastTargetSpell(v, 0)
		end

		if ValidTarget(v, 650) and Ready(0) and Ready(3) and GetCurrentHP(v) < Dmg[0](v) + Dmg[3](v) and ConfigMenu.Champ.KS.Q:Value() and ConfigMenu.Champ.KS.R:Value() then
			CastSkillShot(3, GetOrigin(v))
			DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
		end

		if ValidTarget(v, 650) and Ready(0) and Ready(1) and Ready(3) and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] + Dmg[3](v) and ConfigMenu.Champ.KS.Q:Value() and ConfigMenu.Champ.KS.W:Value() and ConfigMenu.Champ.KS.R:Value() then
			CastSpell(1)
			CastSkillShot(3, GetOrigin(v))
			DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
		end

		if ValidTarget(v, 650) and Ready(0) and self.WBuff and Ready(3) and GetCurrentHP(v) < Dmg[0](v) + Dmg[1] + Dmg[3](v) and ConfigMenu.Champ.KS.Q:Value() and ConfigMenu.Champ.KS.R:Value() then
			CastSkillShot(3, GetOrigin(v))
			DelayAction(function() CastTargetSpell(v, 0) end, GetDistance(v)/self.Spells[3].speed)
		end
	end
end

function Irelia:OnProcComplete(Object, spellProc)
	if Object == myHero then
		if spellProc.name:lower():find("attack") then
			ASDelay = 1/(self.baseAS*GetAttackSpeed(myHero))
			self.windUP = spellProc.windUpTime
			self.aaTimeReady = ASDelay + GetGameTimer() - self.windUP/1000
			if ConfigMenu.Champ.Orb.C:Value() and self.Target ~= nil then
				if Ready(2) and ValidTarget(self.Target, 425) and ConfigMenu.Champ.C.E:Value() == 1 then
					CastTargetSpell(self.Target, 2)
				elseif Ready(2) and ValidTarget(self.Target, 425) and ConfigMenu.Champ.C.E:Value() == 2 and GetPercentHP(myHero) < GetPercentHP(self.Target) then
					CastTargetSpell(self.Target, 2)
				end
			end
		
			if ConfigMenu.Champ.Orb.H:Value() and self.Target ~= nil then
				if Ready(2) and ValidTarget(self.Target, 425) and ConfigMenu.Champ.H.E:Value() == 1 then
					CastTargetSpell(self.Target, 2)
				elseif Ready(2) and ValidTarget(self.Target, 425) and ConfigMenu.Champ.H.E:Value() == 2 and GetPercentHP(myHero) < GetPercentHP(self.Target) then
					CastTargetSpell(self.Target, 2)
				end
			end

			if ConfigMenu.Champ.Orb.LC:Value() then
				for k, v in ipairs(minionManager.objects) do
					if GetTeam(v) == 200 then
						if Ready(2) and ValidTarget(v, 425) and ConfigMenu.Champ.F.LC.E:Value() then
							CastTargetSpell(v, 2)
						end
					end

					if GetTeam(v) == 300 then
						if Ready(2) and ValidTarget(v, 425) and ConfigMenu.Champ.F.JC.E:Value() then
							CastTargetSpell(v, 2)
						end
					end
				end					
			end

			if not Ready(2) and GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero, 3748)) and ConfigMenu.Champ.I.TI:Value() then
				CastSpell(GetItemSlot(myHero, 3748))
			end
		end
	end
end

function Irelia:OnProc(Object, spellProc)
	if Object == myHero then
		if spellProc.name:lower():find("attack") then
			if ConfigMenu.Champ.Orb.C:Value() then
				if spellProc.name == "IreliaEquilibriumStrike" and Tiamat > 0 and Ready(Tiamat) and ConfigMenu.Champ.I.TH:Value() then
					DelayAction(function() CastSpell(Tiamat) end, 0.1)
				elseif spellProc.name == "IreliaEquilibriumStrike" and Hydra > 0 and Ready(Hydra) and ConfigMenu.Champ.I.TH:Value() then
					DelayAction(function() CastSpell(Hydra) end, 0.1)
				end
			end

			if ConfigMenu.Champ.Orb.LC:Value() then
				if spellProc.name == "IreliaEquilibriumStrike" and GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero, 3077)) and ConfigMenu.Champ.I.TH:Value() then
					DelayAction(function() CastSpell(GetItemSlot(myHero, 3077)) end, 0.1)
				elseif spellProc.name == "IreliaEquilibriumStrike" and GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero, 3074)) and ConfigMenu.Champ.I.TH:Value() then
					DelayAction(function() CastSpell(GetItemSlot(myHero, 3074)) end, 0.1)
				end
			end
		end
	end
end

function Irelia:OnUpdate(Object, buff)
	if Object == myHero then
		if buff.Name == "ireliahitenstylecharged" then
			WEndBuff = buff.ExpireTime
			WBuff = true
		end

		if buff.Name == "sheen" then
			Trinity = true
		end
	end
end

function Irelia:OnRemove(Object, buff)
	if Object == myHero then
		if buff.Name == "ireliahitenstylecharged" then
			WBuff = false
		end

		if buff.Name == "sheen" then
			Trinity = false
		end
	end
end

class "Nidalee"

function Nidalee:__init()

	self.Color = ARGB(255,255,255,255)
	Human = true
	self.Recalling = false
	self.QCDmg = {[1] = 4, [2] = 20, [3] = 50, [4] = 90}
	self.QCDmgM = {[1] = 1, [2] = 1.25, [3] = 1.5, [4] = 1.75}
	self.Multi = {[1] = 2, [2] = 2.25, [3] = 2.5, [4] = 2.75}
	self.aaTimer = 0
	self.aaTimeReady = 0
	self.windUP = 0
	self.baseAS = GetBaseAttackSpeed(myHero)
	self.abc = false

	self.Sprite = 
	{
		[1] 	= 	{FName = "Nidalee\\Q_H.png", 		Sprite = nil,		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Q_H.png"},
		[2] 	= 	{FName = "Nidalee\\W_H.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "W_H.png"},
		[3] 	= 	{FName = "Nidalee\\E_H.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2		else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "E_H.png"},
		[4] 	= 	{FName = "Nidalee\\R_H.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "R_H.png"},
		[5] 	= 	{FName = "Nidalee\\Q_H_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Q_H_CD.png"},
		[6] 	= 	{FName = "Nidalee\\W_H_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "W_H_CD.png"},
		[7] 	= 	{FName = "Nidalee\\E_H_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2	 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "E_H_CD.png"},
		[8] 	= 	{FName = "Nidalee\\R_H_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "R_H_CD.png"},
		[9] 	= 	{FName = "Nidalee\\Q_C.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Q_C.png"},
		[10] 	= 	{FName = "Nidalee\\W_C.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75 	else return GetResolution().x/2-127	end end,		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "W_C.png"},
		[11] 	= 	{FName = "Nidalee\\E_C.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2	 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "E_C.png"},
		[12] 	= 	{FName = "Nidalee\\R_C.png", 		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "R_C.png"},
		[13] 	= 	{FName = "Nidalee\\Q_C_CD.png",		Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-150 else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+50  end end, Web = "Q_C_CD.png"},
		[14] 	= 	{FName = "Nidalee\\W_C_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2-75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+125 end end, Web = "W_C_CD.png"},
		[15] 	= 	{FName = "Nidalee\\E_C_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+200 end end, Web = "E_C_CD.png"},
		[16] 	= 	{FName = "Nidalee\\R_C_CD.png", 	Sprite = nil, 		PosX = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().x/2+75 	else return GetResolution().x/2-127	end end, 		PosY = function(Unit) if ConfigMenu.Champ.D.S.H:Value() then return GetResolution().y/2+250 else return GetResolution().y/2+275 end end, Web = "R_C_CD.png"},
	}

	self.Dick = 
	{

		[0] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[1].Sprite ,self.Sprite[1].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[1].Sprite ,self.Sprite[1].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[5].Sprite ,self.Sprite[5].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[5].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
												DrawText(string.format("%.2f", self.Spells[0].Timer), 25, self.Sprite[1].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[5].Sprite ,self.Sprite[5].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[5].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells[0].Timer), 25, self.Sprite[1].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[1].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))	
											end
										end end,
		},

		[1] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[2].Sprite ,self.Sprite[2].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[2].Sprite ,self.Sprite[2].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit)	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[6].Sprite ,self.Sprite[6].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[6].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[1].Timer), 25, self.Sprite[2].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[6].Sprite ,self.Sprite[6].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[6].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[1].Timer), 25, self.Sprite[2].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[2].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[2] = 
		{
			[true] 	= function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[3].Sprite ,self.Sprite[3].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[3].Sprite ,self.Sprite[3].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[7].Sprite ,self.Sprite[7].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[7].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[2].Timer), 25, self.Sprite[3].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[7].Sprite ,self.Sprite[7].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[7].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[2].Timer), 25, self.Sprite[3].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[3].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[3] = 
		{
			[true] 	= function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[4].Sprite ,self.Sprite[4].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[4].Sprite ,self.Sprite[4].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[8].Sprite ,self.Sprite[8].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[8].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[3].Timer), 25, self.Sprite[4].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[8].Sprite ,self.Sprite[8].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[8].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 		
												DrawText(string.format("%.2f", self.Spells[3].Timer), 25, self.Sprite[4].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[4].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,

		},
	}

	self.Dick2 =
	{

		[0] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[9].Sprite ,self.Sprite[9].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[9].Sprite ,self.Sprite[9].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[13].Sprite ,self.Sprite[13].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[13].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[0].Timer), 25, self.Sprite[9].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[13].Sprite ,self.Sprite[13].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[13].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[0].Timer), 25, self.Sprite[9].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[9].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[1] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[10].Sprite ,self.Sprite[10].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[10].Sprite ,self.Sprite[10].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)												
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[14].Sprite ,self.Sprite[14].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[14].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells2[1].Timer), 25, self.Sprite[10].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[14].Sprite ,self.Sprite[14].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[14].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 
												DrawText(string.format("%.2f", self.Spells2[1].Timer), 25, self.Sprite[10].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[10].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},						
		[2] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[11].Sprite ,self.Sprite[11].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[11].Sprite ,self.Sprite[11].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)												
											end
										end end,

			[false] = function(Unit) 	if self.abc then 
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[15].Sprite ,self.Sprite[15].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[15].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[2].Timer), 25, self.Sprite[11].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[15].Sprite ,self.Sprite[15].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[15].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[2].Timer), 25, self.Sprite[11].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[11].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
		[3] = 
		{
			[true] 	= function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[12].Sprite ,self.Sprite[12].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)
											else
												DrawSprite(self.Sprite[12].Sprite ,self.Sprite[12].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color)		
											end
										end end,

			[false] = function(Unit) 	if self.abc then
											if ConfigMenu.Champ.D.S.H:Value() then
												DrawSprite(self.Sprite[16].Sprite ,self.Sprite[16].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[16].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[3].Timer), 25, self.Sprite[12].PosX(Unit)+12.5 + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit)+20 + ConfigMenu.Champ.D.S.Y.QY:Value() + ConfigMenu.Champ.D.S.T:Value())
											else
												DrawSprite(self.Sprite[16].Sprite ,self.Sprite[16].PosX(Unit) + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[16].PosY(Unit) + ConfigMenu.Champ.D.S.Y.QY:Value(), 0, 0, 0, 0, self.Color) 	
												DrawText(string.format("%.2f", self.Spells2[3].Timer), 25, self.Sprite[12].PosX(Unit)+12.5 - ConfigMenu.Champ.D.S.T:Value() + ConfigMenu.Champ.D.S.X.QX:Value(), self.Sprite[12].PosY(Unit)+15 + (ConfigMenu.Champ.D.S.Y.QY:Value()*1.25))
											end
										end end,
		},
	}

	self.Spells =
	{

		[0] = 	{CD = function(myHero) return 	6 								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "JavelinToss", 		Timer = 0, Ready = false, speed = 1300, width = 60, range = 1500, delay = 0.25},
		[1] = 	{CD = function(myHero) return 	14-1*GetCastLevel(myHero, 1) 	+ (14-1*GetCastLevel(myHero, 1))*GetCDR(myHero) 	end, CDT = 0, Name = "Bushwhack", 			Timer = 0, Ready = false, speed = math.huge, width = 90, range = 900, delay = 0.5},
		[2] = 	{CD = function(myHero) return 	12 								+ 12*GetCDR(myHero) 								end, CDT = 0, Name = "PrimalSurge", 		Timer = 0, Ready = false, range = 600},
		[3] = 	{CD = function(myHero) return 	3 								+ 3*GetCDR(myHero) 									end, CDT = 0, Name = "AspectOfTheCougar", 	Timer = 0, Ready = false},
	}

	self.Spells2 =
	{
		[0] = 	{CD = function(myHero) return 	6								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "Takedown", 			Timer = 0, Ready = false, range = 200},
		[1] = 	{CD = function(myHero) return 	6								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "Pounce", 				Timer = 0, Ready = false},
		[2] = 	{CD = function(myHero) return 	6								+ 6*GetCDR(myHero) 									end, CDT = 0, Name = "Swipe", 				Timer = 0, Ready = false},
		[3] = 	{CD = function(myHero) return 	3 								+ 3*GetCDR(myHero) 									end, CDT = 0, Name = "AspectOfTheCougar", 	Timer = 0, Ready = false},
	}
--><
	self.HDmg =
	{
		[0] = function(Unit) if self:QHDmg(myHero) + GetDistance(Unit)/100*self:QHDmg(myHero)*0.258 > self:QHDmg(myHero)*3 then return CalcDamage(myHero,Unit, 0, self:QHDmg(myHero)*3) else return CalcDamage(myHero,Unit, 0, self:QHDmg(myHero) + GetDistance(Unit)/100*self:QHDmg(myHero)*0.258) end end,	--HQ 
		[1] = function(Unit) return CalcDamage(myHero,Unit, 0, 40*GetCastLevel(myHero, 1)+GetBonusAP(myHero)*0.2) end,			--HW
	}

	self.CDmg =
	{
		[0] = function(Unit)
									if self:Hunteds(Unit) then
										if GetPercentHP(Unit) ~= 100 then
											if (self:Maths(myHero) + self:Maths(myHero)*(self.QCDmgM[GetCastLevel(myHero, 3)] * ((GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit))))*1.33 > (self:Maths(myHero)*self.Multi[GetCastLevel(myHero, 3)])*1.33 then
												return CalcDamage(myHero, Unit, 0, (self:Maths(myHero)*self.Multi[GetCastLevel(myHero, 3)])*1.33)
											else
												return CalcDamage(myHero, Unit, 0, (self:Maths(myHero) + self:Maths(myHero)*(self.QCDmgM[GetCastLevel(myHero, 3)] * ((GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit))))*1.33)
											end
										else 
											return CalcDamage(myHero, Unit, 0, (self:Maths(myHero)*1.33))
										end
									else
										if GetPercentHP(Unit) ~= 100 then
											if self:Maths(myHero) + self:Maths(myHero)*(self.QCDmgM[GetCastLevel(myHero, 3)] * (GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit)) > self:Maths(myHero)*self.Multi[GetCastLevel(myHero, 3)] then
												return CalcDamage(myHero, Unit, 0, self:Maths(myHero)*self.Multi[GetCastLevel(myHero, 3)])
											else
												return CalcDamage(myHero, Unit, 0, self:Maths(myHero) + self:Maths(myHero)*(self.QCDmgM[GetCastLevel(myHero, 3)] * ((GetMaxHP(Unit) - GetCurrentHP(Unit)) / GetMaxHP(Unit)))*1.33)
											end
										else 
											return CalcDamage(myHero, Unit, 0, self:Maths(myHero))
										end
									end
									end,


		[1] = function(Unit) return CalcDamage(myHero,Unit, 0, 10+50*GetCastLevel(myHero, 3) + GetBonusAP(myHero)*0.3)		end, 																																															--CW
		[2] = function(Unit) return CalcDamage(myHero,Unit, 0, 10+60*GetCastLevel(myHero, 3) + GetBonusAP(myHero)*0.45) 	end,
	}

	self.Stuff =
	{
		["Combo"] =
		{
			[1] =
			{
				[true] = 	function()			
								if ConfigMenu.Champ.C.H.Q:Value() and self.Target then
									self:CastQH(self.Target)
								end
								if ConfigMenu.Champ.C.H.W:Value() and self.Target then
									self:CastWH(self.Target)
								end
							end,

				[false] = 	function()
								if not self.Spells2[3].Ready then
									if ConfigMenu.Champ.C.C.Q:Value() and self.Target then
										self:CastQC(self.Target)
									end

									if ConfigMenu.Champ.C.C.W:Value() and self.Target then
										self:CastWC(self.Target)
									end

									if ConfigMenu.Champ.C.C.E:Value() and self.Target then
										self:CastEC(self.Target)
									end
								else
									self:CastRC(self.Target)
								end
							end,
			},

			[2] =
			{
				[true] = 	function()
								if self.Spells[3].Ready and self.Target then
									self:CastRH(self.Target)
								else
									if ConfigMenu.Champ.C.H.Q:Value() and self.Target then
										self:CastQH(self.Target)
									end

									if ConfigMenu.Champ.C.H.W:Value() and self.Target then
										self:CastWH(self.Target)
									end
								end
							end,

				[false] = 	function()
								if ConfigMenu.Champ.C.C.Q:Value() and self.Target then
									self:CastQC(self.Target)
								end
								if ConfigMenu.Champ.C.C.W:Value() and self.Target then
									self:CastWC(self.Target)
								end

								if ConfigMenu.Champ.C.C.E:Value() and self.Target then
									self:CastEC(self.Target)
								end
							end,

			},

			[3] =
			{
				[true] = 	function()
								if ConfigMenu.Champ.C.H.Q:Value() and self.Target then
									self:CastQH(self.Target)
								end

								if ConfigMenu.Champ.C.H.W:Value() and self.Target then
									self:CastWH(self.Target)
								end

								if not self.Spells[0].Ready and self.Spells[3].Ready and self.Target then
									self:CastRH(self.Target)
								end
							end,

				[false] = 	function()
								if ConfigMenu.Champ.C.C.Q:Value() and self.Target then
									self:CastQC(self.Target)
								end

								if ConfigMenu.Champ.C.C.W:Value() and self.Target then
									self:CastWC(self.Target)
								end

								if ConfigMenu.Champ.C.C.E:Value() and self.Target then
									self:CastEC(self.Target)
								end

								if self.Spells2[3].Ready and self.Spells[0].Ready and self.Target then
									self:CastRC(self.Target)
								end
							end,	
			},		
		},

		["Harass"] =
		{
			[true] = 	function()
							if ConfigMenu.Champ.H.Q:Value() and self.Spells[0].Ready and self.Target then
								self:CastQH(self.Target)
							end
						end,

			[false] = 	function()
							if ConfigMenu.Champ.H.R:Value() and self.Spells2[3].Ready and self.Target then
								self:CastRC(self.Target)
							end
						end
		},
	}


	self.DebuffTable = {[5] = true, [8] = true, [11] = true, [21] = true, [22] = true, [24] = true, [28] = true, [29] = true, [30] = true}
	self.Fucked = {}
	self.Hunted = {}
	self.Target = nil

	ConfigMenu.Champ:Menu("C", "Combo")
		ConfigMenu.Champ.C:SubMenu("H", "Human Combo")
			ConfigMenu.Champ.C.H:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.C.H:DropDown("W", "Use W (Human) when", 1, {"Enemy on cc", "Always"})
		ConfigMenu.Champ.C:SubMenu("C", "Cat Combo")
			ConfigMenu.Champ.C.C:Boolean("Q", "Use Q", true)
			ConfigMenu.Champ.C.C:Boolean("W", "Use W", true)
			ConfigMenu.Champ.C.C:Boolean("WT", "Go under tower?", false)
			ConfigMenu.Champ.C.C:Boolean("E", "Use E", true)
		ConfigMenu.Champ.C:DropDown("F", "Choose ur form", 3, {"Human", "Cat", "Both"})

	ConfigMenu.Champ:Menu("H", "Harass")
		ConfigMenu.Champ.H:Boolean("Q", "Use Human Q", true)
		ConfigMenu.Champ.H:Boolean("R", "Switch to human?", true)

	ConfigMenu.Champ:Menu("F", "Farm")
		ConfigMenu.Champ.F:SubMenu("LH", "LastHit")
			ConfigMenu.Champ.F.LH:SubMenu("H", "Human LT")
				ConfigMenu.Champ.F.LH.H:Boolean("Q", "Use Human Q", true)
				ConfigMenu.Champ.F.LH.H:Slider("Mn", "Mana for LastHit", 20, 1, 100)
			ConfigMenu.Champ.F.LH:SubMenu("C", "Cat LT")
				ConfigMenu.Champ.F.LH.C:Boolean("Q", "Use Cat Q", true)
			ConfigMenu.Champ.F.LH:DropDown("F", "Choose ur form", 3, {"Human", "Cat", "Both"})

		ConfigMenu.Champ.F:SubMenu("LC", "LaneClear")
			ConfigMenu.Champ.F.LC:SubMenu("H", "Human Mode")
				ConfigMenu.Champ.F.LC.H:Boolean("Q", "Use Q", true)
				ConfigMenu.Champ.F.LC.H:Boolean("W", "Use W", true)
			ConfigMenu.Champ.F.LC:SubMenu("C", "Cat Mode")
				ConfigMenu.Champ.F.LC.C:Boolean("Q", "Use Q", true)
				ConfigMenu.Champ.F.LC.C:Boolean("W", "Use W", true)
				ConfigMenu.Champ.F.LC.C:Boolean("E", "Use E", true)
			--ConfigMenu.Champ.F.LC:Slider("MLC", "Minimun mana to JunglerClear", 20, 1, 100)
		ConfigMenu.Champ.F.LC:DropDown("F", "Choose ur form", 3, {"Human", "Cat", "Both"})

		ConfigMenu.Champ.F:SubMenu("JC", "JunglerClear")
			ConfigMenu.Champ.F.JC:SubMenu("H", "Human Mode")
				ConfigMenu.Champ.F.JC.H:Boolean("Q", "Use Q", true)
				ConfigMenu.Champ.F.JC.H:Boolean("W", "Use W", true)						
			ConfigMenu.Champ.F.JC:SubMenu("C", "Cat Mode")
				ConfigMenu.Champ.F.JC.C:Boolean("Q", "Use Q", true)
				ConfigMenu.Champ.F.JC.C:Boolean("W", "Use W", true)
				ConfigMenu.Champ.F.JC.C:Boolean("E", "Use E", true)
			--ConfigMenu.Champ.F.JC:Slider("MJC", "Minimun mana to JunglerClear", 20, 1, 100)


	ConfigMenu.Champ:Menu("HE", "Heals")
		ConfigMenu.Champ.HE:Boolean("R", "Force human for heal?", true)
		ConfigMenu.Champ.HE:Slider("E", "Use E under hp (Ursef)", 20, 1, 100) 
		DelayAction(function()
			for k, v in ipairs(GetAllyHeroes()) do
				ConfigMenu.Champ.HE:SubMenu("HM"..GetObjectName(v), "Heal config for "..GetObjectName(v))
					ConfigMenu.Champ.HE["HM"..GetObjectName(v)]:Boolean("HO"..GetObjectName(v), "Heal on "..GetObjectName(v).."?", true) 
					ConfigMenu.Champ.HE["HM"..GetObjectName(v)]:Boolean("FH"..GetObjectName(v), "Force heal on "..GetObjectName(v).."?", false)
					ConfigMenu.Champ.HE["HM"..GetObjectName(v)]:Slider("HV"..GetObjectName(v), "Heal on "..GetObjectName(v).." under hp", 20, 1, 100)
			end
		end, 0.001)

	ConfigMenu.Champ:Menu("S", "Run bitch")
		ConfigMenu.Champ.S:Boolean("R", "Switch to Cat?", true) 
		ConfigMenu.Champ.S:Boolean("W", "Use Cat W", true)

	ConfigMenu.Champ:Menu("D", "Draws")
		ConfigMenu.Champ.D:Boolean("F", "Draw different form CD?", true)
		ConfigMenu.Champ.D:SubMenu("HD", "Human Draws")
			ConfigMenu.Champ.D.HD:Boolean("Q", "Draw Q range", true)
			ConfigMenu.Champ.D.HD:Boolean("W", "Draw W range", true)
			ConfigMenu.Champ.D.HD:Boolean("E", "Draw E range", true)
		ConfigMenu.Champ.D:Slider("Q", "Quality", 155, 1, 255)
		ConfigMenu.Champ.D:Boolean("DD", "Draw Total Dmg?", true)
      	ConfigMenu.Champ.D:SubMenu("S", "Sprites")
      		ConfigMenu.Champ.D.S:SubMenu("X", "X Pos")
	      		ConfigMenu.Champ.D.S.X:Slider("QX", "PosX", 0, -1000, 1000)
	      	ConfigMenu.Champ.D.S:SubMenu("Y", "Y Pos")
	      		ConfigMenu.Champ.D.S.Y:Slider("QY", "PosX", 0, -1000, 1000)
	      	ConfigMenu.Champ.D.S:Boolean("H", "Horizontal?", true)
	      	ConfigMenu.Champ.D.S:Slider("T", "Move ur time", 0, -50, 50)


	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
		ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
		ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
		ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)
		ConfigMenu.Champ.Orb:KeyBinding("LH", "LastHit", string.byte("X"), false)
		ConfigMenu.Champ.Orb:KeyBinding("F", "Flee", string.byte("T"), false)
		ConfigMenu.Champ.Orb:KeyBinding("WJ", "WallJump", string.byte("G"), false)

	OnDraw(function(myHero) self:Draw(myHero) end)
	OnTick(function(myHero) self:Tick(myHero) end)
	OnProcessSpellCast(function(unit, spell) self:OnCast(unit, spell) end)
	OnProcessSpell(function(unit, spellProc) self:OnProc(unit, spellProc) end)
	OnProcessSpellComplete(function(unit, spellProc) self:OnProcComplete(unit, spellProc) end)
	OnUpdateBuff(function(unit, buff) self:OnUpdate(unit, buff) end)
	OnRemoveBuff(function(unit, buff) self:OnRemove(unit, buff) end)
	self:Download()
	self:Sprites()
end

function Nidalee:Sprites()
	for i = 1,16,1 do
		if FileExist(SPRITE_PATH..self.Sprite[i].FName) then
        	self.Sprite[i].Sprite = CreateSpriteFromFile(self.Sprite[i].FName, 1)
		end
	end
end

function Nidalee:Draw(myHero)
	if not IsDead(myHero) then
		if self.Spells[0].Ready and ConfigMenu.Champ.D.HD.Q:Value() then
			DrawCircle(GetOrigin(myHero), self.Spells[0].range, 1, ConfigMenu.Champ.D.Q:Value(), GoS.Pink)
		end

		if self.Spells[1].Ready and ConfigMenu.Champ.D.HD.W:Value() then
			DrawCircle(GetOrigin(myHero), self.Spells[1].range, 1, ConfigMenu.Champ.D.Q:Value(), GoS.Green)
		end

		if self.Spells[2].Ready and ConfigMenu.Champ.D.HD.E:Value() then
			DrawCircle(GetOrigin(myHero), self.Spells[2].range, 1, ConfigMenu.Champ.D.Q:Value(), GoS.Black)
		end

		if ConfigMenu.Champ.D.DD:Value() then
			for k, v in pairs(GetEnemyHeroes()) do
				local asd = self:TotalDmg(v)
				local HpBar = GetHPBarPos(v)
				local What = (asd*100)/GetMaxHP(v)
				local hp = (GetCurrentHP(v)*100/GetMaxHP(v))
				if IsVisible(v) and ValidTarget(v, 2000) then
					if GetCurrentHP(v) > asd then
						FillRect(HpBar.x+4+hp-What*1.03,HpBar.y,What*1.03,5, GoS.Red)
					else
						FillRect(HpBar.x+1,HpBar.y,hp*1.03,5, GoS.Red)
					end
				end
			end
		end
		if FileExist(SPRITE_PATH..self.Sprite[16].FName) then
			if ConfigMenu.Champ.D.F:Value() then
				for k = 0, 3, 1 do
					if Human then
						self.Dick2[k][self.Spells2[k].Ready](Unit)
					else
						self.Dick[k][self.Spells[k].Ready](Unit)
					end
				end
			end
		end
	end
end

function Nidalee:Tick(myHero)
	self:Checks()
	self:CastEH()
	self:Walljump()
	self.Target = DickSelector:Targets(1500)
	
	if ConfigMenu.Champ.Orb.C:Value() then
		self.Stuff["Combo"][ConfigMenu.Champ.C.F:Value()][Human]()
	end

	if ConfigMenu.Champ.Orb.H:Value() then
		self.Stuff["Harass"][Human]()
	end

	if ConfigMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
	end

	if ConfigMenu.Champ.Orb.LH:Value() then
		self:LastHit()
	end	

	if ConfigMenu.Champ.Orb.F:Value() then
		self:Flee()
	end
end

function Nidalee:Flee()
	local LastTick = 0
	if Human then
		if self.Spells[3].Ready and ConfigMenu.Champ.S.R:Value() then
			CastSpell(3)
		end
	else
		if self.Spells2[1].Ready and ConfigMenu.Champ.S.W:Value() then
			CastSkillShot(1, GetMousePos())
		end
	end

	if LastTick + 300 < GetGameTimer() then
		MoveToXYZ(GetMousePos())
	end
end

function Nidalee:LaneClear()
	for k, Unit in ipairs(minionManager.objects) do
		if ValidTarget(Unit, 1500) then 
			if GetTeam(Unit) == 200 then
				if ConfigMenu.Champ.F.LC.F:Value() == 1 then 
					if Human then 
										if ConfigMenu.Champ.F.LC.H.Q:Value() then
											self:CastQH(Unit)
										end

										if ConfigMenu.Champ.F.LC.H.W:Value() and self.Spells[1].Ready then
											CastSkillShot(1, GetOrigin(Unit))
										end		
					else
						self:CastRC(Unit)
					end
				elseif ConfigMenu.Champ.F.LC.F:Value() == 2 then
					if Human then 
						self:CastRH(Unit)
					else
										if ConfigMenu.Champ.F.LC.C.Q:Value() then
											self:CastQC(Unit)
										end

										if ConfigMenu.Champ.F.LC.C.W:Value() then
											self:CastWC(Unit)
										end

										if ConfigMenu.Champ.F.LC.C.E:Value() then
											self:CastEC(Unit)
										end
					end
				elseif ConfigMenu.Champ.F.LC.F:Value() == 3 then
					if Human then
										if ConfigMenu.Champ.F.LC.H.Q:Value() then
											self:CastQH(Unit)
										end

										if ConfigMenu.Champ.F.LC.H.W:Value() and self.Spells[1].Ready then
											CastSkillShot(1, GetOrigin(Unit))
										end

										if not self.Spells[0].Ready and not self.Spells[1].Ready then
											self:CastRH(Unit)
										end
					else
										if ConfigMenu.Champ.F.LC.C.Q:Value() then
											self:CastQC(Unit)
										end

										if ConfigMenu.Champ.F.LC.C.W:Value() then
											self:CastWC(Unit)
										end

										if ConfigMenu.Champ.F.LC.C.E:Value() then
											self:CastEC(Unit)
										end

										if not self.Spells2[0].Ready and not self.Spells2[1].Ready and not self.Spells2[2].Ready and self.Spells2[3].Ready then
											self:CastRC(Unit)
										end
					end
				end
			elseif GetTeam(Unit) == 300 then
				if Human then
					if ConfigMenu.Champ.F.JC.H.Q:Value() then
						self:CastQH(Unit)
					end

					if ConfigMenu.Champ.F.JC.H.W:Value() and self.Spells[1].Ready then
						CastSkillShot(1, GetOrigin(Unit))
					end

					if not self.Spells[0].Ready and self.Spells[3].Ready then
						self:CastRH(Unit)
					end
				else
					if ConfigMenu.Champ.F.JC.C.W:Value() then
						self:CastWC(Unit)
					end

					if ConfigMenu.Champ.F.JC.C.E:Value() then
						self:CastEC(Unit)
					end

					if self.Spells[0].Ready and self.Spells2[3].Ready then
						self:CastRC(Unit)
					end
				end
			end
		end
	end
end

function Nidalee:LastHit()
	for k, Unit in ipairs(minionManager.objects) do
		if GetTeam(Unit) == 200 then
			if ConfigMenu.Champ.F.LH.F:Value() == 1 then
				if Human then
					if (GetCurrentHP(Unit) - GetHealthPrediction(Unit, self.aaTimer)) == 0 and ConfigMenu.Champ.F.LH.H.Q:Value() and Unit.valid then
						self:CastQH(Unit)
					end
				else 
					if self.Spells2[3].Ready and self.Spells[0].Ready and v.valid then
						self:CastRC(Unit)
					end
				end
			elseif ConfigMenu.Champ.F.LH.F:Value() == 2 then
				if Human then
					if self.Spells[3].Ready and v.valid then
						self:CastRH(Unit)
					end
				else
					if (GetCurrentHP(Unit) - GetHealthPrediction(Unit, self.aaTimer)) == 0 and self.Spells2[0].Ready and ConfigMenu.Champ.F.LH.C.Q:Value() and Unit.valid then
						self:CastQC(Unit)
					end
				end
			elseif 	ConfigMenu.Champ.F.LH.F:Value() == 3 then
				if Human then
					if (GetCurrentHP(Unit) - GetHealthPrediction(Unit, self.aaTimer)) == 0 and ConfigMenu.Champ.F.LH.H.Q:Value() and Unit.valid then
						self:CastQH(Unit)
					end

					if not self.Spells[0].Ready and self.Spells[3].Ready and Unit.valid then
						self:CastRC(Unit)
					end
				else
					if (GetCurrentHP(Unit) - GetHealthPrediction(Unit, self.aaTimer)) == 0 and self.Spells2[0].Ready and ConfigMenu.Champ.F.LH.C.Q:Value() and Unit.valid then
						self:CastQC(Unit)
					end

					if not self.Spells2[0].Ready and self.Spells[0].Ready and Unit.valid then
						self:CastRC(Unit)
					end		
				end
			end
		end	
	end
end

function Nidalee:Walljump()
	local Pos = {pos = nil, pos2 = nil, pos3 = nil, time = 0, time2 = 0}
	local V1 = GetMousePos() + Vector(Vector(GetOrigin(myHero)) - Vector(GetMousePos())):normalized()*375
	local V2 = GetMousePos() + Vector(Vector(GetOrigin(myHero)) - Vector(GetMousePos())):normalized()*187
	if ConfigMenu.Champ.Orb.WJ:Value() then
		if not MapPosition:inWall(GetMousePos()) and not MapPosition:inWall(V1) and MapPosition:inWall(V2) then
			Pos[1] = GetMousePos()
			Pos[2] = V1
			Pos[3] = GetOrigin(myHero)
			DelayAction(function() Pos[4] = GetDistance(Pos[1])/GetMoveSpeed(myHero) end, 0.1)
			Pos[5] = self.Spells2[3].Timer
			MoveToXYZ(V1)
		end
--><
		if Human then
			if self.Spells[3].Ready then
				CastSpell(3)
			else
				if Pos[4] ~= nil then
					if Pos[5] < Pos[4] and (Pos[5] - Pos[4]) > 1 then
						DelayAction(function() CastSpell(3) end, Pos[5])
					else
						DelayAction(function() CastSpell(3) end, Pos[5])
					end
				end
			end
		end
	end

	if not Human and Pos[1] ~= nil and Pos[2] ~= nil then
		if GetDistance(Pos[2]) < 50 and self.Spells[1].Ready then
			CastSkillShot(1, Pos[1])
			DelayAction(function() HoldPosition() Pos[1] = nil Pos[2] = nil Pos[4] = 0 end, 0.1)
		end
	end
end

function Nidalee:TotalDmg(Unit)
	local TDmg = 0
	if self.Spells[0].Ready then
		TDmg = TDmg + self.HDmg[0](Unit)
	end

	if self.Spells[1].Ready then
		TDmg = TDmg
	end

	if self.Spells2[0].Ready then
		TDmg = TDmg + self.CDmg[0](Unit)
	end

	if self.Spells2[1].Ready then
		TDmg = TDmg + self.CDmg[1](Unit)
	end

	if self.Spells2[2].Ready then
		TDmg = TDmg + self.CDmg[2](Unit)
	end
	return TDmg
end

function Nidalee:Checks()
	if GetCastName(myHero, 0) ~= "JavelinToss" then
		Human = false
	else
		Human = true
	end

	for i = 0, 3, 1 do
		self.Spells[i].Timer = self.Spells[i].CDT + self.Spells[i].CD(myHero) - GetGameTimer()
		self.Spells2[i].Timer = self.Spells2[i].CDT + self.Spells2[i].CD(myHero) - GetGameTimer()
		if self.Spells[i].Timer <= 0 then
			self.Spells[i].Ready = true
			self.Spells[i].Timer = 0
		else
			self.Spells[i].Ready = false
		end

		if self.Spells2[i].Timer <= 0 then
			self.Spells2[i].Ready = true
			self.Spells2[i].Timer = 0
		else
			self.Spells2[i].Ready = false
		end

		if GetCastLevel(myHero, i) == 0 then
			self.Spells[i].Ready = false
			self.Spells2[i].Ready = false
		end
	end

	if self.aaTimeReady ~= nil then
		self.aaTimer = self.aaTimeReady - GetGameTimer()
		if self.aaTimer <= 0 then
			self.aaTimer = 0
		end
	end
end

function Nidalee:UnderTower(Object)
	for i = 1, #Towers, 1 do
		if GetDistance(Object, Towers[i]) < 1000 then
			return true
		end
	end
	return false
end

function Nidalee:Hunteds(Unit)
	if Unit ~= nil and self.Hunted[GetNetworkID(Unit)] then
		return true
	end
	return false
end

function Nidalee:CC(Unit)
	if Unit ~= nil and self.Fucked[GetNetworkID(Unit)] then
		return true
	end
	return false
end

function Nidalee:QHDmg(Unit)
	return 42+17.5*GetCastLevel(myHero, 0) + GetBonusAP(myHero)*0.4
end

function Nidalee:Maths(Unit)
	return self.QCDmg[GetCastLevel(Unit, 3)] + (GetBaseDamage(Unit)+GetBonusDmg(Unit))*0.75 + GetBonusAP(Unit)*0.36
end

function Nidalee:CastQH(Unit)
	local QPred = GetPrediction(Unit, self.Spells[0])
	if self.Spells[0].Ready and ValidTarget(Unit, self.Spells[0].range) and Human and QPred and QPred.hitChance*100 >= 20 and not QPred:mCollision(1) then
		CastSkillShot(0, QPred.castPos)
	end
end

function Nidalee:CastWH(Unit)
	if ConfigMenu.Champ.C.H.W:Value() == 2 then
		local WPred = GetPrediction(Unit, self.Spells[1])
		if self.Spells[1].Ready and ValidTarget(Unit, self.Spells[1].range) and Human and WPred and WPred.hitChance*100 >= 20 then
			CastSkillShot(1, WPred.castPos)
		end
	elseif ConfigMenu.Champ.C.H.W:Value() == 1 then
		if self.Spells[1].Ready and ValidTarget(Unit, self.Spells[1].range) and Human and self:CC(Unit) then
			CastSkillShot(1, GetOrigin(Unit))
		end
	end
end

function Nidalee:CastRH(Unit)
	if self.Spells[3].Ready and ValidTarget(Unit, 750) and Human then
		CastSpell(3)
	end
end

function Nidalee:CastQC(Unit)
	if self.Spells2[0].Ready and ValidTarget(Unit, 200) and not Human then
		CastSpell(0)
		DelayAction(function()
			AttackUnit(Unit)
		end, 0.1)
	end
end

function Nidalee:CastWC(Unit)
	if Unit ~= nil then 
		local V1 = GetOrigin(myHero) - Vector(Vector(GetOrigin(myHero)) - Vector(GetOrigin(Unit))):normalized()*375
		if self.Spells2[1].Ready and not Human then
			if ConfigMenu.Champ.C.C.WT:Value() then
				if self:Hunteds(Unit) then
					if ValidTarget(Unit, 750) then
						CastTargetSpell(Unit, 1)
					end
				else
					if ValidTarget(Unit, 375) then
						CastSkillShot(1, GetOrigin(Unit))
					end
				end
			else
				if self:Hunteds(Unit) then
					if ValidTarget(Unit, 750) and not UnderTurret(GetOrigin(Unit)) then
						CastTargetSpell(Unit, 1)
					end
				else
					if ValidTarget(Unit, 375) and not UnderTurret(V1) then
						CastSkillShot(1, GetOrigin(Unit))
					end
				end
			end
		end
	end
end


function Nidalee:CastEC(Unit)
	if self.Spells2[2].Ready and not Human and ValidTarget(Unit, 300) then
		CastSkillShot(2, GetOrigin(Unit))
	end
end

function Nidalee:CastRC(Unit)
	if self.Spells[3].Ready and not Human and ValidTarget(Unit, self.Spells[0].range) then
		CastSpell(3)
	end
end

function Nidalee:CastEH()
	for k, v in ipairs(GetAllyHeroes()) do
		if not self.Recalling and ConfigMenu.Champ.HE["HM"..GetObjectName(v)] ~= nil then
			if Human then
				if GetPercentHP(myHero) < ConfigMenu.Champ.HE.E:Value() and self.Spells[2].Ready then
					CastTargetSpell(myHero, 2)
				end

				if GetDistance(v) < self.Spells[2].range and GetPercentHP(v) < ConfigMenu.Champ.HE["HM"..GetObjectName(v)]["HV"..GetObjectName(v)]:Value() and self.Spells[2].Ready then
					CastTargetSpell(v, 2)
				end
			else
				if GetPercentHP(myHero) < ConfigMenu.Champ.HE.E:Value() and ConfigMenu.Champ.HE.R:Value() and self.Spells[2].Ready then
					CastSpell(3)
					DelayAction(function() CastTargetSpell(myHero, 2) end, 0.1)
				end

				if GetDistance(v) < self.Spells[2].range and GetPercentHP(v) < ConfigMenu.Champ.HE["HM"..GetObjectName(v)]["HV"..GetObjectName(v)]:Value() and ConfigMenu.Champ.HE["HM"..GetObjectName(v)]["HO"..GetObjectName(v)]:Value() and ConfigMenu.Champ.HE["HM"..GetObjectName(v)]["FH"..GetObjectName(v)]:Value() and self.Spells[2].Ready then
					CastSpell(3)
					DelayAction(function() CastTargetSpell(v, 2) end, 0.1)
				end
			end
		end
	end
end

function Nidalee:OnProc(unit, spellProc)
	if unit == myHero and spellProc.name == self.Spells2[1].Name then
		if self:Hunteds(spellProc.target) then
			DelayAction(function() self.Spells2[1].Timer = self.Spells2[1].Timer*0.70 end, 0.1)
		end
	end
end

function Nidalee:OnProcComplete(unit, spellProc)
	if unit == myHero then
		if spellProc.name:lower():find("attack") then
			ASDelay = 1/(self.baseAS*GetAttackSpeed(myHero))
			self.windUP = spellProc.windUpTime
			self.aaTimeReady = ASDelay + GetGameTimer() - self.windUP/1000
		end

		if ConfigMenu.Champ.Orb.LC:Value() then
			for k, v in ipairs(minionManager.objects) do
				if spellProc.name:lower():find("attack") then
					if Human then
						if ConfigMenu.Champ.F.LC.H.Q:Value() then
							self:CastQH(v)
						end
					else
						if ConfigMenu.Champ.F.LC.C.Q:Value() then
							self:CastQC(v)
						end
					end
				end
			end
		end
	end
end

function Nidalee:OnCast(unit, spell)
	if unit == myHero then
		for i = 0, 3, 1 do
			if Human then
				if spell.name == self.Spells[i].Name then
					self.Spells[i].CDT = GetGameTimer()
				end
			else
				if spell.name == self.Spells2[i].Name then
					self.Spells2[i].CDT = GetGameTimer()
				end				
			end
		end
	end
end

function Nidalee:OnUpdate(unit, buff)
	if GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero or GetObjectType(unit) == Obj_AI_Camp and buff and unit.valid then
		if self.DebuffTable[buff.Type] then
			self.Fucked[GetNetworkID(unit)] = true
		end
		if buff.Name == "NidaleePassiveHunted" then
			self.Hunted[GetNetworkID(unit)] = true
		end
	end
	if buff.Name == "recall" or buff.Name == "OdinRecall" and unit == myHero then
		self.Recalling = true
	end
end

function Nidalee:OnRemove(unit, buff)
	if GetTeam(unit) ~= GetTeam(myHero) and GetObjectType(unit) == Obj_AI_Hero and buff then
		if self.Fucked[GetNetworkID(unit)] then
			self.Fucked[GetNetworkID(unit)] = nil
		end
		if self.Hunted[GetNetworkID(unit)] then
			self.Hunted[GetNetworkID(unit)] = nil
		end
	end
	if buff.Name == "recall" or buff.Name == "OdinRecall" and unit == myHero then
		self.Recalling = false
	end
end

function Nidalee:Download()
	for i = 1,16,1 do
		if FileExist(SPRITE_PATH..self.Sprite[i].FName) then self.abc = true return end
		if not DirExists(SPRITE_PATH.."Nidalee") then
			CreateDir(SPRITE_PATH.."Nidalee")
		end

		if DirExists(SPRITE_PATH.."Nidalee") then
			DownloadFileAsync("https://raw.githubusercontent.com/Hanndel/GoS/master/Sprites/Nidalee/"..self.Sprite[i].Web, SPRITE_PATH .. "Nidalee\\"..self.Sprite[i].Web, function() PrintChat("Downloading "..self.Sprite[i].Web.." F6x2!") return end)
		end
	end
end

class "Singed"

function Singed:__init()
	self.Spot = nil
	self.Target = nil
	self.Poison = false

	ConfigMenu.Champ:Menu("C", "Combo")
		ConfigMenu.Champ.C:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.C:Boolean("W", "Use W", true)
		ConfigMenu.Champ.C:Boolean("E", "Use E", true)
		ConfigMenu.Champ.C:Boolean("R", "Use R", true)

	ConfigMenu.Champ:Menu("JC", "JunglerClear")
		ConfigMenu.Champ.JC:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.JC:Boolean("E", "Use E", true)

	ConfigMenu.Champ:Menu("LC", "LaneClear")
		ConfigMenu.Champ.LC:Boolean("Q", "Use Q", true)
		ConfigMenu.Champ.LC:Boolean("E", "Use E", true)

	ConfigMenu.Champ:Menu("HC", "Hitchance")
		ConfigMenu.Champ.HC:Slider("W", "W HitChance", 20, 1, 100)

	ConfigMenu.Champ:Menu("Orb", "Hotkeys")
		ConfigMenu.Champ.Orb:KeyBinding("C", "Combo", string.byte(" "), false)
		--ConfigMenu.Champ.Orb:KeyBinding("H", "Harass", string.byte("C"), false)
		ConfigMenu.Champ.Orb:KeyBinding("LC", "LaneClear", string.byte("V"), false)
		--ConfigMenu.Champ.Orb:KeyBinding("LH", "LastHit", string.byte("X"), false)

	OnTick(function(myHero) self:Tick(myHero) end)
	OnProcessWaypoint(function(unit, way) self:OnWay(unit, way) end)
end


function Singed:Tick(myHero)
	self.Target = DickSelector:Targets(1000)
	Autolvl:Autolvl(myHero)

	if ConfigMenu.Champ.Orb.C:Value() and self.Target then
		self:Combo(self.Target)
	end

	if ConfigMenu.Champ.Orb.LC:Value() then
		self:LaneClear()
	end
end

function Singed:OnUpdate(unit, buff)
	if unit == myHero and buff.Name == "PoisonTrail" then
		self.Poison = true
	end
end

function Singed:OnRemove(unit, buff)
	if unit == myHero and buff.Name == "PoisonTrail" then
		self.Poison = false
	end
end

function Singed:OnWay(unit, way)
	if unit and unit == self.Target then
		if way.index == 1 then
			self.Spot = way.position
		end
	end
end
--><

function Singed:Combo(Unit)
	if ConfigMenu.Champ.C.Q:Value() then
		self:CastQ(Unit)
	end

	if ConfigMenu.Champ.C.W:Value() then
		self:CastW(Unit)
	end

	if ConfigMenu.Champ.C.E:Value() then
		self:CastE(Unit)
	end

	if ConfigMenu.Champ.C.R:Value() then
		self:CastR(Unit)
	end
end

function Singed:LaneClear()
	for k, v in ipairs(minionManager.objects) do
		if ValidTarget(v, 1000) then
			if GetTeam(v) == MINION_ENEMY then
				if ConfigMenu.Champ.LC.Q:Value() then
					self:CastQ(v)
				end
				if ConfigMenu.Champ.LC.Q:Value() then
					self:CastE(v)
				end
			elseif GetTeam(v) == MINION_JUNGLE then
				if ConfigMenu.Champ.JC.Q:Value() then
					self:CastQ(v)
				end
				if ConfigMenu.Champ.JC.Q:Value() then
					self:CastE(v)
				end
			end
		end
	end
end

function Singed:CastQ(Unit)
		if GetObjectType(Unit) ~= Obj_AI_Minion then 
			if ValidTarget(Unit, 500) then
				if self.Spot then
					local V = GetOrigin(myHero) - Vector(Vector(self.Spot) - Vector(GetOrigin(myHero))):normalized()*100
					if GetDistance(V, Unit) < GetDistance(Unit, myHero) and Ready(0) and not self.Poison then
						CastSpell(0)
						self.Poison = true
					end
				end
			else
				if self.Poison and Ready(0) then
					CastSpell(0)
					self.Poison = false
				end
			end
		else
			if ValidTarget(Unit, 500) then
				if Ready(0) and not self.Poison then
					CastSpell(0)
					self.Poison = true
				end
			else
				if self.Poison and Ready(0) then
					CastSpell(0)
					self.Poison = false
				end
			end
		end
end

function Singed:CastW(Unit)
	local W = {range = 1000, delay = 0.5, radius = 175, speed = 1200}
	local WPRed = GetPrediction(Unit, W)
	if ValidTarget(Unit, W.range) and Ready(1) then
		if GetDistance(Unit) > 200 then
			if WPred and WPred.hitChance >= (ConfigMenu.Champ.HC.W:Value())/100 then
				CastSkillShot(1, WPred.castPos)
			end
		else
			local V = GetOrigin(myHero) - Vector(Vector(GetOrigin(Unit)) - Vector(GetOrigin(myHero))):normalized()*550
			if Ready(2) then
				CastSkillShot(1, V)
				DelayAction(function() CastTargetSpell(Unit, 2) end, 0.6)
			end
		end
	end
end

function Singed:CastE(Unit)
	if ValidTarget(Unit, 200) and Ready(2) and not Ready(1) then
		CastTargetSpell(Unit, 2)
	end
end

function Singed:CastR(Unit)
	local R = {[1] = 7, [2] = 10, [3] = 16}
	if ValidTarget(Unit, 500) and Ready(3) then
		if GetMaxHP(myHero) - GetCurrentHP(myHero) < 25*R[GetCastLevel(myHero, 3)] and GetMaxMana(myHero) - GetCurrentMana(myHero) < 25*R[GetCastLevel(myHero, 3)] then
			CastSpell(3)
		end
	end
end

class "DmgDraw"

function DmgDraw:__init()

	ConfigMenu:Menu("DD", "Draw Dmg")
		ConfigMenu.DD:Boolean("DTD", "Draw Total Damage", true)
		ConfigMenu.DD:ColorPick("DColor", "Damage Color", {255,255,0,255})

	OnDraw(function(myHero) self:Draw(myHero) end)
end



function DmgDraw:Draw(myHero)
	local Keepo = {0, 0, 0, 0}
	for k, v in pairs(GetEnemyHeroes()) do
		for i = 0, 3, 1 do
			if Dmg ~= nil and Dmg[i] then
				if Ready(i) then
					Keepo[i+1] = Dmg[i](v)
				end
				local asd = Keepo[1] + Keepo[2] + Keepo[3] + Keepo[4]
				local HpBar = GetHPBarPos(v)
				local What = (asd*100)/GetMaxHP(v)
				local hp = (GetCurrentHP(v)*100/GetMaxHP(v))
				if IsVisible(v) and ValidTarget(v, 2000) then
					if GetCurrentHP(v) > asd then
						FillRect(HpBar.x+4+hp-What*1.03,HpBar.y,What*1.03,5,ConfigMenu.DD.DColor:Value())
					else
						FillRect(HpBar.x+1,HpBar.y,hp*1.03,5,ConfigMenu.DD.DColor:Value())
					end
				end
			end
		end
	end
end
