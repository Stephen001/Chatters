client
	authenticate = 0
	perspective = EDGE_PERSPECTIVE
	show_popup_menus = 0
	preload_rsc = 0

	Command(command)
		var/success = 0

		if(findtext(command, "/", 1, 2))
			var
				pos = findtext(command, " ")
				cmd = copytext(command, 2, pos)
				params

			if(pos) params = copytext(command, pos + 1)

			for(var/v in mob.verbs)
				if(ckey(cmd) == ckey(v:name))
					call(mob, v:name)(params)
					success = 1

		if(!success && chatter_manager.isTelnet(src.key))
			var/mob/chatter/c = mob
			c.say(command)

		..(command)

	Click(object, location, control, params)
		if(control == "who.grid")
			var/Messenger/im = new(mob, key)
			im.display(mob)

	New()
		..()

		server_manager.logger.info("Client [key] successfully created.")
		assoc_manager.addClient(src)

	Del()
		if(server_manager.logger)
			server_manager.logger.info("Client [key] successfully deleted.")

		..()