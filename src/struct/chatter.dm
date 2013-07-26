mob
	chatter
		icon = 'rsc/icons/who.dmi'
		icon_state = "active"

		var
			name_color = "#000000"
			text_color = "#000000"
			interface_color = "#555555"
			fade_name
			show_colors = TRUE

			time_24hr  = TRUE
			time_offset = 0
			auto_away = 15
			auto_reason = "I have gone auto-AFK."

			default_output_style = "body { background-color: #ffffff; }"

			show_smileys = TRUE
			show_title = TRUE
			show_welcome = FALSE
			show_motd = TRUE
			show_qotd = TRUE
			show_highlight = TRUE
			flip_panes = FALSE

			tmp/afk = FALSE
			tmp/telnet = FALSE
			tmp/away_at = 0
			tmp/away_reason
			tmp/list/msgs
			tmp/MessageHandler/msg_hand
			tmp/color_scope
			tmp/AssocEntry/viewing_entry
			tmp/viewing_log

			list
				ignoring
				fade_colors = list("#000000")

				time_format = list("<font size=1>\[","hh",":","mm",":","ss","]</font>")
				date_format = list("MMM"," ","MM",", `","YY")
				long_date_format = list("Day",", ","Month"," ","DD",", ","YYYY")
				say_format = list("$ts", " <b>","$name",":</b> ","$msg")
				rpsay_format = list("$ts", " ","$name"," ","$rp",":   ","$msg")
				me_format = list("$ts", " ", "$name", " ", "$msg")

				tmp/msg_handlers

		New()
			..()

			msg_hand = new(src)

		Login()
			..()

			chatter_manager.usher(src)

			if(!chatter_manager.isTelnet(key))
				server_manager.home.join(src)

				winshow(src, "showcontent", 0)
				winshow(src, "settings", 0)

				refreshAllSettings()

				spawn() inactivityLoop()

			// Telnet users login differently
			else
				//Set options suited for telnet.
				telnet = TRUE
				show_colors = FALSE
				show_smileys = FALSE
				show_highlight = FALSE

				server_manager.home.join(src)

		Logout()
			if(server_manager)
				server_manager.home.quit(src)

			..()

			del(src)

		proc
			inactivityLoop()
				while(src && client)
					if(auto_away && (auto_away < client.inactivity/600) && !afk) afk(auto_reason)
					sleep(100)

			colorDisplay(scope)
				if(!scope) return
				color_scope = scope

				winshow(src, "color_picker", 1)

			returnAFK()
				server_manager.home.returnAFK(src)

			parseMsg(mob/chatter/M, msg, msg_format[], emote, rp)
				if(!M || !msg || !msg_format || !length(msg_format))
					return

				var
					parsed_msg = ""
					ign = ignoring(M)

				msg = textutil.trimWhitespace(msg)
				var/rp_start = findtext(msg, ":")

				if(rp_start == 1)
					var/rp_end = findtext(msg, ":", 2)

					if(rp_end)
						var/RP = copytext(msg, 2, rp_end)
						msg = copytext(msg, rp_end + 1)

						return parseMsg(M, msg, rpsay_format, 0, RP)

				var
					punctuation
					msg_punctuation = copytext(msg, length(msg))

				switch(msg_punctuation)
					if(".") punctuation = "."
					if("!") punctuation = "!"
					if("?") punctuation = "?"
					else punctuation = "."

				for(var/s in msg_format)
					if(s == "$name")
						if((ign & COLOR_IGNORE) || !show_colors)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s") end = "'"

								parsed_msg += M.name+end

							else parsed_msg += M.name
						else if((ign & FADE_IGNORE) || emote || rp)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s") end = "'"

								parsed_msg += "<font color=[M.name_color]>[M.name][end]</font>"

							else parsed_msg += "<font color=[M.name_color]>[M.name]</font>"
						else
							if(M.fade_name) parsed_msg += M.fade_name
							else parsed_msg += "<font color=[M.name_color]>[M.name]</font>"

					else if(s == "$rp")
						if((ign & COLOR_IGNORE) || !show_colors) parsed_msg += rp
						else if(M.name_color) parsed_msg += "<font color=[M.name_color]>[rp]</font>"

					else if(s == "$msg")
						if((ign & COLOR_IGNORE) || !show_colors) parsed_msg += msg
						else if(!emote) parsed_msg += "<font color=[M.text_color]>[msg]</font>"
						else parsed_msg += "<font color=[M.name_color]>[msg]</font>"

					else if(s == "$ts") parsed_msg += parseTime()
					else if(s == "says")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaims"
							if("?") parsed_msg += "asks"

					else if(s == "said")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaimed"
							if("?") parsed_msg += "asked"

					else parsed_msg += s

				return parsed_msg

			parseTime(hide_ticker)
				var
					parsed_msg = ""
					timestamp = round(world.timeofday + src.time_offset * 36000, 1)
					hour = time2text(timestamp, "hh")
					min = time2text(timestamp, "mm")
					sec = time2text(timestamp, "ss")

				if(!time_24hr)
					hour = text2num(hour)
					var/ampm = " [hour > 11 ? "pm" : "am"]"

					hour = (hour % 12) || 12
					hour = "[hour < 10 ? "0" : ""][hour]"

					if("ss" in time_format) sec += ampm
					else if("mm" in time_format) min += ampm
					else hour += ampm

				for(var/delimiter in time_format)
					switch(delimiter)
						if("hh") parsed_msg += hour
						if("mm") parsed_msg += min
						if("ss") parsed_msg += sec
						if(":")  parsed_msg += hide_ticker ? " " : ":"
						else 	 parsed_msg += delimiter

				return parsed_msg

			ignoring(mob/M)
				if(ignoring && length(ignoring))
					if(istext(M))
						if(ckey(M) in ignoring)
							var/ign = ignoring[ckey(M)]

							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign

					if(ismob(M))
						if(ckey(M.name) in ignoring)
							var/ign = ignoring[ckey(M.name)]

							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign

		verb
			viewHelp()
				set hidden = 1

				if(winget(src, "help", "is-visible") == "true") winshow(src, "help", 0)
				else winshow(src, "help")

			viewGithub()
				set hidden = 1

				src << link("http://www.github.com/Stephen001/Chatters/")

			selectColor(scope as text|null)
				set hidden = 1

				if(!scope) return
				colorDisplay(scope)

			sayAlias(msg as text|null)
				set name = ">"
				set hidden = 1

				say(msg)

			listOps()
				if(length(server_manager.home.operators)) server_manager.bot.say("The channel operators are: [textutil.list2text(server_manager.home.operators, ", ")]", src)

			listBanned()
				if(length(server_manager.home.banned)) server_manager.bot.say("The following users are banned: [textutil.list2text(server_manager.home.banned, ", ")]", src)
				else server_manager.bot.say("There are no users currently banned.", src)

			listMuted()
				if(length(server_manager.home.mute)) server_manager.bot.say("The following users are muted: [textutil.list2text(server_manager.home.mute, ", ")]", src)
				else server_manager.bot.say("There are no users currently muted.", src)

			settings()
				if(telnet) return
				toggleSettings()

			say(msg as text|null)
				if(!msg) return
				if(afk) returnAFK()
				server_manager.home.say(src, msg)

			me(msg as text|null)
				if(!msg) return
				if(afk) returnAFK()
				server_manager.home.me(src, msg)

			my(msg as text|null)
				if(!msg) return
				if(afk) returnAFK()
				server_manager.home.my(src, msg)

			im(target as text|null|mob in server_manager.home.chatters, msg as text|null)
				if(telnet) return
				if(!target)
					var/Messenger/im = new(src)
					im.display(src)
					return

				var/mob/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				if(!C) server_manager.bot.say("[target] is not currently online.", src)
				else
					if(ismob(C))
						if(!msg)
							var/Messenger/im = new(src, C.name)
							im.display(src)

							return

						msg = copytext(msg, 1, 1024)
						if(textutil.isWhitespace(msg)) return

						var/Messenger/im = new(src, C.name)
						im.display(src)

						msg_hand.routeMsg(src, C, msg)

					else
						if(!msg)
							var/Messenger/im = new(src, C)
							im.display(src)

							return

						msg = copytext(msg, 1, 1024)
						if(textutil.isWhitespace(msg)) return

						var/Messenger/im = new(src, C)
						im.display(src)

						var
							savefile/S = new()
							mob/chatter/M = new()

						M.name = name
						M.name_color = name_color
						M.fade_name = fade_name
						M.text_color = text_color
						M.fade_name = fade_name

						S["from"] << M
						S["msg"] << msg
						S["to"] << C

						src << output(src.parseMsg(src, msg, src.say_format), "cim_[C.ckey].output")

			ignore(mob/target as text|null|mob in server_manager.home.chatters, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target)
					server_manager.bot.say("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
					return

				if(!ignoring) ignoring = new
				if(ismob(target)) target = target.name

				var/is_ignored = ignoring(target)

				if(is_ignored == FULL_IGNORE)
					server_manager.bot.say("You are already ignoring [target].", src)
					return

				if(!scope) scope = "[FULL_IGNORE]"
				var/ignore_type = "this scope"

				switch(scope)
					if("im")
						scope = "[IM_IGNORE]"
						ignore_type = "instant messages"

					if("chat")
						scope = "[CHAT_IGNORE]"
						ignore_type = "chat messages"

					if("fade")
						scope = "[FADE_IGNORE]"
						ignore_type = "fades"

					if("colors")
						scope = "[COLOR_IGNORE]"
						ignore_type = "colors"

					if("smileys")
						scope = "[SMILEY_IGNORE]"
						ignore_type = "smileys"

					if("images")
						scope = "[IMAGES_IGNORE]"
						ignore_type = "images"

					if("files")
						scope = "[FILES_IGNORE]"
						ignore_type = "files"

					if("full")
						scope = "[FULL_IGNORE]"

				var/num = text2num(scope)
				if(num && isnum(num))
					if(num & is_ignored)
						server_manager.bot.say("You are already ignoring [ignore_type] from [target].", src)
						return

					num += is_ignored
					ignore_type = ""

					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0

						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							ignore_type += "\n - instant messages"

							if(ckey(target) in msg_handlers)
								winset(src, "cim_[ckey(target)]", "is-visible=false")

						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							ignore_type += "\n - chat messages"

						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							ignore_type += "\n - fade name"

						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							ignore_type += "\n - colors"

						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							ignore_type += "\n - smileys"

						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							ignore_type += "\n - images"

						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							ignore_type += "\n - files"

						if(!scope)
							server_manager.bot.say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
							return

				else
					server_manager.bot.say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full", src)
					return

				if(!is_ignored) ignoring += ckey(target)
				ignoring[ckey(target)] = scope

				if(length(ignore_type)) server_manager.bot.say("You are now ignoring the following from [target]: [ignore_type].", src)
				else server_manager.bot.say("You are now fully ignoring [target].", src)

				chatter_manager.save(src)

			unignore(mob/target as text|null|anything in ignoring, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target) server_manager.bot.say("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)

				if(!ignoring || !length(ignoring))
					server_manager.bot.say("You are not currently ignoring any chatters.", src)
					return

				if(ismob(target)) target = target.name

				var/ign = ignoring(target)
				if(!ign)
					server_manager.bot.say("You are not currently ignoring [target]", src)
					return

				if(!scope) scope = "[FULL_IGNORE]"
				var/ignore_type = "this scope"

				switch(scope)
					if("im")
						scope = "[IM_IGNORE]"
						ignore_type = "instant messages"

					if("chat")
						scope = "[CHAT_IGNORE]"
						ignore_type = "chat messages"

					if("fade")
						scope = "[FADE_IGNORE]"
						ignore_type = "fades"

					if("colors")
						scope = "[COLOR_IGNORE]"
						ignore_type = "colors"

					if("smileys")
						scope = "[SMILEY_IGNORE]"
						ignore_type = "smileys"

					if("images")
						scope = "[IMAGES_IGNORE]"
						ignore_type = "images"

					if("files")
						scope = "[FILES_IGNORE]"
						ignore_type = "files"

					if("full")
						scope = "[FULL_IGNORE]"

				var/num = text2num(scope)
				if(num && isnum(num))
					if((num != FULL_IGNORE) && !(num & ign))
						server_manager.bot.say("You are not currently ignoring [ignore_type] from [target].", src)
						return

					ignore_type = ""

					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0

						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							if(ign - IM_IGNORE)
								ignore_type += "\n - instant messages"

						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							if(ign - CHAT_IGNORE)
								ignore_type += "\n - chat messages"

						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							if(ign - FADE_IGNORE)
								ignore_type += "\n - fade name"

						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							if(ign - COLOR_IGNORE)
								ignore_type += "\n - colors"

						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							if(ign - SMILEY_IGNORE)
								ignore_type += "\n - smileys"

						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							if(ign - IMAGES_IGNORE)
								ignore_type += "\n - images"

						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							if(ign - FILES_IGNORE)
								ignore_type += "\n - files"

						if(!scope)
							server_manager.bot.say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
							return

				else
					server_manager.bot.say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
					return

				if(scope == FULL_IGNORE) ignoring -= ckey(target)
				else ignoring[ckey(target)] &= ~scope

				if(!ignoring[ckey(target)])
					ignoring -= ckey(target)
					ignore_type = ""

				if(length(ignore_type)) server_manager.bot.say("You are no longer ignoring the following from [target]: [ignore_type]", src)
				else server_manager.bot.say("You are no longer ignoring [target].", src)

				chatter_manager.save(src)

			listIgnored(mob/target as text|null|anything in ignoring)
				if(!ignoring || !length(ignoring))
					server_manager.bot.say("You are not currently ignoring any chatters.", src)
					return

				var/ignored
				for(var/i in ignoring)
					var/scoped

					if((ignoring[i] & FULL_IGNORE)) scoped = "full ignore"
					else
						if((ignoring[i] & IM_IGNORE))
							if(!scoped) scoped = "IMs"
							else scoped += ", IMs"

						if((ignoring[i] & CHAT_IGNORE))
							if(!scoped) scoped = "chat"
							else scoped += ", chat"

						if((ignoring[i] & FADE_IGNORE))
							if(!scoped) scoped = "fade name"
							else scoped += ", fade name"

						if((ignoring[i] & COLOR_IGNORE))
							if(!scoped) scoped = "colors"
							else scoped += ", colors"

						if((ignoring[i] & SMILEY_IGNORE))
							if(!scoped) scoped = "smileys"
							else scoped += ", smileys"

						if((ignoring[i] & IMAGES_IGNORE))
							if(!scoped) scoped = "images"
							else scoped += ", images"

						if((ignoring[i] & FILES_IGNORE))
							if(!scoped) scoped = "files"
							else scoped += ", files"

					ignored += "<b>[i]</b> ([scoped]) "

				server_manager.bot.rawSay("You are currently ignoring the following chatters: [ignored]", src)
				return

			share()
				if(winget(src, "showcontent", "is-visible") == "false")
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent")

				else
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent", 0)

			showCode()
				set hidden = 1

				if(telnet) return
				if(afk) returnAFK()

				var/ShowcodeSnippet/S = new

				if(server_manager.home.isMute(src))
					server_manager.bot.say("I'm sorry, but you appear to be muted.", src)
					return

				var/iCode = winget(src, "showcontent.content_input", "text")

				if(!iCode)
					del(S)
					return 0

				S.owner = "[src.name]"
				S.code = iCode
				S.send(1)

				winshow(src, "showcontent", 0)
				winset(src, "showcontent.content_input", "text=")

			showText(t as text|null|mob in server_manager.home.chatters)
				set hidden = 1

				if(telnet) return
				if(afk) returnAFK()
				var/ShowcodeSnippet/S = new

				if(server_manager.home.isMute(src))
					server_manager.bot.say("I'm sorry, but you appear to be muted.", src)
					return

				var/iCode = winget(src, "showcontent.content_input", "text")

				if(!iCode)
					del(S)

					return 0

				S.owner = "[src.name]"
				S.code = iCode
				S.send()

				winshow(src, "showcontent", 0)
				winset(src, "showcontent.content_input", "text=")

			afk(msg as text|null)
				if(!server_manager.home || telnet) return
				if(!afk)
					if(!msg) msg = auto_reason
					server_manager.home.goAFK(src, msg)

				else returnAFK()

			/* OP COMMANDS */

			promote(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(ckey(server_manager.host) != ckey)
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(!server_manager.home.operators) server_manager.home.operators = list()

				if(ckey(server_manager.host) == ckey(target)) return
				if(ckey(target) in server_manager.home.operators) server_manager.bot.say("[target] is already an operator.", src)
				else
					server_manager.bot.say("[target] was promoted to operator by [name].")
					server_manager.home.operators += ckey(target)

				server_manager.home.updateWho()
				server_manager.logger.trace("[key] promoted [target] to operator.")

				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				if(C) winset(C, "[ckey(server_manager.home.name)].ops_button", "is-visible=true")

			demote(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(ckey(server_manager.host) != ckey)
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(ckey(server_manager.host) == ckey(target)) return
				if(!(ckey(target) in server_manager.home.operators)) server_manager.bot.say("[target] is not an operator.", src)
				else
					server_manager.bot.say("[target] was demoted by [name].")
					server_manager.home.operators -= ckey(target)

				server_manager.home.updateWho()
				server_manager.logger.trace("[key] demoted [target] from operator.")

				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				if(C) winset(C, "[ckey(server_manager.home.name)].ops_button", "is-visible=true")

			setTopic(ntopic as text)
				set hidden = 1

				if(!ntopic) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.setTopic(ntopic, 1)
				server_manager.logger.trace("[key] set the topic to [ntopic].")

			botSetTextColor(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.setTextColor(n, 1)
				server_manager.logger.trace("[key] set the bot text color to [n].")

			botSetNameColor(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.setNameColor(n, 1)
				server_manager.logger.trace("[key] set the bot name color to [n].")

			botSetName(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.setName(n, 1)
				server_manager.logger.trace("[key] set the bot's name to [n].")

			botSay(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.say(n)
				server_manager.logger.trace("[key] issued botSay: [html_encode(n)]")

			botMe(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.me(n)
				server_manager.logger.trace("[key] issued botMe: [html_encode(n)]")

			botMy(n as text)
				set hidden = 1

				if(!n) return
				if(!server_manager.bot) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				server_manager.bot.my(n)
				server_manager.logger.trace("[key] issued botMy: [html_encode(n)]")

			purgeAssoc(data as text)
				set hidden = 1

				if(!data) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(data)
					var/d = assoc_manager.purge(data)
					if(d) server_manager.bot.say("Purged [data] from the association database: [d] entrie(s) removed.", src)
					else server_manager.bot.say("No entries found for [data] to be purged.", src)

				server_manager.logger.trace("[key] purged \"[data]\" from association database.")

			checkAssoc(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				var/AssocEntry/entry

				if(C && C.client) entry = assoc_manager.findByClient(C.client)
				else
					entry = assoc_manager.findByCkey(ckey(target))
					if(!entry) entry = assoc_manager.findByIP(target)
					if(!entry) entry = assoc_manager.findByCID(target)

				if(entry)
					server_manager.bot.say("[target] has the following information in the association database:", src)
					server_manager.bot.rawSay("<b>Associated ckeys:</b> [textutil.list2text(entry.ckeys, ", ")]", src)
					server_manager.bot.rawSay("<b>Associated ips:</b> [textutil.list2text(entry.ips, ", ")]", src)
					server_manager.bot.rawSay("<b>Associated computer ids:</b> [textutil.list2text(entry.cids, ", ")]", src)

				else server_manager.bot.say("No information found for [target].", src)

				server_manager.logger.trace("[key] searched for \"[target]\" in the association database.")

			checkIP(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				if(!C)
					server_manager.bot.say("[target] is not currently in the channel.", src)
					return

				if(C.client.address) server_manager.bot.say("[C.name]'s IP: [C.client.address]", src)
				else server_manager.bot.say("[C.name]'s IP is unknown.", src)

				server_manager.logger.trace("[key] checked the IP of [target].")

			mute(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(!server_manager.home.mute) server_manager.home.mute = list()

				if(!(ckey(target) in server_manager.home.operators))
					if(!(ckey(target) in server_manager.home.mute))
						server_manager.bot.say("[target] has been muted by \[b][name]\[/b].")
						server_manager.home.mute += ckey(target)
						server_manager.home.updateWho()

					else server_manager.bot.say("[target] is already mute.", src)

				else server_manager.bot.say("You cannot mute an operator.", src)

				server_manager.logger.trace("[key] muted [target].")

			unmute(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(!server_manager.home.mute) server_manager.home.mute = new
				if(!(ckey(target) in server_manager.home.operators))
					if(ckey(target) in server_manager.home.mute)
						server_manager.bot.say("[target] has been unmuted by \[b][name]\[/b].")
						server_manager.home.mute -= ckey(target)
						server_manager.home.updateWho()

					else server_manager.bot.say("[target] is not muted.", src)

				server_manager.logger.trace("[key] unmuted [target].")

			kick(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				var/mob/chatter/C
				if(ismob(target)) C = target
				else C = chatter_manager.getByKey(target)

				if(!C)
					server_manager.bot.say("[target] is not currently in the channel.", src)
					return

				if(ckey(target) in server_manager.home.operators)
					server_manager.bot.say("You cannot kick an operator.", src)
					return

				server_manager.bot.say("[C.name] has been kicked by \[b][name]\[/b].")
				server_manager.logger.trace("[key] kicked [C.name].")

				C << output("You have been kicked from [server_manager.home.name] by [name].", "chat.default_output")
				C << output("<font color=red>Connection closed.", "chat.default_output")

				server_manager.home.chatters -= C
				server_manager.home.updateWho()

				C.Logout()

			ban(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				var/mob/chatter/C = chatter_manager.getByKey(target)

				if(ckey(target) in server_manager.home.operators)
					server_manager.bot.say("You cannot ban an operator.", src)
					return

				if(!server_manager.home.banned) server_manager.home.banned = list()

				server_manager.bot.say("[target] has been banned by \[b][name]\[/b].")
				server_manager.home.banned += ckey(target)

				server_manager.logger.trace("[key] banned [target].")

				if(C)
					C << output("You have been banned from [server_manager.home.name] by [name]", "chat.default_output")
					C << output("<font color=red>Connection closed.", "chat.default_output")

					server_manager.home.chatters -= C
					server_manager.home.updateWho()

					C.Logout()

			unban(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				if(ckey(target) in server_manager.home.banned)
					server_manager.bot.say("[target] has been unbanned by \[b][name]\[/b].")
					server_manager.home.banned -= ckey(target)

				server_manager.logger.trace("[key] unbanned [target].")

			geolocate(target as text)
				set hidden = 1

				if(!target) return
				if(!server_manager.home) return
				if(!(ckey in server_manager.home.operators))
					server_manager.bot.say("You do not have access to this command.", src)
					return

				var/list/data = assoc_manager.geolocate(target)

				if(data && (length(data) > 1) && ("ip" in data))
					server_manager.bot.say("The following information was found for [target]:", src)
					if(data["country_name"]) server_manager.bot.rawSay("<b>Country:</b> [data["country_name"]]", src)
					if(data["region_name"]) server_manager.bot.rawSay("<b>Region:</b> [data["region_name"]]", src)
					if(data["city"]) server_manager.bot.rawSay("<b>City:</b> [data["city"]]", src)
					if(data["latitude"] && data["longitude"]) server_manager.bot.rawSay("<b>Click <a href=https://maps.google.com/maps?q=[data["latitude"]]+[data["longitude"]]>here</a> to view on Google Maps.</b>", src)

				else server_manager.bot.say("Failed to geolocate [target].", src)

				server_manager.logger.trace("[key] used geolocate to search for \"[target]\".")

			/* SETTINGS */

			setDefaultMisc()
				set hidden = 1

				setShowSmileys(1)

			setShowSmileys(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "misc.show_smileys", "is-checked=true")
					show_smileys = TRUE

				else
					if(winget(src, "misc.show_smileys", "is-checked")=="true") show_smileys = TRUE
					else show_smileys = FALSE

			flipPanes()
				set hidden = 1

				if(winget(src, "misc.flip_panes", "is-checked")=="true") flip_panes = TRUE
				else flip_panes = FALSE

				if(!flip_panes) winset(src, "default.child", "left=[ckey(server_manager.home.name)];right=[ckey(server_manager.home.name)].who;splitter=80")
				else winset(src, "default.child", "left=[ckey(server_manager.home.name)].who;right=[ckey(server_manager.home.name)];splitter=20")

			toggleSettings()
				set hidden = 1

				if(winget(src, "settings", "is-visible") == "false")
					setDisplay("colors")
					winshow(src, "settings")

				else winshow(src, "settings", 0)

			saveAllSettings()
				set hidden = 1

				winset(src, "settings.saving", "is-visible=true")

				var
					NameColor = winget(src, "style_colors.name_color", "text")
					TextColor = winget(src, "style_colors.text_color", "text")
					InterfaceColor = winget(src, "style_colors.interface_color", "text")

				setNameColor(NameColor)
				setTextColor(TextColor)
				setInterfaceColor(InterfaceColor)

				server_manager.home.updateWho()

				if(winget(src, "misc.show_smileys", "is-checked")=="true") setShowSmileys(1)
				else setShowSmileys()

				setShowTitle()
				setShowWelcome()
				setShowMotD()
				setShowQotD()
				setHighlightCode()

				var
					TimeOffset = winget(src, "system.offset", "text")
					AutoAFK = text2num(winget(src, "system.auto_afk", "text"))
					AwayMsg = winget(src, "system.away_msg", "text")

				setTimeOffset(text2num(TimeOffset))
				setAutoAFK(AutoAFK)
				setAwayMsg(AwayMsg)

				var
					ChatFormat = winget(src, "style_formats.chat_format", "text")
					EmoteFormat = winget(src, "style_formats.emote_format", "text")
					InlineEmoteFormat = winget(src, "style_formats.inline_emote_format", "text")
					TimeFormat = winget(src, "style_formats.time_format", "text")
					DateFormat = winget(src, "style_formats.date_format", "text")
					LongDateFormat = winget(src, "style_formats.long_date_format", "text")
					OutputStyle = winget(src, "style_formats.output_style", "text")

				setDateFormat(DateFormat)
				setTimeFormat(TimeFormat)
				setInlineEmoteFormat(InlineEmoteFormat)
				setEmoteFormat(EmoteFormat)
				setChatFormat(ChatFormat)
				setLongDateFormat(LongDateFormat)
				setOutputStyle(OutputStyle)

				chatter_manager.save(src)

				winset(src, "settings.saving", "is-visible=false")

			refreshAllSettings()
				set hidden = 1

				winset(src, "settings.saving", "is-visible=false")

				if(flip_panes) winset(src, "misc.flip_panes", "is-checked=true")
				else winset(src, "misc.flip_panes", "is-checked=false")

				winset(src, "style_colors.name_color", "text='[name_color]'")
				winset(src, "style_colors.name_color_button", "background-color='[name_color]'")
				winset(src, "style_colors.text_color", "text='[text_color]'")
				winset(src, "style_colors.text_color_button", "background-color='[text_color]'")
				winset(src, "style_colors.interface_color", "text='[interface_color]'")
				winset(src, "style_colors.interface_button", "background-color='[interface_color]'")

				src << output(null, "style_colors.output")

				if(fade_name) src << output("[fade_name]", "style_colors.output")
				else src << output("<font color=[name_color]>[name]</font>", "style_colors.output")

				if(show_colors)
					winset(src, "style_colors.show_colors", "is-checked=true")
					winset(src, "style_colors.no_colors", "is-checked=false")

				else
					winset(src, "style_colors.show_colors", "is-checked=false")
					winset(src, "style_colors.no_colors", "is-checked=true")

				winset(src, "style_formats.chat_format", "text='[textutil.list2text(say_format, "")]'")
				winset(src, "style_formats.emote_format", "text='[textutil.list2text(me_format, "")]'")
				winset(src, "style_formats.inline_emote_format", "text='[textutil.list2text(rpsay_format, "")]'")
				winset(src, "style_formats.time_format", "text='[textutil.list2text(time_format, "")]'")
				winset(src, "style_formats.date_format", "text='[textutil.list2text(date_format, "")]'")
				winset(src, "style_formats.long_date_format", "text='[textutil.list2text(long_date_format, "")]'")
				winset(src, "style_formats.output_style", "text=\"[text_manager.escapeQuotes(default_output_style)]\"")

				if(show_title) winset(src, "system.show_title", "is-checked=true")
				else winset(src, "system.show_title", "is-checked=false")

				if(show_welcome) winset(src, "system.show_welcome", "is-checked=true")
				else winset(src, "system.show_welcome", "is-checked=false")

				if(show_motd) winset(src, "system.show_motd", "is-checked=true")
				else winset(src, "system.show_motd", "is-checked=false")

				if(show_qotd) winset(src, "system.show_qotd", "is-checked=true")
				else winset(src, "system.show_qotd", "is-checked=false")

				if(show_highlight) winset(src, "system.show_highlight", "is-checked=true")
				else winset(src, "system.show_highlight", "is-checked=false")

				if(!time_24hr)
					winset(src, "system.24Hour", "is-checked=false")
					winset(src, "system.12Hour", "is-checked=true")

				winset(src, "system.offset", "text='[time_offset]'")

				var/time = text_manager.stripHTML(parseTime())
				src << output(time, "system.time")

				winset(src, "system.auto_afk", "text=\"[auto_away]\"")
				winset(src, "system.away_msg", "text=\"[text_manager.escapeQuotes(auto_reason)]\"")

			setDisplay(page as text)
				set hidden = 1
				refreshAllSettings()

				switch(page)
					if("colors") winset(src, "settings.settings_child", "left=style_colors")
					if("formats") winset(src, "settings.settings_child", "left=style_formats")
					if("misc") winset(src, "settings.settings_child", "left=misc")
					if("system") winset(src, "settings.settings_child", "left=system")

			setDefaultFormatStyle()
				set hidden = 1

				setChatFormat()
				setEmoteFormat()
				setInlineEmoteFormat()
				setTimeFormat()
				setDateFormat()
				setLongDateFormat()
				setOutputStyle()

			setChatFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts <b>$name:</b> $msg"

				var
					list/variables = list("$ts","$name","$msg","says","said")
					list/required = list("$name","$msg")

				say_format = chatter_manager.parseFormat(t, variables, required)
				winset(src, "style_formats.chat_format", "text=\"[text_manager.escapeQuotes(t)]\"")

			setEmoteFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts $name $msg"

				var
					list/variables = list("$ts","$name","$msg")
					list/required = list("$name","$msg")

				me_format = chatter_manager.parseFormat(t, variables, required)
				winset(src, "style_formats.emote_format", "text=\"[text_manager.escapeQuotes(t)]\"")

			setInlineEmoteFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts $name $rp: $msg"

				var
					list/variables = list("$ts","$name","$rp","$msg","says","said")
					list/required = list("$name","$rp","$msg")

				rpsay_format = chatter_manager.parseFormat(t, variables, required)
				winset(src, "style_formats.inline_emote_format", "text=\"[text_manager.escapeQuotes(t)]\"")

			setTimeFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "<font size=1>\[hh:mm:ss]</font>"

				var/list/variables = list("hh","mm","ss")
				time_format = chatter_manager.parseFormat(t, variables)
				winset(src, "style_formats.time_format", "text=\"[text_manager.escapeQuotes(t)]\"")

			setDateFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "MMM MM, `YY"

				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				date_format = chatter_manager.parseFormat(t, variables)
				winset(src, "style_formats.date_format", "text=\"[text_manager.escapeQuotes(t)]\"")

			setLongDateFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "Day, Month DD, YYYY"

				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				long_date_format = chatter_manager.parseFormat(t, variables)
				winset(src, "style_formats.long_date_format", "text='[t]'")

			setOutputStyle(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "body { background-color: #ffffff; }"

				default_output_style = t
				winset(src, "[ckey(server_manager.home.name)].chat.default_output", "style=\"[text_manager.escapeQuotes(t)]\";")
				winset(src, "style_formats.output_style", "text=\"[text_manager.escapeQuotes(default_output_style)]\";")

			setDefaultColorStyle()
				set hidden = 1

				fade_colors.len = 1
				fade_colors[1] = "#000000"
				fade_name = null

				setNameColor("#000000")
				setTextColor("#000000")
				fadeName()
				fadeColors(1)
				fadeNameDone()
				setInterfaceColor()
				setShowColors()

				server_manager.home.updateWho()

			fadeName()
				set hidden = 1

				winset(src, "style_colors.fade_help", "is-visible=true")
				winset(src, "style_colors.fadecolors", "is-visible=true")
				winset(src, "style_colors.colors", "is-visible=true;text=[length(fade_colors)]")
				winset(src, "style_colors.set_colors", "is-visible=true")
				winset(src, "style_colors.done", "is-visible=true")

				for(var/i = 1, i <= length(fade_colors), i ++)
					winset(src, "style_colors.color[i]", "is-visible=true;background-color=[fade_colors[i]]")

			fadeColors(n as num|null)
				set hidden = 1

				if(!isnum(n)) n = text2num(winget(src, "style_colors.colors", "text"))
				if(n > length(name)) n = length(name)

				fade_colors.len = n
				winset(src, "style_colors.colors", "is-visible=true;text=[n]")

				for(var/i = 0, (i + 1) <= n, i ++)
					if(!fade_colors[i + 1]) fade_colors[i + 1] = "#000000"
					winset(src, "style_colors.color[i+1]", "is-visible=true;background-color=[fade_colors[i + 1]]")

				for(var/i = 12, i > n, i --) winset(src, "style_colors.color[i]", "is-visible=false")

			fadeNameDone()
				set hidden = 1

				var/list/colors = new()
				for(var/c in fade_colors)
					var/red = text_manager.hex2dec(copytext(c, 2, 4))

					if(red < 100)
						if(red > 10) red = "0[red]"
						else red = "00[red]"

					else red = "[red]"

					var/grn = text_manager.hex2dec(copytext(c, 4, 6))

					if(grn < 100)
						if(grn > 10) grn = "0[grn]"
						else grn = "00[grn]"

					else grn = "[grn]"

					var/blu = text_manager.hex2dec(copytext(c, 6))
					if(blu < 100)
						if(blu > 10) blu = "0[blu]"
						else blu = "00[blu]"

					else blu = "[blu]"

					colors += red + grn + blu

				var/invalid = FALSE

				if(length(colors))
					var
						i = colors[1]
						same = 1

					for(var/c in colors)
						if(c != i)
							same = 0

							break

					if(same) invalid = TRUE

				if(!colors || !length(colors) || invalid || (fade_name == name)) fade_name = null
				else fade_name = text_manager.fadeText(name, colors)

				winset(src, "style_colors.fade_help", "is-visible=false")
				winset(src, "style_colors.fadecolors", "is-visible=false")
				winset(src, "style_colors.colors", "is-visible=false")
				winset(src, "style_colors.set_colors", "is-visible=false")
				winset(src, "style_colors.done", "is-visible=false")

				for(var/i = 1, i <= length(fade_colors), i ++)
					winset(src, "style_colors.color[i]", "is-visible=false")

				src << output(null, "style_colors.output")

				if(fade_name) src << output("[fade_name]", "style_colors.output")
				else src << output("<font color=[name_color]>[name]</font>", "style_colors.output")

			setNameColor(t as text|null)
				set hidden = 1

				if(!t) t = "#000000"
				if(copytext(t, 1, 2) != "#") t = "#" + t

				if(t && length(t) == 7)
					name_color = uppertext(t)

					winset(src, "style_colors.name_color_button", "background-color='[t]'")
					winset(src, "style_colors.name_color", "text='[t]'")

					src << output(null, "style_colors.output")

					if(fade_name) src << output("[fade_name]", "style_colors.output")
					else src << output("<font color=[name_color]>[name]</font>", "style_colors.output")

					server_manager.home.updateWho()

			setTextColor(t as text|null)
				set hidden = 1

				if(!t) t = "#000000"
				if(copytext(t, 1, 2) != "#") t = "#" + t

				if(t && length(t) == 7)
					text_color = uppertext(t)

					winset(src, "style_colors.text_color_button", "background-color='[t]'")
					winset(src, "style_colors.text_color", "text='[t]'")

			setInterfaceColor(t as text|null)
				set hidden = 1

				if(!t) t = "#555555"
				if(copytext(t, 1, 2) != "#") t = "#" + t

				if(t && length(t) == 7)
					interface_color = uppertext(t)

					winset(src, "style_colors.interface_button", "background-color='[t]'")
					winset(src, "style_colors.interface_color", "text='[interface_color]'")

					if(server_manager.home)
						winset(src, "interfacebar_1", "background-color='[interface_color]';")
						winset(src, "interfacebar_2", "background-color='[interface_color]';")
						winset(src, "cim.interfacebar_3", "background-color='[interface_color]';")
						winset(src, "cim.interfacebar_4", "background-color='[interface_color]';")
						winset(src, "settings.interfacebar_5", "background-color='[interface_color]';")
						winset(src, "showcontent.interfacebar_6", "background-color='[interface_color]';")
						winset(src, "who.interfacebar_7", "background-color='[interface_color]';")

						for(var/ck in msg_handlers)
							winset(src, "cim_[ckey(ck)].interfacebar_3", "background-color='[interface_color]';")
							winset(src, "cim_[ckey(ck)].interfacebar_4", "background-color='[interface_color]';")

			setShowColors(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "true"

				if(t == "false") show_colors = FALSE
				else show_colors = TRUE

			setDefaultSystem()
				set hidden = 1

				setShowTitle(1)
				setShowWelcome(1)
				setShowMotD(1)
				setShowQotD(1)
				setHighlightCode(1)
				set24HourTime()
				setTimeOffset()
				setAutoAFK()
				setAwayMsg()

			setShowTitle(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_title", "is-checked=true")
					show_title = TRUE

				else
					if(winget(src, "system.show_title", "is-checked")=="true") show_title = TRUE
					else show_title = FALSE

			setShowWelcome(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_welcome", "is-checked=true")
					show_welcome = TRUE

				else
					if(winget(src, "system.show_welcome", "is-checked")=="true") show_welcome = TRUE
					else show_welcome = FALSE

			setShowMotD(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_motd", "is-checked=true")
					show_motd = TRUE

				else
					if(winget(src, "system.show_motd", "is-checked")=="true") show_motd = TRUE
					else show_motd = FALSE

			setShowQotD(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_qotd", "is-checked=true")
					show_qotd = TRUE

				else
					if(winget(src, "system.show_qotd", "is-checked")=="true") show_qotd = TRUE
					else show_qotd = FALSE

			setHighlightCode(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_highlight", "is-checked=true")
					show_highlight = TRUE

				else
					if(winget(src, "system.show_highlight", "is-checked")=="true") show_highlight = TRUE
					else show_highlight = FALSE

			set24HourTime(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "24"

				if(t == "24")
					time_24hr = TRUE
					winset(src, "system.12Hour", "is-checked=false")
					winset(src, "system.24Hour", "is-checked=true")
				else
					time_24hr = FALSE
					winset(src, "system.12Hour", "is-checked=true")
					winset(src, "system.24Hour", "is-checked=false")

				src << output(text_manager.stripHTML(parseTime()), "system.time")

			setTimeOffset(t as num|null)
				set hidden = 1

				if(isnull(t) || !isnum(t)) t = 0

				time_offset = t
				src << output(text_manager.stripHTML(parseTime()), "system.time")
				winset(src, "system.offset", "text=[time_offset]")

			setAutoAFK(t as num|null)
				set hidden = 1

				if(isnull(t)) t = 15

				auto_away = t
				winset(src, "system.auto_afk", "text=\"[t]\"")

			setAwayMsg(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "I have gone auto-AFK."

				auto_reason = t
				winset(src, "system.away_msg", "text=\"[text_manager.escapeQuotes(t)]\"")

			pickColor(color as text|null)
				set hidden = 1

				winshow(src, "color_picker", 0)
				if(!color) return

				if(findtext(color_scope, "color")==1)
					var/num = text2num(copytext(color_scope, 6))
					if(!num || (num > length(fade_colors))) return
					fade_colors[num] = color
					winset(src, "style_colors.color[num]", "background-color='[color]'")

				else
					switch(color_scope)
						if("name")
							if(color)
								name_color = color

								winset(src, "style_colors.name_color_button", "background-color='[color]'")
								winset(src, "style_colors.name_color", "text='[color]'")

								src << output(null, "style_colors.output")

								if(fade_name) src << output("[fade_name]", "style_colors.output")
								else src << output("<font color=[name_color]>[name]</font>", "style_colors.output")

								server_manager.home.updateWho()

						if("text")
							text_color = color

							winset(src, "style_colors.text_color_button", "background-color='[color]'")
							winset(src, "style_colors.text_color", "text='[color]'")

						if("interface")
							interface_color = color
							winset(src, "style_colors.interface_button", "background-color='[color]'")
							winset(src, "style_colors.interface_color", "text='[color]'")

			/* OPS VIEW */

			toggleOpsView()
				set hidden = 1

				if(ckey in server_manager.home.operators)
					if(winget(src, "ops", "is-visible") == "false")
						setOpsDisplay("tracker")
						winshow(src, "ops")

					else winshow(src, "ops", 0)

			setOpsDisplay(page as text)
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				refreshAllOps()

				switch(page)
					if("tracker") winset(src, "ops.ops_child", "left=ops_tracker")
					if("logs") winset(src, "ops.ops_child", "left=ops_logs")

			refreshAllOps()
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				updateViewingEntry()
				updateTracker()
				updateViewingLog()
				updateLogs()

			updateTracker()
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				var/c = 1
				for(var/AssocEntry/entry in assoc_manager.entries)
					winset(src, "ops_tracker.ckeys", "current-cell=1,[c]")
					winset(src, "ops_tracker.ckeys", "style='body{text-align: center; background-color: [(c % 2) ? ("#DDDDDD") : ("#EEEEEE")];}'")
					var/e1 = entry.ckeys[1]
					src << output("<a href=byond://?src=\ref[chatter_manager]&target=\ref[chatter_manager.getByKey(key)]&action=tracker_viewckey;ckey=[e1]>[textutil.list2text(entry.ckeys, ", ")]</a>", "ops_tracker.ckeys")
					c ++

				winset(src, "ops_tracker.ckeys", "cells=1x[length(assoc_manager.all_ckeys)]")

			updateViewingEntry()
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				if(viewing_entry)
					var/c = 1
					for(var/i in viewing_entry.ckeys)
						winset(src, "ops_tracker.sel_ckeys", "current-cell=1,[c]")
						winset(src, "ops_tracker.sel_ckeys", "style='body{text-align: center; background-color: [(c % 2) ? ("#CCCCCC") : ("#DDDDDD")];}'")
						var/od = viewing_entry.ckeys[i]
						src << output("[i] [od ? "([od])" : ""]", "ops_tracker.sel_ckeys")
						c ++

					winset(src, "ops_tracker.sel_ckeys", "cells=1x[length(viewing_entry.ckeys)]")

					c = 1
					for(var/i in viewing_entry.ips)
						winset(src, "ops_tracker.sel_ips", "current-cell=1,[c]")
						winset(src, "ops_tracker.sel_ips", "style='body{text-align: center; background-color: [(c % 2) ? ("#CCCCCC") : ("#DDDDDD")];}'")

						var/list/locdata = viewing_entry.ips[i]
						if(locdata)
							var/od = ""
							if(locdata["city"]) od += "[locdata["city"]], "
							if(locdata["region_name"]) od += "[locdata["region_name"]], "
							if(locdata["country_name"]) od += "[locdata["country_name"]]"
							if(od) src << output("[i] ([od])", "ops_tracker.sel_ips")
							else src << output("[i] (no location information)", "ops_tracker.sel_ips")

						else src << output("[i] (no location information)", "ops_tracker.sel_ips")
						c ++

					winset(src, "ops_tracker.sel_ips", "cells=1x[length(viewing_entry.ips)]")

					c = 1
					for(var/i in viewing_entry.cids)
						winset(src, "ops_tracker.sel_cids", "current-cell=1,[c]")
						winset(src, "ops_tracker.sel_cids", "style='body{text-align: center; background-color: [(c % 2) ? ("#CCCCCC") : ("#DDDDDD")];}'")
						var/od = viewing_entry.cids[i]
						src << output("[i] [od ? "(last login: [od])" : ""]", "ops_tracker.sel_cids")
						c ++

					winset(src, "ops_tracker.sel_cids", "cells=1x[length(viewing_entry.cids)]")

			updateLogs()
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				var/list/logs = list()
				for(var/l in flist("./data/logs/"))
					logs += l

				if(length(logs))
					var/c = 1
					for(var/i in logs)
						winset(src, "ops_logs.grid", "current-cell=1,[c]")
						winset(src, "ops_logs.grid", "style='body{text-align: center; background-color: [(c % 2) ? ("#DDDDDD") : ("#EEEEEE")];}'")
						src << output("<a href=\"byond://?src=\ref[chatter_manager]&target=\ref[chatter_manager.getByKey(key)]&action=logs_viewlog;log=[i]\">[i]</a>", "ops_logs.grid")
						c ++

					winset(src, "ops_logs.grid", "cells=1x[length(logs)]")

			updateViewingLog()
				set hidden = 1

				if(!(ckey in server_manager.home.operators)) return

				if(viewing_log)
					if(fexists(viewing_log))
						src << output(file2text(viewing_log), "ops_logs.browser")