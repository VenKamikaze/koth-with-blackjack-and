import("/mods/king of the hill - tsr/modules/constants.lua")

options =
{
	{
		default 	= 1,
		label 		= kothConstants.lobbyLabelPrefix .. ": Type",
		help 		= "Whether or not a map-specific hill or a custom hill is used. If there is no map-specific hill defined, the custom settings will be used.",
		key 		= 'tsrKothHillType',
		pref	 	= 'tsrKothHillType',
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
		label 		= kothConstants.lobbyLabelPrefix .. ": Radius",
		help 		= "Defines the size of the hill.",
		key 		= 'tsrKothHillSize',
		pref	 	= 'tsrKothHillSize',
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
		default 	= 3,
		label 		= kothConstants.lobbyLabelPrefix .. ": Delay",
		help 		= "Defines how long it takes for the hill to become active.",
		key 		= 'tsrKothHillDelay',
		pref	 	= 'tsrKothHillDelay',
		values 		= {
            { 
                text = "No Delay", 
                help = "The hill will be active at start.", 
                key = -1, 
            },
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
                key = 4, 
            },
            { 
                text = "Twenty minutes", 
                help = "The hill will be active after twenty minutes.", 
                key = 9, 
            },
		},	
    },

    {
		default 	= 1,
		label 		= kothConstants.lobbyLabelPrefix .. ": Center",
		help 		= "Defines where the hill will be located.",
		key 		= 'tsrKothHillCenter',
		pref	 	= 'tsrKothHillCenter',
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
                text = "Center of all spawned players (excluding AI)", 
                help = "The hill will be located at the average position of all spawned human players.", 
                key = 3, 
            },
			{ 
                text = "Center of all spawned players (including AI)", 
                help = "The hill will be located at the average position of all spawned human or AI players.", 
                key = 4, 
            },
		},	
    },

    {
		default 	= 3,
		label 		= kothConstants.lobbyLabelPrefix .. ": Score",
		help 		= "Defines how many points are required to win. One point is gained for every 30 seconds of consecutive hill control.",
		key 		= 'tsrKothHillScore',
		pref	 	= 'tsrKothHillScore',
		values 		= {
            { 
                text = "20", 
                help = "The first team with a player of 20 points will win.", 
                key = 0, 
            },	
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
            { 
                text = "80", 
                help = "The first team with a player of 80 points will win.", 
                key = 6, 
            },
		},	
    },

    {
		default 	= 3,
		label 		= kothConstants.lobbyLabelPrefix .. ": Controllers unit",
		help 		= "Defines what unit bonus the controller of the hill will have under its control.",
		key 		= 'tsrKothHillUnit',
		pref	 	= 'tsrKothHillUnit',
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
		label 		= kothConstants.lobbyLabelPrefix .. ": Tech introduction delay",
		help 		= "Defines how long it takes for all the other players to have their tech restrictions lifted.",
		key 		= 'tsrKothHillTechIntroductionDelay',
		pref	 	= 'tsrKothHillTechIntroductionDelay',
		values 		= {
            { 
                text = "No Delay", 
                help = "All the other players will have the latest tech restrictions lifted at the same time.", 
                key = -1, 
            },	
            { 
                text = "One minute", 
                help = "After one minute all the other players will have the latest tech restrictions lifted.", 
                key = 0, 
            },	
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
		label 		= kothConstants.lobbyLabelPrefix .. ": Mass penalty",
		help 		= "Defines the mass production penalty for controlling the hill. The controller will have a higher penalty than its team members.",
		key 		= 'tsrKothHillPenalty',
		pref	 	= 'tsrKothHillPenalty',
		values 		= {
            { 
                text = "No Penalty", 
                help = "No mass production penalty.", 
                key = -1, 
            },	
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
		default 	= 3,
		label 		= kothConstants.lobbyLabelPrefix .. ": Tech unlock curve",
		help 		= "Defines how many points you need to unlock an additional tech.",
		key 		= 'tsrKothTechCurve',
		pref	 	= 'tsrKothTechCurve',
		values 		= {
            { 
                text = "No Tech restrictions", 
                help = "All Tech unlocked from the start.", 
                key = 1, 
            },	
            { 
                text = "Tech 2 Start", 
                help = "Tech 2 will be unlocked at start, tech 3 at 20 percent of the total points and experimentals at 40 percent of the total points.", 
                key = 2, 
            },	
			{ 
                text = "Early", 
                help = "Tech 2 will be unlocked at 20 percent of the total points, tech 3 at 40 percent of the total points and experimentals at 60 percent of the total points.", 
                key = 3, 
            },	
			{ 
                text = "Averaged", 
                help = "Tech 2 will be unlocked at 30 percent of the total points, tech 3 at 55 percent of the total points and experimentals at 80 percent of the total points.", 
                key = 4, 
            },	
		},	
    },

    {
                default         = 1,
                label           = kothConstants.lobbyLabelPrefix .. ": Commander can control hill",
                help            = "A commander immediately contests or controls a hill, if present on the hill.",
                key             = 'tsrKothCommanderControlHill',
                pref            = 'tsrKothCommanderControlHill',
                values          = {
            {
                text = "Yes",
                help = "If a commander is present on the hill, it overrides the need for the mass threshold to control or contest the hill.",
                key = 1,
            },
            {
                text = "No",
                help = "A commander does not override the mass threshold for hill control and is not counted towards controlling or contesting the hill.",
                key = 2,
            },
        },
    },

}
