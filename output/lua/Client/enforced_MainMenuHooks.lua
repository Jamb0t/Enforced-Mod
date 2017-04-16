local loaded = false
local changeLog = nil
local oldMainMenu_Open = MainMenu_Open
function MainMenu_Open()
	if not loaded then
		Script.Load("lua/Class.lua")
		Script.Load("lua/Client/GUI/enforced_GUIModChangelog.lua")
		loaded = true
	end

	oldMainMenu_Open()

	if not changeLog then
		local mm = GetGUIMainMenu and GetGUIMainMenu()
		if mm then
			changeLog = CreateMenuElement(mm.mainWindow, "GUIModChangelog")

			-- when main window appears, show changelog if in game
			local eventCallbacks =
			{
				OnShow = function (self)
					changeLog:SetIsVisible(MainMenu_IsInGame())
				end,
			}
			mm.mainWindow:AddEventCallbacks(eventCallbacks)
		end

		-- show initially only if in game
		if MainMenu_IsInGame() then
			changeLog:SetIsVisible(true)
		end
	end
end