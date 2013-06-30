mob/chatter
	verb
		/*SettingsWindow()
			set hidden = 1
			set name = ".settings"

			SetDisplay(winget(src, "set.tab1", "current-tab"))

		ShowSet()
			set hidden = 1
			winshow(src, "settings", 1)
			BrowseStyle()

		HideSet()
			set hidden = 1
			winshow(src, "settings", 0)*/

		ToggleSettings()
			set hidden = 1

			if(winget(src, "settings", "is-visible") == "false")
				SetDisplay("colors")
				winshow(src, "settings")

			else winshow(src, "settings", 0)

		SaveAllSettings()
			set hidden = 1

			var
				NameColor = winget(src, "style_colors.name_color", "text")
				TextColor = winget(src, "style_colors.text_color", "text")
				Interface = winget(src, "style_colors.interface", "text")

			SetNameColor(NameColor)
			SetTextColor(TextColor)
			SetInterface(Interface)

			Chan.UpdateWho()

			if(winget(src, "misc.show_smileys", "is-checked")=="true") SetShowSmileys(1)
			else SetShowSmileys()
			if(winget(src, "misc.show_images", "is-checked")=="true") SetShowImages(1)
			else SetShowImages()

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

			var
				ChatFormat = winget(src, "style_formats.chat_format", "text")
				EmoteFormat = winget(src, "style_formats.emote_format", "text")
				InlineEmoteFormat = winget(src, "style_formats.inline_emote_format", "text")
				TimeFormat = winget(src, "style_formats.time_format", "text")
				DateFormat = winget(src, "style_formats.date_format", "text")
				LongDateFormat = winget(src, "style_formats.long_date_format", "text")
				OutputStyle = winget(src, "style_formats.output_style", "text")

			SetDateFormat(DateFormat)
			SetTimeFormat(TimeFormat)
			SetInlineEmoteFormat(InlineEmoteFormat)
			SetEmoteFormat(EmoteFormat)
			SetChatFormat(ChatFormat)
			SetLongDateFormat(LongDateFormat)
			SetOutputStyle(OutputStyle)

			ShowFilterList()

			winsize = winget(src, "default", "size")
			ChatMan.Save(src)

		RefreshAllSettings()
			set hidden = 1

			winset(src, "style_colors.name_color", "text='[name_color]'")
			winset(src, "style_colors.name_color_button", "background-color='[name_color]'")
			winset(src, "style_colors.text_color", "text='[text_color]'")
			winset(src, "style_colors.text_color_button", "background-color='[text_color]'")
			winset(src, "style_colors.interface", "text='[interface_color]'")
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

			ShowFilterList()
			SetFilter("[filter]")

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

		SetDisplay(page as text)
			RefreshAllSettings()

			switch(page)
				if("colors") winset(src, "settings.settings_child", "left=style_colors")
				if("formats") winset(src, "settings.settings_child", "left=style_formats")
				if("misc") winset(src, "settings.settings_child", "left=misc")
				if("filters") winset(src, "settings.settings_child", "left=filters")
				if("system") winset(src, "settings.settings_child", "left=system")