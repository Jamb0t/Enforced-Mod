local orig_PrototypeLab_GetTechButtons
orig_PrototypeLab_GetTechButtons = Class_ReplaceMethod( "PrototypeLab", "GetTechButtons",
function(self, techId)
    return { kTechId.JetpackTech, kTechId.None, kTechId.None, kTechId.None,
             kTechId.ExosuitTech, kTechId.DualMinigunTech, kTechId.NanoArmor, kTechId.None }
end
)