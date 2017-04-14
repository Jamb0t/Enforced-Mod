
-- Class_ReplaceMethod asserts for some reason, so just override this guy
function LiveMixin:ClampHealing(healAmount, excludeArmor)
    return healAmount
end
