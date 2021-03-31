capture log using ps2-1, replace

* Problem 1.(a)

clear
set more off
cd "C:\Users\wonja\Documents\GitHub\14.750"

use mitaData

gen x2 = x^2
gen y2 = y^2
gen xy = x*y
gen x3 = x^3
gen y3 = y^3
gen x2y = x^2*y
gen xy2 = x*y^2
sum x2 y2 xy x3 y3 x2y xy2

* Problem 1.(b)

reg lhhequiv pothuan_mita x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <100, vce(cluster district)
reg lhhequiv pothuan_mita x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <75, vce(cluster district)
reg lhhequiv pothuan_mita x2 y2 xy x3 y3 x2y xy2 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <50, vce(cluster district)

* Problem 1.(C)

gen dpot2 = dpot^2
gen dpot3 = dpot^3

reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <100, vce(cluster district)
reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <75, vce(cluster district)
reg lhhequiv pothuan_mita dpot dpot2 dpot3 elv_sh slope infants children adults bfe4_1 bfe4_2 bfe4_3 if d_bnd <50, vce(cluster district)

log close