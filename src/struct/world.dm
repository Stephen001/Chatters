world
	name = "Chatters"
	hub = "Xooxer.Chatters"
	hub_password = "rbl9FQ0hzWtOEKtg"	// my eyes only 0_0
	cache_lifespan = 1
	mob = /mob/chatter
	visibility = 1		// Set to 0 in LoadServerCfg if we're not public, leave otherwise.

	New()
		..()

		createManagers()

	Del()
		deleteManagers()

		..()