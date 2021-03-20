### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 5eebac68-891b-11eb-37ba-c1d9481c6134
begin
	using Test
	using Random
	using RDatasets
	using DataFrames
	using Plots
	# using Gadfly
	
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
	const VF = AbstractVector{T} where T <: AbstractFloat

	struct LabeledPoint
		point::VF
		label::Symbol
	
		LabeledPoint(point::VF, sym::Symbol) = new(point, sym)
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

We will use the Iris dataset which is kind of the "hello wolrd" of machine learning. It contains a set of measurements for 150 flowers representing three species of iris. For each flower we have its petal length, petal width, sepal length, and sepal width,
as well as its species.
"""

# ╔═╡ dbd86924-8915-11eb-351f-8362f09ba984
begin
	iris_ds = dataset("datasets", "iris");
	DataFrames.describe(iris_ds, :eltype, :first => first)
end

# ╔═╡ d32b86e0-8928-11eb-193c-e3d7c85d23dd
measurements_mx = convert(Matrix, select(iris_ds, Not(:Species)))

# ╔═╡ d2d8c676-8928-11eb-2e4a-557f5f9fa1c3
begin
	# [row[1:end] for row ∈ eachrow(measurements)] # copy => Vector{Vector}... slow
	# Vector{Float64}[row for row ∈ eachrow(measurements)] # view
	measurements = [row[1:end] for row ∈ eachrow(measurements_mx)]
	labels = Symbol.(iris_ds[!, :Species])
	iris_data = [
		LabeledPoint(p, l) for (p, l) ∈ zip(measurements, labels)
	]
	N = length(iris_data);
end

# ╔═╡ 9eb1ef78-8953-11eb-3046-331119a0dc9b
@test N == size(iris_ds)[1]

# ╔═╡ 5809f59e-8916-11eb-1c09-6fa00c043e7a
md"""
let us start with some visual exploration
"""

# ╔═╡ 4ffc3b48-895a-11eb-1ed2-f78b522d0ae9
begin
	points_by_species = Dict{Symbol, Vector{VF}}()
	for iris ∈ iris_data
		ary = get(points_by_species, iris.label, VF[])
		push!(ary, iris.point)
		points_by_species[iris.label] = ary
	end
	points_by_species
end

# ╔═╡ 90f58d04-8958-11eb-170e-0f17904c9f2c
begin
	metrics = names(iris_ds)[1:end-1]
	pairs = [(i, j) for i ∈ 1:4 for j ∈ (i+1):4]
	marks = [:v, :o, :^] # we have 3 classes, so 3 markers
	ps = []
	for row ∈ 1:2, col ∈ 1:3
		i, j = pairs[3 * (row - 1) + col]
		k = 0
		for (mark, (species, points)) ∈ zip(marks, points_by_species)
			xs = [p[i] for p ∈ points]
			ys = [p[j] for p ∈ points]
			if k % 3 == 0
				push!(ps, scatter(xs, ys, marker=mark,
						label=string(species),
						legend=false,
						titlefontsize=8, title="$(metrics[i]) vs $(metrics[j])"))
			elseif row == 2 && col == 3
				ps[end] = scatter!(xs, ys, marker=mark,
					label=string(species),
					legendfontsize=6,
					legend=:bottomright)
			else
				ps[end] = scatter!(xs, ys, marker=mark, label=string(species))
			end
			k += 1
		end
	end
end

# ╔═╡ 90d83cae-8958-11eb-2d5c-bd298437f953
begin
	lg = grid(2, 3, widths=[0.33, 0.33, 0.33], heights=[0.5, 0.5, 0.5])
	plot(ps..., layout=lg)
end


# ╔═╡ ab9ac56e-8969-11eb-3340-337957fd81b7
md"""
The measurement seem to really cluster by species. Looking at sepal length vs sepal width alone (top left graph) does not allow for a clean spearation between versiclor and virgina, but adding petal length and width help in the separation. Our nearest neighbors should be able to predict the species. Let us see...
"""

# ╔═╡ 5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
names(iris_ds)

# ╔═╡ 073f6442-892e-11eb-0fc2-bbeb1d12619e
function train_test_split(ds::Vector{LabeledPoint};
		split=0.8, seed=42, shuffled=true)
	Random.seed!(seed)
	nr = length(ds)
	row_ixes = shuffled ? shuffle(1:nr) : collect(1:nr)
	nrp = round(Int, length(row_ixes) * split)
	(ds[row_ixes[1:nrp]], ds[row_ixes[nrp+1:nr]])
end

# ╔═╡ 25fb8f9a-8952-11eb-35bb-b173ac466835
iris_train, iris_test = train_test_split(iris_data; split=0.70)

# ╔═╡ 65ec8554-8953-11eb-3973-b56039754312
begin
	@test length(iris_train) == round(Int, 0.7 * N)
	@test length(iris_test) == round(Int, (1 - 0.7) * N)
end

# ╔═╡ 0c8055b8-89b2-11eb-3046-331119a0dc9b
length(iris_test)

# ╔═╡ d728d526-8956-11eb-3c22-e788d025e8b4
function run_knn(iris_train, iris_test; k=5)
	num_correct = 0
	confusion_matrix = Dict{Tuple{Symbol, Symbol}, Integer}()
	for iris ∈ iris_test
		ŷ = knn(k, iris_train, iris.point)
		y = iris.label
		ŷ == y && (num_correct += 1)
		confusion_matrix[(ŷ, y)] = get(confusion_matrix, (ŷ, y), 0) + 1
	end
	perc_correct = num_correct / length(iris_test)
	(perc_correct, confusion_matrix)
end

# ╔═╡ ad388bba-8955-11eb-34ee-4db60fb0db8a
perc_correct, confusion_matrix = run_knn(iris_train, iris_test)

# ╔═╡ ad036de6-89b1-11eb-3973-b56039754312
md"""
Not bad, we have two mis-matches: versicolor/virginica (and conversely), otherwise the rest looks good.
"""

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

The k-nearest neighbors algorithm has problems in high dimensions due to a phenomena called the “curse of dimensionality”.
In a nutshell high-dimensional spaces are large (tautology) and points in such high-dimensional spaces tend to be far to one another. 

One way to see this is by randomly generating pairs of points in a n-dimensional “unit cube” varying the dimensions and calculating the distances between them.
"""

# ╔═╡ ca91a0d6-8915-11eb-36cc-a18fc8efaf40
random_point(n::Integer) = rand(Float64, n)

# ╔═╡ 194958a6-89b4-11eb-3340-337957fd81b7
function random_distances(dim::Integer, num_pairs::Integer)
	[distance(random_point(dim), random_point(dim)) for _ ∈ 1:num_pairs]
end

# ╔═╡ fa1fe202-89b7-11eb-34ee-4db60fb0db8a
begin
	const NS = 100
	const M = 10_000
	avg_dist, min_dist, min_avg_ratio = [], [], []
	Random.seed!(42)
	for dim ∈ 1:NS
		d = random_distances(dim, M)
		sum_d, min_d = sum(d) / M, minimum(d)
		push!(avg_dist, sum_d)
		push!(min_dist, min_d)
		push!(min_avg_ratio, min_d / sum_d);
	end
	# avg_dist, min_dist, min_avg_ratio;
end

# ╔═╡ 432cd594-89b9-11eb-2d4a-6f46f08a511d
begin
	plot(1:NS, avg_dist, legendfontsize=7, legend=:topleft,
		label="avg. dist.",
		title="$(M) random distances",
		titlefontsize=9,
		xlabel="# of dimensions"
	)
	plot!(1:NS, min_dist, label="min. dist.")
end

# ╔═╡ d0692f3c-89bb-11eb-2c0b-15edb9044d52
plot(1:NS, min_avg_ratio, legend=false, xlabel="# of dimensions",
	title="min. dist. / avg. dist.",
	titlefontsize=9)

# ╔═╡ 2ddeec6c-89bc-11eb-0796-f7dc9885b0de
md"""
In low-dimensional datasets, the nearest points tend to be much closer than
average.

The closeness of two points depends on how close thes points are in each dimension and note that every extra dimension is an opportunity for each point to be farther away from each other.

Thus when we have a lot of dimensions, the likelihood is that the closest points are not much closer than average (unless there is a lot of structure in the data)...
"""

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
# ╟─dbefe77a-8915-11eb-39f1-5d0c84729739
# ╠═dbd86924-8915-11eb-351f-8362f09ba984
# ╠═d32b86e0-8928-11eb-193c-e3d7c85d23dd
# ╠═d2d8c676-8928-11eb-2e4a-557f5f9fa1c3
# ╠═9eb1ef78-8953-11eb-3046-331119a0dc9b
# ╟─5809f59e-8916-11eb-1c09-6fa00c043e7a
# ╠═4ffc3b48-895a-11eb-1ed2-f78b522d0ae9
# ╠═90f58d04-8958-11eb-170e-0f17904c9f2c
# ╠═90d83cae-8958-11eb-2d5c-bd298437f953
# ╟─ab9ac56e-8969-11eb-3340-337957fd81b7
# ╠═5f5e6d02-892a-11eb-32d8-dfc1a7f259fa
# ╠═073f6442-892e-11eb-0fc2-bbeb1d12619e
# ╠═25fb8f9a-8952-11eb-35bb-b173ac466835
# ╠═65ec8554-8953-11eb-3973-b56039754312
# ╠═0c8055b8-89b2-11eb-3046-331119a0dc9b
# ╠═d728d526-8956-11eb-3c22-e788d025e8b4
# ╠═ad388bba-8955-11eb-34ee-4db60fb0db8a
# ╟─ad036de6-89b1-11eb-3973-b56039754312
# ╟─dbbf22a2-8915-11eb-00eb-4b0278c0283d
# ╟─dba976a2-8915-11eb-0ff0-b38952cbc38b
# ╠═ca91a0d6-8915-11eb-36cc-a18fc8efaf40
# ╠═194958a6-89b4-11eb-3340-337957fd81b7
# ╠═fa1fe202-89b7-11eb-34ee-4db60fb0db8a
# ╠═432cd594-89b9-11eb-2d4a-6f46f08a511d
# ╠═d0692f3c-89bb-11eb-2c0b-15edb9044d52
# ╟─2ddeec6c-89bc-11eb-0796-f7dc9885b0de
