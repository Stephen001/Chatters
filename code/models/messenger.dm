
Messenger
	var
		name
		winname
		MessageView
			MsgView

	New(mob/chatter/C, Name)
		..()
		if(!Name)
			Name = input("Who would you like to send an instant message to?", "New IM") as text | null
			if(!Name) return
			var/mob/chatter/N = ChatMan.Get(Name)
			if(!N)
				alert(C, "[Name] is not currently online.", "Unable to Locate Chatter.")
				return
			if(N.ignoring(C) & IM_IGNORE)
				alert(C, "[Name] is ignoring instant messages from you.", "Unable to IM chatter.")
				return
			Name = N.name
		name = Name
		winname = "cim_[ckey(name)]"
		winclone(C,"cim",winname)
		winset(C, "[winname]",			"title='[name] - CIM';")
		winset(C, "[winname].name_label","text='[name]';")
		winset(C, "[winname].ignore",	"command='Ignore \"[name]\" \"1\"'")

		winset(C, "[winname].input", "command='IM \"[name]\" \"'")
		winset(C, "[winname].input", "focus=true")

		winset(C, "[winname].output", "style='[TextMan.escapeQuotes(C.default_output_style)]';max-lines='[C.max_output]';")

		if(!C.msgHandlers)
			C.msgHandlers=new
		C.msgHandlers += ckey(name)
		C.msgHandlers[ckey(name)] = src

	Topic()
		..()

	proc
		Display(mob/chatter/C)
			winshow(C, winname, 1)