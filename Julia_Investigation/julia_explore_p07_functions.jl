### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 3ed2de2e-68cf-11eb-1122-091e57ea014e
using PlutoUI

# ╔═╡ 48988162-68d1-11eb-22dc-2bbc0e41043b
using Test

# ╔═╡ b6e6f16a-68ce-11eb-320d-6b292123f85a
md"""
### Functions in julia
"""

# ╔═╡ d8456146-68ce-11eb-2872-3d66933b3385
begin
	DT = Float64

	function δ(a::DT, b::DT, c::DT)::DT
    	b * b - 4 * a * c
	end
end

# ╔═╡ fbec986e-68ce-11eb-1598-619db8bca4cc
function root(a::DT, b::DT, c::DT)::NamedTuple{(:x1, :x2),Tuple{DT, DT}}
    Δ = δ(a, b, c) 
    Δ < 0 && throw(ArgumentError("No solution in ℜ"))
    
	x₁ = (-b + √ Δ) / 2a
   	x₂ = (-b - √ Δ) / 2a
    (x1 = x₁, x2 = x₂) # named tuple
end

# ╔═╡ 3750513e-68cf-11eb-0e76-7169551337af
with_terminal() do
	println(typeof(δ(1., 1., 1.)))
end

# ╔═╡ 50a85e6a-68cf-11eb-0e5e-2f2cbbfcce73
with_terminal() do
	r = root(2., -3., 1.)
	println("r: $(r) / typeof(r): $(typeof(r))")
end

# ╔═╡ 80512f66-68cf-11eb-3f58-498f113425d4
with_terminal() do
	r = root(1., -2., 1.)
	println("r: $(r) / typeof(r): $(typeof(r))")
end

# ╔═╡ 94a3ce9c-68cf-11eb-1a26-e57d02e78f19
with_terminal() do
	try
    	println(root(1., -1., 1.))
	catch ex
    	println("Intercepted: ", string(ex))
	end
end

# ╔═╡ a5f7141a-68cf-11eb-3dd1-9b04e8b62317
md"""
#### Function composition
"""

# ╔═╡ b2f4f754-68cf-11eb-3d27-dd9df6feb65f
function f(x::Real)::Real  ## Real is an abstract type
    2. * x
end

# ╔═╡ c06c4d8a-68cf-11eb-133e-ed1e6ae4c889
function g(x::Real)::Real
    x - 5.
end

# ╔═╡ cadfceca-68cf-11eb-1b1b-7fcc66d4c632
(g ∘ f)(4.)  # type: \circ<tab>: g(f(4.)) = 2 * 4. - 5, = 3

# ╔═╡ d97425bc-68cf-11eb-20c0-2dcaf9ede5f4
(f ∘ g)(7.) 

# ╔═╡ e0553894-68cf-11eb-0e1f-5be65d986ed8
ary = [x for x in 0:5:100]

# ╔═╡ e4d32200-68cf-11eb-2ff7-0b227d2de510
nary = map(x -> 3x + 2, ary) |> 
    x -> filter(isodd, x)

# ╔═╡ f250750e-68cf-11eb-3e4e-b5fcbcdf2320
map(x -> 3x + 2, ary) |> 
    x -> filter(isodd, x) |>
    x -> reduce(+, x, init=0)

# ╔═╡ fcf27c16-68cf-11eb-3ae6-9b5a3d98c6ab
reduce(+, [x for x in 1:10], init=0)

# ╔═╡ 07a84580-68d0-11eb-0dcc-2dfc25b93d8b
reduce(+, 1:10, init=11)

# ╔═╡ 0b7b3b18-68d0-11eb-0e84-57cbc7e344d1
md"""
#### Function and Closure
"""

# ╔═╡ 1c25a7be-68d0-11eb-29f3-4dd237a2ef2e
adder = function(α::Number=2)
    x -> x + α
end

# ╔═╡ 44e600ba-68d0-11eb-122f-e9973916ffc8
add2 = adder()   # ≡ ad2(x) = x + 2

# ╔═╡ 53b8de8a-68d0-11eb-34e0-c1bbb3824ede
add2(2)

# ╔═╡ 7174059e-68d0-11eb-01fe-e712691890a4
begin
	add3 = adder(3)
	add3(10)
end

# ╔═╡ 840923b0-68d0-11eb-039f-05cd7abb2c04
map(add2, 1:10)

# ╔═╡ 8c579696-68d0-11eb-1321-ad2e8290b3bd
counter = function(; init=0)
    cnt = init
	
    inc() = cnt += 1
	dec() = cnt -= 1
	reset() = cnt = 0
    
	## Declare public:
    ()->(inc, dec, reset)
end

# ╔═╡ 2542f116-68d1-11eb-0eb2-0fa4398666ee
begin 
	xc = counter()
	
	@test xc.inc() == 1
	@test xc.inc() == 2  
	@test xc.inc() == 3
	
	@test xc.dec() == 2
	
	@test xc.reset() == 0
end

# ╔═╡ 6d948d44-68d1-11eb-283f-95c7209184f3
begin 
	yc = counter(init=100)
	
	@test yc.inc() == 101
	@test yc.inc() == 102  
	@test yc.inc() == 103
	
	@test yc.dec() == 102
	
	@test yc.reset() == 0
end

# ╔═╡ 8d553214-68d1-11eb-29d7-d791c9dff9f4
counter_ng = function(;init=0)
    cnt = init

	# closure
    λ = function(action=:inc)
        if action == :inc
            cnt += 1
        elseif action == :dec
            cnt -= 1
        elseif action == :reset
            cnt = 0
        else
            throw(ArgumentError("action $(action) not yet supported..."))
        end
    end
	
    λ
end

# ╔═╡ b2a41b98-68d1-11eb-21b3-9b48c657591d
begin 
	ix = counter_ng()
	
	@test ix(:inc) == 1
	@test ix(:inc) == 2  
	@test ix(:inc) == 3
	
	@test ix(:dec) == 2
	@test ix(:dec) == 1
	
	@test ix(:reset) == 0
end

# ╔═╡ eadfe19a-68d1-11eb-05c0-43915ae2d1b1
begin 
	jy = counter_ng(init=100)
	
	@test jy(:inc) == 101
	@test jy(:inc) == 102  
	@test jy(:inc) == 103
	
	@test jy(:dec) == 102
	@test_throws ArgumentError jy(:rec)
	
	@test jy(:reset) == 0
end

# ╔═╡ Cell order:
# ╟─b6e6f16a-68ce-11eb-320d-6b292123f85a
# ╠═d8456146-68ce-11eb-2872-3d66933b3385
# ╠═fbec986e-68ce-11eb-1598-619db8bca4cc
# ╠═3ed2de2e-68cf-11eb-1122-091e57ea014e
# ╠═48988162-68d1-11eb-22dc-2bbc0e41043b
# ╠═3750513e-68cf-11eb-0e76-7169551337af
# ╠═50a85e6a-68cf-11eb-0e5e-2f2cbbfcce73
# ╠═80512f66-68cf-11eb-3f58-498f113425d4
# ╠═94a3ce9c-68cf-11eb-1a26-e57d02e78f19
# ╟─a5f7141a-68cf-11eb-3dd1-9b04e8b62317
# ╠═b2f4f754-68cf-11eb-3d27-dd9df6feb65f
# ╠═c06c4d8a-68cf-11eb-133e-ed1e6ae4c889
# ╠═cadfceca-68cf-11eb-1b1b-7fcc66d4c632
# ╠═d97425bc-68cf-11eb-20c0-2dcaf9ede5f4
# ╠═e0553894-68cf-11eb-0e1f-5be65d986ed8
# ╠═e4d32200-68cf-11eb-2ff7-0b227d2de510
# ╠═f250750e-68cf-11eb-3e4e-b5fcbcdf2320
# ╠═fcf27c16-68cf-11eb-3ae6-9b5a3d98c6ab
# ╠═07a84580-68d0-11eb-0dcc-2dfc25b93d8b
# ╟─0b7b3b18-68d0-11eb-0e84-57cbc7e344d1
# ╠═1c25a7be-68d0-11eb-29f3-4dd237a2ef2e
# ╠═44e600ba-68d0-11eb-122f-e9973916ffc8
# ╠═53b8de8a-68d0-11eb-34e0-c1bbb3824ede
# ╠═7174059e-68d0-11eb-01fe-e712691890a4
# ╠═840923b0-68d0-11eb-039f-05cd7abb2c04
# ╠═8c579696-68d0-11eb-1321-ad2e8290b3bd
# ╠═2542f116-68d1-11eb-0eb2-0fa4398666ee
# ╠═6d948d44-68d1-11eb-283f-95c7209184f3
# ╠═8d553214-68d1-11eb-29d7-d791c9dff9f4
# ╠═b2a41b98-68d1-11eb-21b3-9b48c657591d
# ╠═eadfe19a-68d1-11eb-05c0-43915ae2d1b1
