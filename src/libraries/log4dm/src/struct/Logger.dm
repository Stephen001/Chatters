#define CHATTERS_LOGGING

Logger
	var
		name = ""
		level = LOG_ALL
		logging = FALSE
		additivity = TRUE
		Appender/default_appender
		list/appenders = null
		list/loggers = null

	New(Appender/_default_appender, _name)
		if(_default_appender) addAppender(_default_appender, 1)
		name = _name

	proc
		fatal(log) _log(log, LOG_FATAL)
		error(log) _log(log, LOG_ERROR)
		warn(log) _log(log, LOG_WARN)
		info(log) _log(log, LOG_INFO)
		debug(log) _log(log, LOG_DEBUG)
		trace(log) _log(log, LOG_TRACE)

		getLogger(name)
			if(name in loggers) return loggers[name]
			else
				if(!loggers) loggers = list()

				var/Logger/logger = new/Logger(, name)
				addLogger(logger, name)

				return logger

		addLogger(Logger/logger, name)
			if(!loggers) loggers = list(name = logger)
			else
				loggers += name
				loggers[name] = logger

				if(logging && !logger.logging) logger.startLogging()
				else if(!logging && logger.logging) logger.endLogging()

		removeLogger(name)
			loggers -= name
			if(!length(loggers)) loggers = null

		setLevel(level)
			ASSERT(level <= LOG_OFF && level >= LOG_ALL)
			src.level = level

		getLevel() return level

		_log(log, level)
			if(!logging) return

			if(level < src.level) return

			#ifdef CHATTERS_LOGGING
			for(var/Appender/FileAppender/appender in appenders)
				var/time = time2text(world.realtime, "DD.MM.YY")
				if(!fexists("./data/logs/[time].html"))
					appender.endLog()
					appender.setOutputFile("./data/logs/[time].html")
					appender.startLog()
			#endif

			for(var/Appender/appender in appenders) appender.append(log, level, name)

			for(var/name in loggers)
				var/Logger/logger = loggers[name]
				logger._log(log, level)

		startLogging()
			logging = TRUE

			for(var/Appender/appender in appenders) appender.startLog()

			for(var/name in loggers)
				var/Logger/logger = loggers[name]
				if(!logger.logging) logger.startLogging()

		endLogging()
			logging = FALSE

			for(var/Appender/appender in appenders) appender.endLog()

			for(var/name in loggers)
				var/Logger/logger = loggers[name]
				if(logger.logging) logger.endLogging()

		addAppender(Appender/appender, default = 0)
			if(!appenders) appenders = list(appender)
			else appenders += appender

			if(default) default_appender = 1

			for(var/name in loggers)
				var/Logger/logger = loggers[name]
				if(logger.additivity) logger.addAppender(appender, default)

		removeAppender(Appender/appender)
			appenders -= appender
			if(!length(appenders)) appenders = null

			for(var/name in loggers)
				var/Logger/logger = loggers[name]
				if(logger.additivity) logger.removeAppender(appender)

		htmlFileConfig(file)
			ASSERT(file)

			var
				Layout/HTMLLayout/html_layout = new
				Appender/FileAppender/file_appender = new(html_layout, file)

			addAppender(file_appender, 1)

		plaintextFileConfig(file)
			ASSERT(file)

			var
				Layout/PlaintextLayout/plaintext_layout = new
				Appender/FileAppender/file_appender = new(plaintext_layout, file)

			addAppender(file_appender, 1)

		plaintextWorldLogConfig()
			var
				Layout/PlaintextLayout/plaintext_layout = new
				Appender/WorldLogAppender/worldlog_appender = new(plaintext_layout)

			addAppender(worldlog_appender, 1)