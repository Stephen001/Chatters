
Bot
	var
		name = "@ChanBot"
		name_color = "#f00"
		text_color = "#000"
		fade_name = ""
		Channel/Chan

	New(Channel/chan)
		..()
		if(chan) Chan = chan

	verb
		echo(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.Say(msg, null, 1)

		echome(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.Me(msg, 1)

		echomy(msg as text|null)
			set hidden = 1
			if(!msg) return
			Home.chanbot.My(msg, 1)

		ViewLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "console.output")
				return
			else
				usr << browse("<title>Chatters Error Log (log.txt)</title><pre>[file2text("./data/saves/logs/log.txt")]</pre>", "window=error_log")

		GetLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "console.output")
				return
			else
				usr << ftp("./data/saves/logs/log.txt")

		ClearLog()
			set hidden = 1
			if(!LogMan.logfile || !fexists("./data/saves/logs/log.txt"))
				usr << output("No log file exists.", "console.output")
				return
			else
				world.log = null
				fdel("./data/saves/logs/log.txt")
				world.log = file("./data/saves/logs/log.txt")
				usr << output("Error Log cleared successfully.", "console.output")
			winshow(usr, "console", 1)

		Reboot(msg as text|null)
			set hidden = 1
			usr << output("Rebooting...", "console.output")
			sleep(10)
			if(Home)
				if(!msg) msg = "A reboot will take place in 15 seconds..."
				var/announcement = {"<center><br><br><br><b>[TextMan.fadetext("#################### --- Attention! --- ####################",list("255255255","255000000","255255255"))]<br>
[TextMan.fadetext("A Reboot has been initiated by [usr.name]: ",list("000000000","255000000","000000000"))]</b><br>
[TextMan.fadetext("----------------------------------------------------------------------------------------------------------",list("255255255","000000000","255255255"))]<br>
<pre>[msg]</pre><br>
[TextMan.fadetext("_____________________ \[end of announcement\] _____________________",list("255255255","000000000","255255255"))]
<br><br>"}
				var/no_color = {"<center><br><br><br><b>#################### --- Attention! --- ####################<br>
A Reboot has been initiated by  [usr.name]: </b><br>
----------------------------------------------------------------------------------------------------------<br>
<pre>[msg]</pre><br>
_____________________ \[end of announcement\] _____________________
<br><br>"}
				for(var/mob/chatter/C in Home.chatters)
					if(C.show_colors)
						C << output(announcement, "[ckey(Home.name)].chat.default_output")
					else
						C << output(no_color, "[ckey(Home.name)].chat.default_output")
				ChanMan.SaveHome()
				BotMan.SaveBot(Home.chanbot)
			sleep(150)
			for(var/mob/chatter/C in world)
				if(!C.telnet && C.clear_on_reboot)
					if(Home) C << output(,"[ckey(Home.name)].chat.default_output")
					C << output(,"default.output")
					C << output(,"console.output")
			sleep(10)
			world.Reboot()


	proc
		Say(msg, mob/chatter/C, echoed)
			msg = copytext(msg, 1, 1024)
			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(C)
				var/message = msg
				if(C.show_smileys) message = TextMan.ParseSmileys(raw_msg)
				message = TextMan.ParseLinks(message)
				message = TextMan.ParseTags(message, C.show_colors, C.show_highlight,0)
				C << output(C.ParseMsg(src, msg, C.say_format),"[ckey(Chan.name)].chat.default_output")
			else
				for(var/mob/chatter/c in Chan.chatters)
					var/message = msg
					if(c.show_smileys)  message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					c << output(c.ParseMsg(src, message, c.say_format),"[ckey(Chan.name)].chat.default_output")

		RawSay(msg, mob/chatter/receiver, echoed)
			if(receiver)
				// Message for a specific chatter.
				receiver << output(receiver.ParseMsg(src, msg, receiver.say_format),"[ckey(Chan.name)].chat.default_output")
			else
				// Message for all chatters.
				for(var/mob/chatter/a in Chan.chatters)
					a << output(a.ParseMsg(src, msg, a.say_format),"[ckey(Chan.name)].chat.default_output")

		Me(msg, echoed)
			msg = copytext(msg, 1, 1024)
			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			if(echoed) name = ">[copytext(name, 2)]"
			for(var/mob/chatter/c in Chan.chatters)
				var/message
				if(c.show_smileys) message = TextMan.ParseSmileys(raw_msg)
				message = TextMan.ParseLinks(message)
				message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
				c << output(c.ParseMsg(src, message, c.me_format,1),"[ckey(Chan.name)].chat.default_output")
			if(echoed) name = "@[copytext(name, 2)]"

		My(msg, echoed)
			msg = copytext(msg, 1, 1024)
			msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			if(echoed) name = ">[copytext(name, 2)]"
			for(var/mob/chatter/c in Chan.chatters)
				var/message
				if(c.show_smileys) message = TextMan.ParseSmileys(raw_msg)
				message = TextMan.ParseLinks(message)
				message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
				c << output(c.ParseMsg(src, message, c.me_format,2),"[ckey(Chan.name)].chat.default_output")
			if(echoed) name = "@[copytext(name, 2)]"


		SetName(newName,save)
			if(!newName) newName = "ChanBot"
			name = "@"+newName
			if(save) BotMan.SaveBot(src)

		SetNameColor(newColor,save)
			if(!newColor) newColor = "#f00"
			name_color = newColor
			if(save) BotMan.SaveBot(src)


		SetTextColor(newColor,save)
			if(!newColor) newColor = "#000"
			text_color = newColor
			if(save) BotMan.SaveBot(src)

		SetDesc(newValue,save)
			Chan.desc = newValue
			if(save) ChanMan.SaveHome()


		SetTopic(newValue,save)
			Chan.topic = newValue
			for(var/mob/chatter/C in Chan.chatters)
				if(ChatMan.istelnet(C.key)) continue
				if(!C.client) continue
				winset(C, "[ckey(Chan.name)].topic_label", "text='[TextMan.escapeQuotes(newValue)]';")
			if(save) ChanMan.SaveHome()

		SetRoomDesc(newValue,save)
			call(usr, "RoomDesc")(newValue)
			if(save) ChanMan.SaveHome()