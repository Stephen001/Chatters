ServerManager
	var
		host = "" // ckey of host as defined in server config file

		Channel/home
		Bot/bot
		Logger/logger

	New()
		createLogger()

		if(!loadServerCfg())
			CRASH("Failed to properly load server.cfg! Check the log file for more information.")
			return

		loadHome()
		loadBot()

		logger.info("ServerManager successfully created.")

	Del()
		saveHome()
		saveBot()

		logger.info("ServerManager successfully deleted.")
		log4dm.endLogging()

	proc
		createLogger()
			logger = log4dm.getLogger("log")
			var/time = time2text(world.realtime, "DDD, MMM YYYY")
			logger.htmlFileConfig("./data/logs/[time].html") // Set up a generic HTML file appender.

			log4dm.startLogging()

		saveHome(Channel/Chan)
			var/savefile/S = new("./data/server_home.sav")

			S["mute"]		<< home.mute
			S["banned"]		<< home.banned
			S["operators"]  << home.operators

			if(fexists("./data/server_home.sav")) logger.info("Successfully saved server_home.sav.")
			else logger.error("server_home.sav does not exist after saving.")

		loadHome(chan)
			if(fexists("./data/server_home.sav"))
				var
					savefile/S = new("./data/server_home.sav")
					list/temp = null

				S["mute"] >> temp
				if(length(temp)) home.mute |= temp

				S["banned"]	>> temp
				if(length(temp)) home.banned |= temp

				S["operators"] >> temp
				if(length(temp)) home.operators |= temp

				logger.info("Successfully loaded server_home.sav.")

			else logger.info("server_home.sav does not exist to be loaded.")

		saveBot()
			var/savefile/S = new("./data/server_bot.sav")

			S["name"]		<< bot.name
			S["name_color"]	<< bot.name_color
			S["text_color"]	<< bot.text_color

			if(fexists("./data/server_bot.sav")) logger.info("Successfully saved server_bot.sav.")
			else logger.error("server_bot.sav does not exist after saving.")

		loadBot(Channel/Chan)
			bot = new

			if(fexists("./data/server_bot.sav"))
				var/savefile/S = new("./data/server_bot.sav")

				S["name"]		>> bot.name
				S["name_color"]	>> bot.name_color
				S["text_color"]	>> bot.text_color

				if(!bot.name) bot.name = "@ChanBot"
				if(!bot.name_color) bot.name_color = "#000000"
				if(!bot.text_color) bot.text_color = "#000000"

				logger.info("Successfully saved server_bot.sav.")

			else logger.info("server_bot.sav does not exist to be loaded.")

		loadServerCfg()
			if(!fexists("./data/server.cfg"))
				logger.fatal("server.cfg not found.")
				return

			var/list/config = parseCFGFile("./data/server.cfg")
			if(!config || !length(config))
				logger.fatal("Failed to parse server.cfg. Is the file empty?")
				return

			var/list/main = params2list(config["main"])
			if(!main || !length(main))
				logger.fatal("No main header found in server.cfg.")
				return

			host = ckey(main["host"])

			var
				list/mute_list = params2list(config["mute"])
				list/ban_list = params2list(config["bans"])
				list/op_list = params2list(config["ops"])
				list/server = params2list(config["server"])

			if(server && length(server))
				var
					chan_name  = server["name"]
					chan_topic = server["topic"]

				home = new(list("name" = chan_name, "topic" = chan_topic))

				if(mute_list && length(mute_list))
					home.mute = new
					for(var/i in mute_list)
						home.mute += ckey(i)

				if(ban_list && length(ban_list))
					home.banned = new
					for(var/i in ban_list)
						home.banned += ckey(i)

				if(op_list && length(op_list))
					home.operators = list()
					for(var/name in op_list)
						var/op_key = ckey(op_list[name])
						home.operators += op_key

				logger.info("Successfully loaded server.cfg.")

				return TRUE

			else logger.fatal("No server header found in server.cfg.")

		parseCFGFile(cfg)
			if(!cfg || !fexists(cfg)) return

			var
				list/config = new()
				list/lines = new()
				head
				txt
				l
				line
				fchar
				cbracket
				phead
				sep
				comm
				param
				value

			txt = file2text(cfg)
			if(!txt || !length(txt)) return

			lines = textutil.text2list(txt, "\n")
			if(!lines || !length(lines)) return

			config += "main"

			for(l in lines)
				line = textutil.trimWhitespace(l)
				if(!line) continue

				fchar = copytext(line, 1, 2)

				switch(fchar)
					if(";") continue
					if("#") continue
					if("\[")
						cbracket = findtext(line, "]")
						if(!cbracket) continue

						if(head)
							phead = config[length(config)]
							config[phead] = head
							config += lowertext(copytext(line, 2, cbracket))
							head = null

							continue

						else if(length(config) == 1)
							config = new()
							config += lowertext(copytext(line, 2, cbracket))

							continue

						else
							phead = config[length(config)]
							config -= phead
							config += lowertext(copytext(line, 2, cbracket))

					else
						sep = findtext(line, "=")

						if(!sep) sep = findtext(line, ":")
						if(!sep) continue

						comm = findtext(line, ";")
						if(!comm) comm = findtext(line, "#")
						if(comm && (comm < sep)) continue
						if(sep == length(line)) continue

						param = lowertext(textutil.trimWhitespace(copytext(line, 1, sep)))
						value = textutil.trimWhitespace(copytext(line, sep + 1, comm))

						if(head) head += "&" + param
						else head = param

						head += "=" + value

			if(head)
				phead = config[length(config)]
				config[phead] = head

			return config