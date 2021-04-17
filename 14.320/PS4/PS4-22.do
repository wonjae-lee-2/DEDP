* Preparation

cd "C:\Users\wonja\Documents\GitHub\DEDP\14.320\PS4"
clear
set more off

capture log using PS4-22, replace

* Answer II.2.(a)

import delimited "ps4_data.csv"
gen potex0 = age - years_ed - 6
gen potex1 = potex0
replace potex1 = 0 if potex1 < 0
gen potex2 = potex1^2
gen female = 0
replace female = 1 if sex == 2
gen femed = female*years_ed

reg ln_ahe female potex1 potex2 years_ed femed, r
esttab using PS4-22a.tex, replace compress ///
	varlabels(female Female potex1 "Potential Experience" potex2 "$\text{Potential Experience}^2$" years_ed "Years of Education" femed "$\text{Female}\times \text{Education}$" _cons Constant) ///
	nonumbers ///
	mtitles ("Log Hourly Wages") ///
	stats(N, fmt(%9.0gc))

* Answer II.2.(b)	

gen femex1 = female*potex1  
gen femex2 = female*potex2  
eststo: reg ln_ahe female years_ed potex1 potex2, r
eststo: reg ln_ahe female years_ed potex1 femex1 potex2 femex2, r
estimates store model1
esttab using PS4-22b-1.tex, replace compress ///
	varlabels(female Female potex1 "Potential Experience" potex2 "$\text{Potential Experience}^2$" years_ed "Years of Education" femex1 "$\text{Female}\times \text{Experience}$" femex2 "$\text{Female}\times \text{Experience}^2$" _cons Constant) ///
	mtitles ("Log Hourly Wages" "Log Hourly Wages") ///
	stats(N, fmt(%9.0gc))
eststo clear

program drop _all
program teststo, eclass
	qui `*'
	ereturn clear
	matrix m_p = r(p)
	matrix m_f = r(F)
	matrix m_df = r(df)
	matrix m_df_r = r(df_r)
	ereturn matrix p = m_p
	ereturn matrix f = m_f
	ereturn matrix df = m_df
	ereturn matrix df_r = m_df_r
	ereturn local cmd "teststo"
end

estimates restore model1
test femex1 femex2
teststo test femex1 femex2
esttab using PS4-22b-2.tex, replace compress ///
	cells("f(fmt(3)) p(fmt(3))") ///
	varlabels(c1 "Restrictions") ///
	nonumbers ///
	nomtitles ///
	collabels(F "$\text{Prob}>\text{F}$") ///
	noobs ///
	addnotes("$\text{(1) Female}\times\text{Experience} = 0$" "$\text{(2) Female}\times\text{Experience}^2 = 0$")

* Answer II.2.(c)

forvalues i = 1/5 {
	gen race_`i' = 0
	replace race_`i' = 1 if race == `i'
	gen race_`i'_ed = race_`i'*years_ed
	label variable race_`i' "Race `i'"
	label variable race_`i'_ed "$\text{Education}\times \text{Race `i'}$"
}

reg ln_ahe potex1 potex2 years_ed female femed race_1 race_1_ed race_2 race_2_ed race_3 race_3_ed race_4 race_4_ed, r
esttab using PS4-22c-1.tex, replace compress label ///
	varlabels(female Female potex1 "Potential Experience" potex2 "$\text{Potential Experience}^2$" years_ed "Years of Education" femex1 "$\text{Female}\times \text{Experience}$" femex2 "$\text{Female}\times \text{Experience}^2$" femed "$\text{Education}\times \text{Female}$" _cons Constant) ///
	nonumbers ///
	mtitles ("Log Hourly Wages") ///
	stats(N, fmt(%9.0gc))

test race_1_ed race_2_ed race_3_ed race_4_ed
teststo test race_1_ed race_2_ed race_3_ed race_4_ed
esttab using PS4-22c-2.tex, replace compress ///
	cells("f(fmt(3)) p(fmt(3))") ///
	varlabels(c1 "Restrictions") ///
	nonumbers ///
	nomtitles ///
	collabels(F "$\text{Prob}>\text{F}$") ///
	noobs ///
	addnotes("$\text{(1) Education}\times\text{Race 1} = 0$" "$\text{(2) Education}\times\text{Race 2} = 0$" "$\text{(3) Education}\times\text{Race 3} = 0$" "$\text{(4) Education}\times\text{Race 4} = 0$")

* Answer II.2.(d)

reg ln_ahe female years_ed femed potex1 femex1 potex2 femex2, r
teststo test femed femex1 femex2
esttab using PS4-22d.tex, replace compress ///
	cells("f(fmt(3)) p(fmt(3))") ///
	varlabels(c1 "Restrictions") ///
	nonumbers ///
	nomtitles ///
	collabels(F "$\text{Prob}>\text{F}$") ///
	noobs ///
	addnotes("$\text{(1) Female}\times\text{Education} = 0$" "$\text{(2) Female}\times\text{Potential Experience} = 0$" "$\text{(3) Female}\times\text{Potential Experience}^2 = 0$")
estimates clear

log close