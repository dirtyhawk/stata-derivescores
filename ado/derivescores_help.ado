*! derivescores_help.ado: helper script for -derivescores- to display inline help
/*
	This procedure displays a syntax diagram of -derivescores- and links to the
	appropriate help file.
	It is supposed to be called if anything goes wrong when running -derivescores-,
	or if explicitly opened with -derivescores help-. 
*/
program define derivescores_help , nclass
	// issue help message
	noisily : display as error _newline in smcl `"{text}This help message is a stub. Please help improving {cmd:derivescores} by writing a real help text. Lateron, it will be expanded to a full Stata help file."'
	// quit
	exit 0
end
// EOF
