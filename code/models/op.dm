mob/chatter
	verb
		Promote(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(ckey(Home.founder) != ckey)
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			if(!Home.operators) Home.operators = list()

			if(ckey(Home.founder) == ckey(target)) return
			if(ckey(target) in Home.operators) Home.chanbot.Say("[target] is already an operator.", src)
			else
				Home.chanbot.Say("[target] was promoted to operator by [name].")
				Home.operators += ckey(target)

			Home.UpdateWho()
			ChanMan.SaveHome()

		Demote(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(ckey(Home.founder) != ckey)
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			if(ckey(Home.founder) == ckey(target)) return
			if(!(ckey(target) in Home.operators)) Home.chanbot.Say("[target] is not an operator.", src)
			else
				Home.chanbot.Say("[target] was demoted by [name].")
				Home.operators -= ckey(target)

			Home.UpdateWho()
			ChanMan.SaveHome()

		SetTopic(ntopic as text)
			set hidden = 1

			if(!ntopic) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.SetTopic(ntopic, 1)

		SetDesc(ndesc as text)
			set hidden = 1

			if(!ndesc) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.SetDesc(ndesc, 1)

		BotSetTextColor(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.SetTextColor(n, 1)

		BotSetNameColor(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.SetNameColor(n, 1)

		BotSetName(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.SetName(n, 1)

		BotSay(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.Say(n)

		BotMe(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.Me(n)

		BotMy(n as text)
			set hidden = 1

			if(!n) return
			if(!Home.chanbot) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			Home.chanbot.My(n)

		CheckIP(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = ChatMan.Get(target)

			if(!C)
				Home.chanbot.Say("[target] is not currently in the channel.", src)
				return

			if(C.client.address) Home.chanbot.Say("[C.name]'s IP: [C.client.address]", src)
			else Home.chanbot.Say("[C.name]'s IP is unknown.", src)

		Mute(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			if(!Home.mute) Home.mute = list()

			if(!(ckey(target) in Home.operators))
				if(!(ckey(target) in Home.mute))
					Home.chanbot.Say("[target] has been muted by \[b][name]\[/b].")
					Home.mute += ckey(target)
					Home.UpdateWho()

				else Home.chanbot.Say("[target] is already mute.", src)

			else Home.chanbot.Say("You cannot mute an operator.", src)

			ChanMan.SaveHome()

		Voice(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			if(!Home.mute) Home.mute = new
			if(!(ckey(target) in Home.operators))
				if(ckey(target) in Home.mute)
					Home.chanbot.Say("[target] has been voiced by \[b][name]\[/b].")
					Home.mute -= ckey(target)
					Home.UpdateWho()

				else Home.chanbot.Say("[target] is not muted.", src)

			ChanMan.SaveHome()

		Kick(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = ChatMan.Get(target)

			if(!C)
				Home.chanbot.Say("[target] is not currently in the channel.", src)
				return

			if(ckey(target) in Home.operators)
				Home.chanbot.Say("You cannot kick an operator.", src)
				return

			Home.chanbot.Say("[C.name] has been kicked by \[b][name]\[/b].")

			if(!ChatMan.istelnet(C.key))
				// clear the chat window of everything but the output
				// to reinforce that they are really out of the program
				winset(C, "default", "menu=")
				C << output(null, "[ckey(Home.name)].chat.default_output")
				winset(C, "[ckey(Home.name)].child", "right=")
				winset(C, "[ckey(Home.name)].set", "is-visible=false")
				winset(C, "[ckey(Home.name)].help", "is-visible=false")
				winset(C, "[ckey(Home.name)].default_input", "is-disabled=true")

				var/size = winget(C, "[ckey(Home.name)].child", "size")
				var/X = copytext(size, 1, findtext(size,"x"))
				var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
				winset(C, "[ckey(Home.name)].child", "size=[X]x[Y];pos=0,0")

			C << output("You have been kicked from [Home.name] by [name].", "[ckey(Home.name)].chat.default_output")
			C << output("<font color=red>Connection closed.", "[ckey(Home.name)].chat.default_output")

			Home.chatters -= C
			Home.UpdateWho()

			C.Logout()

		Ban(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			var/mob/chatter/C = ChatMan.Get(target)

			if(ckey(target) in Home.operators)
				Home.chanbot.Say("You cannot ban an operator.", src)
				return

			if(!Home.banned) Home.banned = list()

			Home.chanbot.Say("[target] has been banned by \[b][name]\[/b].")
			Home.banned += ckey(target)

			if(C)
				if(!ChatMan.istelnet(C.key))
					// clear the chat window of everything but the output
					// to reinforce that they are really out of the program
					winset(C, "default", "menu=")
					C << output(null, "[ckey(Home.name)].chat.default_output")
					winset(C, "[ckey(Home.name)].child", "right=")
					winset(C, "[ckey(Home.name)].set", "is-visible=false")
					winset(C, "[ckey(Home.name)].help", "is-visible=false")
					winset(C, "[ckey(Home.name)].default_input", "is-disabled=true")

					var/size = winget(C, "[ckey(Home.name)].child", "size")
					var/X = copytext(size, 1, findtext(size,"x"))
					var/Y = text2num(copytext(size, findtext(size, "x")+1))+44
					winset(C, "[ckey(Home.name)].child", "size=[X]x[Y];pos=0,0")

					C << output("You have been kicked from [Home.name] by [name]", "[ckey(Home.name)].chat.default_output")
					C << output("<font color=red>Connection closed.", "[ckey(Home.name)].chat.default_output")

				Home.chatters -= C
				Home.UpdateWho()

				C.Logout()

			ChanMan.SaveHome()

		Unban(target as text)
			set hidden = 1

			if(!target) return
			if(!Chan) return
			if(!(ckey in Home.operators))
				Home.chanbot.Say("You do not have access to this command.", src)
				return

			if(ckey(target) in Home.banned)
				Home.chanbot.Say("[target] has been unbanned by \[b][name]\[/b].")
				Home.banned -= ckey(target)

			ChanMan.SaveHome()

		ListBanned()
			if(length(Home.banned))
				for(var/o in Home.banned)
					Home.chanbot.Say("[o]", src)

		ListMuted()
			if(length(Home.mute))
				for(var/o in Home.mute)
					Home.chanbot.Say("[o]", src)