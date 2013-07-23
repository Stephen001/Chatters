Bot
	var
		name = "@ChanBot"
		name_color = "#f00"
		text_color = "#000"
		fade_name = ""

	proc
		say(msg, mob/chatter/C, echoed)
			msg = copytext(msg, 1, 1024)
			msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(C)
				var/message = msg
				if(C.show_smileys) message = text_manager.parseSmileys(raw_msg)

				message = text_manager.parseLinks(message)
				message = text_manager.parseTags(message, C.show_colors, C.show_highlight, 0)

				C << output(C.parseMsg(src, msg, C.say_format), "[ckey(server_manager.home.name)].chat.default_output")

			else
				for(var/mob/chatter/c in server_manager.home.chatters)
					var/message = msg
					if(c.show_smileys) message = text_manager.parseSmileys(raw_msg)

					message = text_manager.parseLinks(message)
					message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

					c << output(c.parseMsg(src, message, c.say_format), "[ckey(server_manager.home.name)].chat.default_output")

		rawSay(msg, mob/chatter/receiver, echoed)
			if(receiver)
				// message for a specific chatter.
				receiver << output(receiver.parseMsg(src, msg, receiver.say_format),"[ckey(server_manager.home.name)].chat.default_output")

			else
				// message for all chatters.
				for(var/mob/chatter/a in server_manager.home.chatters)
					a << output(a.parseMsg(src, msg, a.say_format),"[ckey(server_manager.home.name)].chat.default_output")

		me(msg, echoed)
			msg = copytext(msg, 1, 1024)
			msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(echoed) name = ">[copytext(name, 2)]"

			for(var/mob/chatter/c in server_manager.home.chatters)
				var/message
				if(c.show_smileys) message = text_manager.parseSmileys(raw_msg)

				message = text_manager.parseLinks(message)
				message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

				c << output(c.parseMsg(src, message, c.me_format, 1), "[ckey(server_manager.home.name)].chat.default_output")

			if(echoed) name = "@[copytext(name, 2)]"

		my(msg, echoed)
			msg = copytext(msg, 1, 1024)
			msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(echoed) name = ">[copytext(name, 2)]"

			for(var/mob/chatter/c in server_manager.home.chatters)
				var/message
				if(c.show_smileys) message = text_manager.parseSmileys(raw_msg)

				message = text_manager.parseLinks(message)
				message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

				c << output(c.parseMsg(src, message, c.me_format, 2), "[ckey(server_manager.home.name)].chat.default_output")

			if(echoed) name = "@[copytext(name, 2)]"

		setName(new_name, save = 1)
			if(!new_name) new_name = "chanBot"
			name = "@" + new_name
			if(save) server_manager.saveBot(src)

		setNameColor(new_color, save = 1)
			if(!new_color) new_color = "#f00"
			name_color = new_color
			if(save) server_manager.saveBot(src)

		setTextColor(new_color, save = 1)
			if(!new_color) new_color = "#000"
			text_color = new_color
			if(save) server_manager.saveBot(src)

		setTopic(new_value, save)
			server_manager.home.topic = new_value

			for(var/mob/chatter/C in server_manager.home.chatters)
				if(chatter_manager.isTelnet(C.key)) continue
				if(!C.client) continue
				winset(C, "[ckey(server_manager.home.name)].topic_label", "text='[new_value]';")

			if(save) server_manager.saveHome()