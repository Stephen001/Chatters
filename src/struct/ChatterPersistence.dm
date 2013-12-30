ChatterPersistenceHandler
	proc
		save(var/mob/chatter/C)
			return FALSE

		load(var/mob/chatter/C)
			return FALSE

ChatterPersistenceHandler/Savefile
	save(var/mob/chatter/C)
		var/savefile/S = new()
		C.Write(S)
		sleep(10)
		C.client.Export(S)
		return TRUE

	load(var/mob/chatter/C)
		var/clientFile = C.client.Import()
		if (clientFile && clientFile != "-1.sav")
			var/savefile/F = new(clientFile)
			C.Read(F)
			return TRUE
		return FALSE

ChatterPersistenceHandler/Database
	save(var/mob/chatter/C)
		if (server_manager.database)
			var/sql = ""
			if (server_manager.database.countSelect("SELECT ckey FROM USER_SETTINGS WHERE ckey = [server_manager.database.quote(C.ckey)]"))
				sql = "UPDATE USER_SETTINGS SET "
				sql = __addPreferenceSetters(sql, C)
				sql += "WHERE ckey = [server_manager.database.quote(C.ckey)]"
			else
				sql = "INSERT INTO USER_SETTINGS SET "
				sql += "ckey = [server_manager.database.quote(C.ckey)], "
				sql = __addPreferenceSetters(sql, C)
			return server_manager.database.sendUpdate(sql)
		return FALSE

	load(var/mob/chatter/C)
		if (server_manager.database)
			if (server_manager.database.countSelect("SELECT ckey FROM USER_SETTINGS WHERE ckey = [server_manager.database.quote(C.ckey)]"))
				var/list/results = server_manager.database.singleSelect("SELECT * FROM USER_SETTINGS WHERE ckey = [server_manager.database.quote(C.ckey)]")
				C.name_color 		= results["namecolor"]
				C.text_color 		= results["textcolor"]
				C.interface_color 	= results["interfacecolor"]
				C.show_colors 		= text2num(results["showcolors"])
				C.show_smileys 		= text2num(results["showsmilies"])
				C.show_title 		= text2num(results["showtitle"])
				C.show_welcome 		= text2num(results["showwelcome"])
				C.show_motd 		= text2num(results["showmotd"])
				C.show_qotd 		= text2num(results["showqotd"])
				C.show_highlight	= text2num(results["highlightcode"])
				C.time_24hr			= text2num(results["time24hr"])
				C.time_offset		= text2num(results["timeoffset"])
				C.auto_away			= text2num(results["autoaway"])
				C.auto_reason		= results["autoafkmessage"]
				C.flip_panes		= text2num(results["flippanes"])
				C.fade_colors		= params2list(results["fadecolors"])
				C.fade_name			= results["fadename"]
				return TRUE
		return FALSE

	proc
		__addPreferenceSetters(var/sql, var/mob/chatter/C)
			sql += "namecolor = [server_manager.database.quote(C.name_color)], "
			sql += "textcolor = [server_manager.database.quote(C.text_color)], "
			sql += "interfacecolor = [server_manager.database.quote(C.interface_color)], "
			sql += "showcolors = [C.show_colors ? 1 : 0], "
			sql += "showsmilies = [C.show_smileys ? 1 : 0], "
			sql += "showtitle = [C.show_title ? 1 : 0], "
			sql += "showwelcome = [C.show_welcome ? 1 : 0], "
			sql += "showmotd = [C.show_motd ? 1 : 0], "
			sql += "showqotd = [C.show_qotd ? 1 : 0], "
			sql += "highlightcode = [C.show_highlight ? 1 : 0], "
			sql += "time24hr = [C.time_24hr ? 1 : 0], "
			sql += "timeoffset = [text2num(C.time_offset)], "
			sql += "autoaway = [text2num(C.auto_away)], "
			sql += "autoafkmessage = [server_manager.database.quote(C.auto_reason)], "
			sql += "flippanes = [C.flip_panes ? 1 : 0], "
			sql += "fadecolors = [server_manager.database.quote(list2params(C.fade_colors))], "
			sql += "fadename = [server_manager.database.quote(C.fade_name)] "
			return sql

ChatterPersistenceHandler/Fallback
	var/list/handlers = new()

	New()
		handlers += new/ChatterPersistenceHandler/Database()
		handlers += new/ChatterPersistenceHandler/Savefile()

	save(var/mob/chatter/C)
		for (var/ChatterPersistenceHandler/handler in src.handlers)
			if (handler.save(C))
				return TRUE
		return FALSE

	load(var/mob/chatter/C)
		for (var/ChatterPersistenceHandler/handler in src.handlers)
			if (handler.load(C))
				return TRUE
		return FALSE