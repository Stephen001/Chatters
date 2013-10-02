TextManager
	New()
		server_manager.logger.info("Created TextManager.")

	Del()
		server_manager.logger.info("Deleted TextManager.")

	var
		list
			tags = list("\[code]"       = "\[/code]",
						"\[b]"          = "\[/b]",
						"\[i]"          = "\[/i]",
						"\[u]"          = "\[/u]",
						"\[s]"          = "\[/s]",
						"\[#"           = "\[/#]",
						"\[img]"        = "\[/img]")

			html = list("<code>"        = "</code>",
						"<b>"           = "</b>",
						"<i>"           = "</i>",
						"<u>"           = "</u>",
						"<s>"           = "</s>",
						"<font color=#" = "</font>",
						"<img src='"    = "'>")

			links = list("id"	   	    = "http://www.byond.com/forum/?post=$s",
						 "hub"		    = "http://www.byond.com/games/$s",
						 "people"   	= "http://www.byond.com/people/$s",
						 "wiki"		    = "http://en.wikipedia.org/wiki/$s",
						 "bing"         = "http://www.bing.com/search?q=$s",
						 "google"	    = "http://www.google.com/search?q=$s",
						 "yahoo"        = "http://search.yahoo.com/search?p=$s",
						 "define"	    = "http://dictionary.reference.com/browse/$s",
						 "urban"	    = "http://www.urbandictionary.com/define.php?term=$s",
						 "imdb"		    = "http://imdb.com/find?s=all&q=$s",
						 "snopes"	    = "http://search.atomz.com/search/?sp-a=00062d45-sp00000000&sp-q=$s",
						 "acronym"	    = "http://www.acronymfinder.com/af-query.asp?Acronym=$s",
						 "synonym"	    = "http://thesaurus.reference.com/browse/$s",
						 "youtube"	    = "http://www.youtube.com/watch?v=$s",
						 "myspace"	    = "http://www.myspace.com/$s",
						 "amazon"       = "http://www.amazon.com/s/field-keywords=$s",
						 "newegg"       = "http://www.newegg.com/Product/ProductList.aspx?Submit=ENE&DEPA=0&Order=BESTMATCH&Description=$s&N=-1&isNodeId=1",
						 "facebook"     = "http://www.facebook.com/$s",
						 "reddit"       = "http://www.reddit.com/search?q=$s",
						 "youtube"      = "http://www.youtube.com/results?search_query=$s",
						 "bbash"	    = "http://gazoot.byondhome.com/bbash/?quote=$s",
						 "bash"		    = "http://www.bash.org/?$s",
						 "condo"	    = "http://gazoot.byondhome.com/condo/site.dmb?browse&owner=$s",
						 "issue"	    = "https://github.com/Stephen001/Chatters/issues/$s",
						 "dm"			= "http://www.byond.com/docs/ref/info.html#$s")

	proc
		sanitize(msg)
			if(!msg) return
			var/pos = findtext(msg, "\\...")

			while(pos)
				var
					part1 = copytext(msg, 1, pos)
					part2 = copytext(msg, pos + 4)

				msg = part1 + part2
				pos = findtext(msg, "\\...")

			pos = findtext(msg, ascii2text(10))

			while(pos)
				var
					part1 = copytext(msg, 1, pos)
					part2 = copytext(msg, pos + 1)

				msg = part1 + part2
				pos = findtext(msg, ascii2text(10))

			pos = findtext(msg, "\t")

			while(pos)
				var
					part1 = copytext(msg, 1, pos)
					part2 = copytext(msg, pos + 1)

				msg = part1 + part2
				pos = findtext(msg, "\t")

			msg = html_encode(msg)

			return msg

		parseSmileys(msg)
			if(!msg) return

			var
				list/C = parseCode(msg)
				list/R = new()

			for(var/c in C)
				if(C[c] == "code")
					R += c

					continue

				R += s_smileys(c, 0, './rsc/icons/smileys.dmi')

			msg = textutil.list2text(R, "")

			return msg


		parseLinks(msg)
			if(!msg) return

			var
				list/C = parseCode(msg)
				list/R = new()

			for(var/c in C)
				if(C[c] == "code")
					R += c

					continue

				var/temp = c
				for(var/L in links)
					var/pos = findtext(temp, "[L]:")

					while(pos)
						var
							end = pos + length(L)+1
							t_end = findtext(temp, " ", end)

						if(!t_end) t_end = length(temp) + 1

						var
							part1 = copytext(temp, 1, pos)
							query = copytext(temp, end, t_end)

						if(findtextEx(query, "<IMG")) // temp bug fix, breaks links :(
							pos = findtext(temp, "[L]:", t_end)// would rather not parse
							continue				// smileys instead of breaking links

						var
							part2 = copytext(temp, t_end)
							replace = findtext(links[L], "$s")
							link_part1
							link_part2

						if(!replace)
							temp = part1 + "<a href=\"" + links[L] + query + "\">[L]:[query]</a>" + part2
							t_end = length(part1 + "<a href=\"" + links[L] + query + "\">[L]:[query]</a>")

						else
							link_part1 = copytext(links[L], 1, replace)
							link_part2 = copytext(links[L], replace+2)
							temp = part1 + "<a href=\"" + link_part1 + query + link_part2 + "\">[L]:[query]</a>" + part2
							t_end = length(part1 + "<a href=\"" + link_part1 + query + link_part2 + "\">[L]:[query]</a>")

						if(length(part2)) pos = findtext(temp, "[L]:", t_end)
						else pos = 0

				R += temp

			msg = textutil.list2text(R, "")

			return msg

		parseCode(msg)
				/**
					msg: blah[code]foo[/code]bar
					return val: list("blah", "foo" = "code", "bar")
				**/

			if(!msg) return

			var
				list/L = new()
				pos = findtext(msg, "\[code]")

			if(length(msg) < pos+6)
				L += msg

				return L

			while(pos)
				var
					end = findtext(msg, "\[/code]")
					end_tag

				if(!end) end = length(msg)
				else end_tag = end + 7

				var/part1 = copytext(msg, 1, pos)

				if(part1) L += part1

				var/code = copytext(msg, pos, end_tag)

				L += code
				L[code] = "code"

				if(end_tag) msg = copytext(msg, end_tag)
				else msg = ""

				pos = findtext(msg, "\[code]")

			if(msg) L += msg

			return L

		parseTags(msg, Color, Highlight)
			if(!msg) return

			var/i = 1
			for(var/T in tags)
				var/pos = findtext(msg, T)

				while(pos)
					var/end = findtext(msg, tags[T], pos + 1)
					if(!end) end = length(msg) + 1
					if(T == "\[code]")
						if(end > pos + 6)
							var
								code = html_decode(copytext(msg, pos + 6, end))
								temp = copytext(msg, 1, pos)

							if(code && length(code))
								temp += html_encode(code)
								if(end < length(msg))
									temp += copytext(msg, end + 7)

							msg = temp

						else
							// Empty tags
							msg = copytext(msg, 1, pos) + copytext(msg, end + length(tags[T]))

					else if(T == "\[#")
						var/t_end = findtext(msg, "]", pos, pos + 6)
						if(!t_end) t_end = findtext(msg, "]", pos, pos + 9)
						if(t_end && (end > t_end + 1))
							var
								color = copytext(msg, pos + 2, t_end)
								temp = copytext(msg, 1, pos)

							if(Color) temp += html[i] + color + ">"
							if(end)
								temp += copytext(msg, t_end + 1, end)
								temp += html[html[i]]
								temp += copytext(msg, end + length(tags[T]))

							msg = temp

						else if(end == t_end + 1 && end <= length(msg))
							msg = copytext(msg, 1, pos) + copytext(msg, end + length(tags[T]))

					else if(pos + length(T) < end)
						var/temp = copytext(msg, 1, pos)

						temp += html[i]
						temp += copytext(msg, pos + length(T), end)

						if(end)
							temp += html[html[i]]
							temp += copytext(msg, end + length(tags[T]))

						msg = temp

					pos = findtext(msg, T, pos + 1)

				i++

			return msg

		qotd(mob/chatter/trg)
			if(!trg || !trg.client)
				del(trg)

				return

			var/qotd = quote_manager.getQOTD()

			server_manager.home.qotd = text_manager.parseTags(qotd, trg.show_colors, trg.show_highlight)

			if(server_manager.home.qotd)
				if(trg.show_colors) trg << output("<center><b>[fadeText("Developer Quote of the Day", list("255000000","000000000"))]</b>", "chat.default_output")
				else trg << output("<center><b>Developer Quote of the Day</b>", "chat.default_output")

				trg << output("<center><i style='font-family: Arial'>[server_manager.home.qotd]</i></center>", "chat.default_output")

		// Simple string matching procedure.
		// Crashed, C*a*h*d will match.
		// Crashed, Crah*d will not (missing s).
		// Crashed, Crash* will match.
		// Crashed, Crash will not (missing ed).
		match(string, pattern)
			if(!string || !pattern) return 0

			var
				parts[] = list()
				find = findtext(pattern, "*")
				start_wild = find == 1
				end_wild = text2ascii(pattern, length(pattern)) == 42 // '*'

			while(find)
				if(find > 1) parts += copytext(pattern, 1, find)
				pattern = copytext(pattern, find + 1)
				find = findtext(pattern, "*")

			if(pattern) parts += pattern

			if(!length(parts)) return 1 // "*" pattern

			find = findtext(string, parts[1])
			if(!find || (!start_wild && find != 1))
				return 0

			find += length(parts[1])
			parts.Cut(1, 2)

			for(var/part in parts)
				find = findtext(string, part, find)

				if(find) find += length(part)
				else return

			return end_wild || find == length(string) + 1

		fadeText(text, list/colors)
			if(!colors) return text
			if((!text) || (!length(text))) return
			if((!colors) || (!length(colors))) return text

			var
				list/links = new()
				list/text_nlinks = skipLinks(text, links)

			text = text_nlinks[1]
			links = text_nlinks[2]

			if(!length(text)) return 0

			var
				list/txt = text_manager.splitChars(text)

				list/treds = new()
				list/tgreens = new()
				list/tblues = new()

				list/red_delta = new()
				list/green_delta = new()
				list/blue_delta = new()

				color_span = length(text)

				tr = 0
				tg = 0
				tb = 0

			for(var/x = 1, x <= length(colors), x++)
				treds += text2num(copytext(colors[x], 1, 4))
				tgreens += text2num(copytext(colors[x], 4, 7))
				tblues += text2num(copytext(colors[x], 7))

			if(length(colors) == 1)
				return "<font color=[rgb(treds[1], tgreens[1], tblues[1])]>[text]</font>"

			if(length(colors) >= 2)
				color_span = round(color_span / (length(colors) - 1))
				if(!color_span) color_span = 0.01

				for(var/x = 2, x <= length(colors), x++)
					red_delta += (treds[x-1] - treds[x]) / color_span
					green_delta += (tgreens[x-1] - tgreens[x]) / color_span
					blue_delta += (tblues[x-1] - tblues[x]) / color_span

			else
				red_delta += color_span
				green_delta += color_span
				blue_delta += color_span

			if(color_span < 1)
				for(var/n = 1, n <= length(txt), n++)
					txt[n] = "<span style='color: rgb([treds[n]],[tgreens[n]],[tblues[n]]);'>[txt[n]]</span>"

				return textutil.list2text(restoreLinks(txt, links), "")

			for(var/x = 1, x <= length(colors) - 1, x ++)
				tr = treds[x]
				tg = tgreens[x]
				tb = tblues[x]

				var
					segment_start = ((x * color_span) - color_span) + 1
					segment_end = x * color_span

				if(x == (length(colors) - 1))
					segment_end = length(text)

				for(var/t = segment_start, t <= segment_end, t++)
					txt[t] = "<font color=[rgb(tr, tg, tb)]>[txt[t]]</font>"

					tr -= red_delta[x]
					tg -= green_delta[x]
					tb -= blue_delta[x]

			return textutil.list2text(restoreLinks(txt, links), "")

		stripHTML(text)
			if((!text) || (!length(text))) return
			if(!findtext(text, "<")) return text

			var/pos = findtext(text, "<")

			while(pos)
				var/pos2 = findtext(text, ">", pos)

				if(pos2)
					if(findtext(text, "<", pos + 1, pos2 - 1))
						pos = findtext(text, "<", pos2)

						continue

					var
						part1 = copytext(text, 1, pos)
						part2 = copytext(text, pos2 + 1)

					text = part1 + part2
					pos = findtext(part2, "<")

					if(pos) pos += length(part1)

				else pos = findtext(text, "<", pos + 1)

			return text

		skipLinks(text, list/links)
			var/pos1 = findtext(text,"http://")

			if(!pos1) pos1 = findtext(text, "byond://")
			if(!pos1) pos1 = findtext(text, "telnet://")
			if(!pos1) pos1 = findtext(text, "irc://")
			if(!pos1) pos1 = findtext(text, "<img ")

			if(pos1)
				var
					pos2
					part1
					link
					link_hold
					part2
					text_copy

				while(pos1)
					pos2 = findtext(text, "<", pos1)

					if(!pos2) pos2 = findtext(text," ", pos1)
					if(!pos2) pos2 = findtext(text, ascii2text(9), pos1)	// tab character
					if(!pos2) pos2 = findtext(text, ascii2text(10), pos1)	// newline character
					if(!pos2) pos2 = length(text) + 1

					part1 = copytext(text, 1, pos1)
					link = copytext(text, pos1, pos2)
					part2 = copytext(text, pos2)
					link_hold = ""

					for(var/i = length(link), i > 0, i--)
						link_hold += "�E"

					pos1 = findtext(part2, "http://")

					if(!pos1) pos1 = findtext(part2, "byond://")
					if(!pos1) pos1 = findtext(part2, "telnet://")
					if(!pos1) pos1 = findtext(part2, "irc://")
					if(!pos1) pos1 = findtext(text, "<img ")

					text = part2

					if(!pos1) text_copy += part1 + link_hold + part2
					else text_copy += part1 + link_hold

					if(!links || !length(links)) links = new()
					links += link

				text = text_copy

			return list(text, links)

		restoreLinks(list/L, list/links)
			if(!L) return
			if(!links) return L

			var/pos = 1

			while(length(links))
				for(var/l = pos, l <= length(L) + 1, l++)
					pos = l

					if(!findtext(L[l], "�E")) continue
					else
						L[l] = links[1]

						break

				for(var/l = 0, l < length(links[1])-1, l++)
					L -= L[pos+1]

				links -= links[1]

			return L

		hex2dec(hex)
			hex = (uppertext(hex) || "0")

			var
				dec
				step = 1
				hexlist = list( "0" = 0, "1" = 1, "2" = 2, "3" = 3,
								"4" = 4, "5" = 5, "6" = 6, "7" = 7,
								"8" = 8, "9" = 9, "A" = 10,"B" = 11,
								"C" = 12,"D" = 13,"E" = 14,"F" = 15)

				hexes = invertList(text_manager.splitChars(hex))

			for(var/h in hexes)
				dec += hexlist[h] * step
				step *= 16

			return dec

		invertList(list/L = list())
			if(length(L))
				var/head = 1, tail = length(L)
				while((head != tail) && (head != tail + 1))
					L.Swap(head ++, tail --)

			return L

		splitChars(string)
			if(!string) return list()

			. = list()
			for(var/i = 1, i <= length(string), i ++)
				. += copytext(string, i, i + 1)

		escapeQuotes(string)
			string = textutil.replaceText(string, "'" , "\'")
			string = textutil.replaceText(string, "\"" , "\\\"")
			return string
