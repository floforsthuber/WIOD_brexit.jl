# Script to compute value added losses due to brexit

# so I dont have to open the scripts and run them, should be replaced by a function in the end
include("src/leontief_matrix.jl")
include("src/mfn_tariffs.jl")
include("src/trade_elasticities.jl")

# ---------- Transform dataframes into matrices for computation ------------------------------------------------------------------------------------------------------

soft_brexit = all_tariffs.NTB_soft # N*S×1
hard_brexit = all_tariffs.avg_tariff .+ all_tariffs.NTB_hard # N*S×1
elasticities = all_elasticities.sigma # N*S×1

begin
    EU27 = ["AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", 
    "LTU", "LUX", "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE"]
end

ctry = sort([EU27; "GBR"]) # all vectors/matrices are sorted alphabetically 
position_GBR = findfirst(x -> x == "GBR", ctry) # find position of GBR

exports_to_GBR = exports[:, position_GBR] # N*S×1

# take out GBR rows
N = 27 # EU27 (no GBR)
S = 56

soft_brexit = soft_brexit[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1
hard_brexit = hard_brexit[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1
elasticities = elasticities[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1
exports_to_GBR = exports_to_GBR[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1
#v_add_share = v_add_share[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1
v_add_share = v_add_share[Not(position_GBR*S-S+1:position_GBR*S)] # N*S×1


L = L[Not(position_GBR*S-S+1:position_GBR*S), Not(position_GBR*S-S+1:position_GBR*S)] # N*S×N*S

# ---------- Computation -------------------------------------------------------------------------------------------------------------------------------------------

M_soft_brexit = similar(L) # N*S×N*S
M_hard_brexit = similar(L) # N*S×N*S

for i in 1:size(L, 1)
    for j in 1:size(L, 2)
        M_soft_brexit[i, j] = (elasticities[i] - 1) * soft_brexit[i]/100 * L[i, j] * exports_to_GBR[i] # N*S×N*S
        M_hard_brexit[i, j] = (elasticities[i] - 1) * hard_brexit[i]/100 * L[i, j] * exports_to_GBR[i] # N*S×N*S
    end
end

replace!(v_add_share, NaN => 0.0) # remove all NaN, mostly sectors U, T
# does value added need to stay within (0,1)?
v_add_share = [x < 1.0 && x > 0.0 ? x : 0.0 for x in v_add_share] # remove negative values and values above 1

repeat(1:S:size(M_soft_brexit, 2), inner=S)

# sum over all columns, i.e. per reporting country-sector pair (first S sectors are direct effects) but we need to select the right partner country (domestic sectors)!
index = hcat(1:size(M_soft_brexit, 1), repeat(1:S:size(M_soft_brexit, 2), inner=S)) # index for iterating over

direct_soft = [sum(M_soft_brexit[index[i, 1], index[i, 2]:index[i, 2]+S-1]) for i in 1:size(index, 1)] # N*S×1
direct_hard = [sum(M_hard_brexit[index[i, 1], index[i, 2]:index[i, 2]+S-1]) for i in 1:size(index, 1)] # N*S×1

indirect_soft = [sum(M_soft_brexit[index[i, 1], Not(index[i, 2]:index[i, 2]+S-1)]) for i in 1:size(index, 1)] # N*S×1
indirect_hard = [sum(M_hard_brexit[index[i, 1], Not(index[i, 2]:index[i, 2]+S-1)]) for i in 1:size(index, 1)] # N*S×1

# value added loss per country-sector pair
direct_loss_soft = -v_add_share .* direct_soft # N*S×1
direct_loss_hard = -v_add_share .* direct_hard # N*S×1

indirect_loss_soft = -v_add_share .* indirect_soft # N*S×1
indirect_loss_hard = -v_add_share .* indirect_hard # N*S×1

total_loss_soft = direct_loss_soft .+ indirect_loss_soft # N*S×1
total_loss_hard = direct_loss_hard .+ indirect_loss_hard # N*S×1

# value added loss per country
direct_ctry_loss_soft = [sum(direct_loss_soft[i:i+S-1]) for i in 1:S:S*N] # N×1
direct_ctry_loss_hard = [sum(direct_loss_hard[i:i+S-1]) for i in 1:S:S*N] # N×1

indirect_ctry_loss_soft = [sum(indirect_loss_soft[i:i+S-1]) for i in 1:S:S*N] # N×1
indirect_ctry_loss_hard = [sum(indirect_loss_hard[i:i+S-1]) for i in 1:S:S*N] # N×1

total_ctry_loss_soft = [sum(total_loss_soft[i:i+S-1]) for i in 1:S:S*N] # N×1
total_ctry_loss_hard = [sum(total_loss_hard[i:i+S-1]) for i in 1:S:S*N] # N×1


# some plots and tables

ctry_loss_wide = hcat(sort(EU27), direct_ctry_loss_soft, direct_ctry_loss_hard, indirect_ctry_loss_soft, indirect_ctry_loss_hard, total_ctry_loss_soft, total_ctry_loss_hard)
ctry_loss_wide = DataFrame(ctry_loss_wide, :auto)
rename!(ctry_loss_wide, [:iso3, :direct_soft, :direct_hard, :indirect_soft, :indirect_hard, :total_soft, :total_hard])

XLSX.writetable("clean/all_losses.xlsx", ctry_loss_wide, overwrite=true)

ctry_loss_long = stack(ctry_loss_wide, Not(:iso3))
ctry_loss_long = hcat(ctry_loss_long, DataFrame(reduce(vcat, permutedims.(split.(ctry_loss_long.variable, "_"))), [:channel, :scenario]))
select(ctry_loss_long, Not(:variable))

using StatsPlots

function grouped_bar_plot(scenario, channel, type, name)
    df = filter(row -> row.channel in channel && row.scenario == scenario, ctry_loss_long)
    plot = groupedbar(df[:, :iso3], -df.value/1000, group=df.channel, bar_width=0.8, bar_position=type, xrotation=90, color=[:red :blue])
    xlabel!("EU27")
    ylabel!("billion euro")
    title!("Loss in value added in a $scenario Brexit scenario")
    savefig(plot, "images/$name.png")
    #savefig(plot, "clean/$name.html")
    return plot
end

# direct vis-a-vis indirect loss per country
grouped_bar_plot("soft", ["direct", "indirect"], :dodge, "soft_split")
grouped_bar_plot("hard", ["direct", "indirect"], :dodge, "hard_split")

# total loss per country
grouped_bar_plot("soft", ["direct", "indirect"], :stack, "soft_total")
grouped_bar_plot("hard", ["direct", "indirect"], :dodge, "hard_total")
