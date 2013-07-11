
ChannelManager
	var/telnet_pass
	var/telnet_attempts
	var/Server/server = new()

	New()
		..()
		spawn()
			LoadServerCfg()
			LoadHome()

	Del()
		if(Home) SaveHome()
		..()

	proc
		Join(mob/chatter/C, Channel/Chan)
			Chan.Join(C)

		Quit(mob/chatter/C, Channel/Chan)
			Chan.Quit(C)

		Say(mob/chatter/C, msg)
			C.Chan.Say(C, msg)

		SaveHome(Channel/Chan)
			var/savefile/S = new("./data/saves/Home.sav")
			S["mute"]		<< Home.mute
			S["banned"]		<< Home.banned
			S["operators"]  << Home.operators

		LoadHome(chan)
			var/savefile/S = new("./data/saves/Home.sav")
			S["mute"]		>> Home.mute
			S["banned"]		>> Home.banned
			S["operators"]  >> Home.operators

		LoadServerCfg()
			var/list/config = Console.LoadCFG("./data/saves/server.cfg")
			if(!config || !config.len) return

			var/list/H = params2list(config["main"])
			if(!H || !H.len) return
			server.host = ckey(H["host"])

			var/list/D = params2list(config["devs"])
			if(D && D.len)
				for(var/d in D) server.developers += ckey(D[d])

			var/list/muteList = params2list(config["mute"])
			var/list/banList = params2list(config["bans"])
			var/list/opList = params2list(config["ops"])

			var/list/S = params2list(config["server"])
			if(S && S.len)

				telnet_pass     = S["telnet_pass"]
				telnet_attempts = (text2num(S["telnet_attempts"]) || -1)

				var/ChanName  = S["name"]
				var/Founder   = S["founder"]
				var/ChanDesc  = S["desc"]
				var/ChanTopic = S["topic"]
				var/Publicity = S["publicity"]
				var/Locked    = S["locked"]

				var/botName        = S["bot_name"]
				var/botNameColor   = S["bot_name_color"]
				var/botTextColor   = S["bot_text_color"]

				var/botSpamControls= text2num(S["bot_spam_control"]) ? 1 : 0
				var/botSpamLimit   = text2num(S["bot_spam_limit"])
				var/botFloodLimit  = text2num(S["bot_flood_limit"])
				var/botSmileysLimit= text2num(S["bot_smileys_limit"])
				var/botMaxMsgs     = text2num(S["bot_max_msgs"])
				var/botMinDelay    = text2num(S["bot_min_delay"])

				Home = new(list(
					"Founder"=Founder,
					"Name"=ChanName,
					"Publicity"=Publicity,
					"Desc"=ChanDesc,
					"Topic"=ChanTopic,
					"Locked"=Locked,
					"TelPass"=telnet_pass,
					"TelAtmpts"=telnet_attempts))
				if(Publicity != "public") world.visibility = 0

				Home.chanbot.SetName(botName)
				Home.chanbot.SetNameColor("#"+botNameColor)
				Home.chanbot.SetTextColor("#"+botTextColor)
				Home.chanbot.SetSpamControl(botSpamControls)
				Home.chanbot.SetSpamLimit(botSpamLimit)
				Home.chanbot.SetFloodLimit(botFloodLimit)
				Home.chanbot.SetSmileysLimit(botSmileysLimit)
				Home.chanbot.SetMaxMsgs(botMaxMsgs)
				Home.chanbot.SetMinDelay(botMinDelay)

				if(muteList && muteList.len)
					Home.mute = new
					for(var/i in muteList)
						Home.mute += ckey(i)
				if(banList && banList.len)
					Home.banned = new
					for(var/i in banList)
						Home.banned += ckey(i)
				if(opList && opList.len)
					Home.operators = list()
					for(var/Name in opList)
						var/opKey = ckey(opList[Name])
						Home.operators += opKey

