
mob
	Temp
		Login()
			..()

			var/timer = world.timeofday
			while(!client)
				if(world.timeofday > timer+180) del(src)
				sleep(-1)

			ChatMan.Usher(src)

		verb // temp fix for interface initialization
			InsertTag(var/X as text|null)
			InsertColor(var/X as text|null)
			SetGender(var/X as text|null)
