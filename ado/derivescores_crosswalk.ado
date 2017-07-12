*! derivescores_crosswalk.ado: crosswalk a variable from one classification to another
/*
	This procedure converts a variable in a given classification to another
		classification, generating a new variable from it; naturally, it
		needs a matching correspondence declaration initialized by
		-derivescores init-
*/
program define derivescores_crosswalk , nclass
	// syntax declaration and macros
	syntax varname(string) , FROMdeclaration(string) TOdeclaration(string) generate(name) [, AUXiliary(varlist) ASNUMeric ]
	// check options, prepare macros
	confirm new variable `generate', exact
	local sourcevarname sourceConcept
	local targetvarname targetConcept
	local renamefrom
	local renameto
	local re_renamefrom
	local re_renameto
	tempvar mergesource
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
		exit 459
	}
	// determine initialization number for given crosswalk declaration
	local decnum
	local declaration `"`fromdeclaration' → `todeclaration'"'
	forvalues num=1/${DERIVESCORES_dec_count} {
		if (`"${DERIVESCORES_dec`num'_shortname}"'==`"`declaration'"') {
			local decnum `num'
			continue , break
		}
	}
	if (missing(`"`decnum'"')) {
		noisily : display as error in smcl `"{it:`declaration'} is not a correspondence declaration that has been initialized"'
		exit 198
	}
	// cross-check number of needed and specified auxilliary variables, warn if incompletely specified, abort if too many specified
	*! TODO !*
	// if any: add auxiliary variables to rename lists
	*! TODO !*
	// check if "sourceConcept" and "targetConcept" are unused variable names; add to rename lists, if not
	foreach testvar in `"`sourcevarname'"' `"`targetvarname'"' {
		capture : confirm variable `testvar' , exact
		if (_rc==0) {
			tempvar `testvar'
			local renamefrom : list renamefrom | testvar
			local re_renamefrom : list re_renamefrom | `testvar'
			local renameto : list renameto | `testvar'
			local re_renameto : list re_renameto | testvar
		}
	}
	// rename sourcevariable name
	local renamefrom : list renamefrom | varlist
	local re_renamefrom : list re_renamefrom | sourcevarname
	local renameto : list renameto | sourcevarname
	local re_renameto : list re_renameto | varlist
	// rename variables to match correspondence declaration
	rename (`renamefrom') (`renameto')
	// merge with declaration
	merge m:1 `sourcevarname' using `"${DERIVESCORES_dec`decnum'_file}"' , keep(master match) generate(`mergesource') keepusing(`targetvarname')
	// re-rename variables
	rename (`re_renamefrom' `targetvarname') (`re_renameto' `generate')
	// label target variable
	label variable `generate' `"`: variable label `varlist'' [`todeclaration']"'
	// report results
	*! TODO !*
	// convert targetConcept to classifications prefValue, if specified
	if (!missing(`"`asnumeric'"')) {
		*! TODO *!
	}
	// quit
	exit 0
end
// EOF
