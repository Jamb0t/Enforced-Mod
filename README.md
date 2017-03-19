# Ghouls Balance Mod

**SteamWorks Mod ID**: *2dd47a50*

This mod contains various prototype balance changes based on various ideas of the NS2 balance team.

Current changes:

- Marines
    - Exo
        - Decreased the pres costs of exos to 40 (from 45)
    - MG
        - Increased base damage to 8 from 6. 
        - Decreased damage bonus against players to 150% from 200%
        - Decreased costs to 20 pres.

- Aliens
    - Upgrades
        - Silence
            - Silence no longer affects any "attack" sounds
            - Requieres now a Shade Hive (instead of a Shift Hive)
            
        - Vampirism
            - Requires now a Crag Hive (instead of a Shade Hive)
            - Doesn't cloak anymore
            - Rebalanced health gain values (for each shell):
                - Skulk: 5 (from 5)
                - Gorge: 6 (from 5)
                - Lerk (Bite): 5 (from 3)
                - Lerk (Spike): 2 (from 0.66)
                - Fade: 12 (from 6.66)
                - Onos: 20 (from  13.33)
            - If Focus is selected Vampirism will heal additional 33% to compensate for the longer attack cooldowns.
        
        - Alien Regeneration
            - Alien Regeneration (both the upgrade and the natural one) doesn't restore health if you have been hurt less than 3 seconds ago.
        
        - Crush
            - Requires now a Shift Hive (instead of a Crag Hive)
            
        - Focus
            - The extra cooldown is not changing with the veil level anymore and instead static 33%.
    - Lifeforms
        - Lifeform Abilities
            - Abilities are not longer available as soon as the biomass level drops below the requierements. Previously abilities kept being unlocked as long as the player stayed alive.
        - Onos 
            - Boneshield doesn't heal armor anymore and instead grants a mucous shield of 400 hp while being used.
        - Gorge
            - Movement / Belly Slide
                - Give players more control over belly slide and make it slightly faster:
                    - Increased max belly sliding speed to 14, from 13.
                    - Decreased belly slide cooldown from 1.5 to 1 second.
                    - Reduced slide friction on infestation from 0.068 to 0.039.
                    - Reduced slide energy cost from 25 to 20.
                    - Increased belly slide control from 10 to 18.                
                    - Speed loss sliding uphill is reduced by 25%.
                - Decreased the air friction from 0.8 to 0.2 so the Gorge doesn't move like a brick while jumping.
            - Bilebomb
                - Decreased the tickrate of the bile damge to 2/sec (from 2.5/sec) and lowered the damge that way to 110/sec (from 137.5/sec)
    - PvE
        - Alien Structures
            -  Increased the alien structures autogrowth to 50% (form 33%) of their normal (with drifter) growth rate.
        
        - Hive
            - Added a Biomasss 3 reserach tech
                - Costs 60 tres and takes 60 sec to research
                - It's only avalaible at the first hive of the alien team
            - Spore Research
                - Increased biomass requierement to 5 (from 4)
            - Alien Egg Spawn
                - Every hive spawns an egg every 13¹ secs instead of only at one hive each time.
                    - ¹ Scales down with the team's playercount:
                        - 6 players: 13
                        - 9 players: 8.6
                        - 10 players: 9.75
                        - 12 players: 7.5
                - Every hive can spawn up to 2² eggs (was 3²).
                - The hive's egg hatch tech spawns 2² eggs (was 2)
                    - ² Scales up with the team's playercount:
                        - 6 players: 2
                        - 9 players: 3
                        - 10 players: 3
                        - 12 players: 4
        - Harvester
            - Decreased growth time to 28 secs (from 38 secs)
        - Cyst
            - Increase maturity time to 120 seconds (from 45)            
        
        - Drifter 
            - Added passive abilities for each hive type:
                - Camouflage (Shade Hive): Drifters turn invisble when they idle.
                - Regeneration (Crag Hive): Drifter regenerate 3% of their hp every 2 secs while being hurt.
                - Celerity (Shift Hive): Drifters move 18% faster.                
        - Contamination
            - Disables bile bombs when the Contamination is set on fire.

Code @ Github: https://github.com/GhoulofGSG9/Ghouls-Balance-Mod

Feel free to leave feedback ;)
