MessageHandler
	var/mob/chatter/owner

	New(mob/chatter/C)
		owner = C
		..()

	proc
		getMsg(mob/chatter/from, msg, clean)
			if(!clean)
				msg = text_manager.sanitize(msg)

			var
				fmsg = msg
				omsg = msg

			if(!(ckey(from.name) in owner.msg_handlers))
				var/Messenger/im = new(owner, from.name)
				im.display(owner)

			winset(owner, "cim_[ckey(from.name)]", "is-visible=true;")

			if(owner.show_smileys) omsg = text_manager.parseSmileys(omsg)
			if(from.show_smileys) fmsg = text_manager.parseSmileys(fmsg)

			omsg = text_manager.parseLinks(omsg)
			fmsg = text_manager.parseLinks(fmsg)

			omsg = text_manager.parseTags(omsg, owner.show_colors, owner.show_highlight)
			fmsg = text_manager.parseTags(fmsg, from.show_colors, from.show_highlight)

			if(from != owner) from << output(from.parseMsg(from, fmsg, from.say_format), "cim_[ckey(owner.name)].output")
			owner << output(owner.parseMsg(from, omsg, owner.say_format), "cim_[ckey(from.name)].output")

		routeMsg(mob/chatter/from, mob/chatter/trg, msg, clean)
			if(!msg) return

			if(trg.ignoring(from) & IM_IGNORE)
				server_manager.bot.say("[trg.name] is ignoring instant messages from you.", from)

				return

			trg.msg_hand.getMsg(from, msg, clean)