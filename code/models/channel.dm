Channel
	var
		founder
		name
		publicity
		desc
		topic
		locked
		telnet_pass
		telnet_attempts
		QOTD

		// spam controls
		spam_control =1
		spam_limit = 3
		flood_limit = 3
		smileys_limit = 10
		max_msgs = 3
		min_delay = 20

		room_desc = "An average looking room."
		room_desc_size

		Bot
			chanbot
		list
			chatters
			operators
			op_ranks
			op_privileges
			op_actions
			mute
			banned
			nodes
			ballots
			showcodes = list()

			filtered_words = list(	"fuck"	  =  "fudge",
									"shit"	  =  "dung",
									" ass"	  =  "donkey",
									" asshole"=  "donkeyhole",
									"penis"	  =  "pencil",
									"vagina"  =  "kitty",
									"pussy"	  =  "kitty",
									" cunt"	  =  "kitty",
									"bitch"	  =  "female dog",
									"faggot"  =  "bundle of sticks",
									" fag"	  =  "cigarette",
									"nigger"  =  "ignorant person",
									"nigga"   =  "homeslice",
									" dick"	  =  "private eye",
									" cock"	  =  "rooster",
									"cocksuck"=  "milkdrink")

	New(params[])
		if(params)
			founder = params["Founder"]
			if(!founder) founder = Host.name
			name = params["Name"]
			publicity = params["Publicity"]
			desc = params["Desc"]
			topic = params["Topic"]
			locked = text2num(params["Locked"]) ? 1 : 0
			telnet_pass = params["TelPass"]
			telnet_attempts = (text2num(params["TelAtmpts"]) || -1)
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
							default.size=[C.winsize];\
							default.can-resize=true;\
							default.title='[name] - Chatters';\
							default.menu=menu;\
							default.child.left=[ckey(name)];")
							//default.child.pos=4,4;\
							//default.child.size=[C.winsize];
/*			winset(C, "[ckey(name)].default_input", "is-default=true;")
			winset(C, "[ckey(name)].chat.default_output", "is-default=true;is-disabled=false.")
			winset(C, "[ckey(name)].topic_label", "text='[TextMan.escapeQuotes(topic)]';")
			winset(C, "[ckey(name)].child", "left=[ckey(name)].chat; right=[ckey(name)].who")
			winset(C, "default", "size=[C.winsize];can-resize=true;title='[name] - Chatters';menu=menu;")
			winset(C, "default.child", "pos=0,0;size=[C.winsize];left=[ckey(name)];")
*/

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

			if(!C.telnet && winget(C, "[ckey(name)].default_input", "is-disabled") == "true")
						// Returning from a kick/ban
				var/size = winget(C, "[ckey(name)].child", "size")
				var/X = copytext(size, 1, findtext(size,"x"))
				var/Y = text2num(copytext(size, findtext(size, "x")+1)) - 44
				winset(C, null, "[window].set.is-visible=true;\
								[window].help.is-visible=true;\
								[window].default_input.is-disabled=false;\
								[window].child.size=[X]x[Y];\
								[window].child.pos=0,0;")

			if(C.flip_panes) winset(C, "default.child", "left=[ckey(C.Chan.name)].who;right=[ckey(C.Chan.name)];splitter=20")
			C.SetInterface(C.interface_color)

			winshow(C, ckey(name), 1)
			winset(C, "[ckey(Home.name)].chat.default_output", "style='[TextMan.escapeQuotes(C.default_output_style)]';max-lines='[C.max_output]';")

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

			if(!Home.ismute(C)) EventMan.Parse(C, C.onJoin)

		Quit(mob/chatter/C)
			if(!C)
				for(var/i=1 to chatters.len)
					if(!chatters[i]) chatters -= chatters[i]
				UpdateWho()
				return

			if(!Home.ismute(C)) EventMan.Parse(C, C.onQuit)
			C.Chan = null

			if(chatters) chatters -= C
			if(!chatters.len) chatters = null

			UpdateWho()

			chanbot.Say("[C.name] has quit [name]")

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
							if(C.client) winset(C, "[ckey(name)].who.grid", "style='body{color:gray;}'")
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
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				if(kText.hasPrefix(C.ckey, "guest")) chanbot.Say("Please login with your registered key, or visit http://www.byond.com/ to create a new key now.",C)
				return

			if(length(msg)>512)
				var/part2 = copytext(msg, 513)
				msg = copytext(msg, 1, 513)
				spawn(20) C.Say(part2)

			if(!clean)
				msg = TextMan.Sanitize(msg)
				chanbot.SpamTimer(C, msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(c.ignoring(C) & CHAT_IGNORE) continue
				var/message
				if(!c.filter)
					message = raw_msg
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")
				else if(c.filter==1)
					message = TextMan.FilterChat(raw_msg,c)
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
					message = TextMan.ParseLinks(message)
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg) c << output(Parsedmsg, "[window]")
				else
					message = msg
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
						message = smsg
					message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
					var/Parsedmsg = c.ParseMsg(C,message,c.say_format)
					if(Parsedmsg)
						c << output(Parsedmsg, "[window]")


		Me(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			chanbot.SpamTimer(C, msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(!c.filter)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 1)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else if(c.filter==1)
						message = TextMan.FilterChat(raw_msg,c)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 1)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else
						message = msg
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
							message = smsg
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message, c.me_format, 1)
						if(Parsedmsg)
							c << output(Parsedmsg, "[window]")

		My(mob/chatter/C, msg, clean, window)
			if(ismute(C))
				chanbot.Say("I'm sorry, but you appear to be muted.",C)
				return

			if(!clean) msg = TextMan.Sanitize(msg)

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			var/smsg = TextMan.ParseSmileys(msg)
			smsg = TextMan.ParseLinks(smsg)

			msg = TextMan.ParseLinks(msg)
			chanbot.SpamTimer(C, msg)

			if(!window) window = "[ckey(name)].chat.default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(!c.filter)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(raw_msg)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 2)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else if(c.filter==1)
						message = TextMan.FilterChat(raw_msg,c)
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = TextMan.ParseSmileys(message)
						message = TextMan.ParseLinks(message)
						message = TextMan.ParseTags(message, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,message,c.me_format, 2)
						if(Parsedmsg) c << output(Parsedmsg, "[window]")
					else
						message = msg
						if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE))
							msg = smsg
						msg = TextMan.ParseTags(msg, c.show_colors, c.show_highlight,0)
						var/Parsedmsg = c.ParseMsg(C,msg, c.me_format, 2)
						if(Parsedmsg)
							c << output(Parsedmsg, "[window]")

		GoAFK(mob/chatter/C, msg)
			if(ChatMan.istelnet(C.key)) return
			C.afk = TRUE
			C.away_at = world.realtime
			msg = TextMan.Sanitize(msg)
			C.away_reason = msg

			var/raw_msg = msg
			msg = TextMan.FilterChat(msg)

			chatters = SortWho(chatters)
			C.icon_state = "away"
			UpdateWho()
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						if(!c.filter)
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [raw_msg])", "[ckey(name)].chat.default_output")
						else if(c.filter == 1)
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [TextMan.FilterChat(raw_msg,c)])", "[ckey(name)].chat.default_output")
						else
							c << output("[c.ParseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now <b>AFK</b>. (Reason: [msg])", "[ckey(name)].chat.default_output")
			C << output("Your activity status is now set to Away From Keyboard.", "[ckey(name)].chat.default_output")

		ReturnAFK(mob/chatter/C)
			if(!C) return
			C.afk = FALSE
			C.away_reason = null
			chatters = SortWho(chatters)
			C.icon_state = "active"
			UpdateWho()
			if(!ismute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						c << output("[c.ParseTime()] <font color=[C.name_color]>[C.name]</font> is back from <b>AFK</b> after [round(((world.realtime - C.away_at)/600),1)] minute\s of inactivity.", "[ckey(name)].chat.default_output")
			C.away_at = null
			C << output("Your activity status is now set to Active Chatter.", "[ckey(name)].chat.default_output")

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
