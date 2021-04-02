cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"

capture log using PS3-4, replace

clear
set more off
cd "C:\Users\wonja\Documents\GitHub\14.320\PS3"
use final5

* Problem 4.(a)

keep if 5 < c_size & classize < 45
replace avgmath = avgmath - 100 if avgmath > 100
replace avgverb = avgverb - 100 if avgverb > 100
replace avgmath = . if mathsize == 0
drop if mi(c_size) | mi(classize) | mi(verbsize) | mi(mathsize)
sum classize c_size tipuach verbsize mathsize avgverb avgmath, detail
eststo: quietly estpost sum classize c_size tipuach verbsize mathsize avgverb avgmath, detail
esttab using PS3-4a.tex, replace compress cells("mean(fmt(a1)) sd(fmt(a1)) p10(fmt(a1)) p25(fmt(a1)) p50(fmt(a1)) p75(fmt(a1)) p90(fmt(a1))") nonumbers mtitles("Unweighted descriptive statistics") varlabels(classize "Class size" c_size "Enrollment" tipuach "Percent disadvantaged" verbsize "Reading size" mathsize "Math size" avgverb "Average verbal" avgmath "Average math") stats(N, fmt(%9.0gc) label("Observations"))
eststo clear

* Problem 4.(b)

eststo: reg avgmath classize
eststo: reg avgverb classize
esttab using PS3-4b.tex, replace compress nonumbers mtitles("Average math" "Average verbal") varlabels(classize "Class size" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

* Problem 4.(c) i.

eststo: reg avgmath classize c_size
eststo: reg c_size classize
eststo: reg avgmath classize
esttab using PS3-4ci-1.tex, replace compress nonumbers mtitles("Average math" "Enrollment" "Average math") varlabels(classize "Class size" c_size "Enrollment" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

eststo: reg avgverb classize c_size
eststo: reg c_size classize
eststo: reg avgverb classize
esttab using PS3-4ci-2.tex, replace compress nonumbers mtitles("Average verbal" "Enrollment" "Average verbal") varlabels(classize "Class size" c_size "Enrollment" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

* Problem 4.(c) ii.

eststo: reg avgmath classize tipuach
eststo: reg tipuach classize
eststo: reg avgmath classize
esttab using PS3-4cii-1.tex, replace compress nonumbers mtitles("Average math" "Percent disadvantaged" "Average math") varlabels(classize "Class size" tipuach "Percent disadvantaged" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

eststo: reg avgverb classize tipuach
eststo: reg tipuach classize
eststo: reg avgverb classize
esttab using PS3-4cii-2.tex, replace compress nonumbers mtitles("Average verbal" "Percent disadvantaged" "Average verbal") varlabels(classize "Class size" tipuach "Percent disadvantaged" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))
eststo clear

* Problem 4.(c) iii.

eststo: reg avgmath classize c_size tipuach
eststo: reg avgverb classize c_size tipuach
esttab using PS3-4ciii.tex, replace compress nonumbers mtitles("Average math" "Average verbal") varlabels(classize "Class size" c_size "Enrollment" tipuach "Percent disadvantaged" _cons "Constant") stats(N, fmt(%9.0gc) label(Observations))

log close