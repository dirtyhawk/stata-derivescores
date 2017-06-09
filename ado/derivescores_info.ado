*! derivescores_info.ado: helper script for -derivescores- to display information about a table declaration
/*
	This procedure displays information of -derivescores- initialized table declaration(s) to the user
*/
program define derivescores_info , nclass
	// syntax declaration and macros
	syntax [anything(id="declaration name(s)" name=decnames everything equalok)] [, verbose ]
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
		exit 459
	}
	// if no declaration is explicitly queried, determine list of all declaration numbers
	if (missing(`"`decnames'"') | inlist(`"`decnames'"',"*","_all")) {
		quietly : numlist `"1/${DERIVESCORES_deccount}"'
		local decnums `r(numlist)'
	}
	// determine initialization number for given declaration(s)
	else {
		local decnums
		foreach entry of local decnames {
			local match 0
			forvalues num=1/${DERIVESCORES_deccount} {
				if (`"${DERIVESCORES_dec`num'shortname}"'==`"`entry'"') {
					local decnums : list decnums | num
					local match 1
					continue , break
				}
			}
			if (`match'==0) {
				noisily : display as error in smcl `"{it:`entry'} is not a table declaration that has been initialized"'
				exit 198
			}
		}
	}
	// display information
	foreach decnum of local decnums {
		noisily : display as result in smcl `"*TODO*display info for declaration ${DERIVESCORES_dec`decnum'shortname} here... *TODO*"'
		*!TODO!*
	}
	// quit
	exit 0
end
// EOF
