*! derivescores_init.ado: helper script for -derivescores- to initialize derivation tables
/*
	This procedure reads all tables delivered with -derivescores- into Stata,
	and saves them in the user's temporary directory;
	their relevant paths and other metadata are saved in global macros;
	this procedure is supposed to be executed before any other -derivescores-
	subcommand is called, and will automatically be executed if the called
	procedure detects that -derivescores init- has not been run in the Stata
	session before
*/
program define derivescores_init , nclass
	// syntax declaration and macros
	*! TODO
	
	// quit
	exit 0
end
// EOF
