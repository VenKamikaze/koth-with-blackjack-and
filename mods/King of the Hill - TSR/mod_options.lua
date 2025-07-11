options =
{
	{
		default 	= 1,
		label 		= "Koth: Type",
		help 		= "Whether or not a map-specific hill or a custom hill is used. If there is no map-specific hill defined, the custom settings will be used.",
		key 		= 'KingOfTheHillHillType',
		pref	 	= 'KingOfTheHillHillType',
		values 		= {
			{ 
                text = "Map specific hill", 
                help = "Use a map-specific hill set by the mod if available.", 
                key = 1, 
            },		
			{ 
                text = "Custom hill", 
                help = "Use the options below for a custom hill.", 
                key = 2, 
            },	
		},	
    },

    {
		default 	= 2,
		label 		= "Koth: Radius",
		help 		= "Defines the size of the hill.",
		key 		= 'KingOfTheHillHillSize',
		pref	 	= 'KingOfTheHillHillSize',
		values 		= {
			{ 
                text = "Small", 
                help = "The hill will be relatively small for the size of the map.", 
                key = 1, 
            },	
			{ 
                text = "Normal", 
                help = "The hill will be the expected size for the given map.", 
                key = 2, 
            },	
			{ 
                text = "Large", 
                help = "The hill will be relatively large for the size of the map.", 
                key = 3, 
            },
		},	
    },

    {
		default 	= 2,
		label 		= "Koth: Delay",
		help 		= "Defines how long it takes for the hill to become active.",
		key 		= 'KingOfTheHillHillDelay',
		pref	 	= 'KingOfTheHillHillDelay',
		values 		= {
			{ 
                text = "Four minutes", 
                help = "The hill will be active after four minutes.", 
                key = 1, 
            },	
			{ 
                text = "Six minutes", 
                help = "The hill will be active after six minutes.", 
                key = 2, 
            },	
			{ 
                text = "Eight minutes", 
                help = "The hill will be active after eight minutes.", 
                key = 3, 
            },
            { 
                text = "Ten minutes", 
                help = "The hill will be active after ten minutes.", 
                key = 3, 
            },
		},	
    },

    {
		default 	= 1,
		label 		= "Koth: Center",
		help 		= "Defines where the hill will be located.",
		key 		= 'KingOfTheHillHillCenter',
		pref	 	= 'KingOfTheHillHillCenter',
		values 		= {
			{ 
                text = "Center of the map", 
                help = "The hill will be located in the center of the map.", 
                key = 1, 
            },	
			{ 
                text = "Center of all spawns", 
                help = "The hill will be located at the average position of all spawn locations.", 
                key = 2, 
            },	
			{ 
                text = "Center of all spawned players", 
                help = "The hill will be located at the average position of all spawned players.", 
                key = 3, 
            },
		},	
    },

    {
		default 	= 3,
		label 		= "Koth: Score",
		help 		= "Defines how many points are required to win. One point is gained for every 30 seconds of consecutive hill control.",
		key 		= 'KingOfTheHillHillScore',
		pref	 	= 'KingOfTheHillHillScore',
		values 		= {
			{ 
                text = "30", 
                help = "The first team with a player of 30 points will win. Good for short matches.", 
                key = 1, 
            },	
			{ 
                text = "40", 
                help = "The first team with a player of 40 points will win.", 
                key = 2, 
            },	
			{ 
                text = "50", 
                help = "The first team with a player of 50 points will win. Good for the typical match.", 
                key = 3, 
            },
            { 
                text = "60", 
                help = "The first team with a player of 60 points will win.", 
                key = 4, 
            },
            { 
                text = "70", 
                help = "The first team with a player of 70 points will win. Good for long matches.", 
                key = 5, 
            },
		},	
    },

    {
		default 	= 3,
		label 		= "Koth: Controllers unit",
		help 		= "Defines what unit bonus the controller of the hill will have under its control.",
		key 		= 'KingOfTheHillHillUnit',
		pref	 	= 'KingOfTheHillHillUnit',
		values 		= {
			{ 
                text = "No unit", 
                help = "The controller of the hill will receive no bonus unit.", 
                key = 1, 
            },	
			{ 
                text = "Radar", 
                help = "A radar will be available to the controller of the hill. The radar will gradually upgrade over time.", 
                key = 2, 
            },	
			{ 
                text = "Power generator", 
                help = "A power generator will be available to the controller of the hill. The Power Generator will gradually improve over time.", 
                key = 3, 
            },
            { 
                text = "Stealth Field", 
                help = "A stealth field generator will be available to the controller of the hill.", 
                key = 4, 
            },
            { 
                text = "Shield Generator", 
                help = "A shield generator will be available to the controller of the hill.", 
                key = 5, 
            },
		},	
    },

    {
		default 	= 1,
		label 		= "Koth: Tech introduction delay",
		help 		= "Defines how long it takes for all the other players to have their tech restrictions lifted.",
		key 		= 'KingOfTheHillHillTechIntroductionDelay',
		pref	 	= 'KingOfTheHillHillTechIntroductionDelay',
		values 		= {
			{ 
                text = "Two minutes", 
                help = "After two minutes all the other players will have the latest tech restrictions lifted.", 
                key = 1, 
            },	
			{ 
                text = "Three minutes", 
                help = "After three minutes all the other players will have the latest tech restrictions lifted.", 
                key = 2, 
            },	
            { 
                text = "Four minutes", 
                help = "After four minutes all the other players will have the latest tech restrictions lifted.", 
                key = 3, 
            },	
		},	
    },

    {
		default 	= 2,
		label 		= "Koth: Mass penalty",
		help 		= "Defines the mass production penalty for controlling the hill. The controller will have a higher penalty than its team members.",
		key 		= 'KingOfTheHillHillPenalty',
		pref	 	= 'KingOfTheHillHillPenalty',
		values 		= {
			{ 
                text = "20 and 10 percent", 
                help = "The controller will have a 20 percent mass production penalty, its team members will have a 10 percent mass production penalty.", 
                key = 1, 
            },	
			{ 
                text = "30 and 15 percent", 
                help = "The controller will have a 30 percent mass production penalty, its team members will have a 15 percent mass production penalty.", 
                key = 2, 
            },	
            { 
                text = "40 and 20 percent", 
                help = "The controller will have a 40 percent mass production penalty, its team members will have a 20 percent mass production penalty.", 
                key = 3, 
            },	
		},	
    },

    {
		default 	= 1,
		label 		= "Koth: Tech unlock curve",
		help 		= "Defines how many points you need to unlock an additional tech.",
		key 		= 'kingOfTheHillTechCurve',
		pref	 	= 'kingOfTheHillTechCurve',
		values 		= {
			{ 
                text = "Early", 
                help = "Tech 2 will be unlocked at 20 percent of the total points, tech 3 at 40 percent of the total points and experimentals at 60 percent of the total points.", 
                key = 1, 
            },	
			{ 
                text = "Averaged", 
                help = "Tech 2 will be unlocked at 30 percent of the total points, tech 3 at 55 percent of the total points and experimentals at 80 percent of the total points.", 
                key = 2, 
            },	
		},	
    },
}