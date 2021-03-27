### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
  	using Pkg; Pkg.activate("MLJ_env", shared=true)
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
	λ = p -> p > zero(F) ? -p * log(2, p) : zero(F)
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

# ╔═╡ 13e3ccb6-8aae-11eb-3a9e-85b5afc74097
 class_prob([1, 1, 1, 1, 1])

# ╔═╡ 13c729da-8aae-11eb-29aa-b171020ad8dd
class_prob([0, 0, 0, 1, 1]), class_prob([1, 1, 0, 1, 0])

# ╔═╡ 13b2940c-8aae-11eb-2dd2-8dec30dd4881
data_entropy([0, 0, 0, 1, 1]), data_entropy([1, 1, 0, 1, 0])

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
	# @show subsets
	tot_cnt = sum(length.(subsets))
	# @show tot_cnt
	λ = s -> data_entropy(s) * length(s) / tot_cnt
	sum(λ.(subsets))
end

# ╔═╡ d32b86e0-8928-11eb-193c-e3d7c85d23dd
begin
	a_ = BitArray{1}[[1, 1, 1, 1], [0, 0, 0, 1, 1], [1, 1, 0, 1, 0]]
 	@test abs(partition_entropy(VT[a_...]) - 0.69353613) ≤ 1e-6 
end

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
begin
const NB = Union{Nothing, Bool}

struct Candidate
	level::Symbol
	lang::Symbol
	tweets::Bool
	phd::Bool
	did_well::NB
	function Candidate(level::Symbol, lang::Symbol, tweets::Bool, phd::Bool, did_well::NB=nothing)
		new(level, lang, tweets, phd, did_well)
	end
end
	
end

# ╔═╡ 2ec41c48-8a95-11eb-13b6-61f4a07a31db
inputs = [
	#         level    lang     tweets phd    did_well                  
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
];

# ╔═╡ 25fb8f9a-8952-11eb-35bb-b173ac466835
md"""
We will build a decision tree (DT) following ID3 algorithm, which works as follows:
  - if the data have all the same label, create a leaf node that predicts that label and stops.
  - if the list of attributes is empty (*i.e* no more questions to split the data on), create a leaf that predicts the most common lable and stops
  - otherwise try partitionning the data by each of the attributes
  - choose the partition with the lowest entropy
  - add a decision node based on the chosen attribute
  - using the remaining attributes, recursively apply previous steps on each subset

First let's go manually through those steps using our toy dataset.
"""

# ╔═╡ 045023be-8aac-11eb-29c1-3f4da066ff9b
## Tuple
fieldnames(Candidate)[1:end-1]

# ╔═╡ b1c0a416-8aba-11eb-140a-9f3c4eb93346
## Vector
Symbol[fieldnames(Candidate)[1:end-1]...]

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
function partition_entropy_by(inputs::VT, attr::Symbol, label_attr::Symbol)::F
	"""Given the partition, calc. its entropy"""
	parts = partition_by(inputs, attr)
	# @show(parts, attr) 
	# println("-----------------------")
	
	λ = inp -> getfield(inp, label_attr)
	labels = [λ.(p) for p ∈ values(parts)]
	# @show(labels)
	# println("-----------------------")
	
	partition_entropy(VT[labels...])
end

# ╔═╡ d728d526-8956-11eb-3c22-e788d025e8b4
with_terminal() do
	for key ∈ fieldnames(Candidate)[1:end-1]
		r = partition_entropy_by(inputs, key, :did_well)
		println("$(key) => $(r)")
	end
end

# ╔═╡ 17768334-8a98-11eb-1172-3d5079435dcf
begin
	@test 0.69 ≤ partition_entropy_by(inputs, :level, :did_well) < 0.7
	@test 0.86 ≤ partition_entropy_by(inputs, :lang, :did_well) < 0.87
	@test 0.78 ≤ partition_entropy_by(inputs, :tweets, :did_well) < 0.79
	@test 0.89 ≤ partition_entropy_by(inputs, :phd, :did_well) < 0.90
end

# ╔═╡ 8365f5cc-8aaf-11eb-1928-b3a201b840a0
begin
	senior_inputs = filter(c -> getfield(c, :level) == :Senior, inputs)
	
	@test partition_entropy_by(senior_inputs, :lang, :did_well) ≈ 0.4
	@test partition_entropy_by(senior_inputs, :tweets, :did_well) ≈ 0.0
	@test 0.95 ≤ partition_entropy_by(senior_inputs, :phd, :did_well) ≤ 0.96
end

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
md"""
We are going to define out tree as either:
  - a :leaf that predicts a single value xor
  - a :split containing an attribute to split on, subtrees for specific values of that attribute and possibly a default value (if we see an unknown value)
"""

# ╔═╡ 704c988e-8ab3-11eb-2882-7bdab634fdb4
struct Leaf
	value::T
end

# ╔═╡ 702fd9e2-8ab3-11eb-0ac9-590fd1e3ca02
struct Split
	attr::Symbol
	subtrees::Dict
	defval::T
end

# ╔═╡ 7014500a-8ab3-11eb-13bc-69adb8a72f13
const DT = Union{Leaf, Split}

# ╔═╡ 6ff9bd6c-8ab3-11eb-1346-f1b274ec7283
function classify(dt::DT, input::T)::T
	"""
	Classify given input using given decision tree (dt)
	"""
	typeof(dt) == Leaf && (return dt.value)

	## Otherwise this tree consists of an attr to split on and a 
	## dictionary whose keys are values of that attribute and whose
	## values are subtrees to consider next
	sdt_key = getfield(input, dt.attr)

	if !haskey(dt.subtrees, sdt_key)
		return dt.defval       ## no subtree for key => default value 
	end	

	sdt = dt.subtrees[sdt_key] ## choose appropriate subtree and
	classify(sdt, input)       ## use it to classify the input
end

# ╔═╡ 6fdb83ce-8ab3-11eb-03a2-bf78a195426b
function build_tree_id3(inputs::VT, split_attrs::Vector{Symbol}, 
		target::Symbol)::DT
	λ₁ = inp -> getfield(inp, target)
	label_cnt = λ₁.(inputs) |> counter

	most_common_label = reduce((m, x) -> m = x[2] > m[2] ? x : m, label_cnt;
		init=(nothing, -1))[1]
	# sort(collect(label_cnt), by=t -> t[2], rev=true)[1][1] 

	## If unique label, predict it
	length(label_cnt) == 1 && (return Leaf(most_common_label))

	## no split attributes left => return the majority label
	length(split_attrs) == 0 && (return Leaf(most_common_label))

	## otherwise split by best attribute
	best_attr = reduce(
		(t_attr, c_attr) -> (p = partition_entropy_by(inputs, c_attr, target); 
		t_attr = p < t_attr[2] ? (c_attr, p) : t_attr), split_attrs; 
		init=(nothing, Inf)
	)[1]

	parts = partition_by(inputs, best_attr)
	new_attrs = filter(a -> a ≠ best_attr, split_attrs)

	## Recursively build the subtrees
	subtrees = Dict(attr_val => build_tree_id3(subset, new_attrs, target) 
		for (attr_val, subset) ∈ parts)

	return Split(best_attr, subtrees, most_common_label)
end

# ╔═╡ f21e8240-8ab9-11eb-1223-cbc0f2b1aa8c
dtree = build_tree_id3(inputs, Symbol[fieldnames(Candidate)[1:end-1]...], :did_well)

# ╔═╡ 4891273a-8a8e-11eb-32a5-5b7fb191b833
@test classify(dtree, Candidate(:Junior, :Java, true, false))
## Should predict true

# ╔═╡ 2a823d90-8abd-11eb-0e52-d53dfd7d28af
@test !classify(dtree, Candidate(:Junior, :Java, true, true))
## Should predict false

# ╔═╡ 2a68888e-8abd-11eb-396d-2dbac68b7419
@test classify(dtree, Candidate(:Intern, :Java, true, true))
## Should predict true - :Intern is unknwon to decison tree

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
# ╠═13e3ccb6-8aae-11eb-3a9e-85b5afc74097
# ╠═13c729da-8aae-11eb-29aa-b171020ad8dd
# ╠═13b2940c-8aae-11eb-2dd2-8dec30dd4881
# ╟─dc0c5a5e-8915-11eb-2c62-5328b42add69
# ╟─dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╠═d32b86e0-8928-11eb-193c-e3d7c85d23dd
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╟─5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═2ec41c48-8a95-11eb-13b6-61f4a07a31db
# ╟─25fb8f9a-8952-11eb-35bb-b173ac466835
# ╠═045023be-8aac-11eb-29c1-3f4da066ff9b
# ╠═b1c0a416-8aba-11eb-140a-9f3c4eb93346
# ╠═65ec8554-8953-11eb-3973-b56039754312
# ╠═0c8055b8-89b2-11eb-3046-331119a0dc9b
# ╠═d728d526-8956-11eb-3c22-e788d025e8b4
# ╠═17768334-8a98-11eb-1172-3d5079435dcf
# ╠═8365f5cc-8aaf-11eb-1928-b3a201b840a0
# ╟─432cd594-89b9-11eb-2d4a-6f46f08a511d
# ╟─48db121e-8a8e-11eb-189f-d9f41e4b1d9d
# ╟─48ba469c-8a8e-11eb-0016-d784d1f60eb0
# ╠═704c988e-8ab3-11eb-2882-7bdab634fdb4
# ╠═702fd9e2-8ab3-11eb-0ac9-590fd1e3ca02
# ╠═7014500a-8ab3-11eb-13bc-69adb8a72f13
# ╠═6ff9bd6c-8ab3-11eb-1346-f1b274ec7283
# ╠═6fdb83ce-8ab3-11eb-03a2-bf78a195426b
# ╠═f21e8240-8ab9-11eb-1223-cbc0f2b1aa8c
# ╠═4891273a-8a8e-11eb-32a5-5b7fb191b833
# ╠═2a823d90-8abd-11eb-0e52-d53dfd7d28af
# ╠═2a68888e-8abd-11eb-396d-2dbac68b7419
