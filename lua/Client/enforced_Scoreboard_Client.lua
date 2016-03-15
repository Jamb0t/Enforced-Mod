
kElixerVersion = 1.8
Script.Load("lua/Elixer_Utility.lua")
Elixer.UseVersion( kElixerVersion )

--
local statusTranslationStringMap = GetUpValue( Scoreboard_ReloadPlayerData, "kStatusTranslationStringMap", { LocateRecurse = true } )
if statusTranslationStringMap then
	statusTranslationStringMap[kPlayerStatus.HeavyMachineGun] = "HMG"
end
