Script.Load("lua/GUIMarineBuyMenu.lua")

function GUIMarineBuyMenu_UpdateIcons()
    local bigIconMethod = GetUpValue( GUIMarineBuyMenu._InitializeContent, "GetBigIconPixelCoords" )
    if bigIconMethod then
        -- Do this to initialize the structure so we can get the index
        bigIconMethod(kTechId.Axe)
        local bigIconIndex = GetUpValue( bigIconMethod, "gBigIconIndex" )
        if bigIconIndex then
            table.insert( bigIconIndex, kTechId.NapalmGrenade, 13 )
        end
    end

    local smallIconMethod = GetUpValue( GUIMarineBuyMenu._InitializeEquipped, "GetSmallIconPixelCoordinates" )
    if smallIconMethod then
        -- Do this to initialize the structure so we can get the index
        smallIconMethod(kTechId.Axe)
        local smallIconIndex = GetUpValue( smallIconMethod, "gSmallIconIndex" )
        if smallIconIndex then
            table.insert( smallIconIndex, kTechId.NapalmGrenade, 43 )
        end
    end
end

local orig_GUIMarineBuyMenu_Initialize
orig_GUIMarineBuyMenu_Initialize = Class_ReplaceMethod( "GUIMarineBuyMenu", "Initialize",
function (self)
    GUIMarineBuyMenu_UpdateIcons()
    orig_GUIMarineBuyMenu_Initialize(self)
end)
