capture log using PS2-b2, replace

********************************************************************************
* Problem B.2.(b)i.
********************************************************************************


/* Step #1 */
/* Generate the original published table using Table1_summarystats_May30_2010.do file */


	*Tyler Williams
	*5/30/2010
	*This file uses datasets created by OK_gradesupdater_Feb5_2010.do
	*It outputs summary statistics by treatment status, gender, and year

	*Set stata options
	clear
	set more off
	set mem 200m
	cd "C:\Users\wonja\Documents\GitHub\14.320"

	/* LOAD THE INDIVIDUAL LEVEL GRADE AND ADMINISTRATIVE DATA */

	use OKgradesUpdate_Feb5_2010, clear

	/* CREATE A FEW VARIABLES */

	gen C = 1-T
	gen s_second_year = 1-s_first_year
	gen s_female = 1-s_male

	/* CHANGE COLLEGE GRAD/HIGH SCHOOL GRAD VARIABLES TO INCLUDE THOSE WITH HIGHER DEGREES */

	replace s_motherhsdegree = 1 if s_mothercolldegree==1 | s_mothergraddegree==1
	replace s_fatherhsdegree = 1 if s_fathercolldegree==1 | s_fathergraddegree==1
	replace s_mothercolldegree = 1 if s_mothergraddegree==1
	replace s_fathercolldegree = 1 if s_fathergraddegree==1

	/* GENERATE CONTROLS HYPOTHETICAL EARNINGS VARIABLES */

	gen controlswhoearned = gradeover702008 if T==0
	gen controlsearnings = earnings2008 if T==0

	/* SET THE STRATA CONTROLS LIST */

	local stratacontrols ""
	tab s_group_quart, gen(s_group_quart)
	forvalues i=2(1)16 {
		local stratacontrols "`stratacontrols' s_group_quart`i'"
	}

	/* DESCRIPTIVE STATISTICS ON DEMOGRAPHIC VARIABLES BY STRATIFICATION GROUP AND TREATMENT */

	*Make variable name labels
	local var1 "Age"
	local var2 "High school grade average"
	local var3 "1st language is English"
	local var4 "Mother finished college"
	local var5 "Father finished college"
	local var6 "Answered earnings test question correctly"
	local var7 "Controls who would have been paid"
	local var8 "Mean hypothetical earnings for controls"

	*Erase the old table
	capture erase nbertable1_original.csv
	estimates clear

	*TREATMENT DIFFERENCES CONTROLLING FOR STRATA
	*Loop over variables to be summarized
	local i = 1
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct {

		*Loop over subgroups: . is everyone
		foreach strata in F_1 F_0 M_1 M_0 . {
			qui eststo: reg `sumvar' T `stratacontrols' if regexm(s_group,"`strata'"), r
		}

		*Output all effects in a table
		qui esttab using nbertable1_original.csv, cells(b(fmt(3)) se(fmt(3) star)) append nonumber keep(T) noobs ///
		varlabels(T "`var`i''") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach
		
		qui estimates clear
		local ++i
	}

	*TREATMENT SAMPLE SIZES
	*Loop over subgroups: . is everyone
	foreach strata in F_1 F_0 M_1 M_0 . {

		qui eststo: reg s_age T `stratacontrols' if regexm(s_group,"`strata'"), r
		qui sum s_age if regexm(s_group,"`strata'") & T==1
		qui estadd scalar obs = r(N)
	}

	*Output all effects in a table
	qui esttab using nbertable1_original.csv, cells(none) append nonumber ///
	stats(obs, fmt(0) label("Observations")) mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01)

	qui estimates clear

	*CONTROL MEANS
	*Loop over variables to be summarized
	local i = 1
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct ///
	controlswhoearned controlsearnings {

		*Loop over subgroups: . is everyone
		foreach strata in F_1 F_0 M_1 M_0 . {
			
			qui eststo: reg `sumvar' if regexm(s_group,"`strata'") & T==0, r
			qui sum `sumvar' if regexm(s_group,"`strata'") & T==0
			qui estadd r(mean)
			qui estadd r(sd)
		}

		*Output all effects in a table
		qui esttab using nbertable1_original.csv, cells(none) append nonumber ///
		stats(mean sd, fmt(3 3) labels("`var`i''" " ")) mlabels(none) collabels(none)
		
		qui estimates clear
		local ++i
	}

	*CONTROL SAMPLE SIZES
	*Loop over subgroups: . is everyone
	foreach strata in F_1 F_0 M_1 M_0 . {

		qui eststo: reg s_age T `stratacontrols' if regexm(s_group,"`strata'"), r
		qui sum s_age if regexm(s_group,"`strata'") & T==0
		qui estadd scalar obs = r(N)
	}

	*Output all effects in a table
	qui esttab using nbertable1_original.csv, cells(none) append nonumber ///
	stats(obs, fmt(0) label("Observations")) mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01)

	qui estimates clear

	*F TESTS OF JOINT SIGNIFICANCE (estimate each regression, save results, use "suest" to combine, then test)
	*Loop over variables to be summarized
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct {

		*Loop over subgroups: . is everyone
		local stratanum = 1
		foreach strata in F_1 F_0 M_1 M_0 . {
			qui eststo `sumvar'`stratanum': reg `sumvar' T `stratacontrols' if regexm(s_group,"`strata'")
			local ++stratanum
		}
	}

	*Loop over subgroups
	forvalues stratanum=1(1)5 {

		qui eststo model`stratanum': suest s_age`stratanum' s_hsgrade3`stratanum' s_mtongue_english`stratanum' s_mothercolldegree`stratanum' ///
		s_fathercolldegree`stratanum' s_test2correct`stratanum'
		qui test [s_age`stratanum'_mean]T [s_hsgrade3`stratanum'_mean]T [s_mtongue_english`stratanum'_mean]T ///
		[s_mothercolldegree`stratanum'_mean]T [s_fathercolldegree`stratanum'_mean]T [s_test2correct`stratanum'_mean]T
		qui local F = r(chi2)/r(df)
		qui estadd scalar F = `F'
		qui estadd r(p)
	}

	*Output all effects in a table
	qui esttab model1 model2 model3 model4 model5 using nbertable1_original.csv, cells(none) append nonumber ///
	stats(F p, fmt(3 3) labels("F test for joint significance" " ")) mlabels(none) collabels(none)

	
/* Step #2 */
/* Generate the replicated columns 9-10 with strata controls and save them in nbertable1_new.csv file */
/* I deleted foreach loops that repeated running regressions for every strata and modified the code to run regression only for all strata. */

	
	capture erase nbertable1_new.csv
	estimates clear

	*TREATMENT DIFFERENCES CONTROLLING FOR STRATA
	*Loop over variables to be summarized
	local i = 1
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct {

		*Loop over subgroups: . is everyone
		qui eststo: reg `sumvar' T `stratacontrols', r

		*Output all effects in a table
		qui esttab using nbertable1_new.csv, cells(b(fmt(3)) se(fmt(3) star)) append nonumber keep(T) noobs ///
		varlabels(T "`var`i''") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach
		
		qui estimates clear
		local ++i
	}

	*TREATMENT SAMPLE SIZES
	qui eststo: reg s_age T `stratacontrols', r
	qui sum s_age if T==1
	qui estadd scalar obs = r(N)

	*Output all effects in a table
	qui esttab using nbertable1_new.csv, cells(none) append nonumber ///
	stats(obs, fmt(0) label("Observations")) mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01)

	qui estimates clear

	*CONTROL MEANS
	*Loop over variables to be summarized
	local i = 1
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct ///
	controlswhoearned controlsearnings {

		qui eststo: reg `sumvar' if T==0, r
		qui sum `sumvar' if T==0
		qui estadd r(mean)
		qui estadd r(sd)

		*Output all effects in a table
		qui esttab using nbertable1_new.csv, cells(none) append nonumber ///
		stats(mean sd, fmt(3 3) labels("`var`i''" " ")) mlabels(none) collabels(none)
		
		qui estimates clear
		local ++i
	}

	*CONTROL SAMPLE SIZES
	qui eststo: reg s_age T `stratacontrols', r
	qui sum s_age if T==0
	qui estadd scalar obs = r(N)

	*Output all effects in a table
	qui esttab using nbertable1_new.csv, cells(none) append nonumber ///
	stats(obs, fmt(0) label("Observations")) mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01)

	qui estimates clear

	*F TESTS OF JOINT SIGNIFICANCE (estimate each regression, save results, use "suest" to combine, then test)
	*Loop over variables to be summarized
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct {

		local stratanum = 5
		qui eststo `sumvar'`stratanum': reg `sumvar' T `stratacontrols'	
	}

	qui eststo model`stratanum': suest s_age`stratanum' s_hsgrade3`stratanum' s_mtongue_english`stratanum' s_mothercolldegree`stratanum' ///
	s_fathercolldegree`stratanum' s_test2correct`stratanum'
	qui test [s_age`stratanum'_mean]T [s_hsgrade3`stratanum'_mean]T [s_mtongue_english`stratanum'_mean]T ///
	[s_mothercolldegree`stratanum'_mean]T [s_fathercolldegree`stratanum'_mean]T [s_test2correct`stratanum'_mean]T
	qui local F = r(chi2)/r(df)
	qui estadd scalar F = `F'
	qui estadd r(p)

	*Output all effects in a table
	qui esttab model5 using nbertable1_new.csv, cells(none) append nonumber ///
	stats(F p, fmt(3 3) labels("F test for joint significance" " ")) mlabels(none) collabels(none)
	

/* Step #3 */	
/* Generate the replicated columns 9-10 without strata controls*/	
/* I only kept the code to generate the treatment differences column and removed strata controls from regression. */


	capture erase nbertable1_new_no_strata.csv
	estimates clear

	*TREATMENT DIFFERENCES CONTROLLING FOR STRATA
	*Loop over variables to be summarized
	local i = 1
	foreach sumvar in s_age s_hsgrade3 s_mtongue_english s_mothercolldegree s_fathercolldegree s_test2correct {

		qui eststo: reg `sumvar' T , r

		*Output all effects in a table
		qui esttab using nbertable1_new_no_strata.csv, cells(b(fmt(3)) se(fmt(3) star)) append nonumber keep(T) noobs ///
		varlabels(T "`var`i''") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach
		
		qui estimates clear
		local ++i
	}

********************************************************************************
* Problem B.2.(b)ii.
********************************************************************************

/* Step #1 */
/* Generate the original published table using Table4a_grades_May30_2010.do file */

	*Tyler Williams
	*5/30/2010
	*This file uses datasets created by OK_gradesupdater_Feb5_2010.do
	*It runs OLS regressions to estimate treatment effects on academic outcomes controlling for strata (gender, year, hs grade 
	*quartile) and covariates

	/* LOAD THE INDIVIDUAL LEVEL DATA */

	use OKgradesUpdate_Feb5_2010, clear

	/* SET THE STRATA CONTROLS LIST */

	local stratacontrols ""
	tab s_group_quart, gen(s_group_quart)
	forvalues i=2(1)16 {
		local stratacontrols "`stratacontrols' s_group_quart`i'"
	}

	/* ADD IN ALL OTHER CONTROLS TO GET FULL CONTROLS LIST */

	local fullcontrols "s_hsgrade3 s_mtongue_english s_test1correct s_test2correct s_motherhsdegree s_mothercolldegree s_mothergraddegree s_mothereducmiss s_fatherhsdegree s_fathercolldegree s_fathergraddegree s_fathereducmiss `stratacontrols'" 

	/* TABLE 4a: CONTROL MEANS AND ACADEMIC OUTCOME REGRESSIONS FOR FULL YEAR, SPRING, AND FALL VARS WITH ALL CONTROLS */

	*Loop over academic variables
	local tabnum "4a"
	foreach depvar in earnings avggrade {

	*Erase old tables
	capture erase nbertable`tabnum'.csv
	estimates clear

	*RESULTS

	*Loop over fall, spring, full year
	foreach length in fall spring "" {

		*CONTROL MEANS
		*Loop over subgroups: ^F is all women, ^M is all men, 1$ is all 1st years, 0$ is all 2nd years, . is everyone
		foreach strata in F_1 F_0 ^F M_1 M_0 ^M 1$ 0$ . {

			qui eststo: reg `depvar'`length'2008 if regexm(s_group,"`strata'"), r
			qui sum `depvar'`length'2008 if regexm(s_group,"`strata'") & T==0
			qui estadd r(mean)
			qui estadd r(sd)
		}

		*Output all effects in a table
		qui esttab using nbertable`tabnum'.csv, cells(none) append nonumber ///
		stats(mean sd, fmt(%9.3f %9.3f) labels("Control Mean" "SD")) mlabels(none) collabels(none)
		
		qui estimates clear

		*TREATMENT EFFECTS
		*Loop over subgroups: ^F is all women, ^M is all men, 1$ is all 1st years, 0$ is all 2nd years, . is everyone
		local labnum = 1
		foreach strata in F_1 F_0 ^F M_1 M_0 ^M 1$ 0$ . {

			foreach controlset in "`fullcontrols'" {
				qui eststo: reg `depvar'`length'2008 T `controlset' if regexm(s_group,"`strata'"), r
			}
		}

		*Output all effects in a table
		qui esttab using nbertable`tabnum'.csv, cells(b(fmt(%9.3f)) se(fmt(%9.3f) star)) append nonumber keep(T) ///
		varlabels(T "Treatment Effect") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach stats(N, fmt(0))
		
		qui estimates clear
	}

	*Close loop over academic variables
	}

	
/* Step #2 */
/* Generate the replicated columns 7-9 and save them in nbertable4a_new.csv file */
/* I limited the dependent variable to avggrade only, restricted foreach loops that repeated running regressions for all sex-year combinations so that the code ran regression only by year for all men and women. */

	*Erase old tables
	capture erase nbertable`tabnum'_new.csv
	estimates clear

	*RESULTS

	*Loop over fall, spring, full year
	foreach length in fall spring "" {

		*CONTROL MEANS
		*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
		foreach strata in 1$ 0$ . {

			qui eststo: reg avggrade`length'2008 if regexm(s_group,"`strata'"), r
			qui sum avggrade`length'2008 if regexm(s_group,"`strata'") & T==0
			qui estadd r(mean)
			qui estadd r(sd)
		}

		*Output all effects in a table
		qui esttab using nbertable`tabnum'_new.csv, cells(none) append nonumber ///
		stats(mean sd, fmt(%9.3f %9.3f) labels("Control Mean" "SD")) mlabels(none) collabels(none)
		
		qui estimates clear

		*TREATMENT EFFECTS
		*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
		foreach strata in 1$ 0$ . {

			foreach controlset in "`fullcontrols'" {
				qui eststo: reg avggrade`length'2008 T `controlset' if regexm(s_group,"`strata'"), r
			}
		}

		*Output all effects in a table
		qui esttab using nbertable`tabnum'_new.csv, cells(b(fmt(%9.3f)) se(fmt(%9.3f) star)) append nonumber keep(T) ///
		varlabels(T "Treatment Effect") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach stats(N, fmt(0))
		
		qui estimates clear
	}


********************************************************************************
* Problem B.2.(b)iii.
********************************************************************************

/* Generate treatment effect in the columns 7-9 without controls and save them in nbertable4a_new_no_control.csv file */
/* I removed the foreach loop that repeated through the list of fullcontrols and deleted control variables from the regression formula. */

*Loop over academic variables
*Erase old tables
capture erase nbertable`tabnum'_new_no_control.csv
estimates clear

*RESULTS

*Loop over fall, spring, full year
foreach length in fall spring "" {

	*TREATMENT EFFECTS
	*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
	foreach strata in 1$ 0$ . {

		qui eststo: reg avggrade`length'2008 T if regexm(s_group,"`strata'"), r
	}

	*Output all effects in a table
	qui esttab using nbertable`tabnum'_new_no_control.csv, cells(b(fmt(%9.3f)) se(fmt(%9.3f) star)) append nonumber keep(T) ///
	varlabels(T "Treatment Effect") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach stats(N, fmt(0))
	
	qui estimates clear
}

********************************************************************************
* Problem B.2.(c)
********************************************************************************

/* Claim #1  */
/* I created and used 'partialcontrols' instead of 'fullcontrols' as the list of control variablea. 'partialcontrols' dropoed strata controls from 'fullcontrols'. */
/* I added a forvalues loop to run regression once for those with financial concerns and again for those without financial concerns. */

	*Erase old tables
	capture erase nbertable`tabnum'_claim1.csv
	estimates clear

	*RESULTS
	
	local partialcontrols "s_hsgrade3 s_mtongue_english s_test1correct s_test2correct s_motherhsdegree s_mothercolldegree s_mothergraddegree s_mothereducmiss s_fatherhsdegree s_fathercolldegree s_fathergraddegree s_fathereducmiss"
	
	forvalues claim1 = 0/1 {
	
		*Loop over fall, spring, full year
		foreach length in fall spring "" {

			*CONTROL MEANS
			*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
			foreach strata in 1$ 0$ . {
				qui eststo: reg avggrade`length'2008 if regexm(s_group,"`strata'") & s_highfundsconcern == `claim1', r
				qui sum avggrade`length'2008 if regexm(s_group,"`strata'") & s_highfundsconcern == `claim1' & T==0
				qui estadd r(mean)
				qui estadd r(sd)
			}

			*Output all effects in a table
			qui esttab using nbertable`tabnum'_claim1.csv, cells(none) append nonumber ///
			stats(mean sd, fmt(%9.3f %9.3f) labels("Control Mean" "SD")) mlabels(none) collabels(none)
			
			qui estimates clear

			*TREATMENT EFFECTS
			*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
			foreach strata in 1$ 0$ . {
				foreach controlset in "`partialcontrols'" {
				qui eststo: reg avggrade`length'2008 T `controlset' if regexm(s_group,"`strata'") & s_highfundsconcern == `claim1', r
				}
			}

			*Output all effects in a table
			qui esttab using nbertable`tabnum'_claim1.csv, cells(b(fmt(%9.3f)) se(fmt(%9.3f) star)) append nonumber keep(T) ///
			varlabels(T "Treatment Effect") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach stats(N, fmt(0))
			
			qui estimates clear
		}
	}

	
/* Claim #2  */
/* I added a forvalues loop to run regression once for those with financial concerns and again for those without financial concerns. */

	*Erase old tables
	capture erase nbertable`tabnum'_claim2.csv
	estimates clear

	*RESULTS
	
	gen s_parentscolldegree = 0
	replace s_parentscolldegree = 1 if s_fathercolldegree == 1 | s_mothercolldegree == 1
	replace s_parentscolldegree = 2 if s_fathercolldegree == 1 & s_mothercolldegree == 1
	
	forvalues claim2 = 0/2 {
	
		*Loop over fall, spring, full year
		foreach length in fall spring "" {

			*CONTROL MEANS
			*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
			foreach strata in 1$ 0$ . {
				qui eststo: reg avggrade`length'2008 if regexm(s_group,"`strata'") & s_parentscolldegree == `claim2', r
				qui sum avggrade`length'2008 if regexm(s_group,"`strata'") & s_parentscolldegree == `claim2' & T==0
				qui estadd r(mean)
				qui estadd r(sd)
			}

			*Output all effects in a table
			qui esttab using nbertable`tabnum'_claim2.csv, cells(none) append nonumber ///
			stats(mean sd, fmt(%9.3f %9.3f) labels("Control Mean" "SD")) mlabels(none) collabels(none)
			
			qui estimates clear

			*TREATMENT EFFECTS
			*Loop over subgroups: 1$ is all 1st years, 0$ is all 2nd years, . is everyone
			foreach strata in 1$ 0$ . {
				foreach controlset in "`partialcontrols'" {
				qui eststo: reg avggrade`length'2008 T `controlset' if regexm(s_group,"`strata'") & s_parentscolldegree == `claim2', r
				}
			}

			*Output all effects in a table
			qui esttab using nbertable`tabnum'_claim2.csv, cells(b(fmt(%9.3f)) se(fmt(%9.3f) star)) append nonumber keep(T) ///
			varlabels(T "Treatment Effect") mlabels(none) collabels(none) starlevels(* .1 ** .05 *** .01) stardetach stats(N, fmt(0))
			
			qui estimates clear
		}
	}
	

log close