cd "C:\Users\wonja\Documents\GitHub\DEDP\14.320\PS5"
capture log using PS5-22, replace
clear
set more off

* PS5-II.2.a

use fish

gen n = _n
reshape long price_ qty_, i(n) j(race) string

gen ln_price = log(price)
gen asian = race == "a"
gen t = n
replace t = n + 100 if asian == 1

eststo: reg ln_price asian day* wave* if t != 1 & t != 101
tsset t
eststo: prais ln_price asian day* wave2 wave3, corc twostep
esttab using PS5-22a.tex, replace ///
	nonumbers mtitles("OLS" "CORC")
eststo clear

* PS5-II.2.b

predict e, residual
gen l_e = e[_n-1]
reg e l_e if t != 1 & t != 101

foreach var in ln_price asian day1 day2 day3 day4 wave2 wave3 {
	gen l_`var' = `var' - `var'[_n-1]*_b[l_e]
}

eststo: reg l_ln_price l_asian l_day* l_wave* if t != 1 & t != 101
eststo: prais ln_price asian day* wave2 wave3, corc twostep
esttab using PS5-22b.csv, replace ///
	nonumbers mtitles("Manual" "CORC")
eststo clear

log close 