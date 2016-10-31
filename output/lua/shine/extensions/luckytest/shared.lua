Script.Load("lua/Test/enforced_MoveServer.lua")

--It is the job of shared.lua to create the plugin table.
local Plugin = {}

local Shine = Shine
local SetupClassHook = Shine.Hook.SetupClassHook
local SetupGlobalHook = Shine.Hook.SetupGlobalHook

--This will setup a datatable for the plugin, which is a table of networked values.
function Plugin:SetupDataTable()
  --self:AddDTVar( "boolean", "Enabled", false )

	--This adds a boolean value, indexed as "Bool", with default value true.
	--self:AddDTVar( "boolean", "Bool", true )
	--This adds an integer value, clamped between 0 and 10, indexed as "Int" and with default value 4.
	--self:AddDTVar( "integer (0 to 10)", "Int", 4 )
end

--This is called when any datatable variable changes.
function Plugin:NetworkUpdate( Key, Old, New )
	if Server then return end
	
	--Key is the variable name, Old and New are the old and new values of the variable.
	--Print( "%s has changed from %s to %s.", Key, tostring( Old ), tostring( New ) )
end

--This table will be passed into server.lua and client.lua as the global value "Plugin".
Shine:RegisterExtension("luckytest", Plugin)
