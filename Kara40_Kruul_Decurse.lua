Kara40 = Kara40 or {}
Kara40.Kruul = Kara40.Kruul or {}


function Kara40.GetClassColor(unit)
	local _,class = UnitClass(unit)
	if (class == "DRUID") then return "FF7C0A" end
	if (class == "HUNTER") then return "AAD372" end
	if (class == "MAGE") then return "3FC7EB" end
	if (class == "PALADIN") then return "F48CBA" end
	if (class == "PRIEST") then return "FFFFFF" end
	if (class == "ROGUE") then return "FFF468" end
	if (class == "SHAMAN") then return "0070DD" end
	if (class == "WARLOCK") then return "8788EE" end
	if (class == "WARRIOR") then return "C69B6D" end
	return "FFFFFF"
end

function Kara40.ColoredName(unit)
    return "\124cff"..Kara40.GetClassColor(unit)..UnitName(unit).."\124r"
end

function Kara40.Info(message)
    DEFAULT_CHAT_FRAME:AddMessage("\124cff00ff00INFO\124r: "..tostring(message))
end

function Kara40.Warning(message)
    DEFAULT_CHAT_FRAME:AddMessage("\124cffffff00WARNING\124r: "..tostring(message))
end

function Kara40.Error(message)
    DEFAULT_CHAT_FRAME:AddMessage("\124cffff0000ERROR\124r: "..tostring(message))
end

function Kara40.UnitIsCursed(unit, dtypestr)
    if (not dtypestr) then dtypestr = "curse" end
	local i = 1
	local debuff,_,dtype = UnitDebuff(unit, i)
	while (debuff) do
        if (strlower(tostring(dtype)) == strlower(dtypestr)) then
            return true
        end
		i = i + 1
		debuff,_,dtype = UnitDebuff(unit, i)
	end
	return false
end

function Kara40.CheckRaidProximity(targetUnitString, proximity)
	local result = -1 -- includes self
	local tx, ty = UnitPosition(targetUnitString)
	for i = 1, GetNumRaidMembers(), 1 do
		local unitString = "RAID"..i
		local rx, ry = UnitPosition(unitString)
        if (rx and ry) then
            local dx = tx - rx
            local dy = ty - ry
            local distance = math.sqrt(dx * dx + dy * dy)
            if (distance < proximity) then
                result = result + 1
            end
        end
	end
	return result
end


function Kara40.Kruul.Decurse(proximity)
	if (not SUPERWOW_VERSION) then
		Kara40.Error("SuperWoW required!")
		return nil
	end

	local decurseSpell = nil
	local _,class = UnitClass("PLAYER")

	if (class == "MAGE") then
		decurseSpell = "Remove Lesser Curse"
	elseif (class == "DRUID") then
		decurseSpell = "Remove Curse"
    --elseif (class == "PRIEST") then -- debug
    --    decurseSpell = "Power Word: Fortitude"
	end

	if (decurseSpell == nil) then
		Kara40.Error("You can't decurse")
		return false
	end

	if (not proximity) then
		proximity = 10
	end

    local cursed = 0
	for targetIndex = 1, GetNumRaidMembers(), 1 do
		local unitString = "RAID"..targetIndex

        if (Kara40.UnitIsCursed(unitString)) then
            cursed = cursed + 1
            local closePlayers = Kara40.CheckRaidProximity(unitString, proximity)
            if (closePlayers <= 0) then -- only target himself in proximity
                if (CheckInteractDistance(unitString, 4)) then -- check if target is in 30y range
                    TargetUnit(unitString)
                    CastSpellByName(decurseSpell)
                    Kara40.Info("Decursing "..Kara40.ColoredName(unitString)..".")
                    return true
                else
                    Kara40.Warning(Kara40.ColoredName(unitString).." is safe to decurse but out of our range!")
                end
            else
                Kara40.Warning(Kara40.ColoredName(unitString).." has "..closePlayers.." player(s) in exlosion range!")
            end
        end
	end

    if (cursed == 0) then
        Kara40.Info("Nobody is cursed.")
    end
	
	return false
end