Script.Load("lua/ModularExo_Shared.lua")
Script.Load("lua/AlienTechMap.lua")

kAlienTechMap =
{
                    { kTechId.Whip, 5.5, 0.5 },          { kTechId.Shift, 6.5, 0.5 },          { kTechId.Shade, 7.5, 0.5 }, { kTechId.Crag, 8.5, 0.5 }, 
                    
                    { kTechId.Harvester, 4, 1.5 },                           { kTechId.Hive, 7, 1.5 },                         { kTechId.UpgradeGorge, 10, 1.5 }, 
  
                   { kTechId.CragHive, 4, 3 },                               { kTechId.ShadeHive, 7, 3 },                            { kTechId.ShiftHive, 10, 3 },
              { kTechId.Shell, 4, 4, SetShellIcon },                     { kTechId.Veil, 7, 4, SetVeilIcon },                    { kTechId.Spur, 10, 4, SetSpurIcon },
  { kTechId.Carapace, 3.5, 5 },{ kTechId.Regeneration, 4.5, 5 }, { kTechId.Phantom, 6.5, 5 },{ kTechId.Aura, 7.5, 5 },{ kTechId.Celerity, 9.5, 5 },{ kTechId.Adrenaline, 10.5, 5 },
  
  { kTechId.BioMassOne, 3, 7, nil, "1" }, { kTechId.BabblerEgg, 3, 8 },
  
  { kTechId.BioMassTwo, 4, 7, nil, "2" }, {kTechId.Rupture, 4, 8},
  
  { kTechId.BioMassThree, 5, 7, nil, "3" }, {kTechId.BoneWall, 5, 8}, {kTechId.BileBomb, 5, 9}, { kTechId.MetabolizeEnergy, 5, 10 },

  { kTechId.BioMassFour, 6, 7, nil, "4" }, {kTechId.Leap, 6, 8}, {kTechId.Umbra, 6, 9},
  
  { kTechId.BioMassFive, 7, 7, nil, "5" },  {kTechId.WebTech, 7, 8}, {kTechId.BoneShield, 7, 9}, {kTechId.MetabolizeHealth, 7, 10},
  
  { kTechId.BioMassSix, 8, 7, nil, "6" },  {kTechId.Spores, 8, 8},
  
  { kTechId.BioMassSeven, 9, 7, nil, "7" }, {kTechId.Stab, 9, 8},
  
  { kTechId.BioMassEight, 10, 7, nil, "8" },  {kTechId.Stomp, 10, 8}, {kTechId.Doomsday, 10, 9}, 
  
  { kTechId.BioMassNine, 11, 7, nil, "9" }, {kTechId.Contamination, 11, 8}, {kTechId.Xenocide, 11, 9},

}

kAlienLines = 
{
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Crag),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shift),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shade),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Whip),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Harvester, kTechId.Hive),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.UpgradeGorge),
    { 7, 1.5, 7, 2.5 },
    { 4, 2.5, 10, 2.5},
    { 4, 2.5, 4, 3},{ 7, 2.5, 7, 3},{ 10, 2.5, 10, 3},
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Shell),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Veil),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Spur),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Carapace),GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Regeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Phantom),GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Aura),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Celerity),GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Adrenaline),

}

local kGrenades =
{
    kTechId.ClusterGrenade,
    kTechId.GasGrenade,
    kTechId.NapalmGrenade,
    kTechId.PulseGrenade
}


-- Same as ns2, but use a different "kGrenades" table instead
function PlayerUI_GetHasItem(techId)
    local hasItem = false
    local isaGrenade = table.contains(kGrenades, techId)

    if techId and techId ~= kTechId.None then

       local player = Client.GetLocalPlayer()
        if player then

	   local items = GetChildEntities(player, "ScriptActor")

	   for index, item in ipairs(items) do

	      if item:GetTechId() == techId then

                    hasItem = true
                    break

	      elseif isaGrenade and table.contains(kGrenades, item:GetTechId()) then

                    hasItem = true
                    break

                end

            end

        end

    end

    return hasItem
end

local oldPlayerUI_GetCrosshairY = PlayerUI_GetCrosshairY
function PlayerUI_GetCrosshairY()
	local player = Client.GetLocalPlayer()
    if(player and not player:GetIsThirdPerson()) then  
        local weapon = player:GetActiveWeapon()
        if weapon ~= nil and weapon:GetMapName() == HeavyMachineGun.kMapName then
			return 0 * 64
		end
	end
	return oldPlayerUI_GetCrosshairY()
end

local oldOnCommandScores = OnCommandScores
function OnCommandScores(scoreTable)

    local status = kPlayerStatus[scoreTable.status]
    if scoreTable.status == kPlayerStatus.HeavyMachineGun then
        status = "HMG"
		
		 Scoreboard_SetPlayerData(scoreTable.clientId, scoreTable.entityId, scoreTable.playerName, scoreTable.teamNumber, scoreTable.score,
                             scoreTable.kills, scoreTable.deaths, math.floor(scoreTable.resources), scoreTable.isCommander, scoreTable.isRookie,
                             status, scoreTable.isSpectator, scoreTable.assists, scoreTable.clientIndex)
							 
    else
		oldOnCommandScores(scoreTable)
    end
    
end

local kStatusTranslationStringMap = GetUpValue( Scoreboard_ReloadPlayerData,   "kStatusTranslationStringMap", { LocateRecurse = true })
if kStatusTranslationStringMap then
	kStatusTranslationStringMap[kPlayerStatus.HeavyMachineGun] = "HMG"
end

local function SetupHMGOutlineColors()
	kEquipmentOutlineColor = enum { [0]='TSFBlue', 'Green', 'Fuchsia', 'Yellow', 'Red' }
	local _lookup = GetUpValue( EquipmentOutline_UpdateModel, "lookup" )
	table.insert(_lookup, "HeavyMachineGun")
	ReplaceLocals(EquipmentOutline_UpdateModel, { lookup = _lookup })
end

SetupHMGOutlineColors()

local kTechIdToMaterialOffset = GetUpValue( GetMaterialXYOffset,   "kTechIdToMaterialOffset" )
kTechIdToMaterialOffset[kTechId.HeavyMachineGun] = 73
kTechIdToMaterialOffset[kTechId.Electrify] = 3