### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 000c1c07-fd7a-4e08-9e36-3f0aa6069309
begin
	using PlutoUI
	
	using CSV, DataFrames, Pipe, TabularDisplay
	using Plots, StatsPlots
end

# ╔═╡ 578530b0-9b50-11eb-07e1-5db7ceb1b1c7
md"""
## Data wrangling in Julia

Based on presentations by Tom Kwong:
  - [Data Wrangling Techniques in Julia - Part 1](https://www.youtube.com/watch?v=txme9o0EdLk) 
  - [Data Wrangling Techniques in Julia - Part 2](https://www.youtube.com/watch?v=NbqQZq42gLc)


$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ 6bcfba84-98ab-4d26-b98c-d86cb65dc277
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ f88a1737-7a84-4103-82c8-1920bae6b2e8
md"""
### What is data wrangling?

Take raw data (and/or unorganized data) and turn them (data as plural of datum) into something useful.

A possible data wrangling is as follows:


 read | $\Rightarrow$ | clean |  $\Rightarrow$ | Tidy 
  --- | --- | --- | --- | --- 
      |     |         $\Uparrow$ |           | $\Downarrow$ 
      |              | **Visualize** | $\Leftarrow$ | **Analyze** 


**Julia ecosystem**:

Read | Clean, Tidy, Analyze | Visualize
--- | --- | --- |
CSV | DataFrames| Plots, StatsPlots
Parquet | DataFramesMeta | Makie, StatsMakie
SASLib | Query| Gadfly
ReadStat | JuliaDB, JuliaDBMeta | Gaston
JSON, JSON2/3 | | VegaLite
LightXML, EzXML | | UnicodePlots
XLSX, ExcelReader, Taro | | 
PDFIO | |
"""

# ╔═╡ 02ac758d-3706-4bf4-8a36-83aff4422d0e
md"""
### Read

Utilize automated tools to read data into memory as cleanly as possible.

`CSV.jl`:
  - Skip leading/trailing rows
  - Parse missing values e.g "NA"
  - Parse date/time values
  - Normalize columns
  - Select/drop columns on read
  - User specified column types
  - Auto-delimiter detection
  - Automatic pooled string columns
  - Parse booleans
  - Transpose data
"""

# ╔═╡ fb1f4efc-6b89-48a6-95d5-8e3661edf53d
md"""
### Clean

  - Delete unwanted columns
  - Delete rows with missing data
  - Rename columns
  - Fix column data type
  - ...

Examples
```julia
describe(df)          # take a quick peek

select!(df, 1:5)      # keep "good" columns / delete unwanted ones 
select!(df, Not(["garbaggecol1", "garbaggecol2"]))


rename!(df, "Region Name" => :region_name)

dropmissing!(df)      # Remove rows with missing data
dropmissing!(df, Between(:x3, :x5))
```

"""

# ╔═╡ f22c3d88-e0e6-4d1d-92d4-c99f80aa4733
md"""
### Tidy Data

  - Each variable forms a *column*
  - Each observation forms a *row*
  - Each type of observational unit forms a *table*


**Tidy Recipes, examples:**

```julia
# Stack all date columns into rows
# The column names are stored ion a new column "Date"
sdf = stack(df, Not(:Region_name); variable_name=:Date)
sdf = stack(df, Not(1); variable_name=:Date)
sdf = stack(df, 2:5; variable_name=:Date)

# Date column is a CategoricalArray type. Make it Date type
sdf.Date = [Date(get(x)) for x ∈ sdf.Date]
# or maybe using broadcast:
sdf.Date .= get.(sdf.Data) .|> Date

# Hoe to turn it back to a wide format?
df2 = unstack(sdf, :date, :value)

# It may introduce Union{Missing, T} column type. Let's fix it.
disallowmissing!(df2, 2:5)
```
"""

# ╔═╡ 2dc07426-ad94-46a0-8da2-68d687ad87c2
md"""
### Analyze

Get some insights from data. 

**Analuyze Recipe**:

```julia
selct(df, :region_name, 4:5)                   # select by column

filter(:region_name => ==("Abilene, TX"), df)  # note df is the 2nd arg here
filter("2020-01-31" => >(400_000), df)

sort(df, :region_name)
sort(df, :region_name, rev=true)

# Transform means adding new columns - many more ways of using Transform
transform(df, :region_name => ByRow(length) => :region_name_len)

# Group
groupby(sdf, :Date)

# Summarize the grouped data:
combine(groupby(sdf, :Date), :value => mean => :avg)

# Using Pipe.jl to build a transformation pipeline
@pipe sdf |>
    groupby(_, :Date) |>
	combine(_, :value => mean => :avg)

country = DataFrame(Name=["United States"])

# Joining data is easy
innerjoin(df, country, on=[:region_name => :name])
leftjoin(df, country, on=[:region_name => :name])
rightjoin(df, country, on=[:region_name => :name])
outerjoin(df, country, on=[:region_name => :name])

# Also
semijoin(df, country, on=[:region_name => :name])
antijoin(df, country, on=[:region_name => :name])
```
"""

# ╔═╡ cb11e3e6-f385-44db-b739-cf056a7f8841
md"""
### Visualize

Gain more insight by looking at the data in a graphical form.


**Visualize Recipes:**

`Plots.jl` | `StatsPlots.jl`
--- | ---
`plot` | `groupedbar`
`scatter` | `corrplot`
`histogram` | `marginhist`
`heatmap` | `boxplot`
`bar` | `violin`
... | ...

"""

# ╔═╡ 944f1843-1802-45b7-a505-8bb32ad09902
md"""
## Let's practice

### Tidying
"""

# ╔═╡ f9d0761d-a859-404a-812f-f2a424c7b191
begin
	df = CSV.File("data/youth_suicide.csv", header=true) |> DataFrame;
	size(df)
end

# ╔═╡ 6790c878-d494-4247-ab1a-d5122d3d845b
first(df, 5)

# ╔═╡ ff4cc1c3-5967-4614-82eb-cc8771e962dc
names(df)

# ╔═╡ 5315e6b5-344e-42e7-a9a7-b53cfaf2b5b5
with_terminal() do
	displaytable(names(df), index=true)
end

# ╔═╡ 8083c3d3-51f6-437e-ba12-38f8b5814e1e
describe(df, :eltype, :nmissing, :first => first)

# ╔═╡ e70b9da8-34f9-4193-a86e-5e7dc9ed23aa
## turn colums 2 to 19 to row (observations)
sdf = stack(df, 2:19; variable_name=:type_year);

# ╔═╡ e783b82c-052e-49d3-87c8-70142b990d5f
size(sdf)

# ╔═╡ e9d507d7-df67-4bd4-b80b-02385b2f9be5
begin
	## Now spread content of column `:type_year` into 2 separate columns
	sdf[!, :ctype] .= split.(sdf.type_year, " ") .|> a -> getindex(a, 1)
	sdf[!, :year] .= split.(sdf.type_year, " ") .|> a -> getindex(a, 2)
	select!(sdf, Not(:type_year))
	first(sdf, 3)
end

# ╔═╡ 723dc0d9-96c4-43c0-81fd-611209e10106
## Let's check if the Total type really contains the total
## 1 - Pick a county
sdf[sdf.County .== "Yakima", :]

# ╔═╡ 0031eb09-8e5f-47fe-b04d-1600fad8f994
## Remove the total row which is redundant

sdf₁ = @pipe sdf |>
	filter(:ctype => ≠("Total"), _) |>
	filter(:year => ≠("(2008-2012)"), _);

# ╔═╡ f8ee2398-2b69-4133-b2d6-11a2c12b9d27
sdf₁[sdf₁.County .== "Yakima", :]

# ╔═╡ c52c8ce7-c68b-4b7b-b507-5a813d32cf93
describe(sdf₁)

# ╔═╡ 4b14a6ad-6dc5-4319-95bf-007e84ae6877
unique(sdf₁.year)
## Now we want integer instead of string and we want to get rid of the parentheses.

# ╔═╡ 54a8cfd0-5daa-40e3-8a0e-12413cc36e83
## mutate column year from String to Int
sdf₁[!, :year] .= replace.(sdf₁.year, r"[\(\)]" => "") |> a -> parse.(Int, a)

# ╔═╡ 3378787b-c9cf-4d47-a119-2a35abc3b0b4
describe(sdf₁, :eltype, :min, :max, :nunique, :nmissing)

# ╔═╡ 53aa180c-7260-46cf-a2a3-4a49e0c30844
begin
	# Male and Female variables can be put back as columns now
	df₁ = unstack(sdf₁, :ctype, :value)
	df₁[df₁.County .== "Yakima", :]
end

# ╔═╡ 56d8dcc1-8b76-4332-bbe4-f7081e178300
md"""
### Visualize
"""

# ╔═╡ 73a99bae-e8a6-44d1-af74-9778e17df7b9
# Plot King county's yearly rate
filter(:County => ==("King"), df₁)

# ╔═╡ 5eaa88b0-95e4-4410-bd99-cb9ad40fdb79
# bar chart
@pipe df₁ |>
	filter(:County => ==("King"), _) |>
	bar(_.year, _.Male, 
        title = "King County Youth Suicides (Male)",
        legend = :none,
        size = (450, 300))

# ╔═╡ 5548eaac-d390-4cb1-bf49-0b8985c1f0f0
begin
	# Prepare to plot both Male and Female together
	df_stacked = stack(df₁, 3:4; variable_name = "gender");
	names(df_stacked)
end

# ╔═╡ bb947d94-62f3-45f6-a0d1-9ed596e289c8
@pipe df_stacked |>
	filter(:County => ==("King"), _) |>
	 groupedbar(    # StatsPlots.jl
		_.year,     # x-axis 
	    _.value;    # y-axis
        group = _.gender,
        bar_position = :stack,
        bar_width = 0.7,
        title = "King County Suicides",
        size = (450, 300),
        legend = :topleft)

# ╔═╡ 5fadd975-cbcf-4a0e-b493-0382875354ba
@pipe df₁ |>
    groupby(_, :County)

# ╔═╡ a92c1c18-39bd-4dcf-81a7-f2f62577e156
# 5 year totals
@pipe df₁ |>
    groupby(_, :County) |>
    combine(_, :Female => sum, :Male => sum)

# ╔═╡ 2c21d894-7e57-4f92-b08d-a4d527f5c25a
# 5 year totals with male/female combined
@pipe df₁ |>
    groupby(_, :County) |>
    combine(_, :Female => sum, :Male => sum) |>
    select(_, :County, [:Female_sum, :Male_sum] => ByRow(+) => :Total)

# ╔═╡ 72aeaa39-6529-4fc3-ba86-f2b113a5a075
let 
    data₁ = @pipe df₁ |>
        groupby(_, :year) |>
        combine(_, :Female => sum => :Female, :Male => sum => :Male) |>
        stack(_, 2:3; variable_name = :gender, value_name = :suicides) 
	
    plot(data₁.year, data₁.suicides; groups = data₁.gender,
        title = "Youth Suicides Trend",
        legend = :topleft,
        linewidth = 3,
        size = (450, 300))
end

# ╔═╡ a7802df0-6819-4650-a539-ccbb99333e92
let
    data₂ = @pipe df₁ |>
        select(_, :County, :year, [:Female, :Male] => ByRow(+) => :total) |>
        unstack(_, :year, :total)
	
    values = Matrix(data₂[:, 2:end])
	
    StatsPlots.heatmap(2008:2012, data₂.County, values;
        title = "Youth Suicide Heatmap",
        xticks = :all,
        yticks = :all,
        size = (400, 600))
end

# ╔═╡ 8018394c-a123-43c4-aaaf-3d942284e182
html"""
<style>
  main {
        max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
        background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─578530b0-9b50-11eb-07e1-5db7ceb1b1c7
# ╠═000c1c07-fd7a-4e08-9e36-3f0aa6069309
# ╟─6bcfba84-98ab-4d26-b98c-d86cb65dc277
# ╟─f88a1737-7a84-4103-82c8-1920bae6b2e8
# ╟─02ac758d-3706-4bf4-8a36-83aff4422d0e
# ╟─fb1f4efc-6b89-48a6-95d5-8e3661edf53d
# ╟─f22c3d88-e0e6-4d1d-92d4-c99f80aa4733
# ╟─2dc07426-ad94-46a0-8da2-68d687ad87c2
# ╟─cb11e3e6-f385-44db-b739-cf056a7f8841
# ╟─944f1843-1802-45b7-a505-8bb32ad09902
# ╠═f9d0761d-a859-404a-812f-f2a424c7b191
# ╠═6790c878-d494-4247-ab1a-d5122d3d845b
# ╠═ff4cc1c3-5967-4614-82eb-cc8771e962dc
# ╠═5315e6b5-344e-42e7-a9a7-b53cfaf2b5b5
# ╠═8083c3d3-51f6-437e-ba12-38f8b5814e1e
# ╠═e70b9da8-34f9-4193-a86e-5e7dc9ed23aa
# ╠═e783b82c-052e-49d3-87c8-70142b990d5f
# ╠═e9d507d7-df67-4bd4-b80b-02385b2f9be5
# ╠═723dc0d9-96c4-43c0-81fd-611209e10106
# ╠═0031eb09-8e5f-47fe-b04d-1600fad8f994
# ╠═f8ee2398-2b69-4133-b2d6-11a2c12b9d27
# ╠═c52c8ce7-c68b-4b7b-b507-5a813d32cf93
# ╠═4b14a6ad-6dc5-4319-95bf-007e84ae6877
# ╠═54a8cfd0-5daa-40e3-8a0e-12413cc36e83
# ╠═3378787b-c9cf-4d47-a119-2a35abc3b0b4
# ╠═53aa180c-7260-46cf-a2a3-4a49e0c30844
# ╟─56d8dcc1-8b76-4332-bbe4-f7081e178300
# ╠═73a99bae-e8a6-44d1-af74-9778e17df7b9
# ╠═5eaa88b0-95e4-4410-bd99-cb9ad40fdb79
# ╠═5548eaac-d390-4cb1-bf49-0b8985c1f0f0
# ╠═bb947d94-62f3-45f6-a0d1-9ed596e289c8
# ╠═5fadd975-cbcf-4a0e-b493-0382875354ba
# ╠═a92c1c18-39bd-4dcf-81a7-f2f62577e156
# ╠═2c21d894-7e57-4f92-b08d-a4d527f5c25a
# ╠═72aeaa39-6529-4fc3-ba86-f2b113a5a075
# ╠═a7802df0-6819-4650-a539-ccbb99333e92
# ╟─8018394c-a123-43c4-aaaf-3d942284e182
