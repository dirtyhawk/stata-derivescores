*! derivescores_list.ado: helper script for -derivescores- to display available (initialized) classification and crosswalk declarations
/*
	This procedure lists table declarations initialized by -derivescores- to the user,
	and link to the appropriate further information command
*/
program define derivescores_list , nclass
	// syntax declaration and macros
	syntax [, verbose ]
	// set macros
	local tableoffset 3
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
		exit 459
	}
	// get maximum length of declaration names for creating table structure
	local maxnamelength 16
	forvalues num=1/${DERIVESCORES_deccount} {
		if (udstrlen(`"${DERIVESCORES_dec`num'shortname}"')>`maxnamelength') local maxnamelength=udstrlen(`"${DERIVESCORES_dec`num'shortname}"')+`tableoffset'+2
	}
	// build table displaying information
	noisily : display as result in smcl _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+2' 0}{text}{p2col:declaration}content{p_end}"' _newline `"{p2line}"'
	forvalues num=1/${DERIVESCORES_deccount} {
		// display information per table declaration
		noisily : display as result in smcl `"{p2col:${DERIVESCORES_dec`num'shortname}}${DERIVESCORES_dec`num'label}"',,cond(missing(`"${DERIVESCORES_dec`num'label}"'),""," ("),,`"{stata derivescores info "${DERIVESCORES_dec`num'shortname}":more information}"',,cond(missing(`"${DERIVESCORES_dec`num'label}"'),"",")"),,`"{p_end}"'
	}
	noisily : display as result in smcl "{p2colreset}" _continue
	// quit
	exit 0
end
// EOF
