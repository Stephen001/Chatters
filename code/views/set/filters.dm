mob
	chatter
		verb
			BrowseFilters()
				set hidden = 1

				SetDisplay(src, "filters")

			UpdateFilters()
				set hidden = 1

				ShowFilterList()
				winset(src, "filters.updated", "is-visible=true")

				if(winget(src, "filters.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "filters.saved", "is-visible=true")

				sleep(50)

				winset(src, "filters.updated", "is-visible=false")
				winset(src, "filters.saved", "is-visible=false")

			SetDefaultFilters()
				set hidden = 1

				if(winget(src, "filters.save", "is-checked") == "true")
					winsize = winget(src, "default", "size")
					ChatMan.Save(src)
					winset(src, "filters.saved", "is-visible=true")

				sleep(50)

				if(src && client)
					winset(src, "filters.updated", "is-visible=false")
					winset(src, "filters.saved", "is-visible=false")

			SetFilter(t as text|null)
				set hidden = 1

				if(!t) t = "0"

				switch(t)
					if("0")
						filter = 0
						ShowFilterList()
						winset(src, "filters.no_filter", "is-checked=true")
						winset(src, "filters.my_filter", "is-checked=false")
						winset(src, "filters.chan_filter", "is-checked=false")

					if("1")
						filter = 1
						ShowFilterList(filtered_words)
						winset(src, "filters.no_filter", "is-checked=false")
						winset(src, "filters.my_filter", "is-checked=true")
						winset(src, "filters.chan_filter", "is-checked=false")

					if("2")
						filter = 2
						if(Home) ShowFilterList(Home.filtered_words)
						winset(src, "filters.no_filter", "is-checked=false")
						winset(src, "filters.my_filter", "is-checked=false")
						winset(src, "filters.chan_filter", "is-checked=true")

			AddWord()
				set hidden = 1

				var
					f_word = winget(src, "filters.filtered_word_input", "text")
					r_word = winget(src, "filters.replacement_word_input", "text")

				if(!f_word || !r_word) return
				if(!filtered_words) filtered_words = new
				if(!(f_word in filtered_words)) filtered_words += f_word

				filtered_words[f_word] = r_word
				ShowFilterList()

			RemoveWord()
				set hidden = 1

				var
					f_word = winget(src, "filters.filtered_word_input", "text")
					r_word = winget(src, "filters.replacement_word_input", "text")

				if(!f_word && !r_word) return
				if(!filtered_words) return
				if(f_word in filtered_words) filtered_words -= f_word
				if(r_word)
					for(var/word in filtered_words)
						if(filtered_words[word] == r_word)
							filtered_words -= word

				ShowFilterList()

			SetFilteredWord(t as text|null)
				set hidden = 1

				winset(src, "filters.filtered_word_input", "text='[t]';")

			SetReplacementWord(t as text|null)
				set hidden = 1

				winset(src, "filters.replacement_word_input", "text='[t]';")

		proc
			ShowFilterList(list/L)
				set hidden = 1

				if(!L) switch(filter)
					if(0) L = list("No filtered words")
					if(1)
						if(filtered_words) L = filtered_words
						else L = list("No filtered words")

					if(2)
						if(Home) L = Home.filtered_words
						else
							winset(src, "filters.chan_filter", "is-disabled=true;")
							L = list("No filtered words")

				if(filter==1)
					winset(src, "filters.filtered_word_label", "text-color='#333';")
					winset(src, "filters.replacement_word_label", "text-color='#333';")
					winset(src, "filters.filtered_word_input", "is-disabled=false;background-color='#FFF';")
					winset(src, "filters.replacement_word_input", "is-disabled=false;background-color='#FFF';")
					winset(src, "filters.add_word", "is-disabled=false;")
					winset(src, "filters.remove_word", "is-disabled=false;")

				else
					winset(src, "filters.filtered_word_label", "text-color='#BBB';")
					winset(src, "filters.replacement_word_label", "text-color='#BBB';")
					winset(src, "filters.filtered_word_input", "is-disabled=true;background-color='#CCC';")
					winset(src, "filters.replacement_word_input", "is-disabled=true;background-color='#CCC';")
					winset(src, "filters.add_word", "is-disabled=true;")
					winset(src, "filters.remove_word", "is-disabled=true;")

				if(Home) winset(src, "filters.chan_filter", "is-disabled=false;")

				for(var/i=1, i<=L.len, i++)
					if(i&1) winset(src, "filters.grid", "style='body{background-color:#CCC;}';")
					else winset(src, "filters.grid", "style='body{background-color:#DDD;}';")

					winset(src, "filters.grid", "current-cell=1,[i]")
					src << output(L[i], "filters.grid")
					winset(src, "filters.grid", "current-cell=2,[i]")
					src << output(L[L[i]], "filters.grid")

				winset(src, "filters.grid", "cells=2x[L.len]")