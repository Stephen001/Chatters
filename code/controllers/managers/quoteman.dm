QuoteManager
	New()
		..()

		loadQuotes()

	var
		list/quotes = null

	proc
		loadQuotes()
			quotes = list()

			var
				f = kText.replaceText(file2text("data/quotes.txt"), "\n", "")
				list/split = kText.text2list(f, ";;")

			for(var/q in split)
				if(q)
					var/list/qsplit = kText.text2list(q, "##")

					if(length(qsplit) >= 2)
						var/Quote/quote = new
						quote.author = qsplit[1]
						quote.text = qsplit[2]
						if(length(qsplit) >= 3) quote.link = qsplit[3]

						quotes += quote

		getQOTD()
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
				var/qtxt = "\"[q.text]\"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - [q.author]"
				if(q.link) qtxt += " ([q.link])"

				return qtxt

Quote
	var
		text = ""
		link = ""
		author = ""