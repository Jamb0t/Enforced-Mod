
kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

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
            kTechId.HeavyMachineGun,
            kTechId.ClusterGrenade,
            kTechId.NapalmGrenade,
            kTechId.PulseGrenade,
        }
    end
    return itemList
end
)
