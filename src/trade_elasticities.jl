# Trade elasticities

# Using trade elasticities from Imbs and Mejean (2017) (http://www.isabellemejean.com/data.html)
# http://www.isabellemejean.com/data.html in the folder for the paper "Trade elasticities", "/data_trade_elasticities/sigma_v9195.txt"

using DataFrames, CSV, XLSX

raw_sigma = CSV.read("data/sigma_v9195.txt", DataFrame) # data for elasticities
raw_names = CSV.read("data/country_m49_iso3.csv", DataFrame) # correspondance table for country names

raw_sigma[!, [:model, :method]] = convert.(String, raw_sigma[:, [:model, :method]]) # convert to string to use XLSX.writetable()
rename!(raw_sigma, :j => :m49) # change column name to join on identifier "m49"

joined = leftjoin(raw_sigma, raw_names, on = :m49) # join table

joined = joined[completecases(joined), :] # delete rows with missing values
transform!(joined, [:country, :iso3] .=> ByRow(string) .=> [:country, :iso3], renamecols=false) # change type to string to use XLSX.writetable()

# Still needs a match between ISIC Rev.3 and NACE Rev.2
# could not find a direct match, possible to use ISIC Rev. 3.1 as all included sectors were not changed
# however, still not possible to match properly (matching based on own judgement resultet in about 5-10 sectoral elasticities not 16 as authors claim)
# correspondance tables on Eurostat (RAMON): https://ec.europa.eu/eurostat/ramon/index.cfm?TargetUrl=DSP_PUB_WELC

XLSX.writetable("data/matching_elasticities.xlsx", joined, overwrite=true)
