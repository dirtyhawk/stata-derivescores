/*-------------------------------------------------------------------------------
  derivescores_setup.ado: helper script for -derivescores- to initialize derivation tables
  
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
*! derivescores_setup.ado: helper script for -derivescores- to initialize derivation tables
/*
	This procedure reads all tables delivered with -derivescores- into Stata,
	and saves them in the user's temporary directory;
	their relevant paths and other metadata are saved in global macros;
	this procedure is supposed to be executed before any other -derivescores-
	subcommand is called, and will automatically be executed if the called
	procedure detects that -derivescores setup- has not been run in the Stata
	session before
*/
// TODO: mark crosswalks containig invalid declarations as invalid
program define derivescores_setup , nclass
	// syntax declaration and macros
	syntax [, verbose ]
	local declarationfile `"conceptschemes_correspondences.csv"'
	local temppath `"`c(tmpdir)'/DERIVESCORES_tmp"'
	tempvar selector random max_prob sortorder
	// check if derivescores_setup has been run previously, abort if so (unless option -force- is set
	if (!missing(`"${DERIVESCORES_initialized}"')) {
		noisily : display as error in smcl `"{it:derivescores} already has been set up;"' _newline `"{tab}continue with {stata derivescores list}/{stata derivescores info}, or clean up with {stata derivescores wipe}"'
		exit 0
	}
	// find main CSV file with table declarations
	capture : findfile `"`declarationfile'"'
	if (_rc!=0) {
		noisily: display as error in smcl `"could not find table declaration file;"' _newline `"{tab}maybe your package installation is broken?"'
		exit 601
	}
	else local declarationfile `"`r(fn)'"'
	// read main CSV file with table declarations; save all metadata as globals
	quietly : snapshot save
	local snapshotnum `r(snapshot)'
	if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"reading table declarations from file {result}{it:`declarationfile'}{text}"'
	quietly : import delimited `"`declarationfile'"' , clear varnames(1) case(preserve) encoding("utf-8") bindquotes(loose) stripquotes(default)
	local total `c(N)'
	local invalid 0
	forvalues num=1/`total' {
		local counter=`num'-`invalid'
		local searchfilename
		if (missing(`"`=Correspondence[`num']'"')) {
			global DERIVESCORES_dec`counter'_shortname=ConceptScheme[`num']
			local searchfilename=lower(ConceptScheme[`num'])+`".csv"'
			global DERIVESCORES_dec`counter'_type ConceptScheme
		}
		else {
			global DERIVESCORES_dec`counter'_shortname=ConceptScheme[`num']+`" → "'+Correspondence[`num']
			local searchfilename=lower(ConceptScheme[`num'])+`"--"'+lower(Correspondence[`num'])+`".csv"'
			global DERIVESCORES_dec`counter'_type Correspondence
		}
		global DERIVESCORES_dec`counter'_file=ustrregexrf(`"`searchfilename'"',`"\.csv$"',`".dta"',.)
		capture : findfile `"`searchfilename'"'
		if (_rc!=0) {
			noisily: display as error in smcl `"could not find table file for {result}{it:${DERIVESCORES_dec`counter'_type}}{error} {result}{it:${DERIVESCORES_dec`num'_shortname}}{error} ({result}{it:`searchfilename'}{error});"' _newline `"{tab}it will not be available, nor any crosswalks to or from it;"' _newline `"{tab}maybe your package installation is broken?"'
			global DERIVESCORES_dec`counter'_shortname
			global DERIVESCORES_dec`counter'_type
			local --total
			local ++invalid
		}
		global DERIVESCORES_dec`counter'_pkgfile `"`r(fn)'"'
		global DERIVESCORES_dec`counter'_label=prefLabel[`num']
		global DERIVESCORES_dec`counter'_note=coreContentNote[`num']
		global DERIVESCORES_dec`counter'_sourcelink=source_overview[`num']
		global DERIVESCORES_dec`counter'_deeplink=source_direct[`num']
		
	}
	global DERIVESCORES_dec_count `total'
	clear
	// open each table declaration file, check for consistency, save temporarily in the user's temp directory
	quietly : mkdir `"`temppath'"'
	forvalues counter=1/`total' {
		local auxvars
		global DERIVESCORES_dec`counter'_file `"`temppath'/${DERIVESCORES_dec`counter'_file}"'
		quietly : import delimited using `"${DERIVESCORES_dec`counter'_pkgfile}"' , clear varnames(1) case(preserve) encoding("utf-8") stringcols(1/4) bindquotes(loose) stripquotes(default)
		// determine defined labelStyles end default labelStyle in ConceptScheme declarations
		if ("${DERIVESCORES_dec`counter'_type}"'=="ConceptScheme") {
			if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"detecting {it:labelStyle}s in {result}{it:${DERIVESCORES_dec`counter'_shortname}}{text}, and saving labels to matrices"'
			quietly : levelsof labelStyle , local(styles) clean
			global DERIVESCORES_dec`counter'_labelStyles `"`styles'"'
			global DERIVESCORES_dec`counter'_defaultStyle=labelStyle[1]
			foreach style of local styles {
				if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"{tab}...saving {it:labelStyle} {result}{it:`style'}{text}"'
				quietly : generate `selector'=(labelStyle==`"`style'"')
				// save vectors for each labelStyle to create value labels from
				mata : DERIVESCORES_dec`counter'_vals_`style'=st_data(. , `"prefValue"', `"`selector'"')
				mata : DERIVESCORES_dec`counter'_lbls_`style'=st_sdata(. , `"prefLabel"', `"`selector'"')
				drop `selector'
			}
		}
		// detect and save number of auxiliary variables in Correspondence declarations
		if ("${DERIVESCORES_dec`counter'_type}"'=="Correspondence") {
			if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"detecting auxiliary varriables in {result}{it:${DERIVESCORES_dec`counter'_shortname}}{text}"'
			capture : unab auxvars : aux*
			if (_rc==0) global DERIVESCORES_dec`counter'_auxvars `"`auxvars'"'
		}
		// tag entry with highest probability per classification code for merging in Correspondence declarations
		if ("${DERIVESCORES_dec`counter'_type}"'=="Correspondence") {
			if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"tagging target values with highest propability score in {result}{it:${DERIVESCORES_dec`counter'_shortname}}{text}"'
			quietly {
				generate `sortorder'=_n
				generate `random'=runiform()
				bysort sourceConcept `auxvars' : egen `max_prob'=max(prob)
				generate probmarker=(prob==`max_prob')
				gsort +sourceConcept `auxvars' -probmarker +`random'
				by sourceConcept `auxvars' : replace probmarker=5 if (probmarker==1 & _n==1)
				replace probmarker=prob+`random' if (probmarker!=5)
				sort `sortorder'
				drop `max_prob' `random' `sortorder'
			}
		}
		quietly : save `"${DERIVESCORES_dec`counter'_file}"'
		if (`"`verbose'"'=="verbose") noisily : display as text in smcl `"saved classification table for declaration {result}{it:${DERIVESCORES_dec`counter'_shortname}}{text} to {result}{it:${DERIVESCORES_dec`counter'_file}}{text}"'
	}
	snapshot restore `snapshotnum'
	snapshot erase `snapshotnum'
	// save global marking everything as initialized
	global DERIVESCORES_initialized 1
	// success message
	noisily : display as result in smcl `"{text}successfully read {result}{it:${DERIVESCORES_dec_count}}{text} table declarations"'
	// quit
	exit 0
end
// EOF
