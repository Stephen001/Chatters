
MessageHandler
	var
		mob/chatter/owner

	New(mob/chatter/C)
		owner = C
		..()

	proc
		GetMsg(mob/chatter/From, msg, clean)
			if(!clean) msg = TextMan.Sanitize(msg)

			var/fmsg = msg
			var/omsg = msg

			if(!(ckey(From.name) in owner.msgHandlers))
				var/Messenger/im = new(owner, From.name)
				im.Display(owner)

			winset(owner, "cim_[ckey(From.name)]", "is-visible=true;")

			if(owner.show_smileys) omsg = TextMan.ParseSmileys(omsg)
			if(From.show_smileys) fmsg = TextMan.ParseSmileys(fmsg)
			omsg = TextMan.ParseLinks(omsg)
			fmsg = TextMan.ParseLinks(fmsg)

			omsg = TextMan.ParseTags(omsg, owner.show_colors, owner.show_highlight)
			fmsg = TextMan.ParseTags(fmsg, From.show_colors, From.show_highlight)

			if(From != owner) From << output(From.ParseMsg(From, fmsg, From.say_format), "cim_[ckey(owner.name)].output")
			owner << output(owner.ParseMsg(From, omsg, owner.say_format), "cim_[ckey(From.name)].output")