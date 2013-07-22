mob
	chatter
		verb
			BrowseSystem()
				set hidden = 1

				SetDisplay("system")

			SetDefaultSystem()
				set hidden = 1

				SetShowTitle(1)
				SetShowWelcome(1)
				SetShowMotD(1)
				SetShowQotD(1)
				SetClearOnReboot("false")
				SetHighlightCode(1)
				Set24HourTime()
				SetTimeOffset()
				SetAutoAFK()
				SetAwayMsg()

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

			SetHighlightCode(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "system.show_highlight", "is-checked=true")
					show_highlight = TRUE

				else
					if(winget(src, "system.show_highlight", "is-checked")=="true") show_highlight = TRUE
					else show_highlight = FALSE

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
