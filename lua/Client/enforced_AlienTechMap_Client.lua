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
    if kAlienTechMap then
        local findCharge = searchMap( kAlienTechMap, kTechId.Charge )
        if not findCharge then
            return
        else
            table.remove( kAlienTechMap, findCharge )
            findCharge = nil
        end
     
        local findStomp = searchMap( kAlienTechMap, kTechId.Stomp )
        if findStomp then
            table.insert( kAlienTechMap, findStomp+1, doomsday )
            findStomp = nil
        end
    end
 end

UpdateAlienTechMap()
