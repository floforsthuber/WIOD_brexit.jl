# WTO MFN tariffs

# In the paper they use US-EU MFN tariffs as a proxy for hard Brexit (should only need to download US-DE since same trade policy at EU level)
# Tariffs are levied at product level (HS6), thus they need to be aggregated to the 56 sectors of the WIOD table.
# Use the correspondence of HS2007 and CPA2008 (obtained via Eurostat: RAMON)
# WTO tariff data was obtained via: http://tariffdata.wto.org/Default.aspx?culture=en-US

using DataFrames, CSV

# ---------- Correspondence tables -------------------------------------------------------------------------------------------------------

# HS2007 vis-a-vis CPA2008
raw_HS_CPA = CSV.read("data/HS2007_CPA2008.csv", DataFrame)[2:end, 1:2]
rename!(raw_HS_CPA, [:HS2007, :CPA2008])
transform!(raw_HS_CPA, [:HS2007, :CPA2008] .=> ByRow(string) .=> [:HS2007, :CPA2008], renamecols=false) # change type to string
raw_HS_CPA = replace.(raw_HS_CPA, r"[.]" => "") # take out dot of string

# HS2017 vis-a-vis HS2007
raw_HS_HS = CSV.read("data/WTO_tariffs/HS2017_HS2007.txt", DataFrame)
rename!(raw_HS_HS, [:TL_used, :TL_selected] .=> [:HS2017, :HS2007])
raw_HS_HS = lpad.(raw_HS_HS[:, [:HS2017, :HS2007]], 6, '0') # pad with leading zeros so all have 6 digits

# combine HS2017, HS2007 and CPA2008
HS_HS_CPA = leftjoin(raw_HS_HS, raw_HS_CPA, on=:HS2007)

# ---------- WTO tariffs -------------------------------------------------------------------------------------------------------

begin
delete = ["Base nomenclature", "Number of subheadings", "Number of lines", "Number of AVDuties", "Number of non AVDuties", "List of non AVDuties",
 "List of unit values", "Exchange rate", "Import value"]
end

raw_tariffs = CSV.read("data/WTO_tariffs/MFN_tariffs.txt", DataFrame)[:, Not(delete)]
col_names = ["reporter", "year", "HS_level", "HS2017", "avtariff_avg", "avtariff_min", "avtariff_max", "tariff_free", "HS2017_long"] # new names
rename!(raw_tariffs, col_names) # rename columns
transform!(raw_tariffs, [:reporter, :HS2017, :HS2017_long] .=> ByRow(string) .=> [:reporter, :HS2017, :HS2017_long], renamecols=false) # change type to string

# depending on digit code pad with leading zeros (not absolutely necessary since we lose all codes with digits < 6 when matched with correspondence tables)
for i in 1:size(raw_tariffs, 1)
    raw_tariffs.HS2017[i] = lpad(raw_tariffs.HS2017[i], raw_tariffs.HS_level[i], "0")
end


