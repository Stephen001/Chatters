mob
	chatter
		verb
			SetDefaultFormatStyle()
				set hidden = 1

				SetNameNotify()
				SetChatFormat()
				SetEmoteFormat()
				SetInlineEmoteFormat()
				SetTimeFormat()
				SetDateFormat()
				SetLongDateFormat()
				SetOutputStyle()

			SetNameNotify(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "false"

				if(t == "true") name_notify = TRUE
				else name_notify = FALSE

			SetChatFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts <b>$name:</b> $msg"

				var
					list/variables = list("$ts","$name","$msg","says","said")
					list/required = list("$name","$msg")

				say_format = ChatMan.ParseFormat(t, variables, required)
				winset(src, "style_formats.chat_format", "text='[TextMan.escapeQuotes(t)]'")

			SetEmoteFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts $name $msg"

				var
					list/variables = list("$ts","$name","$msg")
					list/required = list("$name","$msg")

				me_format = ChatMan.ParseFormat(t, variables, required)
				winset(src, "style_formats.emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetInlineEmoteFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "$ts $name $rp: $msg"

				var
					list/variables = list("$ts","$name","$rp","$msg","says","said")
					list/required = list("$name","$rp","$msg")

				rpsay_format = ChatMan.ParseFormat(t, variables, required)
				winset(src, "style_formats.inline_emote_format", "text='[TextMan.escapeQuotes(t)]'")

			SetTimeFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "<font size=1>\[hh:mm:ss]</font>"

				var/list/variables = list("hh","mm","ss")
				time_format = ChatMan.ParseFormat(t, variables)
				winset(src, "style_formats.time_format", "text='[TextMan.escapeQuotes(t)]'")

			SetDateFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "MMM MM, `YY"

				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				date_format = ChatMan.ParseFormat(t, variables)
				winset(src, "style_formats.date_format", "text='[TextMan.escapeQuotes(t)]'")

			SetLongDateFormat(t as text|null)
				set hidden = 1

				if(isnull(t)) t = "Day, Month DD, YYYY"

				var/list/variables = list("YYYY","YY","Month","MMM","MM","Day","DDD","DD")
				long_date_format = ChatMan.ParseFormat(t, variables)
				winset(src, "style_formats.long_date_format", "text='[TextMan.escapeQuotes(t)]'")

			SetOutputStyle(t as text|null)
				set hidden = 1
				if(isnull(t)) t = "body { background-color: #ffffff; }"

				default_output_style = t
				winset(src, "[ckey(Home.name)].chat.default_output", "style='[TextMan.escapeQuotes(t)]';")
				winset(src, "style_formats.output_style", "text='[TextMan.escapeQuotes(default_output_style)]';")
