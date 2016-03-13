Script.Load("lua/Class.lua")

kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

-- New techIds go here
local newTechIds = {
    'Electrify',
    'HeavyMachineGun',
    'NapalmGrenade',
    'NapalmGrenadeProjectile',
    'Doomsday',
}

 -- Figure out how many more tech we can add by:
 --
 --  1. Cache old max
 --  2. Calculate how many values remain by the maximum number of bits being used
 --     e.g.
 --     if current kTechIdMax = 500, then
 --     total bits = log base 2 ( 500 ) = 8.966 => 9 bits
 --     new max = 2^9 = 512
 --
 
local oldkTechIdMax = kTechIdMax
kTechIdMax = math.pow(2, math.ceil( math.log( #kTechId ) / math.log( 2 ) ) ) - 1

-- Adds all of the techIds in a group to the techIds
local function AppendListToEnum( target, newTech, limit )
    local max = tonumber(target.Max)
    local count = #newTech
    local last = max + count
    
    assert(last < limit)

    rawset( target, 'Max', last )
    rawset( target, last, 'Max' )

    for i, v in ipairs(newTech) do
        local idx = max + i - 1
        rawset( target, v, idx )
        rawset( target, idx, v )
    end
end

local techIdPosition = GetUpValue(GetTexCoordsForTechId, "gTechIdPosition")
local firstTech = rawget( kTechId, newTechIds[1] )
if firstTech == nil then
    if kTechId then
        AppendListToEnum( kTechId, newTechIds, kTechIdMax )
    end
    
    -- Add napalm and hmg icons
    if techIdPosition then
        techIdPosition[kTechId.NapalmGrenade] = kDeathMessageIcon.GasGrenade
        techIdPosition[kTechId.HeavyMachineGun] = kDeathMessageIcon.Rifle
    end
end
