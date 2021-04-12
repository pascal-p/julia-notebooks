### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 2e0f805a-68d3-11eb-35c6-95c237883fcd
using PlutoUI

# ╔═╡ e5eee32e-68de-11eb-3267-33a033f1dab1
begin
	using Printf

	macro timeit(expr)
		quote
			local t₀ = time()         ## avoid poluting client env.
			local res = $(esc(expr))  ## eval. expr
			local dt = time() - t₀
			print("Ellapsed time: ")
			@printf("%.9f\n", dt)
			
			res                       ## finally return res
		end
	end
end

# ╔═╡ f6867c32-68df-11eb-042e-1bd6b900f6fa
using Test

# ╔═╡ dc528154-68d2-11eb-2f60-f3499c34b532
md"""
## Macros in Julia
"""

# ╔═╡ eb0c80ff-9b03-4391-a2b1-ff56e3e4c8a9
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ f88b338e-68d2-11eb-1fa8-0bf5b252e9b6
md"""
### Example: assert macro
"""

# ╔═╡ 04400be6-68d3-11eb-35b3-79c07b358527
macro assert(expr)
    :($expr ? nothing : error("Assertion failed: ", $(string(expr))))
end

# ╔═╡ 3f24e7a4-68d3-11eb-22b9-f70cbdfa1b76
md"""
### Assert with message
"""

# ╔═╡ 51b16460-68d3-11eb-0b52-1b31d835485a
macro assert(expr, msg)
    quote 
        if $expr
            nothing
        else
            local m = length($msg) == 0 ? "Assertion failed: " : string($msg, ' ') 
            error(m, $(string(expr)))
        end
    end
end

# ╔═╡ 1148416e-68d3-11eb-24b3-b1a15aa812a0
begin
	@assert 1 == 1.0
	
	@assert 1 != 42.0
end

# ╔═╡ 282df856-68d3-11eb-3424-23d08b7af6a3
@assert 1 == 0.0

# ╔═╡ 66f4760a-68d3-11eb-1426-871a3354d9dd
@assert 1 == 42.0

# ╔═╡ 736424d0-68d3-11eb-1ada-750f7c8d622c
@assert(1 == 42.0, "How come?")

# ╔═╡ 90ab2322-68d3-11eb-21f0-35e49b201db4
@assert 1 == 42.0 "How come?"   ## no parentheses, no comma

# ╔═╡ ba35d962-68d3-11eb-1e10-05a84354a399
md"""
### Macro timeit
"""

# ╔═╡ db90b314-68df-11eb-02d5-69315dac74ad
function fact(n::Integer)::Integer
	n < 0 && throw(ArgumentError("n should be positive"))
    (n == 0 || n == 1) && return 1
    n * fact(n - 1) # remember no tail recursion!
end

# ╔═╡ fdcc1536-68df-11eb-34e1-55281df41ceb
begin
	@test fact(0) == 1
	@test fact(1) == 1
	@test_throws ArgumentError fact(-2)
	@test fact(2) == 2
	@test fact(3) == 6
	@test fact(4) == 24
end

# ╔═╡ 8237cd88-68e0-11eb-111c-3b0c6245d629
with_terminal() do
	@timeit fact(7)
end

# ╔═╡ c7e510ca-68e0-11eb-3bfe-d338d10081aa
with_terminal() do
	@timeit fact(15)
end

# ╔═╡ 0923f20e-68e1-11eb-37ae-19e4a24f48b4
md"""
### Macro Trace
"""

# ╔═╡ 5b0d1a14-68e1-11eb-2068-b5b4249c0d61
macro trace(expr)
	quote
		local fn_name = $(string(expr.args[1]))
		local args = $(string(expr.args[2]))
		
		println("Start of exec. function ", string(fn_name), " with args: ", args)
		local res = $(esc(expr))    ## call the actual expr ≡ function
		println("End of exec. function ", string(fn_name))
		
		res
	end
end

# ╔═╡ 3dab143e-68e2-11eb-100c-016893824ccd
begin
	fn_α = function (α::Integer=2)  ## function builder
    	## this is a closure
    	λ(x::Integer) = x * α
	end

	double_fn = fn_α()
	triple = fn_α(3)
end

# ╔═╡ e5397084-68e1-11eb-3322-5956fa8fd17a
# let see the content of this macro, using another macro
@macroexpand @trace double_fn(2)

# ╔═╡ 86936d9a-68e2-11eb-2217-47e57c631638
begin
	expr = :(double_fn(3))
	
	expr.args
end

# ╔═╡ a60c13b6-68e2-11eb-3fab-f73606ea715d
@test triple(11) == 33

# ╔═╡ b4e68d26-68e2-11eb-3bf9-bbba25301549
with_terminal() do
	@trace triple(11)
end

# ╔═╡ df8b48a8-68e2-11eb-1698-8f414b4a7fc4
md"""
### Macro unless
"""

# ╔═╡ ebe12cb4-68e2-11eb-216e-a3869afd2b1f
macro unless0(cond, body)
	quote
		if !$(esc(cond))
			$(esc(body))
		end
	end
end

# ╔═╡ 2599be12-68e3-11eb-07c4-376988e519d0
with_terminal() do
	x = 2
	
	@unless0 x < 0 begin
		println("we are done with x: $(x)")
	end
end

# ╔═╡ 6c19c67a-68e3-11eb-1c71-21ffa0892f7d
with_terminal() do
	x = -1
	
	@unless0 x < 0 begin
		println("we are done with x: $(x)")
	end
end

# Expect nothing

# ╔═╡ 78acc86c-68e3-11eb-2048-0969c36a0f1a
macro unless(cond, body)
	:(!$(esc(cond)) && $(esc(body)))
	
	# ≡ @eval $expr ? nothing : $body
end

# ╔═╡ a3511828-68e3-11eb-07ec-4de4d1836d95
with_terminal() do
	x = 2
	
	@unless x < 0 begin
		println("we are done with x: $(x)")
	end
end

# ╔═╡ a5bdc6f6-68e3-11eb-2248-fb359467846d
md"""
### Expression
"""

# ╔═╡ c3b46a5c-68e3-11eb-0edd-9f98a253f055
with_terminal() do
	dump(:(2 + a * b - c))
end

# ╔═╡ dee8a4f0-68e3-11eb-2336-abcb7af27dcf
with_terminal() do
	dump(:(-c + 2 - a * b))
end

# ╔═╡ a87243cb-3c70-4ecd-ad6e-80a876d6d261
html"""
<style>
  main {
        max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
        background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─dc528154-68d2-11eb-2f60-f3499c34b532
# ╠═2e0f805a-68d3-11eb-35c6-95c237883fcd
# ╟─eb0c80ff-9b03-4391-a2b1-ff56e3e4c8a9
# ╟─f88b338e-68d2-11eb-1fa8-0bf5b252e9b6
# ╠═04400be6-68d3-11eb-35b3-79c07b358527
# ╠═1148416e-68d3-11eb-24b3-b1a15aa812a0
# ╠═282df856-68d3-11eb-3424-23d08b7af6a3
# ╠═3f24e7a4-68d3-11eb-22b9-f70cbdfa1b76
# ╠═51b16460-68d3-11eb-0b52-1b31d835485a
# ╠═66f4760a-68d3-11eb-1426-871a3354d9dd
# ╠═736424d0-68d3-11eb-1ada-750f7c8d622c
# ╠═90ab2322-68d3-11eb-21f0-35e49b201db4
# ╟─ba35d962-68d3-11eb-1e10-05a84354a399
# ╠═e5eee32e-68de-11eb-3267-33a033f1dab1
# ╠═db90b314-68df-11eb-02d5-69315dac74ad
# ╠═f6867c32-68df-11eb-042e-1bd6b900f6fa
# ╠═fdcc1536-68df-11eb-34e1-55281df41ceb
# ╠═8237cd88-68e0-11eb-111c-3b0c6245d629
# ╠═c7e510ca-68e0-11eb-3bfe-d338d10081aa
# ╟─0923f20e-68e1-11eb-37ae-19e4a24f48b4
# ╠═5b0d1a14-68e1-11eb-2068-b5b4249c0d61
# ╠═e5397084-68e1-11eb-3322-5956fa8fd17a
# ╠═3dab143e-68e2-11eb-100c-016893824ccd
# ╠═86936d9a-68e2-11eb-2217-47e57c631638
# ╠═a60c13b6-68e2-11eb-3fab-f73606ea715d
# ╠═b4e68d26-68e2-11eb-3bf9-bbba25301549
# ╟─df8b48a8-68e2-11eb-1698-8f414b4a7fc4
# ╠═ebe12cb4-68e2-11eb-216e-a3869afd2b1f
# ╠═2599be12-68e3-11eb-07c4-376988e519d0
# ╠═6c19c67a-68e3-11eb-1c71-21ffa0892f7d
# ╠═78acc86c-68e3-11eb-2048-0969c36a0f1a
# ╠═a3511828-68e3-11eb-07ec-4de4d1836d95
# ╟─a5bdc6f6-68e3-11eb-2248-fb359467846d
# ╠═c3b46a5c-68e3-11eb-0edd-9f98a253f055
# ╠═dee8a4f0-68e3-11eb-2336-abcb7af27dcf
# ╟─a87243cb-3c70-4ecd-ad6e-80a876d6d261
