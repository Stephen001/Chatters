mob
	chatter
		verb
			BrowseSystem()
				set hidden = 1

				SetDisplay("system")

			UpdateSystem()
				set hidden = 1

				SetShowTitle()
				SetShowWelcome()
				SetShowMotD()
				SetShowQotD()
				SetClearOnReboot()

				var
					maxout = winget(src, "system.max_output", "text")
					tnpswd = winget(src, "system.telnet_pass", "text")
					X = winget(src, "system.win_size_x", "text")
					Y = winget(src, "system.win_size_y", "text")

				SetMaxOutput(maxout)
				SetHighlightCode()
				SetTelnetPassword(tnpswd)
				SetWinSizeX(X)
				SetWinSizeY(Y)

				if(Chan) winset(src, "default", "size=[winsize]")

				var
					TimeOffset = winget(src, "system.offset", "text")
					AutoAFK = text2num(winget(src, "system.auto_afk", "text"))
					AwayMsg = winget(src, "system.away_msg", "text")

				SetTimeOffset(text2num(TimeOffset))
				SetAutoAFK(AutoAFK)
				SetAwayMsg(AwayMsg)

				winset(src, "system.updated", "is-visible=true")

				if(winget(src, "system.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "system.saved", "is-visible=true")

				sleep(50)

				if(src && client)
					winset(src, "system.updated", "is-visible=false")
					winset(src, "system.saved", "is-visible=false")

			SetDefaultSystem()
				set hidden = 1

				SetShowTitle(1)
				SetShowWelcome(1)
				SetShowMotD(1)
				SetShowQotD(1)
				SetClearOnReboot("false")
				SetMaxOutput("1000")
				SetHighlightCode(1)
				SetTelnetPassword()
				SetWinSizeX()
				SetWinSizeY()
				Set24HourTime()
				SetTimeOffset()
				SetAutoAFK()
				SetAwayMsg()

				winset(src, "system.updated", "is-visible=true")

				if(winget(src, "system.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "system.saved", "is-visible=true")

				sleep(50)

				winset(src, "system.updated", "is-visible=false")
				winset(src, "system.saved", "is-visible=false")

			SetShowTitle(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_title", "is-checked=true")
					show_title = TRUE

				else
					if(winget(src, "system.show_title", "is-checked")=="true") show_title = TRUE
					else show_title = FALSE

			SetShowWelcome(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_welcome", "is-checked=true")
					show_welcome = TRUE

				else
					if(winget(src, "system.show_welcome", "is-checked")=="true") show_welcome = TRUE
					else show_welcome = FALSE

			SetShowMotD(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_motd", "is-checked=true")
					show_motd = TRUE

				else
					if(winget(src, "system.show_motd", "is-checked")=="true") show_motd = TRUE
					else show_motd = FALSE

			SetShowQotD(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_qotd", "is-checked=true")
					show_qotd = TRUE

				else
					if(winget(src, "system.show_qotd", "is-checked")=="true") show_qotd = TRUE
					else show_qotd = FALSE

			SetClearOnReboot(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.clear_reboot", "is-checked=true")
					clear_on_reboot = FALSE

				else
					if(winget(src, "system.clear_reboot", "is-checked")=="true") clear_on_reboot = TRUE
					else clear_on_reboot = FALSE

			SetMaxOutput(t as text|null)
				set hidden = 1

				t = text2num(t)
				if(t<0) t = 0
				max_output = t
				winset(src, "system.max_output", "text='[max_output]';")
				if(Home) winset(src, "[ckey(Home.name)].chat.default_output", "max-lines='[max_output]';")

			SetHighlightCode(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_highlight", "is-checked=true")
					show_highlight = TRUE

				else
					if(winget(src, "system.show_highlight", "is-checked")=="true") show_highlight = TRUE
					else show_highlight = FALSE

			SetTelnetPassword(t as text|null)
				set hidden = 1

				var
					list/L = new()
					telnet_key = md5(key)
					savefile/S = new("./data/saves/tel.net")

				if(t)
					var/telnet_pass = md5(t)
					telnet_pass = t
					if(S && length(S))
						S["telnet"] >> L

					if(!telnet_key in L) L += telnet_key
					L[telnet_key] = telnet_pass
					S["telnet"] << L

				else if(S && length(S))
					if(!telnet_key in L) return
					L[telnet_key] = null
					S["telnet"] << L

			SetWinSizeX(t as text|null)
				set hidden = 1

				var
					X
					Y=480

				t = text2num(t)
				if(t<=0) t = 640
				X = t

				if(winsize) Y = copytext(winsize, findtext(winsize, "x")+1)

				winsize = "[X]x[Y]"
				winset(src, "system.win_size_x", "text='[X]';")

			SetWinSizeY(t as text|null)
				set hidden = 1

				var
					Y
					X=640

				t = text2num(t)
				if(t<=0) t = 480
				Y = t

				if(winsize) X = copytext(winsize, 1, findtext(winsize, "x"))

				winsize = "[X]x[Y]"
				winset(src, "system.win_size_y", "text='[Y]';")

			Set24HourTime(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "24"

				if(t == "24")
					_24hr_time = TRUE
					winset(src, "system.12Hour", "is-checked=false")
					winset(src, "system.24Hour", "is-checked=true")
				else
					_24hr_time = FALSE
					winset(src, "system.12Hour", "is-checked=true")
					winset(src, "system.24Hour", "is-checked=false")

				src << output(TextMan.strip_html(ParseTime()), "system.time")

			SetTimeOffset(t as num|null)
				set hidden = 1

				if(isnull(t) || !isnum(t)) t = 0

				time_offset = t
				src << output(TextMan.strip_html(ParseTime()), "system.time")
				winset(src, "system.offset", "text=[time_offset]")

			SetAutoAFK(t as num|null)
				set hidden = 1

				if(isnull(t)) t = 15

				auto_away = t
				winset(src, "system.auto_afk", "text='[t]'")

			SetAwayMsg(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "I have gone auto-AFK."

				auto_reason = t
				winset(src, "system.away_msg", "text='[TextMan.escapeQuotes(t)]'")