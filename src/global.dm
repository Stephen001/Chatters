// Preprocessor Definitions

// Ignore Scopes
#define NO_IGNORE     0
#define IM_IGNORE     1
#define CHAT_IGNORE   2
#define FADE_IGNORE   4
#define COLOR_IGNORE  8
#define SMILEY_IGNORE 16
#define IMAGES_IGNORE 32
#define FILES_IGNORE  64
#define FULL_IGNORE   128

// Global variables and procedures
var/global
	kText/textutil = new

	ServerManager/server_manager
	ChatterManager/chatter_manager
	TextManager/text_manager
	QuoteManager/quote_manager

proc
	createManagers()
		server_manager = new
		chatter_manager = new
		text_manager = new
		quote_manager = new

	deleteManagers()
		del(chatter_manager)
		del(text_manager)
		del(quote_manager)
		del(server_manager)