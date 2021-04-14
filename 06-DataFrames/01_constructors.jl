### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 629d929c-6a3d-11eb-0413-5185929928cb
begin
	using DataFrames, Random
	using PlutoUI
end

# ╔═╡ 0b08257e-6a3d-11eb-3da0-ed75be40d90e
md"""
## Introduction to DataFrames

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/01_constructors.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ 2c93b1b1-39f7-49c3-8d19-060fac1dba52
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 81665132-6a3d-11eb-37b7-991da3953909
md"""
### Constructors and Conversions

#### Constructors
"""

# ╔═╡ 82e2153c-6a3d-11eb-0397-e78654843e7e
DataFrame();  ## create an empty DataFrame

# ╔═╡ b037eb42-6a3d-11eb-0443-c3fef979ac19
begin
	n = 5
	DataFrame(A=1:n, B=rand(n), C=randstring.([n for _ ∈ 1:n]), fixed=42)
	## a 5 × 4 DataFrame - 
	## Remark on fixed column, the scalar gets automatically broadcasted
end

# ╔═╡ 18ff9300-6a3e-11eb-158b-5bec35b58c84
begin
	## Create a DataFrame from a dictionary
	hsh = Dict(:A => collect(1:n), :B => [x % 2 == 0 for x ∈ 1:n], 
		:C => [x % 2 == 0 ? 'a' : 'b' for x ∈ 1:n], 
		:fixed => Ref([1 for _ ∈ 1:n]))
	
	DataFrame(hsh)
end

# ╔═╡ 6c87db40-6a3e-11eb-3a1c-7d3c95ffc793
md"""
**Remarks**

This time we used `Ref` to protect a vector from being treated as a column and forcing broadcasting it into every row of :fixed column (note that the [1, 1, 1, 1, 1] vector is aliased in each row).

Rather than explicitly creating a dictionary first, as above, we could pass `DataFrame` arguments with the syntax of dictionary key-value pairs.
"""

# ╔═╡ 9c069eba-6a3e-11eb-0b99-69c73c8db3f8
DataFrame(:A => collect(1:n), :B => [x % 2 == 0 for x ∈ 1:n], 
	:C => [x % 2 == 0 ? 'a' : 'b' for x ∈ 1:n], 
	:fixed => Ref([1 for _ ∈ 1:n]))

# ╔═╡ c7eb6274-6a3e-11eb-3846-e337d215f871
## or pass a Vector of pairs
DataFrame([:A => collect(1:n),
		:B => [x % 2 == 0 for x ∈ 1:n],
		:C => [x % 2 == 0 ? 'a' : 'b' for x ∈ 1:n],
    	:fixed => "const"])

# ╔═╡ eafc3138-6a3e-11eb-11e8-c333d5bf13c1
## Create a DataFrame from a vector of vectors, and each vector becomes a column.
DataFrame([rand(Float32, n) for _ ∈ 1:n])

# ╔═╡ d53123d6-6a3e-11eb-1304-c938d3ffc423
## As above with explicit column naming
DataFrame([rand(n) for _ ∈ 1:n], [Symbol(String("y$(ix)")) for ix ∈ 1:n])

# ╔═╡ 5f83c5b6-6a3f-11eb-09ad-2d01fa5e3a6e
## It is not allowed to pass a vector of scalars to the DataFrame constructor
## instead use a transposed vector
DataFrame(permutedims(collect(1:n)))

# ╔═╡ a3dd623a-6a3f-11eb-392d-5d188b60f5b3
## We can also pass a vector of NamedTuples to construct a DataFrame
DataFrame([(a=1, b=2, c=10), (a=3, b=4, c=6), (a=3, b=7, c=8)])

# ╔═╡ c7a51708-6a3f-11eb-0a86-ad52d4366887
## DataFrame from a matrix
DataFrame(rand(3, n), Symbol.('a':'e'))

# ╔═╡ dc5bc4ee-6a3f-11eb-07fa-21d227880d8e
## We can also create a DataFrame with no rows, but with predefined columns and their types:

DataFrame(A=Int[], B=Float64[], C=String[], D=Bool[], E=Symbol[])

# ╔═╡ fc951166-6a3f-11eb-0cce-71a959aed87a
## Finally, we can create a DataFrame by copying an existing DataFrame.
## Note that copy also copies the vectors.
begin
	xdf = DataFrame(a=1:n, b='a':'e')
	ydf = copy(xdf)
	
	## ===: same reference, isequal 2 different references, same content
	(xdf === ydf), isequal(xdf, ydf), (xdf.a == ydf.a), (xdf.a === ydf.a)
end

# ╔═╡ 2dc885e0-6a40-11eb-2bae-395fd78e1e4f
## Calling DataFrame on a DataFrame object works like copy.

begin
	df1 = DataFrame(a=1:n, b='a':'e')
	dfc1 = DataFrame(df1)
	(df1 === dfc1), isequal(df1, dfc1), (df1.a == dfc1.a), (df1.a === dfc1.a)
end

# ╔═╡ 65e148ba-6a40-11eb-3119-5faa428a40e9
## WE can avoid copying of columns of a data frame (if it is possible) by passing copycols=false keyword argument:

begin
	df2 = DataFrame(a=1:n, b='a':'e')
	dfc2 = DataFrame(df2, copycols=false)
	(df2 === dfc2), isequal(df2, dfc2), (df2.a == dfc2.a), (df2.a === dfc2.a)
end

# ╔═╡ aa41798c-6a40-11eb-32af-57cabd65363a
## Create a similar uninitialized DataFrame based on an original one:
ndf = DataFrame(a=1, b=1.0)

# ╔═╡ c8182d3e-6a40-11eb-014e-a344fba2bd93
similar(ndf)

# ╔═╡ d17d06d6-6a40-11eb-297d-7b94161b5187
## With number of rows explicitly stated
similar(ndf, 3)

# ╔═╡ f01bbc40-6a40-11eb-3c31-0fc5b5ea28da
## We can also create a new DataFrame from SubDataFrame or DataFrameRow 
sdf = view(ndf, [1, 1], :)

# ╔═╡ 06efd550-6a41-11eb-0a51-6b7d64d82815
typeof(sdf)

# ╔═╡ 126e028a-6a41-11eb-1466-8f3c8c02143e
dfr = ndf[1, :]

# ╔═╡ 1b067fd0-6a41-11eb-3c17-777d1204480b
DataFrame(dfr)

# ╔═╡ 82c5cb20-6a3d-11eb-34bb-8fa036f13b8b
md"""
#### Conversion to matrix
"""

# ╔═╡ 82aca774-6a3d-11eb-3477-f91467210f50
x_df = DataFrame(x=1:2, y=["A", "B"])

# ╔═╡ 82954234-6a3d-11eb-138a-f3e2372d13ed
Matrix(x_df)

# ╔═╡ 827557d0-6a3d-11eb-1d97-857d6de9f26a
Array(x_df)

# ╔═╡ 82178042-6a3d-11eb-346e-0f1886c3856f
## This would work even if the DataFrame had some missings:

y_df = DataFrame(x=1:2, y=[missing,"B"])

# ╔═╡ 6161d65a-6a41-11eb-09fc-0b70e80f7ba1
Matrix(y_df)

# ╔═╡ 77dc3074-6a41-11eb-2a05-474caf947205
md"""
#### Conversion to `NamedTuple` related tabular structures
"""

# ╔═╡ 817775f8-6a41-11eb-0e93-1d1cfc09a00e
nt_df = DataFrame(x=1:n, y=["A", "B", "C", "D", "E"])

# ╔═╡ 8fd83650-6a41-11eb-2a0a-8727e31109a8
## Conversion into a NamedTuple of vectors
ct = Tables.columntable(nt_df)

# ╔═╡ a943ea9e-6a41-11eb-022e-8dc8a75562b3
## Conversion into a vector of NamedTuples
rt = Tables.rowtable(nt_df)

# ╔═╡ c3e077a0-6a41-11eb-3f3a-cd35f67ac77b
## Conversion back to DataFrame

DataFrame(ct)

# ╔═╡ d62e7e8c-6a41-11eb-226c-75489e440d63
DataFrame(rt)

# ╔═╡ e8c4ebdc-6a41-11eb-26c9-cf0060b276da
md"""
### Iterating data frame by rows or columns
"""

# ╔═╡ f53608f6-6a41-11eb-2bcf-fb9dbc15c8a0
ec = eachcol(xdf)

# ╔═╡ 00596ffa-6a42-11eb-36a0-f7ca0c1616ce
ec isa AbstractVector

# ╔═╡ 1ed33062-6a42-11eb-279a-a7de8bfd1436
ec[1]

# ╔═╡ 24d7a5ec-6a42-11eb-0743-997a55fa7e31
## Can also use index 
ec[:a]

# ╔═╡ 4ea7ed00-6a42-11eb-3039-c904e26fdfd5
er = eachrow(xdf)

# ╔═╡ 5654c37a-6a42-11eb-1bd4-db7aacba9907
er isa AbstractVector

# ╔═╡ 58be76ba-6a42-11eb-040c-4d424ef55092
er[end]

# ╔═╡ 187c1633-6aa4-4e27-8707-cb8c24500273
html"""
<style>
  main {
  max-width: calc(800px + 25px + 6px);
  }

  .plutoui-toc.aside {
    background: linen;
  }

  h4, h5 {
  background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─0b08257e-6a3d-11eb-3da0-ed75be40d90e
# ╠═629d929c-6a3d-11eb-0413-5185929928cb
# ╟─2c93b1b1-39f7-49c3-8d19-060fac1dba52
# ╟─81665132-6a3d-11eb-37b7-991da3953909
# ╠═82e2153c-6a3d-11eb-0397-e78654843e7e
# ╠═b037eb42-6a3d-11eb-0443-c3fef979ac19
# ╠═18ff9300-6a3e-11eb-158b-5bec35b58c84
# ╟─6c87db40-6a3e-11eb-3a1c-7d3c95ffc793
# ╠═9c069eba-6a3e-11eb-0b99-69c73c8db3f8
# ╠═c7eb6274-6a3e-11eb-3846-e337d215f871
# ╠═eafc3138-6a3e-11eb-11e8-c333d5bf13c1
# ╠═d53123d6-6a3e-11eb-1304-c938d3ffc423
# ╠═5f83c5b6-6a3f-11eb-09ad-2d01fa5e3a6e
# ╠═a3dd623a-6a3f-11eb-392d-5d188b60f5b3
# ╠═c7a51708-6a3f-11eb-0a86-ad52d4366887
# ╠═dc5bc4ee-6a3f-11eb-07fa-21d227880d8e
# ╠═fc951166-6a3f-11eb-0cce-71a959aed87a
# ╠═2dc885e0-6a40-11eb-2bae-395fd78e1e4f
# ╠═65e148ba-6a40-11eb-3119-5faa428a40e9
# ╠═aa41798c-6a40-11eb-32af-57cabd65363a
# ╠═c8182d3e-6a40-11eb-014e-a344fba2bd93
# ╠═d17d06d6-6a40-11eb-297d-7b94161b5187
# ╠═f01bbc40-6a40-11eb-3c31-0fc5b5ea28da
# ╠═06efd550-6a41-11eb-0a51-6b7d64d82815
# ╠═126e028a-6a41-11eb-1466-8f3c8c02143e
# ╠═1b067fd0-6a41-11eb-3c17-777d1204480b
# ╟─82c5cb20-6a3d-11eb-34bb-8fa036f13b8b
# ╠═82aca774-6a3d-11eb-3477-f91467210f50
# ╠═82954234-6a3d-11eb-138a-f3e2372d13ed
# ╠═827557d0-6a3d-11eb-1d97-857d6de9f26a
# ╠═82178042-6a3d-11eb-346e-0f1886c3856f
# ╠═6161d65a-6a41-11eb-09fc-0b70e80f7ba1
# ╟─77dc3074-6a41-11eb-2a05-474caf947205
# ╠═817775f8-6a41-11eb-0e93-1d1cfc09a00e
# ╠═8fd83650-6a41-11eb-2a0a-8727e31109a8
# ╠═a943ea9e-6a41-11eb-022e-8dc8a75562b3
# ╠═c3e077a0-6a41-11eb-3f3a-cd35f67ac77b
# ╠═d62e7e8c-6a41-11eb-226c-75489e440d63
# ╟─e8c4ebdc-6a41-11eb-26c9-cf0060b276da
# ╠═f53608f6-6a41-11eb-2bcf-fb9dbc15c8a0
# ╠═00596ffa-6a42-11eb-36a0-f7ca0c1616ce
# ╠═1ed33062-6a42-11eb-279a-a7de8bfd1436
# ╠═24d7a5ec-6a42-11eb-0743-997a55fa7e31
# ╠═4ea7ed00-6a42-11eb-3039-c904e26fdfd5
# ╠═5654c37a-6a42-11eb-1bd4-db7aacba9907
# ╠═58be76ba-6a42-11eb-040c-4d424ef55092
# ╟─187c1633-6aa4-4e27-8707-cb8c24500273
