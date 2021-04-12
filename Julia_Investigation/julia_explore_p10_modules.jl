### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ e1a58fce-68e7-11eb-28e0-1dfcb1dd2da9
begin
	push!(LOAD_PATH, "../../../../Julia/Julia_Projects/02_modules/")
	using Letters
end

# ╔═╡ eb6d37b4-68e7-11eb-2edb-75552408475d
begin
	push!(LOAD_PATH, "../../../../Julia/Julia_Projects/02_modules/")
	import Numbers
end

# ╔═╡ f64b4784-68e7-11eb-063c-b373fbf05182
include("../../../../Julia/Julia_Projects/02_modules/Letters.jl")

# ╔═╡ c559673c-68e7-11eb-1d60-f53b2158b21c
md"""
### Loading modules with using
"""

# ╔═╡ 0c4ce83a-68e8-11eb-2677-eb6c5dea141e
names(Letters)

# ╔═╡ 1104b66e-68e8-11eb-3283-0387f513e1b5
names(Letters, all=true)

# ╔═╡ 15a40d8c-68e8-11eb-2cc3-fb7be8f74647
Letters.rand_string()

# ╔═╡ 1ca2cd9e-68e8-11eb-100c-fdee2f7cd4b2
begin
	# using Letters: my_name, MY_NAME # from here we no longer need to prefix these "objects" with Letters
	# my_name
	# my_name()
end

# ╔═╡ e251a020-68e7-11eb-2f5f-71145240b647
md"""
### Loading modules with import
"""

# ╔═╡ 36a82734-68e8-11eb-0570-69c26a8f6aea
names(Numbers)

# ╔═╡ 3bc25f70-68e8-11eb-2476-8f0b891d8f09
names(Numbers,all =true)

# ╔═╡ 3ba009fa-68e8-11eb-212c-c139505444bb
Numbers.half_rand()

# ╔═╡ 3b61ec42-68e8-11eb-240d-c7211691226a
Numbers.MY_NAME

# ╔═╡ 3b09e948-68e8-11eb-274e-afc96a0f2c36
Numbers.my_name()

# ╔═╡ ec2b956a-68e7-11eb-0cae-ad84f259746a
md"""
### Loading modules with include
"""

# ╔═╡ 6bec9754-68e8-11eb-3424-454616577b81
# using Letters

# ╔═╡ 7e24e980-68e8-11eb-1f06-d1e1e3ac8f12
# using Main.Letters

# ╔═╡ 8704a19e-68e8-11eb-29ea-57bac063da49
# rand_string()

# ╔═╡ Cell order:
# ╟─c559673c-68e7-11eb-1d60-f53b2158b21c
# ╠═e1a58fce-68e7-11eb-28e0-1dfcb1dd2da9
# ╠═0c4ce83a-68e8-11eb-2677-eb6c5dea141e
# ╠═1104b66e-68e8-11eb-3283-0387f513e1b5
# ╠═15a40d8c-68e8-11eb-2cc3-fb7be8f74647
# ╠═1ca2cd9e-68e8-11eb-100c-fdee2f7cd4b2
# ╟─e251a020-68e7-11eb-2f5f-71145240b647
# ╠═eb6d37b4-68e7-11eb-2edb-75552408475d
# ╠═36a82734-68e8-11eb-0570-69c26a8f6aea
# ╠═3bc25f70-68e8-11eb-2476-8f0b891d8f09
# ╠═3ba009fa-68e8-11eb-212c-c139505444bb
# ╠═3b61ec42-68e8-11eb-240d-c7211691226a
# ╠═3b09e948-68e8-11eb-274e-afc96a0f2c36
# ╟─ec2b956a-68e7-11eb-0cae-ad84f259746a
# ╠═f64b4784-68e7-11eb-063c-b373fbf05182
# ╠═6bec9754-68e8-11eb-3424-454616577b81
# ╠═7e24e980-68e8-11eb-1f06-d1e1e3ac8f12
# ╠═8704a19e-68e8-11eb-29ea-57bac063da49
