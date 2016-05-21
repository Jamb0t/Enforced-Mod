local orig_TeamInfo_OnCreate
orig_TeamInfo_OnCreate = Class_ReplaceMethod( "TeamInfo", "OnCreate",
function(self)

    local hasElectrify = table.contains(TeamInfo.kRelevantTechIdsMarine, kTechId.ElectrifyTech)
    if not hasElectrify then
        table.insert(TeamInfo.kRelevantTechIdsMarine, kTechId.ElectrifyTech)
    end

    orig_TeamInfo_OnCreate(self)
end
)