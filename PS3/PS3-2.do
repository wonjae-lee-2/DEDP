cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"

capture log using PS3-2, replace

clear
set more off
cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"
use STAR_public_use

* Problem 2.(a) i.

local all_treatments = "ssp sfp sfsp"
foreach treatment in `all_treatments' {
    ttest grade_20059_fall if control == 1 | `treatment' == 1, by(control)
	eststo: quietly estpost ttest grade_20059_fall if control == 1 | `treatment' == 1, by(control)
}
esttab using PS3-2ai.tex, replace compress cells("b(label(diff) fmt(a3) star) t(fmt(a3))" se(par fmt(a3))) label nonumber mtitles(`all_treatments') stats(N, fmt(%9.0gc) label(Observations)) addnote("standard errors in parentheses" "@starlegend")
eststo clear

* Problem 2.(a) i.

gen treat = 1 - control
foreach treatment in `all_treatments' {
    eststo: reg grade_20059_fall treat if treat == 0 | `treatment' == 1
}
esttab using PS3-2aii.tex, replace compress gaps cells("b(label(coef) fmt(a3) star) t(fmt(a3))" se(par fmt(a3))) label nonumber varlabels(treat "Fall grade" _cons "Constant") mtitles(`all_treatments') stats(N, fmt(%9.0gc) label(Observations)) addnote("standard errors in parentheses" "@starlegend")
eststo clear

* Problem 2.(b) i.

eststo: reg grade_20059_fall `all_treatments'
esttab using PS3-2bi.tex, replace compress label nonumber stats(N, fmt(%9.0gc) label(Observations))
eststo clear

* Problem 2.(c)

gen sfp_sfsp = 0
replace sfp_sfsp = 1 if sfp == 1 | sfsp == 1
eststo: reg grade_20059_fall ssp sfp_sfsp
esttab using PS3-2c.tex, replace compress label nonumber varlabels(sfp_sfsp "Offered sfp or sfsp" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

* Problem 2.(d)

eststo: reg grade_20059_fall ssp sfp_sfsp female gpa0 dad2 mom2
esttab using PS3-2d.tex, replace compress label nonumber varlabels(sfp_sfsp "Offered sfp or sfsp" female "Female" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

log close