Script.Load("lua/GUIMinimap.lua")

local blipColorType = GetUpValue( GUIMinimap.Initialize, "kBlipColorType", { LocateRecurse = true } )
local highlightWorldId = blipColorType['HighlightWorld']

local orig_GUIMinimap_Initialize
orig_GUIMinimap_Initialize = Class_ReplaceMethod( "GUIMinimap", "Initialize", 
function (self)
    orig_GUIMinimap_Initialize(self)

    if self.highlightWorldColor then
        self.highlightWorldColor = Color(0, 0.8, 0, 1)
    end
    
    if self.blipColorTable then
        for i, table in pairs(self.blipColorTable) do
            if table and table[highlightWorldId] then
                table[highlightWorldId] = self.highlightWorldColor
            end
        end
    end
end
)
