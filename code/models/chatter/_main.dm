mob
	chatter
		icon = 'resources/icons/who.dmi'
		icon_state = "active"

		var
			name_color = "#000000"
			text_color = "#000000"
			interface_color = "#555555"
			fade_name
			show_colors = TRUE

			_24hr_time  = TRUE
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

			clear_on_reboot = FALSE

			// Added to notify a user if his name has been said in conversation.
			//
			name_notify = FALSE

			tmp/afk = FALSE
			tmp/telnet = FALSE
			tmp/away_at = 0
			tmp/away_reason
			tmp/list/msgs
			tmp/Channel/Chan
			tmp/ColorView/CV
			tmp/MessageHandler/MsgHand

			list
				ignoring
				fade_colors = list("#000000")

				time_format = list("<font size=1>\[","hh",":","mm",":","ss","]</font>")
				date_format = list("MMM"," ","MM",", `","YY")
				long_date_format = list("Day",", ","Month"," ","DD",", ","YYYY")
				say_format = list("$ts", " <b>","$name",":</b> ","$msg")
				rpsay_format = list("$ts", " ","$name"," ","$rp",":   ","$msg")
				me_format = list("$ts", " ", "$name", " ", "$msg")

				tmp/msgHandlers


		New()
			..()
			MsgHand = new(src)

		Login()
			..()

			if(!ChatMan.istelnet(key))
				ChanMan.Join(src, Home)

				winshow(src, "showcontent", 0)
				winshow(src, "settings", 0)

				RefreshAllSettings()

			// Telnet users login differently
			else
				//Set options suited for telnet.
				telnet = TRUE
				show_colors = FALSE
				show_smileys = FALSE
				show_highlight = FALSE
				ChanMan.Join(src, Home)

		Stat()
			..()

			if(telnet) return
			if(auto_away && (auto_away < client.inactivity/600) && !afk) AFK(auto_reason)
			if(src.msgHandlers && src.msgHandlers.len)
				for(var/msgHandler in msgHandlers)
					var/open = winget(src, "cim_[msgHandler]", "is-visible")
					if(open == "false")
						src << output(null, "cim_[msgHandler].output")
						winset(src, "cim_[msgHandler].input", "text=")
						var/Messenger/M = msgHandlers[msgHandler]
						msgHandlers -= msgHandler
						del(M)

		Click()
			var/Messenger/im = new(usr, key)
			im.Display(usr)

		Logout()
			if(Console && Chan) ChanMan.Quit(src, Chan)
			..()
			sleep(50)
			if(!client) del(src)
