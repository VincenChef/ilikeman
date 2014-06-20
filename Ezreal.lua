if myHero.charName ~= "Ezreal" then return end



local version = "0.13"
local AUTOUPDATE = true
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/fter44/ilikeman/master/Ezreal.lua".."?rand="..math.random(1,10000)
local UPDATE_FILE_PATH = SCRIPT_PATH .. GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#6699ff\"><b>Ezreal:</b></font> <font color=\"#FFFFFF\">"..msg..".</font>") end
if AUTOUPDATE then
	local ServerData = GetWebResult(UPDATE_HOST, "/fter44/ilikeman/master/VersionFiles/Ezreal.version".."?rand="..math.random(1,10000))
	if ServerData then
		ServerVersion = type(tonumber(ServerData)) == "number" and tonumber(ServerData) or nil
		if ServerVersion then
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end) end, 3)
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end




require 'VPrediction'
require 'SOW'
require "SourceLib"
require "Prodiction"
require "DRAW_POS_MANAGER"
require "ITEM_MANAGER"
local SPELL_DATA = { [_Q  ] = { skillshotType = SKILLSHOT_LINEAR, range = 01200, speed = 2000, width = 060,	delay=0.25},
					 [_W  ] = { skillshotType = SKILLSHOT_LINEAR, range = 01050, speed = 1600, width = 080,	delay=0.25},  
					 [_E  ] = { range = 550},
					 [_R  ] = { skillshotType = SKILLSHOT_LINEAR, range = 65536, speed = 2000, width = 160,	delay=1.00},
}
--[[Kill Str Manager]]--
local KILLTEXTS

function OnLoad()
	if Init_Settings() and Load_Menu() then
		AddTickCallback(OnTick2)
		AddDrawCallback(OnDraw2)
		Print("EZREAL Loaded")
	end
end

local menu
local VP,SOWi,STS
local Q,W,E,R
--BUFFS
local P_BUFF_NAME="ezrealrisingspellforce"
local P_BUFF_STACK=0

function Init_Settings()
	VP = VPrediction()
	
	Spell.VP=VP
	function Spell:IsInRangeAdv(target, from)--fter44
		return (self.range+self.VP:GetHitBox(target))^2 >= _GetDistanceSqr(target, from or self.sourcePosition)
	end
	SOWi = SOW(VP)
	
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	
	--Q
		Q = Spell(_Q,SPELL_DATA[_Q].range,true) 
			Q:SetSkillshot(VP, SPELL_DATA[_Q ].skillshotType, SPELL_DATA[_Q ].width,SPELL_DATA[_Q ].delay, SPELL_DATA[_Q ].speed,true)
	--W
		W = Spell(_W,SPELL_DATA[_W].range)
			W:SetSkillshot(VP, SPELL_DATA[_W ].skillshotType, SPELL_DATA[_W ].width,SPELL_DATA[_W ].delay, SPELL_DATA[_W ].speed,false)
	--E
		E = Spell(_E,SPELL_DATA[_E].range)
	--R
		R = Spell(_R,SPELL_DATA[_R].range) --R:Cast_ChampCollision(Target)
			R:SetSkillshot(VP, SPELL_DATA[_R].skillshotType, SPELL_DATA[_R].width,SPELL_DATA[_R].delay, SPELL_DATA[_R].speed)
			R:SetAOE(true) 
	return true
end


function Load_Menu()
	menu = scriptConfig("Ezreal", "Ezreal")
	
	--OW
	menu:addSubMenu("Orbwalker", "SOWiorb")
		SOWi:LoadToMenu(menu.SOWiorb)
	
	--TS
	menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(menu.STS)	
	--SPELLS
	menu:addSubMenu("Q", "Q")	
		menu.Q:addParam("ks", "Q@KS", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("combo", "Q@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("harass", "Q@harass", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("farm", "Q@farm", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("laneclear", "Q@laneclear", SCRIPT_PARAM_ONOFF, true)
		menu.Q:addParam("jungle", "Q@jungle", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("W", "W")
		menu.W:addParam("ks", "W@KS", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("combo", "Auto W@Combo", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("harass", "Auto W@harass", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("P", "Consider Passive Stack", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("mana", "Consider Mana before cast", SCRIPT_PARAM_ONOFF, true)
		menu.W:addParam("Q", "Q mana", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)	
		menu.W:addParam("E", "E mana", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)	
		menu.W:addParam("R", "R mana", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)	
	menu:addSubMenu("E", "E")				 		
		--menu.E:addParam("gap", "Anti-Gapcloser with E", SCRIPT_PARAM_ONOFF, true)
	menu:addSubMenu("R", "R")
		menu.R:addParam("ks", "KS R", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("alert", "Alert R", SCRIPT_PARAM_ONOFF, true)
		menu.R:addParam("min", "Min R Range", SCRIPT_PARAM_SLICE, 1100, 0, 1800, 0)	
		menu.R:addParam("max", "Max R Range", SCRIPT_PARAM_SLICE, 1700, 0, 3575, 0)
		menu.R:addParam("N", "Min Enemies for Auto R", SCRIPT_PARAM_SLICE, 4, 1, 5, 0)
		menu.R:addParam("cast","Cast R@KS Target",SCRIPT_PARAM_ONKEYDOWN,false,string.byte("T"))
	
	--[[
	--AntiGapcloser
	menu:addSubMenu("AntiGapcloser","AG")
		AntiGapcloser(menu.AG, function(unit,data)			
			if menu.E.gap and R:IsReady() and SOWi:InRange(target)  then
				R:Cast(unit,true,true)
			end
		end)
	]]
	--DRAWING
	menu:addSubMenu("Drawings", "Drawings")
		local DManager = DrawManager()
		DManager:CreateCircle(myHero, SPELL_DATA[_Q ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"Q range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_W ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"W range", true, true, true)
		DManager:CreateCircle(myHero, SPELL_DATA[_E ].range, 1, {255, 255, 255, 255}):AddToMenu(menu.Drawings,"E range", true, true, true)		
		menu.Drawings:addSubMenu("KillTexts","KillTexts")
			KILLTEXTS=TEXTPOS_HPBAR(menu.Drawings.KillTexts,23,46,30)	
			menu.Drawings.KillTexts:addParam("hit","hit",SCRIPT_PARAM_ONOFF,true)
			menu.Drawings.KillTexts:addParam("time","time",SCRIPT_PARAM_ONOFF,true)
	--EXTRA
	menu:addSubMenu("Extra menu", "Extras")
		menu.Extras:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)				
	menu:addParam("combo", "combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))		menu:permaShow("combo")
	menu:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X')) 		menu:permaShow("harass")
	menu:addParam("farm", "farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('Z'))		menu:permaShow("farm")
	menu:addParam("laneclear", "laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V')) 		menu:permaShow("laneclear")
	menu:addParam("jungle", "jungle", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V')) 		menu:permaShow("jungle")
	
	return true
end

local R_KS_Target
local Target
function OnTick2()
	KD()
	--KS		
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then		
			if  menu.Q.ks and Q:IsReady() and getDmg("Q", enemy, myHero) > enemy.health then
				CAST_Q(enemy)
				goto continue
			elseif  menu.W.ks and W:IsReady() and getDmg("W", enemy, myHero) > enemy.health then
				CAST_W(enemy,true)
				goto continue
			elseif R:IsReady() and getDmg("R", enemy, myHero) > enemy.health then
				if menu.R.ks then
					CAST_R(enemy,true)
				else
					if menu.R.alert then
						PrintAlert_T(enemy,enemy.charName.." R KILLABLE",1,0,0,255)
					end
				end
				R_KS_Target=enemy
			end
		end
		::continue::
	end	
	if R_KS_Target and R_KS_Target.health< getDmg("R",R_KS_Target,myHero) then
		R_KS_Target=nil
	end
	--MANUAL CAST
		--R
	if ValidTarget(R_KS_Target) and R:IsReady() and menu.R.cast then
		CAST_R(R_KS_Target,true,true)
	end
	
	
	if menu.farm then
		FARM()
	end
	if menu.laneclear then
		LANECLEAR()
	end
	if menu.jungle then
		JUNGLE()
	end
	
	--SET TARGET	
	Target = STS:GetTarget(SPELL_DATA[_W].range)
	if not Target or not ValidTarget(Target) then return end

	
	if menu.combo then
		COMBO(Target)
	elseif menu.harass then
		HARASS(Target)
	end
end

function COMBO(Target)
	if Q:IsReady() and menu.Q.combo then
		CAST_Q(Target)
	end  
	if W:IsReady() and menu.W.combo then
		CAST_W(Target)
	end  
	if R:IsReady() and menu.R.combo then
		CAST_R(Target)
	end
end
function HARASS(Target)
	if Q:IsReady() and menu.Q.harass then
		CAST_Q(Target)
	end  
	if W:IsReady() and menu.W.harass then
		CAST_W(Target)
	end 
end

--[[
██╗  ██╗    ██╗    ██╗         ██╗     
██║ ██╔╝    ██║    ██║         ██║     
█████╔╝     ██║    ██║         ██║     
██╔═██╗     ██║    ██║         ██║     
██║  ██╗    ██║    ███████╗    ███████╗
╚═╝  ╚═╝    ╚═╝    ╚══════╝    ╚══════╝
                                       
--]]
do
local KD_nexttick=0
function KD()
	if os.clock() < KD_nexttick then return end
	KD_nexttick = os.clock()+0.2
	
	for _,enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			local AA 	= getDmg("AD",enemy,myHero) --critChance
			local HP 	= enemy.health
			
			local hit = math.ceil( HP/AA)
			local hit_T = math.ceil( hit/myHero.attackSpeed )
			local str=""
			
			if menu.Drawings.KillTexts.hit then
				str=str..hit.." Hit\n"
			end
			if menu.Drawings.KillTexts.time then
				str=str..hit_T.." Sec\n"
			end
			KILLTEXTS:SET_TEXT(enemy,str)		
		end
	end
end
end


--[[
 ██████╗     █████╗     ███████╗    ████████╗
██╔════╝    ██╔══██╗    ██╔════╝    ╚══██╔══╝
██║         ███████║    ███████╗       ██║   
██║         ██╔══██║    ╚════██║       ██║   
╚██████╗    ██║  ██║    ███████║       ██║   
 ╚═════╝    ╚═╝  ╚═╝    ╚══════╝       ╚═╝   
                                             
--]]



function CAST_Q(Target)
	return Q:Cast(Target)==SPELLSTATE_TRIGERRED
end


local Q_COST={28,31,34,37,40}
local E_COST={90,90,90,90,90}
local R_COST={100,100,100}
function Is_Mana_Enough(Qc,Ec,Rc)
	local mana=0
	--[[
	mana = mana + (Qc * Q_COST[Q:GetLevel()] or 0)
	mana = mana + (Ec * 90 )
	mana = mana + (Rc * 100)
	]]
	mana = mana + (Qc and Q_COST[Q:GetLevel()] or 0)
	mana = mana + (Ec and 90 )
	mana = mana + (Rc and 100)
	
	return myHero.mana>=mana	
end

function CAST_W(Target,force)--consider (Q,E,R mana cost) and (Passive Stack)
	--local b_mana=(not menu.W.mana or Is_Mana_Enough(menu.W.Q,menu.W.E,menu.W.R))
	--local b_stack=(not menu.W.P or P_BUFF_STACK<5 )
	--print(b_mana,b_stack)
	if force or ((not menu.W.mana or Is_Mana_Enough(menu.W.Q,menu.W.E,menu.W.R)) and (not menu.W.P or P_BUFF_STACK<5 )) then
		return W:Cast(Target)
	end
end

function CAST_R(Target,forceN,forceD)
	if forceN then
		R.minTargetsAoe=1
		if forceD or (_GetDistanceSqr(Target) > menu.R.min*menu.R.min and _GetDistanceSqr(Target) < menu.R.max*menu.R.max) then
			return R:Cast(Target)
		end
	else
		R.minTargetsAoe=menu.R.N
		return R:Cast(Target)
	end
end 
function OnDraw2()
	--DEBUG
	if menu.Extras.Debug then
		DrawText3D("Current P_BUFF_STACK status is " .. tostring(P_BUFF_STACK), myHero.x+200, myHero.y, myHero.z+200, 25,  ARGB(255,255,0,0), true)
	end
	--R TARGET
	if ValidTarget(R_KS_Target) and R:IsReady() then
		DrawText3D("R KILLABLE",R_KS_Target.x,0,R_KS_Target.z,20,ARGB(255,255,0,0),true)
	end
	--TARGET
	if ValidTarget(Target) then
		DrawCircle3D(Target.x, Target.y, Target.z, 100, 2, ARGB(175, 255, 0, 0), 25)
	end
end
--[[
██████╗               ██████╗     ██╗   ██╗    ███████╗    ███████╗
██╔══██╗              ██╔══██╗    ██║   ██║    ██╔════╝    ██╔════╝
██████╔╝    █████╗    ██████╔╝    ██║   ██║    █████╗      █████╗  
██╔═══╝     ╚════╝    ██╔══██╗    ██║   ██║    ██╔══╝      ██╔══╝  
██║                   ██████╔╝    ╚██████╔╝    ██║         ██║     
╚═╝                   ╚═════╝      ╚═════╝     ╚═╝         ╚═╝     
                                                                   
--]]
do
function OnGainBuff(unit, buff)
	if unit.isMe then
		print(buff.name)
		if buff.name == P_BUFF_NAME then
			P_BUFF_STACK = 1
		end
	end
end
function OnUpdateBuff(unit,buff)
	if unit.isMe then 
		if buff.name == P_BUFF_NAME then
			P_BUFF_STACK = buff.stack
		end
	end
end
function OnLoseBuff(unit, buff)
	if unit.isMe then 
		if buff.name == P_BUFF_NAME then
			P_BUFF_STACK = 0
		end
	end
end
end 
--[[
███╗   ███╗    ██╗    ███████╗     ██████╗    ███████╗
████╗ ████║    ██║    ██╔════╝    ██╔════╝    ██╔════╝
██╔████╔██║    ██║    ███████╗    ██║         ███████╗
██║╚██╔╝██║    ██║    ╚════██║    ██║         ╚════██║
██║ ╚═╝ ██║    ██║    ███████║    ╚██████╗    ███████║
╚═╝     ╚═╝    ╚═╝    ╚══════╝     ╚═════╝    ╚══════╝
                                                      
--]]
do
function Print(str)	print("<font color=\"#6699ff\"><b>FTER44:</b></font> <font color=\"#FFFFFF\">"..str..".</font>") end

function CountEnemyHeroInRange(point,range)
    local count = 0
    for _,c in pairs(GetEnemyHeroes()) do	
        if ValidTarget(c) and GetDistanceSqr(c, point) <= range*range then
			count=count+1
		end
    end
    return count
end


local Alert_Texts={}
function PrintAlert_T(target,text,duration,r,g,b)
	if Alert_Texts[target] then
		if Alert_Texts[target]<os.clock() then --used before
			PrintAlert(text,duration,r,g,b)	
			DelayAction(PingClient,  0.3, {target.x, target.z})
			DelayAction(PingClient,  0.6, {target.x, target.z})
			DelayAction(PingClient,  0.9, {target.x, target.z})
		end
	else
		PrintAlert(text,duration,r,g,b)
		DelayAction(PingClient,  0.3, {target.x, target.z})
		DelayAction(PingClient,  0.6, {target.x, target.z})
		DelayAction(PingClient,  0.9, {target.x, target.z})
	end	
	
	Alert_Texts[target]=os.clock()+10
end


function FARM()
	SOWi.EnemyMinions:update()
	for _, minion in ipairs(SOWi.EnemyMinions.objects) do	
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if SOWi:ValidTarget(minion) and SOWi:GetState()==0 and not( PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.farm and CAST_Q(minion) ) --[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.farm and CAST_W(minion) )]]
			--[[or]]--[[ ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.farm or menu.E.cast) and CAST_E(minion) )]] )
			then
			break
		end
	end
end
function LANECLEAR()
	SOWi.EnemyMinions:update()
	for _, minion in ipairs(SOWi.EnemyMinions.objects) do	
		local time = SOWi:WindUpTime(true) + GetDistance(minion.visionPos, myHero.visionPos) / SOWi.ProjectileSpeed - 0.07
		local PredictedHealth = SOWi.VP:GetPredictedHealth(minion, time, GetSave("SOW").FarmDelay / 1000)
		if not( SOWi:ValidTarget(minion) and PredictedHealth < VP:CalcDamageOfAttack(myHero, minion, {name = "Basic"}, 0) + SOWi:BonusDamage(minion) and SOWi:CanAttack()==true ) and ( 
			( Q:IsReady() and getDmg("Q",minion,myHero)>=minion.health and menu.Q.laneclear and CAST_Q(minion) )--[[or ( W:IsReady() and getDmg("W",minion,myHero)>=minion.health and menu.W.laneclear and CAST_W(minion) )]]
			--[[or]]--[[ ( E:IsReady() and getDmg("E",minion,myHero)>=minion.health and (menu.E.laneclear or menu.E.cast) and CAST_E(minion) )]] )
			then
			break
		end
	end
end
function JUNGLE()
	target = SOWi.JungleMinions.objects[1]
	if ValidTarget(target) then
		if menu.Q.jungle then
			CAST_Q(target)
		end
	end
end

end
