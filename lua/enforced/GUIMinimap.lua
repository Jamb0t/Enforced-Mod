kElixerVersion = 1.8
Script.Load("lua/Enforced/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion ) 

local orig_GUIMinimap_Initialize
orig_GUIMinimap_Initialize = Class_ReplaceMethod( "GUIMinimap", "Initialize", 
	function (self)
		self.highlightWorldColor = Color(0, 0.8, 0, 1)
	
		for i, table in ipairs(self.blipColorTable) do
			if i == kBlipColorType.HighlightWorld then
				self.blipColorTable[i] = self.highlightWorldColor
			end
		end
	end
)
