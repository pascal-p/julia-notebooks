### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 794a5356-6e05-44b4-ad9d-375a1fa3613b
begin
	using PlutoUI
	using DataFrames
	using CSV
	
	using Arrow
	using Serialization
	using JLSO
	using JSONTables
	using CodecZlib
	using ZipFile
	using JDF
	
	using StatsPlots # for charts
	using Mmap       # for compression
	using Test
end

# ╔═╡ b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
md"""
## Introduction to DataFrames / 4 - Load and Save

ref. [Introduction to DataFrames, Bogumił Kamiński](https://github.com/bkamins/Julia-DataFrames-Tutorial/blob/master/04_loadsave.ipynb)

We do not cover all features of the packages. Please refer to their documentation to learn them.

Here we will load `CSV.jl` to read and write CSV files and `Arrow.jl`, `JLSO.jl`, and `serialization`, which allow us to work with a binary format and `JSONTables.jl` for JSON interaction. Finally we consider a custom `JDF.jl` format.

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ 6ba0cb33-81e2-4a14-b408-71acaa0f25b1
# using Pkg; Pkg.add("Mmap")

# ╔═╡ d6993a5b-8158-4ce3-accb-8e8c514229b3
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ de97ded0-3952-4188-9a43-a8f383e1ae65
md"""
### Load and save DataFrames

Let us create a simple DataFrame for testing purpose :
"""

# ╔═╡ 887ea560-b824-44bd-96ba-7756271993e7
x₀ = DataFrame(A=[true, false, true], B=[1, 2, missing], 
	C=[missing, "b", "c"], D=['a', missing, 'c'])

# ╔═╡ 327fae3b-f00a-4bb4-ba95-a003e0740c58
md"""
and use `eltypes` to look at the columnwise types.
"""

# ╔═╡ b18bb84d-99f2-454e-b8bd-7c5e52b94141
eltype.(eachcol(x₀))

# ╔═╡ ca9927e5-3ff2-4c73-8206-4d7495668312
md"""
### CSV.jl

Let's use `CSV.jl` to save x₀ to disk; make sure `x0.csv` does not conflict with some file in your working directory.
"""

# ╔═╡ 696d306e-c000-47af-a904-eff748b317f3
CSV.write("./Data/x0.csv", x₀)

# ╔═╡ 157caf96-53ad-4ae6-aa1f-5d3fef0b178f
md"""
Now we can see how it was saved by reading `x0.csv`.
"""

# ╔═╡ c04fb113-c95f-4a23-8884-147cdc62ac5c
with_terminal() do
	print(read("./Data/x0.csv", String))
end

# ╔═╡ 06ee8941-57ef-4dfa-8385-861146755d53
md"""
We can also load it back, as usual running:
"""

# ╔═╡ ae8ac551-ea7f-4a9f-bfb4-e1b86677a6a8
y₀ = CSV.read("./Data/x0.csv", DataFrame)

# ╔═╡ 86253acd-78a2-44c2-931e-f2322ed67dc2
eltype.(eachcol(y₀))

# ╔═╡ 069ea341-4097-42f5-83ff-18548bd34de2
md"""
*Remark:* Note that when loading in a DataFrame from a CSV the column type for column :D has changed!
"""

# ╔═╡ a4615e9b-d3d9-443a-9146-e411f9bbd749
md"""
### Serialization, JDF.jl, and JLSO.j

#### Serialization

Now we use serialization to save x₀.

There are two ways to perform serialization. 
  - The first way is to use the Serialization.serialize as below:
    **Note** *that in general, this process will not work if the reading and writing are done by different versions of Julia, or an instance of Julia with a different system image*.
"""

# ╔═╡ 8cc8ae4d-44df-495b-9469-6b467abd6add
open("./Data/x₀.bin", "w") do io
    serialize(io, x₀)
end

# ╔═╡ 8c7e6303-0d09-4993-943f-d9bd3a9c316b
md"""
Now we load back the saved file to `y₁` variable. Again `y₁` is identical to `x₀`. However, please beware that if you session does not have `DataFrames.jl` loaded, then it may not recognise the content as `DataFrames.jl`.
"""

# ╔═╡ aa8ffd59-e791-4dca-bce7-05a18dfda955
y₁ = open(deserialize, "./Data/x₀.bin")

# ╔═╡ b67f1614-90e2-4e4f-9890-9fd66d24cf5b
eltype.(eachcol(y₁))

# ╔═╡ 3d64997f-bfed-4c48-b962-d0bd6c7aa1ef
md"""
#### JDF.jl


[`JDF.jl`](https://github.com/xiaodaigh/JDF) is a relatively new package designed to serialize DataFrames. You can save a DataFrame with the `savejdf` function.
"""

# ╔═╡ 9be83f87-de31-4403-b567-4f488f88645e
savejdf("./Data/x₀.jdf", x₀);

# ╔═╡ 2717467d-c2c5-4006-bc6f-f5c5de3c6304
md"""
To load the saved JDF file, we use the `loadjdf` function
"""

# ╔═╡ 1f9c7d56-3471-4679-aa17-c5ba3b7c31c6
x₀_loaded = loadjdf("./Data/x₀.jdf") |> DataFrame

# ╔═╡ 332e66fe-5a54-4741-a09c-465afef318b7
@assert isequal(x₀_loaded, x₀)

# ╔═╡ 494e54f6-f29c-457a-9aba-0b7a3cd143b9
md"""
`JDF.jl` offers the ability to load only certain columns from disk to help with working with large files
"""

# ╔═╡ 2909e4a4-5355-4ca9-aca2-efc43d938b29
# set up a JDFFile which is a on disk representation of `x₀` backed by JDF.jl
x₀_ondisk = jdf"./Data/x₀.jdf"

# ╔═╡ 8beffe4b-051a-41e9-af93-10329564355f
md"""
We can see all the names of `x` without loading it into memory
"""

# ╔═╡ 43b9a909-dd99-4bf0-bf41-8a21c5127e24
names(x₀_ondisk)

# ╔═╡ 424dc5a0-f64d-4563-a8be-99ffbb1b211d
md"""
The below is an example of how to load only columns `:A` and `:D`
"""

# ╔═╡ 6109fe95-9cd4-47b7-a79d-387e7aac78db
xd = sloadjdf(x₀_ondisk; cols = ["A", "D"]) |> DataFrame

# ╔═╡ 7211a7cc-3ab1-4c4e-a858-60ee8d910054
eltype.(eachcol(xd))

# ╔═╡ c7ea6a2b-8719-4a1a-b2ce-34237bbbc625
md"""
#### JDF.jl vs others

`JDF.jl` is specialized to `DataFrames.jl` and only supports a restricted list of columns, so it cannot save dataframes with arbitrary column types. However, this also means that `JDF.jl` has specialised algorithms to serailize the type it supports to optimize speed, minimize disk usage, and reduce the chance of errors

The list support columns for `JDF` include

```Julia
WeakRefStrings.StringVector
Vector{T}, Vector{Union{Mising, T}}, Vector{Union{Nothing, T}}
CategoricalArrays.CategoricalVetors{T}
```

where `T` can be `String`, `Bool`, `Symbol`, `Char`, `TimeZones.ZonedDateTime` (experimental) and `isbits` types i.e. `UInt*`, `Int*`, `Float*`, and `Date*` types etc.
"""

# ╔═╡ 2516d88a-9141-4a25-90b3-fc212e6299f9
md"""
#### JLSO.jl


JLSO.jl

Another way to perform serialization is by using the [JLSO.jl](https://github.com/invenia/JLSO.jl) library:
"""

# ╔═╡ 381916dc-3610-4df4-9911-c822d28d3956
JLSO.save("./Data/x₀.jlso", :data => x₀)

# ╔═╡ db07eb7e-2fa7-44e7-adb6-c0254a83e0e3
md"""
Now we can load back the file to y₂.
"""

# ╔═╡ 4f63f693-8392-4e8e-a04e-00f45ba016a3
y₂ = JLSO.load("./Data/x₀.jlso")[:data]

# ╔═╡ a3203a29-33f5-457a-9a90-80c5e14422a6
eltype.(eachcol(y₂))

# ╔═╡ f12dc3e2-167d-4cad-a999-53c67d55af07
md"""
#### JSONTables.jl

Often you might need to read and write data stored in JSON format. `JSONTables.jl` provides a way to process them in row-oriented or column-oriented layout. We present both options below.
"""

# ╔═╡ 23b96b56-709f-4f5b-8bb9-961764f61faf
open(io -> arraytable(io, x₀), "./Data/x₁.json", "w")

# ╔═╡ 6223627b-7541-42f7-892a-80c86e3a95ec
open(io -> objecttable(io, x₀), "./Data/x₂.json", "w")

# ╔═╡ f9281efb-e8aa-4267-9d63-7094e6010315
with_terminal() do
	print(read("./Data/x₁.json", String))
end

# ╔═╡ f215042e-5dec-4e2f-940f-02467c0b3d94
with_terminal() do
	print(read("./Data/x₂.json", String))
end

# ╔═╡ ef097417-b572-4110-b943-7b2500c81838
yj₁ = open(jsontable, "./Data/x₁.json") |> DataFrame

# ╔═╡ 1aca803a-197a-47ac-8eb3-73ab3c40de47
eltype.(eachcol(yj₁))

# ╔═╡ 0e193005-cd0b-4c1c-aa1e-42cee639238c
yj₂ = open(jsontable, "./Data/x₁.json") |> DataFrame

# ╔═╡ 6dd53b4a-a936-40c3-873d-42abe4421189
eltype.(eachcol(yj₂))

# ╔═╡ dc97e056-2d8d-442e-90d2-b75931cecb33
md"""
#### Arrow.jl

Finally we use `Apache Arrow` format that allows, in particular, for data interchange with `R` or `Python`.
"""

# ╔═╡ d1a0d653-ac96-4712-bc26-430ba4436544
Arrow.write("./Data/x₀.arrow", x₀)

# ╔═╡ 2244a140-ec46-4ec5-84c6-fc40511953ad
yₐ = Arrow.Table("./Data/x₀.arrow") |> DataFrame

# ╔═╡ e392701a-75a4-465b-9547-a8d6a3bdc059
eltype.(eachcol(yₐ))

# ╔═╡ 2bf8f141-c809-4599-ace3-3fabd1bbc1d6
yₐ.A[1] = false   ## can be changed - used to be immutable

# ╔═╡ f00b7857-6393-4501-b0a8-bfd7d50667c4
yₐ.A

# ╔═╡ 613569c5-20f4-4463-a039-12fecab721eb
yₐ.B

# ╔═╡ edd10614-b548-4148-acf5-33e16ab0a8be
md"""
### Basic benchmarking

Next, we'll create some files, so be careful that you don't already have these files in your working directory!

In particular, we'll time how long it takes us to write a DataFrame with 10^3 rows and 10^5 columns.

"""

# ╔═╡ 3d478ed4-cf5a-44a1-9441-6da73f7986d2
begin
	bigdf = DataFrame(rand(Bool, 10^5, 500), :auto)
	bigdf[!, 1] = Int.(bigdf[!, 1])
	bigdf[!, 2] = bigdf[!, 2] .+ 0.5
	bigdf[!, 3] = string.(bigdf[!, 3], ", as string")
	
	bigdf = DataFrame(rand(Bool, 10^5, 500), :auto)
	bigdf[!, 1] = Int.(bigdf[!, 1])
	bigdf[!, 2] = bigdf[!, 2] .+ 0.5
	bigdf[!, 3] = string.(bigdf[!, 3], ", as string")
	
	with_terminal() do
		println("First run")
		println("CSV.jl")
		global csvwrite1 = @elapsed @time CSV.write("./Data/bigdf1.csv", bigdf)
	
		println("Serialization")
		global serializewrite1 = @elapsed @time open(io -> serialize(io, bigdf), 
			"./Data/bigdf.bin", "w")
		
		println("JDF.jl")
		global jdfwrite1 = @elapsed @time savejdf("./Data/bigdf.jdf", bigdf)
		
		println("JLSO.jl")
		global jlsowrite1 = @elapsed @time JLSO.save("./Data/bigdf.jlso", :data => bigdf)
		
		println("Arrow.jl")
		global arrowwrite1 = @elapsed @time Arrow.write("./Data/bigdf.arrow", bigdf)
		
		println("JSONTables.jl arraytable")
		global jsontablesawrite1 = @elapsed @time open(io -> arraytable(io, bigdf), 
			"./Data/bigdf1.json", "w")
		
		println("JSONTables.jl objecttable")
		global jsontablesowrite1 = @elapsed @time open(io -> objecttable(io, bigdf), 
			"./Data/bigdf2.json", "w")
		
		println("Second run")
		println("CSV.jl")
		global csvwrite2 = @elapsed @time CSV.write("./Data/bigdf1.csv", bigdf)
		
		println("Serialization")
		global serializewrite2 = @elapsed @time open(io -> serialize(io, bigdf), 
				"./Data/bigdf.bin", "w")
		
		println("JDF.jl")
		global jdfwrite2 = @elapsed @time savejdf("./Data/bigdf.jdf", bigdf)
		
		println("JLSO.jl")
		global jlsowrite2 = @elapsed @time JLSO.save("./Data/bigdf.jlso", :data => bigdf)
		
		println("Arrow.jl")
		global arrowwrite2 = @elapsed @time Arrow.write("./Data/bigdf.arrow", bigdf)
		
		println("JSONTables.jl arraytable")
		global jsontablesawrite2 = @elapsed @time open(io -> arraytable(io, bigdf), 
			"./Data/bigdf1.json", "w")
		
		println("JSONTables.jl objecttable")
		global jsontablesowrite2 = @elapsed @time open(io -> objecttable(io, bigdf), 
			"./Data/bigdf2.json", "w")
	end
end

# ╔═╡ 782f560a-9fd5-498b-9ff8-0215736b240e
groupedbar(
    # Exclude JSONTables.jl arraytable due to timing
	repeat(["CSV.jl", "Serialization", "JDF.jl", "JLSO.jl", 
			"Arrow.jl", "JSONTables.jl\nobjecttable"], inner = 2),

	[csvwrite1, csvwrite2, serializewrite1, serializewrite1, jdfwrite1, jdfwrite2,
     jlsowrite1, jlsowrite2, arrowwrite1, arrowwrite2, jsontablesowrite2, jsontablesowrite2],

	group = repeat(["1st", "2nd"], outer = 6),
	ylab = "Second",
	title = "Write Performance\nDataFrame: bigdf\nSize: $(size(bigdf))"
)

# ╔═╡ 5ab7852b-ea4e-42de-829f-a101e58a0b93
begin
	data_files = ["./Data/bigdf1.csv", "./Data/bigdf.bin", "./Data/bigdf.arrow", 
		"./Data/bigdf1.json", "./Data/bigdf2.json"]
	df = DataFrame(file = data_files, size = getfield.(stat.(data_files), :size))
	append!(df, 
			DataFrame(file = "./Data/bigdf.jdf", 
			size=reduce((x,y) -> x + y.size, stat.(joinpath.("./Data/bigdf.jdf", readdir("./Data/bigdf.jdf"))), 
				init=0)))
	sort!(df, :size)
end

# ╔═╡ 175391bb-3cdc-409f-8963-8aa3d613b601
@df df plot(:file, :size/1024^2, seriestype=:bar, title = "Format File Size (MB)", label="Size", ylab="MB", legend=:topleft, xrotation=45)

# ╔═╡ 5e475f09-3177-45b5-a9a1-f25c1cfeef37
begin
	
	with_terminal() do
		println("First run")
		println("CSV.jl")
		global csvread1 = @elapsed @time CSV.read("./Data/bigdf1.csv", DataFrame)
		
		println("Serialization")
		global serializeread1 = @elapsed @time open(deserialize, "./Data/bigdf.bin")
		
		println("JDF.jl")
		global jdfread1 = @elapsed @time loadjdf("./Data/bigdf.jdf")
		
		println("JLSO.jl")
		global jlsoread1 = @elapsed @time JLSO.load("./Data/bigdf.jlso")
		
		println("Arrow.jl")
		global arrowread1 = @elapsed @time df_tmp = Arrow.Table("./Data/bigdf.arrow") |> DataFrame
		global arrowread1copy = @elapsed @time copy(df_tmp)
		
		println("JSONTables.jl arraytable")
		global jsontablesaread1 = @elapsed @time open(jsontable, "./Data/bigdf1.json")
		
		println("JSONTables.jl objecttable")
		global jsontablesoread1 = @elapsed @time open(jsontable, "./Data/bigdf2.json")
		
		println("Second run")
		global csvread2 = @elapsed @time CSV.read("./Data/bigdf1.csv", DataFrame)
		
		println("Serialization")
		global serializeread2 = @elapsed @time open(deserialize, "./Data/bigdf.bin")
		
		println("JDF.jl")
		global jdfread2 = @elapsed @time loadjdf("./Data/bigdf.jdf")
		
		println("JLSO.jl")
		global jlsoread2 = @elapsed @time JLSO.load("./Data/bigdf.jlso")
		
		println("Arrow.jl")
		global arrowread2 = @elapsed @time df_tmp = Arrow.Table("./Data/bigdf.arrow") |> DataFrame
		global arrowread2copy = @elapsed @time copy(df_tmp)
		
		println("JSONTables.jl arraytable")
		global jsontablesaread2 = @elapsed @time open(jsontable, "./Data/bigdf1.json")
		
		println("JSONTables.jl objecttable")
		global jsontablesoread2 = @elapsed @time open(jsontable, "./Data/bigdf2.json");
	end
end

# ╔═╡ 2fac7472-ddf7-477e-9142-0640bda99890
groupedbar(
    repeat(["CSV.jl", ".Serialization", "JDF.jl", "JLSO.jl", "Arrow.jl", 
			"Arrow.jl\ncopy", "JSON\narraytable", "JSON\nobjecttable"], inner = 2),
	
    [csvread1, csvread2, serializeread1, serializeread2, jdfread1, jdfread2, jlsoread1, jlsoread2,
     arrowread1, arrowread2, arrowread1+arrowread1copy, arrowread2+arrowread2copy,
     jsontablesaread1, jsontablesaread2, jsontablesoread1, jsontablesoread2],    
    
	group = repeat(["1st", "2nd"], outer = 8),
    ylab = "Second",
    title = "Read Performance\nDataFrame: bigdf\nSize: $(size(bigdf))",
	legend=:topleft
)

# ╔═╡ d2df242d-259c-4935-b71b-e1d444ac6f07
md"""
#### Using gzip compression

A common user requirement is to be able to load and save CSV that are compressed using `gzip`. Below we show how this can be accomplished using `CodecZlib.jl`. The same pattern is applicable to `JSONTables.jl` compression/decompression.

Again make sure that you do not have file named df_compress_test.csv.gz in your working directory

We first generate a random data frame

"""

# ╔═╡ b7b657d6-0723-4209-9ecb-efcc72be402f
dfₓ = DataFrame(rand(1:10, 10, 1000), :auto)

# ╔═╡ 8357bef1-d31c-4fa5-992f-f2a6eb6d9573
# GzipCompressorStream comes from CodecZlib

open("./Data/df_compress_test.csv.gz", "w") do io
    stream = GzipCompressorStream(io)
    CSV.write(stream, dfₓ)
    close(stream)
end

# ╔═╡ c33160d1-b12e-42ab-a3c3-b8d6bc58bd9d
df₂ = CSV.File(transcode(GzipDecompressor, 
		Mmap.mmap("./Data/df_compress_test.csv.gz"))) |> DataFrame

# ╔═╡ 544fbeae-ca73-487d-92b5-8d619d9b8db7
@assert dfₓ == df₂

# ╔═╡ bcee6550-63e7-4ff2-a324-37bef45a28b9
md"""
#### Using zip files

TODO...
"""

# ╔═╡ 8b87edb5-d8a7-4234-ac8d-f9e0c8f5f8a0


# ╔═╡ f257c2c9-6cdf-4df8-8b53-7a8d3794b7c3


# ╔═╡ ec462215-2451-4e8e-b440-58503378faae


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

# ╔═╡ 1d8e3b27-8af6-4541-923a-a7744b271464


# ╔═╡ Cell order:
# ╟─b3dcf3f4-9d68-11eb-01a6-317fe0e0cd7e
# ╠═794a5356-6e05-44b4-ad9d-375a1fa3613b
# ╠═6ba0cb33-81e2-4a14-b408-71acaa0f25b1
# ╟─d6993a5b-8158-4ce3-accb-8e8c514229b3
# ╟─de97ded0-3952-4188-9a43-a8f383e1ae65
# ╠═887ea560-b824-44bd-96ba-7756271993e7
# ╟─327fae3b-f00a-4bb4-ba95-a003e0740c58
# ╠═b18bb84d-99f2-454e-b8bd-7c5e52b94141
# ╟─ca9927e5-3ff2-4c73-8206-4d7495668312
# ╠═696d306e-c000-47af-a904-eff748b317f3
# ╟─157caf96-53ad-4ae6-aa1f-5d3fef0b178f
# ╠═c04fb113-c95f-4a23-8884-147cdc62ac5c
# ╟─06ee8941-57ef-4dfa-8385-861146755d53
# ╠═ae8ac551-ea7f-4a9f-bfb4-e1b86677a6a8
# ╠═86253acd-78a2-44c2-931e-f2322ed67dc2
# ╟─069ea341-4097-42f5-83ff-18548bd34de2
# ╟─a4615e9b-d3d9-443a-9146-e411f9bbd749
# ╠═8cc8ae4d-44df-495b-9469-6b467abd6add
# ╟─8c7e6303-0d09-4993-943f-d9bd3a9c316b
# ╠═aa8ffd59-e791-4dca-bce7-05a18dfda955
# ╠═b67f1614-90e2-4e4f-9890-9fd66d24cf5b
# ╟─3d64997f-bfed-4c48-b962-d0bd6c7aa1ef
# ╠═9be83f87-de31-4403-b567-4f488f88645e
# ╟─2717467d-c2c5-4006-bc6f-f5c5de3c6304
# ╠═1f9c7d56-3471-4679-aa17-c5ba3b7c31c6
# ╠═332e66fe-5a54-4741-a09c-465afef318b7
# ╟─494e54f6-f29c-457a-9aba-0b7a3cd143b9
# ╠═2909e4a4-5355-4ca9-aca2-efc43d938b29
# ╟─8beffe4b-051a-41e9-af93-10329564355f
# ╠═43b9a909-dd99-4bf0-bf41-8a21c5127e24
# ╟─424dc5a0-f64d-4563-a8be-99ffbb1b211d
# ╠═6109fe95-9cd4-47b7-a79d-387e7aac78db
# ╠═7211a7cc-3ab1-4c4e-a858-60ee8d910054
# ╟─c7ea6a2b-8719-4a1a-b2ce-34237bbbc625
# ╟─2516d88a-9141-4a25-90b3-fc212e6299f9
# ╠═381916dc-3610-4df4-9911-c822d28d3956
# ╟─db07eb7e-2fa7-44e7-adb6-c0254a83e0e3
# ╠═4f63f693-8392-4e8e-a04e-00f45ba016a3
# ╠═a3203a29-33f5-457a-9a90-80c5e14422a6
# ╟─f12dc3e2-167d-4cad-a999-53c67d55af07
# ╠═23b96b56-709f-4f5b-8bb9-961764f61faf
# ╠═6223627b-7541-42f7-892a-80c86e3a95ec
# ╠═f9281efb-e8aa-4267-9d63-7094e6010315
# ╠═f215042e-5dec-4e2f-940f-02467c0b3d94
# ╠═ef097417-b572-4110-b943-7b2500c81838
# ╠═1aca803a-197a-47ac-8eb3-73ab3c40de47
# ╠═0e193005-cd0b-4c1c-aa1e-42cee639238c
# ╠═6dd53b4a-a936-40c3-873d-42abe4421189
# ╟─dc97e056-2d8d-442e-90d2-b75931cecb33
# ╠═d1a0d653-ac96-4712-bc26-430ba4436544
# ╠═2244a140-ec46-4ec5-84c6-fc40511953ad
# ╠═e392701a-75a4-465b-9547-a8d6a3bdc059
# ╠═2bf8f141-c809-4599-ace3-3fabd1bbc1d6
# ╠═f00b7857-6393-4501-b0a8-bfd7d50667c4
# ╠═613569c5-20f4-4463-a039-12fecab721eb
# ╟─edd10614-b548-4148-acf5-33e16ab0a8be
# ╠═3d478ed4-cf5a-44a1-9441-6da73f7986d2
# ╠═782f560a-9fd5-498b-9ff8-0215736b240e
# ╠═5ab7852b-ea4e-42de-829f-a101e58a0b93
# ╠═175391bb-3cdc-409f-8963-8aa3d613b601
# ╠═5e475f09-3177-45b5-a9a1-f25c1cfeef37
# ╠═2fac7472-ddf7-477e-9142-0640bda99890
# ╟─d2df242d-259c-4935-b71b-e1d444ac6f07
# ╠═b7b657d6-0723-4209-9ecb-efcc72be402f
# ╠═8357bef1-d31c-4fa5-992f-f2a6eb6d9573
# ╠═c33160d1-b12e-42ab-a3c3-b8d6bc58bd9d
# ╠═544fbeae-ca73-487d-92b5-8d619d9b8db7
# ╟─bcee6550-63e7-4ff2-a324-37bef45a28b9
# ╠═8b87edb5-d8a7-4234-ac8d-f9e0c8f5f8a0
# ╠═f257c2c9-6cdf-4df8-8b53-7a8d3794b7c3
# ╠═ec462215-2451-4e8e-b440-58503378faae
# ╟─c54cdbf1-7787-4f0f-b9ff-d4389f4a7c5e
# ╠═1d8e3b27-8af6-4541-923a-a7744b271464
