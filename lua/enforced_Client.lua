
local function OnLoadComplete()
    if Client then
	    Script.Load("lua/Client/GUI/enforced_GUI.lua")
	end
end

Event.Hook("LoadComplete", OnLoadComplete)
