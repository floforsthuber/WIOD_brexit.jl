# WTO MFN tariffs

# In the paper they use US-EU MFN tariffs as a proxy for hard Brexit (should only need to download US-DE since same trade policy at EU level)
# Tariffs are levied at product level (HS6), thus they need to be aggregated to the 56 sectors of the WIOD table.
# Use the correspondence of HS2007 and CPA2008 (obtained via Eurostat: RAMON)
# WTO tariff data was obtained via: http://tariffdata.wto.org/Default.aspx?culture=en-US

using DataFrames, CSV, Statistics, Plots, XLSX

# ---------- Correspondence tables -------------------------------------------------------------------------------------------------------

# HS2007 vis-a-vis CPA2008
raw_HS_CPA = CSV.read("data/HS2007_CPA2008.csv", DataFrame)[2:end, 1:2]
rename!(raw_HS_CPA, [:HS2007, :CPA2008])
transform!(raw_HS_CPA, [:HS2007, :CPA2008] .=> ByRow(string) .=> [:HS2007, :CPA2008], renamecols=false) # change type to string
raw_HS_CPA = replace.(raw_HS_CPA, r"[.]" => "") # take out dot of string
f(x) = x[1:2] # select first two elements of cell
raw_HS_CPA[:, :CPA2digits] = f.(raw_HS_CPA[:, :CPA2008]) # aggregates CPA2008 to two digit level

# CPA2008 (2 digits) vis-a-vis NACE Rev.2 (and the WIOD classification of sectors which aggregates some NACE)
raw_CPA_NACE = CSV.read("data/CPA2008_NACE2.csv", DataFrame)
transform!(raw_CPA_NACE, names(raw_CPA_NACE) .=> ByRow(string) .=> names(raw_CPA_NACE), renamecols=false) # change type to string
raw_CPA_NACE[:, :CPA2digits] = lpad.(raw_CPA_NACE[:, :CPA2digits], 2, '0') # pad with leading zeros so all have 2 digits

# combine HS2007, CPA2008, CPA2digits, NACE Rev. 2
c_table_HS_NACE = leftjoin(raw_HS_CPA, raw_CPA_NACE, on=:CPA2digits)

# HS2007 vis-a-vis HS2017
raw_HS_HS = CSV.read("data/HS2007_HS2017.csv", DataFrame)
raw_HS_HS = lpad.(raw_HS_HS[:, [:HS2017, :HS2007]], 6, '0') # pad with leading zeros so all have 6 digits

# add correspondence vis-a-vis HS2017 as tariff data from WTO uses HS2017
c_table_HS_NACE = leftjoin(c_table_HS_NACE, raw_HS_HS, on=:HS2007)
describe(c_table_HS_NACE)[:, :nmissing] # 62 of 5642 HS2007 codes do not have a corresponding HS2017 code (would say thats pretty good!)

XLSX.writetable("clean/table_correspondence_HS_NACE.xlsx", c_table_HS_NACE, overwrite=true)

# ---------- WTO tariffs -----------------------------------------------------------------------------------------------------------------

begin # vector for columns to take out
delete = ["Base nomenclature", "Number of subheadings", "Number of lines", "Number of AVDuties", "Number of non AVDuties", "List of non AVDuties",
 "List of unit values", "Exchange rate", "Import value"]
end

raw_tariffs = CSV.read("data/MFN_tariffs_2020.txt", DataFrame)[:, Not(delete)]
col_names = ["reporter", "year", "HS_level", "HS2017", "avtariff_avg", "avtariff_min", "avtariff_max", "tariff_free", "HS2017_long"] # new names
rename!(raw_tariffs, col_names) # rename columns
transform!(raw_tariffs, [:reporter, :HS2017, :HS2017_long] .=> ByRow(string) .=> [:reporter, :HS2017, :HS2017_long], renamecols=false) # change type to string

# depending on digit code pad with leading zeros (not absolutely necessary since we lose all codes with digits < 6 when matched with correspondence tables)
for i in 1:size(raw_tariffs, 1)
    raw_tariffs.HS2017[i] = lpad(raw_tariffs.HS2017[i], raw_tariffs.HS_level[i], "0")
end

# ---------- Correspondence: Tariffs to NACE Rev.2 -----------------------------------------------------------------------------------------------------------------

dropmissing!(c_table_HS_NACE) # cannot join on column with missing values
raw_tariffs = raw_tariffs[map(x->length(x), raw_tariffs[:, :HS2017]).==6, :] # only keep 6 digit HS codes

tariff_NACE = leftjoin(raw_tariffs, c_table_HS_NACE, on=:HS2017)
describe(tariff_NACE) # 172 of 11.330 missing due to matching, 623 of 11.330 missing due to data reported missing
# what to do with missing tariff data? either drop or assume zero tariffs, i.e. impacts the calculation of the average

# ---------- Replicate Figure 1: Average tariffs imposed by EU -----------------------------------------------------------------------------------------------------

dropmissing!(tariff_NACE) # still need to decide what to do with missing tariff data - for now just drop all of them

# data for averages with zero tariffs, maximum and minimum (always 0)
gdf = groupby(tariff_NACE, [:reporter, :WIOD, :Figure1])
d_tariff_NACE = combine(gdf, :avtariff_avg => mean => :avg, :avtariff_avg => maximum => :max) # we lose some sectors (non-tradables, for example public administration)
filter!(row -> row.reporter == "European Union", d_tariff_NACE)
sort!(d_tariff_NACE, :avg, rev=true)
#filter!(row -> row.reporter == "United States of America", d_tariff_NACE)

# data for sample average without zero tariffs
avg_zeros = filter(x -> x.avtariff_avg > 0 && x.reporter == "European Union", tariff_NACE)
gdf = groupby(avg_zeros, [:reporter, :WIOD, :Figure1])
avg_zeros = combine(gdf, :avtariff_avg => mean => :avg)

# Figure 1
begin
    figure1 = bar(d_tariff_NACE.max, xticks=(1:size(d_tariff_NACE,1),
     d_tariff_NACE.Figure1), ylims=(0,25), xrotation=90, label="min/max", color=:orange)
    xlabel!("NACE Rev. 2 activties")
    ylabel!("AV Applied Tariff (%)")
    scatter!(d_tariff_NACE.avg, label="average", color=:blue)
    plot!(fill(mean(d_tariff_NACE.avg), size(d_tariff_NACE,1)), width=2,
     color=:red, label="sample average with zero tariffs = $(round(mean(d_tariff_NACE.avg), digits=1)) ")
    plot!(fill(mean(avg_zeros.avg), size(avg_zeros, 1)), width=2,
     color=:green, label="sample average of positive tariffs = $(round(mean(avg_zeros.avg), digits=1))")
    
    savefig(figure1, "clean/figure1.png")
end
