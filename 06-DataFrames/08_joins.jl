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
## Introduction DataFrames / 8 - Joining DataFrames

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/04_loadsave.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Preparing DataFrames for a join
"""

# ╔═╡ 815474c9-8d95-44c0-ac6c-4df825a61b09
x = DataFrame(ID=[1, 2, 3, 4, missing], name = ["Alice", "Bob", "Conor", "Dave","Zed"])

# ╔═╡ f4362c1b-c787-4b57-9279-00dbac74e445
y = DataFrame(id=[1, 2, 5, 6, missing], age = [21, 22, 23, 24, 99])

# ╔═╡ 3d73280f-89dc-4939-9fdf-11f9cadc3944
md"""
Rules for the on keyword argument:

  - a single Symbol or string if joining on one column with the same name, e.g. `on=:id`
  - a Pair of Symbols or string if joining on one column with different names, e.g. on=:id => :id2`
  - a vector of Symbols or strings if joining on multiple columns with the same name, e.g. `on=[:id1, :id2]`
  - a vector of Pairs of Symbols or strings if joining on multiple columns with the same name, e.g. `on=[:a1=>:a2, :b1=>:b2]`
  - a vector containing a combination of Symbols or strings or Pair of Symbols or strings, e.g. `on=[:a1=>:a2, :b1]`

"""

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### Standard joins: inner, left, right, outer, semi, anti

"""

# ╔═╡ a1ab6cc4-61e1-47dd-a573-8c8884345e5c
@test_throws ArgumentError innerjoin(x, y, on=:ID=>:id)  
## missing is not allowed to join-on by default

# ╔═╡ e155fefb-95ae-469e-bcc0-479bf321b1f9
innerjoin(x, y, on=:ID=>:id, matchmissing=:equal)

# ╔═╡ 5149af4b-4511-443b-abf5-9b53e38e1d45
leftjoin(x, y, on="ID"=>"id", matchmissing=:equal)

# ╔═╡ 0698c48c-b0d8-47a4-a1fb-eb93d0602815
rightjoin(x, y, on=:ID=>:id, matchmissing=:equal)

# ╔═╡ a7cf86b6-11cf-4e24-9d3f-9abec87503a6
outerjoin(x, y, on=:ID=>:id, matchmissing=:equal)

# ╔═╡ aec2bdaa-3e3f-42fb-8747-d9397148983c
semijoin(x, y, on=:ID=>:id, matchmissing=:equal)

# ╔═╡ e2d707ab-13b1-4f85-a688-d4f358a9c1d5
antijoin(x, y, on=:ID=>:id, matchmissing=:equal)

# ╔═╡ a4615e9b-d3d9-443a-9146-e411f9bbd749
md"""
### Cross join
"""

# ╔═╡ 7bc6197d-2c03-471b-b7ac-22f78fa6d383
crossjoin(DataFrame(x=[1, 2]), DataFrame(y=["a", "b", "c"]))  # no `on` argument

# ╔═╡ 79de555b-1858-4fda-adc7-d29c503a0f96


# ╔═╡ 1688d806-c5ef-40dd-8b09-2f9de434023b
md"""
### Complex cases of joins
"""

# ╔═╡ 4b1ba677-fa53-4acd-ba44-4f098e9e4ed5
cx = DataFrame(id1=[1, 1, 2, 2, missing, missing],
              id2=[1, 11, 2, 21, missing, 99],
              name = ["Alice", "Bob", "Conor", "Dave","Zed", "Zoe"])

# ╔═╡ c6a8e4af-63bb-49a6-b810-877a6fe7ab5d
cy = DataFrame(id1=[1, 1, 3, 3, missing, missing],
              id2=[11, 1, 31, 3, missing, 999],
              age = [21, 22, 23, 24, 99, 100])

# ╔═╡ b0015c63-6ee8-422f-95e5-98510b4c893e
innerjoin(cx, cy, on=[:id1, :id2], matchmissing=:equal)  ## joining on two columns

# ╔═╡ 1b8def29-f289-47cb-86ca-0b511e92e193
outerjoin(cx, cy, on=:id1, makeunique=true, indicator=:source, matchmissing=:equal) 
## with duplicates all combinations are produced

# ╔═╡ bfecee96-e044-40a6-a2c6-ab4fea31c975
## you can force validation of uniqueness of key on which you join

@test_throws ArgumentError innerjoin(cx, cy, on=:id1, makeunique=true, validate=(true, true),
	matchmissing=:equal)

# ╔═╡ 2ea96ebd-86d1-4def-8404-911d651b6dbf
md"""
mixed on argument for joining on multiple columns
"""

# ╔═╡ 4eae57b0-c23a-47c8-931c-9dc57508a7cc
x₁ = DataFrame(id1=1:6, id2=[1, 2, 1, 2, 1, 2], x1 = 'a':'f')

# ╔═╡ f58a6cbf-38d9-4874-ada7-39812c81a874
y₁ = DataFrame(id1=1:6, ID2=1:6, x2 = 'a':'f')

# ╔═╡ 68b6d030-0c1a-4a7c-913f-7e164eb835e0
innerjoin(x₁, y₁, on=[:id1, :id2=>:ID2])

# ╔═╡ 7434a9b0-9995-4c90-94ca-20778e677ea2
md"""
joining more than two data frames:
"""

# ╔═╡ 8aefe960-02eb-484b-bdf7-ade42d90295d
xs = [DataFrame("id"=>1:6, "v$i"=>((1:6) .+ 10i)) for i in 1:5]

# ╔═╡ e9909c0b-d57b-413b-bccc-0638ea66d43b
innerjoin(xs..., on=:id)   ## also for outerjoin and crossjoin

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
# ╠═815474c9-8d95-44c0-ac6c-4df825a61b09
# ╠═f4362c1b-c787-4b57-9279-00dbac74e445
# ╟─3d73280f-89dc-4939-9fdf-11f9cadc3944
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═a1ab6cc4-61e1-47dd-a573-8c8884345e5c
# ╠═e155fefb-95ae-469e-bcc0-479bf321b1f9
# ╠═5149af4b-4511-443b-abf5-9b53e38e1d45
# ╠═0698c48c-b0d8-47a4-a1fb-eb93d0602815
# ╠═a7cf86b6-11cf-4e24-9d3f-9abec87503a6
# ╠═aec2bdaa-3e3f-42fb-8747-d9397148983c
# ╠═e2d707ab-13b1-4f85-a688-d4f358a9c1d5
# ╟─a4615e9b-d3d9-443a-9146-e411f9bbd749
# ╠═7bc6197d-2c03-471b-b7ac-22f78fa6d383
# ╠═79de555b-1858-4fda-adc7-d29c503a0f96
# ╟─1688d806-c5ef-40dd-8b09-2f9de434023b
# ╠═4b1ba677-fa53-4acd-ba44-4f098e9e4ed5
# ╠═c6a8e4af-63bb-49a6-b810-877a6fe7ab5d
# ╠═b0015c63-6ee8-422f-95e5-98510b4c893e
# ╠═1b8def29-f289-47cb-86ca-0b511e92e193
# ╠═bfecee96-e044-40a6-a2c6-ab4fea31c975
# ╟─2ea96ebd-86d1-4def-8404-911d651b6dbf
# ╠═4eae57b0-c23a-47c8-931c-9dc57508a7cc
# ╠═f58a6cbf-38d9-4874-ada7-39812c81a874
# ╠═68b6d030-0c1a-4a7c-913f-7e164eb835e0
# ╟─7434a9b0-9995-4c90-94ca-20778e677ea2
# ╠═8aefe960-02eb-484b-bdf7-ade42d90295d
# ╠═e9909c0b-d57b-413b-bccc-0638ea66d43b
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
