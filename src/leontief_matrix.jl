# Script to create leontief inverse matrix, exports and value added

using DataFrames, XLSX, LinearAlgebra

# ---------- Notes -------------------------------------------------------------------------------------------------------

# Problems with value added. See comment for v_add_share.

# ---------- Load data -------------------------------------------------------------------------------------------------------

# Subsample of EU27+GB (code also works for original dataset too only need to adjust the row bounds from 6/5 to 7/6 and N = 43+1)
path = "clean/raw_wide_EU.xlsx"

raw = DataFrame(XLSX.readxlsx(path)["Sheet1"][:], :auto)

# ---------- Data wrangling -------------------------------------------------------------------------------------------------------

N = 27 + 1 # number of countries, EU27+GB
S = 56 # number of sectors

# cut out the additional variables in beginning/end (to have square matrix) (N*S×N*S rows/columns)
raw_D = raw[6:N*S+5, 5:N*S+4]
# cut sectoral input/output so only final demand variables remain (S*N rows and 5*N columns - 5 different measures of final demand:
# households/government/NGOs/inventory/capital_formation)
raw_FD = raw[6:N*S+5, 5+N*S:4+N*S+5*N]

# convert into matrix (cannot make matrix calculations with DataFrames)
D = Matrix(convert.(Float64, raw_D)) # N*S×N*S
FD = Matrix(convert.(Float64, raw_FD)) # N*S×N*5

# ---------- Variable creation -------------------------------------------------------------------------------------------------------

# gross total inputs used by sector k and country i: sum rows of column k,i
inputs = [sum(D[1:end, i]) for i in 1:size(D, 2)] # N*S×1

# gross total output from sector k and country i: sum columns of row k,i
outputs = [sum(D[i, 1:end]) for i in 1:size(D, 1)] # N*S×1, without final demand

# gross final demand from sector k and country i per country: sum five final demand columns of row k, i
f_demand = [sum(FD[i, j:j+4]) for i in 1:size(FD, 1), j in 1:5:size(FD, 2)] # N*S×N, final demand

# gross output from sector k and country i per country = exports per country (without final demand => intermediate demand): sum all country columns of row k, i
i_demand = [sum(D[i, j:j+S-1]) for i in 1:size(D, 1), j in 1:S:size(D, 2)] # N*S×N, intermediate demand per country

# gross exports from sector k and country i per country: sum intermediate and final demand
exports = i_demand + f_demand #N*S×N, exports per country

# gross final demand from sector k and country i
final = [sum(f_demand[i, :]) for i in 1:size(f_demand, 1)] # N*S×1

# gross total demand from sector k and country i
outputs_total = outputs .+ final

# value added of sector k and country i (total): (output-input)/output
v_add_share = (outputs_total .- inputs) ./ outputs_total # N*S×1, with final demand

all_value_added = hcat(raw[6:end,[:x4, :x1]], v_add_share, makeunique=true)
rename!(all_value_added, [:iso3, :WIOD, :value_added])
transform!(all_value_added, [:iso3, :WIOD] .=> ByRow(string) .=> [:iso3, :WIOD], renamecols=false) # change type to string to use XLSX.writetable()

XLSX.writetable("clean/all_value_added.xlsx", all_value_added, overwrite=true)

# value added of sector k and country i (total): (output-input)/output
#v_add_share_without_fd = (outputs .- inputs) ./ outputs # N*S×1, without final demand (probably wrong)


# Problems with value added:
# 1.    what to do with negative numbers (inputs > outputs), 1.0 (value added is all), Inf (no output)
#       maybe problem lies in the importing of the data and conversion to matrix, possibly multiply by 1million so we have bigger values form the start?
#       possibly solved when restricting sample to EU27+UK
#

# ---------- Leontief inverse matrix -------------------------------------------------------------------------------------------------------

# technical coefficients: "a dollar's value of inputs from country i into sector k per a dollar's worth of output of country j in sector s"
A = similar(D)

# we need to use final demand here!
for i in 1:size(A, 1)
    for j in 1:size(A, 2)
        A[i, j] = D[i, j] / outputs_total[i] # if I use final instead, I cannot invert the matrix below
    end
end

replace!(A, NaN => 0.0) # remove all NaN, mostly sectors U, T

# Leontief inverse matrix
# Leontief coeffiecients measure the total of dollars worth of country j, sector k goods required to meet 1 dollar woth of country i, sector z 's final demand
L = inv(I - A)