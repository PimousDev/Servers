SandboxVars = {
    VERSION = 4,
    Zombies = 4, -- Zombie spawn rate. 1 is most, 5 is none
    Distribution = 1, -- 1 is urban, 2 is uniform
    DayLength = 3, -- 1 is 15 minutes, 2 is 30 minutes, 3 is 1 hour, 4 is 2 hours, 5 is 3 hours, 6 is 4 hours, 7 is 5 hours, 8 is 12 hours, 9 is real-time
    StartYear = 1, -- 1 is the 1st year etc
    StartMonth = 4, -- 1 is Jan, 12 is Dec
    StartDay = 1, -- 1 is the 1st of the month etc
    StartTime = 2, -- 1 is 7AM, 2 is 9AM, 3 is 12PM, 4 is 2PM, 5 is 5PM, 6 is 9PM, 7 is 12AM, 8 is 2AM, 9 is 5AM
    WaterShut = 2,
    ElecShut = 2,
    WaterShutModifier = 500, -- the number of days before water is shut off. -1 is instant
    ElecShutModifier = 480, -- the number of days before electricity is shut off. -1 is instant
    FoodLoot = 4, -- 1 is extremely rare, 5 is abundant
    WeaponLoot = 2, -- 1 is extremely rare, 5 is abundant
    OtherLoot = 3, -- 1 is extremely rare, 5 is abundant
    Temperature = 3, -- 1 is very cold, 5 is very hot
    Rain = 3, -- 1 is very dry, 5 is is very rainy
    ErosionSpeed = 5, -- 1 is very fast (20 days), 5 is very slow (500 days)
    XpMultiplier = 15.0,
    Farming = 1, -- 1 is vey fast, 5 is very slow
    StatsDecrease = 4, -- 1 is very fast, 5 is very slow
    NatureAbundance = 3, -- 1 is very poor, 5 is very abundant
    Alarm = 6, -- 1 is never, 6 is very often
    LockedHouses = 6, -- 1 is never, 6 is very often
    StarterKit = false,
    Nutrition = false,
    FoodRotSpeed = 5, -- 1 is very fast, 5 is very slow
    FridgeFactor = 5, -- 1 is very low, 5 is very high
    LootRespawn = 2, -- 1 is none, 2 is every day, 3 is every week, 4 is every month, 5 is every two months
    TimeSinceApo = 1,
    PlantResilience = 3, -- Plants resilience against disease/weather. 1 is very low, 5 is very high
    PlantAbundance = 3, -- How much farm plants produce. 1 is very poor, 5 is very abundant
    EndRegen = 3, -- Endurance regeneration (how fast you regain endurance). 1 is very fast, 5 is very slow
    ZombieLore = {
        Speed = 3, -- 1 is sprinters (fastest), 2 is fast shamblers, 3 is shamblers (slowest)
        Strength = 3, -- 1 is superhuman, 2 is normal, 3 is weak
        Toughness = 3, -- 1 is tough, 2 is normal, 3 is fragile
        Transmission = 1, -- 1 is blood/saliva, 2 is saliva only, 3 is everyone is infected, 4 is no transmission
        Mortality = 6, -- This governs how deadly infection is. 1 is instant, 6 is 1 to 2 weeks
        Reanimate = 0, -- How fast zombies come back to life...again. 1 is instant, 6 is 1 to 2 weeks
        Cognition = 3, -- How smart zombies are. 1 is Navigate/Use Doors, 3 is basic navigation only
        Memory = 2, -- How much zombies will remember. 1 is long, 4 is none
        Decomp = 1, -- 1 is slows/weakens them, 4 is no effect
        Sight = 2, -- How well zombies can see. 1 is eagle-eyed, 3 is poor
        Hearing = 2, -- How well zombies can hear. 1 is pinpoint, 3 is poor
        Smell = 2, -- How well zombies can smell. 1 is bloodhound, 3 is poor
        ThumpNoChasing = true,
        ThumpOnConstruction = true,
        ActiveOnly = 1,
        TriggerHouseAlarm = false,
        ZombiesDragDown = true,
        ZombiesFenceLunge = true,
    },
    ZombieConfig = {
        PopulationMultiplier = 1.0, -- Zombie spawn rate. 4.0 = Insane, 2.0 = High, 1.0 = Normal, 0.35 = Low, 0.0 = None. Minimum = 0.0 Maximum = 4.0 Default = 1.0
        PopulationStartMultiplier = 1.0, -- Adjusts the desired population at the start of the game. Minimum = 0.0 Maximum = 4.0 Default = 1.0
        PopulationPeakMultiplier = 1.5, -- Adjusts the desired population on the peak day. Minimum = 0.0 Maximum = 4.0 Default = 1.5
        PopulationPeakDay = 28, -- The day when the population reaches it's peak. Minimum = 1 Maximum = 365 Default = 28
        RespawnHours = 0.0, -- The number of hours that must pass before zombies may respawn in a cell. If 0, spawning is disabled. Minimum = 0.0 Maximum = 8760.0 Default = 72.0. Dev post for 32.17 update
        RespawnUnseenHours = 16.0, -- The number of hours that a chunk must be unseen before zombies may respawn in it. Minimum = 0.0 Maximum = 8760.0 Default = 16.0
        RespawnMultiplier = 0.0, -- The fraction of a cell's desired population that may respawn every RespawnHours. Minimum = 0.0 Maximum = 1.0 Default = 0.1
        RedistributeHours = 12.0, -- The number of hours that must pass before zombies migrate to empty parts of the same cell. Minimum = 0.0 Maximum = 8760.0 Default = 12.0
        FollowSoundDistance = 100, -- The distance a virtual zombie will try to walk towards the last sound it heard. Minimum = 10 Maximum = 1000 Default = 100
        RallyGroupSize = 20, -- The size of groups real zombies form when idle. 0 means zombies don't form groups. Groups don't form inside buildings or forest zones. Minimum = 0 Maximum = 1000 Default = 20
        RallyTravelDistance = 20, -- The distance real zombies travel to form groups when idle. Minimum = 5 Maximum = 50 Default = 20
        RallyGroupSeparation = 15, -- The distance between zombie groups. Minimum=  5 Maximum = 25 Default = 15
        RallyGroupRadius = 3, -- How close members of a group stay to the group's leader. Minimum = 1 Maximum = 10 Default = 3
    }
}