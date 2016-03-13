Script.Load("lua/GUIMarineBuyMenu.lua")

local bigIconIndex = GetUpValue( GetBigIconPixelCoords, "gBigIconIndex", { LocateRecurse = true } )
if bigIconIndex and not bigIconIndex[kTechId.HeavyMachineGun] then
--    Log("DEBUG -- GUIMarineBuyMenu Added big icons")
    table.insert( bigIconIndex, kTechId.HeavyMachineGun, 2 )
    table.insert( bigIconIndex, kTechId.NapalmGrenade, 13 )	
end

local smallIconIndex = GetUpValue( GetSmallIconPixelCoordinates, "gSmallIconIndex", { LocateRecurse = true } )
if smallIconIndex and not smallIconIndex[kTechId.HeavyMachineGun] then
--    Log("DEBUG -- GUIMarineBuyMenu Added small icons")
    table.insert( smallIconIndex, kTechId.HeavyMachineGun, 1 )
    table.insert( smallIconIndex, kTechId.NapalmGrenade, 43 )
end

local orig_GUIMarineBuyMenu_Initialize
orig_GUIMarineBuyMenu_Initialize = Class_ReplaceMethod( "GUIMarineBuyMenu", "Initialize",
function (self)
--    Log("DEBUG -- GUIMarineBuyMenu:Initialize")
    orig_GUIMarineBuyMenu_Initialize(self)

end
)

--Log("DEBUG -- GUIMarineBuyMenu.lua done")
