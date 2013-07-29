QuoteManager
	New()
		loadQuotes()

		server_manager.logger.info("Created QuoteManager.")

	Del()
		server_manager.logger.info("Deleted QuoteManager.")

	var
		list/quotes = null

	proc
		loadQuotes()
			if(fexists("./data/quotes.txt"))
				quotes = list()

				var
					f = textutil.replaceText(file2text("./data/quotes.txt"), "\n", "")
					list/split = textutil.text2list(f, ";;")

				for(var/q in split)
					if(q)
						var/list/qsplit = textutil.text2list(q, "##")

						if(length(qsplit) >= 2)
							var/Quote/quote = new
							quote.author = qsplit[1]
							quote.text = qsplit[2]
							if(length(qsplit) >= 3) quote.link = qsplit[3]

							quotes += quote

				server_manager.logger.info("Loaded [length(quotes)] quote(s) from quotes.txt.")

			else
				server_manager.logger.warn("quotes.txt does not exist to be loaded.")

		getQOTD()
			if(!quotes || !length(quotes)) return

			var
				t = time2text(world.timeofday, "MMDD")
				month = text2num(copytext(t, 1, 3))
				day = text2num(copytext(t, 3))

				qloc = ((month - 1) * 12) + day // compute the location of today's quote in the quote list
				Quote/q
				qlen = length(quotes)

			if(qloc && (qloc <= qlen)) q = quotes[qloc]
			else
				qloc = round(qloc % qlen)
				if(qloc < 1) qloc = 1
				if(qloc > qlen) qloc = qlen
				q = quotes[qloc]

			if(q)
				var/qtxt = "\"[q.text]\"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - [q.author]"
				if(q.link) qtxt += " ([q.link])"

				return qtxt

Quote
	var
		text = ""
		link = ""
		author = ""
