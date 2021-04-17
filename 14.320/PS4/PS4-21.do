* Preparation

cd "C:\Users\wonja\Documents\GitHub\DEDP\14.320\PS4"
clear
set more off

capture log using PS4-21, replace

* Answer II.1.(a)

import delimited "ps4_data.csv"
gen potex0 = age - years_ed - 6
sum potex0
gen potex1 = potex0
replace potex1 = 0 if potex1 < 0
sum potex1
qui estpost sum potex0 potex1
esttab using PS4-21a.tex, replace compress ///
	cells("count(fmt(%9.0gc)) mean(fmt(3)) sd(fmt(3)) min max") ///
	varlabels(potex0 "Potential Experience (Initial)" potex1 "Potential Experience (Cleaned)") ///
	collabels(Obs Mean "Std. Dev." Min Max) ///
	nomtitles ///
	nonumbers ///
	noobs

* Answer II.1.(b)

drop if sex == 2
gen potex2 = potex1^2
eststo: reg ln_uwe potex1 potex2 years_ed
eststo: reg ln_uwe potex1 potex2 years_ed, r
estimates store model_robust
esttab using PS4-21b.tex, replace compress ///
	cells("b(fmt(a3) star) se(fmt(a3))" t(par fmt(a3))) ///
	varlabels(potex1 "Potential Experience" potex2 "Potential Experience Squared" years_ed "Years of Education" _cons "Constant") ///
	mtitles("Log Weekly Wage (Normal)" "Log Weekly Wage (Robust)") ///
	collabels("Coef. / t" "Std. Err.") ///
	nonumbers ///
	stats(N, fmt(%9.0gc)) ///
	addnotes("t statistics in parentheses" @starlegend)
eststo clear

* Answer II.1.(c)

estimates restore model_robust
graph twoway function y = _b[_cons] + _b[potex1]*x + _b[potex2]*(x^2), range(0 80) xtick(#10) xlabel(#10) xtitle(Potential Experience) ytitle(Log Weekly Wages)
graph export PS4-21c.png, replace

* Answer II.1.(d)

program drop _all
program comsto, eclass
	qui `*'
	ereturn clear
	ereturn scalar estimate = r(estimate)
	ereturn scalar se = r(se)
	ereturn scalar t = r(t)
	ereturn scalar p = r(p)
	ereturn scalar lb = r(lb)
	ereturn scalar ub = r(ub)
	ereturn local cmd "comsto"
end

sum potex1
local avg_exp = r(mean)
qui estpost sum potex1
esttab using PS4-21d-1.tex, replace compress ///
	cells("count(fmt(%9.0gc)) mean(fmt(3)) sd(fmt(3)) min max") ///
	varlabels(potex1 "Potential Experience") ///
	collabels(Obs Mean "Std. Dev." Min Max) ///
	nomtitles ///
	nonumbers ///
	noobs

estimates restore model_robust
lincom _b[potex1] + 2*_b[potex2]*`avg_exp'
comsto lincom _b[potex1] + 2*_b[potex2]*`avg_exp'
esttab using PS4-21d-2.tex, replace compress ///
	cells("estimate(fmt(3) star) se(fmt(3)) t(fmt(2)) p(fmt(3)) lb(fmt(3)) ub(fmt(3))") ///
	varlabels(c1 "Marginal Effect") ///
	collabels(Coef. "Std. Err." t "$\text{P}>|\text{t}|$" "[95\% Conf." "Interval]") ///
	nomtitles ///
	nonumbers ///
	noobs ///
	addnotes(@starlegend)

* Answer II.1.(e)

estimates restore model_robust
nlcom _b[potex1] / (-2*_b[potex2] ), post
esttab using PS4-21e.tex, replace compress ///
	cells("b(fmt(3) star) se(fmt(3)) z(fmt(2)) p(fmt(3)) ci_l(fmt(3)) ci_u(fmt(3))") ///
	varlabels(_nl_1 "Peak-Earnings Age") ///
	collabels(Coef. "Std. Err." z "$\text{P}>|\text{z}|$" "[95\% Conf." "Interval]") ///
	nomtitles ///
	nonumbers ///
	noobs ///
	addnotes(@starlegend)
estimates clear

log close