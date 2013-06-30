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