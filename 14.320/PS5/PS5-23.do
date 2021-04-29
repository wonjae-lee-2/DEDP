cd "C:\Users\wonja\Documents\GitHub\DEDP\14.320\PS5"
capture log using PS5-23, replace
clear
set more off

* PS5-II.3.a

use k99

eststo: reg pscore cs
esttab using PS5-23a.tex, replace ///
	nonumbers mtitles("Regular") ///
	coeflabels(cs "Class Size" _cons "Constant") ///
	b(3) se(3)

* PS5-II.3.b

eststo: reg pscore cs, robust
esttab using PS5-23b.tex, replace ///
	nonumbers mtitles("Regular" "Robust") ///
	coeflabels(cs "Class Size" _cons "Constant") ///
	b(3) se(3)

* PS5-II.3.c

eststo: reg pscore cs, vce (cluster classid)
esttab using PS5-23c.tex, replace ///
	nonumbers mtitles("Regular" "Robust" "Cluster") ///
	coeflabels(cs "Class Size" _cons "Constant") ///
	b(3) se(3)

* PS5-II.3.d

collapse (mean) pscore cs (count) observations = pscore, by(classid)
eststo: reg pscore cs [aweight = observations]
esttab using PS5-23d.tex, replace ///
	nonumbers mtitles("Regular" "Robust" "Cluster" "Collapsed") ///
	coeflabels(cs "Class Size" _cons "Constant") ///
	b(3) se(3)
eststo clear

log close