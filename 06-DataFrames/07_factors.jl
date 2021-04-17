### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames
	# using Statistics
	using CategoricalArrays
	using Pipe

	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction DataFrames / 7 - working with CategoricalArrays.jl

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/07_factors.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Constructor
"""

# ╔═╡ 42476ba8-478d-49e2-94b5-80df7877a20f
x = categorical(["A", "B", "B", "C"])               ## unordered

# ╔═╡ bfffc9aa-9d20-4011-accf-ae379281209c
y = categorical(["A", "B", "B", "C"], ordered=true) ## ordered, by default order is sorting order

# ╔═╡ f61250b5-f3d9-496b-85be-c107685c9ba3
z = categorical(["A","B","B","C", missing])         ## unordered with missings

# ╔═╡ 7694c9d7-655a-4335-8478-8f7095c1805d
c = cut(1:10, 5) ## ordered, into equal counts, possible to rename labels and give custom breaks

# ╔═╡ 31d9f385-5926-4f9a-b085-c16a766063bb
@pipe DataFrame(x=cut(randn(100000), 10)) |>
      groupby(_, :x) |>
      combine(_, nrow)            ## just to make sure cut works right

# ╔═╡ 7109068b-5913-4622-8a74-6c54a9f05d4e
v = categorical([1, 2, 2, 3, 3])  ## contains integers not strings

# ╔═╡ d3ebccf9-b96d-4902-8fcd-bdf74e9e3169
Vector{Union{String, Missing}}(z) ## sometimes you need to convert back to a standard vector

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### Managing levels
"""

# ╔═╡ 5ace73ce-ca39-4565-90d2-ce6637408f8c
ary = [x, y, z, c, v]

# ╔═╡ 46fe7e92-91d2-44b0-978e-25b2304e01c5
isordered.(ary)                  ## check if categorical array is orderd

# ╔═╡ dcff20c4-e82f-4f9f-be0d-3b5d37bf766a
ordered!(x, true), isordered(x)  ## make x ordered

# ╔═╡ 29d813df-bac4-46f3-b859-78dda9819b6f
ordered!(x, false), isordered(x) ## and unordered again

# ╔═╡ 45d1eb30-d9c6-45ac-b45d-72074c3ae9b7
levels.(ary)                     ## list levels  

# ╔═╡ 725a4fdc-c46d-4e4f-894c-36616cbdbaed
unique.(ary)                     ## missing will be included

# ╔═╡ 751906fe-503f-435a-a73e-e4755c22d20c
y[1] < y[2]                      ## can compare as y is ordered

# ╔═╡ 15a37486-be1d-4098-98a8-10482190b81f
@test_throws ArgumentError v[1] < v[2] 
## not comparable, v is unordered although it contains integers

# ╔═╡ 7c71af4c-23fd-4a49-b4fe-8415e83dfb7c
y[2] < "A"      ## comparison against type underlying categorical value is possible

# ╔═╡ db7f8d20-7c20-4f5f-8cb3-496a9a9b24b7
@test_throws KeyError y[2] < "Z" 
## but it is treated as a level, and thus only valid levels are allowed

# ╔═╡ 775d8043-aac0-410d-98f4-df1fbad111b6
levels!(y, ["C", "B", "A"]) ## you can reorder levels, mostly useful for ordered CategoricalArrays

# ╔═╡ db1c777b-8b9c-4b50-b0d6-1a9093d48c35
y[1] < y[2]    ## observe that the order is changed

# ╔═╡ b3bb8f9e-3b4f-4b9b-a5b2-8f09e7b766e9
y[1] < "B"     ## level ordering is respected also when comparing with an underlying type

# ╔═╡ 6d83f001-47f2-4744-9e5d-8c0750f77cf7
@test_throws ArgumentError levels!(z, ["A", "B"]) 
## you have to specify all levels that are present

# ╔═╡ c6ad1156-7d24-4de4-ad56-f208180fedb8
levels!(z, ["A", "B"], allowmissing=true) 
## unless the underlying array allows for missings and force removal of levels

# ╔═╡ 491c112f-e266-43f8-ad6e-b54af3ff940a
z[1] = "B"; z   ## now z has only "B" entries

# ╔═╡ d451ce95-8272-42da-95de-33ee2d7a7b14
levels(z)       ## but it remembers the levels it had (the reason is mostly performance)

# ╔═╡ e2313fb2-2781-40ea-a1e8-67153dfa710e
begin
	droplevels!(z)  ## this way we can clean it up
	levels(z)
end

# ╔═╡ a4615e9b-d3d9-443a-9146-e411f9bbd749
md"""
### Data manipulation

"""

# ╔═╡ 9065a655-af23-4f3b-88cc-b21f245035a8
x, levels(x)

# ╔═╡ 7a809f76-36fb-4867-a87f-c237251fd6dd
# begin
# 	x[2] = "0"
# 	x, levels(x) ## new level added at the end (works only for unordered)
# end

# ╔═╡ bc223b35-929a-4912-a07b-f5cc9aa6a84f
v, levels(v)

# ╔═╡ 35d2408b-5252-4042-9f0f-edcc9d21b8a6
@test_throws MethodError v[1] + v[2] 
## even though the underlying data is Int, we cannot operate on it

# ╔═╡ e88e3cb2-d48f-4543-a575-ef7c3b575102
Vector{Int}(v)   ## you have either to retrieve the data by conversion (may be expensive)

# ╔═╡ b1f576e9-2145-4467-9d39-3e626db25ed4
get(v[1]) + get(v[2])            ## or get a single value

# ╔═╡ 80327e1c-faf3-44ce-aa61-e91796558892
get.(v)                          ## this will work for arrays without missings

# ╔═╡ c0986ddb-feae-4ffc-a054-81f09cb7c6d9
@test_throws MethodError get.(z) ## but will fail on missing values

# ╔═╡ 50a8f8f7-5857-4aa0-9dc6-09378dea2360
passmissing(get).(z)             ## you have to wrap it in passmissing

# ╔═╡ 59edffc4-8b66-4962-896f-3e9749281a87
Vector{Union{String, Missing}}(z) ## or do the conversion

# ╔═╡ bac73d64-1974-4717-a218-b6c650b8e3f9
recode([1, 2, 3, 4, 5, missing], 1=>10) 
## recode some values in an array; has also in place recode! equivalent

# ╔═╡ 542d11f5-3941-4de4-b96a-06142e84499b
recode([1, 2, 3, 4, 5, missing], "a", 1=>10, 2=>20) 
## here we provided a default value for not mapped recordings

# ╔═╡ f61e7337-db34-4c22-9df9-1b6a1753a261
recode([1, 2, 3, 4, 5, missing], 1=>10, missing=>"missing") 
## to recode Missing you have to do it explicitly

# ╔═╡ e08b1c3f-6fc9-468e-9e5a-b4d4012c811c
begin
	t = categorical([1:5; missing])
	t, levels(t)
end

# ╔═╡ dbfb0c05-a389-4bd2-9149-5d6724fc885e
begin
	recode!(t, [1,3]=>2)
	t, levels(t) # note that the levels are dropped after recode
end

# ╔═╡ 646169b5-df7e-4dd8-8c95-3476f4726058
begin
	t₁ = categorical([1, 2, 3], ordered=true)
	levels(recode(t₁, 2=>0, 1=>-1)) 
	## and if you introduce a new levels they are added at the end in the order of appearance
end

# ╔═╡ 577b2c8c-f059-4e9a-8911-8bab2d266319
begin
	t₂ = categorical([1, 2, 3, 4, 5], ordered=true) # when using default it becomes the last level
	levels(recode(t₂, 300, [1, 2]=>100, 3=>200))
end

# ╔═╡ a103be27-45af-4f86-b25b-143ee811c34d
md"""
### Comparisons
"""

# ╔═╡ 7716455a-6bc5-4fa5-8275-03420ffa697f
begin
	x₀ = categorical([1, 2, 3])
	xs = [x₀, categorical(x₀), categorical(x₀, ordered=true), categorical(x₀, ordered=true)]
	levels!(xs[2], [3, 2, 1])
	levels!(xs[4], [2, 3, 1])
	[a == b for a in xs, b in xs]  ## all are equal - comparison only by contents
end

# ╔═╡ e8a72937-65ac-486f-91f7-dd710b19e1d8
begin
	signature(x::CategoricalArray) = (x, levels(x), isordered(x)) 
	## this is actually the full 	signature of CategoricalArray

	## all are different, notice that x[1] and x[2] are unordered but have a different 
	## order of levels
	[signature(a) == signature(b) for a in xs, b in xs]
end

# ╔═╡ 5455528c-b692-4a44-8004-4992b61163db
@test_throws ArgumentError x₀[1] < x₀[2]
## you cannot compare elements of unordered CategoricalArray

# ╔═╡ 53b2f0f6-70d4-4a26-9f66-9a4d69773b4a
isless(t[1], t[2])  ## but you can do it for an ordered one (use `isless`)

# ╔═╡ 486de780-108e-4291-b251-8869d676ba31
isless(x[1], x[2])  ## isless works within the same CategoricalArray even if it is not ordered

# ╔═╡ d95df360-7718-4e64-994f-eb67271d3867
begin
	y₀ = deepcopy(x₀)  ## but not across categorical arrays
	@test_throws ArgumentError isless(x₀[1], y₀[2])
end

# ╔═╡ 1a593150-62aa-4150-a892-ec7e780fba64
isless(get(x₀[1]), get(y₀[2])) 
## you can use get to make a comparison of the contents of CategoricalArray

# ╔═╡ fb305059-cc46-4233-ad75-003a2bb3c649
x[1] == y[2]  ## equality tests works OK across CategoricalArrays

# ╔═╡ 64039ae5-c281-4bd4-9b69-92bf9238b77d
md"""
### Categorical columns in a DataFrame"
"""

# ╔═╡ a3f12968-59ea-4c03-b3dd-4dd22efc61fe
df = DataFrame(x = 1:3, y = 'a':'c', z = ["a","b","c"])

# ╔═╡ ba18cae0-5e7d-4634-915e-9dbc803e9f95
md"""
Convert all string columns to categorical in-place
"""

# ╔═╡ db301499-c92a-475b-88d9-539a5ae8c7b3
transform!(df, names(df, String) => categorical, renamecols=false)

# ╔═╡ 194a7be1-5eac-4473-a35f-59a8dc9088df
describe(df)

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
# ╠═42476ba8-478d-49e2-94b5-80df7877a20f
# ╠═bfffc9aa-9d20-4011-accf-ae379281209c
# ╠═f61250b5-f3d9-496b-85be-c107685c9ba3
# ╠═7694c9d7-655a-4335-8478-8f7095c1805d
# ╠═31d9f385-5926-4f9a-b085-c16a766063bb
# ╠═7109068b-5913-4622-8a74-6c54a9f05d4e
# ╠═d3ebccf9-b96d-4902-8fcd-bdf74e9e3169
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═5ace73ce-ca39-4565-90d2-ce6637408f8c
# ╠═46fe7e92-91d2-44b0-978e-25b2304e01c5
# ╠═dcff20c4-e82f-4f9f-be0d-3b5d37bf766a
# ╠═29d813df-bac4-46f3-b859-78dda9819b6f
# ╠═45d1eb30-d9c6-45ac-b45d-72074c3ae9b7
# ╠═725a4fdc-c46d-4e4f-894c-36616cbdbaed
# ╠═751906fe-503f-435a-a73e-e4755c22d20c
# ╠═15a37486-be1d-4098-98a8-10482190b81f
# ╠═7c71af4c-23fd-4a49-b4fe-8415e83dfb7c
# ╠═db7f8d20-7c20-4f5f-8cb3-496a9a9b24b7
# ╠═775d8043-aac0-410d-98f4-df1fbad111b6
# ╠═db1c777b-8b9c-4b50-b0d6-1a9093d48c35
# ╠═b3bb8f9e-3b4f-4b9b-a5b2-8f09e7b766e9
# ╠═6d83f001-47f2-4744-9e5d-8c0750f77cf7
# ╠═c6ad1156-7d24-4de4-ad56-f208180fedb8
# ╠═491c112f-e266-43f8-ad6e-b54af3ff940a
# ╠═d451ce95-8272-42da-95de-33ee2d7a7b14
# ╠═e2313fb2-2781-40ea-a1e8-67153dfa710e
# ╟─a4615e9b-d3d9-443a-9146-e411f9bbd749
# ╠═9065a655-af23-4f3b-88cc-b21f245035a8
# ╠═7a809f76-36fb-4867-a87f-c237251fd6dd
# ╠═bc223b35-929a-4912-a07b-f5cc9aa6a84f
# ╠═35d2408b-5252-4042-9f0f-edcc9d21b8a6
# ╠═e88e3cb2-d48f-4543-a575-ef7c3b575102
# ╠═b1f576e9-2145-4467-9d39-3e626db25ed4
# ╠═80327e1c-faf3-44ce-aa61-e91796558892
# ╠═c0986ddb-feae-4ffc-a054-81f09cb7c6d9
# ╠═50a8f8f7-5857-4aa0-9dc6-09378dea2360
# ╠═59edffc4-8b66-4962-896f-3e9749281a87
# ╠═bac73d64-1974-4717-a218-b6c650b8e3f9
# ╠═542d11f5-3941-4de4-b96a-06142e84499b
# ╠═f61e7337-db34-4c22-9df9-1b6a1753a261
# ╠═e08b1c3f-6fc9-468e-9e5a-b4d4012c811c
# ╠═dbfb0c05-a389-4bd2-9149-5d6724fc885e
# ╠═646169b5-df7e-4dd8-8c95-3476f4726058
# ╠═577b2c8c-f059-4e9a-8911-8bab2d266319
# ╟─a103be27-45af-4f86-b25b-143ee811c34d
# ╠═7716455a-6bc5-4fa5-8275-03420ffa697f
# ╠═e8a72937-65ac-486f-91f7-dd710b19e1d8
# ╠═5455528c-b692-4a44-8004-4992b61163db
# ╠═53b2f0f6-70d4-4a26-9f66-9a4d69773b4a
# ╠═486de780-108e-4291-b251-8869d676ba31
# ╠═d95df360-7718-4e64-994f-eb67271d3867
# ╠═1a593150-62aa-4150-a892-ec7e780fba64
# ╠═fb305059-cc46-4233-ad75-003a2bb3c649
# ╟─64039ae5-c281-4bd4-9b69-92bf9238b77d
# ╠═a3f12968-59ea-4c03-b3dd-4dd22efc61fe
# ╟─ba18cae0-5e7d-4634-915e-9dbc803e9f95
# ╠═db301499-c92a-475b-88d9-539a5ae8c7b3
# ╠═194a7be1-5eac-4473-a35f-59a8dc9088df
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
