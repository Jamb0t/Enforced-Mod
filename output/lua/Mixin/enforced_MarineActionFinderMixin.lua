local kFindWeaponRange = 2

local function SortByValue(item1, item2)

    local cost1 = HasMixin(item1, "Tech") and LookupTechData(item1:GetTechId(), kTechDataCostKey, 0) or 0
    local cost2 = HasMixin(item2, "Tech") and LookupTechData(item2:GetTechId(), kTechDataCostKey, 0) or 0

    return cost1 < cost2

end

local function LegacyFindNearbyWeapon(self, toPosition)

    local nearbyWeapons = GetEntitiesWithMixinWithinRange("Pickupable", toPosition, kFindWeaponRange)
    table.sort(nearbyWeapons, SortByValue)

    local closestWeapon = nil
    local closestDistance = Math.infinity
    local cost = 0

    for i, nearbyWeapon in ipairs(nearbyWeapons) do

        if nearbyWeapon:isa("Weapon") and nearbyWeapon:GetIsValidRecipient(self) then

            local nearbyWeaponDistance = (nearbyWeapon:GetOrigin() - toPosition):GetLengthSquared()
            local currentCost = HasMixin(nearbyWeapon, "Tech") and LookupTechData(nearbyWeapon:GetTechId(), kTechDataCostKey, 0) or 0

            if currentCost < cost then
                break

            else

                closestWeapon = nearbyWeapon
                closestDistance = nearbyWeaponDistance
                cost = currentCost

            end

        end

    end

    return closestWeapon

end


function MarineActionFinderMixin:FindNearbyAutoPickupWeapon()
	return LegacyFindNearbyWeapon(self, self:GetOrigin())
end

function MarineActionFinderMixin:GetNearbyPickupableWeapon()
	return LegacyFindNearbyWeapon(self, self:GetOrigin())
end
