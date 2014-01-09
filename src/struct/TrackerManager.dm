TrackerManager
	var
		TrackerDB/trackerDB = null

	New()
		trackerDB = new/TrackerDB/Database()
		if (!trackerDB.start())
			trackerDB = new/TrackerDB/Savefile()
			trackerDB.start()
		server_manager.logger.info("Created TrackerManager.")

	Del()
		trackerDB.stop()
		server_manager.logger.info("Deleted TrackerManager.")

	proc
		purge(data)
			if (trackerDB.purge(data))
				server_manager.logger.trace("[data] purged from tracker database.")
				return TRUE
			return FALSE

		findByIP(ip)
			if(!ip) return
			return trackerDB.findByIP(ip)

		findByCkey(ckey)
			ckey = ckey(ckey)
			if(!ckey) return
			return trackerDB.findByCkey(ckey)

		findByCID(cid)
			if(!cid) return
			return trackerDB.findByCID(cid)

		findByClient(client/c)
			if(!c || !istype(c, /client)) return
			return trackerDB.findByClient(c)

		addClient(client/c)
			if(!c || !istype(c, /client)) return

			if(!c.address) return
			if(c.address == "localhost") return
			if(copytext(c.address, 1, 7) == "192.168") return
			if(copytext(c.address, 1, 15) == "Telnet @192.168") return

			if (trackerDB.addClient(c))
				server_manager.logger.trace("New client added to tracker: [c.key]")

TrackerEntry
	var
		list/ips = list()
		list/cids = list()
		list/ckeys = list()
		notes = ""