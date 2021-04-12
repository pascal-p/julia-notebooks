### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ b8dda4e4-68e4-11eb-36ba-9df2d25c7737
using PlutoUI

# ╔═╡ 6e09faa6-68e6-11eb-3478-39a74c43259f
using Test

# ╔═╡ 4c32defe-68e4-11eb-2ccd-2b7bd29fbebd
md"""
### Functions in Julia / 2
"""

# ╔═╡ 676fac42-68e4-11eb-207b-19080677a358
md"""
##### Partial Application
"""

# ╔═╡ 43c74f81-2272-48df-b10a-fc6d345fe836
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 75354800-68e4-11eb-1d71-79b19115a8ab
function partial(fn::Function, x...)
    # lamdba
    (y...) -> fn(x..., y...)
end

# ╔═╡ 8dc62d9e-68e4-11eb-0d1d-61902cf5bd41
adder(x::Integer, y::Integer) = x + y

# ╔═╡ 9c57cbce-68e4-11eb-0617-5f9625aed520
begin
	add_2 = partial(adder, 2)
	
	with_terminal() do
		println(typeof(add_2))
	end
end

# ╔═╡ def5be8c-68e4-11eb-2186-bf8cf9dcaf2f
add_2(4)

# ╔═╡ ea11e87c-68e4-11eb-2bec-378c16cde8c3
md"""
#### Partial implemented as a macro
"""

# ╔═╡ f749b858-68e4-11eb-11a1-8bbdff30bcaa
macro partial(fn, args...)
	return :( (nargs...) -> $(esc(fn))($(esc(args))..., nargs...) )
end

# ╔═╡ 3dd12e5a-68e5-11eb-0fe6-858be3b23e04
@macroexpand @partial(adder, 2)

# ╔═╡ 6007a636-68e5-11eb-290d-7be1776c9b66
padd2 = @partial(adder, 2)

# ╔═╡ 2c8cc072-68e6-11eb-2f75-77e00bc75da3
padd2(3)

# ╔═╡ 407660a2-68e6-11eb-17b7-290309df8a69
f(a, b, c, x, y, z) = √((x - a)^2 + (y - b)^2 + (z - c)^2)

# ╔═╡ 4c60d834-68e6-11eb-0b4d-815b5ddec42f
@macroexpand @partial(f, 1, 2, 3)

# ╔═╡ 62934240-68e6-11eb-0da0-77ac10d3a66f
f123 = @partial(f, 1, 2, 3)

# ╔═╡ 7645d79c-68e6-11eb-0c4e-056ac6abb291
@test f123(0, 0, 0) == √14

# ╔═╡ 7f23d1cc-68e6-11eb-13fe-3b28848804ba
@test f123(1, 2, 0) == 3

# ╔═╡ 0562f2a6-0a70-440c-99b7-61e3441dcb96
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
# ╟─4c32defe-68e4-11eb-2ccd-2b7bd29fbebd
# ╟─676fac42-68e4-11eb-207b-19080677a358
# ╠═b8dda4e4-68e4-11eb-36ba-9df2d25c7737
# ╟─43c74f81-2272-48df-b10a-fc6d345fe836
# ╠═75354800-68e4-11eb-1d71-79b19115a8ab
# ╠═8dc62d9e-68e4-11eb-0d1d-61902cf5bd41
# ╠═9c57cbce-68e4-11eb-0617-5f9625aed520
# ╠═def5be8c-68e4-11eb-2186-bf8cf9dcaf2f
# ╟─ea11e87c-68e4-11eb-2bec-378c16cde8c3
# ╠═f749b858-68e4-11eb-11a1-8bbdff30bcaa
# ╠═3dd12e5a-68e5-11eb-0fe6-858be3b23e04
# ╠═6007a636-68e5-11eb-290d-7be1776c9b66
# ╠═2c8cc072-68e6-11eb-2f75-77e00bc75da3
# ╠═407660a2-68e6-11eb-17b7-290309df8a69
# ╠═4c60d834-68e6-11eb-0b4d-815b5ddec42f
# ╠═62934240-68e6-11eb-0da0-77ac10d3a66f
# ╠═6e09faa6-68e6-11eb-3478-39a74c43259f
# ╠═7645d79c-68e6-11eb-0c4e-056ac6abb291
# ╠═7f23d1cc-68e6-11eb-13fe-3b28848804ba
# ╟─0562f2a6-0a70-440c-99b7-61e3441dcb96
