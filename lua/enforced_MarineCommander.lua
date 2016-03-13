Script.Load("lua/Class.lua")

kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

local buttonTable = GetUpValue( MarineCommander.GetButtonTable, "gMarineMenuButtons", { LocateRecurse = true } )
local function UpdateButtonTable()
    if buttonTable and buttonTable[kTechId.WeaponsMenu] then
        local weaponsMenu = buttonTable[kTechId.WeaponsMenu]
        if weaponsMenu[7] ~= kTechId.HeavyMachineGun then
            weaponsMenu[7] = kTechId.HeavyMachineGun
        end   
    end
end

UpdateButtonTable()

if Server then
    local oldGetIsEquipment = GetUpValue( MarineCommander.ProcessTechTreeActionForEntity, "GetIsEquipment", { LocateRecurse = true } )
    local function NewGetIsEquipment(techId)
        if techId == kTechId.HeavyMachineGun then
            return true
        end
        return oldGetIsEquipment(techId)
    end

    ReplaceUpValue( MarineCommander.ProcessTechTreeActionForEntity, "GetIsEquipment", NewGetIsEquipment, { LocateRecurse = true; CopyUpValues = true; } )
end
