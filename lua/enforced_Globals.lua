--Script.Load("lua/Class.lua")

kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

local newStatus = {
    'HeavyMachineGun'
}

local haveHMG = rawget( kPlayerStatus, newStatus[1] )
if not haveHMG then
    for k,v in ipairs(newStatus) do
        AppendToEnum( kPlayerStatus, v )
    end
end
