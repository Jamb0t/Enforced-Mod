
local original_Armory_GetItemList
original_Armory_GetItemList = Class_ReplaceMethod( "Armory", "GetItemList",
function(self)
    local itemList = original_Armory_GetItemList(self)
    if self:GetTechId() == kTechId.AdvancedArmory then
        itemList = {
            kTechId.Welder,
            kTechId.LayMines,
            kTechId.Shotgun,
            kTechId.GrenadeLauncher,
            kTechId.Flamethrower,
            kTechId.ClusterGrenade,
            kTechId.NapalmGrenade,
            kTechId.PulseGrenade,
        }
    end
    return itemList
end
)

local original_Armory_GetTechButtons
original_Armory_GetTechButtons = Class_ReplaceMethod( "Armory", "GetTechButtons",
function (self)
    -- Show button to upgraded to advanced armory
    if self:GetTechId() == kTechId.Armory and self:GetResearchingId() ~= kTechId.AdvancedArmoryUpgrade then
        techButtons[kMarineUpgradeButtonIndex] = kTechId.AdvancedArmoryUpgrade
    end
	
end)
