*! derivescores_wipe.ado: helper script for -derivescores- to cleanup everything left behind from -derivescores init-
/*
	This procedure erases everything that -derivescores init- leaves behind, especially:
		- all temporary files in the temporary directory
		- the temporary directory itself
		- all global macros in Stata's memory that start with the text "DERIVESCORES";
		- all Mata matrixes, vectors, scalars and functions in Stata's memory that start with the text "DERIVESCORES";
	this procedure is supposed to be executed after a session with -derivescores-
	is finished, to make sure a new session can begin afterwards without
	encountering conflicts in older or newer initialization info
*/
program define derivescores_wipe , nclass
	// syntax declaration and macros
	syntax [, verbose ]
	local temppath `"`c(tmpdir)'/DERIVESCORES_tmp"'
	local pwd `"`c(pwd)'"'
	capture : cd `"`temppath'"'
	if (_rc==0) {
		quietly : cd `"`pwd'"'
		// erase all files from temppath
		local filelist: dir "`temppath'" files "*.*" , respectcase
		foreach file of local filelist {
			if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"erasing file {result}{it:`temppath'/`file'}{text}"'
			rm `"`temppath'/`file'"'
		}
		// erase temporary directory
		if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"erasing directory {result}{it:`temppath'}{text}"'
		rmdir `"`temppath'"'
	}
	// erase all globals from Stata's memory, and matrices from Mata
	if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"erasing global macros {result}{it:DERIVESCORES*}{text} from Stata's memory"'
	macro drop DERIVESCORES*
	mata : mata drop DERIVESCORES* DERIVESCORES*()
	// quit
	exit 0
end
// EOF
