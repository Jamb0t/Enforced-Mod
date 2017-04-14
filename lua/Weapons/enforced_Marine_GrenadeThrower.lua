kMaxHandGrenades = 2

local networkVars =
{
    grenadesLeft = "integer (0 to ".. kMaxHandGrenades ..")",
}

Shared.LinkClassToMap("GrenadeThrower", GrenadeThrower.kMapName, networkVars)