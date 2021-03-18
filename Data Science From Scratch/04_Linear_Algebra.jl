### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ c96551a0-881e-11eb-0d92-61edbb6c86e6
begin
	using Test 
end

# ╔═╡ accc6f84-881d-11eb-3b49-e9cd25a3b6fd
md"""
## Linear Algebra

ref. from book **"Data Science from Scratch"**, Chap 4
"""

# ╔═╡ 1439cfec-8835-11eb-31c6-a31ee138f43c
html"""
<a id='toc'></a> 
"""

# ╔═╡ 136cdd48-8835-11eb-0482-737cf7bd5a3e
md"""
#### TOC
  - [Vectors](#vectors)
  - [Matrices](#matrices)
"""

# ╔═╡ b22cf860-8834-11eb-02de-d3ad803d1db6
html"""
<p style="text-align: right;">
  <a id='vectors'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ b1e26cfa-8834-11eb-16f5-85efb64c6a4c
md"""
### Vectors
Points in some finite dimensional space. A vector has a direction and a magnitude.$(html"<br />")
Vectors are useful to represent data (which lie in some multi-finite-dimensional space).  
We will want to perform operations on those vectors, so let defines and implements those operations. $(html"<br />")
We will be using the `Vector` type from `Julia`.
"""

# ╔═╡ 9b2a7694-881e-11eb-325c-f3edd9178641
begin
	import Base: +, -

	function +(v₁::Vector{T}, v₂::Vector{T})::Vector{T} where T <: Number
		"""
		Vector Additon is component-wise 
		"""
		@assert length(v₁) == length(v₂)
		v₁ .+ v₂
	end
	
	function +(vc::Vector{Vector{T}})::Vector{T} where T <: Number
		"""
		Sum all corresponding components of a collection of vector to return
		one vector
		"""
		@assert length(vc) > 0 "expect the collection to have at leat one vector element"
		n = length(vc[1])
		@assert all(v -> length(v) == n, vc) "Expect all vectors to be of he same length"
		v = zeros(T, n)
		for v₀ ∈ vc
			v .+= v₀
		end	
		v
	end
	
	function -(v₁::Vector{T}, v₂::Vector{T})::Vector{T} where T <: Number
		"""
		Vector Additon is component-wise 
		"""
		@assert length(v₁) == length(v₂)	
		v₁ .- v₂
	end
end

# ╔═╡ 21a74512-881f-11eb-31e6-974bcaf59141
begin
	@test +([1, 2, 3], [4, 5, 6]) == [5, 7, 9]
	@test [1, 2, 3] + [4, 5, 6] == [5, 7, 9]
	
	vᵣ = [1.0, -1.0, π, ℯ]
	@test vᵣ + [-1.0, 1.0, -π, -ℯ] == zeros(eltype(vᵣ), length(vᵣ))
end

# ╔═╡ 11ff42a0-8828-11eb-3ba5-dbd12b5ffdda
md"""
Sometimes we want to sum a collection of vector component wise. that is create a new vector whose first component is the sum of evry first comp[onent of thew collection and  so for for the other components.

Here the collection is itsef a vector in `Julia`'s term.
cf. celle above for implementation
"""

# ╔═╡ 7dc3365c-8828-11eb-3c57-69dae41619cd
begin
	@test +([[1, 2], [3, 4], [5, 6], [7, 8]]) == [16, 20]
	@test +([[1, 3, 2] for _ ∈ 1:3]) == [3, 9, 6]
end

# ╔═╡ e9b7d526-8829-11eb-34d1-e317fdc7a1d0
md"""
`Multiplication` by a scalar, `Mean` and `dot` product.
"""

# ╔═╡ 3a7741c2-882a-11eb-2ffd-65b97e75a0b2
begin
	import Base.*
	
	*(x::T, v::Vector{T}) where T <: Number = v .* x
	*(v::Vector{T}, x::T) where T <: Number = v .* x
	
	function μ(vc::Vector{Vector{T}})::Vector{AbstractFloat} where T <: Number
		"""Element-wise mean"""
		@assert length(vc) > 0 
		n = length(vc[1])
		@assert all(v -> length(v) == n, vc) 
		reduce(+, vc) / n
 	end

	function dot(v₁::Vector{T}, v₂::Vector{T})::T where T <: Number
		@assert length(v₁) == length(v₂)
		sum(v₁ .* v₂)
	end
end

# ╔═╡ b3f61d4e-881f-11eb-2dcb-4dd0fd7fba06
begin
	@test -([1, 2, 3], [4, 5, 6]) == [-3, -3, -3]
	@test [1, 2, 3] - [4, 5, 6] == [-3, -3, -3]
	
	# vᵣ = [1.0, -1.0, π, ℯ]
	@test vᵣ - [-1.0, 1.0, -π, -ℯ] == [2.0, -2.0, 2π, 2ℯ]
end

# ╔═╡ 19f5b176-882b-11eb-3713-73c85f599be1
begin
	@test *(2, [1, 2, 3]) == [2, 4, 6]
	@test *(2, [1, 2, 3]) == *([1, 2, 3], 2)
	@test 2 * [1, 2, 3] == [1, 2, 3] * 2  ==  [2, 4, 6]
end

# ╔═╡ 50444c92-882b-11eb-2893-bf66b63ee595
begin
	μ([[1, 2, 1, 2], [3, 4, 3, 4], [5, 6, 5, 6]]) == Float64[3., 4., 3., 4.]
end

# ╔═╡ d358476c-882d-11eb-26bd-c167cabd7b28
begin
	@test dot([1, 2, 3], [4, 5, 6]) == 32
end

# ╔═╡ d33d417e-882d-11eb-0aae-a1d10512920f
function sum_of_square(v::Vector{T})::T where T <: Number
	"""
	return vᵢ * vᵢ ∀ i ∈ 1:length(v)
	"""
	dot(v, v)
end

# ╔═╡ d3202a62-882d-11eb-2e24-6d874dce773d
begin
	@test sum_of_square([1, 2, 3]) == 14
	@test sum_of_square([4, 5, 6]) == 77
end

# ╔═╡ 9db8e630-882e-11eb-07e5-0d5036f7e8e2
md"""
Let's now implement L₂ norm and euclidean distance.
"""

# ╔═╡ ba1d63da-882e-11eb-1736-37a246585172
function norm(v::Vector{T})::AbstractFloat where T <: Number
	√ sum(v .* v)
end

# ╔═╡ 9da1fcfc-882e-11eb-021f-1f89149817a9
begin
	@test norm([3, 4]) == 5
	@test norm([1, 0, 2]) ≈ √5
end

# ╔═╡ 9d8634ae-882e-11eb-15ad-75b06c847379
function distance(v₁::Vector{T}, v₂::Vector{T})::AbstractFloat where T <: Number
	"""
	distance(v₁, v₂) ≡ √(Σ (v₁ᵢ - v₂ᵢ)²)
	"""
	@assert length(v₁) == length(v₂)
	√ sum((v₁ .- v₂).^2)  # == norm(v₁ .- v₂)
end

# ╔═╡ 9d69ec22-882e-11eb-0637-d7e29f7b9f37
begin
	@test distance([2, 6, 7, 7, 5, 13, 14, 17, 11, 8],
		[3, 5, 5, 3, 7, 12, 13, 19, 22, 7]) ≈ 12.409673645990857
end

# ╔═╡ 0539916a-8835-11eb-3407-41f17efc2ee4
html"""
<p style="text-align: right;">
  <a id='matrices'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 73e7de7a-8830-11eb-05ef-b93f6c774587
md"""
### Matrices

A two-dimensional collection of numbers.
"""

# ╔═╡ 7f051430-8830-11eb-1e43-797df6b195ed
function shape(m::Matrix{T})::Tuple{Integer, Integer} where T <: Number
	size(m)
end

# ╔═╡ 7ee4e642-8830-11eb-3d15-813c4dbb6420
@test shape([1 2 3; 4 5 6]) == (2, 3) # 2 rows, 3 columns

# ╔═╡ 7ec91688-8830-11eb-18a0-d5a67e267f9b
function get_row(m::Matrix{T}, r::Integer)::Vector{T}  where T <: Number
	@assert 1 ≤ r ≤ size(m)[1]
	view(m, r, :)  ## no copy!
end

# ╔═╡ 7e9afe92-8830-11eb-3772-150255e27923
begin
	@test get_row([1 2 3; 4 5 6], 1) == [1, 2, 3]
	@test get_row([1 2 3; 4 5 6], 2) == [4, 5, 6]	
	@test_throws AssertionError get_row([1 2 3; 4 5 6], 0) 
end

# ╔═╡ 648af952-8831-11eb-340b-5bc7ef7aaa73
function get_column(m::Matrix{T}, c::Integer)::Vector{T}  where T <: Number
	@assert 1 ≤ c ≤ size(m)[2]
	view(m, :, c)  ## no copy!
end

# ╔═╡ 6470ad90-8831-11eb-0413-5d016bf66536
begin
	@test get_column([1 2 3; 4 5 6], 1) == [1, 4]
	@test get_column([1 2 3; 4 5 6], 2) == [2, 5]
	@test get_column([1 2 3; 4 5 6], 3) == [3, 6]
	@test_throws AssertionError get_column([1 2 3; 4 5 6], 0) 
end

# ╔═╡ 6458987c-8831-11eb-2b89-efac8fabf803
md"""
We will want to be able to create a new matrix given its shape and a function generator.
"""

# ╔═╡ c832331c-8831-11eb-0b7c-9f978c82f890
function make_matrix(nrows::Integer, ncols::Integer, fn::Function;
		DT::DataType=Float64)::Matrix
	@assert 1 ≤ nrows && 1 ≤ ncols
	
	m = zeros(DT, (nrows, ncols))
	for c ∈ 1:ncols, r ∈ 1:nrows
		m[r, c] = fn(r, c)
	end
	m
end

# ╔═╡ be10ce56-8832-11eb-0742-d90fa7f6f669
function identity_matrix(n::Integer; DT::DataType=Float64)::Matrix
	"""Returns the n × n identity matrix"""	
	make_matrix(n, n, (i, j) -> i == j ? one(DT) : zero(DT); DT)
end

# ╔═╡ c81a12dc-8831-11eb-27e9-07132c6310a1
@test identity_matrix(5) == [1. 0. 0. 0. 0.; 0. 1. 0. 0. 0.; 0. 0. 1. 0. 0.; 0. 0. 0. 1. 0.; 0. 0. 0. 0. 1.]

# ╔═╡ 3c69e83a-8835-11eb-218e-0bb108ad7b9c
html"""
<hr />
<sub><em>Mar 2021, Corto Inc</em></sub>
"""

# ╔═╡ Cell order:
# ╟─accc6f84-881d-11eb-3b49-e9cd25a3b6fd
# ╟─1439cfec-8835-11eb-31c6-a31ee138f43c
# ╟─136cdd48-8835-11eb-0482-737cf7bd5a3e
# ╟─b22cf860-8834-11eb-02de-d3ad803d1db6
# ╟─b1e26cfa-8834-11eb-16f5-85efb64c6a4c
# ╠═c96551a0-881e-11eb-0d92-61edbb6c86e6
# ╠═9b2a7694-881e-11eb-325c-f3edd9178641
# ╠═21a74512-881f-11eb-31e6-974bcaf59141
# ╠═b3f61d4e-881f-11eb-2dcb-4dd0fd7fba06
# ╟─11ff42a0-8828-11eb-3ba5-dbd12b5ffdda
# ╠═7dc3365c-8828-11eb-3c57-69dae41619cd
# ╟─e9b7d526-8829-11eb-34d1-e317fdc7a1d0
# ╠═3a7741c2-882a-11eb-2ffd-65b97e75a0b2
# ╠═19f5b176-882b-11eb-3713-73c85f599be1
# ╠═50444c92-882b-11eb-2893-bf66b63ee595
# ╠═d358476c-882d-11eb-26bd-c167cabd7b28
# ╠═d33d417e-882d-11eb-0aae-a1d10512920f
# ╠═d3202a62-882d-11eb-2e24-6d874dce773d
# ╟─9db8e630-882e-11eb-07e5-0d5036f7e8e2
# ╠═ba1d63da-882e-11eb-1736-37a246585172
# ╠═9da1fcfc-882e-11eb-021f-1f89149817a9
# ╠═9d8634ae-882e-11eb-15ad-75b06c847379
# ╠═9d69ec22-882e-11eb-0637-d7e29f7b9f37
# ╟─0539916a-8835-11eb-3407-41f17efc2ee4
# ╟─73e7de7a-8830-11eb-05ef-b93f6c774587
# ╠═7f051430-8830-11eb-1e43-797df6b195ed
# ╠═7ee4e642-8830-11eb-3d15-813c4dbb6420
# ╠═7ec91688-8830-11eb-18a0-d5a67e267f9b
# ╠═7e9afe92-8830-11eb-3772-150255e27923
# ╠═648af952-8831-11eb-340b-5bc7ef7aaa73
# ╠═6470ad90-8831-11eb-0413-5d016bf66536
# ╟─6458987c-8831-11eb-2b89-efac8fabf803
# ╠═c832331c-8831-11eb-0b7c-9f978c82f890
# ╠═be10ce56-8832-11eb-0742-d90fa7f6f669
# ╠═c81a12dc-8831-11eb-27e9-07132c6310a1
# ╟─3c69e83a-8835-11eb-218e-0bb108ad7b9c
