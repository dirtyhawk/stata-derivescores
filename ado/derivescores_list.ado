/*-------------------------------------------------------------------------------
  derivescores_list.ado: helper script for -derivescores- to display available (initialized) classification and crosswalk declarations
  
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
*! derivescores_list.ado: helper script for -derivescores- to display available (initialized) classification and crosswalk declarations
/*
	This procedure lists table declarations initialized by -derivescores- to the user,
	and link to the appropriate further information command
*/
program define derivescores_list , nclass
	// syntax declaration and macros
	syntax [, verbose AUXiliary ]
	// set macros
	local tableoffset 3 // offset for indenting the whole table
	local tablespace 2 // space between the two table columns
	local col1header `"[no.] declaration"' // column header for column 1
	local col2header `"content"' // column header for column 2
	local maxnamelength=udstrlen(`"`col1header'"') // initialization value for width of column 1
	// abort if -derivescores setup- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores setup} first?"'
		exit 459
	}
	// get maximum length of declaration names for creating table structure
	forvalues num=1/${DERIVESCORES_dec_count} {
		// ignore auxiliary variable "classifications" (unless specified otherwise)
		if (missing(`"`auxiliary'"') & ustrregexm(`"${DERIVESCORES_dec`num'_shortname}"',"aux[0-9]+$")) {
			continue
		}
		if (udstrlen(`"[`num'] ${DERIVESCORES_dec`num'_shortname}"')+`tableoffset'+`tablespace'>`maxnamelength') local maxnamelength=udstrlen(`"[`num'] ${DERIVESCORES_dec`num'_shortname}"')+`tableoffset'+`tablespace'
	}
	// build table displaying information
	noisily : display as result in smcl _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+`tablespace'' 0}{text}{p2col:`col1header'}`col2header'{p_end}"' _newline `"{p2line}"'
	forvalues num=1/${DERIVESCORES_dec_count} {
		// ignore auxiliary variable "classifications" (unless specified otherwise)
		if (missing(`"`auxiliary'"') & ustrregexm(`"${DERIVESCORES_dec`num'_shortname}"',"aux[0-9]+$")) {
			continue
		}
		// display information per table declaration
		noisily : display as result in smcl `"{p2col:[`num'] ${DERIVESCORES_dec`num'_shortname}}"',,cond(`"${DERIVESCORES_dec`num'_type}"'==`"Correspondence"',`"correspondence from `=word(`"${DERIVESCORES_dec`num'_shortname}"',1)' to `=word(`"${DERIVESCORES_dec`num'_shortname}"',-1)'"',`"${DERIVESCORES_dec`num'_label}"'),,`" ({stata derivescores info "${DERIVESCORES_dec`num'_shortname}":more information}){p_end}"'
	}
	noisily : display as result in smcl "{p2colreset}" _continue
	// quit
	exit 0
end
// EOF

