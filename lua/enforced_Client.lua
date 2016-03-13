Script.Load("lua/enforced_Shared.lua")

local function OnLoadComplete()
    if Client then
	    Script.Load("lua/Client/GUI/enforced_GUI.lua")
	end
end

Event.Hook("LoadComplete", OnLoadComplete)

local equipmentOutlineModelLookup = GetUpValue( EquipmentOutline_UpdateModel, "lookup" )
local origEquipmentOutline_Initialize = EquipmentOutline_Initialize
function newEquipmentOutline_Initialize()
    if equipmentOutlineModelLookup then
    	table.insert(equipmentOutlineModelLookup, "HeavyMachineGun")
    end
end

local techIdToMaterialOffset = GetUpValue( GetMaterialXYOffset, "kTechIdToMaterialOffset" )
if false and techIdToMaterialOffset then
	techIdToMaterialOffset[kTechId.HeavyMachineGun] = 73
	techIdToMaterialOffset[kTechId.Electrify] = 3
end
