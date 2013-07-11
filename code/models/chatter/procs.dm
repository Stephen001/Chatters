
mob
	chatter
		proc
			ReturnAFK()
				Home.ReturnAFK(src)

			ParseMsg(mob/chatter/M, msg, msg_format[], emote, rp)
				if(!M || !msg || !msg_format || !msg_format.len) return

				var/parsed_msg = ""
				var/ign = ignoring(M)
				msg = trim(msg)
				var/rp_start = findtext(msg, ":")
				if(rp_start == 1)
					var/rp_end = findtext(msg, ":", 2)
					if(rp_end)
						var/RP = copytext(msg, 2, rp_end)
						msg = copytext(msg, rp_end+1)
						return ParseMsg(M, msg, src.rpsay_format, 0, RP)

				var/punctuation
				var/msg_punctuation = copytext(msg, length(msg))
				switch(msg_punctuation)
					if(".")
						punctuation = "."
						if(forced_punctuation)
							if(copytext(msg, length(msg)) == ".")
								if((msg_format.Find("said") > msg_format.Find("$msg")) || (msg_format.Find("says") > msg_format.Find("$msg")))
									msg = copytext(msg, 1, length(msg))+","
					if("!") punctuation = "!"
					if("?") punctuation = "?"
					else
						punctuation = "."
						if(forced_punctuation)
							if((msg_format.Find("said") > msg_format.Find("$msg")) || (msg_format.Find("says") > msg_format.Find("$msg")))
								msg += ","
							else msg += "."

				for(var/s in msg_format)
					if(s == "$name")
						if((ign & COLOR_IGNORE) || !show_colors)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s")
									end = "'"
								parsed_msg += M.name+end
							else
								parsed_msg += M.name
						else if((ign & FADE_IGNORE) || emote || rp)
							if(emote == 2)
								var/end = "'s"
								if(copytext(M.name, length(M.name)-1) == "s")
									end = "'"
								parsed_msg += "<font color=[M.name_color]>[M.name][end]</font>"
							else
								parsed_msg += "<font color=[M.name_color]>[M.name]</font>"
						else
							if(M.fade_name)
								parsed_msg += M.fade_name
							else
								parsed_msg += "<font color=[M.name_color]>[M.name]</font>"
					else if(s == "$rp")
						if((ign & COLOR_IGNORE) || !show_colors)
							parsed_msg += rp
						else
							if(M.name_color)
								parsed_msg += "<font color=[M.name_color]>[rp]</font>"
					else if(s == "$msg")
						if(name_notify)
							// Highlight your name!
							msg = kText.replaceText(msg, name, "<font color='red'>[name]</font>")

						if((ign & COLOR_IGNORE) || !show_colors)
							parsed_msg += msg
						else if(!emote)
							parsed_msg += "<font color=[M.text_color]>[msg]</font>"
						else
							parsed_msg += "<font color=[M.name_color]>[msg]</font>"
					else if(s == "$ts")
						parsed_msg += ParseTime()
					else if(s == "says")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaims"
							if("?") parsed_msg += "asks"
					else if(s == "said")
						switch(punctuation)
							if(".") parsed_msg += s
							if("!") parsed_msg += "exclaimed"
							if("?") parsed_msg += "asked"
					else parsed_msg += s

				return parsed_msg


			ParseTime(hide_ticker)
				var/parsed_msg = ""
				var/timestamp = round(world.timeofday + src.time_offset * 36000, 1)
				var/hour = time2text(timestamp, "hh")
				var/min = time2text(timestamp, "mm")
				var/sec = time2text(timestamp, "ss")
				if (!_24hr_time)
					hour = text2num(hour)
					var/ampm = " [hour > 11 ? "pm" : "am"]"
					hour = (hour % 12) || 12
					hour = "[hour < 10 ? "0" : ""][hour]"
					if ("ss" in time_format)
						sec += ampm
					else if ("mm" in time_format)
						min += ampm
					else
						hour += ampm

				for(var/delimiter in time_format)
					switch(delimiter)
						if ("hh") parsed_msg += hour
						if ("mm") parsed_msg += min
						if ("ss") parsed_msg += sec
						if (":")  parsed_msg += hide_ticker ? " " : ":"
						else 	  parsed_msg += delimiter

				return parsed_msg


			ignoring(mob/M)
				if(ignoring && ignoring.len)
					if(istext(M))
						if(ckey(M) in ignoring)
							var/ign = ignoring[ckey(M)]
							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign
					if(ismob(M))
						if(ckey(M.name) in ignoring)
							var/ign = ignoring[ckey(M.name)]
							if(ign == FULL_IGNORE) return FULL_IGNORE-1
							else return ign


			fsize(F)
				var/l=length(F);if(isnum(F))l=F
				if(l<1024)return"[round(l,0.01)]B"; l/=1024
				if(l<1024)return"[round(l,0.01)]KB";l/=1024
				if(l<1024)return"[round(l,0.01)]MB";l/=1024
				.="[l]GB"
