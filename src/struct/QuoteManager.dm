QuoteManager
	New()
		quote_changer_event = new(server_manager.global_scheduler)
		server_manager.global_scheduler.schedule(quote_changer_event, 864000)

		server_manager.logger.info("Created QuoteManager.")

	Del()
		server_manager.global_scheduler.cancel(quote_changer_event)
		server_manager.logger.info("Deleted QuoteManager.")

	var
		list/quotes = null

		tmp
			qotd_current = 0
			Event/Timer/QuoteChanger/quote_changer_event
			Event/Timer/BotFacts/bot_facts

	proc
		loadQuotes()
			if (!length(quotes))
				server_manager.logger.info("Loading quote(s) from quotes.txt.")
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
			if(!qotd_current)
				loadQuotes()
				set_new_quote()
				if (qotd_current)
					getQOTD()
			else
				var/Quote/q = quotes[qotd_current]
				var/qtxt = "\"[q.text]\"<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - [q.author]"
				if(q.link)
					qtxt += " ([q.link])"
				return qtxt

		set_new_quote()
			if (length(quotes))
				if (qotd_current >= length(quotes))
					qotd_current = 1
			else
				qotd_current = 0
			server_manager.logger.info("QuoteManager set current quote number to [qotd_current] of [length(quotes)].")

Quote
	var
		text = ""
		link = ""
		author = ""


Event/Timer/QuoteChanger
	var/QuoteManager/quoteManager

	New(var/EventScheduler/scheduler, var/QuoteManager/quoteManager)
		..(scheduler, 864000)
		src.quoteManager = quoteManager

	fire()
		quoteManager.set_new_quote()
		..()