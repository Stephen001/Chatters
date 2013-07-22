Channel
	var
		founder
		name
		desc
		topic
		QOTD

		Bot
			chanbot
		list
			chatters
			operators
			mute
			banned
			nodes
			ballots
			showcodes = list()

	New(params[])
		if(params)
			founder = params["Founder"]
			if(!founder) founder = Host.name
			name = params["Name"]
			desc = params["Desc"]
			topic = params["Topic"]
		..()
		chanbot = new /Bot(src)

	proc
		Join(mob/chatter/C)
			if(!C || !C.client)
				del C
				return

			if(C.Chan == src) return
			C.Chan = src
			winclone(C, "channel", ckey(name))
			winclone(C, "who", "[ckey(name)].who")
			winclone(C, "chat", "[ckey(name)].chat")
			var/window = ckey(name)
			winset(C, null, "[window].default_input.is-default=true;\
							[window].chat.default_output.is-default=true;\
							[window].chat.default_output.is-disabled=false;\
							[window].topic_label.text='[TextMan.escapeQuotes(topic)]';\
							[window].child.left=[window].chat;\
							[window].child.right=;\
							default.child.right=[window].who;\
							default.can-resize=true;\
							default.title='[name] - Chatters';\
							default.menu=menu;\
							default.child.left=[ckey(name)];")

			if(C.ckey in banned)
				C << output("<font color='red'>Sorry, you are banned from this channel.</font>", "[ckey(name)].chat.default_output")
				C << output("<font color='red'>Connection closed.</font>", "[ckey(name)].chat.default_output")
				del C
				return

			if(kText.hasPrefix(C.ckey, "guest")) if("guest" in banned)
				C << output("<font color='red'>Please login with your registered key, or visit <a href=\"http://www.byond.com/?invite=Cbgames\">http://www.byond.com/</a> to create a new key now.</font>", "[ckey(name)].chat.default_output")
				C << output("<font color='red'>Connection closed.</font>", "[ckey(name)].chat.default_output")
				del C
				return


			if(Host == C) winset(C, "default", "menu=host")

			if(C.flip_panes) winset(C, "default.child", "left=[ckey(C.Chan.name)].who;right=[ckey(C.Chan.name)];splitter=20")
			C.SetInterface(C.interface_color)

			winshow(C, ckey(name), 1)
			winset(C, "[ckey(Home.name)].chat.default_output", "style='[TextMan.escapeQuotes(C.default_output_style)]';")

			C << output("<center>- - - - - - - - - - - - - - -", "[ckey(name)].chat.default_output")

			if(C.show_title)
				if(C.show_colors)
					C << output({"<span style='text-align: center;'><b><font color='#0000ff'>[world.name] - Created by Xooxer</font></b></span>
<span style='text-align: center;'><b><font color='#0000ff'>and the BYOND Community</font></b></span>
<span style='text-align: center;'><b>[TextMan.fadetext("Still the greatest chat program on BYOND!", list("102000000","255000000","102000000","000000000","000000255"))]</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/Stephen001/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright (c) 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'><font color=red>- All Rights Reserved -</font></span>
"}, "[ckey(name)].chat.default_output")

				else
					C << output({"<span style='text-align: center;'><b>[world.name] - Created by Xooxer</b></span>
<span style='text-align: center;'><b>and the BYOND Community</b></span>
<span style='text-align: center;'><b>Still the greatest chat program on BYOND!</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/Stephen001/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright (c) 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'>- All Rights  Reserved -</span>
"}, "[ckey(name)].chat.default_output")

			if(C.show_qotd) TextMan.QOTD(C)

			if(C.show_welcome)
				C << output("<center>[time2text(world.realtime+C.time_offset, list2text(C.long_date_format))]<br><b>Welcome, [C.name]!</b></center>", "[ckey(name)].chat.default_output")

			C << output("<span style='text-align: center;'><b>Please report any issues with Chatters <a href='https://github.com/Stephen001/Chatters/issues?state=open'>here</a>!</b></span>", "[ckey(name)].chat.default_output")

			C << output("<center>- - - - - - - - - - - - - - -</center>", "[ckey(name)].chat.default_output")

			if(!chatters) chatters = new()
			chatters += C
			chatters = SortWho(chatters)

			C.icon_state = "active"
			UpdateWho()

			world.status = "[Home.name] founded by [Home.founder] ([Home.chatters.len] chatter\s)"

			winset(C, "[ckey(Home.name)].default_input", "text='> ';focus=true;")

			chanbot.Say("[C.name] has joined [name].")
			chanbot.Say("You have joined [name] founded by [founder].",C)
			chanbot.Say("[topic]",C)

			if(C.client.address)
				for(var/_ck in operators)
					var/mob/chatter/op = ChatMan.Get(_ck)
					if(op) chanbot.Say("[C.name]'s IP: [C.client.address]", op)

		Quit(mob/chatter/C)
			if(!C)
				for(var/i=1 to chatters.len)
					if(!chatters[i]) chatters -= chatters[i]
				UpdateWho()
				return

			C.Chan = null

			if(chatters) chatters -= C
			if(!chatters.len) chatters = null

			UpdateWho()

			chanbot.Say("[C.name] has quit [name].")

			if(C && ChatMan.istelnet(C.key))
				C.Logout()

		UpdateWho()
			for(var/mob/chatter/C in chatters)
				if(!ChatMan.istelnet(C.key))
					for(var/i=1, i<=chatters.len, i++)
						var/mob/chatter/c = chatters[i]
						if(isnull(c))
							chatters -= chatters[i]
							continue
						if(C.client) winset(C, "[ckey(name)].who.grid", "current-cell=1,[i]")
						var/n = c.name
						if(!ChatMan.istelnet(c.key) && c.afk)
							if(C.client)
								if(!(c.ckey in C.Chan.operators)) winset(C, "[ckey(name)].who.grid", "style='body{color: gray;}'")
								else winset(C, "[ckey(name)].who.grid", "style='body{color:gray;font-weight:bold}'")

						else if(c.ckey in C.Chan.operators)
							if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:[c.name_color];font-weight:bold}'")
						else if(c.ckey in C.Chan.mute)
							if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:[c.name_color];text-decoration:line-through;}'")
						else
							if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:[c.name_color];}'")
						C << output(c, "[ckey(name)].who.grid")
						c.name = n
				if(C.client)
					winset(C, "[ckey(name)].who.grid", "cells=1x[chatters.len]")

		SortWho(list/L)
			var/list/AFK
			for(var/mob/chatter/C in L)
				if(C.afk)
					if(!AFK) AFK = new
					L -= C
					AFK += C
					if(!L.len) L = null
			L = ListMan.atomSort(L)
			AFK = ListMan.atomSort(AFK)
			if(L && AFK)
				return L + AFK
			else if(AFK)
				return AFK
			else
				return L

		Say(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.", C)
				if(kText.hasPrefix(C.ckey, "guest")) chanbot.Say("Please login with your registered key, or visit http://www.byond.com/ to create a new key now.",C)
				return

			msg = copytext(msg, 1, 1024)

			if(!clean)
				msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(c.ignoring(C) & CHAT_IGNORE) continue
				var/message = raw_msg
				if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
				message = TextMan.ParseLinks(message)
				message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
				var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
				if(Parsedmsg) c << output(Parsedmsg, "[window]")


		Me(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			msg = copytext(msg, 1, 1024)

			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 1)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")

		My(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			msg = copytext(msg, 1, 1024)
			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 2)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")

		GoAFK(mob/chatter/C, msg)
			if(ChatMan.istelnet(C.key)) return
			C.afk = TRUE
			C.away_at = world.realtime
			msg = copytext(msg, 1, 1024)
			msg = TextMan.Sanitize(msg)
			C.away_reason = msg

			var/raw_msg = msg

			chatters = SortWho(chatters)
			C.icon_state = "away"
			UpdateWho()
			Home.chanbot.Say("You are now AFK.", C)
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						var/rsn = ""
						if(ckey(raw_msg)) rsn = "([raw_msg])"

						c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now AFK. [rsn]", "[ckey(name)].chat.default_output")

		ReturnAFK(mob/chatter/C)
			if(!C) return
			C.afk = FALSE
			C.away_reason = null
			chatters = SortWho(chatters)
			C.icon_state = "active"
			UpdateWho()
			Home.chanbot.Say("You are no longer AFK.", C)
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						c << output("[c.ParseTime()] <font color=[C.name_color]>[C.name]</font> is back from <b>AFK</b> after [round(((world.realtime - C.away_at)/600),1)] minute\s of inactivity.", "[ckey(name)].chat.default_output")
			C.away_at = null

		ismute(mob/M)
			if(mute && mute.len)
				var/search = ""
				if(istext(M)) search = ckey(M)
				else if(ismob(M)) search = M.ckey
				else return 1
				if(kText.hasPrefix(search, "guest"))
					if("guest" in mute) return 1
				else
					if(search in mute) return 1
