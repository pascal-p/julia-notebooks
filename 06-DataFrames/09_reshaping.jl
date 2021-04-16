### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames

	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction DataFrames / 9 - Reshaping DataFrames

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/09_reshaping.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Wide to long
"""

# ╔═╡ 3ecd5008-03f0-4727-abba-345b8ac08e1d
x = DataFrame(id=[1, 2, 3, 4], id2=[1, 1, 2, 2], M1=[11, 12, 13, 14], M2=[111, 112, 113, 114])

# ╔═╡ b294ecbe-2f49-4e5d-bda9-78096463da07
stack(x, [:M1, :M2], :id)  ## first pass measure variables and then id-variable

# ╔═╡ 53eb03ad-2c1d-44e6-9f4d-e56c121d0845
md"""
add `view=true` keyword argument to make a view; in that case columns of the resulting dataframe share memory with columns of the source data frame, so the operation is *potentially unsafe*
"""

# ╔═╡ 59d52da1-01b9-4df2-b18a-db87f834eaac
## optionally you can rename columns
stack(x, ["M1", "M2"], "id", variable_name="key", value_name="observed")

# ╔═╡ 8b34aaef-4a4e-4751-ac4f-4765910244aa
md"""
if second argument is omitted in stack, all other columns are assumed to be the id-variables
"""

# ╔═╡ 196f3066-f8a8-40c4-8db8-719108b86e38
stack(x, Not([:id, :id2]))

# ╔═╡ 8dae04b5-bb93-4f1a-9272-84ac47935394
stack(x, Not([1, 2]))  ## we can use index instead of symbol

# ╔═╡ f8eeacd5-5085-4652-9aef-d31a128fe682
nx = DataFrame(id=[1, 1, 1], id2=['a', 'b', 'c'], a1=rand(3), a2=rand(3))

# ╔═╡ f2ad2b0f-ff3f-49b0-8c4a-b28359ebabe7
md"""
if stack is not passed any measure variables by default numeric variables are selected as measures
"""

# ╔═╡ 25116592-668c-4ce9-b3d6-c04faab3ea21
stack(nx)

# ╔═╡ 0b94505f-3e6d-427f-939f-72c2bbf0aab2
md"""
Here all columns are treated as measures:
"""

# ╔═╡ db1ec4bd-60c5-4dac-a8a7-63731e4199d1
stack(DataFrame(rand(3, 2), :auto))

# ╔═╡ 1a78b75c-1c77-4c81-81d1-0769f7e2542f
begin
	df = DataFrame(rand(3, 2), :auto)
	df.key = [1, 1, 1]
	mdf = stack(df)                       ## duplicates in key are silently accepted
end

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### Long to wide
"""

# ╔═╡ 806fff39-f475-4c30-8964-a7858c91bc81
x₁ = DataFrame(id=[1, 1, 1], id2=['a', 'b', 'c'], a1=rand(3), a2=rand(3))

# ╔═╡ 24e09155-38ec-4afb-82ef-17ab32d149fc
y₁ = stack(x₁)

# ╔═╡ c5ae24cf-c09d-45c7-bf45-3161250af616
unstack(y₁, :id2, :variable, :value)  ## standard unstack with a specified key

# ╔═╡ a16e6b3d-2a20-4f04-b34a-9428b8edc853
unstack(y₁, :variable, :value)        ## all other columns are treated as keys

# ╔═╡ 16886bba-11e7-4d71-8df6-6f958c4ee1a4
unstack(y₁)    ## all columns other than named :variable and :value are treated as keys

# ╔═╡ c986ec52-c3b8-4f8b-af87-df04c70c46a4
unstack(y₁, renamecols=n->string("unstacked_", n))  ## we can rename the unstacked columns

# ╔═╡ 3dad50c9-e60b-468c-be15-eab978c80128
df₁ = stack(DataFrame(rand(3, 2), :auto))

# ╔═╡ a9ebc088-20ab-44f9-88a9-aac9964796d7
@test_throws ArgumentError unstack(df₁, :variable, :value) 
## unable to unstack when no key column is present

# ╔═╡ c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
html"""
<style>
  main {
  	max-width: calc(800px + 25px + 6px);
  }

  .plutoui-toc.aside {
	background: linen;
  }

  h3, h4, h5 {
	background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
# ╠═794a5356-6e05-44b4-ad9d-375a1fa3613b
# ╟─d6993a5b-8158-4ce3-accb-8e8c514229b3
# ╟─de97ded0-3952-4188-9a43-a8f383e1ae65
# ╠═3ecd5008-03f0-4727-abba-345b8ac08e1d
# ╠═b294ecbe-2f49-4e5d-bda9-78096463da07
# ╟─53eb03ad-2c1d-44e6-9f4d-e56c121d0845
# ╠═59d52da1-01b9-4df2-b18a-db87f834eaac
# ╟─8b34aaef-4a4e-4751-ac4f-4765910244aa
# ╠═196f3066-f8a8-40c4-8db8-719108b86e38
# ╠═8dae04b5-bb93-4f1a-9272-84ac47935394
# ╠═f8eeacd5-5085-4652-9aef-d31a128fe682
# ╟─f2ad2b0f-ff3f-49b0-8c4a-b28359ebabe7
# ╠═25116592-668c-4ce9-b3d6-c04faab3ea21
# ╟─0b94505f-3e6d-427f-939f-72c2bbf0aab2
# ╠═db1ec4bd-60c5-4dac-a8a7-63731e4199d1
# ╠═1a78b75c-1c77-4c81-81d1-0769f7e2542f
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═806fff39-f475-4c30-8964-a7858c91bc81
# ╠═24e09155-38ec-4afb-82ef-17ab32d149fc
# ╠═c5ae24cf-c09d-45c7-bf45-3161250af616
# ╠═a16e6b3d-2a20-4f04-b34a-9428b8edc853
# ╠═16886bba-11e7-4d71-8df6-6f958c4ee1a4
# ╠═c986ec52-c3b8-4f8b-af87-df04c70c46a4
# ╠═3dad50c9-e60b-468c-be15-eab978c80128
# ╠═a9ebc088-20ab-44f9-88a9-aac9964796d7
# ╠═c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
