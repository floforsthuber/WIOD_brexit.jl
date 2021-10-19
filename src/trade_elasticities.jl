# Script to obtain sectoral-country trade elasticities

# Using trade elasticities from Imbs and Mejean (2017) (http://www.isabellemejean.com/data.html)
# http://www.isabellemejean.com/data.html in the folder for the paper "Trade elasticities", "/data_trade_elasticities/sigma_v9195.txt"

using DataFrames, CSV, XLSX, Statistics

# ---------- Match elasticities with WIOD ISO3 names -------------------------------------------------------------------------------------------------------

# elasticities
raw_sigma = CSV.read("data/sigma_v9195.txt", DataFrame) # data for elasticities
rename!(raw_sigma, :j => :m49) # change column name to join on identifier "m49"

# M49 vis-a-vis ISO3 country names
raw_names = CSV.read("data/country_m49_iso3.csv", DataFrame)

# join tables
c_table_ctry = leftjoin(raw_sigma, raw_names, on = :m49) # join table
c_table_ctry = c_table_ctry[completecases(c_table_ctry), :] # delete rows with missing values
transform!(c_table_ctry, [:isic3, :model, :method, :country, :iso3] .=> ByRow(string) .=> [:isic3, :model, :method, :country, :iso3], renamecols=false) # change type to string to use XLSX.writetable()

XLSX.writetable("clean/table_elasticities.xlsx", c_table_ctry, overwrite=true)

# ---------- Correspondence table for ISIC to NACE -------------------------------------------------------------------------------------------------------

# Cannot match directly between ISIC Rev.3 and NACE Rev.2
# Solution: ISIC Rev.3 to ISIC Rev.3.1 to ISIC Rev.4 to NACE Rev.2 to classification used in paper (i.e. small aggregations)

# ISIC Rev.3 vis-a-vis ISIC Rev.3.1
raw_ISIC3_ISIC31 = CSV.read("data/ISIC3_ISIC31.txt", DataFrame)[:, Not(["partial3", "partial31", "Activity"])]
rename!(raw_ISIC3_ISIC31, [:ISIC3, :ISIC31])
raw_ISIC3_ISIC31 = string.(raw_ISIC3_ISIC31)
raw_ISIC3_ISIC31 = lpad.(raw_ISIC3_ISIC31, 4, '0') # pad with leading zeros so all have 4 digits

# ISIC Rev.3.1 vis-a-vis ISIC Rev.4
raw_ISIC31_ISIC4 = CSV.read("data/ISIC31_ISIC4.txt", DataFrame)[:, Not(["partialISIC31", "partialISIC4", "Detail"])]
rename!(raw_ISIC31_ISIC4, [:ISIC31, :ISIC4])
raw_ISIC31_ISIC4 = string.(raw_ISIC31_ISIC4)
raw_ISIC31_ISIC4 = lpad.(raw_ISIC31_ISIC4, 4, '0') # pad with leading zeros so all have 4 digits

# ISIC Rev.4 vis-a-vis NACE Rev.2
raw_ISIC4_NACE2 = CSV.read("data/ISIC4_NACE2.csv", DataFrame)[2:end, 1:2]
rename!(raw_ISIC4_NACE2, [:ISIC4, :CPA2008]) # rename to CPA2008 as only numerical NACE codes (i.e. no A01 but just 01 which correspond to CPA2008)
raw_ISIC4_NACE2 = string.(raw_ISIC4_NACE2) # remove all one digit codes (otherwise bounds error below since we select first two characters)
filter!(row -> length(row.CPA2008) > 1, raw_ISIC4_NACE2)
f(x) = x[1:2] # select first two elements of cell
raw_ISIC4_NACE2[:, :CPA2008] = f.(raw_ISIC4_NACE2[:, :CPA2008]) # aggregates CPA2008 to two digit level (i.e. match all codes to just two digit level)

# CPA2008 (2 digits) vis-a-vis NACE Rev.2 (and the WIOD classification of sectors which aggregates some NACE)
raw_CPA_NACE = CSV.read("data/CPA2008_NACE2.csv", DataFrame)
transform!(raw_CPA_NACE, names(raw_CPA_NACE) .=> ByRow(string) .=> names(raw_CPA_NACE), renamecols=false) # change type to string
raw_CPA_NACE[:, :CPA2digits] = lpad.(raw_CPA_NACE[:, :CPA2digits], 2, '0') # pad with leading zeros so all have 2 digits

# join table to create a single correspondence table
c_table_ISIC_NACE = leftjoin(raw_ISIC3_ISIC31, raw_ISIC31_ISIC4, on=:ISIC31)
c_table_ISIC_NACE = leftjoin(c_table_ISIC_NACE, raw_ISIC4_NACE2, on=:ISIC4)
rename!(c_table_ISIC_NACE, :CPA2008 => :CPA2digits)
c_table_ISIC_NACE = leftjoin(c_table_ISIC_NACE, raw_CPA_NACE, on=:CPA2digits)

XLSX.writetable("clean/table_correspondence_ISIC_NACE.xlsx", c_table_ISIC_NACE, overwrite=true)

# ---------- Match elasticities with NACE Rev.2 -------------------------------------------------------------------------------------------------------

rename!(c_table_ctry, :isic3 => :ISIC3)

# lose too many sectors when matching to 4 digits with adding a zero, therefore, change ISIC into 2 digits and match
#c_table_ctry[:, :ISIC3] = rpad.(c_table_ctry[:, :ISIC3], 4, '1') # add a zero since since we match with 4 digit codes (lose too many sectors)
c_table_ctry[:, :ISIC3] = f.(c_table_ctry[:, :ISIC3])
c_table_ISIC_NACE[:, :ISIC3] = f.(c_table_ISIC_NACE[:, :ISIC3])

elas_NACE = leftjoin(c_table_ctry, c_table_ISIC_NACE, on=:ISIC3) 

dropmissing!(elas_NACE) # only two sectors which are not matched (38 and 39 - actually could not find ISIC sectors with these codes!)
begin
    EU27 = ["AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", 
    "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"]
end
filter!(row -> row.iso3 in [EU27; "GBR"], elas_NACE) # only keep EU27 and GBR

# summary statistics per country
gdf = groupby(elas_NACE, [:iso3])
d_elas_NACE = combine(gdf, :sigma => mean => :avg, :sigma => maximum => :max, :sigma => minimum => :min) # elasticities only available for 11 countries

# summary statistics per country-sector pairs (some sectors have multiple elasticities - need to average over them)
gdf = groupby(elas_NACE, [:iso3, :WIOD])
elas_NACE = combine(gdf, :sigma => mean => :sigma)

# ---------- Final table containinng all elasticities, countries, sectors -------------------------------------------------------------------------------------------

# use the country-sector elasticities and assume an elasticity of -4 per sector for all other country-sector partialISIC31

WIOD = raw_CPA_NACE.WIOD
unique!(WIOD)

N = size(EU27, 1) + 1 # EU27 + GBR
S = size(WIOD, 1)

country = repeat([EU27; "GBR"], inner=S)
WIOD = repeat(WIOD, outer=N)
d_ctry_WIOD = DataFrame(iso3 = country, WIOD = WIOD)

all_elasticities = leftjoin(d_ctry_WIOD, elas_NACE, on=[:iso3, :WIOD]) # have elasticities for about 15 sectors per available country
all_elasticities = coalesce.(all_elasticities, 5.0) # assume elasticity of -4 for all the missing country-sector pairs
sort!(all_elasticities, [:iso3, :WIOD])

XLSX.writetable("clean/all_elasticities.xlsx", all_elasticities, overwrite=true)
