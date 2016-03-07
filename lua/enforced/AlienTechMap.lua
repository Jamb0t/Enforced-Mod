kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

--
local function addToTechmap(techMap, searchTech, tech)
	local idx = nil
	for i, t in ipairs(techMap) do
		if t[1] == searchTech then
			idx = i + 1
			break
		end
	end
		
	if idx then
		table.insert(techmap, idx, tech)
	end
end

local oldGetLinePositionForTechMap = GetLinePositionForTechMap
function GetLinePositionForTechMap(techMap, fromTechId, toTechId)
	-- dirty, but will it work?
	if fromTechId == kTechId.Hive then
		addToTechmap(kTechId.Rupture, { kTechId.Charge, 4, 9 }) 
		addToTechmap(kTechId.Stomp, { kTechId.Doomsday, 10, 9 })
	end
end
