### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ e704feae-919c-11eb-35ea-0932dbb413dd
begin
	using Pkg; Pkg.activate("MLJ_env", shared=true)
	# Pkg.add("StatsBase")
	# Pkg.add("BenchmarkTools");

	using StatsBase
	using BenchmarkTools
	using Test
	using Random
	using PlutoUI
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Finding index of a random minimum element in an array

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)

**Context**
In many applications, we need to find the index of the minimum element of some array. The built-in argmin function which is designed to perform this task returns the index of the minimum element in a collection. However, if there are multiple minimal elements, only the first one is returned. 
There are situations when we need to get all the indices of a minimal element or a single index is chosen uniformly at random from this set. 

Let us implement such a function in two ways.
"""

# ╔═╡ e849191c-919c-11eb-0d04-b9ec7a4ac478
function all_argmin(ary::AbstractArray)::Vector{Integer}
	@assert length(ary) > 0
	m = minimum(ary)
	filter(ix -> ary[ix] == m, eachindex(ary))
end

# ╔═╡ 08f24660-919e-11eb-37c9-155375b48cf4
rand_argmin₁(ary::AbstractArray)::Integer = all_argmin(ary) |> rand

# ╔═╡ 61c23c88-919d-11eb-0d37-23783e1fd854
begin
	@test_throws AssertionError all_argmin([])
	
	x = [3, 2, 1, 4, 1, 2, 3, 4, 4, 3, 2, 1, 2, 1, 3, 4]
	@test all_argmin([10, 10, 1, 2, 3, 5, 10]) == [3]
	@test all_argmin(x) == [3, 5, 12, 14]

	n = 10^6
	f = n ÷ 4
	@test rand_argmin₁([10, 10, 1, 2, 3, 5, 10]) == 3
	
	## 10^6 samples - should be roughly equally distributed 1/4 as x has f
	## our 1 (min element)
	@test all(map(p -> abs(p[2] - f) ≤ 1200, 
			countmap([rand_argmin₁(x) for _ ∈1:10^6]) |> collect))
end

# ╔═╡ 4f47a640-919f-11eb-0072-e9855b338704
md"""
Let us define a more efficient (and generic function).
"""

# ╔═╡ 67982c78-91a0-11eb-29d7-613d4624cf20
function rand_argmin₂(ary::AbstractArray)::Integer
	indices = eachindex(ary)     ## take into account cartesian and linear indexing
	y = iterate(indices)
	y === nothing && throw(ArgumentError("collection must be non-empty"))

	(ix, state) = y              ## first elem iof iteratble, state
	minval, best_ix, best_cnt = ary[ix], ix, 1
	y = iterate(indices, state)
	while y !== nothing
		(ix, state) = y 
		curval = ary[ix]

		if isless(curval, minval)    ## isless moree genral than <
			minval, best_ix = curval, ix
			best_cnt = 1             ## reset 

		elseif isequal(curval, minval)
			best_cnt += 1
			## updated prob. of choosing this ix:
			rand() * best_cnt < 1. && (best_ix = ix)

		end
		y = iterate(indices, state)
	end
	best_ix
end

# ╔═╡ 56c60dc2-91a3-11eb-301d-1d0ce38e5cfa
md"""
Notes:
  - `y === nothing`       faster than `isnothing(y)`
  - `while y !== nothing` faster than `while !isnothing(y)`
"""

# ╔═╡ 3a4d6e52-91a2-11eb-0b87-bdc9ff551759
Random.seed!(42)

# ╔═╡ 89cfa838-91a1-11eb-2753-1d838efe223c
(countmap([rand_argmin₁(x) for _ ∈ 1:10^6]), 
	countmap([rand_argmin₂(x) for _ ∈ 1:10^6]))

# ╔═╡ 4cc66048-91a2-11eb-2bf3-5b39967d17bb
begin
	const y = rand(1:1000, 10_000)
	
	with_terminal() do
		@btime rand_argmin₂(y)

		@btime rand_argmin₁(y)
	end
end

# ╔═╡ a15a8f10-91a4-11eb-3489-45611ec3c9d1
md"""
**Comments**

if we encounter a new minimum value, we simply store it. The challenge is what to do if we encounter a minimal element more than once. 
Assume that we have already seen some element best_cnt times. A variable best_ix, with probability 1. / best_cnt, holds each previously encountered minimal index. 
If we encounter a new index ix for which a[ix] is equal to the current minimum minval, then in the code with probability 1., / (bestcnt + 1), we set best_ix to this value. This means that this new value has the correct probability of being stored. 
Also, notice that all earlier values have the following probability of being stored:

$$\frac{1.}{bestcnt} × \frac{bestcnt}{(bestcnt + 1)} = \frac{1.}{(bestcnt + 1)}$$

This means that, ultimately, our algorithm properly randomizes the choice of the returned index.

The second challenge is related to the fact that Julia features many different types of collections that can be efficiently accessed using different indexing, for example, linear indexing or Cartesian indexing. 

Therefore, in the code, we traverse a collection of indices into `ary`, returned by `eachindex(ary)`, using an iteration protocol. The protocol is based on the `iterate` function. If we pass an iterable to this function (for example, iterate(indices)), it returns a tuple containing the following:
  - The first element of the iterable
  - A state variable that can be used in subsequent calls

Then, we can iterate over the collection by passing two arguments to iterate — a collection and an earlier returned state. Finally, we know that we have reached the end of the collection if iterate returns nothing.

Note that we have iterated over `eachindex(ary)` and not over `ary`, since we needed to work with the indices of collection a rather than the values contained in it.
"""

# ╔═╡ 9d3d8f1c-91a5-11eb-3f37-79ae44a88223
md"""
We use the `isless` and `isequal` functions in tests and not the `<` and `== ` functions. The main reason for this is that `isless` and `isequal` guarantee to always return a `Bool` result while `<` and `==`  can return missing when one of their arguments is missing. 

Additionally, there are subtle differences between those functions when comparing `0.0` and `-0.0` and `NaN`:
"""

# ╔═╡ d73c9186-91a5-11eb-2bce-47367fc9522e
(.0 == -.0, -.0 < .0), (isequal(.0, -.0), isless(-.0, .0))

# ╔═╡ eda015e2-91a5-11eb-32af-2778d08859ed
(NaN == NaN, NaN < NaN), (isequal(NaN, NaN), isless(NaN, NaN))

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╠═e704feae-919c-11eb-35ea-0932dbb413dd
# ╠═e849191c-919c-11eb-0d04-b9ec7a4ac478
# ╠═08f24660-919e-11eb-37c9-155375b48cf4
# ╠═61c23c88-919d-11eb-0d37-23783e1fd854
# ╟─4f47a640-919f-11eb-0072-e9855b338704
# ╠═67982c78-91a0-11eb-29d7-613d4624cf20
# ╟─56c60dc2-91a3-11eb-301d-1d0ce38e5cfa
# ╠═3a4d6e52-91a2-11eb-0b87-bdc9ff551759
# ╠═89cfa838-91a1-11eb-2753-1d838efe223c
# ╠═4cc66048-91a2-11eb-2bf3-5b39967d17bb
# ╟─a15a8f10-91a4-11eb-3489-45611ec3c9d1
# ╟─9d3d8f1c-91a5-11eb-3f37-79ae44a88223
# ╠═d73c9186-91a5-11eb-2bce-47367fc9522e
# ╠═eda015e2-91a5-11eb-32af-2778d08859ed
