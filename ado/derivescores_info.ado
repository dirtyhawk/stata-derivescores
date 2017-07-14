*! derivescores_info.ado: helper script for -derivescores- to display information about a table declaration
/*
	This procedure displays information of -derivescores- initialized table declaration(s) to the user
*/
program define derivescores_info , nclass
	// syntax declaration and macros
	syntax [anything(id="declaration name(s)" name=decnames everything equalok)] [, verbose ]
	// set macros
	local tableoffset 3 // offset for indenting the whole table
	local tablespace 2 // space between the two table columns
	local col1header `"key"' // column header for column 1
	local col2header `"content"' // column header for column 2
	local maxnamelength=udstrlen(`"`col1header'"') // initialization value for width of column 1
	local keypriority `"type shortname label note defaultStyle labelStyles sourcelink deeplink"'
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
		exit 459
	}
	// if no declaration is explicitly queried, determine list of all declaration numbers
	if (missing(`"`decnames'"') | inlist(`"`decnames'"',"*","_all")) {
		quietly : numlist `"1/${DERIVESCORES_dec_count}"'
		local decnums `r(numlist)'
	}
	// determine initialization number for given declaration(s)
	else {
		local decnums
		foreach entry of local decnames {
			local match 0
			forvalues num=1/${DERIVESCORES_dec_count} {
				if (`"${DERIVESCORES_dec`num'_shortname}"'==`"`entry'"') {
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
		noisily : display as result in smcl `"{text} information about derivescores table declaration {result}[`decnum'] ${DERIVESCORES_dec`decnum'_shortname}:"'
		// get maximum length of declaration keys for creating table structure
		local keys : all globals `"DERIVESCORES_dec`decnum'_*"'
		local keys : list sort keys
		if (`"`: list posof "`decnum'" in decnums'"'=="1") {
			foreach key of local keys {
				// display information per table declaration
				local keyname : subinstr local key `"DERIVESCORES_dec`decnum'_"' "" , all
				if (udstrlen(`"`keyname'"')+`tableoffset'+`tablespace'>`maxnamelength') local maxnamelength=udstrlen(`"`keyname'"')+`tableoffset'+`tablespace'
			}
		}
		// change sorting of keys for display (according do `keypriority')
		local displaykeys
		foreach priokey of local keypriority {
			local addkey `"DERIVESCORES_dec`decnum'_`priokey'"'
			if (!missing(`"${DERIVESCORES_dec`decnum'_`priokey'}"')) local displaykeys : list displaykeys | addkey
		}
		local displaykeys : list displaykeys | keys
		// build table displaying information
		noisily : display as result in smcl _newline `"{p2colset `tableoffset' `maxnamelength' `=`maxnamelength'+`tablespace'' 0}{text}{p2col:`col1header'}`col2header'{p_end}"' _newline `"{p2line}"'
		// display declaration's information per key
		foreach key of local displaykeys {
			// display information per table declaration
			local keyname : subinstr local key `"DERIVESCORES_dec`decnum'_"' "" , all
			noisily : display as result in smcl `"{p2col:{text}`keyname'}{result}"',cond(strmatch(`"`keyname'"',"*link"),`"{browse `"${`key'}"':`=cond(udstrlen(`"${`key'}"')<=100,`"${`key'}"',udsubstr(`"${`key'}"',1,100)+"[...]")'}"',cond(`"`keyname'"'==`"file"',`"{stata `"use `"${`key'}"'"':${`key'}}"',`"${`key'}"')),`"{p_end}"'
		}
		noisily : display as result in smcl "{p2colreset}" _newline
	}
	// quit
	exit 0
end
// EOF
