mob
	chatter
		verb
			UpdateColorStyle()
				set hidden = 1

				var
					NameColor = winget(src, "style_colors.name_color", "text")
					TextColor = winget(src, "style_colors.text_color", "text")
					Background = winget(src, "style_colors.background", "text")

				SetNameColor(NameColor)
				SetTextColor(TextColor)
				SetBackground(Background)

				winset(src, "style_colors.updated", "is-visible=true")

				if(winget(src, "style_colors.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "style_colors.saved", "is-visible=true")

				sleep(50)

				if(src && client)
					winset(src, "style_colors.updated", "is-visible=false")
					winset(src, "style_colors.saved", "is-visible=false")

			SetDefaultColorStyle()
				set hidden = 1

				fade_colors.len = 1
				fade_colors[1] = "#000000"
				fade_name = null

				FadeName()
				FadeColors(1)
				FadeNameDone()
				SetNameColor()
				SetTextColor()
				SetBackground()
				SetShowColors()

				winset(src, "style_colors.updated", "is-visible=true")

				if(winget(src, "style_colors.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "style_colors.saved", "is-visible=true")

				sleep(50)
				winset(src, "style_colors.updated", "is-visible=false")
				winset(src, "style_colors.saved", "is-visible=false")

			FadeName()
				set hidden = 1

				winset(src, "style_colors.fade_help", "is-visible=true")
				winset(src, "style_colors.fadecolors", "is-visible=true")
				winset(src, "style_colors.colors", "is-visible=true;text=[fade_colors.len]")
				winset(src, "style_colors.set_colors", "is-visible=true")
				winset(src, "style_colors.done", "is-visible=true")

				for(var/i=1, i<=fade_colors.len, i++)
					winset(src, "style_colors.color[i]", "is-visible=true;background-color=[fade_colors[i]]")

			FadeColors(n as num|null)
				set hidden = 1

				if(!isnum(n)) n = text2num(winget(src, "style_colors.colors", "text"))
				if(n > length(name)) n = length(name)

				fade_colors.len = n
				winset(src, "style_colors.colors", "is-visible=true;text=[n]")

				for(var/i=0, (i+1)<=n, i++)
					if(!fade_colors[i+1]) fade_colors[i+1] = "#000000"
					winset(src, "style_colors.color[i+1]", "is-visible=true;background-color=[fade_colors[i+1]]")

				for(var/i=12, i>n, i--) winset(src, "style_colors.color[i]", "is-visible=false")

			FadeNameDone()
				set hidden = 1

				var/list/colors = new()
				for(var/c in fade_colors)
					var/red = TextMan.hex2dec(copytext(c, 2, 4))
					if(red<100) { if(red>10) {red = "0[red]"} else red = "00[red]" }
					else red = "[red]"

					var/grn = TextMan.hex2dec(copytext(c, 4, 6))
					if(grn<100) { if(grn>10) {grn = "0[grn]"} else grn = "00[grn]" }
					else grn = "[grn]"

					var/blu = TextMan.hex2dec(copytext(c, 6))
					if(blu<100) { if(blu>10) {blu = "0[blu]"} else blu = "00[blu]" }
					else blu = "[blu]"

					colors += red+grn+blu

				if(!colors || !colors.len || ((colors.len==1) && (colors[1] == "000000000")))
					if(name_color) fade_name = "<font color=[name_color]>[name]</font>"
					else fade_name = name

				else fade_name = TextMan.fadetext(name, colors)

				winset(src, "style_colors.fade_help", "is-visible=false")
				winset(src, "style_colors.fadecolors", "is-visible=false")
				winset(src, "style_colors.colors", "is-visible=false")
				winset(src, "style_colors.set_colors", "is-visible=false")
				winset(src, "style_colors.done", "is-visible=false")

				for(var/i=1, i<=fade_colors.len, i++)
					winset(src, "style_colors.color[i]", "is-visible=false")

				src << output("<b>[fade_name]</b>", "style_colors.output")

			SetNameColor(t as text|null)
				set hidden = 1

				if(!t) t = "#000000"
				if(copytext(t, 1, 2) != "#") t = "#" + t
				name_color = uppertext(t)

				if(fade_name == "<font color=[name_color]>[name]</font>") fade_name = null


				if(!fade_name || (fade_name == name))
					if(name_color) fade_name = "<font color=[name_color]>[name]</font>"
					else fade_name = name

					src << output("<b>[fade_name]</b>", "style_colors.output")

				winset(src, "style_colors.name_color_button", "background-color='[t]'")
				winset(src, "style_colors.name_color", "text='[t]'")

			SetTextColor(t as text|null)
				set hidden = 1

				if(!t) t = "#000000"
				if(copytext(t, 1, 2) != "#") t = "#" + t
				text_color = uppertext(t)

				winset(src, "style_colors.text_color_button", "background-color='[t]'")
				winset(src, "style_colors.text_color", "text='[t]'")

			SetBackground(t as text|null)
				set hidden = 1

				if(!t) t = "#ffffff"
				if(copytext(t, 1, 2) != "#") t = "#" + t
				background = uppertext(t)

				winset(src, "style_colors.background_button", "background-color='[t]'")
				winset(src, "style_colors.background", "text='[background]'")

				if(Chan) winset(src, "[ckey(Chan.name)].chat.default_output", "background-color='[TextMan.escapeQuotes(background)]';")

			SetShowColors(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "true"

				if(t == "false") show_colors = FALSE
				else show_colors = TRUE