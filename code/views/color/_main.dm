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
						if(color)
							name_color = color

							winset(src, "style_colors.name_color_button", "background-color='[color]'")
							winset(src, "style_colors.name_color", "text='[color]'")

							src << output(null, "style_colors.output")

							if(fade_name) src << output("[fade_name]", "style_colors.output")
							else src << output("<font color=[name_color]>[name]</font>", "style_colors.output")

							Chan.UpdateWho()

					if("text")
						text_color = color

						winset(src, "style_colors.text_color_button", "background-color='[color]'")
						winset(src, "style_colors.text_color", "text='[color]'")

					if("interface")
						interface_color = color
						winset(src, "style_colors.interface_button", "background-color='[color]'")
						winset(src, "style_colors.interface", "text='[color]'")

					//if("op_rank") SetOpRankColor(color)

	proc
		ColorDisplay(scope)
			if(!scope) return
			color_scope = scope

			winshow(src, "color_picker", 1)