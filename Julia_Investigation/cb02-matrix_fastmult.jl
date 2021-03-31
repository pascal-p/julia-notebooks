### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ e704feae-919c-11eb-35ea-0932dbb413dd
begin
	# using Pkg; 
	using StatsBase
	using BenchmarkTools
	using Test
	using Random
	using PlutoUI
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Fast matrix multiplication

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)

**Context**
Performing computations on matrices are one of the fundamental operations in numerical computing. If we want to multiply an $m × n$ matrix by $n × p$ matrix the cost of this operattion is proportional to the product of these dimensions, namely $O(nmp)$, this  then produces and $n × p$ matrix.

If we want to multiply several matrices, the total cost will depend on the order in which the multiplication are performed. 
For example if we have 3 matrices $A$, $B$ and  $C$ with respective dimensions $10×40$, $40×10$ and $10×50$ and we want to conpute $A × B × C$ we can do:

 $(A×B)×C$, cost: $10×40×10 + 10×10×50 ≡  9000$ or

 $A×(B×C)$, cost: $10×40×50 + 40×10×50 ≡ 40000$
"""

# ╔═╡ 2321e634-9267-11eb-1c6f-af2e0a29f7e7
md"""
We will use a technique called dynamic programming (DP) to find the optimal order of multiplications.

Assume we want to multiply the following matrices: A₁, A₂, ...Aₙ.

Let $f(i, j)$ be the minimal cost of multiplaying Aᵢ by Aⱼ.

Our objective is to find: $f(1, n)$.

Performing 0 multiplication has a zero cost, $f(i, i) = 0$

The minimal cost $(f(i, j)$ can be found by considering all possible outermost points of multiplication:

$$f(i, j) = min_{i \le k < j}\{f(i, k) + f(k-1, j) + d(i, 1)×d(k, 2)×d(j,2)\}  \tag{α}$$

where $d(i, s)$ is the $s$-th dimention of matrix $i$

Note: in order to perfomr the actual multiplication, we need to know the value of $f(i, j)$ and the value of $k$ for which the expression in the recurrence was minimal.
"""

# ╔═╡ 61f7bad8-926b-11eb-01c1-1310ca7f9e50
begin
	const TI = Tuple{Int, Int}
	const VTI = Vector{TI}
	const D_TI = Dict{TI, TI}
end

# ╔═╡ 08f24660-919e-11eb-37c9-155375b48cf4
function solve_mult(sizes::NTuple, part_cost::D_TI, from::Int, to::Int)
	if from == to
		part_cost[(from, to)] = (0, from)
		return
	end
	
	min_cost, min_j = typemax(Int), -1
	for j ∈ from:(to - 1)
		# using memoization, each tuple (f, t) is calc. once
		haskey(part_cost, (from, j)) || solve_mult(sizes, part_cost, from, j)
		haskey(part_cost, (j+1, to)) || solve_mult(sizes, part_cost, j+1, to)

		# using equation (α) defined above
		curr_cost = part_cost[(from, j)][1] + part_cost[(j+1, to)][1] + 
			sizes[from][1] * sizes[j][2] * sizes[to][2]

		curr_cost < min_cost && ((min_cost, min_j) = (curr_cost, j))
	end
	# @assert min_j > 0  "min_j must be 0 but: $(min_j)"
	part_cost[(from, to)] = (min_cost, min_j)
	# return
end

# ╔═╡ 09071fe0-926b-11eb-0f26-9f4a7538bdcf
function do_mult(matrices::NTuple, part_cost::D_TI, 
		from::Int, to::Int)
	from == to && (return matrices[from])
	from + 1 == to && (return matrices[from] * matrices[to])

	j = part_cost[(from, to)][2]
	do_mult(matrices, part_cost, from, j) * do_mult(matrices, part_cost, j+1, to)
end

# ╔═╡ e849191c-919c-11eb-0d04-b9ec7a4ac478
function fast_matmult(matrices::AbstractMatrix...)# ::AbstractMatrix
	length(matrices) ≤ 1 && (return *(matrices...))

	sizes = size.(matrices)
	!all(ix -> sizes[ix+1][1] == sizes[ix][2], 1:length(sizes) - 1) &&
		throw(ArgumentError("Matrices dimensions mismatch"))

	from, to = 1, length(sizes)
	part_cost = D_TI()
	solve_mult(sizes, part_cost, from, to)
	do_mult(matrices, part_cost, from, to)
end

# ╔═╡ 5b5c8830-926f-11eb-0654-854d9567db7c
begin
	n, p = 5000, 5
	m₁ = rand(Float64, (p, n))
	m₂ = rand(Float64, (n, p))
	m₃ = rand(Float64, (p, 4000))
	m₄ = rand(Float64, (4000, p))

	with_terminal() do
		@btime *(repeat([m₁, m₂, m₃, m₄], outer=10)...)
	end
end

# ╔═╡ 3c7301d4-9270-11eb-2a8a-bf0f3a69f0f9
with_terminal() do
	@btime fast_matmult(repeat([m₁, m₂, m₃, m₄], outer=10)...)
end

# ╔═╡ 204f8bd6-9277-11eb-2b15-1199f4f503a6
md"""
In practice, we migth want to define a macro to turn a matrix multiplication into a fast matrix multiplication:
"""

# ╔═╡ 4082f32a-9277-11eb-06f8-939e0ff5560e
macro fast_matmult(expr::Expr)
	expr.head == :call || throw(ArgumentError("expression must be a call"))
	expr.args[1] == :(*) || throw(ArgumentError("only for multiplication!"))
	#
	new_expr = deepcopy(expr)         ## make a defensive copy
	new_expr.args[1] = :fast_matmult  ## overwrite '*' operator with ours
	#
	esc(new_expr)                     ## macor hygiene
 end

# ╔═╡ 1d773e30-9278-11eb-1d3d-2bdd47ef091b
@fast_matmult rand(Float64, (2, 3)) * rand(Float64, (3,4)) * ones(4, 5)
#
# expr = :(rand(Float64, (2, 3)) * rand(Float64, (3, 4)) * ones(4, 5))
# new_expr = :(fast_matmult(rand(Float64, (2, 3)), rand(Float64, (3, 4)), ones(4, 5)))
#

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╟─2321e634-9267-11eb-1c6f-af2e0a29f7e7
# ╠═e704feae-919c-11eb-35ea-0932dbb413dd
# ╠═61f7bad8-926b-11eb-01c1-1310ca7f9e50
# ╠═e849191c-919c-11eb-0d04-b9ec7a4ac478
# ╠═08f24660-919e-11eb-37c9-155375b48cf4
# ╠═09071fe0-926b-11eb-0f26-9f4a7538bdcf
# ╠═5b5c8830-926f-11eb-0654-854d9567db7c
# ╠═3c7301d4-9270-11eb-2a8a-bf0f3a69f0f9
# ╟─204f8bd6-9277-11eb-2b15-1199f4f503a6
# ╠═4082f32a-9277-11eb-06f8-939e0ff5560e
# ╠═1d773e30-9278-11eb-1d3d-2bdd47ef091b
