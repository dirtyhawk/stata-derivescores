*! derivescores_list.ado: helper script for -derivescores- to display available (initialized) classification and crosswalk declarations
/*
	This procedure lists table declarations initialized by -derivescores- to the user,
	and link to the appropriate further information command
*/
program define derivescores_list , nclass
	// syntax declaration and macros
	syntax [, verbose ]
	// set macros
	local tableoffset 3 // offset for indenting the whole table
	local tablespace 2 // space between the two table columns
	local col1header `"[no.] declaration"' // column header for column 1
	local col2header `"content"' // column header for column 2
	local maxnamelength=udstrlen(`"`col1header'"') // initialization value for width of column 1
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
		exit 459
	}
	// get maximum length of declaration names for creating table structure
	forvalues num=1/${DERIVESCORES_dec_count} {
		if (udstrlen(`"[`num'] ${DERIVESCORES_dec`num'_shortname}"')>`maxnamelength') local maxnamelength=udstrlen(`"[`num'] ${DERIVESCORES_dec`num'_shortname}"')+`tableoffset'+`tablespace'
	}
	// build table displaying information
	noisily : display as result in smcl _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+`tablespace'' 0}{text}{p2col:`col1header'}`col2header'{p_end}"' _newline `"{p2line}"'
	forvalues num=1/${DERIVESCORES_dec_count} {
		// display information per table declaration
		noisily : display as result in smcl `"{p2col:[`num'] ${DERIVESCORES_dec`num'_shortname}}${DERIVESCORES_dec`num'_label}"',,cond(missing(`"${DERIVESCORES_dec`num'_label}"'),""," ("),,`"{stata derivescores info "${DERIVESCORES_dec`num'_shortname}":more information}"',,cond(missing(`"${DERIVESCORES_dec`num'_label}"'),"",")"),,`"{p_end}"'
	}
	noisily : display as result in smcl "{p2colreset}" _continue
	// quit
	exit 0
end
// EOF
