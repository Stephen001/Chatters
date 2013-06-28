mob/chatter
	verb
		SettingsWindow()
			set hidden = 1
			set name = ".settings"

			SetDisplay(winget(src, "set.tab1", "current-tab"))

		ShowSet()
			set hidden = 1
			winshow(src, "set", 1)
			BrowseStyle()

		HideSet()
			set hidden = 1
			winshow(src, "set", 0)

	proc
		SetDisplay(page)
			switch(page)
				if("style")
					winset(src, "style_colors.name_color", "text='[name_color]'")
					winset(src, "style_colors.name_color_button", "background-color='[name_color]'")
					winset(src, "style_colors.text_color", "text='[text_color]'")
					winset(src, "style_colors.text_color_button", "background-color='[text_color]'")
					winset(src, "style_colors.background", "text='[background]'")
					winset(src, "style_colors.background_button", "background-color='[background]'")

					src << output("<b>[fade_name]</b>", "style_colors.output")

					if(show_colors)
						winset(src, "style_colors.show_colors", "is-checked=true")
						winset(src, "style_colors.no_colors", "is-checked=false")

					else
						winset(src, "style_colors.show_colors", "is-checked=false")
						winset(src, "style_colors.no_colors", "is-checked=true")

					if(forced_punctuation)
						winset(src, "style_formats.forced", "is-checked=true")
						winset(src, "style_formats.no_forced", "is-checked=false")

					else
						winset(src, "style_formats.forced", "is-checked=false")
						winset(src, "style_formats.no_forced", "is-checked=true")

					winset(src, "style_formats.chat_format", "text='[TextMan.escapeQuotes(list2text(say_format))]'")
					winset(src, "style_formats.emote_format", "text='[TextMan.escapeQuotes(list2text(me_format))]'")
					winset(src, "style_formats.inline_emote_format", "text='[TextMan.escapeQuotes(list2text(rpsay_format))]'")
					winset(src, "style_formats.time_format", "text='[TextMan.escapeQuotes(list2text(time_format))]'")
					winset(src, "style_formats.date_format", "text='[TextMan.escapeQuotes(list2text(date_format))]'")
					winset(src, "style_formats.long_date_format", "text='[TextMan.escapeQuotes(list2text(long_date_format))]'")
					winset(src, "style_formats.output_style", "text='[TextMan.escapeQuotes(default_output_style)]'")

				if("icons")
				if("filters")
					ShowFilterList()
					SetFilter("[filter]")

				if("security")
				if("system")
					if(show_title) winset(src, "system.show_title", "is-checked=true")
					else winset(src, "system.show_title", "is-checked=false")

					if(show_welcome) winset(src, "system.show_welcome", "is-checked=true")
					else winset(src, "system.show_welcome", "is-checked=false")

					if(show_motd) winset(src, "system.show_motd", "is-checked=true")
					else winset(src, "system.show_motd", "is-checked=false")

					if(show_qotd) winset(src, "system.show_qotd", "is-checked=true")
					else winset(src, "system.show_qotd", "is-checked=false")

					if(clear_on_reboot) winset(src, "system.clear_reboot", "is-checked=true")
					else winset(src, "system.clear_reboot", "is-checked=false")

					winset(src, "system.max_output", "text='[max_output]'")

					if(show_highlight) winset(src, "system.show_highlight", "is-checked=true")
					else winset(src, "system.show_highlight", "is-checked=false")

					winset(src, "system.telnet_pass", "text='[TextMan.escapeQuotes(telnet_pass)]';")

					var
						X
						Y

					if(winsize)
						X = copytext(winsize, 1, findtext(winsize, "x"))
						Y = copytext(winsize, findtext(winsize, "x")+1)

					SetWinSizeX(X)
					SetWinSizeY(Y)

					if(!_24hr_time)
						winset(src, "system.24Hour", "is-checked=false")
						winset(src, "system.12Hour", "is-checked=true")

					winset(src, "system.offset", "text='[time_offset]'")

					var/time = TextMan.strip_html(ParseTime())
					src << output(time, "system.time")

					winset(src, "system.auto_afk", "text='[auto_away]'")
					winset(src, "system.away_msg", "text='[TextMan.escapeQuotes(auto_reason)]'")