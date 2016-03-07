kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local function NewGetIsEquipment(techId)

    return techId == kTechId.DropWelder or techId == kTechId.DropMines or techId == kTechId.DropShotgun or techId == kTechId.DropGrenadeLauncher or
           techId == kTechId.DropFlamethrower or techId == kTechId.DropJetpack or techId == kTechId.DropExosuit or techId == kTechId.HeavyMachineGun

end

ReplaceUpValue( MarineCommander.ProcessTechTreeActionForEntity, "GetIsEquipment", NewGetIsEquipment, { LocateRecurse = true; CopyUpValues = true; } )
