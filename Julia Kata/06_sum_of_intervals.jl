### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 5bd9e6aa-6820-11eb-2b20-3f17c0045841
begin
	using Test
	using BenchmarkTools
	using PlutoUI
end

# ╔═╡ 19046b20-6820-11eb-3fac-e993b8847dc0
md"""
### Sum of Intervals


Write a function called `sum_intervals()` that accepts an array of intervals, and returns the sum of all the interval lengths. Overlapping intervals should only be counted once.

**Intervals**:  

Intervals are represented by a pair of integers in the form of a tuple. The first value of the interval will always be less than the second value. Interval example: `(1, 5)` is an interval from 1 to 5. The length of this interval is 4.


**Overlapping Intervals**:  

List containing overlapping intervals:

```julia
[
  (1, 4),
  (7, 10),
  (3, 5)
]
```


The sum of the lengths of these intervals is 7. Since `(1, 4)` and `(3, 5)` overlap, we can treat the interval as `(1, 5)`, which has a length of 4.


**Examples**:  

```julia
sum_intervals([
   (1, 2),
   (6, 10),
   (11, 15)
]); # => 9

sum_intervals([
   (1, 4),
   (7, 10),
   (3, 5)
]); # => 7

sum_intervals([
   (1, 5),
   (10, 20),
   (1, 6),
   (16, 19),
   (5, 11)
]); # => 19
```
"""

# ╔═╡ 698441e4-6820-11eb-2ed2-e90fbf53d7f0
md"""
#### Defining a parametric type
"""

# ╔═╡ 7da89592-6820-11eb-0ad7-699807d1d952
struct Interval{T <: Integer}
    lb::T  # lower bound
    ub::T  # upper bound

    function Interval{T}(lb, ub) where {T <: Integer}
		(lb, ub) = lb > ub ? (ub, lb) : (lb, ub)
		@assert 0 ≤ lb ≤ ub
		new(lb, ub)
	end
end

# ╔═╡ 9e07bbc4-6820-11eb-07ca-77f29e8a3030
IntervInt64 = Interval{Int64}

# ╔═╡ b9125d20-6820-11eb-3773-07dd4728988d
interv0 = IntervInt64(3, 1)

# ╔═╡ f6264b68-6820-11eb-1fc4-afcb22381c09
md"""
##### Length of an Interval
"""

# ╔═╡ 1640dbfe-6821-11eb-30bb-37b1f76609a3
function interv_len(interv::Interval{T})::T where T <: Integer 
    interv.ub - interv.lb
end

# ╔═╡ 3cdd4d22-6821-11eb-3c20-a7997b70c44d
begin
	interv1 = IntervInt64(3, 1)
	@test interv_len(interv1) == 2

	interv2 = IntervInt64(4, 7)
	@test interv_len(interv2) == 3

	interv3 = IntervInt64(1, 1)
	@test interv_len(interv3) == 0

	interv4 = IntervInt64(5, 1) 
	@test interv_len(interv4) == 4
end

# ╔═╡ 46c62dea-6821-11eb-0b18-771fd704ee84
md"""
##### Compute if two intervals overlap
"""

# ╔═╡ 91d63a66-6821-11eb-07a4-97c4a000b482
begin

function interv_inter(i₁::Interval{T}, i₂::Interval{T})::Bool where T <: Integer
	i₁ ⊆ i₂ || i₂ ⊆ i₁ || i₁ ⊆ i₂ || i₁ ∩ i₂ || i₂ ∩ i₁  
end
	
function ⊆(i₁::Interval{T}, i₂::Interval{T})::Bool where T <: Integer
	lb1, ub1 = i₁.lb, i₁.ub
  	lb2, ub2 = i₂.lb, i₂.ub
	
	lb2 ≤ lb1 ≤ ub1 ≤ ub2
end

# \cap ≡ ∩
function ∩(i₁::Interval{T}, i₂::Interval{T})::Bool where T <: Integer
	lb1, ub1 = i₁.lb, i₁.ub
  	lb2, ub2 = i₂.lb, i₂.ub
		
	lb1 ≤ lb2 ≤ ub1 ≤ ub2
end
	
end

# ╔═╡ 14f1261a-6823-11eb-3d78-ebc8784d5ef8
begin
	@test interv_inter(IntervInt64(1, 10), IntervInt64(3, 7))
	@test interv_inter(IntervInt64(3, 7), IntervInt64(1, 8))
	@test interv_inter(IntervInt64(1, 6), IntervInt64(3, 9))
	@test interv_inter(IntervInt64(1, 5), IntervInt64(3, 4))
	@test interv_inter(IntervInt64(1, 5), IntervInt64(5, 6))
	@test interv_inter(IntervInt64(6, 10), IntervInt64(5, 8))
	@test !interv_inter(IntervInt64(1, 5), IntervInt64(6, 8))
	@test !interv_inter(IntervInt64(1, 5), IntervInt64(10, 20))
end

# ╔═╡ aac494f8-6823-11eb-138e-59b1641e416b
md"""
##### Adding two intervals length
"""

# ╔═╡ c2440f3a-6823-11eb-1fac-07057f45e3e3
function Base.:+(i₁::Interval{T}, i₂::Interval{T})::T where T <: Integer
	lb1, ub1 = i₁.lb, i₁.ub
	lb2, ub2 = i₂.lb, i₂.ub

	i₁ ⊆ i₂ && return ub2 - lb2
	i₂ ⊆ i₁ && return ub1 - lb1
     
   	s_inter = interv_len(i₁) + interv_len(i₂)
    
	# There might be some overlap: i₁.lb ---- i₂.lb ----- i₁.ub ---- i₂.ub
   	i₁ ∩ i₂ && return s_inter - (ub1 - lb2)
   	i₂ ∩ i₁ && return s_inter - (ub2 - lb1) # symmetry
    
   	s_inter
end

# ╔═╡ a68980ee-6824-11eb-06e2-b5a9527b24b5
begin
	@test IntervInt64(1, 10) + IntervInt64(3, 7) == 9
	@test IntervInt64(3, 7) + IntervInt64(1, 8) == 7
	@test IntervInt64(1, 6) + IntervInt64(3, 9) == 8
	@test IntervInt64(6, 10) + IntervInt64(5, 8) == 5
	@test IntervInt64(1, 5) + IntervInt64(6, 8) == 6	
end

# ╔═╡ dda42a42-6825-11eb-1896-c7c0c2f6577d
md"""
##### Adding interval (length) and a length
"""

# ╔═╡ eb0fe112-6825-11eb-1d1c-d5c2fc96e381
begin
	
function Base.:+(i::Interval{T}, len::T)::T where T <: Integer
   interv_len(i) + len
end

function Base.:+(len::T, i::Interval{T})::T where T <: Integer
   interv_len(i) + len
end
	
end

# ╔═╡ 2be6f644-6826-11eb-168f-31248b1f7b57
begin
	@test IntervInt64(1, 10) + 10 == 19
	@test 6 + IntervInt64(2, 10) == 14
end

# ╔═╡ 647479b4-6826-11eb-0e26-8ffb421b8aba
md"""
##### Sorting an array of Intervals

We will sort on ascending order given the lower bound.
"""

# ╔═╡ 73948ede-6826-11eb-3414-e184635bb6b4
begin
	ary = [
    	IntervInt64(2, 4), IntervInt64(8, 10), IntervInt64(1, 5),
    	IntervInt64(1, 3), IntervInt64(4, 8), IntervInt64(3, 7),
    	IntervInt64(5, 11)
	]

	with_terminal() do
		sort!(ary, by = interv -> interv.lb, rev=false)
		for e ∈ ary
			println(e)
		end
	end
end

# ╔═╡ f204da94-6826-11eb-3007-c1a3d607e835
md"""
#### Merging overlapping intervals (in linear time)
"""

# ╔═╡ 30bf00fc-6827-11eb-14ea-8bf3ef119dfe
begin
	
const VT{T <: Integer} = Vector{Interval{T}}

function merge_interv(il::VT{T})::VT{T} where T <: Integer
	"""
	Merge all the intervals from given vector
	"""
	
	size(il, 1) == 1 && return il   ## identity
	
	n = size(il, 1)
	n_il = VT{T}(undef, n)  ## at most the size of given vector
	i₁, jx = il[1], 1
	
	for ix ∈ 2:n
		i₂ = il[ix]
		if interv_inter(i₁, i₂)
			i₁ = Interval{T}(min(i₁.lb, i₂.lb), max(i₁.ub, i₂.ub))
		else
			n_il[jx] = i₁
			jx += 1
			i₁ = i₂
		end
	end
	
	n_il[jx] = i₁
	view(n_il, 1:jx)
end
	
end

# ╔═╡ 344e9cda-6829-11eb-3c5d-61e4908b38a0
begin
	ary1 = [
    	IntervInt64(2, 4), IntervInt64(8, 10), IntervInt64(1, 5),
    	IntervInt64(1, 3), IntervInt64(4, 8), IntervInt64(3, 7),
    	IntervInt64(5, 11)
	]

	sort!(ary1, by = interv -> interv.lb)

	
	
	ary2 = [
    	IntervInt64(2, 4), IntervInt64(8, 10), IntervInt64(1, 5),
    	IntervInt64(17, 20), IntervInt64(11, 15), IntervInt64(3, 7),
	]

	sort!(ary2, by = interv -> interv.lb)
	
	with_terminal() do
		for e ∈ ary1
			println(e)
		end
		println()
		
		for e ∈ ary2
			println(e)
		end
	end
end

# ╔═╡ 88e56bca-6829-11eb-3da4-d9b2299f2801
@test merge_interv(ary1) == [IntervInt64(1, 11)]

# ╔═╡ fc900436-6829-11eb-1783-b1e82c817e8d
@test merge_interv(ary2) == [IntervInt64(1, 7), 
	IntervInt64(8, 10), 
    IntervInt64(11, 15), 
	IntervInt64(17, 20)
]

# ╔═╡ 158a8cb8-682a-11eb-1d50-d922aa7274a2
begin
	ary3 = [IntervInt64(1, 2), IntervInt64(11, 15)]
	sort!(ary3, by = interv -> interv.lb)

	@test merge_interv(ary3) == ary3 # Identity
end

# ╔═╡ 27a6a1ac-682a-11eb-39f5-9b9159b03088
with_terminal() do
	@btime merge_interv(ary1)
end

# ╔═╡ 33bdfd96-682a-11eb-3f55-93f22f7b1fdf
with_terminal() do
	@btime merge_interv(ary2)
end

# ╔═╡ 8ff62b88-682a-11eb-355e-03ea9b57ab05
# import Base: convert #promote_rule

# overload + already done

Base.convert(::Type{T}, i::Interval{T}) where T <: Integer = i.ub - i.lb
# promote_rule(::Interval{T}, ::Interval{<:Integer}) = T

# ╔═╡ c7b6c8fc-682a-11eb-2cc9-5706878cf4a3
md"""
##### Compute Sum of Interval array

###### Take 1
"""

# ╔═╡ d359aff8-682a-11eb-1061-89a949359934
function sum_intervals(il::VT{T}; merger_fn=merge_interv)::T where T <: Integer
    size(il, 1) == 1 && return interv_len(il[1])
    
	foldl((s, i) -> s += interv_len(i), 
		merger_fn(sort(il, by=interv -> interv.lb)); 
		init=0)
end

# ╔═╡ 697050a0-682b-11eb-0ec0-650a0a68b11a
begin
	s_ary11 = [
    	IntervInt64(2, 4), IntervInt64(8, 10), IntervInt64(1, 5),
    	IntervInt64(1, 3), IntervInt64(4, 8), IntervInt64(3, 7),
    	IntervInt64(5, 11)
	]

	s_ary12 = [
    	IntervInt64(2, 4), IntervInt64(8, 10), IntervInt64(1, 5),
    	IntervInt64(1, 3), IntervInt64(4, 8), IntervInt64(3, 7),
    	IntervInt64(5, 11)
	]

	@test sum_intervals(s_ary11) == sum_intervals(s_ary12) 
end

# ╔═╡ 9cc8c4b4-682b-11eb-046f-b9f2e3e82908
begin
	_ary11 = [IntervInt64(1, 2), IntervInt64(11, 15)]
	@test sum_intervals(_ary11) == 5

	_ary12 = [IntervInt64(1, 2), IntervInt64(11, 15), IntervInt64(6, 10)]
	@test sum_intervals(_ary12) == 9
	
	_ary13 = [
    	IntervInt64(1, 5), IntervInt64(10, 20), IntervInt64(1, 6),
    	IntervInt64(16, 19), IntervInt64(5, 11)
	]
	@test sum_intervals(_ary13) == 19
end

# ╔═╡ ca5c153e-682b-11eb-390b-ef6bbc821d95
with_terminal() do
	@btime sum_intervals(_ary13)
end

# ╔═╡ 1ae7fe64-682c-11eb-349c-3f3919aafd76
md"""
###### Take 2
"""

# ╔═╡ 2d3db23e-682c-11eb-2baa-91d0f9caf485
function sum_intervals_2(il::VT{T}; merger_fn=merge_interv)::T where T <: Integer
 	size(il, 1) == 1 && return interv_len(il[1])
    
	map(iv -> interv_len(iv), 
		merger_fn(sort(il, by=interv -> interv.lb))) |> sum
	
end

# ╔═╡ 21c48f2c-682c-11eb-2971-a34d13b77f1c
@test sum_intervals_2(s_ary11) == sum_intervals_2(s_ary12) 

# ╔═╡ 9e3b563a-682c-11eb-03b6-292ba8b72db5
begin
	@test sum_intervals_2(_ary11) == 5
	@test sum_intervals_2(_ary12) == 9
	@test sum_intervals_2(_ary13) == 19
end

# ╔═╡ 134299a0-6852-11eb-17ad-f7fa7323406b
with_terminal() do
	@btime sum_intervals_2(_ary13)
end

# ╔═╡ 218593a8-682c-11eb-1eb8-579b44dfd57c
md"""
###### Take 3
"""

# ╔═╡ 04684c04-6852-11eb-3522-bf07f9428110
function sum_intervals_3(il::VT{T}; merger_fn=merge_interv)::T where T <: Integer
 	size(il, 1) == 1 && return interv_len(il[1])
    
    reduce(+, 
		merger_fn(sort(il, by=interv -> interv.lb))
	)
end

# ╔═╡ 40cfa4dc-6853-11eb-2469-ef9c84d3a4f6
@test sum_intervals_3(s_ary11) == sum_intervals_3(s_ary12) 

# ╔═╡ 39406316-6853-11eb-2783-35b77b3b62cc
begin
	@test sum_intervals_3(_ary11) == 5
	@test sum_intervals_3(_ary12) == 9
	@test sum_intervals_3(_ary13) == 19
end

# ╔═╡ 47aa8d46-6853-11eb-2505-5727d9c83eb2
with_terminal() do
	@btime sum_intervals_3(_ary13)
end

# ╔═╡ Cell order:
# ╟─19046b20-6820-11eb-3fac-e993b8847dc0
# ╠═5bd9e6aa-6820-11eb-2b20-3f17c0045841
# ╟─698441e4-6820-11eb-2ed2-e90fbf53d7f0
# ╠═7da89592-6820-11eb-0ad7-699807d1d952
# ╠═9e07bbc4-6820-11eb-07ca-77f29e8a3030
# ╠═b9125d20-6820-11eb-3773-07dd4728988d
# ╟─f6264b68-6820-11eb-1fc4-afcb22381c09
# ╠═1640dbfe-6821-11eb-30bb-37b1f76609a3
# ╠═3cdd4d22-6821-11eb-3c20-a7997b70c44d
# ╟─46c62dea-6821-11eb-0b18-771fd704ee84
# ╠═91d63a66-6821-11eb-07a4-97c4a000b482
# ╠═14f1261a-6823-11eb-3d78-ebc8784d5ef8
# ╟─aac494f8-6823-11eb-138e-59b1641e416b
# ╠═c2440f3a-6823-11eb-1fac-07057f45e3e3
# ╠═a68980ee-6824-11eb-06e2-b5a9527b24b5
# ╟─dda42a42-6825-11eb-1896-c7c0c2f6577d
# ╠═eb0fe112-6825-11eb-1d1c-d5c2fc96e381
# ╠═2be6f644-6826-11eb-168f-31248b1f7b57
# ╟─647479b4-6826-11eb-0e26-8ffb421b8aba
# ╠═73948ede-6826-11eb-3414-e184635bb6b4
# ╟─f204da94-6826-11eb-3007-c1a3d607e835
# ╠═30bf00fc-6827-11eb-14ea-8bf3ef119dfe
# ╠═344e9cda-6829-11eb-3c5d-61e4908b38a0
# ╠═88e56bca-6829-11eb-3da4-d9b2299f2801
# ╠═fc900436-6829-11eb-1783-b1e82c817e8d
# ╠═158a8cb8-682a-11eb-1d50-d922aa7274a2
# ╠═27a6a1ac-682a-11eb-39f5-9b9159b03088
# ╠═33bdfd96-682a-11eb-3f55-93f22f7b1fdf
# ╠═8ff62b88-682a-11eb-355e-03ea9b57ab05
# ╟─c7b6c8fc-682a-11eb-2cc9-5706878cf4a3
# ╠═d359aff8-682a-11eb-1061-89a949359934
# ╠═697050a0-682b-11eb-0ec0-650a0a68b11a
# ╠═9cc8c4b4-682b-11eb-046f-b9f2e3e82908
# ╠═ca5c153e-682b-11eb-390b-ef6bbc821d95
# ╟─1ae7fe64-682c-11eb-349c-3f3919aafd76
# ╠═2d3db23e-682c-11eb-2baa-91d0f9caf485
# ╠═21c48f2c-682c-11eb-2971-a34d13b77f1c
# ╠═9e3b563a-682c-11eb-03b6-292ba8b72db5
# ╠═134299a0-6852-11eb-17ad-f7fa7323406b
# ╟─218593a8-682c-11eb-1eb8-579b44dfd57c
# ╠═04684c04-6852-11eb-3522-bf07f9428110
# ╠═40cfa4dc-6853-11eb-2469-ef9c84d3a4f6
# ╠═39406316-6853-11eb-2783-35b77b3b62cc
# ╠═47aa8d46-6853-11eb-2505-5727d9c83eb2
