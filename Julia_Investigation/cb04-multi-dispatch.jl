### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
begin
	using Pkg
	
	try
		using DataFrames
		
	catch ArgumentError
		Pkg.add("DataFrames")
		using DataFrames
	end
end

# ╔═╡ 9608fdc8-807e-4be2-91f8-950c0ceec2dd
begin
	try
		using CategoricalArrays
		
	catch ArgumentError
		Pkg.add("CategoricalArrays")
		using CategoricalArrays
	end
	
	using PlutoUI
	using BenchmarkTools
end

# ╔═╡ 45d72214-919c-11eb-2e69-23c0786baacb
md"""
### Multiple dispatch to handle branching behavio

Src: [Julia 1.0 Cookbook -  Bogumił Kamiński , Przemysław Szufel - 2018](https://www.packtpub.com/product/julia-1-0-programming-cookbook/9781788998369)

"""

# ╔═╡ 25b36455-0e5a-4318-9bd3-0440ac0b0080
df = DataFrame(s = categorical(["a", "b", "c"]),
		n = 1.:3.,
		f = [sin, cos, missing]
		)

# ╔═╡ 173f0e52-1430-457d-ae2f-9277342194a7
typeof(df)

# ╔═╡ ced242ca-2352-4b3f-bf32-a095705756ef
md"""
Let us write a function to display the different types of data:
"""

# ╔═╡ a70143ea-4920-413f-a6c1-515eef6c4f78
begin
	simple_describe(v) = "Unknown Type"
	
	simple_describe(v::Vector{<: Number}) = "Numeric"
	
	simple_describe(v::CategoricalArray) = "Categorical"
end

# ╔═╡ 995ebcfe-5e8d-448c-a4ee-f992df4e0404
with_terminal() do
	println(methods(simple_describe))
end

# ╔═╡ 224a9eaa-7062-481f-8af3-098ba1988c5d
md"""
And now we can create a function that walks through a data frame:
"""

# ╔═╡ 6b7104b1-2a92-4278-996d-bf0acd972770
simple_display(df::DataFrame) = foreach(
		attr -> println(attr, ": ", simple_describe(df[!, attr])),
		propertynames(df)
	)

# ╔═╡ e432f0a0-45de-4f23-aab7-09a30b1b7bdc
simple_display₁(df::DataFrame) = foreach(
		c -> println(c[1], ": ", simple_describe(c[2])),
		eachcol(df)
	)

# ╔═╡ 5309bf0c-f34e-4496-8fb3-567f4f66f4e2
with_terminal() do
	simple_display(df)
end

# ╔═╡ ea0410df-31c6-4c95-bd1a-1b2873eade53
with_terminal() do
	simple_display₁(df)
end

# ╔═╡ 20453809-0799-43ba-a2a5-528cf462e3c5
md"""
**Remarks**

Such an approach to dispatching is not only convenient but can also speed up computations. In particular, the DataFrame type does not convey information about column type to the compiler, so this technique is especially useful. It is called a *barrier function*.
"""

# ╔═╡ 62b4299f-fc9c-4774-b0f4-5ea1bc2a53a6
ndf = DataFrame(x=1:10^6)

# ╔═╡ 4ae4fc10-2ce1-4240-9988-f1a37646c8e8
function helper(x)
	s = zero(eltype(x))
	for v ∈ x; s += v; end
	s
end

# ╔═╡ 2d7c22b4-9843-44d0-84e6-c8e53a4fbf73
function fn1(df)
	s = eltype(df[!, 1]) |> zero
	for v ∈ df[!, 1]; s += v; end
	s
end

# ╔═╡ b4d08c1c-7b97-429f-9c22-e5d18c43b89b
fn2(df) = helper(df[!, 1])

# ╔═╡ b4bb2738-7049-4045-8735-f7d1f1bf0313
with_terminal() do
	@btime fn1(ndf)
end

# ╔═╡ e23a7eb8-d676-49e5-9984-f2d6a93c3a19
with_terminal() do
	@btime fn2(ndf)
end

# ╔═╡ 85f955f5-0802-4738-8a90-88772b575ba2
md"""
The reason for the difference is that `fn1` is not specialized by the `Julia compiler` to the type of `df[!, 1]`, while in `fn2`, the work is passed to a helper function that knows the type of `x` at compilation time, and `Julia` is able to generate efficient code computing the desired value.
"""

# ╔═╡ Cell order:
# ╟─45d72214-919c-11eb-2e69-23c0786baacb
# ╠═15b8afb9-ace9-4b5b-894e-dce9dda5bf5f
# ╠═9608fdc8-807e-4be2-91f8-950c0ceec2dd
# ╠═25b36455-0e5a-4318-9bd3-0440ac0b0080
# ╠═173f0e52-1430-457d-ae2f-9277342194a7
# ╟─ced242ca-2352-4b3f-bf32-a095705756ef
# ╠═a70143ea-4920-413f-a6c1-515eef6c4f78
# ╠═995ebcfe-5e8d-448c-a4ee-f992df4e0404
# ╟─224a9eaa-7062-481f-8af3-098ba1988c5d
# ╠═6b7104b1-2a92-4278-996d-bf0acd972770
# ╠═e432f0a0-45de-4f23-aab7-09a30b1b7bdc
# ╠═5309bf0c-f34e-4496-8fb3-567f4f66f4e2
# ╠═ea0410df-31c6-4c95-bd1a-1b2873eade53
# ╟─20453809-0799-43ba-a2a5-528cf462e3c5
# ╠═62b4299f-fc9c-4774-b0f4-5ea1bc2a53a6
# ╠═4ae4fc10-2ce1-4240-9988-f1a37646c8e8
# ╠═2d7c22b4-9843-44d0-84e6-c8e53a4fbf73
# ╠═b4d08c1c-7b97-429f-9c22-e5d18c43b89b
# ╠═b4bb2738-7049-4045-8735-f7d1f1bf0313
# ╠═e23a7eb8-d676-49e5-9984-f2d6a93c3a19
# ╟─85f955f5-0802-4738-8a90-88772b575ba2
