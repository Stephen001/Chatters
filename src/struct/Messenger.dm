Messenger
	var
		name
		winname
		MessageView/msg_view

	New(mob/chatter/C, _name)
		..()

		if(!_name)
			_name = input("Who would you like to send an instant message to?", "New IM") as text | null

			if(!_name) return

			var/mob/chatter/N = chatter_manager.getByKey(_name)

			if(!N)
				server_manager.bot.say("[_name] is not currently online.", C)
				return

			if(N.ignoring(C) & IM_IGNORE)
				server_manager.bot.say("[_name] is ignoring instant messages from you.", C)
				return

			_name = N.name

		name = _name

		winname = "cim_[ckey(name)]"
		winclone(C,"cim",winname)

		winset(C, "[winname]",			"title='[name] - CIM';")
		winset(C, "[winname].name_label","text='[name]';")
		winset(C, "[winname].ignore",	"command='Ignore \"[name]\" \"1\"'")

		winset(C, "[winname].input", "command='IM \"[name]\" \"'")
		winset(C, "[winname].input", "focus=true")

		winset(C, "[winname].output", "style='[C.default_output_style]';")

		winset(C, "[winname].interfacebar_3", "background-color='[C.interface_color]';")
		winset(C, "[winname].interfacebar_4", "background-color='[C.interface_color]';")

		if(!C.msg_handlers)
			C.msg_handlers = new

		C.msg_handlers += ckey(name)
		C.msg_handlers[ckey(name)] = src

	Topic()
		..()

	proc
		display(mob/chatter/C)
			winshow(C, winname, 1)
