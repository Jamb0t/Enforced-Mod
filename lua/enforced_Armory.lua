Script.Load("lua/Class.lua")

kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

local original_Armory_GetItemList
original_Armory_GetItemList = Class_ReplaceMethod( "Armory", "GetItemList",
function(self)
    local itemList = original_Armory_GetItemList(self)
    if self:GetTechId() == kTechId.AdvancedArmory then
        itemList = {
            kTechId.LayMines,
            kTechId.Shotgun,
            kTechId.Welder,
            kTechId.ClusterGrenade,
            kTechId.NapalmGrenade,
            kTechId.PulseGrenade,
            kTechId.GrenadeLauncher,
            kTechId.Flamethrower,
        }
    end
    return itemList
end
)
