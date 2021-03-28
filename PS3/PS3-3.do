cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"

capture log using PS3-3, replace

clear
set more off
cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"
use NHIS2009_clean

* Problem 3.(a)

* select non-missings
	keep if marradult==1 & perweight!=0 
		by serial: egen hi_hsb = mean(hi_hsb1)
			keep if hi_hsb!=. & hi!=.
		by serial: egen female = total(fml)
			keep if female==1
			drop female
	
* Josh's sample selection criteria	
	gen angrist = ( age>=26 & age<=59 & marradult==1 & adltempl>=1 )
		keep if angrist==1
	// drop single-person HHs
	by serial: gen n = _N
		keep if n>1

eststo: reg health uninsured if sex == 1
esttab using PS3-3a.tex, replace compress cells("b(label(coef) fmt(a3) star) ci(par fmt(a3))" t(par fmt(a3))) label varlabels(uninsured "Covered by insurance" _cons "Constant") nonumber stats(N, fmt(%9.0gc) label(Observations)) addnote("t statistics in parentheses" "@starlegend")
eststo clear

* Problem 3.(b)

eststo: reg health uninsured age if sex == 1
eststo: reg health uninsured age yedu if sex == 1
eststo: reg health uninsured age yedu inc if sex == 1
esttab using PS3-3b.tex, replace compress cells(b(label(coef) fmt(a3) star) t(par fmt(a3))) label varlabels(uninsured "Covered by insurance" yedu "Years of education" inc "Income" _cons "Constant") nonumber stats(N, fmt(%9.0gc) label(Observations)) addnote("t statistics in parentheses" "@starlegend")
eststo clear

log close