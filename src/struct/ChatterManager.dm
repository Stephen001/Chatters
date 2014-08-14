ChatterManager
	New()
		server_manager.logger.info("Created ChatterManager.")

	Del()
		server_manager.logger.info("Deleted ChatterManager.")

	Topic(href, href_list)
		..()
		var/mob/chatter/trg
		if(href_list["target"]) trg = locate(href_list["target"])

		switch(href_list["action"])
			if("showcontent")
				var/Snippet/snippet = server_manager.home.snippets[text2num(href_list["index"])]

				if(snippet.target && snippet.target != usr.ckey && usr.ckey != trg.ckey)
					// This is a private message they are not allowed to view.
					return

				else 	
					// To make sure the popup doesn't appear offscreen, move it somewhere.
					// e.g. centered with the default window like it should do by default. 
					var params = params2list(winget(usr, "default;[window_id]", "pos;size"))
					var x = text2num(params["default.pos"])
					var y = text2num(copytext(params["default.pos"], length("[x]") + 2))
					var width1 = text2num(params["default.size"])
					var height1 = text2num(copytext(params["default.size"], length("[width1]") + 2))
					var width2 = text2num(params["[window_id].size"])
					var height2 = text2num(copytext(params["[window_id].size"], length("[width2]") + 2))
					var new_x = x + (width1 - width2) / 2
					var new_y = y + (height1 - height2) / 2
					winset(src, window_id, "pos=[new_x],[new_y]")

			if("tracker_viewckey")
				if(trg && trg.ckey in server_manager.home.operators)
					var/ckey = href_list["ckey"]
					if(ckey)
						var/TrackerEntry/entry = tracker_manager.findByCkey(ckey)
						if(entry)
							trg.viewing_entry = entry
							trg.updateViewingEntry()

			if("logs_viewlog")
				if(trg && trg.ckey in server_manager.home.operators)
					var/log = href_list["log"]
					if(log && fexists("./data/logs/[log].html"))
						trg.viewing_log = "[log]"
						trg.updateViewingLog()

	proc
		usher(mob/chatter/C)
			if(!C.client)
				del(src)
				return

			// Do not call client.Import on telnet users
			if(!chatter_manager.isTelnet(C.key))
				load(C)
				save(C) // This offers the ability to save to new mediums on login, like DBs.
				if(server_manager)
					C.watchdog = new(server_manager.global_scheduler, C)
					// server_manager.global_scheduler.schedule(C.watchdog, 600)
					// TODO: Debug the scheduler issue that loses events sometimes.
					spawn(600)
						while(C && C.client)
							winget(C, "main", "is-visible")
							sleep(600)


		// Tests if the key is a telnet key eg: Telnet @127.000.000.001
		isTelnet(key)
			if(findtext(key, "Telnet @") == 1)
				return 1

		getByKey(chatter)
			if(server_manager && server_manager.home)
				for(var/mob/M in server_manager.home.chatters)
					if(M.ckey == ckey(chatter)) return M

		parseFormat(format, variables[], required[])
			if(!format || !variables || !length(variables))
				return FALSE

			if(required)
				for(var/r in required)
					if(!findtext(format, r))
						return FALSE

			var
				list/L = new()
				temp = format

			for(var/v in variables)
				var/pos = findtext(format, v)
				if(pos) variables[v] = pos
				else variables -= v

			for(var/v = length(variables), v >= 1, v--)
				for(var/i = 1, i < v, i ++)
					if(variables[variables[i]] > variables[variables[i + 1]])
						variables.Swap( i, i + 1)

					else if(variables[variables[i]] == variables[variables[i + 1]])
						variables -= variables[i + 1]

					if(v > length(variables))
						break

			for(var/v in variables)
				var/pos = findtext(temp, v)
				if(pos > 1)
					L += copytext(temp, 1, pos)

				L += v
				temp = copytext(temp, pos + length(v))

			if(length(temp))
				L += temp

			return L

		load(mob/chatter/C)
			server_manager.persistenceHandler.load(C)

		save(mob/chatter/C)
			server_manager.persistenceHandler.save(C)

Event/Timer/Watchdog
	var/mob/chatter/C

	New(var/EventScheduler/scheduler, var/mob/chatter/C)
		..(scheduler, 600)
		src.C = C

	fire()
		if (C && C.client)
			..()
			winget(C, "main", "is-visible")
			server_manager.logger.trace("Watchdog fired for [C.key]")
