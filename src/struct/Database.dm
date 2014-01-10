Database
	var/host   = "localhost"
	var/port   = "3306"
	var/user   = "chatters"
	var/pass   = null
	var/dbname = "chatters"
	var/tmp/DBConnection/connection = null
	var/tmp/list/availableSchema = null

	New()
		src.availableSchema = flist("schema/")
		for (var/I in 1 to length(src.availableSchema))
			src.availableSchema[I] = copytext(src.availableSchema[I], 1, length(src.availableSchema[I]))
		QuickSort(src.availableSchema, /Database/proc/__sortSchemaVersions)

	proc
		connect()
			if (src.connection != null && src.isConnected())
				return TRUE
			src.connection = new/DBConnection("dbi:mysql:[src.dbname]:[src.host]:[src.port]", src.user, src.pass)
			return src.connection.Connect()

		testConnectionDetails()
			var/DBConnection/tempConnection = new/DBConnection("dbi:mysql:[src.dbname]:[src.host]:[src.port]", src.user, src.pass)
			var/result = tempConnection.Connect()
			if (result)
				tempConnection.Disconnect()
			return result

		isConnected()
			return src.connection != null && src.connection.IsConnected()

		__sortSchemaVersions(A, B)
			return sorttext(A, B)

		installedSchema()
			if (src.isConnected())
				var/DBQuery/query = src.connection.NewQuery("SHOW TABLES LIKE [src.quote("SCHEMA_VERSION")]")
				query.Execute()
				if (!query.RowCount())
					return null
				query = src.connection.NewQuery("SELECT * FROM SCHEMA_VERSION")
				query.Execute()
				query.NextRow()
				var/list/results = query.GetRowData()
				query.Close()
				return "[results["major"]].[results["minor"]].[results["patch"]]"
			return null

		latestAvailableSchema()
			return src.availableSchema[length(src.availableSchema)]

		needsUpgrade()
			return sorttext(src.latestAvailableSchema(), src.installedSchema()) > 0

		select(var/text)
			var/list/results = new()
			if (src.isConnected())
				server_manager.logger.trace("Selecting: [text]")
				var/DBQuery/query = src.connection.NewQuery(text)
				if (query.Execute())
					while (query.NextRow())
						var/result = query.GetRowData()
						server_manager.logger.trace("Select results: [list2params(result)]")
						for(var/key in result)
							var/list/L = results["[key]"]
							if (isnull(L))
								L = list()
								results["[key]"] = L
							L += result["[key]"]
				else
					server_manager.logger.error("Error: [query.ErrorMsg()]")
				query.Close()
				server_manager.logger.trace("[length(results)] rows from select")
			return results

		singleSelect(var/text)
			if (src.isConnected())
				server_manager.logger.trace("Single selecting: [text]")
				var/DBQuery/query = src.connection.NewQuery(text)
				if (query.Execute())
					if (query.NextRow())
						var/result = query.GetRowData()
						server_manager.logger.trace("Single select results: [list2params(result)]")
						return result
				else
					server_manager.logger.error("Error: [query.ErrorMsg()]")
				query.Close()
				server_manager.logger.trace("No result from single select")
			return null

		sendUpdate(var/text)
			if (src.isConnected())
				server_manager.logger.trace("Executing update for: [text]")
				var/DBQuery/query = src.connection.NewQuery(text)
				if (!query.Execute())
					server_manager.logger.error("Error: [query.ErrorMsg()]")
					return FALSE
				return TRUE
			return FALSE

		countSelect(var/text)
			if (src.isConnected())
				server_manager.logger.trace("Counting: [text]")
				var/DBQuery/query = src.connection.NewQuery(text)
				if (query.Execute())
					var/count = query.RowCount()
					server_manager.logger.trace("Count returns [count]")
					return count
				else
					server_manager.logger.error("Error: [query.ErrorMsg()]")
				query.Close()
			return null

		quote(var/text)
			return src.connection.Quote(text)
