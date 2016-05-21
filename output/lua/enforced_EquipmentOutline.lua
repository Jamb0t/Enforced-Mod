
local equipmentOutlineModelLookup = GetUpValue( EquipmentOutline_UpdateModel, "lookup" )
if equipmentOutlineModelLookup then
    table.insert(equipmentOutlineModelLookup, "HeavyMachineGun")
end
