# Create leontief inverse matrix

using DataFrames, XLSX, LinearAlgebra

# ---------- Notes -------------------------------------------------------------------------------------------------------

# Problems with value added. See comment for v_add_share.

# ---------- Load data -------------------------------------------------------------------------------------------------------

# Subsample of EU27+GB (code also works for original dataset too only need to adjust the row bounds from 6/5 to 7/6 and N = 43+1)
path = "data/raw_wide_EU.xlsx"

raw = DataFrame(XLSX.readxlsx(path)["Sheet1"][:], :auto)

# ---------- Data wrangling -------------------------------------------------------------------------------------------------------

N = 27 + 1 # number of countries, EU27+GB
S = 56 # number of sectors

# cut out the additional variables in beginning/end (to have square matrix) (N*S×N*S rows/columns)
raw_A = raw[6:N*S+5, 5:N*S+4]
# cut sectoral input/output so only final demand variables remain (S*N rows and 5*N columns - 5 different measures of final demand:
# households/government/NGOs/inventory/capital_formation)
raw_FD = raw[6:N*S+5, 5+N*S:4+N*S+5*N]

# convert into matrix (cannot make matrix calculations with DataFrames)
A = Matrix(convert.(Float64, raw_A)) # N*S×N*S
FD = Matrix(convert.(Float64, raw_FD)) # N*S×N*5

# Leontief inverse matrix
L = inv(I - A) # N*S×N*S

# ---------- Variable creation -------------------------------------------------------------------------------------------------------

# gross total inputs used by sector k and country i: sum rows of column k,i
inputs = [sum(A[1:end, i]) for i in 1:size(A, 2)] # N*S×1

# gross total output from sector k and country i: sum columns of row k,i
outputs = [sum(A[i, 1:end]) for i in 1:size(A, 1)] # N*S×1, without final demand

# gross final demand from sector k and country i per country: sum five final demand columns of row k, i
f_demand = [sum(FD[i, j:j+4]) for i in 1:size(FD, 1), j in 1:5:size(FD, 2)] # N*S×N, final demand

# gross output from sector k and country i per country = exports per country (without final demand => intermediate demand): sum all country columns of row k, i
i_demand = [sum(A[i, j:j+S-1]) for i in 1:size(A, 1), j in 1:S:size(A, 2)] # N*S×N, intermediate demand per country

# gross exports from sector k and country i per country: sum intermediate and final demand
exports = [i_demand[i, j] + f_demand[i, j] for i in 1:size(i_demand, 1), j in 1:size(f_demand, 2)] #N*S×N, exports per country

# value added of sector k and country i (total): (output-input)/output
v_add_share = (outputs .- inputs) ./ outputs # N*S×1,

# Problems with value added:
# 1.    what to do with negative numbers (inputs > outputs), 1.0 (value added is all), Inf (no output)
#       maybe problem lies in the importing of the data and conversion to matrix, possibly multiply by 1million so we have bigger values form the start?
#       possibly solved when restricting sample to EU27+UK
# 

using Plots
histogram(v_add_share, xlims=(-1,1))

histogram(v_add_share, normalize=:probability, xlims=(-1,1))

size(v_add_share[v_add_share .< 1.0 & v_add_share .> -1.0])

v_add_share[v_add_share in -1:1]


a = v_add_share[v_add_share .> -1.0]
a[a .< 1.0]

size(a, 1)/size(v_add_share, 1)