### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
	using Test
	
	push!(LOAD_PATH, "./src")
	using YaLinearAlgebra
end

# ╔═╡ 87e5e2ec-8915-11eb-362b-6bf13a36b8e4
md"""
## k-Nearest Neightbors

ref. from book **"Data Science from Scratch"**, Chap 12
"""

# ╔═╡ cb25501a-8915-11eb-3626-a1ae6d233f92
html"""
<a id='toc'></a>
"""

# ╔═╡ cb0838ae-8915-11eb-082f-3991192a101f
md"""
#### TOC
  - [The model](#model)
  - [Example with this Iris Dataset](#iris-dataset)
  - [The Curse of Dimensionality](#dimensionality)
"""

# ╔═╡ caf03ada-8915-11eb-2935-01e110accba6
html"""
<p style="text-align: right;">
  <a id='model'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ cad66356-8915-11eb-0173-ada200678f63
md"""
### The model

Nearest makes no mathematical assumption and only requires two elements:
  1. A distance
  1. An assumption that points close to each other (given the distance) are similar.

The prediction for a given data point depends only on a few datapoints (k of them) "close" to it.

In this notebook the data points will be vector and the distance will be the Euclidean one.

Assuming we pick a number k, we then want to classify a new data point by finding the k nearest ones and let them vote on the new ouptut.
To achieve this we need a function that counts the votes.
"""

# ╔═╡ dc3b7280-8915-11eb-258a-1789476897b9
begin
	function raw_majority_vote(labels::AbstractVector{Symbol})::Symbol
		votes = count(labels)
		most_common(votes; k=1)[1]
	end
	
	function count(labels::AbstractVector{Symbol})::Dict{Symbol, Integer}
		hcnt = Dict{Symbol, Integer}()
		for label ∈ labels
			hcnt[label] = get(hcnt, label, 0) + 1
		end
		hcnt
	end
	
	function most_common(hcnt::Dict{Symbol, Integer}; 
			k::Integer=1)::Pair{Symbol,Integer}
		collect(hcnt) |> l -> sort(l, by=t -> t[2]; rev=true)[k]
	end
end

# ╔═╡ dc209b9a-8915-11eb-0f63-ab3b7c33793c
begin
	h = count([:b, :a, :b, :a, :c, :b, :d])
	@test h[:b] == 3
	@test h[:a] == 2
	@test h[:c] == h[:d] == 1
	
	@test sort(collect(h), by=t -> t[2]; rev=true)[1] == (:b => 3)

	@test raw_majority_vote([:b, :a, :b, :a, :c, :b, :d]) == :b
end

# ╔═╡ d7aade44-891b-11eb-00d3-abe7406c4b09
md"""
We need to take into account the possibility of ties. If this happens we will reduce k until we find a winner which will happen eventually. In the worse case we will go down until k equals 1.
"""

# ╔═╡ 9ae99efe-891c-11eb-3d1f-89182e3f9ff8
function majority_vote(labels::AbstractVector{Symbol})::Symbol
	"""
	Assuming labels is ordered from nearest to farthest
	"""
	vote_counts = count(labels)
	winner, winner_cnt = most_common(vote_counts)
	num_winners = length([
		cnt for cnt ∈ values(vote_counts) if cnt == winner_cnt 
	])
	
	num_winners == 1 && (return winner)
	majority_vote(view(labels, 1:length(labels)-1))
end

# ╔═╡ ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
begin
	@test majority_vote([:b, :a, :b, :a, :c, :b, :d]) == :b
	@test majority_vote([:b, :a, :b, :a, :c, :b, :d, :a]) == :b
	@test majority_vote([:b, :a, :b, :a, :c, :a, :d, :b]) == :a
end

# ╔═╡ d7931368-891b-11eb-2899-f5e5a3f4bd35
md"""
Let us now create our classifer applying knn.
"""

# ╔═╡ 516d69f0-891e-11eb-0f7a-3f05981cc1e1
begin
	const VF = Vector{AbstractFloat}

	struct LabeledPoint
		point::VF
		label::Symbol
	
		LabeldPoint(point::VF, sym::Symbol) = new(point, label)
	end

	function knn(k::Integer, dataset::Vector{LabeledPoint}, qpoint::VF)::Symbol
		## order from nearest to farthest using euclidean distance
		bydist = sort(dataset, by=lp -> distance(lp.point, qpoint), rev=false)
		
		## find label from k closest
		k_near_labels = map(lp -> lp.label, view(bydist, 1:k))
			
		## vote and return decision
		majority_vote(k_near_labels)
	end
end

# ╔═╡ 50fe5114-891e-11eb-18ee-35d98ad32b7b
md"""
Let us test this on an existing dataset.
"""

# ╔═╡ dc0c5a5e-8915-11eb-2c62-5328b42add69
html"""
<p style="text-align: right;">
  <a id='iris-dataset'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ dbefe77a-8915-11eb-39f1-5d0c84729739
md"""
### Example with this Iris Dataset

TODO ...
"""

# ╔═╡ dbd86924-8915-11eb-351f-8362f09ba984


# ╔═╡ 582837d4-8916-11eb-0d89-bd391a60224d


# ╔═╡ 5809f59e-8916-11eb-1c09-6fa00c043e7a


# ╔═╡ 57eda95c-8916-11eb-24c1-7f950c322cdf


# ╔═╡ dbbf22a2-8915-11eb-00eb-4b0278c0283d
html"""
<p style="text-align: right;">
  <a id='dimensionality'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ dba976a2-8915-11eb-0ff0-b38952cbc38b
md"""
### The Curse of Dimensionality

TODO ...
"""

# ╔═╡ 5996f2f4-8916-11eb-390e-7d4e4bcbd394


# ╔═╡ 59756f76-8916-11eb-1a95-05445d906d2c


# ╔═╡ db8c02b6-8915-11eb-1283-c7803529cff3


# ╔═╡ ca91a0d6-8915-11eb-36cc-a18fc8efaf40


# ╔═╡ Cell order:
# ╟─87e5e2ec-8915-11eb-362b-6bf13a36b8e4
# ╠═5eebac68-891b-11eb-37ba-c1d9481c6134
# ╟─cb25501a-8915-11eb-3626-a1ae6d233f92
# ╟─cb0838ae-8915-11eb-082f-3991192a101f
# ╟─caf03ada-8915-11eb-2935-01e110accba6
# ╟─cad66356-8915-11eb-0173-ada200678f63
# ╠═dc3b7280-8915-11eb-258a-1789476897b9
# ╠═dc209b9a-8915-11eb-0f63-ab3b7c33793c
# ╟─d7aade44-891b-11eb-00d3-abe7406c4b09
# ╠═9ae99efe-891c-11eb-3d1f-89182e3f9ff8
# ╠═ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
# ╟─d7931368-891b-11eb-2899-f5e5a3f4bd35
# ╠═516d69f0-891e-11eb-0f7a-3f05981cc1e1
# ╟─50fe5114-891e-11eb-18ee-35d98ad32b7b
# ╟─dc0c5a5e-8915-11eb-2c62-5328b42add69
# ╠═dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╠═582837d4-8916-11eb-0d89-bd391a60224d
# ╠═5809f59e-8916-11eb-1c09-6fa00c043e7a
# ╠═57eda95c-8916-11eb-24c1-7f950c322cdf
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╠═dba976a2-8915-11eb-0ff0-b38952cbc38b
# ╠═5996f2f4-8916-11eb-390e-7d4e4bcbd394
# ╠═59756f76-8916-11eb-1a95-05445d906d2c
# ╠═db8c02b6-8915-11eb-1283-c7803529cff3
# ╠═ca91a0d6-8915-11eb-36cc-a18fc8efaf40
