/*-------------------------------------------------------------------------------
  derivescores_destring.ado: helper script for -derivescores- convert a classification code variable to the corresponding preferred numerical equivalent
  
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
*! derivescores_destring.ado: helper script for -derivescores- convert a classification code variable to the corresponding preferred numerical equivalent
/*
	This procedure displays converts a given string classification code variable
		and generates a numerical variable from it, by using the appropriate
		preferred values from the classification table ('prefValue').
*/
program define derivescores_destring , nclass
	// syntax declaration and macros
	syntax varname(string) , DEClaration(string) [, generate(name) replace verbose LABel labelname(passthru) ]
	// set macros
	local sourcevarname Concept
	local targetvarname prefValue
	local stylevarname labelStyle
	local renamefrom
	local renameto
	local re_renamefrom
	local re_renameto
	tempvar mergesource
	local tableoffset 3 // offset for indenting the whole table
	local tablespace 2 // space between the two table columns
	local col1header `"key"' // column header for column 1
	local col2header `"content"' // column header for column 2
	local maxnamelength=udstrlen(`"`col1header'"') // initialization value for width of column 1
	// abort if -derivescores setup- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores setup} first?"'
		exit 459
	}
	// determine initialization number for given declaration(s)
	local decnum
	forvalues num=1/${DERIVESCORES_dec_count} {
		if (`"${DERIVESCORES_dec`num'_shortname}"'==`"`declaration'"') {
			local decnum `num'
			continue , break
		}
	}
	if (missing(`"`decnum'"')) {
		noisily : display as error in smcl `"{it:`declaration'} is not a table declaration that has been initialized"'
		exit 198
	}
	// check mutually exclusive options `replace' and `generate()'
	if (!missing(`"`replace'"') & !missing(`"`generate'"')) {
		noisily : display as error in smcl `"options {it:generate()} and {it:`replace'} are mutually exclusive
		exit 198
	}
	// replace-scenario: temporarily generate variable as new
	if `"`replace'"'=="replace" {
		tempvar generate
	}
	// assert that `generate' is a new variable
	confirm new variable `generate' , exact
	// check if "Concept" and "prefValue" and so on are unused variable names; add to rename lists, if not
	foreach testvar in `sourcevarname' `targetvarname' `stylevarname' {
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
		// generate helper variable for label style (to match entries in declaration table uniquely)
		generate labelStyle=`"${DERIVESCORES_dec`decnum'_defaultStyle}"'
		// merge with declaration
		noisily : merge m:1 `sourcevarname' `stylevarname' using `"${DERIVESCORES_dec`decnum'_file}"', keepusing(`"`targetvarname'"') keep(match master) generate(`mergesource') noreport nolabel nonotes
		// add successfully merged variable to re-rename lists
		local re_renamefrom : list re_renamefrom | targetvarname
		local re_renameto : list re_renameto | generate
		// save values for reporting results lateron
		if (`"`report'"'!="noreport") {
			count if `mergesource'==3
			local dupmatches `r(N)'
			duplicates report `sourcevarname' if (`mergesource'==3)
			local uniqmatches `r(unique_value)'
			count if `mergesource'==1
			local dupmismatches `r(N)'
			duplicates report `sourcevarname' if (`mergesource'==1)
			local uniqmismatches `r(unique_value)'
		}
		// sort new variable after source variable
		order `targetvarname' , after(`sourcevarname')
	}
	// in case something went wrong: save return code, and abort after re-renaming variables
	local returncode=_rc
	// drop labelStyle
	drop `stylevarname'
	// re-rename variables
	rename (`re_renamefrom') (`re_renameto')
	// label target variable
	label variable `generate' `"`: variable label `varlist''"'
	// if requested, value-label the new variable
	if (`"`label'"'==`"label"') {
		derivescores valuelabel `generate' , declaration(`declaration') `labelname'
	}
	// replace-scenario: interchange (temporary) new and already existing variable names
	if `"`replace'"'=="replace" {
		rename (`varlist' `generate') (`generate' `varlist')
	}
	// abort on errors
	if (`returncode'!=0) {
		exit `returncode'
	}
	// report results
	if (`"`report'"'!="noreport") {
		local maxnamelength 30
		noisily : display as result in smcl _newline `"{text}results from destringing values according to declaration {result}`declaration'{text}:"' _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+`tablespace'' `=c(linesize)-`maxnamelength'-`tablespace'-`tableoffset'-15'}"' _newline `"{p2line}"' _newline `"{text}{p2col:destringed observations:}"' %8.0g `dupmatches' `"{p_end}"' _newline `"{text}{p2col:unchanged observations:}"' %8.0g `dupmismatches' `"{p_end}"' _newline(2) `"{text}{p2col:unique destring matches:}"' %8.0g `uniqmatches' `"{p_end}"' _newline `"{text}{p2col:unique unchanged values:}"' %8.0g `uniqmismatches' `"{p_end}"' _newline `"{p2line}"' _newline `"{p2colreset}"'
	}
	// quit
	exit 0
end
// EOF
