-- search a techMap for the given tech (search)
-- returns index, or returns nil if not found
local function searchMap( map, search )
    local count = #map
    for i, t in ipairs(map) do
        if t[1] == search then
            return i
        end
    end
    return nil
end

local function UpdateAlienTechMap()
    local doomsday = { kTechId.Doomsday, 10, 9 }
	local webtech = { kTechId.WebTech, 5, 11 }
    if kAlienTechMap then
        local findCharge = searchMap( kAlienTechMap, kTechId.Charge )
        if not findCharge then
            return
        else
            table.remove( kAlienTechMap, findCharge )
            findCharge = nil
        end
		
        local findWebTech = searchMap( kAlienTechMap, kTechId.WebTech )
        if not findWebTech then
            return
        else
            table.remove( kAlienTechMap, findWebTech )
            findWebTech = nil
        end
		
        local findStomp = searchMap( kAlienTechMap, kTechId.Stomp )
        if findStomp then
            table.insert( kAlienTechMap, findStomp+1, doomsday )
            findStomp = nil
        end
		
        local findMetabolizeEnergy = searchMap( kAlienTechMap, kTechId.MetabolizeEnergy )
        if findMetabolizeEnergy then
            table.insert( kAlienTechMap, findMetabolizeEnergy+1, webtech )
            findMetabolizeEnergy = nil
        end		
    end
 end

UpdateAlienTechMap()
