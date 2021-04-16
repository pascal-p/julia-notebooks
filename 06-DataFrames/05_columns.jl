### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames
	using BenchmarkTools
	using Statistics
	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction DataFrames / 5 - Manipulating columns

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/05_columns.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ ce0a87f7-8f0c-4c87-8fd1-8198edbec86c
md"""
### Renaming columns

Let us start with a DataFrame of Bools that has default column names.
"""

# ╔═╡ e7020e48-1e43-4f07-93a5-07ea1f1a63e7
x₀ = DataFrame(rand(Bool, 3, 4), :auto)

# ╔═╡ 9528b5ce-da9e-449f-a042-bb9033f8bffa
begin
	using Random
	Random.seed!(42)

	x₀[:, shuffle(names(x₀))]
end

# ╔═╡ 9a500d40-75c6-4914-86af-2c255255c1ad
md"""
With `rename`, we create new DataFrame; here we rename the column `:x1` to `:A`. (`rename` also accepts collections of Pairs.)
"""

# ╔═╡ 33bdbcf6-893e-46ce-9370-917b87045b72
rename(x₀, :x1 => :A)

# ╔═╡ 98379291-e308-4642-a71e-b8cb5cf6f376
md"""
With `rename!` we do an in place transformation.

This time we have applied a function to every column name (note that the function gets a column names as a string).
"""

# ╔═╡ 2f70c7eb-ab73-4447-9529-354995484739
rename!(c -> c^2, x₀)

# ╔═╡ 549aa400-44b0-4bfb-8cb4-81bffdb6cd41
md"""
We can also change the name of a particular column without knowing the original.

Here we change the name of the third column, creating a new DataFrame.
"""

# ╔═╡ 31edf126-68b7-435f-b286-0e762e8affaf
rename(x₀, 3 => :third)

# ╔═╡ bac788c3-fa41-4daa-a34c-4d5e3fd8c285
md"""
If we pass a vector of names to `rename!`, we can change the names of all variables.
"""

# ╔═╡ 3925258e-c5f2-42c0-9af2-8b60cf3d51d2
rename!(x₀, [:a, :b, :c, :d])

# ╔═╡ aedfb361-edc8-46a3-9497-75542db83642
md"""
In all the above examples you could have used strings instead of symbols, e.g.
"""

# ╔═╡ 45f24ad5-ff3e-48b6-8917-36ea094388f2
rename!(x₀, string.('a':'d'))

# ╔═╡ 6b133d04-6912-4c5b-9784-bf7eea64bc55
md"""
`rename!` allows for circular renaming of columns, e.g.:
"""

# ╔═╡ ae7e4869-a3cc-4012-8436-47d3af7d28c0
rename!(x₀, "a"=>"d", "d"=>"a")

# ╔═╡ 96958f4d-df91-44f1-89fd-088fb0c6682d
md"""
We get an error when we try to provide duplicate names
"""

# ╔═╡ bd4ece67-9755-448c-93a8-30b391178c0d
@test_throws ArgumentError rename(x₀, fill(:a, 4))

# ╔═╡ 5b7b3282-a516-4b21-980b-ef552e6b0c0f
rename(x₀, fill(:a, 4), makeunique=true)

# ╔═╡ 4f72dc4a-31b8-40a4-81d9-a727ed2c22b8
md"""
### Reordering columns

We can reorder the names(x) vector as needed, creating a new DataFrame.
"""

# ╔═╡ 41bac74c-b6f9-4896-9b8d-fcb4d6ce7d47
md"""
Also `select!` can be used to achieve this in place (or select to perform a copy):
"""

# ╔═╡ b4e3e3cb-27a6-4002-993b-b5a87587db06
select!(x₀, 4:-1:1); x₀

# ╔═╡ 15106b6a-4f96-4701-bf95-4f0ed2d988e7
md"""
### Merging/Adding columns
"""

# ╔═╡ 44b6e6a2-b22a-485e-b161-6a79513486e5
x₁ = DataFrame([(i, j) for i ∈ 1:3, j ∈ 1:4], :auto)

# ╔═╡ dd2c281c-34a6-4aa1-a339-6d2cc5baa455
md"""
With `hcat` we can merge two DataFrames. Also `[x y]` syntax is supported but only when DataFrames have unique column names.
"""

# ╔═╡ 97acfc11-79a5-48eb-b8e8-5b040bd92b8f
hcat(x₁, x₁, makeunique=true)

# ╔═╡ b1be6837-38dd-4313-8860-e73ac130b30d
md"""
We can also use `hcat` to add a new column; a default name `:x1` will be used for this column, so `makeunique=true` is needed in our case.
"""

# ╔═╡ 72bab76f-91bb-4f78-9dfb-c865ad271cfb
y₁ = hcat(x₁, [1, 2, 3], makeunique=true)

# ╔═╡ 4d2d3d2b-cf7d-4ca6-9da0-67d28f269db9
md"""
We can also prepend a vector with `hcat`.
"""

# ╔═╡ 5881f7e3-f6d9-4dfc-ba1d-dfa0fea2c07c
hcat([1, 2, 3], x₁, makeunique=true)

# ╔═╡ 5d103d4b-9ca8-4274-b556-acbce4aea876
md"""
Alternatively you could append a vector with the following syntax. This is a bit more verbose but cleaner.
"""

# ╔═╡ eb08d57b-69b8-4543-88ba-c56793210681
y₂ = [x₁ DataFrame(A=[1, 2, 3])]

# ╔═╡ a33dc13b-732c-4ecf-9295-9fa0f5bc417c
md"""
And here we do the same but add column `:A` to the front.
"""

# ╔═╡ e1d534a0-dc8e-4fd6-a35a-314985d6eba8
y₃ = [DataFrame(A=[1, 2, 3]) x₁]

# ╔═╡ 129c6825-9c01-400b-9318-74a3bde8c163
md"""
A column can also be added in the middle. Here a brute-force method is used and a new DataFrame is created.
"""

# ╔═╡ 33bb1d78-0bcd-4c04-8ef8-d9e62c9f16c6
with_terminal() do
	@btime [$x₁[!, 1:2] DataFrame(A=[1,2,3]) $x₁[!, 3:4]]
end

# ╔═╡ 483bfe0d-6e54-4355-8688-d34d9b68fad0
md"""
We could also do this with a specialized in place method `insertcols!`. Let's add `:newcol` to the DataFrame y₂.
"""

# ╔═╡ e14dfcec-5710-4051-895e-b2f0fdcd6c78
insertcols!(y₂, 2, "newcol" => [1, 2, 3])

# ╔═╡ c968b160-53cb-4ecc-ad11-78e4b09a73b8
md"""
If you want to insert the same column name several times `makeunique=true` is needed as usual.
"""

# ╔═╡ 016e5a00-49d6-4ce0-a6be-62287d5c928b
insertcols!(y₂, 2, :newcol => [1, 2, 3], makeunique=true)

# ╔═╡ f312fcc0-e8f4-4e1a-9a7a-b2f6675caac5
md"""
We can see how much faster it is to insert a column with `insertcols!` than with `hcat` using `@btime` (note that here we use a Pair notation as an example).
"""

# ╔═╡ c64a8915-c2e8-47fe-96e3-2ab7a066764f
with_terminal() do
	@btime insertcols!(copy($x₁), 3, :A => [1, 2, 3])
end

# ╔═╡ 52d33d1a-0e2c-4f32-a1fd-2380b656460d
md"""
Let's use `insertcols!` to append a column in place (note that we dropped the index at which we insert the column).
"""

# ╔═╡ 33dfd57c-9252-495d-b39b-caf96ab8008f
insertcols!(x₁, :A => 1:3)

# ╔═╡ 520123eb-9673-4c8f-af83-f6f36a621602
md"""
and to in place `prepend` a column.
"""

# ╔═╡ d8d90255-2393-4362-a239-798976e50a92
insertcols!(x₁, 1, :B => 1:3)

# ╔═╡ 76498ebd-e783-4716-8c9a-f0ef05616a8f
md"""
Note that `insertcols!` can be used to insert several columns to a dataframe at once and that it performs broadcasting if needed:
"""

# ╔═╡ 91f780ee-6e10-4124-9d80-d8a0164155fe
df₀ = DataFrame(a = [1, 2, 3])

# ╔═╡ d58ac235-cf27-4540-aaab-413b72d07418
insertcols!(df₀, :b => "x", :c => 'a':'c', :d => Ref([1, 2, 3]))

# ╔═╡ 4a8e2e67-8e97-4e09-bffc-8866ff566648
md"""
Interestingly we can emulate hcat mutating the data frame in-place using `insertcols!`:
"""

# ╔═╡ b693f3ac-bcf8-43fd-9060-753267d7bef9
df₁ = DataFrame(a=[1,2])

# ╔═╡ 60cf6f09-55b8-4a70-a208-9e13f43d64ce
df₂ = DataFrame(b=[2,3], c=[3,4])

# ╔═╡ 686cf84f-8bc1-4a74-90f2-cfc52d3963cf
hcat(df₁, df₂)  ## df₁ is not touched

# ╔═╡ 3510270e-7edc-4edc-bb9b-e1b274479300
insertcols!(df₁, pairs(eachcol(df₂))...)

# ╔═╡ ddce5237-d203-43cf-879c-a6dd91adbf55
df₁   ## now we have changed df1

# ╔═╡ 51011425-7eff-4742-9753-d67405de81d5
md"""
### Subsetting/Removing columns

Let us create a new DataFrame `sdf` and show a few ways to create DataFrames with a subset of `x`'s columns.
"""

# ╔═╡ 8a99674d-1e8a-4991-9390-9dad31b3d998
sdf = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)

# ╔═╡ fa280e7c-cdeb-484d-9678-6d1359ebe5f2
md"""
First we could do this by index:
"""

# ╔═╡ b3a8f83d-8150-456e-9682-2195a2ea4aea
sdf[:, [1, 2, 4, 5]]   ## use ! instead of : for non-copying operation

# ╔═╡ c8f0a8e0-e433-4607-af1a-dfe54df641d4
md"""
or by column name:
"""

# ╔═╡ 07ae5e0b-df47-4d7e-871d-a0ea8b4bb839
sdf[:, [:x1, :x4]]

# ╔═╡ cbfe95e6-dc80-4b62-9f68-6fd9d72196e9
md"""
We can also choose to keep or exclude columns by Bool (we need a vector whose length is the number of columns in the original DataFrame).
"""

# ╔═╡ 08c6994f-52c2-43be-b547-8b10dbfb0bcd
sdf[:, [true, false, true, false, true]]

# ╔═╡ ab2465b5-e837-44a6-983f-92c7489abb05
md"""
Here we create a single column DataFrame
"""

# ╔═╡ 198df989-3013-429f-94d5-a5af95e1e8fd
sdf[:, [:x1]]

# ╔═╡ 592d59cf-a253-4103-9610-3a7c232d9bbd
md"""
and here we access the vector contained in column `:x1`
"""

# ╔═╡ 8659fa70-cc8f-4a15-bd5d-d9b0cc13c52c
sdf[!, :x1]   ## use : instead of ! to copy

# ╔═╡ a525f4b8-eb1c-4e75-9829-1fe31c2dc620
sdf.x1        ## the same

# ╔═╡ b346fbd0-a135-4200-9f9d-756afe0221ce
md"""
We could grab the same vector by column number
"""

# ╔═╡ b934b67d-8d8e-4854-a038-3e1cf71bf15b
sdf[!, 1]

# ╔═╡ 18487733-491e-4a95-a44d-f5ef109695c7
md"""
**Note** that getting a single column returns it without copying while creating a new DataFrame performs a copy of the column:
"""

# ╔═╡ 21fe70fd-0799-43e1-92ce-340c7c523c3e
@assert sdf[!, 1] !== sdf[!, [1]]

# ╔═╡ 04abd76d-5b51-45e4-8e23-d9b568387fba
md"""
We can also use `Regex`, `All`, `Between` and `Not` from `InvertedIndies.jl` for column selection:
"""

# ╔═╡ 96f3cd04-f903-4f1c-be07-94860d381bd5
sdf[!, r"[12]"]

# ╔═╡ 6dd8de75-fabf-4659-aea5-33b40e219463
sdf[!, Not(1)]

# ╔═╡ 00f4efee-e0da-42a1-8f0a-b6d7a3f4a035
sdf[!, Between(:x2, :x4)]

# ╔═╡ 1fc27c5d-092b-4e54-9eca-6582bc00a241
sdf[!, Cols(:x1, Between(:x3, :x5))]

# ╔═╡ 303882ce-bff9-4295-80b4-873f96de1345
select(sdf, :x1, Between(:x3, :x5), copycols=false)  ## the same as above

# ╔═╡ 6b42aeef-6eda-47c6-9aa9-4d06a9738bce
md"""
We can use `select` and `select!` functions to select a subset of columns from a data frame. `select` creates a new data frame and `select!` operates in place
"""

# ╔═╡ f70a4b29-5ec6-44df-b231-7a429de639d0
ndf = copy(sdf)

# ╔═╡ 3b379422-e957-47de-96f8-62101bf391a8
ndf₂ = select(ndf, [1, 2])

# ╔═╡ 8c7e1e4e-98de-4f50-9999-234c0c7ef309
select(ndf, Not([1, 2]))

# ╔═╡ e41dfcc4-c92c-4548-985e-8cb8eb32c858
md"""
by default `select` copies columns
"""

# ╔═╡ a5acfa9e-6af8-47b1-b85a-95dab43b7fa8
@assert ndf₂[!, 1] !== ndf[!, 1]

# ╔═╡ 74ccb3d6-9ecf-4118-b913-afe49849bd11
md"""
This can be avoided by using `copycols=false` keyword argument
"""

# ╔═╡ c7dc731b-3e97-4439-805f-dab44d1f43de
ndf₃ = select(ndf, [1, 2], copycols=false)

# ╔═╡ 452a8e80-b98a-40df-b942-a9359e3546a1
@assert ndf₃[!, 1] === ndf[!, 1]

# ╔═╡ 98789796-33e4-415f-a7a6-76a55078c92f
md"""
Using `select!` will modify the source dataframe
"""

# ╔═╡ 7e51ffcf-86b6-4832-9246-57e69a8b1d85
select!(ndf, [1, 2])

# ╔═╡ 5b4e71a2-bbb4-42dc-9674-2823e0aafeef
@assert ndf == ndf₂

# ╔═╡ 795c4656-e789-48de-a38b-9b5c70c2b86f
md"""
Here we create a copy of `sdf` and delete the 3rd column from the copy with `select!` and `Not`.
"""

# ╔═╡ ed1fee04-a51b-4909-9dd1-972a917335df
begin
	dfz = copy(sdf)
	select!(dfz, Not(3))
end

# ╔═╡ 386f5384-fb9a-48c9-8a91-c8a812ab3e1a
md"""
Alternatively we can achieve the same by using the `select` function
"""

# ╔═╡ 108b3bdb-8275-4e6b-8b30-6c6a8f81f950
select(sdf, Not(3))

# ╔═╡ 6de67316-b33d-456b-8754-88cc8e43819e
sdf   ## sdf stays unchanged

# ╔═╡ 998d6542-ff01-43f9-aa21-9f48f0cefdd6
md"""
#### Views

Note, that we can also create a view of a DataFrame when we want a subset of its columns:
"""

# ╔═╡ a84445cf-1598-4558-a978-ca1c912e1303
with_terminal() do
	@btime sdf[:, [1,3,5]]
end

# ╔═╡ 2ec79047-6e56-4303-ac57-dce06620ad45
with_terminal() do
	@btime @view sdf[:, [1, 3, 5]]
end

# ╔═╡ ecb25704-6a75-4bd2-a598-145ff9982dc4
md"""
### Modify column by name
"""

# ╔═╡ 2cbc8d22-6e0d-4a39-8669-7e3ab5f11521
xdf = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)

# ╔═╡ e6386760-0bf2-4dcc-a4ae-849dc89cc220
md"""
With the following syntax, the existing column is *modified without performing any copying* (**this is discouraged as it creates column alias**).
"""

# ╔═╡ 6b10c9af-934e-4f37-8013-120b918626d0


# ╔═╡ ef253e41-17b4-436b-9ecf-fb425814ca35
md"""
This syntax is safer
"""

# ╔═╡ e6072582-80d7-402c-9869-55441f9bafcf
xdf[!, :x1] = xdf[:, :x2]; xdf

# ╔═╡ 74051d06-5b6a-4fec-b76c-db71fe767110
md"""
We can also use the following syntax to add a new column at the end of a DataFrame.
"""

# ╔═╡ 71a75892-2724-4ee1-b20f-02030959b49b
xdf[!, :A] = [1, 2, 3]; xdf

# ╔═╡ e2ebb352-df12-4abc-9c06-fde8175d5bce
md"""
A new column name will be added to our DataFrame with the following syntax as well:
"""

# ╔═╡ 2c436f30-26cd-496d-8f50-a5aecd4ea419
xdf.B = 11:13; xdf

# ╔═╡ 6950fc3b-6436-4894-a7ee-cdf299ae39dc
md"""
### Find column name
"""

# ╔═╡ e1c027a2-2547-4612-ad80-d6b815977ebb
dfx = DataFrame([(i,j) for i in 1:3, j in 1:5], :auto)

# ╔═╡ 3c4f5e66-4903-4a2d-a554-3ddec91d3bd2
md"""
We can check if a column with a given name exists via `hasproperty`:
"""

# ╔═╡ 9cf7e784-0b0d-46d9-b32e-23eee66d1451
@assert hasproperty(dfx, :x1)

# ╔═╡ 3cf08ee6-9555-4ed7-8356-985633984030
md"""
and determine its index via `columnindex`:
"""

# ╔═╡ fcc0b1b4-6e99-40a0-97ae-d1d451946510
columnindex(dfx, :x2)

# ╔═╡ a9a58863-587a-4ee8-91af-438b5049d835
md"""
### Advanced ways of column selection

These are most useful for non-standard column names (e.g. containing spaces)
"""

# ╔═╡ 9c2d17a2-3758-4ff9-a099-d8c50ed9289c
begin
	df = DataFrame()
	df.x1 = 1:3
	df[!, "column 2"] = 4:6
	df
end

# ╔═╡ b8125aba-a8da-436e-b658-de277f992836
df."column 2"

# ╔═╡ bdffb7fd-bcd0-463a-b7a2-f9dc066d191e
df[:, "column 2"]

# ╔═╡ 48d6dcea-c814-4568-a47f-9d92fcb51b3f
md"""
Or we can interpolate column name using `:()` syntax
"""

# ╔═╡ 0a6b0a70-b6e3-4b06-8b52-dd5f9714bacc
with_terminal() do
	for n in names(df)
   		println(n, "\n", df.:($n), "\n")
	end
end

# ╔═╡ 9de09d8d-3e55-402d-8907-1131a2287ae3
md"""
#### Working on a collection of columns

When using `eachcol` of a data frame the resulting object retains reference to its parent and e.g. can be queried with `getproperty`:
"""

# ╔═╡ f8a050a2-dfc6-4473-a54d-045435f2dd0a
dfₓ = DataFrame(reshape(1:12, 3, 4), :auto)

# ╔═╡ baed2eb3-925f-485f-ae18-bc28e413bbe2
ec_df = eachcol(dfₓ)

# ╔═╡ 55f5c1bc-1c05-4b87-8673-aa6156ae2ccf
@assert ec_df.x1 == ec_df[1]

# ╔═╡ bbff0c85-b56f-4168-a035-84816b87b38c
md"""
### Transforming columns

We will get to this subject later in `10_transforms.jl` notebook, but here let us just note that `select`, `select!`, `transform`, `transform!` and `combine` functions allow to generate new columns based on the old columns of a data frame.

The general rules are the following:

  - `select` and `transform` always return the number of rows equal to the source dataframe, while `combine` returns any number of rows (`combine` is allowed to combine rows of the source dataframe)
  - `transform` retains columns from the old data frame
  - `select!` and `transform!` are in-place versions of `select` and `transform`
"""

# ╔═╡ 248fb9c3-caed-4298-bdb2-3d8426fa8514
tdf = DataFrame(reshape(1:12, 3, 4), :auto)

# ╔═╡ b0acc38f-49fe-405e-beb0-3932c59e0680
md"""
Here we add a new column `:res` that is a sum of columns `:x1` and `:x2`. A general syntax of transformations of this kind is:

	source_columns => function_to_apply => target_column_name

then `function_to_apply` gets columns selected by `source_columns` as positional arguments.
"""

# ╔═╡ afc96124-55d6-4b42-8ea1-de5d79647da8
transform(tdf, [:x1, :x2] => (+) => :res)

# ╔═╡ a866a4c5-c8a3-410f-bd26-b240859f28bb
md"""
One can omit passing `target_column_name` in which case it is automatically generated:
"""

# ╔═╡ dedc8234-630c-4fa2-8353-6b260620c3ea
combine(tdf, [:x1, :x2] => cor)

# ╔═╡ 03e05f07-3221-4cf7-a5c2-b81b71e0b4b3
md"""
Note that `combine` allowed the number of columns in the resulting dataframe to be changed. If we used `select` instead it would automatically broadcast the return value to match the number of rows of the source:
"""

# ╔═╡ 62d7860d-d52f-401c-b446-dd63638fc628
select(tdf, [:x1, :x2] => cor)

# ╔═╡ d4cbc501-7d7f-49ac-a296-971e0ada0edd
md"""
If we want to apply some function on each row of the source wrap it in `ByRow`:
"""

# ╔═╡ 28b31f33-b76d-4910-ba04-2d9d8f01ffd6
select(tdf, :x1, :x2, [:x1, :x2] => ByRow(string))

# ╔═╡ ef51c633-f8be-4884-ad62-c7969cb94bf8
md"""
Also if we want columns to be passed as a NamedTuple to a funcion (instead of being positional arguments) wrap them in `AsTable`:
"""

# ╔═╡ 35426049-4cc9-4fdb-b856-9e73fa3d7343
select(tdf, :x1, :x2, AsTable([:x1, :x2]) => x -> x.x1 + x.x2)

# ╔═╡ e26f822a-1649-43e1-b98e-93ed3d8d9a3b
md"""
For simplicity (as this functionality is often needed) there is a special treatement of nrow function that can be just passed as a transformation (without specifying of column selector):
"""

# ╔═╡ 7c6ca147-007d-46db-8dff-51a0e97dfd57
select(tdf, :x1, nrow => "number_of_rows")

# ╔═╡ 2166ab63-1628-4726-8d01-b6fbf25f966b
md"""
*Note* that in `select` the number of rows is automatically broadcasted to match the number of rows of the source data frame.

Finally we can conveniently create multiple columns with one function, e.g.:
"""

# ╔═╡ 4d86e251-c8f7-4281-a9ce-ea17d016f871
select(tdf, :x1, :x1 => ByRow(x -> [x ^ 2, x ^ 3]) => ["x1²", "x1³"])

# ╔═╡ f78fc90b-b3a5-4be7-90c2-25dc3dfdbe1c
md"""
or with the following which produces the same result (as above):
"""

# ╔═╡ f8ee1b70-5588-4328-a036-cf3499bdb1d0
select(tdf, :x1, :x1 => (x -> DataFrame("x1²" => x .^ 2, "x1³" => x .^ 3)) => AsTable)

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
# ╟─ce0a87f7-8f0c-4c87-8fd1-8198edbec86c
# ╠═e7020e48-1e43-4f07-93a5-07ea1f1a63e7
# ╟─9a500d40-75c6-4914-86af-2c255255c1ad
# ╠═33bdbcf6-893e-46ce-9370-917b87045b72
# ╟─98379291-e308-4642-a71e-b8cb5cf6f376
# ╠═2f70c7eb-ab73-4447-9529-354995484739
# ╟─549aa400-44b0-4bfb-8cb4-81bffdb6cd41
# ╠═31edf126-68b7-435f-b286-0e762e8affaf
# ╟─bac788c3-fa41-4daa-a34c-4d5e3fd8c285
# ╠═3925258e-c5f2-42c0-9af2-8b60cf3d51d2
# ╟─aedfb361-edc8-46a3-9497-75542db83642
# ╠═45f24ad5-ff3e-48b6-8917-36ea094388f2
# ╟─6b133d04-6912-4c5b-9784-bf7eea64bc55
# ╠═ae7e4869-a3cc-4012-8436-47d3af7d28c0
# ╟─96958f4d-df91-44f1-89fd-088fb0c6682d
# ╠═bd4ece67-9755-448c-93a8-30b391178c0d
# ╠═5b7b3282-a516-4b21-980b-ef552e6b0c0f
# ╟─4f72dc4a-31b8-40a4-81d9-a727ed2c22b8
# ╠═9528b5ce-da9e-449f-a042-bb9033f8bffa
# ╟─41bac74c-b6f9-4896-9b8d-fcb4d6ce7d47
# ╠═b4e3e3cb-27a6-4002-993b-b5a87587db06
# ╟─15106b6a-4f96-4701-bf95-4f0ed2d988e7
# ╠═44b6e6a2-b22a-485e-b161-6a79513486e5
# ╟─dd2c281c-34a6-4aa1-a339-6d2cc5baa455
# ╠═97acfc11-79a5-48eb-b8e8-5b040bd92b8f
# ╟─b1be6837-38dd-4313-8860-e73ac130b30d
# ╠═72bab76f-91bb-4f78-9dfb-c865ad271cfb
# ╟─4d2d3d2b-cf7d-4ca6-9da0-67d28f269db9
# ╠═5881f7e3-f6d9-4dfc-ba1d-dfa0fea2c07c
# ╟─5d103d4b-9ca8-4274-b556-acbce4aea876
# ╠═eb08d57b-69b8-4543-88ba-c56793210681
# ╟─a33dc13b-732c-4ecf-9295-9fa0f5bc417c
# ╠═e1d534a0-dc8e-4fd6-a35a-314985d6eba8
# ╟─129c6825-9c01-400b-9318-74a3bde8c163
# ╠═33bb1d78-0bcd-4c04-8ef8-d9e62c9f16c6
# ╟─483bfe0d-6e54-4355-8688-d34d9b68fad0
# ╠═e14dfcec-5710-4051-895e-b2f0fdcd6c78
# ╟─c968b160-53cb-4ecc-ad11-78e4b09a73b8
# ╠═016e5a00-49d6-4ce0-a6be-62287d5c928b
# ╟─f312fcc0-e8f4-4e1a-9a7a-b2f6675caac5
# ╠═c64a8915-c2e8-47fe-96e3-2ab7a066764f
# ╟─52d33d1a-0e2c-4f32-a1fd-2380b656460d
# ╠═33dfd57c-9252-495d-b39b-caf96ab8008f
# ╟─520123eb-9673-4c8f-af83-f6f36a621602
# ╠═d8d90255-2393-4362-a239-798976e50a92
# ╟─76498ebd-e783-4716-8c9a-f0ef05616a8f
# ╠═91f780ee-6e10-4124-9d80-d8a0164155fe
# ╠═d58ac235-cf27-4540-aaab-413b72d07418
# ╟─4a8e2e67-8e97-4e09-bffc-8866ff566648
# ╠═b693f3ac-bcf8-43fd-9060-753267d7bef9
# ╠═60cf6f09-55b8-4a70-a208-9e13f43d64ce
# ╠═686cf84f-8bc1-4a74-90f2-cfc52d3963cf
# ╠═3510270e-7edc-4edc-bb9b-e1b274479300
# ╠═ddce5237-d203-43cf-879c-a6dd91adbf55
# ╟─51011425-7eff-4742-9753-d67405de81d5
# ╠═8a99674d-1e8a-4991-9390-9dad31b3d998
# ╟─fa280e7c-cdeb-484d-9678-6d1359ebe5f2
# ╠═b3a8f83d-8150-456e-9682-2195a2ea4aea
# ╟─c8f0a8e0-e433-4607-af1a-dfe54df641d4
# ╠═07ae5e0b-df47-4d7e-871d-a0ea8b4bb839
# ╟─cbfe95e6-dc80-4b62-9f68-6fd9d72196e9
# ╠═08c6994f-52c2-43be-b547-8b10dbfb0bcd
# ╟─ab2465b5-e837-44a6-983f-92c7489abb05
# ╠═198df989-3013-429f-94d5-a5af95e1e8fd
# ╟─592d59cf-a253-4103-9610-3a7c232d9bbd
# ╠═8659fa70-cc8f-4a15-bd5d-d9b0cc13c52c
# ╠═a525f4b8-eb1c-4e75-9829-1fe31c2dc620
# ╟─b346fbd0-a135-4200-9f9d-756afe0221ce
# ╠═b934b67d-8d8e-4854-a038-3e1cf71bf15b
# ╟─18487733-491e-4a95-a44d-f5ef109695c7
# ╠═21fe70fd-0799-43e1-92ce-340c7c523c3e
# ╟─04abd76d-5b51-45e4-8e23-d9b568387fba
# ╠═96f3cd04-f903-4f1c-be07-94860d381bd5
# ╠═6dd8de75-fabf-4659-aea5-33b40e219463
# ╠═00f4efee-e0da-42a1-8f0a-b6d7a3f4a035
# ╠═1fc27c5d-092b-4e54-9eca-6582bc00a241
# ╠═303882ce-bff9-4295-80b4-873f96de1345
# ╟─6b42aeef-6eda-47c6-9aa9-4d06a9738bce
# ╠═f70a4b29-5ec6-44df-b231-7a429de639d0
# ╠═3b379422-e957-47de-96f8-62101bf391a8
# ╠═8c7e1e4e-98de-4f50-9999-234c0c7ef309
# ╟─e41dfcc4-c92c-4548-985e-8cb8eb32c858
# ╠═a5acfa9e-6af8-47b1-b85a-95dab43b7fa8
# ╟─74ccb3d6-9ecf-4118-b913-afe49849bd11
# ╠═c7dc731b-3e97-4439-805f-dab44d1f43de
# ╠═452a8e80-b98a-40df-b942-a9359e3546a1
# ╟─98789796-33e4-415f-a7a6-76a55078c92f
# ╠═7e51ffcf-86b6-4832-9246-57e69a8b1d85
# ╠═5b4e71a2-bbb4-42dc-9674-2823e0aafeef
# ╟─795c4656-e789-48de-a38b-9b5c70c2b86f
# ╠═ed1fee04-a51b-4909-9dd1-972a917335df
# ╟─386f5384-fb9a-48c9-8a91-c8a812ab3e1a
# ╠═108b3bdb-8275-4e6b-8b30-6c6a8f81f950
# ╠═6de67316-b33d-456b-8754-88cc8e43819e
# ╟─998d6542-ff01-43f9-aa21-9f48f0cefdd6
# ╠═a84445cf-1598-4558-a978-ca1c912e1303
# ╠═2ec79047-6e56-4303-ac57-dce06620ad45
# ╟─ecb25704-6a75-4bd2-a598-145ff9982dc4
# ╠═2cbc8d22-6e0d-4a39-8669-7e3ab5f11521
# ╟─e6386760-0bf2-4dcc-a4ae-849dc89cc220
# ╠═6b10c9af-934e-4f37-8013-120b918626d0
# ╟─ef253e41-17b4-436b-9ecf-fb425814ca35
# ╠═e6072582-80d7-402c-9869-55441f9bafcf
# ╟─74051d06-5b6a-4fec-b76c-db71fe767110
# ╠═71a75892-2724-4ee1-b20f-02030959b49b
# ╟─e2ebb352-df12-4abc-9c06-fde8175d5bce
# ╠═2c436f30-26cd-496d-8f50-a5aecd4ea419
# ╟─6950fc3b-6436-4894-a7ee-cdf299ae39dc
# ╠═e1c027a2-2547-4612-ad80-d6b815977ebb
# ╟─3c4f5e66-4903-4a2d-a554-3ddec91d3bd2
# ╠═9cf7e784-0b0d-46d9-b32e-23eee66d1451
# ╟─3cf08ee6-9555-4ed7-8356-985633984030
# ╠═fcc0b1b4-6e99-40a0-97ae-d1d451946510
# ╟─a9a58863-587a-4ee8-91af-438b5049d835
# ╠═9c2d17a2-3758-4ff9-a099-d8c50ed9289c
# ╠═b8125aba-a8da-436e-b658-de277f992836
# ╠═bdffb7fd-bcd0-463a-b7a2-f9dc066d191e
# ╟─48d6dcea-c814-4568-a47f-9d92fcb51b3f
# ╠═0a6b0a70-b6e3-4b06-8b52-dd5f9714bacc
# ╟─9de09d8d-3e55-402d-8907-1131a2287ae3
# ╠═f8a050a2-dfc6-4473-a54d-045435f2dd0a
# ╠═baed2eb3-925f-485f-ae18-bc28e413bbe2
# ╠═55f5c1bc-1c05-4b87-8673-aa6156ae2ccf
# ╟─bbff0c85-b56f-4168-a035-84816b87b38c
# ╠═248fb9c3-caed-4298-bdb2-3d8426fa8514
# ╟─b0acc38f-49fe-405e-beb0-3932c59e0680
# ╠═afc96124-55d6-4b42-8ea1-de5d79647da8
# ╟─a866a4c5-c8a3-410f-bd26-b240859f28bb
# ╠═dedc8234-630c-4fa2-8353-6b260620c3ea
# ╟─03e05f07-3221-4cf7-a5c2-b81b71e0b4b3
# ╠═62d7860d-d52f-401c-b446-dd63638fc628
# ╟─d4cbc501-7d7f-49ac-a296-971e0ada0edd
# ╠═28b31f33-b76d-4910-ba04-2d9d8f01ffd6
# ╟─ef51c633-f8be-4884-ad62-c7969cb94bf8
# ╠═35426049-4cc9-4fdb-b856-9e73fa3d7343
# ╟─e26f822a-1649-43e1-b98e-93ed3d8d9a3b
# ╠═7c6ca147-007d-46db-8dff-51a0e97dfd57
# ╟─2166ab63-1628-4726-8d01-b6fbf25f966b
# ╠═4d86e251-c8f7-4281-a9ce-ea17d016f871
# ╟─f78fc90b-b3a5-4be7-90c2-25dc3dfdbe1c
# ╠═f8ee1b70-5588-4328-a036-cf3499bdb1d0
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
