mob
	chatter
		verb
			ViewHelp()
				set hidden = 1

				if(winget(src, "help", "is-visible") == "true") winshow(src, "help", 0)
				else winshow(src, "help")

			ViewGithub()
				set hidden = 1

				src << link("http://www.github.com/Stephen001/Chatters/")

			ListOps()
				var
					ops = ""
					i = 0

				for(var/op in Home.operators)
					i ++

					if(i < length(Home.operators)) ops += "[op], "
					else
						if(length(Home.operators) > 1) ops += "and [op]."
						else ops += "[op]."

				if(ops) Home.chanbot.Say(ops, src)

			Set()
				if(telnet) return
				ToggleSettings()

			Say(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				Chan.Say(src, msg)

			Me(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				Chan.Me(src, msg)

			My(msg as text|null)
				if(!msg) return
				if(afk) ReturnAFK()
				Chan.My(src, msg)

			IM(target as text|null|mob in Home.chatters, msg as text|null)
				if(telnet) return
				if(!target)
					var/Messenger/im = new(src)
					im.Display(src)
					return

				var/mob/C
				if(ismob(target)) C = target
				else C = ChatMan.Get(target)
				if(!C) Home.chanbot.Say("[target] is not currently online.", src)
				else
					if(ismob(C))
						if(!msg)
							var/Messenger/im = new(src, C.name)
							im.Display(src)
							return
						if(length(msg)>512)
							var/part2 = copytext(msg, 513)
							msg = copytext(msg, 1, 513)
							spawn(20) IM(C.name, part2)

						var/Messenger/im = new(src, C.name)
						im.Display(src)
						MsgMan.RouteMsg(src, C, msg)

					else
						if(!msg)
							var/Messenger/im = new(src, C)
							im.Display(src)
							return
						if(length(msg)>512)
							var/part2 = copytext(msg, 513)
							msg = copytext(msg, 1, 513)
							spawn(20) IM(C, part2)

						var/Messenger/im = new(src, C)
						im.Display(src)
						var/savefile/S = new()
						var/mob/chatter/M = new()

						M.name = name
						M.name_color = name_color
						M.fade_name = fade_name
						M.text_color = text_color
						M.fade_name = fade_name

						S["from"] << M
						S["msg"] << msg
						S["to"] << C

						src << output(src.ParseMsg(src, msg, src.say_format), "cim_[C.ckey].output")
						world.Export("[ChanMan.server.chatters[C]]?dest=msgman&action=msg",S)

			Ignore(mob/target as text|null|mob in Home.chatters, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target)
					Home.chanbot.Say("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
					return

				if(!ignoring) ignoring = new
				if(ismob(target)) target = target.name
				var/is_ignored = ignoring(target)
				if(is_ignored == FULL_IGNORE)
					Home.chanbot.Say("You are already ignoring [target].", src)
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
					if("full")		scope = "[FULL_IGNORE]"
				var/num = text2num(scope)
				if(num && isnum(num))
					if(num & is_ignored)
						Home.chanbot.Say("You are already ignoring [ignore_type] from [target].", src)
						return

					num += is_ignored
					ignore_type = ""
					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0
						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							ignore_type += "\n	- instant messages"
							if(ckey(target) in msgHandlers)
								winset(src, "cim_[ckey(target)]", "is-visible=false")
						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							ignore_type += "\n	- chat messages"
						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							ignore_type += "\n	- fade name"
						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							ignore_type += "\n	- colors"
						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							ignore_type += "\n	- smileys"
						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							ignore_type += "\n	- images"
						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							ignore_type += "\n	- files"
						if(!scope)
							Home.chanbot.Say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
							return

				else
					Home.chanbot.Say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full", src)
					return

				if(!is_ignored) ignoring += ckey(target)
				ignoring[ckey(target)] = scope
				if(length(ignore_type)) Home.chanbot.Say("You are now ignoring the following from [target]: [ignore_type].", src)
				else Home.chanbot.Say("You are now fully ignoring [target].", src)

				ChatMan.Save(src)

			Unignore(mob/target as text|null|anything in ignoring, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target) Home.chanbot.Say("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)

				if(!ignoring || !ignoring.len)
					Home.chanbot.Say("You are not currently ignoring any chatters.", src)
					return

				if(ismob(target)) target = target.name
				var/ign = ignoring(target)
				if(!ign)
					Home.chanbot.Say("You are not currently ignoring [target]", src)
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
					if("full")		scope = "[FULL_IGNORE]"
				var/num = text2num(scope)
				if(num && isnum(num))
					if((num != FULL_IGNORE) && !(num & ign))
						Home.chanbot.Say("You are not currently ignoring [ignore_type] from [target].", src)
						return

					ignore_type = ""
					if(num == 31) num = FULL_IGNORE
					if(num & FULL_IGNORE) scope = FULL_IGNORE
					else
						scope = 0
						if(num & IM_IGNORE)
							scope |= IM_IGNORE
							if(ign - IM_IGNORE)
								ignore_type += "\n	- instant messages"
						if(num & CHAT_IGNORE)
							scope |= CHAT_IGNORE
							if(ign - CHAT_IGNORE)
								ignore_type += "\n	- chat messages"
						if(num & FADE_IGNORE)
							scope |= FADE_IGNORE
							if(ign - FADE_IGNORE)
								ignore_type += "\n	- fade name"
						if(num & COLOR_IGNORE)
							scope |= COLOR_IGNORE
							if(ign - COLOR_IGNORE)
								ignore_type += "\n	- colors"
						if(num & SMILEY_IGNORE)
							scope |= SMILEY_IGNORE
							if(ign - SMILEY_IGNORE)
								ignore_type += "\n	- smileys"
						if(num & IMAGES_IGNORE)
							scope |= IMAGES_IGNORE
							if(ign - IMAGES_IGNORE)
								ignore_type += "\n	- images"
						if(num & FILES_IGNORE)
							scope |= FILES_IGNORE
							if(ign - FILES_IGNORE)
								ignore_type += "\n	- files"
						if(!scope)
							Home.chanbot.Say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
							return
				else
					Home.chanbot.Say("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", src)
					return

				if(scope == FULL_IGNORE) ignoring -= ckey(target)
				else ignoring[ckey(target)] &= ~scope
				if(!ignoring[ckey(target)])
					ignoring -= ckey(target)
					ignore_type = ""

				if(length(ignore_type)) Home.chanbot.Say("You are no longer ignoring the following from [target]: [ignore_type]", src)
				else Home.chanbot.Say("You are no longer ignoring [target].", src)

				ChatMan.Save(src)

			ListIgnored(mob/target as text|null|anything in ignoring)
				if(!ignoring || !ignoring.len)
					Home.chanbot.Say("You are not currently ignoring any chatters.", src)
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
					ignored += "[i] ([scoped]) "

				Home.chanbot.Say("You are currently ignoring the following chatters: [ignored]", src)
				return

			Share()
				if(winget(src, "showcontent", "is-visible") == "false")
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent")

				else
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent", 0)

			ShowCode()
				set hidden = 1

				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new

				if(Home.ismute(src))
					Home.chanbot.Say("I'm sorry, but you appear to be muted.", src)
					return

				var/iCode = winget(src, "showcontent.content_input", "text")

				if(!iCode)
					del(S)
					return 0

				S.owner = "[src.name]"
				S.code = iCode
				S.Send(1)

				winshow(src, "showcontent", 0)
				winset(src, "showcontent.content_input", "text=")

			ShowText(t as text|null|mob in Home.chatters)
				set hidden = 1

				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new

				if(Home.ismute(src))
					Home.chanbot.Say("I'm sorry, but you appear to be muted.", src)
					return

				var/iCode = winget(src, "showcontent.content_input", "text")

				if(!iCode)
					del(S)

					return 0

				S.owner = "[src.name]"
				S.code = iCode
				S.Send()

				winshow(src, "showcontent", 0)
				winset(src, "showcontent.content_input", "text=")

			AFK(msg as text|null)
				if(!Chan || telnet) return
				if(!afk)
					if(!msg) msg = auto_reason
					Home.GoAFK(src, msg)
				else
					ReturnAFK()