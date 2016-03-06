
local orig_Armory_GetItemList = Armory.GetItemList
function Armory:GetItemList(forPlayer)

    local itemList = {   
        kTechId.LayMines, 
        kTechId.Shotgun,
        kTechId.Welder,
        kTechId.ClusterGrenade,
        kTechId.GasGrenade,
        kTechId.PulseGrenade
    }
    
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