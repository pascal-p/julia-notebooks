### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ b3e63d70-68c6-11eb-17c2-0f899e780c9e
begin
	using PlutoUI
	using Test
end

# ╔═╡ 2d54bdea-68c6-11eb-3f0f-6978c66b6785
md"""
### Queen Placement problem
"""

# ╔═╡ 2142ac02-68c8-11eb-3c34-35667eb5e7d5
md"""
**Define a type point**.
"""

# ╔═╡ 559b845a-68c6-11eb-37c8-7798fbf254aa
begin
  struct Point{T <: Integer}
  	x::T
  	y::T
  end
	
  Base.show(io::IO, p::Point) = print(io, "($(p.x), $(p.y))")

  const VP{T} = Vector{Point{T}} where {T <: Integer}
end

# ╔═╡ 6aa8bfde-68c6-11eb-224b-1dd95917caf7
"""
Add a queen at position p to the current board
"""
qadd(board::VP, p::Point) = push!(copy(board), p)

# ╔═╡ 70f930e4-68c6-11eb-2881-5fcbfb3358f1
begin
	Base.:-(p₁::Point, p₂::Point) = (p₁.x - p₂.x, p₁.y - p₂.y)
	Base.abs(p::Point) = (abs(p.x), abs(p.y))

	## Iterator
	Base.collect(p::Point) = [p.x, p.y]

	function Base.iterate(iter::Point, state=(collect(iter), 1))
  		comp, ix = state
  		comp === nothing && return nothing     ## are we done?
  		ix == length(comp) && return (comp[ix], (nothing, ix))
  		(comp[ix], (collect(iter), ix + 1))
	end

	Base.length(iter::Point) where T = length(collect(iter))
	Base.eltype(::Point{T}) where T = T
end

# ╔═╡ cc5b11aa-68c6-11eb-25af-35517b6dd119
p = Point(2, 3)

# ╔═╡ 997cc7b0-68c6-11eb-2a4d-715782d7cc30
with_terminal() do
	for c ∈ p; println(c); end
end

# ╔═╡ e8a4563e-68c6-11eb-2df6-236cdf425e22
begin
	"""
	Check for constriant satisfaction:
	no 2 queens using the same row nor the same columns nor the same diagonals
	"""
	qhit(board::VP, p::Point) = any(map(o_p -> qhit_hlpr(p, o_p), board))
	
	qhit_hlpr(p₁::Point, p₂::Point) = 
    	any(p₁ .== p₂) || abs((p₁ - p₂)[1]) == abs((p₁ - p₂)[2])
	#   check for ≠ row/col or ≠ diags
end

# ╔═╡ f39f8fdc-68c6-11eb-0521-6b474172d441
"""
Try placing the n queens on the n × n board
"""
function queen_solver(n::Int; m::Int=n, board=VP{Int}())
    m < 1 && return board 
    for x = 1:n, y = 1:n
      p = Point(x, y)
      if ! qhit(board, p)
          ## then place queen at position Point(x, y)
          s = queen_solver(n; m=m-1, board=qadd(board, p))
          s != nothing && return s
      end
    end
  
    return nothing
end

# ╔═╡ fd0f3c68-68c6-11eb-1285-41862ff156d1
methods(queen_solver)

# ╔═╡ 0dea7ef8-68c7-11eb-0499-1b1c2e83f31b
with_terminal() do
	n = 8   # for 8 queens
	sol = queen_solver(n)
	println("solution for n: $(n)")
	if sol == nothing
		println("No solution")
	else
		for c ∈ sol; println(c) ; end
	end

end

# ╔═╡ d09cf0ca-68c7-11eb-3bc3-6dadca56a7e0
with_terminal() do
	n = 4   # for 4 queens
	sol = queen_solver(n)
	println("solution for n: $(n)")
	if sol == nothing
		println("No solution")
	else
		for c ∈ sol; println(c) ; end
	end
end

# ╔═╡ be45e20a-68c8-11eb-1281-55f090b4d5bb
with_terminal() do
	n = 3   # for 3 queens
	sol = queen_solver(n)
	println("solution for n: $(n)")
	if sol == nothing
		println("No solution")
	else
		for c ∈ sol; println(c) ; end
	end
end

# ╔═╡ Cell order:
# ╟─2d54bdea-68c6-11eb-3f0f-6978c66b6785
# ╠═b3e63d70-68c6-11eb-17c2-0f899e780c9e
# ╟─2142ac02-68c8-11eb-3c34-35667eb5e7d5
# ╠═559b845a-68c6-11eb-37c8-7798fbf254aa
# ╠═6aa8bfde-68c6-11eb-224b-1dd95917caf7
# ╠═70f930e4-68c6-11eb-2881-5fcbfb3358f1
# ╠═cc5b11aa-68c6-11eb-25af-35517b6dd119
# ╠═997cc7b0-68c6-11eb-2a4d-715782d7cc30
# ╠═e8a4563e-68c6-11eb-2df6-236cdf425e22
# ╠═f39f8fdc-68c6-11eb-0521-6b474172d441
# ╠═fd0f3c68-68c6-11eb-1285-41862ff156d1
# ╠═0dea7ef8-68c7-11eb-0499-1b1c2e83f31b
# ╠═d09cf0ca-68c7-11eb-3bc3-6dadca56a7e0
# ╠═be45e20a-68c8-11eb-1281-55f090b4d5bb
