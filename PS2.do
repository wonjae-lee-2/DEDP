capture log using PS2-b1, replace

* Problem B.1.(a)

clear
set more off
local path "C:\Users\wonja\Documents\GitHub\14.320"
cd `path'
use cps_extract

keep if 30 <= age & age < 50
summ
gen awe = incwage / wkswork1
drop if mi(awe)
gen ahe = awe / uhrswork1
drop if mi(ahe)
gen lnawe = ln(awe)
drop if mi(lnawe)
gen lnahe = ln(ahe)
drop if mi(lnahe)
la var awe "average weekly earnings"
la var ahe "average hourly earnings"
la var lnawe "natural log of average weekly earnings"
la var lnahe "natural log of average hourly earnings"
summ awe ahe lnawe lnahe

* Problem B.1.(b)

preserve
keep if race == 100 & 40 <= age
ttest lnawe, by (sex)
ttest lnahe, by (sex)

* Problem B.1.(c)

reg lnawe sex
reg lnahe sex

* Problem B.1.(d)

ttest lnahe, by (sex)
ttest lnahe, by (sex) unequal
reg lnahe sex

restore

* Problem B.1.(e)

gen age2 = age^2
bys sex: reg lnahe age age2

* Problem B.1.(f)

gen white = 0
replace white = 1 if race == 100
gen ba = 0
replace ba = 1 if 15 <= educ99 
reg lnahe sex
reg lnahe sex white age2 ba


log close