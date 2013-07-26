var/const
	LOG_OFF = 6
	LOG_FATAL = 5
	LOG_ERROR = 4
	LOG_WARN = 3
	LOG_INFO = 2
	LOG_DEBUG = 1
	LOG_TRACE = 0
	LOG_ALL = -1

proc/level2text(level)
	switch(level)
		if(LOG_OFF) return "OFF"
		if(LOG_FATAL) return "FATAL"
		if(LOG_ERROR) return "ERROR"
		if(LOG_WARN) return "WARN"
		if(LOG_INFO) return "INFO"
		if(LOG_DEBUG) return "DEBUG"
		if(LOG_TRACE) return "TRACE"
		if(LOG_ALL) return "ALL"