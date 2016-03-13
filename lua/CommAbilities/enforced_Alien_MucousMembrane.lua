MucousMembrane.kLifeSpan = 10
MucousMembrane.kThinkTime = 0.1
MucousMembrane.kArmorHealPercentagePerSecond = 24

if Server then

    local function GetEntityRecentlyHealed(entityId, time)
        for index, pair in ipairs(gHealedByMucousMembrane) do
            if pair[1] == entityId and pair[2] > Shared.GetTime() - MucousMembrane.kThinkTime then
                return true
            end
        end
        
        return false
    end

    local function SetEntityRecentlyHealed(entityId)
        for index, pair in ipairs(gHealedByMucousMembrane) do
            if pair[1] == entityId then
                table.remove(gHealedByMucousMembrane, index)
            end
        end
        
        table.insert(gHealedByMucousMembrane, {entityId, Shared.GetTime()})
    end


	local orig_MucousMembrane_Perform 
	orig_MucousMembrane_Perform = Class_ReplaceMethod( "MucousMembrane", "Perform", 
    function (self)
        for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), MucousMembrane.kRadius)) do

            if not GetEntityRecentlyHealed(unit:GetId()) then

                local addArmor = math.max(1, unit:GetMaxArmor() * MucousMembrane.kThinkTime / MucousMembrane.kArmorHealPercentagePerSecond)
                --Log("%s healarmor %s", ToString(unit), ToString(addArmor))
                unit:SetArmor(unit:GetArmor() + addArmor)
                SetEntityRecentlyHealed(unit:GetId())

            end
            
        end
    end)

end
