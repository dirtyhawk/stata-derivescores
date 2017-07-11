*! derivescores_label.ado: labels one or more variables with classification labels
/*
	This procedure reads a classification declaration from derivescores' storage,
	and value-labels one or more given variables accordingly
*/
program define derivescores_label , nclass
	// syntax declaration and macros
	syntax varlist(numeric) , DEClaration(string) [, LABELname(name) Style(string) verbose replace ]
	// abort if -derivescores init- has not been run previously
	if (`"${DERIVESCORES_initialized}"'!="1") {
		noisily : display as error in smcl `"It does not seem that {it:derivescores} has been initialized; maybe you should run {stata derivescores init} first?"'
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
	if (missing(`"`labelname'"')) local labelname=ustrtoname(`"${DERIVESCORES_dec`decnum'_shortname}"',1)
	// check if target label name is already present, abort if yes (and option -replace- is not specified)
	if (`"`replace'"'!="replace") {
		capture : label list `labelname'
		if (_rc==0) {
			noisily : display as error in smcl `"value label {it:`label'} already exists in data"'
			exit 198
		}
	}
	// check if given `style' (if any) is valid
	if (missing(`"`style'"')) local style : copy global DERIVESCORES_dec`decnum'_defaultStyle
	else {
		if (`: list style in global(DERIVESCORES_dec`decnum'_labelStyles)'==0) {
			noisily : display as error in smcl `"style {it:`style'} is not an available {it:labelStyle} for declaration {it:${DERIVESCORES_dec`num'_shortname}}"'
		}
	}
	// write relevant information from Mata matrix to Stata value label
	mata: st_vlmodify(`"`labelname'"', DERIVESCORES_dec`decnum'_vals_`style', DERIVESCORES_dec`decnum'_lbls_`style')
	// label target variable(s)
	label values `varlist' `labelname'
	// quit
	exit 0
end
// EOF
