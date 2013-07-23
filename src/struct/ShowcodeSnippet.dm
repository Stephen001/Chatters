ShowcodeSnippet
	var
		id
		owner = ""
		target = ""

		code
		timestamp

	New()
		..()
		// Generates a unique ID for the code snippet based off the global array showcodes.
		if(!server_manager.home.showcodes)
			server_manager.home.showcodes = list()

		id = length(server_manager.home.showcodes) + 1
		server_manager.home.showcodes += src

	proc
		returnHTML(mob/chatter/C, code = 0)
			if(!C) return

			var/html

			if(C.show_highlight && code)
				html = {"
					<html>
					<head>
					<link rel="stylesheet" href="http://yandex.st/highlightjs/6.2/styles/default.min.css">
					<script src="http://yandex.st/highlightjs/6.2/highlight.min.js"></script>
					<style>body {margin: 4px; overflow: auto; background-color: #ffffff}</style>
					<script>hljs.initHighlightingOnLoad();</script>
					<title>[owner]'s Highlighted Showcode</title>
					</head>
					<body><pre><code>[html_encode(src.code)]</code></pre></body>
					</html>"}

			else if(code)
				html = {"
					<html>
					<head>
					<style>body {margin: 4px; overflow: auto; background-color: #ffffff}</style>
					<title>[owner]'s Showcode</title>
					</head>
					<body><pre><code>[src.code]</code></pre></body>
					</html> "}

			else
				html = {"
					<html>
					<head>
					<style>body {margin: 4px; overflow: auto; background-color: #ffffff}</style>
					<title>[owner]'s Showtext</title>
					</head>
					<body>[src.code]</body>
					</html>"}

			return html

		send(code = 0)
			if(!target)
				// This is shown to the channel.
				server_manager.bot.rawSay("Click <a href='byond://?src=\ref[chatter_manager]&target=\ref[chatter_manager.getByKey(owner)]&action=show[code ? "code" : "text"]&index=[id]'>here</a> to view [owner]'s [code ? "code" : "text"] snippet.")

			else
				var
					Messenger/im = new(chatter_manager.getByKey(owner), target)
					mob/chatter/o = chatter_manager.getByKey(owner)

				im.display(o)
				o.msg_hand.routeMsg(o, chatter_manager.getByKey(target), "[owner] has sent a private [code ? "code" : "text"] snippet.  <a href='byond://?src=\ref[chatter_manager]&target=\ref[chatter_manager.getByKey(owner)]&action=show[code ? "code" : "text"]&index=[id]'>Show [code ? "Code" : "Text"]</a>", 1)
