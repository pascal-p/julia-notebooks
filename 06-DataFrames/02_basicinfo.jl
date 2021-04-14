### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ dac66550-6a42-11eb-18fd-1dbb51ebb356
using DataFrames, PlutoUI

# ╔═╡ b9438ea0-6a42-11eb-3203-bdef1a59bb19
md"""
## Introduction to DataFrames / 2

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/02_basicinfo.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ be11851f-b9a5-4140-9d56-fa0e1ec896f9
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 0c9061f5-92fc-4861-8920-acb7f16aea51
md"""
### Getting basic information about a DataFrame
"""

# ╔═╡ e8266538-6a42-11eb-0919-f7a19fd021ba
xdf = DataFrame(A = [1, 2], B = [1.0, missing], C = ["a", "b"])

# ╔═╡ f28d6da0-6a42-11eb-1bfd-edda225bd80a
size(xdf), size(xdf, 1), size(xdf, 2)

# ╔═╡ 02630c26-6a43-11eb-375b-d3bf7b722863
nrow(xdf), ncol(xdf)

# ╔═╡ 09ef1732-6a43-11eb-3ce5-6904ca52514f
describe(xdf)

# ╔═╡ 1436e9b8-6a43-11eb-1dde-d97c58bf5218
describe(xdf, cols=1:2)

# ╔═╡ 6ca3a755-9f7b-4b49-b15c-1989144e4e44
## A custom describe
describe(xdf, :eltype, :nmissing, :first => first, :last => last)

# ╔═╡ 20d87024-6a43-11eb-0a14-d5c00e2aafde
names(xdf)

# ╔═╡ 2c9fb4c6-6a43-11eb-3e4c-5d12a291df4a
propertynames(xdf)

# ╔═╡ 3534cd7e-6a43-11eb-2eb7-0fa46c82b12d
eltype.(eachcol(xdf))

# ╔═╡ 7f69dd67-3fa6-4c74-bf8c-4fecb087b74f
md"""
Let's create a large dataframe and have peek into it using `first` and `last`.
"""

# ╔═╡ 3f6d9596-6a43-11eb-3469-5dcd7f0332e0
begin
	n = 10
	ydf = DataFrame(rand(1:n, 1000, n))
end

# ╔═╡ 546cdee8-6a43-11eb-38a2-35fe89ae2dde
first(ydf, 3)

# ╔═╡ 5bc30e06-6a43-11eb-1625-015e8cb5bce1
last(ydf, 3)

# ╔═╡ cc4ffb73-ada8-4446-8914-9e1d5cf669d4
md"""
### DataFrames get and set operations

Re-using `xdf` DataFrame as defined a few cells above.
"""

# ╔═╡ c6786444-6a43-11eb-21b9-3d4a2722cdfd
# all get the vector stored in our DataFrame without copying it
xdf.A, xdf[!, 1], xdf[!, :A] 

# ╔═╡ 04e69443-e80d-45ea-9d59-fb5dd8bf11e5
xdf."A", xdf[!, "A"]   # the same using string indexing

# ╔═╡ d105dcca-6a43-11eb-07fe-cd24a5efcf2a
begin
	xdf[:, 1]                                  # note that this creates a copy...
	xdf[:, 1] === xdf[:, 1]                    # ...here is the proof
	
	objectid(xdf[:, 1]), objectid(xdf[:, 1])   # ...and another way to show this
end

# ╔═╡ 49729e83-ebb2-4514-bdaf-68db8847800a
md"""
To grab one row as a DataFrame, we can index as follows:
"""

# ╔═╡ 0ea18045-6d7e-4202-ab94-709ab6150201
xdf[1:1, :]

# ╔═╡ 288c1879-77db-4246-b087-5f4e7ee600c5
xdf[1, :] # this produces a DataFrameRow which is treated as 1-dim object similar to a NamedTuple

# ╔═╡ 2140fccb-bbbb-4bae-b3e0-40a850ca40b9
typeof(xdf[1:1, :]), typeof(xdf[1, :])

# ╔═╡ b9566a8c-748b-4696-8aed-d9add8a085d0
md"""
We can grab a single cell or element with the same syntax to grab an element of an array.
"""

# ╔═╡ 0ea6ef6d-d908-4888-9fa3-4bd5edefeea6
xdf[1, 2]

# ╔═╡ 2aae7a6a-21db-45ee-bcdf-619ee2ea5240
md"""
or a new DataFrame that is a subset of rows and columns:
"""

# ╔═╡ 9b8d271c-5def-46d4-a38d-a98a63e4d62c
xdf[1:2, 1:2]

# ╔═╡ 2e1155ca-0cfc-4113-b2ce-2ff770e51e52
md"""
We can also use a `Regexp` to select columns and `Not` from `InvertedIndices.jl` both to select rows and columns>
"""

# ╔═╡ af6641c1-d1eb-4ae0-9e31-63aed4793b14
xdf[Not(1), r"A"]

# ╔═╡ bd1f96af-21fb-4e9e-933b-c4b99a05d13a
md"""
**Reference (`!`) and copy (`:`)**
"""

# ╔═╡ 6f4ab986-81af-4fbd-93b2-546b3ad7c425
xdf[!, Not(1)]     # ! indicates that underlying columns are not copied

# ╔═╡ da813272-f45a-4fcd-a4ff-539bb4c924c1
xdf[:, Not(1)]     # (however) : means that the columns will get copied

# ╔═╡ 17f8d99c-0bf0-4442-b234-d8d4955482e0
md"""
Assignment of a scalar to a dataframe can be done in ranges using broadcasting:
"""

# ╔═╡ 3be6e5f8-777b-4f9a-9430-362880e842ad
begin
	xdf[!, :B] = convert.(Float64, xdf[!, :B])   ## Type conversion for column :B
	xdf[1:2, :B] .= π;                           ## broadcaset π over all rows
	xdf
end

# ╔═╡ 137dfe1f-0a3d-4d76-978a-70da3c178479
begin
	xdf[1:2, 1:2] .= 3;   ## Assignment over both columns :A(1) and :B(1), over all rows
	xdf
end

# ╔═╡ 5f890d28-43ef-40f3-b1ff-b32c9cd5773d
md"""
Assignment of a vector of length equal to the number of assigned rows using broadcasting:
"""

# ╔═╡ 20ae267b-c26b-49c5-9096-96190f868c18
begin
	xdf[1:2, 1:2] .= [2, 4]
	xdf
end

# ╔═╡ 49daec8a-0263-4f69-a27b-dc0efdf89c71
md"""
Assignment or of another data frame of matching size and column names, again using broadcasting:
"""

# ╔═╡ ed5ee6d9-ec3e-417c-8206-f62666d88c4f
begin
	xdf[1:2, 1:2] .= DataFrame([5 6; 7 8], [:A, :B])
	xdf
end

# ╔═╡ 05d0a958-6071-41ba-8219-98f040ac90ae
md"""
#### Caution

  - With `df[!, :col]` and `df.col` syntax we get a direct (non copying) access to a column of a data frame. This is *potentially unsafe* as we can easily corrupt data in the `df` dataframe if we resize, sort, etc. the column obtained in this way. *Therefore such access should be used with caution*.

  - Similarly `df[!, cols]` when `cols` is a collection of columns produces a new data frame that holds the same (not copied) columns as the source `df` dataframe. *Similarly, modifying the data frame obtained via `df[!, cols]` might cause problems with the consistency of `df`*.

  - The `df[:, :col]` and `df[:, cols]` syntaxes always copy columns so they are safe to use (and should generally be preferred except for performance or memory critical use cases).
"""

# ╔═╡ c0960534-f6a1-40f8-8b35-b19aa5b78ac2
md"""
Here are examples of how `Cols` and `Between` can be used to select columns of a data frame:
"""

# ╔═╡ 0bfe2061-cddb-4f9f-9b7e-33a3e703d084
xdf₁ = DataFrame(rand(4, 5), :auto)

# ╔═╡ 5055355b-a405-4d27-b2aa-9477bd5ee2c4
ydf₀ = xdf₁[:, Between(:x2, :x4)]     ## make a copy

# ╔═╡ 2623b999-d8b1-4cba-9f2b-4d644c672354
ydf₁ = xdf₁[:, Cols("x1", Between("x3", "x4"))]   ## make a copy

# ╔═╡ 3c8b682a-5387-40b6-b3cd-d8beaa09383c
begin
	ydf₁[!, :x3] .= 3
	ydf₁
end

# ╔═╡ b1d6b7e3-8c67-44b3-ae30-87302295e976
xdf₁   ## was not changed

# ╔═╡ 61ac92e7-f181-4554-809a-dba4b786acec
ydf₀   ## nor this dataframe

# ╔═╡ e5e723bd-aa8e-415c-b7c6-ffd49bbf1841
md"""
#### Views

We can simply create a view of a DataFrame (it is more efficient than creating a materialized selection). Here are the possible return value options.
"""

# ╔═╡ fe37621d-c903-4055-bdb9-0dbc98f9d524
@view xdf[1:2, 1]

# ╔═╡ 8624b878-775b-4e37-a5c5-9b1cf38ef614
@view xdf[1, 1]

# ╔═╡ 9d40b847-5ebc-4656-aa03-f918ccee3974
@view xdf[1, 1:2]   ## a DataFrameRow, the same as for xdf[1, 1:2] without a view

# ╔═╡ 12a63294-6a44-11eb-0f29-7dcf33acface
md"""
### Adding new columns to a DataFrame
"""

# ╔═╡ 8c59bad5-6a7c-4923-b088-07a225c57a96
xdf₂ = DataFrame();    ## Create an empty DataFrame

# ╔═╡ 91e94361-3b46-4e0f-b8c3-14ced0b2e71b
md"""
Using `setproperty`!
"""

# ╔═╡ 48c59474-ffb8-4c92-96d1-39dddcd39076
begin
	v = collect(1:5)
	xdf₂.a = v
	xdf₂
end

# ╔═╡ 2180b2ba-3201-49a6-a0d5-5549c00c7b37
xdf₂.a === v   ## no copy is performed

# ╔═╡ 4c3feedd-f3e0-4121-91b6-9b43b0840c9b
md"""
using `setindex`!
"""

# ╔═╡ dcf94057-a263-4b27-b086-db0c74953405
begin
	xdf₂[!, :b] = v
	xdf₂[:, :c] = v
	
	@assert xdf₂[!, :b] === v  ## no copy is performed
	@assert xdf₂[!, :c] !== v  ## copy performed
	
	xdf₂
end

# ╔═╡ 56ba4b95-5a94-46be-ab6c-c80a40daccec
begin
	xdf₂[!, :d] .= v
	xdf₂[:, :e] .= v

	## using broadcasting implies copy:
	@assert xdf₂[!, :d] !== v  ## copy performed
	@assert xdf₂[!, :e] !== v  ## copy performed
	
	xdf₂
end

# ╔═╡ f0c302ae-23c1-4019-80d9-d727f83b9815
md"""
Remember that columns `:a` and `:b` are not copies of `v`.
This can lead to silent errors.

For example the following code leads to a bug (note that calling `pairs` on `eachcol(df)` creates an iterator of (column name, column) pairs):
"""

# ╔═╡ e0f1d7c5-039a-4be6-9b84-e7434faafad6
with_terminal() do
	for (n, c) in pairs(eachcol(xdf₂))
    	println("$n: ", pop!(c))           ## side-effect !
	end
end

# ╔═╡ 73b293e6-4609-419f-afe6-5f1185ab58f7
md"""
note (above cell) that for column `:b` we printed 4 as 5 was removed from it when we used `pop!` on column `:a`.


Such mistakes sometimes happen. Because of this `DataFrames.jl` performs consistency checks before doing an expensive operation (most notably before showing a DataFrame).
"""

# ╔═╡ 09290340-e74c-4f2c-9962-ccac5dd334a8
collect(pairs(eachcol(xdf₂)))  ## The output confirms that the DataFrame got corrupted.

# ╔═╡ 5a53e3f7-1585-4d16-ad4a-1e88ec08ef83
md"""
`DataFrames.jl` supports a complete set of `getindex`, `getproperty`, `setindex!`, `setproperty!`, view, broadcasting, and broadcasting assignment operations. The details are explained here: [http://juliadata.github.io/DataFrames.jl/latest/lib/indexing/](http://juliadata.github.io/DataFrames.jl/latest/lib/indexing/).
"""

# ╔═╡ 96f4c0ff-8bd7-4622-9d32-d382f3674485
md"""
### Comparisons
"""

# ╔═╡ 0d0af2ac-a896-4f70-bc8f-8715342037f0
xdf₃ = DataFrame(rand(2,3), :auto)

# ╔═╡ f2715e53-7a02-4eb8-ac0e-28902540e3b9
xdf₄ = copy(xdf₃)

# ╔═╡ 2471303f-8618-4c09-a511-2decf60a1c6c
@assert xdf₃ == xdf₄   ## compares column names and contents

# ╔═╡ 1aa0c67e-c1b0-4f0d-958f-84562eb39d76
md"""
Create a minimally different DataFrame and use `isapprox` for comparison:
"""

# ╔═╡ bef79b4f-d498-4e4f-b635-d769d0e191fd
xdf₅ = xdf₃ .+ eps()

# ╔═╡ 14df0d21-dc58-4385-a29c-d339d54a0719
begin
	@assert xdf₅ ≠ xdf₃                          ## different
	@assert isapprox(xdf₅, xdf₅, atol=eps()/2)   ## approx. equal
end

# ╔═╡ 1bbbb4ca-5d4a-466a-8541-8cdf7fe6c92c
md"""
`missings` are handled as in `Julia Base`:
"""

# ╔═╡ 3dc2357e-0cc7-4259-95e3-bc9b41243ebe
xdfₘ = DataFrame(a=missing)

# ╔═╡ 2ea87bb2-2d60-40f3-8728-ed5460c6c0c8
xdfₘ == xdfₘ

# ╔═╡ 8d06d5d7-2fb9-4b6a-be3c-1f6fcc4fd7ba
begin
	@assert xdfₘ === xdfₘ
	isequal(xdfₘ, xdfₘ)
end

# ╔═╡ 56edf702-2972-482a-b371-5d9d5de38fcd
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
# ╟─b9438ea0-6a42-11eb-3203-bdef1a59bb19
# ╠═dac66550-6a42-11eb-18fd-1dbb51ebb356
# ╟─be11851f-b9a5-4140-9d56-fa0e1ec896f9
# ╟─0c9061f5-92fc-4861-8920-acb7f16aea51
# ╠═e8266538-6a42-11eb-0919-f7a19fd021ba
# ╠═f28d6da0-6a42-11eb-1bfd-edda225bd80a
# ╠═02630c26-6a43-11eb-375b-d3bf7b722863
# ╠═09ef1732-6a43-11eb-3ce5-6904ca52514f
# ╠═1436e9b8-6a43-11eb-1dde-d97c58bf5218
# ╠═6ca3a755-9f7b-4b49-b15c-1989144e4e44
# ╠═20d87024-6a43-11eb-0a14-d5c00e2aafde
# ╠═2c9fb4c6-6a43-11eb-3e4c-5d12a291df4a
# ╠═3534cd7e-6a43-11eb-2eb7-0fa46c82b12d
# ╟─7f69dd67-3fa6-4c74-bf8c-4fecb087b74f
# ╠═3f6d9596-6a43-11eb-3469-5dcd7f0332e0
# ╠═546cdee8-6a43-11eb-38a2-35fe89ae2dde
# ╠═5bc30e06-6a43-11eb-1625-015e8cb5bce1
# ╟─cc4ffb73-ada8-4446-8914-9e1d5cf669d4
# ╠═c6786444-6a43-11eb-21b9-3d4a2722cdfd
# ╠═04e69443-e80d-45ea-9d59-fb5dd8bf11e5
# ╠═d105dcca-6a43-11eb-07fe-cd24a5efcf2a
# ╟─49729e83-ebb2-4514-bdaf-68db8847800a
# ╠═0ea18045-6d7e-4202-ab94-709ab6150201
# ╠═288c1879-77db-4246-b087-5f4e7ee600c5
# ╠═2140fccb-bbbb-4bae-b3e0-40a850ca40b9
# ╟─b9566a8c-748b-4696-8aed-d9add8a085d0
# ╠═0ea6ef6d-d908-4888-9fa3-4bd5edefeea6
# ╟─2aae7a6a-21db-45ee-bcdf-619ee2ea5240
# ╠═9b8d271c-5def-46d4-a38d-a98a63e4d62c
# ╟─2e1155ca-0cfc-4113-b2ce-2ff770e51e52
# ╠═af6641c1-d1eb-4ae0-9e31-63aed4793b14
# ╟─bd1f96af-21fb-4e9e-933b-c4b99a05d13a
# ╠═6f4ab986-81af-4fbd-93b2-546b3ad7c425
# ╠═da813272-f45a-4fcd-a4ff-539bb4c924c1
# ╟─17f8d99c-0bf0-4442-b234-d8d4955482e0
# ╠═3be6e5f8-777b-4f9a-9430-362880e842ad
# ╠═137dfe1f-0a3d-4d76-978a-70da3c178479
# ╟─5f890d28-43ef-40f3-b1ff-b32c9cd5773d
# ╠═20ae267b-c26b-49c5-9096-96190f868c18
# ╟─49daec8a-0263-4f69-a27b-dc0efdf89c71
# ╠═ed5ee6d9-ec3e-417c-8206-f62666d88c4f
# ╟─05d0a958-6071-41ba-8219-98f040ac90ae
# ╟─c0960534-f6a1-40f8-8b35-b19aa5b78ac2
# ╠═0bfe2061-cddb-4f9f-9b7e-33a3e703d084
# ╠═5055355b-a405-4d27-b2aa-9477bd5ee2c4
# ╠═2623b999-d8b1-4cba-9f2b-4d644c672354
# ╠═3c8b682a-5387-40b6-b3cd-d8beaa09383c
# ╠═b1d6b7e3-8c67-44b3-ae30-87302295e976
# ╠═61ac92e7-f181-4554-809a-dba4b786acec
# ╟─e5e723bd-aa8e-415c-b7c6-ffd49bbf1841
# ╠═fe37621d-c903-4055-bdb9-0dbc98f9d524
# ╠═8624b878-775b-4e37-a5c5-9b1cf38ef614
# ╠═9d40b847-5ebc-4656-aa03-f918ccee3974
# ╟─12a63294-6a44-11eb-0f29-7dcf33acface
# ╠═8c59bad5-6a7c-4923-b088-07a225c57a96
# ╟─91e94361-3b46-4e0f-b8c3-14ced0b2e71b
# ╠═48c59474-ffb8-4c92-96d1-39dddcd39076
# ╠═2180b2ba-3201-49a6-a0d5-5549c00c7b37
# ╟─4c3feedd-f3e0-4121-91b6-9b43b0840c9b
# ╠═dcf94057-a263-4b27-b086-db0c74953405
# ╠═56ba4b95-5a94-46be-ab6c-c80a40daccec
# ╟─f0c302ae-23c1-4019-80d9-d727f83b9815
# ╠═e0f1d7c5-039a-4be6-9b84-e7434faafad6
# ╟─73b293e6-4609-419f-afe6-5f1185ab58f7
# ╠═09290340-e74c-4f2c-9962-ccac5dd334a8
# ╟─5a53e3f7-1585-4d16-ad4a-1e88ec08ef83
# ╟─96f4c0ff-8bd7-4622-9d32-d382f3674485
# ╠═0d0af2ac-a896-4f70-bc8f-8715342037f0
# ╠═f2715e53-7a02-4eb8-ac0e-28902540e3b9
# ╠═2471303f-8618-4c09-a511-2decf60a1c6c
# ╟─1aa0c67e-c1b0-4f0d-958f-84562eb39d76
# ╠═bef79b4f-d498-4e4f-b635-d769d0e191fd
# ╠═14df0d21-dc58-4385-a29c-d339d54a0719
# ╟─1bbbb4ca-5d4a-466a-8541-8cdf7fe6c92c
# ╠═3dc2357e-0cc7-4259-95e3-bc9b41243ebe
# ╠═2ea87bb2-2d60-40f3-8728-ed5460c6c0c8
# ╠═8d06d5d7-2fb9-4b6a-be3c-1f6fcc4fd7ba
# ╟─56edf702-2972-482a-b371-5d9d5de38fcd
