BanPersistence
	var
		list/banned = new()
		list/muted  = new()

	proc
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
	
	Savefile
		var/savefile/database = null
		
		New(var/savefile/F)
			src.database = F
			src.database["banned"] >> src.banned
			src.database["muted"] >> src.muted
		
		Del()
			src.database["banned"] << src.banned
			src.database["muted"] << src.muted
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
		
