cd "C:\Users\wonja\Documents\GitHub\DEDP\14.320\PS5"
capture log using PS5-21, replace
clear
set more off

* PS5-II.1.a

use k93
keep if 16 <= age & age <= 65
keep if working == 1

gen educ_cat = 0
replace educ_cat = 1 if educ == 12
replace educ_cat = 2 if 12 < educ
replace educ_cat = 3 if educ == 16
replace educ_cat = 4 if 16 < educ

gen age_cat = .
replace age_cat = 0 if 18 <= age
replace age_cat = 1 if 25 <= age
replace age_cat = 2 if 40 <= age
replace age_cat = 3 if 55 <= age

gen union_cat = 0
replace union_cat = 1 if union == 0

gen parttime_cat = 0
replace parttime_cat = 1 if parttime == 0

gen use_comp_pct = use_comp*100

eststo: mean use_comp_pct if year == 1984
eststo: mean use_comp_pct if year == 1989
esttab using PS5-21a.csv, replace ///
	nolines nonum ///
	mtitles("1984" "1989") ///
	varlabels(use_comp_pct "All workers") ///
	b(a1) nostar not noobs
eststo clear

foreach var in female educ_cat black age_cat union_cat parttime_cat region {
	eststo: mean use_comp_pct if year == 1984, over(`var')
	eststo: mean use_comp_pct if year == 1989, over(`var')
	esttab using PS5-21a.csv, append ///
		nolines nonum nomtitles ///
		varlabels(c.use_comp_pct@0.female "Men" c.use_comp_pct@1.female "Women" c.use_comp_pct@0.educ_cat "Less than high school" c.use_comp_pct@1.educ_cat "High school" c.use_comp_pct@2.educ_cat "Some college" c.use_comp_pct@3.educ_cat "College" c.use_comp_pct@4.educ_cat "Postcollege" c.use_comp_pct@0.black "White" c.use_comp_pct@1.black "Black" c.use_comp_pct@0.age_cat "Age 18-24" c.use_comp_pct@1.age_cat "Age 25-39" c.use_comp_pct@2.age_cat "Age 40-54" c.use_comp_pct@3.age_cat "Age 55-65" c.use_comp_pct@0.union_cat "Union member" c.use_comp_pct@1.union_cat "Nonunion" c.use_comp_pct@0.parttime_cat "Part-time" c.use_comp_pct@1.parttime_cat "Full-time" c.use_comp_pct@1.region "Northeast" c.use_comp_pct@2.region "Midwest" c.use_comp_pct@3.region "South" c.use_comp_pct@4.region "West") ///
		refcat(c.use_comp_pct@0.female "Gender" c.use_comp_pct@0.educ_cat "Education" c.use_comp_pct@0.black "Race" c.use_comp_pct@0.age_cat "Age" c.use_comp_pct@0.union_cat "Union status" c.use_comp_pct@0.parttime_cat "Hours" c.use_comp_pct@1.region "Region", nolabel) ///
		b(a1) nostar not noobs
	eststo clear
}

* PS5-II.1.b

drop if rhrwg < 1.5 | 250 < rhrwg
gen expsq_100 = expsq / 100

eststo: reg rlnhrwg use_comp if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union occup_* i.region if year == 1984
eststo: reg rlnhrwg use_comp if year == 1989
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union i.region if year == 1989
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union occup_* i.region if year == 1989
esttab using PS5-21b.csv, replace ///
	nomtitles ///
	drop(occup_* *.region) ///
	varlabels(use_comp "Uses computer at work (1 = yes)" educ "Years of education" exp "Experience" expsq_100 "Experience-squared / 100" black "Black (1 = yes)" other_race "Other race (1 = yes)" parttime "Part-time (1 = yes)" smsa "Lives in SMSA (1 = yes)" veteran "Veteran (1 = yes)" female "Female (1 = yes)" married "Married (1 = yes)" marr_fem "Married*Female" union "Union member (1 = yes)" _cons "Intercept") ///
	refcat(union "8 Occupation dummies", below nolabel) ///
	b(3) se(3) nostar ///
	r2 noobs nonotes
eststo clear

* PS5-II.1.c

eststo: reg rlnhrwg use_comp comp_* educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union occup_* if year == 1989
estadd summ, mean
esttab using PS5-21c.csv, replace ///
	keep(use_comp comp_*) ///
	nonumbers nomtitles ///
	collabels("Coefficient (std. error)" "Proportion") ///
	coeflabels(use_comp "Uses computer at work for any task" comp_wordproc "Word processing" comp_bookkeep "Bookkeeping" comp_cad "Computer-assisted design" comp_email "Electronic mail" comp_inventory "Inventory control" comp_program "Programming" comp_dtp "Desktop publishing or newsletters" comp_spreadsht "Spread sheets" comp_sales "Sales" comp_games "Computer games") ///
	refcat(comp_wordproc "Specific Task", nolabel) ///
	cells("b(fmt(3)) mean(fmt(3))" se(par fmt(3))) ///
	r2 noobs
eststo clear

* PS5-II.1.d

reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union occup_* if year == 1989
esttab using PS5-21d.tex, replace ///
	nomtitles ///
	drop(occup_*) ///
	varlabels(use_comp "Uses computer at work (1 = yes)" educ "Years of education" exp "Experience" expsq_100 "Experience-squared / 100" black "Black (1 = yes)" other_race "Other race (1 = yes)" parttime "Part-time (1 = yes)" smsa "Lives in SMSA (1 = yes)" veteran "Veteran (1 = yes)" female "Female (1 = yes)" married "Married (1 = yes)" marr_fem "Married*Female" union "Union member (1 = yes)" _cons "Intercept") ///
	refcat(union "8 Occupation dummies", below nolabel) ///
	b(3) se(3) nostar ///
	r2 noobs nonotes

local r2_short = e(r2)
reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union occup_* i.region if year == 1989
local r2_long = e(r2)
display "R2 version of the F-test : " ((e(N) - e(df_m) - 1)/3)*((`r2_long' - `r2_short')/(1 - `r2_long'))
test 1.region 2.region 3.region 4.region

* PS5-II.1.e

eststo: reg rlnhrwg use_comp if year == 1984
eststo: reg rlnhrwg use_comp if year == 1984, robust
eststo: reg rlnhrwg use_comp if year == 1989
eststo: reg rlnhrwg use_comp if year == 1989, robust
esttab using PS5-21e.tex, replace ///
	mtitles("Regular" "Robust" "Regular" "Robust") ///
	varlabels(use_comp "Uses computer at work (1 = yes)" _cons "Intercept") ///
	b(3) se(3) nostar ///
	r2 noobs nonotes
eststo clear

* PS5-II.1.f

gen use_comp_fem = use_comp*female
gen educ_fem = educ*female

eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_fem  i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union educ_fem i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_fem educ_fem i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_fem  i.region if year == 1989
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union educ_fem i.region if year == 1989
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_fem educ_fem i.region if year == 1989
esttab using PS5-21f-1.tex, replace ///
	nomtitles ///
	drop(*.region) ///
	varlabels(use_comp "Uses computer at work (1 = yes)" use_comp_fem "Computer-use*Female" educ "Years of education" educ_fem "Education*Female" exp "Experience" expsq_100 "Experience-squared / 100" black "Black (1 = yes)" other_race "Other race (1 = yes)" parttime "Part-time (1 = yes)" smsa "Lives in SMSA (1 = yes)" veteran "Veteran (1 = yes)" female "Female (1 = yes)" married "Married (1 = yes)" marr_fem "Married*Female" union "Union member (1 = yes)" _cons "Intercept") ///
	refcat(union "8 Occupation dummies", below nolabel) ///
	b(3) se(3) nostar ///
	r2 noobs nonotes
eststo clear

gen use_comp_educ = use_comp*educ
gen use_comp_educ_fem = use_comp*educ*female

eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_educ i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_educ educ_fem i.region if year == 1984
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_educ educ_fem use_comp_educ_fem i.region if year == 1984
lincom educ + use_comp_educ
lincom educ + educ_fem + use_comp_educ + use_comp_educ_fem
esttab using PS5-21f-2.tex, replace ///
	nomtitles ///
	drop(*.region) ///
	varlabels(use_comp "Uses computer at work (1 = yes)" use_comp_fem "Computer-use*Female" educ "Years of education" use_comp_educ "Computer_use*Education" educ_fem "Education*Female" exp "Experience" expsq_100 "Experience-squared / 100" black "Black (1 = yes)" other_race "Other race (1 = yes)" parttime "Part-time (1 = yes)" smsa "Lives in SMSA (1 = yes)" veteran "Veteran (1 = yes)" female "Female (1 = yes)" married "Married (1 = yes)" marr_fem "Married*Female" union "Union member (1 = yes)" use_comp_educ_fem "Computer*Education*Female" _cons "Intercept") ///
	b(3) se(3) nostar ///
	r2 noobs nonotes
eststo clear

* PS5-II.1.g

gen year_cat = 0
replace year_cat = 1 if year == 1989
gen educ_year = educ*year_cat
gen use_comp_year = use_comp*year_cat

eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union i.region
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_year i.region
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union educ_year i.region
eststo: reg rlnhrwg use_comp educ exp expsq_100 black other_race parttime smsa veteran female married marr_fem union use_comp_year educ_year i.region
test use_comp_year educ_year
esttab using PS5-21g-1.tex, replace ///
	nomtitles ///
	drop(*.region) ///
	varlabels(use_comp "Uses computer at work (1 = yes)" use_comp_fem "Computer-use*Female" educ "Years of education" use_comp_educ "Computer_use*Education" educ_fem "Education*Female" exp "Experience" expsq_100 "Experience-squared / 100" black "Black (1 = yes)" other_race "Other race (1 = yes)" parttime "Part-time (1 = yes)" smsa "Lives in SMSA (1 = yes)" veteran "Veteran (1 = yes)" female "Female (1 = yes)" married "Married (1 = yes)" marr_fem "Married*Female" union "Union member (1 = yes)" use_comp_educ_fem "Computer*Education*Female" use_comp_year "Computer-use*Year" educ_year "Education*Year" _cons "Intercept") ///
	b(3) se(3) nostar ///
	r2 noobs nonotes
eststo clear

log close