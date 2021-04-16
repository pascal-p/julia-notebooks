### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames
	using Random
	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction DataFrames / 6 - Manipulating rows

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/06_rows.ipynb)

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Selecting rows
"""

# ╔═╡ 9ccb6d8f-a8e0-42c2-8691-2eac247e591a
Random.seed!(42) 

# ╔═╡ 385aee9f-5c17-4bd2-b3b2-58171fcc5990
df = DataFrame(rand(4, 5), :auto)

# ╔═╡ 472fe012-dd24-46d3-b1b1-f217054c40f0
md"""
using `:` as row selector will **copy** columns
"""	

# ╔═╡ 147bcb72-1d40-458e-abb4-02c8d8ddfa76
df[:, :]

# ╔═╡ 7699775c-8dec-4467-af21-89bd8354d409
@assert df[:, :] == copy(df)   # meaning copy(df) ≡ df[:, :]

# ╔═╡ 09617e8f-1d09-4145-831f-38fd98313dd1
md"""
We can get a subset of rows of a DataFrame without copying using view to get a `SubDataFrame`
"""

# ╔═╡ 80277a09-24ea-4dae-9a41-39853a46fbaa
vdf = view(df, 1:3, 1:3)

# ╔═╡ 9b61d582-6d26-483d-bb66-174b44b38ff4
md"""
we still have a detailed reference to the parent:
"""

# ╔═╡ 5e7c5b0f-be5d-43aa-b13a-4202b1cb34bf
parent(vdf), parentindices(vdf)

# ╔═╡ 26a2e983-0a3c-41b3-ae2a-79395644e2d4
md"""
Selecting a single row returns a `DataFrameRow` object which is also a view
"""

# ╔═╡ f7dbfd3d-2450-4db3-9d25-d08011c62bf2
dfr = df[3, :]

# ╔═╡ cdee6bee-59d8-4fe4-80d9-183b1fa3e18b
parent(dfr), parentindices(dfr), rownumber(dfr)

# ╔═╡ 96b5f96f-57de-4fef-bc73-3f092b00be74
md"""
Let us add a column to a DataFrame by assigning a scalar broadcasting.
"""

# ╔═╡ 912c5b66-38d9-49f4-881c-4f2a988104c2
df[!, :Z] .= 1

# ╔═╡ 560497da-2699-411f-96f9-334919bfffdf
df

# ╔═╡ d114f107-4e31-4585-915f-a17369023a74
md"""
Earlier we used `:` for column selection in a view (`SubDataFrame` and `DataFrameRow`). In this case a view will have all columns of the parent after the parent is mutated.
"""

# ╔═╡ 5b92be5d-a394-4f8e-b081-bfaef94f3165
dfr

# ╔═╡ 3ac61fe5-3e33-44f5-86e9-c5945a2fc03c
parent(dfr), parentindices(dfr), rownumber(dfr)

# ╔═╡ e7da86b9-595c-450c-8a42-60cb63633982
md"""
**Note** that `parent` and `parentindices` refer to the true source of data for a `DataFrameRow` and `rownumber` refers to row number in the direct object that was used to create `DataFrameRow`
"""

# ╔═╡ 6a211df8-ec06-4c24-a362-5e7f604b944a
df₁ = DataFrame(a=1:4)

# ╔═╡ d552bdef-2106-4465-8244-0c8c2144d1f7
dfv₁ = view(df₁, [3, 2], :)

# ╔═╡ f4c515e2-a550-42ec-836c-6f6968c383bc
dfr₁ = dfv₁[1, :]

# ╔═╡ 31a0adc2-c50d-4949-a234-f71e36f46c3c
parent(dfr₁), parentindices(dfr₁), rownumber(dfr₁)

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### Reordering rows

We create some random data frame (and hope that x.x is not sorted :), which is quite likely with 12 rows)

"""

# ╔═╡ 5d950253-8184-492f-a649-9123161ba9cc
x₀ = DataFrame(id=1:12, x = rand(12), y = [zeros(6); ones(6)])

# ╔═╡ 479bbe19-5faf-4f94-8fc2-45f541fffba2
md"""
Check if a DataFrame or a subset of its columns is sorted
"""

# ╔═╡ e68e64a2-4bd7-446d-b550-0cfa157831e4
issorted(x₀), issorted(x₀, :x)

# ╔═╡ 96733dd9-e40a-4ee9-85f9-082feab93144
sort!(x₀, :x)   ## in-place sort

# ╔═╡ 2d6c26cc-f52f-4d77-a17e-def865adc34c
y₀ = sort(x₀, :id)  ## Create new dataframe

# ╔═╡ e7b9b478-e2a7-4633-b963-2408a203ef33
md"""
We sort by two columns, first is decreasing, second is increasing.
"""

# ╔═╡ 9e30faf0-2617-43db-9177-64fad45f7b03
sort(x₀, [:y, :x], rev=[true, false])

# ╔═╡ fe56f87b-50df-4a8a-b531-232a0a51293c
@assert sort(x₀, [:y, :x], rev=[true, false]) == sort(x₀, [order(:y, rev=true), :x]) 
# 2 equivalent ways of sorting

# ╔═╡ 1c003f86-9321-4809-a4b9-a98add2ad39d
md"""
Now let us try some more fancy sorting stuff
"""

# ╔═╡ bace7faf-5eee-4f3d-af48-f9c7ff31ce27
sort(x₀, [order(:y, rev=true), order(:x, by=v -> -v)])
# :y descendant then :x  descendant (as well)

# ╔═╡ 09530879-8714-4332-a925-6f9298d6dc8b
md"""
And here is how we can reorder rows (here randomly)
"""

# ╔═╡ 00818c32-887c-4e3d-8a5f-18c1dcaedba1
x₀[shuffle(1:10), :]

# ╔═╡ 800fcbb6-e1ca-4c63-96af-30bf4680a97b
md"""
It is also easy to swap rows using broadcasted assignment
"""

# ╔═╡ 86916666-4b3e-49dd-bb97-1321f34097f4
begin
	sort!(x₀, :id)
	x₀[[1, 10], :] .= x₀[[10, 1], :]
	x₀
end

# ╔═╡ a4615e9b-d3d9-443a-9146-e411f9bbd749
md"""
### Merging/Adding rows
"""

# ╔═╡ b82a4d73-57f9-48fa-9c76-7d2cf853edd3
x₁ = DataFrame(rand(3, 5), :auto)

# ╔═╡ 6c8bd34e-2f6f-44bd-a6cd-e7b79597f7ae
md"""
merge by rows - dataframes must have the same column names; the same is `vcat`
"""

# ╔═╡ 69d2f06d-866a-4e95-92e9-9b4f06eaff04
[x₁; x₁]

# ╔═╡ 05bdca3f-033a-41c6-9dac-888b08b55cce
md"""
we can efficiently `vcat` a vector of DataFrames using `reduce`
"""

# ╔═╡ 6e4115db-22b2-487a-bda1-255364597014
reduce(vcat, [x₁, x₁, x₁])

# ╔═╡ b03679d0-2ecc-4b64-9aa6-735c6d18a407
md"""
get y with other order of names
"""

# ╔═╡ 1b40287c-b7b6-4ed8-bbe1-1141ef6fb04a
y₁ = x₁[:, reverse(names(x₁))]

# ╔═╡ bd4429da-3378-4392-9cd9-bba21ff9ec37
md"""
`vcat` is still possible as it does column name matching
"""

# ╔═╡ 4becce78-c6d2-43ec-a8ed-58edbf3290ff
vcat(x₁, y₁)

# ╔═╡ e741cbed-3da6-4713-ac85-93b8a683fd87
md"""
However column names must still match or...
"""

# ╔═╡ 39f529a7-8ffa-4149-9780-0d98feee2975
@test_throws ArgumentError vcat(x₁, y₁[:, 1:3])

# ╔═╡ 9df70270-20db-4a83-9c40-55edc37c99b4
md"""
...Unless we pass `:intersect`, `:union` or specific column names as keyword argument `cols`
"""

# ╔═╡ 037843b8-810b-4e78-8262-f9eb631986c4
vcat(x₁, y₁[:, 1:3], cols=:intersect)

# ╔═╡ 5a2aa52a-8739-4c49-95af-e2cd82a96523
vcat(x₁, y₁[:, 1:3], cols=:union)

# ╔═╡ af43af30-7221-4fbb-aef8-63f08956b010
vcat(x₁, y₁[:, 1:3], cols=[:x1, :x5])

# ╔═╡ 198ba262-a6b4-4a2f-8d87-23249c78cb99
md"""
`append!` modifies x in place
"""

# ╔═╡ dd22d95d-840d-41fa-8e1e-1cafb160676e
append!(x₁, y₁)

# ╔═╡ 7fea33ff-04e0-4d67-9bf5-d450269ed8a5
md"""
Standard `repeat` function works on rows; also `inner` and `outer` keyword arguments are accepted
"""

# ╔═╡ a8d073a5-e8ac-4cc0-a668-4bc478533c10
repeat(x₁, 2)

# ╔═╡ 6eb15245-caf0-4598-8741-00bb545ab7dd
md"""
`push!` adds one row to x at the end; one must pass a correct number of values unless `cols` keyword argument is passed.
"""

# ╔═╡ d43682a9-6399-404b-9d88-7a15a198eb08
push!(x₁, 1:5); x₁

# ╔═╡ 70fbd712-7a30-4776-ae1b-109a0a0ca1fe
md"""
It also works with dictionaries
"""

# ╔═╡ 8f227a0c-0083-4abf-8857-7518add1ace8
push!(x₁, Dict(:x1=> 11, :x2=> 12, :x3=> 13, :x4=> 14, :x5=> 15)); x₁

# ╔═╡ ed3ed957-056d-46c9-9877-10490d054122
md"""
and `NamedTuples` via name matching
"""

# ╔═╡ 83a04fdc-93c6-4377-ab35-c18151ca668c
push!(x₁, (x2=2, x1=1, x4=4, x3=3, x5=5))

# ╔═╡ 770b0df0-6095-4e39-b08e-ca49d64cd778
md"""
and DataFrameRow also via name matching
"""

# ╔═╡ 014c6489-a973-48fe-ad5d-a3f487b510b2
push!(x₁, x₁[1, :]); x₁

# ╔═╡ 84aed6e2-afbd-4657-8453-5e1afb91a061
md"""
For more consult the documentation of `push!`, `append!` and `vcat` for allowed values of `cols` keyword argument. This keyword argument governs the way these functions perform column matching of passed arguments. Also `append!` and `push!` support a `promote` keyword argument that decides if column type promotion is allowed.

Let us here just give a quick example of how heterogeneous data can be stored in the dataframe using these functionalities:
"""

# ╔═╡ 3f12d46a-786b-4a20-83ec-7eca121f2770
src = [(a=1, b=2), (a=missing, b=10, c=20), (b="s", c=1, d=1)]

# ╔═╡ b981bce1-dd57-4451-86a5-e9ee14eeb185
dfₛ = DataFrame();

# ╔═╡ 98973c9c-dcd3-44dc-835e-b60d2e7ac4b0
for r in src
    push!(dfₛ, r, cols=:union) ## if cols is :union then promote is true by default
end

# ╔═╡ fa7a9bc6-6609-4e84-93c6-7924bd653fde
dfₛ

# ╔═╡ cf16bd85-9da2-44ac-8e1a-051f04546b60
md"""
We see that `push!` dynamically added columns as needed and updated their element types
"""

# ╔═╡ 7ff49b11-9b98-4e8c-af33-f8ecbc2565c8
md"""
### Subsetting/Removing rows
"""

# ╔═╡ c1f5641e-adad-4ab5-8118-c7a9763cff6f
x₂ = DataFrame(id=1:10, val='a':'j')	

# ╔═╡ 3db600e4-3fbb-4fb8-8df6-9438753f18b9
md"""
by using indexing
"""

# ╔═╡ 1474158e-c2aa-457b-abbb-f10089054f60
x₂[1:2, :]	

# ╔═╡ d3050da0-db13-40e0-a5f5-bb290178f2a0
md"""
a single row selection creates a DataFrameRow
"""

# ╔═╡ b6972fc7-2d40-47b3-b8a1-825cfa59ef67
x₂[1, :]

# ╔═╡ e51b2218-e998-415f-aa9c-ae7582a04619
md"""
but this is a DataFrame.
"""

# ╔═╡ aaea674f-88c7-43b7-8327-31abdc145787
x₂[1:1, :]

# ╔═╡ df89ef70-ab45-4fdf-830a-154260225e2f
md"""
And here is a view.
"""

# ╔═╡ 02650cd1-e572-4d70-a39e-da92ce674659
view(x₂, 1:2, :)

# ╔═╡ 94ac6ebb-86b6-4e31-a64d-e4139b850316
md"""
selects columns 1 and 2
"""

# ╔═╡ d9a8ac15-2774-4e51-ab1b-8c0e95cf158c
view(x₂, :, 1:2)

# ╔═╡ d8d13d16-10ad-4e1e-8265-36516448e702
md"""
indexing by Bool, exact length math is required
"""

# ╔═╡ b85c34fc-9d01-4f7e-9104-452ec672101c
x₂[repeat([true, false], 5), :]

# ╔═╡ 7cd99843-0ead-4119-9221-7dd8c03d3b27
md"""
Alternatively we can also create a view
"""

# ╔═╡ d7e6404c-d0a9-4ee1-8372-edd4ee4fa520
view(x₂, repeat([true, false], 5), :)

# ╔═╡ bad9c21d-c35b-4e4e-8e18-51aeb41c57a9
md"""
we can delete one row in place
"""

# ╔═╡ 2d042183-e3f6-4e00-b86c-bdc1f11bc703
delete!(x₂, 7)

# ╔═╡ b80e344e-8550-4f47-bef6-69833a04277c
md"""
or a collection of rows, also in place
"""

# ╔═╡ 61d6ee03-b042-4f79-a017-dcd59e4eca80
delete!(x₂, 6:7)

# ╔═╡ 26e4a50f-eeb7-4bee-ba4e-e87c479c760c
md"""
We can also create a new DataFrame when deleting rows using `Not` indexing
"""

# ╔═╡ 0b758728-d696-4043-aa02-f3fc27189de8
x₂[Not(1:2), :]

# ╔═╡ 2a2a8d79-f872-4139-bd8e-9119ffed0bcd
x₂

# ╔═╡ 223176a3-aba4-4e6e-a5b1-c51d3ac0bf7e
md"""
Now let us move to row filtering
"""

# ╔═╡ d0d96bda-a7ca-4417-9992-7e3bd748d30b
x₃ = DataFrame([1:4, 2:5, 3:6], :auto)

# ╔═╡ 36088a45-a24c-4d43-9ca1-de665cccb25c
md"""
Let us create a new DataFrame where filtering function operates on DataFrameRow
"""

# ╔═╡ fa126b33-51b7-4aa7-9cc6-c7998ec93fcf
filter(r -> r.x1 > 2.5, x₃)

# ╔═╡ 60ba6b50-48ee-460d-bbd9-61e681d72c74
filter(r -> r.x1 > 2.5, x₃, view=true)  ## the same but as a view

# ╔═╡ 3edc2f7f-0b92-421b-ab10-0a5ee432eed0
filter(:x1 => >(2.5), x₃)               ## Another way

# ╔═╡ a7dcb351-fff6-4bff-96b9-287ca467dfc5
md"""
In place modification of x₃, an example with do-block syntax
"""

# ╔═╡ 04d68d08-4c9e-4e59-aeb4-8c1502aa64be
filter!(x₃) do r
    r.x1 > 2.5 && (return r.x2 < 4.5)
    r.x3 < 3.5
end

# ╔═╡ 616f8df8-0bc1-49eb-b161-6be6fe3dc932
md"""
A common operation is selection of rows for which a value in a column is contained in a given set. Here are a few ways in which you can achieve this.
"""

# ╔═╡ eb5af9d1-ab74-448f-a38b-8f6b1521a510
sdf₁ = DataFrame(x=1:12, y=mod1.(1:12, 4))

# ╔═╡ 9dbef9da-3d2a-4a47-98f3-48947176452a
md"""
We select rows for which column `y` has value 1 or 4.
"""

# ╔═╡ 1d1cccb2-d0ce-4cbb-b81c-5a887d382bf9
filter(r -> r.y ∈ [1, 4], sdf₁)

# ╔═╡ bcc5685b-13f8-40d8-a9de-953ae04f08dc
filter(:y => ∈([1,4]), sdf₁)

# ╔═╡ db9f9a23-2301-423e-b4ee-4d3de02a55f4
sdf₁[in.(sdf₁.y, Ref([1, 4])), :]

# ╔═╡ 31249b78-474f-4ccc-9ca4-540c9ef258aa
md"""
### Deduplicating
"""

# ╔═╡ 3d6aab60-11d2-4c78-bd84-4ceb3b5bfc20
begin 
	xdf = DataFrame(A=[1,2], B=["x","y"])
	append!(xdf, xdf)
	xdf.C = 1:4
	xdf
end

# ╔═╡ 5b5da74e-c5ea-4154-8515-b625dc2b300d
md"""
Get first unique rows for given index
"""

# ╔═╡ cfaa2f0f-1228-4f61-81ad-a5cc08a901ed
unique(xdf, [1, 2])

# ╔═╡ a412e28a-e2d4-45af-a193-75bdefbecc75
md"""
Now we look at whole rows
"""

# ╔═╡ bcd063bb-3629-4060-a0e5-d1f56458cc36
unique(xdf)

# ╔═╡ 7be5c6d8-a7f2-4243-b50f-109f8090a636
md"""
Get indicators of non-unique rows
"""

# ╔═╡ 02a45544-c83b-4917-84ca-2b7f6474a771
nonunique(xdf, :A)

# ╔═╡ 488788a4-071e-4d29-96ba-319f235076a9
md"""
modify `xdf` in place
"""

# ╔═╡ e16de281-1676-430d-9049-9fd81d402dcb
unique!(xdf, :B)

# ╔═╡ 701b11d4-017f-48ea-998f-2203a58b98fb
md"""
### Extracting one row from a DataFrame into standard collections
"""

# ╔═╡ ee246276-451a-4fb1-ab79-81acef89a416
x = DataFrame(x=[1,missing,2], y=["a", "b", missing], z=[true,false,true])

# ╔═╡ dd5860ed-3bc2-44d4-ba25-c155a68f8e05
cols = [:y, :z]

# ╔═╡ c66d68b3-5410-4612-841b-ae53acc5ed69
md"""
We can use a conversion to a Vector or an Array
"""

# ╔═╡ d22c3b36-bfe0-4c70-bdd4-045c52098e34
Vector(x[1, cols])

# ╔═╡ 21f9eb7e-9b62-4e6a-b19e-0ff3648dd2bd
@assert Vector(x[1, cols]) == Array(x[1, cols]) # the same

# ╔═╡ 8a68f92e-265c-4099-b5db-42adfa4aa94e
md"""
Now we will get a vector of vectors
"""

# ╔═╡ 42960153-7f10-4e9e-952f-5fb084268191
[Vector(x[i, cols]) for i ∈ axes(x, 1)]

# ╔═╡ 69329cda-551a-4876-be22-a4b3cdda3c1d
md"""
It is easy to convert a DataFrameRow into a NamedTuple
"""

# ╔═╡ aa3c7475-c680-4c99-837a-5dae1e0ae789
copy(x[1, cols])

# ╔═╡ f4c268e8-a5a1-4bf7-861a-afb557b9bd43
md"""
or a Tuple
"""

# ╔═╡ 1e312c3c-8cde-4de3-8781-90cbe992a023
Tuple(x[1, cols])

# ╔═╡ 0b445f9c-a038-436f-b6e6-a7cacfdb43a6
md"""
### Working with a collection of rows of a DataFrame

We can use eachrow to get a vector-like collection of DataFrameRows
"""

# ╔═╡ 17f9c040-20b8-427f-b3d0-906480bea76c
ndf = DataFrame(reshape(1:12, 3, 4), :auto)

# ╔═╡ 629b54fb-7c55-4a11-b868-c7ff4a1c6e7d
er_df = eachrow(ndf)

# ╔═╡ 053ee3b7-ed9e-4111-86b0-491d0693b8c3
er_df[1]

# ╔═╡ 94f5aa8c-a4d4-42e9-ab67-60e90defa945
last(er_df)

# ╔═╡ bfd74ab1-6cfd-4f82-b72f-f5d32e198676
@assert last(er_df) == er_df[end]

# ╔═╡ e6b663c6-3fab-4b93-9fc4-151a3511236f
md"""
As DataFrameRows objects keeps connection to the parent dataframe you can get the columns of the parent using `getproperty`
"""

# ╔═╡ 06e1bd78-289c-47af-80fa-d83ae43e87f1
er_df.x1

# ╔═╡ 4134d57c-4472-48b9-a12b-cb6799d0cc75
md"""
### Flattening a DataFrame

Occasionally we have a dataframe whose one column is a vector of collections. We can expand (flatten) such a column using the `flatten` function
"""

# ╔═╡ 8e1c24ba-85c9-4d64-a038-3854d2f733c4
fdf = DataFrame(a = 'a':'c', b = [[1, 2, 3], [4, 5], 6])

# ╔═╡ 9aa32873-4528-4a6b-b0a4-031b0e105a55
flatten(fdf, :b)

# ╔═╡ 58a333e7-1d2c-4911-87d6-cbbfab505044


# ╔═╡ 1d8d14d1-cc81-486d-89e6-0d7266e44d7a
md"""
### Only one row

`only` from Julia Base is also supported in `DataFrames.jl` and succeeds if the dataframe has only one row, in which case it is returned. 
"""

# ╔═╡ f2030d95-3dcf-450f-a1cb-acf284d4870a
udf = DataFrame(a=1)

# ╔═╡ d2e6ba37-05bd-4760-9ebc-409fc40adbde
only(udf)

# ╔═╡ b8d0b8cb-021d-42bd-90a6-858496b8a9c0
udf₂ = repeat(udf, 2)

# ╔═╡ fe183565-5068-49d3-b6a9-3bc5de81cc84
@test_throws ArgumentError only(udf₂)

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
# ╠═9ccb6d8f-a8e0-42c2-8691-2eac247e591a
# ╠═385aee9f-5c17-4bd2-b3b2-58171fcc5990
# ╟─472fe012-dd24-46d3-b1b1-f217054c40f0
# ╠═147bcb72-1d40-458e-abb4-02c8d8ddfa76
# ╠═7699775c-8dec-4467-af21-89bd8354d409
# ╟─09617e8f-1d09-4145-831f-38fd98313dd1
# ╠═80277a09-24ea-4dae-9a41-39853a46fbaa
# ╟─9b61d582-6d26-483d-bb66-174b44b38ff4
# ╠═5e7c5b0f-be5d-43aa-b13a-4202b1cb34bf
# ╟─26a2e983-0a3c-41b3-ae2a-79395644e2d4
# ╠═f7dbfd3d-2450-4db3-9d25-d08011c62bf2
# ╠═cdee6bee-59d8-4fe4-80d9-183b1fa3e18b
# ╟─96b5f96f-57de-4fef-bc73-3f092b00be74
# ╠═912c5b66-38d9-49f4-881c-4f2a988104c2
# ╠═560497da-2699-411f-96f9-334919bfffdf
# ╟─d114f107-4e31-4585-915f-a17369023a74
# ╠═5b92be5d-a394-4f8e-b081-bfaef94f3165
# ╠═3ac61fe5-3e33-44f5-86e9-c5945a2fc03c
# ╟─e7da86b9-595c-450c-8a42-60cb63633982
# ╠═6a211df8-ec06-4c24-a362-5e7f604b944a
# ╠═d552bdef-2106-4465-8244-0c8c2144d1f7
# ╠═f4c515e2-a550-42ec-836c-6f6968c383bc
# ╠═31a0adc2-c50d-4949-a234-f71e36f46c3c
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═5d950253-8184-492f-a649-9123161ba9cc
# ╟─479bbe19-5faf-4f94-8fc2-45f541fffba2
# ╠═e68e64a2-4bd7-446d-b550-0cfa157831e4
# ╠═96733dd9-e40a-4ee9-85f9-082feab93144
# ╠═2d6c26cc-f52f-4d77-a17e-def865adc34c
# ╟─e7b9b478-e2a7-4633-b963-2408a203ef33
# ╠═9e30faf0-2617-43db-9177-64fad45f7b03
# ╠═fe56f87b-50df-4a8a-b531-232a0a51293c
# ╟─1c003f86-9321-4809-a4b9-a98add2ad39d
# ╠═bace7faf-5eee-4f3d-af48-f9c7ff31ce27
# ╟─09530879-8714-4332-a925-6f9298d6dc8b
# ╠═00818c32-887c-4e3d-8a5f-18c1dcaedba1
# ╟─800fcbb6-e1ca-4c63-96af-30bf4680a97b
# ╠═86916666-4b3e-49dd-bb97-1321f34097f4
# ╟─a4615e9b-d3d9-443a-9146-e411f9bbd749
# ╠═b82a4d73-57f9-48fa-9c76-7d2cf853edd3
# ╟─6c8bd34e-2f6f-44bd-a6cd-e7b79597f7ae
# ╠═69d2f06d-866a-4e95-92e9-9b4f06eaff04
# ╟─05bdca3f-033a-41c6-9dac-888b08b55cce
# ╠═6e4115db-22b2-487a-bda1-255364597014
# ╟─b03679d0-2ecc-4b64-9aa6-735c6d18a407
# ╠═1b40287c-b7b6-4ed8-bbe1-1141ef6fb04a
# ╟─bd4429da-3378-4392-9cd9-bba21ff9ec37
# ╠═4becce78-c6d2-43ec-a8ed-58edbf3290ff
# ╟─e741cbed-3da6-4713-ac85-93b8a683fd87
# ╠═39f529a7-8ffa-4149-9780-0d98feee2975
# ╟─9df70270-20db-4a83-9c40-55edc37c99b4
# ╠═037843b8-810b-4e78-8262-f9eb631986c4
# ╠═5a2aa52a-8739-4c49-95af-e2cd82a96523
# ╠═af43af30-7221-4fbb-aef8-63f08956b010
# ╟─198ba262-a6b4-4a2f-8d87-23249c78cb99
# ╠═dd22d95d-840d-41fa-8e1e-1cafb160676e
# ╟─7fea33ff-04e0-4d67-9bf5-d450269ed8a5
# ╠═a8d073a5-e8ac-4cc0-a668-4bc478533c10
# ╟─6eb15245-caf0-4598-8741-00bb545ab7dd
# ╠═d43682a9-6399-404b-9d88-7a15a198eb08
# ╟─70fbd712-7a30-4776-ae1b-109a0a0ca1fe
# ╠═8f227a0c-0083-4abf-8857-7518add1ace8
# ╟─ed3ed957-056d-46c9-9877-10490d054122
# ╠═83a04fdc-93c6-4377-ab35-c18151ca668c
# ╟─770b0df0-6095-4e39-b08e-ca49d64cd778
# ╠═014c6489-a973-48fe-ad5d-a3f487b510b2
# ╟─84aed6e2-afbd-4657-8453-5e1afb91a061
# ╠═3f12d46a-786b-4a20-83ec-7eca121f2770
# ╠═b981bce1-dd57-4451-86a5-e9ee14eeb185
# ╠═98973c9c-dcd3-44dc-835e-b60d2e7ac4b0
# ╠═fa7a9bc6-6609-4e84-93c6-7924bd653fde
# ╟─cf16bd85-9da2-44ac-8e1a-051f04546b60
# ╟─7ff49b11-9b98-4e8c-af33-f8ecbc2565c8
# ╠═c1f5641e-adad-4ab5-8118-c7a9763cff6f
# ╟─3db600e4-3fbb-4fb8-8df6-9438753f18b9
# ╠═1474158e-c2aa-457b-abbb-f10089054f60
# ╟─d3050da0-db13-40e0-a5f5-bb290178f2a0
# ╠═b6972fc7-2d40-47b3-b8a1-825cfa59ef67
# ╟─e51b2218-e998-415f-aa9c-ae7582a04619
# ╠═aaea674f-88c7-43b7-8327-31abdc145787
# ╟─df89ef70-ab45-4fdf-830a-154260225e2f
# ╠═02650cd1-e572-4d70-a39e-da92ce674659
# ╟─94ac6ebb-86b6-4e31-a64d-e4139b850316
# ╠═d9a8ac15-2774-4e51-ab1b-8c0e95cf158c
# ╟─d8d13d16-10ad-4e1e-8265-36516448e702
# ╠═b85c34fc-9d01-4f7e-9104-452ec672101c
# ╟─7cd99843-0ead-4119-9221-7dd8c03d3b27
# ╠═d7e6404c-d0a9-4ee1-8372-edd4ee4fa520
# ╟─bad9c21d-c35b-4e4e-8e18-51aeb41c57a9
# ╠═2d042183-e3f6-4e00-b86c-bdc1f11bc703
# ╟─b80e344e-8550-4f47-bef6-69833a04277c
# ╠═61d6ee03-b042-4f79-a017-dcd59e4eca80
# ╟─26e4a50f-eeb7-4bee-ba4e-e87c479c760c
# ╠═0b758728-d696-4043-aa02-f3fc27189de8
# ╠═2a2a8d79-f872-4139-bd8e-9119ffed0bcd
# ╟─223176a3-aba4-4e6e-a5b1-c51d3ac0bf7e
# ╠═d0d96bda-a7ca-4417-9992-7e3bd748d30b
# ╟─36088a45-a24c-4d43-9ca1-de665cccb25c
# ╠═fa126b33-51b7-4aa7-9cc6-c7998ec93fcf
# ╠═60ba6b50-48ee-460d-bbd9-61e681d72c74
# ╠═3edc2f7f-0b92-421b-ab10-0a5ee432eed0
# ╟─a7dcb351-fff6-4bff-96b9-287ca467dfc5
# ╠═04d68d08-4c9e-4e59-aeb4-8c1502aa64be
# ╟─616f8df8-0bc1-49eb-b161-6be6fe3dc932
# ╠═eb5af9d1-ab74-448f-a38b-8f6b1521a510
# ╟─9dbef9da-3d2a-4a47-98f3-48947176452a
# ╠═1d1cccb2-d0ce-4cbb-b81c-5a887d382bf9
# ╠═bcc5685b-13f8-40d8-a9de-953ae04f08dc
# ╠═db9f9a23-2301-423e-b4ee-4d3de02a55f4
# ╟─31249b78-474f-4ccc-9ca4-540c9ef258aa
# ╠═3d6aab60-11d2-4c78-bd84-4ceb3b5bfc20
# ╟─5b5da74e-c5ea-4154-8515-b625dc2b300d
# ╠═cfaa2f0f-1228-4f61-81ad-a5cc08a901ed
# ╟─a412e28a-e2d4-45af-a193-75bdefbecc75
# ╠═bcd063bb-3629-4060-a0e5-d1f56458cc36
# ╟─7be5c6d8-a7f2-4243-b50f-109f8090a636
# ╠═02a45544-c83b-4917-84ca-2b7f6474a771
# ╟─488788a4-071e-4d29-96ba-319f235076a9
# ╠═e16de281-1676-430d-9049-9fd81d402dcb
# ╟─701b11d4-017f-48ea-998f-2203a58b98fb
# ╠═ee246276-451a-4fb1-ab79-81acef89a416
# ╠═dd5860ed-3bc2-44d4-ba25-c155a68f8e05
# ╟─c66d68b3-5410-4612-841b-ae53acc5ed69
# ╠═d22c3b36-bfe0-4c70-bdd4-045c52098e34
# ╠═21f9eb7e-9b62-4e6a-b19e-0ff3648dd2bd
# ╟─8a68f92e-265c-4099-b5db-42adfa4aa94e
# ╠═42960153-7f10-4e9e-952f-5fb084268191
# ╟─69329cda-551a-4876-be22-a4b3cdda3c1d
# ╠═aa3c7475-c680-4c99-837a-5dae1e0ae789
# ╟─f4c268e8-a5a1-4bf7-861a-afb557b9bd43
# ╠═1e312c3c-8cde-4de3-8781-90cbe992a023
# ╟─0b445f9c-a038-436f-b6e6-a7cacfdb43a6
# ╠═17f9c040-20b8-427f-b3d0-906480bea76c
# ╠═629b54fb-7c55-4a11-b868-c7ff4a1c6e7d
# ╠═053ee3b7-ed9e-4111-86b0-491d0693b8c3
# ╠═94f5aa8c-a4d4-42e9-ab67-60e90defa945
# ╠═bfd74ab1-6cfd-4f82-b72f-f5d32e198676
# ╟─e6b663c6-3fab-4b93-9fc4-151a3511236f
# ╠═06e1bd78-289c-47af-80fa-d83ae43e87f1
# ╟─4134d57c-4472-48b9-a12b-cb6799d0cc75
# ╠═8e1c24ba-85c9-4d64-a038-3854d2f733c4
# ╠═9aa32873-4528-4a6b-b0a4-031b0e105a55
# ╠═58a333e7-1d2c-4911-87d6-cbbfab505044
# ╟─1d8d14d1-cc81-486d-89e6-0d7266e44d7a
# ╠═f2030d95-3dcf-450f-a1cb-acf284d4870a
# ╠═d2e6ba37-05bd-4760-9ebc-409fc40adbde
# ╠═b8d0b8cb-021d-42bd-90a6-858496b8a9c0
# ╠═fe183565-5068-49d3-b6a9-3bc5de81cc84
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
