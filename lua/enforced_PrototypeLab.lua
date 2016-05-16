
local orig_PrototypeLab_GetTechButtons
orig_PrototypeLab_GetTechButtons = Class_ReplaceMethod( "PrototypeLab", "GetTechButtons",
function(self, techId)
    return { kTechId.JetpackTech, kTechId.None, kTechId.None, kTechId.None,
             kTechId.ExosuitTech, kTechId.DualMinigunTech, kTechId.None, kTechId.None }
end
)


local orig_PrototypeLab_GetItemList
orig_Extractor_OnCreate = Class_ReplaceMethod( "PrototypeLab", "GetItemList",
function(self, forPlayer)
    if forPlayer:isa("Exo") then
        if forPlayer:GetHasDualGuns() then
            return {}
        elseif forPlayer:GetHasRailgun() then
            return { kTechId.UpgradeToDualRailgun }
        elseif forPlayer:GetHasMinigun() then
            return { kTechId.UpgradeToDualMinigun }
        end
    end

    return { kTechId.Jetpack, kTechId.Exosuit, kTechId.ClawRailgunExosuit,
             kTechId.DualMinigunExosuit, kTechId.DualRailgunExosuit, }
end
)
