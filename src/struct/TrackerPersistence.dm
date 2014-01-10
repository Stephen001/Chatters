TrackerDB
	proc
		start()
			return FALSE

		stop()
			return FALSE

		purge(var/data)
			return FALSE

		addClient(var/client/C)
			return FALSE

		findByIP(var/ip)
			return list()

		findByCkey(var/ckey)
			return list()

		findByCID(var/cid)
			return list()

		findByClient(var/client/C)
			return findByIP(C.address)

TrackerDB/Savefile
	var
		list/entries   = list()
		list/all_ips   = list()
		list/all_cids  = list()
		list/all_ckeys = list()

	start()
		if(fexists("./data/tracker_db.sav"))
			var/savefile/f = new("./data/tracker_db.sav")
			Read(f)
			server_manager.logger.info("Loaded tracker_db.sav.")
		else
			server_manager.logger.info("tracker_db.sav does not exist to be loaded.")
		if(!src.entries) src.entries = list()
		if(!src.all_ips) src.all_ips = list()
		if(!src.all_cids) src.all_cids = list()
		if(!src.all_ckeys) src.all_ckeys = list()
		return TRUE

	stop()
		var/savefile/f = new("./data/tracker_db.sav")
		Write(f)
		if(fexists("./data/tracker_db.sav"))
			server_manager.logger.info("Saved tracker_db.sav.")
			return TRUE
		else
			server_manager.logger.error("tracker_db.sav does not exist after saving.")
			return FALSE

	purge(var/data)
		. = 0
		src.all_ips -= data
		src.all_ckeys -= ckey(data)
		src.all_cids -= data
		for(var/TrackerEntry/entry in src.entries)
			if(data in entry.ips)
				entry.ips -= data
				. ++
			if(ckey(data) in entry.ckeys)
				entry.ckeys -= ckey(data)
				. ++
			if(data in entry.cids)
				entry.cids -= data
				. ++
			if(!length(entry.ips) && !length(entry.ckeys) && !length(entry.cids))
				src.entries -= entry
		return TRUE

	findByIP(ip)
		var/list/sentries = list()
		for(var/TrackerEntry/entry in entries)
			if(ip in entry.ips)
				sentries += entry
			if(length(sentries))
				if(length(sentries) > 1) return __combineEntries(sentries)
			else return sentries[1]

	findByCkey(ckey)
		var/list/sentries = list()
		for(var/TrackerEntry/entry in entries)
			if(ckey in entry.ckeys)
				sentries += entry

		if(length(sentries))
			if(length(sentries) > 1) return __combineEntries(sentries)
			else return sentries[1]

	findByCID(cid)
		var/list/sentries = list()
		for(var/TrackerEntry/entry in entries)
			if(cid in entry.cids)
				sentries += entry

		if(length(sentries))
			if(length(sentries) > 1) return __combineEntries(sentries)
			else return sentries[1]

	findByClient(client/c)
		addClient(c)

		var/list/sentries = list()

		if(c.address && c.address in all_ips) sentries += all_ips[c.address]
		if(c.computer_id && c.computer_id in all_cids) sentries += all_cids[c.computer_id]
		if(c.ckey in all_ckeys) sentries += all_ckeys[c.ckey]

		if(length(sentries))
			if(length(sentries) > 1) return __combineEntries(sentries)
			else return sentries[1]

	addClient(client/c)
		if((c.ckey in all_ckeys) || (c.computer_id && (c.computer_id in all_cids)) || (c.address && (c.address in all_ips)))
			var/list/sentries = list()

			if(c.ckey in all_ckeys)
				var/TrackerEntry/entry = all_ckeys[c.ckey]
				sentries += entry

			if(c.computer_id && (c.computer_id in all_cids))
				var/TrackerEntry/entry = all_cids[c.computer_id]
				if(!(entry in sentries)) sentries += entry

			if(c.address && (c.address in all_ips))
				var/TrackerEntry/entry = all_ips[c.address]
				if(!(entry in sentries)) sentries += entry

			for(var/TrackerEntry/entry in sentries)
				if(!(c.ckey in entry.ckeys)) entry.ckeys += c.ckey
				entry.ckeys[c.ckey] = c.key

				if(c.computer_id)
					if(!(c.computer_id in entry.cids)) entry.cids += c.computer_id
					entry.cids[c.computer_id] = time2text(world.realtime)

				if(c.address)
					if(!(c.address in entry.ips)) entry.ips += c.address
					if(!entry.ips[c.address]) entry.ips[c.address] = server_manager.geolocator.geolocate(c.address)

			if(length(sentries) > 1) __combineEntries(sentries)
			return FALSE

		else
			var/TrackerEntry/entry = new

			if(c.address)
				entry.ips += c.address
				entry.ips[c.address] = server_manager.geolocator.geolocate(c.address)
				all_ips += c.address
				all_ips[c.address] = entry

			if(c.computer_id)
				entry.cids += c.computer_id
				entry.cids[c.computer_id] = time2text(world.realtime)
				all_cids += c.computer_id
				all_cids[c.computer_id] = entry

			entry.ckeys += c.ckey
			entry.ckeys[c.ckey] = c.key

			all_ckeys += c.ckey
			all_ckeys[c.ckey] = entry

			entries += entry
			return TRUE

	proc
		__combineEntries(list/sentries)
			if(!length(sentries)) return

			var/TrackerEntry/entry = new

			for(var/TrackerEntry/e in sentries)
				for(var/ip in e.ips)
					if(!(ip in all_ips)) all_ips += ip
					all_ips[ip] = entry
					if(!(ip in entry.ips))
						entry.ips += ip
						if(e.ips[ip]) entry.ips[ip] = e.ips[ip]
						else entry.ips[ip] = server_manager.geolocator.geolocate(ip)

					else if(!entry.ips[ip])
						if(e.ips[ip]) entry.ips[ip] = e.ips[ip]
						else entry.ips[ip] = server_manager.geolocator.geolocate(ip)

				for(var/cid in e.cids)
					if(!(cid in all_cids)) all_cids += cid
					all_cids[cid] = entry
					if(!(cid in entry.cids))
						entry.cids += cid
						if(e.cids[cid]) entry.cids[cid] = e.cids[cid]

					else if(!entry.cids[cid]) if(e.cids[cid]) entry.cids[cid] = e.cids[cid]

				for(var/ckey in e.ckeys)
					if(!(ckey in all_ckeys)) all_ckeys += ckey
					all_ckeys[ckey] = entry
					if(!(ckey in entry.ckeys))
						entry.ckeys += ckey
						if(e.ckeys[ckey]) entry.ckeys[ckey] = e.ckeys[ckey]

					else if(!entry.ckeys[ckey]) if(e.ckeys[ckey]) entry.ckeys[ckey] = e.ckeys[ckey]

				if(ckey(e.notes) && (ckey(e.notes) != ckey(entry.notes)))
					entry.notes += "[e.notes]"

				entries -= e
				del(e)

			entries += entry

			return entry

TrackerDB/Database
	start()
		return server_manager.database && server_manager.database.isConnected()

	stop()
		return TRUE

	purge(var/data)
		server_manager.database.sendUpdate("DELETE FROM USER_IP_ADDRESS WHERE ckey = [server_manager.database.quote(ckey(data))] OR ipaddress = [server_manager.database.quote(data)]")
		server_manager.database.sendUpdate("DELETE FROM USER_COMPUTER_ID WHERE ckey = [server_manager.database.quote(ckey(data))] OR computerid = [server_manager.database.quote(data)]")
		return TRUE

	addClient(var/client/C)
		if(C.address)
			server_manager.database.sendUpdate("INSERT IGNORE INTO USER_IP_ADDRESS SET ckey = [server_manager.database.quote(C.ckey)], ipaddress = [server_manager.database.quote(C.address)]")
		if(C.computer_id)
			server_manager.database.sendUpdate("INSERT IGNORE INTO USER_COMPUTER_ID SET ckey = [server_manager.database.quote(C.ckey)], computerid = [server_manager.database.quote(C.computer_id)]")
		return TRUE

	findByIP(ip)
		var/TrackerEntry/entry = new()
		var/list/results = __condense(server_manager.database.select("SELECT DISTINCT ipaddress FROM USER_IP_ADDRESS WHERE ipaddress = [server_manager.database.quote(ip)]"))
		if (length(results))
			entry.ips.Add(results["ipaddress"])
		return __expandEntry(entry)

	findByCkey(ckey)
		var/TrackerEntry/entry = new()
		var/list/results = __condense(server_manager.database.select("SELECT DISTINCT ckey FROM USER_IP_ADDRESS WHERE ckey = [server_manager.database.quote(ckey)]"))
		if (length(results))
			entry.ckeys.Add(results["ckey"])
		return __expandEntry(entry)

	findByCID(cid)
		var/TrackerEntry/entry = new()
		var/list/results = __condense(server_manager.database.select("SELECT DISTINCT computerid FROM USER_COMPUTER_ID WHERE computerid = [server_manager.database.quote(cid)]"))
		if (length(results))
			entry.ckeys.Add(results["computerid"])
		return __expandEntry(entry)

	findByClient(client/c)
		return findByCkey(c.ckey)

	proc
		__expandEntry(var/TrackerEntry/entry)
			if(length(entry.ckeys) || length(entry.ips) || length(entry.cids))
				var/list/ckeys = new()
				var/list/ips = new()
				var/list/cids = new()
				if(length(entry.ckeys))
					var/list/results = __condense(server_manager.database.select("SELECT DISTINCT * FROM USER_IP_ADDRESS WHERE ckey IN [__sqlList(entry.ckeys)]"))
					ckeys.Add(results["ckey"])
					ips.Add(results["ipaddress"])
					results = __condense(server_manager.database.select("SELECT DISTINCT * FROM USER_COMPUTER_ID WHERE ckey IN [__sqlList(entry.ckeys)]"))
					ckeys.Add(results["ckey"])
					cids.Add(results["computerid"])
				if(length(entry.ips))
					var/list/results = __condense(server_manager.database.select("SELECT DISTINCT * FROM USER_IP_ADDRESS WHERE ipaddress IN [__sqlList(entry.ips)]"))
					ckeys.Add(results["ckey"])
					ips.Add(results["ipaddress"])
				if (length(entry.cids))
					var/list/results = __condense(server_manager.database.select("SELECT DISTINCT * FROM USER_COMPUTER_ID WHERE computerid IN [__sqlList(entry.cids)]"))
					ckeys.Add(results["ckey"])
					cids.Add(results["computerid"])
				ckeys.Remove(entry.ckeys)
				ips.Remove(entry.ips)
				cids.Remove(entry.cids)
				entry.ckeys += ckeys
				entry.ips += ips
				entry.cids += cids
				if(length(ckeys) || length(ips) || length(cids))
					return __expandEntry(entry)
			return entry


		__sqlList(var/list/L)
			var/result = "("
			for (var/i = 1; i <= length(L); i++)
				result += "[L[i]]"
				if (i < length(L))
					result += ", "
			result += ")"
			return result

		__condense(var/list/L)
			var/list/result = new()
			for (var/list/row in L)
				for(var/key in row)
					if (isnull(result[key]))
						result[key] = list()
					result[key] += row[key]
			return result