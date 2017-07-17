
/*-------------------------------------------------------------------------------
  derivescores_crosswalk.ado: crosswalk a variable from one classification to another
  
    Copyright (C) 2017 	Daniel Bela (daniel.bela@lifbi.de)
			Knut Wenzig

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------*/
*! derivescores_crosswalk.ado: crosswalk a variable from one classification to another
/*
	This procedure converts a variable in a given classification to another
		classification, generating a new variable from it; naturally, it
		needs a matching correspondence declaration initialized by
		-derivescores setup-
*/
program define derivescores_crosswalk , nclass
	// syntax declaration and macros
	syntax varname(string) , FROMdeclaration(string) TOdeclaration(string) generate(name) [, AUXiliary(varlist) ASNUMeric ]
	// check options, prepare macros
	confirm new variable `generate', exact
	local probmarkername probmarker
	local sourcevarname sourceConcept
	local targetvarname targetConcept
	local renamefrom
	local renameto
	local re_renamefrom
	local re_renameto
	tempvar mergesource
	local tableoffset 3 // offset for indenting the whole table
	local tablespace 2 // space between the two table columns
	// abort if -derivescores setup- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores setup} first?"'
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
	// cross-check number of needed and specified auxilliary variables, warn if none specified, abort if too many or too less specified
	if (!missing(`"${DERIVESCORES_dec`decnum'_auxvars}"')) {
		local auxvars ${DERIVESCORES_dec`decnum'_auxvars}
		local needed_auxvarcount : word count `auxvars'
		local given_auxvarcount : word count `auxiliary'
		if (`needed_auxvarcount'>1) local plural s
		if (`needed_auxvarcount'==`given_auxvarcount') {
			local rename_auxvars `auxiliary'
		}
		else if (`given_auxvarcount'==0) {
			noisily : display as result in smcl `"{error}Warning:{text} the correspondence declaration {result}{it:`declaration'}{text} expects {result}`needed_auxvarcount'{text} auxiliary variable`plural'; you specified none; to continue, auxiliary variable`plural' will be assumed (and temporarily created) containing the value {it:0} for all observations"'
			local create_auxvars `auxvars'
		}
		else {
			noisily : display as error in smcl `"the correspondence declaration {it:`declaration'} expects {it:`needed_auxvarcount'} auxiliary variable`plural'; you specified {it:`given_auxvarcount'} (namely: {it:`auxiliary'})"'
			exit 198
		}
	}
	else {
		if (!missing(`"`auxiliary'"')) di as err "HAST HILFSVARS ANGEGEBEN, BRAUCHSTE ABER NICHT!"
	}
	// check if "sourceConcept" and "targetConcept" and so on are unused variable names; add to rename lists, if not
	foreach testvar in `probmarkername' `sourcevarname' `targetvarname' `auxvars' {
		capture : confirm variable `testvar' , exact
		if (_rc==0) {
			tempvar `testvar'
			local renamefrom : list renamefrom | testvar
			local re_renamefrom : list re_renamefrom | `testvar'
			local renameto : list renameto | `testvar'
			local re_renameto : list re_renameto | testvar
		}
	}
	// bring sourcevariable name to rename list
	local renamefrom : list renamefrom | varlist
	local re_renamefrom : list re_renamefrom | sourcevarname
	local renameto : list renameto | sourcevarname
	local re_renameto : list re_renameto | varlist
	// rename variables to match correspondence declaration
	rename (`renamefrom') (`renameto')
	// everything between here and the hoefully successful merge shall not abort;
	// if it does regardless, we have to cleanup the oddly renamed variables in the dataset before termination
	capture {
		// create probability marker for merging
		quietly : generate `probmarkername'=5
		// rename auxiliary variables as needed
		if (!missing(`"`rename_auxvars'"')) {
			rename (`rename_auxvars') (`auxvars')
			local re_renamefrom : list re_renamefrom | auxvars
			local re_renameto : list re_renameto | rename_auxvars
		}
		// create ommitted auxiliary variables (if any)
		else if (!missing(`"`create_auxvars'"')) {
			foreach auxvar of local create_auxvars {
				generate `auxvar'=0
			}
		}
		// merge with declaration
		noisily : merge m:1 `sourcevarname' `probmarkername' `auxvars' using `"${DERIVESCORES_dec`decnum'_file}"' , keep(master match) generate(`mergesource') keepusing(`targetvarname') noreport nolabel nonotes
		// add successfully merged variable to re-rename lists
		local re_renamefrom : list re_renamefrom | targetvarname
		local re_renameto : list re_renameto | generate
		// save values for reporting results lateron
		if (`"`report'"'!="noreport") {
			count if `mergesource'==3
			local dupmatches `r(N)'
			duplicates report `sourcevarname' `probmarkername' `auxvars' if (`mergesource'==3)
			local uniqmatches `r(unique_value)'
			count if `mergesource'==1
			local dupmismatches `r(N)'
			duplicates report `sourcevarname' `probmarkername' `auxvars' if (`mergesource'==1)
			local uniqmismatches `r(unique_value)'
		}
		// sort new variable after source variable
		order `targetvarname' , after(`sourcevarname')
	}
	// in case something went wrong: save return code, and abort after re-renaming variables
	local returncode=_rc
	// remove probmarker
	drop `probmarkername'
	// remove newly created auxiliary variables
	if (!missing(`"`create_auxvars'"')) {
		drop `create_auxvars'
	}
	// re-rename variables
	rename (`re_renamefrom') (`re_renameto')
	// abort on errors
	if (`returncode'!=0) {
		exit `returncode'
	}
	// label target variable
	label variable `generate' `"`: variable label `varlist'' [`todeclaration']"'
	// report results
	if (`"`report'"'!="noreport") {
		local maxnamelength 30
		noisily : display as result in smcl _newline `"{text}results from crosswalking {result}`declaration'{text}:"' _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+`tablespace'' `=c(linesize)-`maxnamelength'-`tablespace'-`tableoffset'-15'}"' _newline `"{p2line}"' _newline `"{text}{p2col:matched observations:}"' %8.0g `dupmatches' `"{p_end}"' _newline `"{text}{p2col:unmatched observations:}"' %8.0g `dupmismatches' `"{p_end}"' _newline(2) `"{text}{p2col:unique matches:}"' %8.0g `uniqmatches' `"{p_end}"' _newline `"{text}{p2col:unique non-matches:}"' %8.0g `uniqmismatches' `"{p_end}"' _newline `"{p2line}"' _newline `"{p2colreset}"'
	}
	// convert targetConcept to classifications prefValue, if specified
	if (!missing(`"`asnumeric'"')) {
		*! will work as soon as -derivescores destring- is finished *!
		derivescores destring `generate' , declaration(`todeclaration') replace
		derivescores label `generate' , declaration(`todeclaration')
	}
	// quit
	exit 0
end
// EOF
