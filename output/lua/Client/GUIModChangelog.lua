class 'GUIModChangelog' (Window)

local kTextureName = "*changelog_webpage_render"
GUIModChangelog.URL = "https://www.luckyfkers.com/enforced-ingame/"
GUIModChangelog.titleText = "Welcome to LuckyFkers Server"

function GUIModChangelog:Initialize()
	Window.Initialize(self)

	self:SetWindowName("Changelog")
	self:SetIsVisible(false)
	self:DisableResizeTile()
	self:DisableSlideBar()
	self:DisableContentBox()
	self:SetLayer(kGUILayerMainMenuDialogs)

	self:AddEventCallbacks{
		OnEscape = function(self)
			self:SetIsVisible(false)
			GetGUIMainMenu():MaybeOpenPopup()
		end
	}

	-- Hook the close...
	self.titleBar.closeButton:AddEventCallbacks( {
		OnClick = function(self)
			if self.windowHandle then
				self.windowHandle:SetIsVisible(false)
				GetGUIMainMenu():MaybeOpenPopup()
			end
		end
	} )


	self.title = CreateMenuElement(self:GetTitleBar(), "Font")
	self.title:SetText(self.titleText)
	self.title:SetCSSClass("title")

	self.webContainer = CreateMenuElement(self, "Image")
	self.webContainer:SetBackgroundTexture(kTextureName)
	self.webContainer:SetCSSClass("web")

	self.webContainer.webView = Client.CreateWebView(self.webContainer:GetWidth(), self.webContainer:GetHeight())
	self.webContainer.webView:SetTargetTexture(kTextureName)
	self.webContainer.webView:LoadUrl(self.URL)
	self.webContainer.webView:SetGreenScreen(true)

	self.webContainer:AddEventCallbacks{
		OnMouseIn = function(self)
			local windowManager = GetWindowManager()
			windowManager:HandleFocusBlur(windowManager:GetActiveWindow(), self)
		end,
		OnMouseOut = function(self)
			GetWindowManager():ClearActiveElement(self)
		end,
		OnMouseOver = function(self)
			local mouseX, mouseY = Client.GetCursorPosScreen()
			local _, withinX, withinY = GUIItemContainsPoint(self:GetBackground(), mouseX, mouseY)
			self.webView:OnMouseMove(withinX, withinY)
		end,
		OnMouseUp = function(self)
			self.webView:OnMouseUp(0)
		end,
		OnMouseDown = function(self)
			self.webView:OnMouseDown(0)
		end,
		OnMouseWheel = function(self, up)
			if up then
				self.webView:OnMouseWheel(30, 0)
				MainMenu_OnSlide()
			else
				self.webView:OnMouseWheel(-30, 0)
				MainMenu_OnSlide()
			end
		end
	}

	self.footer = CreateMenuElement(self, "Image")
	self.footer:SetCSSClass("footer")
end

function GUIModChangelog:OnEscape()
	self:SetIsVisible(false)
end

function GUIModChangelog:GetTagName()
	return "changelog"
end