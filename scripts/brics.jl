using DrWatson
@quickactivate "conspnet"

#using XLSX
using CSV
using DataFrames

#https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
# data for GDR for PPP current 
ffPPP = CSV.File(open(datadir("API_NY.GDP.MKTP.PP.CD_DS2_en_csv_v2_5730729.csv")), header=4) |> DataFrame

#data for GDP in constant 2015 $
ffKD = CSV.File(open(datadir("API_NY.GDP.MKTP.KD_DS2_en_csv_v2_5728927.csv")), header=4) |> DataFrame

#data for GDP in constant 2017 PPP
ffKPPP2017 = CSV.File(open(datadir("API_NY.GDP.MKTP.PP.KD_DS2_en_csv_v2_5795821.csv")), header=4) |> DataFrame

using Plots, Colors
using StatsPlots
#@df ff plot(:a, [:b :c])

get_country = cname -> filter("Country Name" => ==(cname), ff)

for i in ffPPP[!, "Country Name"]
    if contains(lowercase(i), "wor")
        @show i
    end
end

# i = "Central Europe and the Baltics"
# i = "Europe & Central Asia (excluding high income)"
# i = "Europe & Central Asia"
# i = "Euro area"
# i = "European Union"
# i = "Europe & Central Asia (IDA & IBRD countries)

G7 = ["Canada", "Japan", "United Kingdom", "United States", "European Union"] # "France", "Germany", "Italy"
brics = ["Brazil", "Russian Federation", "India", "China", "South Africa"]
world = ["World"]

bricsplus = ["Argentina", "Egypt, Arab Rep.", "Ethiopia", "Saudi Arabia", "United Arab Emirates"]
bricsplus = [brics..., bricsplus...]

cn = ffPPP[!, "Country Name"]

function get_sums(df, country_group, cn)
    dfdf = df[[findfirst(==(x), cn) for x in country_group], :]
    dftot = dfdf[:, 40:end-1] ./ 1e12
    dftot = combine(dftot, names(dftot) .=> sum, renamecols=false)
end

sums_bricsplus_PPP = get_sums(ffPPP, bricsplus, cn)
sums_bricsplus_PPP_const = get_sums(ffKPPP2017, bricsplus, cn)
sums_bricsplus_const2015 = get_sums(ffKD, bricsplus, cn)

sums_brics_PPP = get_sums(ffPPP, brics, cn)
sums_brics_PPP_const = get_sums(ffKPPP2017, brics, cn)
sums_brics_const2015 = get_sums(ffKD, brics, cn)

sums_g7_PPP = get_sums(ffPPP, G7, cn)
sums_g7_PPP_const = get_sums(ffKPPP2017, G7, cn)
sums_g7_const2015 = get_sums(ffKD, G7, cn)

sumsUSAPPP_const = get_sums(ffKPPP2017, ["United States"], cn)
sumsChinaPPP_const = get_sums(ffKPPP2017, ["China"], cn)
sumsUSA = get_sums(ffKD, ["United States"], cn)
sumsChina = get_sums(ffKD, ["China"], cn)

worldPPP = get_sums(ffKPPP2017, world, cn)
world_const2015 = get_sums(ffKD, world, cn)

dates = names(sums_g7_PPP)

ad = x -> adjoint(Matrix(x))
plot(dates, ad(sums_g7_PPP), title="Constant 2017 PPP", label="G7", linewidth=3)
plot!(dates, Matrix(sums_bricsplus_PPP)', label="BRICS+", linewidth=3)
plot!(dates, Matrix(sums_brics_PPP)', label="BRICS", linewidth=3)
ylabel!("Tn US\$")

plot(dates, Matrix(sumsUSAPPP)', label="USA", linewidth=3)
plot!(dates, Matrix(sumsChinaPPP)', label="China", linewidth=3)

plot(dates, Matrix(sums_g7_const2015)', label="G7", title="Constant 2015 US\$", linewidth=3)
plot!(dates, Matrix(sums_bricsplus_const2015)', label="BRICS+", linewidth=3)
plot!(dates, Matrix(sums_brics_const2015)', label="BRICS", linewidth=3)

plot(dates, Matrix(sumsUSAPPP)', label="USA", linewidth=3)
plot!(dates, Matrix(sumsChinaPPP)', label="China", linewidth=3)



ch_pc = sumsChina ./ world_const2015 .* 100
us_pc = sumsUSA ./ world_const2015 .* 100

plot(dates, Matrix(ch_pc)', title="% World GDP", label="China", linewidth=3)
plot!(dates, Matrix(us_pc)', title="% World GDP", label="USA", linewidth=3)


ch_pcppp = sumsChinaPPP_const ./ worldPPP .* 100
us_pcppp = sumsUSAPPP_const ./ worldPPP .* 100

plot(dates, Matrix(ch_pcppp)', title="% World GDP PPP const 2017", label="China", linewidth=3)
pp = plot!(dates, Matrix(us_pcppp)', title="% World GDP PPP const 2017", label="USA", linewidth=3)
savefig(pp, "USA_CN_worldPC.png")


#linestyle :solid, :dash, :dot, :dashdot, :dashdotdot
# US as pc of G&
us_pcg7 = sumsUSA ./ sums_g7_const2015 .* 100
g7plot = plot(dates, ad(us_pcg7), title="% of G7 GDP in constant 2015 \$", label="USA", line=(3, :green, :dash, :path))
#marker=(:circle,8,:green,:green)
#plot()

for country in G7
    if country == "United States"
        continue
    end
    count_pcg7 = get_sums(ffKD, [country], cn)
    g7plot = plot!(dates, ad(count_pcg7 ./ sums_g7_const2015 .* 100), label=country, linewidth=3)

end
g7plot
a = 2

china_pcbrics = sumsChina ./ sums_brics_const2015 .* 100
bricspcplot = plot(dates, ad(china_pcbrics), ylabel="%", title="% of BRICS GDP in 2017 PPP \$", label="China", linewidth=3, color=:black)
#plot()

for (i, country) in enumerate(brics) # plus
    count_pcbrics = get_sums(ffKD, [country], cn)
    bricspcplot = plot!(dates, ad(count_pcbrics ./ sums_brics_const2015 .* 100), label=country, linewidth=3)

end
bricspcplot


constrat = sums_bricsplus_const2015 ./ sums_g7_const2015
plot(dates, ad(constrat), title="Ratio of BRICS+ / G7 GDP", label="Const 2015 \$", line=(3, :black, :dash, :path))

PPPrat = sums_brics_PPP_const ./ sums_g7_PPP_const
plot!(dates, ad(PPPrat), label="PPP Const 2015 \$", line=(3, :red, :path))
a = 2


# brics = ["Brazil","Russian Federation", "India", "China", "South Africa"]
# bricsdfppp = ffPPP[[findfirst(==(x),cn) for x in brics],:]
# bricsdf_kd = ffKD[[findfirst(==(x),cn) for x in brics],:]

# bricsplus = ["Argentina", "Egypt, Arab Rep.", "Ethiopia", "Saudi Arabia", "United Arab Emirates"]
# bricsplus = [brics...,bricsplus...] 

# bricsplusdfppp = ffPPP[[findfirst(==(x),cn) for x in bricsplus],:]
# bricsplusdf_kd = ffKD[[findfirst(==(x),cn) for x in bricsplus],:]

# bricsplustot = bricsplusdfppp[:,40:end-1]  ./ 1e12
# bricsplustot = combine(bricsplustotssum, names(bricsplustotssum) .=> sum, renamecols=false )

# bricstot = bricsdfppp[:,40:end-1]  ./ 1e12
# bricstot = combine(bricstotssum, names(bricstotssum) .=> sum, renamecols=false )

# bricsplusKDtot = bricsplusKDppp[:,40:end-1]  ./ 1e12
# bricsplustot = combine(bricsplustotssum, names(bricsplustotssum) .=> sum, renamecols=false )

# bricstot = bricsdfppp[:,40:end-1]  ./ 1e12
# bricstot = combine(bricstotssum, names(bricstotssum) .=> sum, renamecols=false )



# plot(names(aa),Matrix(ssum)')