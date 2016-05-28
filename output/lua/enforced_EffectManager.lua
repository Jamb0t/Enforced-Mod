
local function ReplaceMethodInDerivedClasses(className, methodName, method, original)

	if _G[className][methodName] ~= original then
		return
	end

	_G[className][methodName] = method

	local classes = Script.GetDerivedClasses(className)
	assert(classes ~= nil)

	for i, c in ipairs(classes) do
		ReplaceMethodInDerivedClasses(c, methodName, method, original)
	end

end

function Class_ReplaceMethod(className, methodName, method)

	local original = _G[className][methodName]
	assert(original ~= nil)

	ReplaceMethodInDerivedClasses(className, methodName, method, original)
	return original

end

function ReplaceLocals(originalFunction, replacedLocals)

    local numReplaced = 0
    for name, value in pairs(replacedLocals) do

        local index = 1
        local foundIndex = nil
        while true do

            local n, v = debug.getupvalue(originalFunction, index)
            if not n then
                break
            end

            -- Find the highest index matching the name.
            if n == name then
                foundIndex = index
            end

            index = index + 1

        end

        if foundIndex then

            debug.setupvalue(originalFunction, foundIndex, value)
            numReplaced = numReplaced + 1

        end

    end

    return numReplaced

end

local napalmCinematic = {parented_cinematic = "cinematics/marine/grenades/napalm_explo.cinematic"}
local napalmSound = {sound = "sound/NS2.fev/marine/grenades/gas/explode"}

local original_EffectManager_AddEffectData
original_EffectManager_AddEffectData = Class_ReplaceMethod("EffectManager", "AddEffectData",
function(self, identifier, data)
    if (identifier == "DamageEffects") then
        if (data and not data.release_napalm) then
            local effects = { }
            table.insert(effects, napalmCinematic)
            table.insert(effects, napalmSound)

            local release_napalm = { }
            release_napalm["releaseNapalmEffects"] = effects

            data["release_napalm"] = release_napalm
        end
    end

    original_EffectManager_AddEffectData(self, identifier, data)
end
)
