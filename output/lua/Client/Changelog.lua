Script.Load("lua/Client/GUIModChangelog.lua")

local function showchangelog()
	MainMenu_Open()
	local mm = GetGUIMainMenu and GetGUIMainMenu()
	if mm then
		local changelog = CreateMenuElement(mm.mainWindow, "GUIModChangelog")
	end
end

	--[[local function onLoadComplete()
			showchangelog()
	end]]

--Event.Hook("LoadComplete", onLoadComplete)
Event.Hook("Console_changelog", showchangelog)