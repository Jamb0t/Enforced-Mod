if Server then

local function fakeSpewBile( self )
	return false
end

ReplaceLocals( Contamination.OnInitialized, { SpewBile = fakeSpewBile } )

end
