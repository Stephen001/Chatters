BanManager
	var/BanPersistence/banDB = new/BanPersistence/Savefile(new/savefile("data/bans.sav"))

	proc
		isBanned(var/T as text)
			return banDB.isBanned(T)

		ban(var/T as text)
			return banDB.ban(T)

		unban(var/T as text)
			return banDB.unban(T)

		isMuted(var/T as text)
			return banDB.isMuted(T)

		mute(var/T as text)
			return banDB.mute(T)

		unmute(var/T as text)
			return banDB.unmute(T)

		getAllBanned()
			return banDB.getAllBanned()

		getAllMuted()
			return banDB.getAllMuted()