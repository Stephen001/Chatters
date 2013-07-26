Appender
	var/Layout/layout = null

	New(Layout/_layout)
		layout = _layout

	proc
		startLog() if(layout) append(layout.startLog(), 0, "", FALSE)
		endLog() if(layout) append(layout.endLog(), 0, "", FALSE)

		append(log, level, name, format = TRUE)
			if(!layout) layout = new/Layout/PlaintextLayout

		setLayout(Layout/_layout)
			ASSERT(_layout)
			layout = _layout

		getLayout() return layout

	FileAppender
		var/output_file = ""

		New(Layout/_layout, _output_file)
			layout = _layout
			output_file = _output_file

			..()

		append(log, level, name, format = TRUE)
			..()

			if(format) log = layout.formatLog(log, level, name)
			if(output_file) text2file(log, output_file)

			return log

		proc
			setOutputFile(_output_file) output_file = _output_file
			getOutputFile() return output_file

	WorldLogAppender
		append(log, level, name,  format = TRUE)
			..()

			if(format) log = layout.formatLog(log, level, name)
			world.log << log