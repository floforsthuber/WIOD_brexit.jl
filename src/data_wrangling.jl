# Script to transform data

using DataFrames, XLSX

# ---------- Load data --------------------------------------------------------------------------------------------------------

# File in ".xlsb" format, hence, need to transform manually into ".csv" first (download from http://www.wiod.org/database/wiots16)
url = "http://www.wiod.org/protected3/data16/wiot_ROW/WIOT2014_Nov16_ROW.xlsb" # does not work because of "xlsb"
url = "data/WIOT2014_Nov16_ROW.xlsx"

raw = DataFrame(XLSX.readxlsx(url)["2014"][:], :auto)

# ---------- Data wrangling ---------------------------------------------------------------------------------------------------

# Naming convention
# --- r...reporter
# --- p...partner
# --- s...sector
# --- ctry...country/countries

raw = raw[3:end, :] # delete empty rows
raw[1:2, 1] .= missing # delete table legend in top left corner

# table in long format (need to broadcast countries and sectors)
# idea is to name the columns as a combination of sectors and countries, transform into long format and then seperate names again
names_sector_iso = collect(raw[1, 5:end])
names_sector_long = collect(raw[2, 5:end])
names_sector_short = collect(raw[4, 5:end])
names_ctry = collect(raw[3, 5:end])
seperator = fill("___", size(collect(raw[3, 5:end]), 1)) # take 3 "_" as there are some in the text as well
colnames = names_sector_iso .* seperator .* names_sector_long .* seperator .* names_sector_short .* seperator .* names_ctry # combination of names

colnames = vcat(["r_s_iso", "r_s_long", "r_ctry", "r_s_short"], colnames) # name the reporter columns
rename!(raw, Symbol.(colnames))

table_matching = raw[1:4, 5:end] # save the table of names for later, possibly need to match sectors/countries later

raw = raw[5:end, :] # get rid of the now useless first 4 rows

raw_long = stack(raw, Not(1:4)) # transform to long format

# split the column with the combined names along "___" into four columns
raw_long = hcat(raw_long, DataFrame(reduce(vcat, permutedims.(split.(raw_long.variable, "___"))), [:p_s_iso, :p_s_long, :p_s_short, :p_ctry]))
#raw_long = raw_long[:, Not(:variable)] # delete combined named column

begin
    EU27 = ["AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", 
    "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"]
end

raw_long_EU = filter(row -> row.r_ctry in [EU27; "GBR"], raw_long)
filter!(row -> row.p_ctry in [EU27; "GBR"], raw_long_EU)

# delete extra columns which where split before and return to wide format (not possible to match multiple into one column name yet)
select!(raw_long_EU, Not([:p_s_iso, :p_s_long, :p_s_short, :p_ctry]))
raw_wide_EU = unstack(raw_long_EU, [:r_s_iso, :r_s_long, :r_s_short, :r_ctry], :variable, :value)

# get original column names (4 rows) and combine it with table
col_names = names(raw_wide_EU[1,5:end]) # gives the names in the right order
col_names = split.(col_names, "___") # splits along seperator
col_names = [col_names[i][j] for i in 1:size(col_names, 1), j in 1:4]
col_names = permutedims(col_names) # gives transpose of string matrix
col_names = convert.(String, col_names) # could not write excel file with type String{String}
col_names = DataFrame(hcat(zeros(4, 4), col_names), :auto) # transform into dataframe

raw_wide_EU = vcat(col_names, DataFrame(Matrix(raw_wide_EU), :auto)) # transform column names so they can be joined

XLSX.writetable("data/raw_wide_EU.xlsx", raw_wide_EU, overwrite=true)

