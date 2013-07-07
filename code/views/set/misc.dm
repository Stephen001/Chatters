mob
	chatter
		verb
			BrowseMisc()
				set hidden = 1
				SetDisplay("misc")

			SetDefaultMisc()
				set hidden = 1

				SetShowSmileys(1)
				SetShowImages(1)

			SetShowSmileys(t as text|null)
				set hidden = 1

				if(t)
					winset(src, "misc.show_smileys", "is-checked=true")
					show_smileys = TRUE
				else
					if(winget(src, "misc.show_smileys", "is-checked")=="true")
						show_smileys = TRUE
					else
						show_smileys = FALSE

			SetShowImages(t as text|null)
				set hidden = 1
				if(t)
					winset(src, "misc.show_images", "is-checked=true")
					show_images = TRUE
				else
					if(winget(src, "misc.show_images", "is-checked")=="true")
						show_images = TRUE
					else
						show_images = FALSE

			/*FlipPanes()
				set hidden = 1

				if(winget(src, "misc.flip_panes", "is-checked")=="true") flip_panes = TRUE
				else flip_panes = FALSE

				if(!flip_panes) winset(src, "default.child", "left=[ckey(Chan.name)];right=[ckey(Chan.name)].who;splitter=80")
				else winset(src, "default.child", "left=[ckey(Chan.name)].who;right=[ckey(Chan.name)];splitter=20")*/