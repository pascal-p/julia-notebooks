### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames
	using Statistics
	using CategoricalArrays
	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction to DataFrames / 3 - Missing values

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/03_missingvalues.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Handling missing values

A `Julia` singleton type `Missing` allows us to deal with missing values:
"""

# ╔═╡ 624c9b0a-e7e8-4ec7-8802-dcf12a71117e
missing, typeof(missing)

# ╔═╡ 0921e011-b191-4b27-ac9e-17ea3bc0105f
md"""
Arrays automatically create an appropriate union type.
"""

# ╔═╡ 1fb36dcf-0b6a-4ab0-8c0f-0b2c7f23c3c9
begin
	x = [1, 2, missing, 3];
	typeof(x)
end

# ╔═╡ c64cd43a-8a17-4d2f-8d69-0db1073b7968
md"""
`ismissing` (predicate) function checks if a passed value is missing.
"""

# ╔═╡ 58aeff5c-3f12-4bbb-82b9-84bddb2159dd
ismissing.(x)   ## using broadcasting

# ╔═╡ 60f16698-3f4a-4a15-9366-10e7f801d9f5
md"""
We can extract the type combined with `Missing` from a `Union` via `nonmissingtype`

This is useful for arrays, see:
"""

# ╔═╡ 94ccb18d-4ea6-40f7-aa90-314d2c5704cc
eltype(x), nonmissingtype(eltype(x))

# ╔═╡ dcac6464-a916-4c57-9f8a-991b98baa4db
md"""
missing comparisons produce missing.
"""

# ╔═╡ 6e2620ac-736e-4531-b580-fd4bbf6112e7
missing == missing, missing != missing , missing < missing

# ╔═╡ a1f09f3b-e49d-49e2-8b82-aed03374b896
md"""
This is also true when missings are compared with values of other types.
"""

# ╔═╡ 123870b9-a79f-4fa7-b8b8-24e81a989ad9
1 == missing, π != missing , missing < √2

# ╔═╡ 92eccb60-fbf3-464f-a207-60dc2e23ebe6
md"""
`isequal`, `isless`, and `===` produce results of type `Bool`. 

**Note that `missing` is considered greater than any numeric value.**
"""

# ╔═╡ 673e843d-0ce8-4cae-bc38-37aed282e4e6
isequal(missing, missing), missing === missing, isequal(1, missing), isless(1, missing)

# ╔═╡ cf1e4d30-2c35-49b9-a917-55df01522788
md"""
In the next few examples, we see that many (*not all!*) functions handle missing.
"""

# ╔═╡ ee9e58dd-2d41-4fc8-81f1-8b9c348df8bc
map(x -> x(missing), [sin, cos, zero, sqrt])   ## part 1

# ╔═╡ 1f71ca99-9b15-43e4-8afc-15ffc5d4a1a1
map(x -> x(missing, 1), [+, - , *, /, div])    ## part 2 - arithmetic ops

# ╔═╡ d6c88a1c-80b3-49c0-84af-716c28974f42
map(x -> x([1, 2, missing]), 
	[minimum, maximum, extrema, mean, float])  ## part 3

# ╔═╡ fb6deb6c-c503-4a9d-8a4c-7f1c4c24ca76
md"""
`skipmissing` returns iterator skipping missing values. We can use `collect` and `skipmissing` to create an array that excludes these missing values."
"""

# ╔═╡ 9d7df124-4942-44c2-807b-f5c39d14ec14
skipmissing([1, missing, 2, missing]) |> collect

# ╔═╡ e8ffd09a-1944-4d0f-926d-0fb1f9dda7a4
md"""
Here we use `replace` to create a new array that replaces all missing values with some value (`NaN` in this case).
"""

# ╔═╡ a108cd54-45f7-48ec-a130-441dc7cf0f5e
replace([1.0, missing, 2.0, missing], missing => NaN)

# ╔═╡ 4049c78a-2250-42f1-b548-6fd0925711bf
md"""
Another way to do this:
"""

# ╔═╡ aeacb14c-db6f-4363-948c-00588ccb4583
coalesce.([1.0, missing, 2.0, missing], NaN)

# ╔═╡ 7e385236-ff48-4f6d-af46-924c727c25d7
md"""
We can also use `recode` from `CategoricalArrays.jl` if we have a default output value.
"""

# ╔═╡ 8fa0b5c6-22a4-46ba-ac06-4c1c71a0304a
recode([1.0, missing, 2.0, missing], false, missing => true)

# ╔═╡ e9eb3ad3-9278-4d5c-8de8-4821939080c6
md"""
There are also `replace!` and `recode!` functions that work in place.

Here is an example how you can to missing inputation in a data frame.
"""

# ╔═╡ 56a979fe-dc5e-4416-8f85-47f1f9db0285
df = DataFrame(a=[1, 2, missing], b=["a", "b", missing])

# ╔═╡ d32c9670-c8f9-46a5-ac54-4f9639325a5c
md"""
we change `df.a` vector in place:
"""

# ╔═╡ 9c8574fe-c181-4017-aada-00508d8360e3
replace!(df.a, missing => 999)

# ╔═╡ cf55fe7e-c5b9-46f0-815b-785f1fc64a95
md"""
Now we overwrite `df.b` with a new vector, because the replacement type is different than what `eltype(df.b)` accepts:
"""

# ╔═╡ 9f1fb12a-39bb-479a-b115-5364c7ea999d
df.b = coalesce.(df.b, 100)

# ╔═╡ 53c20047-c44d-44b9-93a6-9b093c326c0b
df

# ╔═╡ 38f2f006-3d80-4190-bbf8-e87c8400dbb4
md"""
We can use `unique` or `levels` to get unique values with or without missings, respectively.
"""

# ╔═╡ 2284ff98-9303-4d98-9409-34b2ac28117d
unique([1, missing, 2, missing]), levels([1, missing, 2, missing])

# ╔═╡ 47687957-622a-4ca4-9b45-361b011d4af9
md"""
In this next example, we convert x to y with `allowmissing`, where y has a type that accepts missings.
"""

# ╔═╡ 82a421c5-2b80-44d5-9bfb-242877ea624d
begin
	x₁ = [1, 2, 3]
	y₁ = allowmissing(x₁)
	typeof(y₁)
end

# ╔═╡ 7080eca8-faba-4c70-a7ba-a843d3ccb459
md"""
Then, we convert back with `disallowmissing`. This would fail if `y` contained missing values!
"""

# ╔═╡ 29010c54-cd2f-41e8-81fc-5354e4ca7f6e
begin
	z₁ = disallowmissing(y₁)
	x₁, y₁, z₁
end

# ╔═╡ 7021180c-01a1-4565-be9d-53e72ffee9bc
md"""
`disallowmissing` has an `error` keyword argument that can be used to decide how it should behave when it encounters a column that actually contains a missing value.
"""

# ╔═╡ ae893d9e-9ea5-4ea9-94d8-d646b8699088
df₁ = allowmissing(DataFrame(ones(2, 3), :auto))

# ╔═╡ 8d7b3298-8f14-4d21-a569-04c61ade9bda
df₁[1, 1] = missing

# ╔═╡ 9f8c6697-33bf-4362-96b1-98ab5802dd9e
df₁

# ╔═╡ e1a6c188-2299-494e-92a7-ab4556a59c85
@test_throws MethodError disallowmissing(df₁)    ## an error is thrown 

# ╔═╡ 140fe595-4d87-4282-b880-b7d73dd2ecdb
disallowmissing(df₁, error=false) # column :x1 is left untouched as it contains missing

# ╔═╡ 1dd4fba9-c80d-44c0-8a6d-ff88a6dd9545
md"""
In this next example, we show that the type of each column in x is initially `Int64`. After using `allowmissing!` to accept missing values in columns 1 and 3, the types of those columns become `Union{Int64,Missing}`.
"""

# ╔═╡ 3bcca454-4077-4714-b6c9-a2c50f0a7748
with_terminal() do
	x₂ = DataFrame(rand(Int, 2,3), :auto)
	println("Before: ", eltype.(eachcol(x₂)))

	allowmissing!(x₂, 1)       # make first column accept missings
	allowmissing!(x₂, :x3)     # make :x3 column accept missings

	println("After: ", eltype.(eachcol(x₂)))
end

# ╔═╡ 5d4237f4-8bcc-47cf-a21d-8fe3c56e5ec1
md"""
In this next example, we will use `completecases` to find all the rows of a DataFrame that have complete data.
"""

# ╔═╡ 6a3921f9-ceb7-47e2-a042-574dc01d7951
with_terminal() do
	x₂ = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])
	println("Complete cases:\n", completecases(x₂))
end

# ╔═╡ 99efee9e-d7b5-4bdb-ad60-f6613545bbd9
md"""
We can use `dropmissing` or `dropmissing!` to remove the rows with incomplete data from a DataFrame and either create a new DataFrame or mutate the original in-place.
"""

# ╔═╡ bbffa430-3ae8-42f8-80cc-04c646c3ae89
begin
	x₂ = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])
	y₂ = dropmissing(x₂)
	dropmissing!(x₂), describe(x₂)
end

# ╔═╡ 5fe7ddc1-b36d-4757-a213-d7a5a437ef14
md"""
Alternatively you can pass `disallowmissing` keyword argument to `dropmissing` and `dropmissing!`
"""

# ╔═╡ 5bb6d14f-af90-4a46-ab25-168cf7e57670
x₃ = DataFrame(A=[1, missing, 3, 4], B=["A", "B", missing, "C"])

# ╔═╡ 47bb179b-f865-4d48-8e4f-317af7fbf590
dropmissing!(x₃, disallowmissing=false)

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### Making functions missing-aware

If we have a function that does not handle missing values we can wrap it using `passmissing` function so that if any of its positional arguments is missing we will get a missing value in return. 

In the example below we change how string function behaves:
"""

# ╔═╡ 13e1f76a-baac-4a79-b150-3be8af1d2d54
string(missing)

# ╔═╡ a6d55bb4-8c4e-4eee-8452-df6510d3dcc4
string(missing, " ", missing)

# ╔═╡ e6d047c6-40d4-4bb4-b566-1878d59f3172
string(1, 2, 3)

# ╔═╡ 8c7187f7-ad7d-47e2-8152-26969ed66f58
lift_string = passmissing(string)

# ╔═╡ d8a357b2-a6f3-4aa4-978b-b7d5967efae9
lift_string(missing)  ## No longer string "missing" but instead the value missing

# ╔═╡ 1d4e483c-4217-49fa-bee1-6c4f729dd823
lift_string(missing, " ", missing)

# ╔═╡ adc9610d-01f6-4060-97d2-9b3a4d0970d5
lift_string(1, 2, 3)

# ╔═╡ a4615e9b-d3d9-443a-9146-e411f9bbd749
md"""
### Aggregating rows containing missing values

Create an example DataFrame containing missing values:
"""

# ╔═╡ 19982031-e9a0-4a17-aad2-18d816096f45
df₂ = DataFrame(a=[1, missing, missing], b=[1, 2, missing])

# ╔═╡ 609834b7-c4fc-4f5e-9ec3-f442e084c94c
md"""
If we just run `sum` on the rows we get two missing entries:
"""

# ╔═╡ a27323a5-d651-41d0-a588-5d5fd9395522
sum.(eachrow(df₂))

# ╔═╡ 9c886a50-b929-4ef5-bbae-a727d7b691b1
md"""
We can apply `skipmissing` on the rows to avoid this problem
"""

# ╔═╡ 1fc8067a-da59-4e6b-a8e6-7e32fcad49dd
@test_throws ArgumentError sum.(skipmissing.(eachrow(df₂)))  ## However this triggers another problem 

# ╔═╡ 372b242d-81eb-4b99-84e1-7cc79f244a1c
md"""
We get an error. The problem is that the last row of `df₂` contains only missing values, and since eachrow is type unstable the `eltype` of the result of `skipmissing` is unknown (so it is marked `Any`), see:
"""

# ╔═╡ e6a28a9e-942c-407d-9b99-da9bf1e594ff
skipmissing(eachrow(df₂)[end]) |> collect

# ╔═╡ 85063cfc-9992-4530-bf15-5d101b64e170
md"""
In such cases it is useful to switch to `Tables.namedtupleiterator` which is type stable as discussed in `01_constructors.ipynb` notebook.
"""

# ╔═╡ 77330f55-8ec6-492b-9e08-00dfcbb004eb
Tables.namedtupleiterator(df₂) .|> 
	skipmissing .|> 
    sum

# ≡ sum.(skipmissing.(Tables.namedtupleiterator(df)))

# ╔═╡ c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
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
# ╟─b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
# ╠═794a5356-6e05-44b4-ad9d-375a1fa3613b
# ╟─d6993a5b-8158-4ce3-accb-8e8c514229b3
# ╟─de97ded0-3952-4188-9a43-a8f383e1ae65
# ╠═624c9b0a-e7e8-4ec7-8802-dcf12a71117e
# ╟─0921e011-b191-4b27-ac9e-17ea3bc0105f
# ╠═1fb36dcf-0b6a-4ab0-8c0f-0b2c7f23c3c9
# ╟─c64cd43a-8a17-4d2f-8d69-0db1073b7968
# ╠═58aeff5c-3f12-4bbb-82b9-84bddb2159dd
# ╟─60f16698-3f4a-4a15-9366-10e7f801d9f5
# ╠═94ccb18d-4ea6-40f7-aa90-314d2c5704cc
# ╟─dcac6464-a916-4c57-9f8a-991b98baa4db
# ╠═6e2620ac-736e-4531-b580-fd4bbf6112e7
# ╟─a1f09f3b-e49d-49e2-8b82-aed03374b896
# ╠═123870b9-a79f-4fa7-b8b8-24e81a989ad9
# ╟─92eccb60-fbf3-464f-a207-60dc2e23ebe6
# ╠═673e843d-0ce8-4cae-bc38-37aed282e4e6
# ╟─cf1e4d30-2c35-49b9-a917-55df01522788
# ╠═ee9e58dd-2d41-4fc8-81f1-8b9c348df8bc
# ╠═1f71ca99-9b15-43e4-8afc-15ffc5d4a1a1
# ╠═d6c88a1c-80b3-49c0-84af-716c28974f42
# ╟─fb6deb6c-c503-4a9d-8a4c-7f1c4c24ca76
# ╠═9d7df124-4942-44c2-807b-f5c39d14ec14
# ╟─e8ffd09a-1944-4d0f-926d-0fb1f9dda7a4
# ╠═a108cd54-45f7-48ec-a130-441dc7cf0f5e
# ╟─4049c78a-2250-42f1-b548-6fd0925711bf
# ╠═aeacb14c-db6f-4363-948c-00588ccb4583
# ╟─7e385236-ff48-4f6d-af46-924c727c25d7
# ╠═8fa0b5c6-22a4-46ba-ac06-4c1c71a0304a
# ╟─e9eb3ad3-9278-4d5c-8de8-4821939080c6
# ╠═56a979fe-dc5e-4416-8f85-47f1f9db0285
# ╟─d32c9670-c8f9-46a5-ac54-4f9639325a5c
# ╠═9c8574fe-c181-4017-aada-00508d8360e3
# ╟─cf55fe7e-c5b9-46f0-815b-785f1fc64a95
# ╠═9f1fb12a-39bb-479a-b115-5364c7ea999d
# ╠═53c20047-c44d-44b9-93a6-9b093c326c0b
# ╟─38f2f006-3d80-4190-bbf8-e87c8400dbb4
# ╠═2284ff98-9303-4d98-9409-34b2ac28117d
# ╟─47687957-622a-4ca4-9b45-361b011d4af9
# ╠═82a421c5-2b80-44d5-9bfb-242877ea624d
# ╟─7080eca8-faba-4c70-a7ba-a843d3ccb459
# ╠═29010c54-cd2f-41e8-81fc-5354e4ca7f6e
# ╟─7021180c-01a1-4565-be9d-53e72ffee9bc
# ╠═ae893d9e-9ea5-4ea9-94d8-d646b8699088
# ╠═8d7b3298-8f14-4d21-a569-04c61ade9bda
# ╠═9f8c6697-33bf-4362-96b1-98ab5802dd9e
# ╠═e1a6c188-2299-494e-92a7-ab4556a59c85
# ╠═140fe595-4d87-4282-b880-b7d73dd2ecdb
# ╟─1dd4fba9-c80d-44c0-8a6d-ff88a6dd9545
# ╠═3bcca454-4077-4714-b6c9-a2c50f0a7748
# ╟─5d4237f4-8bcc-47cf-a21d-8fe3c56e5ec1
# ╠═6a3921f9-ceb7-47e2-a042-574dc01d7951
# ╟─99efee9e-d7b5-4bdb-ad60-f6613545bbd9
# ╠═bbffa430-3ae8-42f8-80cc-04c646c3ae89
# ╟─5fe7ddc1-b36d-4757-a213-d7a5a437ef14
# ╠═5bb6d14f-af90-4a46-ab25-168cf7e57670
# ╠═47bb179b-f865-4d48-8e4f-317af7fbf590
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═13e1f76a-baac-4a79-b150-3be8af1d2d54
# ╠═a6d55bb4-8c4e-4eee-8452-df6510d3dcc4
# ╠═e6d047c6-40d4-4bb4-b566-1878d59f3172
# ╠═8c7187f7-ad7d-47e2-8152-26969ed66f58
# ╠═d8a357b2-a6f3-4aa4-978b-b7d5967efae9
# ╠═1d4e483c-4217-49fa-bee1-6c4f729dd823
# ╠═adc9610d-01f6-4060-97d2-9b3a4d0970d5
# ╟─a4615e9b-d3d9-443a-9146-e411f9bbd749
# ╠═19982031-e9a0-4a17-aad2-18d816096f45
# ╟─609834b7-c4fc-4f5e-9ec3-f442e084c94c
# ╠═a27323a5-d651-41d0-a588-5d5fd9395522
# ╟─9c886a50-b929-4ef5-bbae-a727d7b691b1
# ╠═1fc8067a-da59-4e6b-a8e6-7e32fcad49dd
# ╟─372b242d-81eb-4b99-84e1-7cc79f244a1c
# ╠═e6a28a9e-942c-407d-9b99-da9bf1e594ff
# ╟─85063cfc-9992-4530-bf15-5d101b64e170
# ╠═77330f55-8ec6-492b-9e08-00dfcbb004eb
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
