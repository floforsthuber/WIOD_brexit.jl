# Create leontief inverse matrix

using DataFrames, XLSX, LinearAlgebra

# ---------- Load data -------------------------------------------------------------------------------------------------------

# File in ".xlsb" format, hence, need to transform manually into ".csv" first (download from http://www.wiod.org/database/wiots16)
url = "http://www.wiod.org/protected3/data16/wiot_ROW/WIOT2014_Nov16_ROW.xlsb" # does not work because of "xlsb"
url = "WIOT2014_Nov16_ROW.xlsx"

raw = DataFrame(XLSX.readxlsx(url)["2014"][:], :auto)

# cut out the additional variables on the end (to have square matrix) (so take S*N rows/columns (56*(43+ROW)))
raw = raw[7:56*44+6, 5:56*44+4]

A = Matrix(convert.(Float64, raw))

L = inv(I - A)

# gross inputs for sector k and country i: sum rows of column k,i
# gross output for sector k and country i: sum columns of row k,i

inputs = [sum(A[1:end, i]) for i in 1:size(A, 1)]
outputs = [sum(A[i, 1:end]) for i in 1:size(A, 2)] # without final demand of households/government/NGOs/inventory/capital_formation

v_add_share = (outputs .- inputs) ./ outputs # what to do with negative numbers (inputs > outputs), 1.0 (value added is all), Inf (no output)
# problem lies probably in the importing of the data and conversion to matrix, possibly multiply by 1million so we have bigger values form the start?