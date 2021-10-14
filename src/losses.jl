# Script to compute value added losses due to brexit

# so I dont have to open the scripts and run them, should be replaced by a function in the end
include("src/leontief_matrix.jl")
include("src/mfn_tariffs.jl")
include("src/trade_elasticities.jl")

# ---------- Transform dataframes into matrices for computation ------------------------------------------------------------------------------------------------------

N = 27 + 1 # EU27 + GBR
S = 56

soft_brexit = all_tariffs.avg_tariff .+ all_tariffs.NTB_soft # N*S×1
hard_brexit = all_tariffs.avg_tariff .+ all_tariffs.NTB_hard # N*S×1
elasticities = all_elasticities.sigma # N*S×1

begin
    EU27 = ["AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", 
    "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"]
end

ctry = sort([EU27; "GBR"]) # all vectors/matrices are sorted alphabetically 
position_GBR = findfirst(x -> x == "GBR", ctry) # find position of GBR

exports_to_GBR = exports[:, 12] # N*S×1

# ---------- Computation -------------------------------------------------------------------------------------------------------------------------------------------


a = (elasticities .- 1) .* soft_brexit # N*S×1
b = L*exports_to_GBR # N*S×1
c = a .* b
d = v_add_share .* c

e = d[1:54]
sum(e)

sum(d[57:57+54])