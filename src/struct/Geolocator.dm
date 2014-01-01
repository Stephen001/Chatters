Geolocator
	var
		url = null

	New(var/url as text)
		src.url = url

	proc
		geolocate(target)
			if (isnull(src.url))
				return list()
			var/mob/chatter/C
			if(ismob(target)) C = target
			else C = chatter_manager.getByKey(target)

			if(C && C.client) target = C.client.address
			target = copytext(target, 1, 16)

			var/http[] = world.Export("[src.url][target]")
			if(!http || !file2text(http["CONTENT"]))
				server_manager.logger.warn("Failed to geolocate [target].")
				return

			var/content = file2text(http["CONTENT"])

			content = copytext(content, 2, length(content) - 1)
			content = textutil.replaceText(content, ":", "=")
			content = textutil.replaceText(content, ",", "&")
			content = textutil.replaceText(content, "\"", "")

			return params2list(content)