Layout
	proc
		formatLog(log, level, name)
		startLog()
		endLog()

	PlaintextLayout
		startLog() return "Logging started at [time2text(world.timeofday)]"

		formatLog(log, level, name = "root")
			if(log)
				log = "\[[name]\] {[num2text(world.time, 32)] ([time2text(world.timeofday, "hh:mm:ss")])} {[level2text(level)] ([level])}: [log]\n"

				return log

		endLog() return "Logging ended at [time2text(world.timeofday)]"

	HTMLLayout
		startLog() return {"
			<i>Logging started at [time2text(world.timeofday)]</i><br>
			<table border=1 cellspacing=0 style='width: 100%;'><tr style='text-align: center; background-color: #000000; color: #FFFFFF;'><td><b>TIME</b></td><td><b>LEVEL</b></td><td><b>LOGGER</b></td><td width="75%"><b>MESSAGE</b></td></tr>"}

		formatLog(log, level, name = "root")
			var
				time_format = "[num2text(world.time, 32)] ([time2text(world.timeofday, "hh:mm:ss")])"
				level_format = "[level2text(level)] ([level])"
				name_format = "[name]"
				log_format = "[log]"

			if(level == LOG_FATAL)
				time_format = "<b><font color=#FF0000>[time_format]</font><b>"
				level_format = "<b><font color=#FF0000>[level_format]</font><b>"
				name_format = "<b><font color=#FF0000>[name_format]</font><b>"
				log_format = "<b><font color=#FF0000>[log_format]</font><b>"

			if(level == LOG_ERROR)
				time_format = "<font color=#FF0000>[time_format]</font>"
				level_format = "<font color=#FF0000>[level_format]</font>"
				name_format = "<font color=#FF0000>[name_format]</font>"
				log_format = "<font color=#FF0000>[log_format]</font>"

			if(level == LOG_WARN)
				time_format = "<b>[time_format]</b>"
				level_format = "<b>[level_format]</b>"
				name_format = "<b>[name_format]</b>"
				log_format = "<b>[log_format]</b>"

			log = "<tr><td>[time_format]</td><td>[level_format]</td><td>[name_format]</td><td>[log_format]</td></tr>"

			return log

		endLog() return "</table><i>Logging ended at [time2text(world.timeofday)]</i><hr>"