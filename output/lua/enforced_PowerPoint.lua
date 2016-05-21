
local original_PowerPoint_CanBeCompletedByScriptActor
original_PowerPoint_CanBeCompletedByScriptActor = Class_ReplaceMethod( "PowerPoint", "CanBeCompletedByScriptActor",
function ( self, player )
	if player:isa("MAC") or player:isa("Marine") then
		return true
	end
	return original_PowerPoint_CanBeCompletedByScriptActor(self, player)
end
)
