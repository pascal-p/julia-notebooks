### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 1b354ec4-68fb-11eb-2963-2bf081ae52ad
using JuliaDB, Distributions

# ╔═╡ fb086364-68fc-11eb-32f6-ab7218186246
begin
	# using Pkg
	# Pkg.add("OnlineStats")
	
	using OnlineStats
end

# ╔═╡ e0cc6636-690d-11eb-0885-9790a38923c8
using PlutoUI

# ╔═╡ aeb3b894-68fa-11eb-18c7-516e32b88d55
md"""
## JuliaDB - tutorial

ref. [Using table](https://www.youtube.com/watch?v=pv5zfIs2lyU)  

ref. [Selections in JuliaDB ](https://www.youtube.com/watch?v=eQORf4m_8Hk)  

ref. [Reductions in JuliaDB](https://www.youtube.com/watch?v=tCVgn9m2ajM)

ref. [Grouping in JuliaDB to calculate descriptive statistics](https://www.youtube.com/watch?v=hU7N-EWnC2A)

ref. [Joining 2 tables](https://www.youtube.com/watch?v=CIBxY7PUjc0)

ref. [Importing a csv file in JuliaDB] (https://www.youtube.com/watch?v=slL_oj5Dmzc)   

ref. [JuliaDB](https://juliacomputing.github.io/JuliaDB)

"""

# ╔═╡ 21d810d6-68fb-11eb-3542-5906971c0c1a
md"""
### The `table()` function
"""

# ╔═╡ 53c79c1a-68fb-11eb-26a2-bf3828728dbb
begin
	ids = collect(1:10);
	ages = round.(Int8, rand(Normal(50, 20), 10)); # Normal distribution with μ=50 and σ^2 = 20
	length(ids), length(ages)
end

# ╔═╡ 715cd434-68fb-11eb-177f-eb8052e0787c
typeof(ids), typeof(ages)

# ╔═╡ 762ef460-68fb-11eb-1439-e7c2b6528c28
table_1 = table(ids, ages, names=[:ID, :AGE])

# ╔═╡ 953e99dc-68fb-11eb-30b6-5f9c7cc86257
subject_3 = table_1[3]

# ╔═╡ 9c2f284c-68fb-11eb-256c-ab5ee6c17d67
table_1[3:5]

# ╔═╡ a2e4491a-68fb-11eb-384a-652b7eb5ac71
# Another table (in_memory)

table_2 = table(ids,
    [:I, :I, :II, :III, :III, :II, :I, :III, :II, :I],
    round.(rand(Normal(16, 4), 10), digits=1), ## Normal dist μ=16 and σ^2 = 4
    round.(rand(Normal(12, 3), 10), digits=1), ## Normal dist. with μ=12 and σ^2 = 3
    names = [:ID, :GROUP, :HB, :WCC], pkey=:ID)

# ╔═╡ a3bd8a22-68fb-11eb-1333-7199c93b565d
table_3 = table(Columns(ID=ids, CRP=round.(Int16, rand(Normal(100, 20), 10))), pkey=:ID)

# ╔═╡ 09d1097e-68fc-11eb-1259-5da24a55ac7c
md"""
### Selections
"""

# ╔═╡ 2a824488-68fc-11eb-0de7-fbd2904440fb
## create new (sub-)table, using filter function passing a lambda and a table
## select all rowqs fro group :I
grouped_by_I = filter(t -> t.GROUP == :I, table_2)

# ╔═╡ 47bfa588-68fc-11eb-0365-a95c30fd3d39
grouped_by_III = filter(t -> t.GROUP == :III, table_2)

# ╔═╡ 533225c6-68fc-11eb-0d69-45914f9418db
high_WCC = filter(t -> t.WCC > 12, table_2)

# ╔═╡ 5eb97ade-68fc-11eb-18b4-d1a014439da9
md"""
### Reductions
"""

# ╔═╡ 758a03b4-68fc-11eb-3834-1710458d0191
table_2

# ╔═╡ 7f48e442-68fc-11eb-3526-45f76696ff14
## sum on column :WCC
reduce(+, table_2, select=:WCC; init=0)

# ╔═╡ 8d170fb8-68fc-11eb-197d-5fb88f9b12b2
## min and max values on column :WCC
## NOTE: we pass a tuple to reduce

reduce((min, max), table_2, select=:WCC)

# ╔═╡ a169a92e-68fc-11eb-23cd-a9c983423808
reduce((Mean(), Variance()), table_2, 
	select=:WCC) # using function from OnlineStats package

# ╔═╡ 443cf75c-68fd-11eb-0ad0-25884c49c9ae
md"""
### Grouping
"""

# ╔═╡ 630e56b2-68fd-11eb-1bf5-2f69e0dd269a
## Calculate the mean of HB per group
groupreduce(Mean(), table_2, :GROUP, select = :HB)

# ╔═╡ 6b59c392-68fd-11eb-18dd-29050ae8cb39
## Calculate the variance of HB per group
groupreduce(Variance(), table_2, :GROUP, select = :HB)

# ╔═╡ 884358c4-68fd-11eb-3e8f-e11e24f1dc84
## grouping by mean, median, ...

groupby((mean, median, std, var, quantile), table_2, :GROUP, select=:HB)

# ╔═╡ b5e4fb40-68fd-11eb-3568-6754c8dcf55b
md"""
### Joining 2 tables 
"""

# ╔═╡ d9c87b40-68fd-11eb-32ac-9108bff7f829
left_table = table(ids, ages, names=[:ID, :AGE], pkey=:ID)

# ╔═╡ f4fc8dd2-68fd-11eb-2309-ffe7574dc250
right_table = table(collect(1:15), 
	round.(Int16, rand(Normal(100, 20), 15)), 
	names=[:ID, :GROUP], 
	pkey = :ID) 

# ╔═╡ 14de3128-68fe-11eb-0c08-f5409401513e
join(left_table, right_table)  ## inner-join the 2 tables on ID

# ╔═╡ 28eedfd2-68fe-11eb-1b84-6dcf0ce6857b
join(right_table, left_table)  ## inner-join the 2 tables on ID, the other way...

# ╔═╡ 4d6808b6-68fe-11eb-0790-f1619d25e329
join(left_table, right_table, how=:left) ## inner-join the 2 tables on ID, from left table

# ╔═╡ 58c352f4-68fe-11eb-384d-d576e23d1d46
join(left_table, right_table, how=:outer) ## outer-join left and right table on ID 

# ╔═╡ 648943d4-68fe-11eb-0b23-c71f63be5957
join(right_table, left_table, how=:anti)  ## only tuple that have no id in right table

# ╔═╡ b61dc290-68fe-11eb-1d40-e72940ae6be0
md"""
### Loading a CSV file
"""

# ╔═╡ c83fda3c-68fe-11eb-3112-3d01bf2d0693
## csv file is in the current directory
db = loadtable("Data.csv", header_exists=true)

# ╔═╡ 9e8aa658-68ff-11eb-1a80-f50efa89f446
length(db)

# ╔═╡ da1b2fee-690e-11eb-2ca1-1785bbccb4e5
with_terminal() do
	println(rows(db, (:CRIM, :ZN)))
end

# ╔═╡ 882f3840-6901-11eb-2329-f3ab3b4c22a1
begin
	n_t = filter(t -> t.CRIM > 2., db)
	
	with_terminal() do
		println(select(n_t, (:CRIM, :ZN, :AGE, :B)))
	end
end

# ╔═╡ 72b6b062-690e-11eb-1abc-d9ddf9f363e1
summarize((m = mean, s = std), db)

# ╔═╡ Cell order:
# ╟─aeb3b894-68fa-11eb-18c7-516e32b88d55
# ╠═1b354ec4-68fb-11eb-2963-2bf081ae52ad
# ╠═fb086364-68fc-11eb-32f6-ab7218186246
# ╠═e0cc6636-690d-11eb-0885-9790a38923c8
# ╟─21d810d6-68fb-11eb-3542-5906971c0c1a
# ╠═53c79c1a-68fb-11eb-26a2-bf3828728dbb
# ╠═715cd434-68fb-11eb-177f-eb8052e0787c
# ╠═762ef460-68fb-11eb-1439-e7c2b6528c28
# ╠═953e99dc-68fb-11eb-30b6-5f9c7cc86257
# ╠═9c2f284c-68fb-11eb-256c-ab5ee6c17d67
# ╠═a2e4491a-68fb-11eb-384a-652b7eb5ac71
# ╠═a3bd8a22-68fb-11eb-1333-7199c93b565d
# ╟─09d1097e-68fc-11eb-1259-5da24a55ac7c
# ╠═2a824488-68fc-11eb-0de7-fbd2904440fb
# ╠═47bfa588-68fc-11eb-0365-a95c30fd3d39
# ╠═533225c6-68fc-11eb-0d69-45914f9418db
# ╟─5eb97ade-68fc-11eb-18b4-d1a014439da9
# ╠═758a03b4-68fc-11eb-3834-1710458d0191
# ╠═7f48e442-68fc-11eb-3526-45f76696ff14
# ╠═8d170fb8-68fc-11eb-197d-5fb88f9b12b2
# ╠═a169a92e-68fc-11eb-23cd-a9c983423808
# ╟─443cf75c-68fd-11eb-0ad0-25884c49c9ae
# ╠═630e56b2-68fd-11eb-1bf5-2f69e0dd269a
# ╠═6b59c392-68fd-11eb-18dd-29050ae8cb39
# ╠═884358c4-68fd-11eb-3e8f-e11e24f1dc84
# ╟─b5e4fb40-68fd-11eb-3568-6754c8dcf55b
# ╠═d9c87b40-68fd-11eb-32ac-9108bff7f829
# ╠═f4fc8dd2-68fd-11eb-2309-ffe7574dc250
# ╠═14de3128-68fe-11eb-0c08-f5409401513e
# ╠═28eedfd2-68fe-11eb-1b84-6dcf0ce6857b
# ╠═4d6808b6-68fe-11eb-0790-f1619d25e329
# ╠═58c352f4-68fe-11eb-384d-d576e23d1d46
# ╠═648943d4-68fe-11eb-0b23-c71f63be5957
# ╟─b61dc290-68fe-11eb-1d40-e72940ae6be0
# ╠═c83fda3c-68fe-11eb-3112-3d01bf2d0693
# ╠═9e8aa658-68ff-11eb-1a80-f50efa89f446
# ╠═da1b2fee-690e-11eb-2ca1-1785bbccb4e5
# ╠═882f3840-6901-11eb-2329-f3ab3b4c22a1
# ╠═72b6b062-690e-11eb-1abc-d9ddf9f363e1
