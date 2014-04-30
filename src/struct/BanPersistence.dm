BanPersistence
	var
		list/banned
		list/muted

	proc
		start()
			src.banned = new()
			src.muted = new()

		stop()
			src.banned = null
			src.muted = null

		isBanned(var/C as text)
			return (C in src.banned)

		isMuted(var/C as text)
			return (C in src.muted)

		ban(var/C as text)
			if (!(C in src.banned))
				src.banned.Add(C)
			return 1

		unban(var/C as text)
			if (C in src.banned)
				src.banned.Remove(C)
			return 1

		mute(var/C as text)
			if (!(C in src.muted))
				src.muted.Add(C)
			return 1

		unmute(var/C as text)
			if (C in src.muted)
				src.muted.Remove(C)
			return 1

		getAllBanned()
			return src.banned

		getAllMuted()
			return src.muted

	Savefile
		var/savefile/database = null

		New(var/savefile/F)
			src.database = F

		start()
			src.database["banned"] >> src.banned
			if (isnull(src.banned))
				src.banned = new()
			src.database["muted"] >> src.muted
			if (isnull(src.muted))
				src.muted = new()

		stop()
			src.database["banned"] << src.banned
			src.database["muted"] << src.muted
			sleep(10) // We need this to let the save go through.
			..()

		ban(var/C as text)
			. = ..()
			src.database["banned"] << src.banned
			return .

		unban(var/C as text)
			. = ..()
			src.database["banned"] << src.banned
			return .

		mute(var/C as text)
			. = ..()
			src.database["muted"] << src.muted
			return .

		unmute(var/C as text)
			. = ..()
			src.database["muted"] << src.muted
			return .

