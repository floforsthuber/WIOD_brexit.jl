# Using trade elasticities from Imbs and Mejean (2017) (http://www.isabellemejean.com/data.html)
# http://www.isabellemejean.com/data.html in the folder for the paper "Trade elasticities", "/data_trade_elasticities/sigma_v9195.txt"

using DataFrames, CSV, DelimitedFiles

raw_sigma = CSV.read("sigma_v9195.txt", DataFrame)

raw_names = CSV.read("country_m49_iso3.csv", DataFrame)

