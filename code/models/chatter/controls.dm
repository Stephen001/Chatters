
mob
	chatter
		verb
			NewInstantMessage()
				set hidden = 1
				var/Messenger/im = new(src)
				im.Display(src)

			SelectColor(scope as text|null)
				set hidden = 1
				if(!scope) return
				CV.Display(scope)

			Join()
				set hidden = 1
				if(afk) ReturnAFK()
				ChanMan.Join(src, Home)

			Quit()
				set hidden = 1
				ChanMan.Quit(src, Home)

			SayAlias(msg as text|null)
				set name = ">"
				Say(msg)
