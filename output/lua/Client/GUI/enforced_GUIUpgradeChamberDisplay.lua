local IndexToUpgrades =
{
    { kTechId.Shell, kTechId.Carapace, kTechId.Regeneration },
    { kTechId.Spur, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Veil, kTechId.Phantom, kTechId.Aura },
}

ReplaceLocals(GUIUpgradeChamberDisplay.Update, { kIndexToUpgrades = IndexToUpgrades })
