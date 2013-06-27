mob/chatter
	var/color_scope

	verb
		PickColor(var/color as text|null)
			set hidden = 1

			winshow(src, "color_picker", 0)
			if(!color) return

			if(findtext(color_scope, "color")==1)
				var/num = text2num(copytext(color_scope, 6))
				if(!num || (num > fade_colors.len)) return
				fade_colors[num] = color
				winset(src, "style_colors.color[num]", "background-color='[color]'")

			else
				switch(color_scope)
					if("name")
						if(fade_name == "<font color=[name_color]>[name]</font>") fade_name = null
						if(color == "#000000") name_color = null
						else name_color = color

						if(!fade_name || (fade_name == name))
							if(name_color) fade_name = "<font color=[name_color]>[name]</font>"
							else fade_name = name

						winset(src, "style_colors.name_color_button", "background-color='[color]'")
						winset(src, "style_colors.name_color", "text='[color]'")
						src << output("<b>[fade_name]</b>", "style_colors.output")

					if("text")
						if(color == "#000000") text_color = null
						else text_color = color

						winset(src, "style_colors.text_color_button", "background-color='[color]'")
						winset(src, "style_colors.text_color", "text='[color]'")

					if("background")
						background = color
						winset(src, "style_colors.background_button", "background-color='[color]'")
						winset(src, "style_colors.background", "text='[color]'")

					//if("op_rank") SetOpRankColor(color)

	proc
		ColorDisplay(scope)
			if(!scope) return
			color_scope = scope

			winshow(src, "color_picker", 1)