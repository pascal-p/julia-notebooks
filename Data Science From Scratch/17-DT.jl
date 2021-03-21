### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
	using Test
	using Random
	using PlutoUI
end

# ╔═╡ 87e5e2ec-8915-11eb-362b-6bf13a36b8e4
md"""
## Decision Trees (DT)

ref. from book **"Data Science from Scratch"**, Chap 17
"""

# ╔═╡ 8e2aca8e-8a8f-11eb-1e68-1316740f4697
begin
	const F = Float64
	const T = Any
	const VF = AbstractVector{F}
	const VT = AbstractVector{T1} where {T1 <: Any};
end

# ╔═╡ cb25501a-8915-11eb-3626-a1ae6d233f92
html"""
<a id='toc'></a>
"""

# ╔═╡ cb0838ae-8915-11eb-082f-3991192a101f
md"""
#### TOC
  - [Entropy](#entropy)
  - [Entropy Partition](#entropy-partition)
  - [Creating our DT](#creating-dt)
  - [Putting it all Together](#all-together)
"""

# ╔═╡ caf03ada-8915-11eb-2935-01e110accba6
html"""
<p style="text-align: right;">
  <a id='entropy'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ cad66356-8915-11eb-0173-ada200678f63
md"""
### Entropy

In mathematical terms, if pᵢ is the proportion of data labeled as class cᵢ, then the entropy is defined as:

$$H(S) = \sum_i -p_i \times log_2(p_i)$$

With the standard convention: $0 \times log_2(0) = 0$

Each term is non-negative and is close to 0 when pᵢ is either close 0 or close to 1.
This means the entropy will be small when every pᵢ is close to 0 or 1 (*i.e.* when most of the data is in 1 class) and it will be larger when many of the pᵢ's are close to 0 (*i.e.* when the data is spread across multiple classes).
"""

# ╔═╡ dc3b7280-8915-11eb-258a-1789476897b9
function entropy(class_prob::VF)::F
	λ = p -> p > zero(F) ? -p * log(p) / log(2.) : zero(F)
	sum(λ.(class_prob))
end

# ╔═╡ dc209b9a-8915-11eb-0f63-ab3b7c33793c
begin
	@test entropy([1.]) ≈ 0.        # minimal entropy (max. certainty)
	@test entropy([.5, .5]) ≈ 1.    # maximal entropy for 2 classes
	@test 0.81 < entropy([.25, .75]) < 0.82
 end

# ╔═╡ d7aade44-891b-11eb-00d3-abe7406c4b09
md"""
Our data will consist of pairs(input, label) for which we will need to compute the class probabilities.
"""

# ╔═╡ 9ae99efe-891c-11eb-3d1f-89182e3f9ff8
begin
	function counter(labels::VT)::Dict{T, Integer}
		h = Dict{T, Integer}()
		for v ∈ labels
			h[v] = get(h, v, 0) + 1
		end
		h
	end
	
	function class_prob(labels::VT)::VF
		@assert length(labels) > 0
		tot_cnt = length(labels)
		[cnt / tot_cnt for cnt ∈ values(counter(labels))]
	end
	
	function data_entropy(labels::VT)::F
		class_prob(labels) |> entropy
	end
end

# ╔═╡ ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
begin
	@test data_entropy(["a"]) ≈ 0. # == 0.
	@test data_entropy([:a]) ≈ 0.
	@test data_entropy([:b, :a, :b]) ≈ entropy([1. / 3., 2. / 3.])
	@test data_entropy([true, false]) == 1.
	@test data_entropy([2, 1, 2, 2]) == entropy([0.25, 0.75])
end

# ╔═╡ dc0c5a5e-8915-11eb-2c62-5328b42add69
html"""
<p style="text-align: right;">
  <a id='entroyp-partition'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ dbefe77a-8915-11eb-39f1-5d0c84729739
md"""
### Entropy Partition

Mathematically, if we split our data S into partitions S₁, ...Sₘ containing proportions q₁, ...qₘ of the data, then we compute the entropy of the partition as a weighted sum:

$$H = \sum_{i=1}^m q_i \times H(S_i)$$
"""

# ╔═╡ dbd86924-8915-11eb-351f-8362f09ba984
function partition_entropy(subsets::Vector{VT})::F
	"""Given the partition into subsets, calc. its entropy"""
	tot_cnt = sum(length.(subsets))
	λ = s -> data_entropy(s) * length(s) / tot_cnt
	sum(λ.(subsets))
end

# ╔═╡ d32b86e0-8928-11eb-193c-e3d7c85d23dd
begin
	a_ = BitArray{1}[[1, 1, 1, 1], [0, 0, 0, 1, 1], [1, 1, 0, 1, 0]]
	typeof(a_)
 	# partition_entropy(a_)
end

# ╔═╡ 98dbf98a-8a99-11eb-269e-3f6a5b3cd8c3
# typeof(a_) <: AbstractVector{AbstractVector{T}} where {T <: Any}

# BitArray <: AbstractArray  # true

AbstractVector{BitArray} <: AbstractVector{AbstractArray}

# ╔═╡ dbbf22a2-8915-11eb-00eb-4b0278c0283d
html"""
<p style="text-align: right;">
  <a id='creating-dt'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

## ================================

# ╔═╡ 5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
md"""
### Creating our DT
"""

# ╔═╡ 073f6442-892e-11eb-0fc2-bbeb1d12619e
struct Candidate
	level::Symbol
	lang::Symbol
	tweets::Bool
	phd::Bool
	did_well::Union{Nothing, Bool}
end

# ╔═╡ 2ec41c48-8a95-11eb-13b6-61f4a07a31db
inputs = [ 
	Candidate(:Senior, :Java,   false, false, false),
	Candidate(:Senior, :Java,   false, true,  false),
	Candidate(:Mid,    :Python, false, false, true),
	Candidate(:Junior, :Python, false, false, true),
	Candidate(:Junior, :R,      true,  false, true),
	Candidate(:Junior, :R,      true,  true,  false),
	Candidate(:Mid,    :R,      true,  true,  true),
	Candidate(:Senior, :Python, false, false, false),
	Candidate(:Senior, :R,      true,  false, true),
	Candidate(:Junior, :Python, true,  false, true),
	Candidate(:Senior, :Python, true,  true,  true),
	Candidate(:Mid,    :Python, false, true,  true),
	Candidate(:Mid,    :Java,   true,  false, true),
	Candidate(:Junior, :Python, false, true,  false)
]

# ╔═╡ 25fb8f9a-8952-11eb-35bb-b173ac466835
md"""
We will build a decision tree (DT) following ID3 algorithm, which works as follows:
  - if the data have all the same label, create a leaf node that predicts that label and stops.
  - if the list of attributes is empty (*i.e* no more questions to split the data on), create a leaf that predicts the most common lable and stops
  - otherwise try partitionning the data by each of the attributes
  - Choose the partition with the lowest entropy
  - Add a decision node based on the chosen attribute
  - Using the remaining attributes, recursively apply previous steps on each subset

First let's go manually through those steps using our toy dataset.
"""

# ╔═╡ 65ec8554-8953-11eb-3973-b56039754312
function partition_by(inputs::VT, attr::Symbol)::Dict{T, VT}
	part = Dict{T, VT}()
	for inp ∈ inputs
		key = getfield(inp, attr)
		part[key] = push!(get(part, key, []), inp)
	end
	part
end

# ╔═╡ 0c8055b8-89b2-11eb-3046-331119a0dc9b
function partition_entropy_by(inputs::VT, attr::Symbol, label::Symbol)::F
	"""Given the partition, calc. its entropy"""
	parts = partition_by(inputs, attr)
	@show parts
	
	λ = inp -> getfield(inp, label)
	labels = [λ.(p) for p ∈ values(parts)]
	println("FOUND: $(labels) / $(typeof(labels))")
	# partition_entropy(labels)
	0.
end

# ╔═╡ fded51da-8a98-11eb-1cff-b34716e09a75


# ╔═╡ d728d526-8956-11eb-3c22-e788d025e8b4
with_terminal() do
	
	for key ∈ fieldnames(Candidate)[1:end-1]
		r = partition_entropy_by(inputs, key, :did_well)
		# r = 0
		println("$(key) => $(r)")
	end
end

# ╔═╡ 17768334-8a98-11eb-1172-3d5079435dcf
fieldnames(Candidate)[1:end-1]

# ╔═╡ ad388bba-8955-11eb-34ee-4db60fb0db8a
md"""
Generate predictions
"""

# ╔═╡ ad036de6-89b1-11eb-3973-b56039754312
# code for predictions

## ================================

# ╔═╡ dba976a2-8915-11eb-0ff0-b38952cbc38b
md"""
This gives 84 true positives (spam classified as “spam”), 25 false positives (ham
classified as “spam”), 703 true negatives (ham classified as “ham”), and 44 false
negatives (spam classified as “ham”). This means our precision is 84 / (84 + 25) =
77%, and our recall is 84 / (84 + 44) = 65%, which are not bad numbers for such a
simple model. (Presumably we’d do better if we looked at more than the subject
lines.)
"""

# ╔═╡ ca91a0d6-8915-11eb-36cc-a18fc8efaf40
# p_spam_given_token


# ╔═╡ 194958a6-89b4-11eb-3340-337957fd81b7
md"""
The spammiest words include things like sale, mortgage, money, and rates...
"""

# ╔═╡ fa1fe202-89b7-11eb-34ee-4db60fb0db8a
md"""
using stemmer...
"""

# ╔═╡ 432cd594-89b9-11eb-2d4a-6f46f08a511d
html"""
<p style="text-align: right;">
  <a id='all-together'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 48db121e-8a8e-11eb-189f-d9f41e4b1d9d
md"""
### Putting it all Together

"""

# ╔═╡ 48ba469c-8a8e-11eb-0016-d784d1f60eb0


# ╔═╡ 4891273a-8a8e-11eb-32a5-5b7fb191b833


# ╔═╡ Cell order:
# ╟─87e5e2ec-8915-11eb-362b-6bf13a36b8e4
# ╠═5eebac68-891b-11eb-37ba-c1d9481c6134
# ╠═8e2aca8e-8a8f-11eb-1e68-1316740f4697
# ╟─cb25501a-8915-11eb-3626-a1ae6d233f92
# ╟─cb0838ae-8915-11eb-082f-3991192a101f
# ╟─caf03ada-8915-11eb-2935-01e110accba6
# ╟─cad66356-8915-11eb-0173-ada200678f63
# ╠═dc3b7280-8915-11eb-258a-1789476897b9
# ╠═dc209b9a-8915-11eb-0f63-ab3b7c33793c
# ╟─d7aade44-891b-11eb-00d3-abe7406c4b09
# ╠═9ae99efe-891c-11eb-3d1f-89182e3f9ff8
# ╠═ea1f4a2c-891d-11eb-3027-bd447dd9d1e1
# ╟─dc0c5a5e-8915-11eb-2c62-5328b42add69
# ╟─dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╠═d32b86e0-8928-11eb-193c-e3d7c85d23dd
# ╠═98dbf98a-8a99-11eb-269e-3f6a5b3cd8c3
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╟─5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═2ec41c48-8a95-11eb-13b6-61f4a07a31db
# ╟─25fb8f9a-8952-11eb-35bb-b173ac466835
# ╠═65ec8554-8953-11eb-3973-b56039754312
# ╠═0c8055b8-89b2-11eb-3046-331119a0dc9b
# ╠═fded51da-8a98-11eb-1cff-b34716e09a75
# ╠═d728d526-8956-11eb-3c22-e788d025e8b4
# ╠═17768334-8a98-11eb-1172-3d5079435dcf
# ╠═ad388bba-8955-11eb-34ee-4db60fb0db8a
# ╟─ad036de6-89b1-11eb-3973-b56039754312
# ╟─dba976a2-8915-11eb-0ff0-b38952cbc38b
# ╠═ca91a0d6-8915-11eb-36cc-a18fc8efaf40
# ╠═194958a6-89b4-11eb-3340-337957fd81b7
# ╠═fa1fe202-89b7-11eb-34ee-4db60fb0db8a
# ╟─432cd594-89b9-11eb-2d4a-6f46f08a511d
# ╟─48db121e-8a8e-11eb-189f-d9f41e4b1d9d
# ╠═48ba469c-8a8e-11eb-0016-d784d1f60eb0
# ╠═4891273a-8a8e-11eb-32a5-5b7fb191b833
