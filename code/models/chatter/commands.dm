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
				if(!C)
					if(src.Chan)
						src << output("[target] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
					else
						alert(src, "[target] is not currently online.", "Unable to locate chatter")
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
					if(src.Chan)
						src << output("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("Please provide a name. Proper usage: /Ignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "Ignore")
					return
				if(!ignoring) ignoring = new
				if(ismob(target)) target = target.name
				var/is_ignored = ignoring(target)
				if(is_ignored == FULL_IGNORE)
					if(src.Chan)
						src << output("You are already ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are already ignoring [target].", "Unable to ignore chatter")
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
						if(src.Chan)
							src << output("You are already ignoring [ignore_type] from [target].", "[ckey(Home.name)].chat.default_output")
						else
							alert("You are already ignoring [ignore_type] from [target].","Unable to ignore chatter")
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
							if(src.Chan)
								src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
							else
								alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full","Unable to ignore chatter")
							return
				else
					if(src.Chan)
						src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full", "[ckey(Home.name)].chat.default_output")
					else
						alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files full","Unable to ignore chatter")
					return
				if(!is_ignored) ignoring += ckey(target)
				ignoring[ckey(target)] = scope
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are now ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are now ignoring the following from [target]: [ignore_type]", "Ignoring chatter")
				else
					if(src.Chan)
						src << output("You are now fully ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are now fully ignoring [target].", "Ignoring chatter")
				ChatMan.Save(src)


			Unignore(mob/target as text|null|anything in ignoring, scope as text|null|anything in list("im", "chat", "fade", "colors", "smileys", "images", "files", "full"))
				if(!target)
					if(src.Chan)
						src << output("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("Please provide a name. Proper usage: /Unignore \"Chatter\" \"scope\" Available Scopes: im, chat, fade, colors, smileys, images, files, full", "Unignore")
					return
				if(!ignoring || !ignoring.len)
					if(src.Chan)
						src << output("You are not currently ignoring any chatters.", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring any chatters.", "Unable to unignore chatter")
					return
				if(ismob(target)) target = target.name
				var/ign = ignoring(target)
				if(!ign)
					if(src.Chan)
						src << output("You are not currently ignoring [target]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring [target]", "Unable to unignore chatter")
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
						if(src.Chan)
							src << output("You are not currently ignoring [ignore_type] from [target].", "[ckey(Home.name)].chat.default_output")
						else
							alert("You are not currently ignoring [ignore_type] from [target].","Unable to unignore chatter")
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
							if(src.Chan)
								src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
							else
								alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full","Unable to unignore chatter")
							return
				else
					if(src.Chan)
						src << output("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full", "[ckey(Home.name)].chat.default_output")
					else
						alert("The scope you provided did not match a known ignore scope. Available Scopes: im, chat, fade, colors, smileys, images, files, full","Unable to unignore chatter")
					return
				if(scope == FULL_IGNORE) ignoring -= ckey(target)
				else ignoring[ckey(target)] &= ~scope
				if(!ignoring[ckey(target)])
					ignoring -= ckey(target)
					ignore_type = ""
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are no longer ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are no longer ignoring the following from [target]: [ignore_type]", "Unignoring chatter")
				else
					if(src.Chan)
						src << output("You are no longer ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are no longer ignoring [target].", "Unignoring chatter")
				ChatMan.Save(src)

			Ignoring(mob/target as text|null|anything in ignoring)
				if(!ignoring || !ignoring.len)
					if(src.Chan)
						src << output("You are not currently ignoring any chatters.", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring any chatters.", "No chatters ignored")
					return
				if(!target)
					var/ignored
					for(var/i in ignoring)
						var/scoped
						if((ignoring[i] & FULL_IGNORE)) scoped = "Full ignore"
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
						ignored += "\n[i] - [scoped]"
					if(src.Chan)
						src << output("You are currently ignoring the following chatters.[ignored]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are currently ignoring the following chatters.[ignored]", "Not Ignoring chatter")
					return
				if(ismob(target)) target = target.name
				var/ign = ignoring(target)
				if(!ign)
					if(src.Chan)
						src << output("You are not currently ignoring [target]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are not currently ignoring [target]", "Not Ignoring chatter")
					return
				var/ignore_type = ""
				if(!(ign & FULL_IGNORE))
					if(ign & IM_IGNORE)
						if(ign - IM_IGNORE)
							ignore_type += "\n	- instant messages"
					if(ign & CHAT_IGNORE)
						if(ign - CHAT_IGNORE)
							ignore_type += "\n	- chat messages"
					if(ign & FADE_IGNORE)
						if(ign - FADE_IGNORE)
							ignore_type += "\n	- fade name"
					if(ign & COLOR_IGNORE)
						if(ign - COLOR_IGNORE)
							ignore_type += "\n	- colors"
					if(ign & SMILEY_IGNORE)
						if(ign - SMILEY_IGNORE)
							ignore_type += "\n	- smileys"
					if(ign & IMAGES_IGNORE)
						if(ign - IMAGES_IGNORE)
							ignore_type += "\n	- images"
					if(ign & FILES_IGNORE)
						if(ign - FILES_IGNORE)
							ignore_type += "\n	- files"
				if(length(ignore_type))
					if(src.Chan)
						src << output("You are ignoring the following from [target]: [ignore_type]", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are ignoring the following from [target]: [ignore_type]", "Ignoring chatter")
				else
					if(src.Chan)
						src << output("You are fully ignoring [target].", "[ckey(Home.name)].chat.default_output")
					else
						alert("You are fully ignoring [target].", "Ignoring chatter")

			Share()
				if(winget(src, "showcontent", "is-visible") == "false")
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent")

				else
					winset(src, "showcontent.content_input", "text=")
					winshow(src, "showcontent", 0)

			ShowCode(t as text|null|mob in Home.chatters)
				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new
				if(t)
					var/mob/chatter/C
					if(ismob(t)) C = t
					else C = ChatMan.Get(t)
					if(!C)
						if(Chan)
							src << output("[t] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
						else
							alert(src, "[t] is not currently online.", "Unable to locate chatter")
					else
						var/ign = C.ignoring(src)
						if(ign && CHAT_IGNORE)
							src << "<b>Unable to show code!</b>"
							src << "[C.name] is ignoring you."
							return
					S.target = C.ckey
				else
					if(!Chan || Chan.ismute(src))
						if(src.Chan) src.Chan.chanbot.Say("I'm sorry, but you appear to be muted.", src)
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
				if(telnet) return
				if(afk) ReturnAFK()
				var/showcode_snippet/S = new
				if(t)
					var/mob/chatter/C
					if(ismob(t)) C = t
					else C = ChatMan.Get(t)
					if(!C)
						if(src.Chan)
							src << output("[t] is not currently online.", "[ckey(src.Chan.name)].chat.default_output")
						else
							alert(src, "[t] is not currently online.", "Unable to locate chatter")
					else
						var/ign = C.ignoring(src)
						if(ign && CHAT_IGNORE)
							src << "<b>Unable to show code!</b>"
							src << "[C.name] is ignoring you."
							return
					S.target = C.ckey
				else
					if(!src.Chan || Chan.ismute(src))
						if(src.Chan) src.Chan.chanbot.Say("I'm sorry, but you appear to be muted.", src)
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

			Who()
				set hidden = 1
				var chatter_array[] = list()
				for(var/mob/chatter/C in Home.chatters)
					chatter_array += "[C.name][C.afk ? "\[AFK\]" : ""]"
				src << "<b>Chatters:</b> [kText.list2text(chatter_array, ", ")]"

			login(telnet_key as text|null)
				set hidden = 1
				if(!telnet_key || !telnet) return
				for(var/mob/chatter/C in Home.chatters)
					if((C.key && C.key==telnet_key) || C.name==telnet_key)
						src << "<b>Error:</b> That key is already logged in!"
						return
				var/savefile/S = new("./data/saves/tel.net")
				if(!S || !length(S))
					src << "<b>Error:</b> There is no password saved for that key!"
					return
				var/list/L = new
				S["telnet"] >> L
				if(!L || !L.len)
					src << "<b>Error:</b> There is no password saved for that key!"
					return
				var/key_hash = md5(telnet_key)
				if(key_hash in L)
					var/telnet_pass = input("Please enter your telnet password:", "Telnet Key Login") as password|null
					if(!telnet_pass)
						return
					if(L[key_hash] != md5(telnet_pass))
						src << "<b>Error:</b> Incorrect password!"
						return
					src << "You have successfully logged in as <b>telnet_key</b>!"
					name = telnet_key
					Home.UpdateWho()
				else src << "<b>Error:</b> There is no password saved for that key!"
