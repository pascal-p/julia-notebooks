### A Pluto.jl notebook ###
# v0.19.5

using Markdown
using InteractiveUtils

# ╔═╡ 58be9293-5a04-4c05-9160-cb612e67b639
begin
	using PlutoUI
	PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 112e1901-6ff2-47f0-8d77-26ca31be4495
begin
	# importing the packages
	using DataFrames, CSV, GLM, Lathe, MLBase
	using ClassImbalance, ROCAnalysis
end

# ╔═╡ 3242be09-3b0c-419b-9d2a-4fc2a7fa1b79
using FreqTables

# ╔═╡ 8c9d1d83-ff49-4c4a-b5c3-b6abfc86ed86
using Lathe.preprocess:TrainTestSplit

# ╔═╡ 4409281e-de31-11ec-0a35-9b335b8e6b36
md"""
## Logistic Regression with Julia

ref. TBD

"""

# ╔═╡ 5cab410f-a2cc-4e55-a6f7-28740767bbf9
md"""
### Import the packages
"""

# ╔═╡ 0c29c313-fa37-4429-b644-72a6ff29771a
md"""
### Load the data
"""

# ╔═╡ 17ddd360-10ef-4bb4-a473-903b3fc07c11
begin
	df = CSV.read("./bestsellers.csv", DataFrame)
	first(df, 7)
end

# ╔═╡ 28b43a70-49d1-4914-b07b-c464519f8339
md"""
### Logistic Regression Equation

$P = \frac{1}{1 + e^-(a + bX)}$
"""

# ╔═╡ afd9c09f-bdc3-41b9-8d5a-99078f553540
md"""
Summary Statistics
"""

# ╔═╡ 6e563b3b-4b84-44f0-b19d-6725ba23faff
describe(df)

# ╔═╡ 11ad2200-8c5b-4df8-a4e6-ecfdf2c20378
md"""
Here we are going to use the `:Genre` as our target variable (the one we want to make  a prediction for). We will need to _one-hot-encode_ this variable.
"""

# ╔═╡ b006154c-dae8-43d9-82c5-a0e001d6d9eb
size(df)

# ╔═╡ 26f9065a-7d04-4dac-9ba8-b671b364cb2f
md"""
### Handling missing values

In this case we will drop all rows containing a missing value. Other more sophsiticated techniques are possible (imputing using the mean ...). 
"""

# ╔═╡ d1af90a2-97c5-4de1-b17b-3eb414cdc59d
dropmissing!(df)

# ╔═╡ 9727c6e3-98de-4a2c-97de-aa61715ece2a
size(df) # there was no missing values actually!

# ╔═╡ b2da867b-ef43-4324-91d5-58790a3bc08c
md"""
### One Hot Encoding

By one hot encoding the `:Genre` feature, we will get two new columns in our dataframe, namely:
  - fiction
  - non fiction
"""

# ╔═╡ 5842abd0-781f-4566-91de-145d2f682325
PlutoUI.LocalResource("./one_hot_encoding.png")

# ╔═╡ c3fec45c-a20a-4deb-acfd-b2cc03a84367
begin
	target_final = Lathe.preprocess.OneHotEncode(df, :Genre)
	first(df, 5)
end

# ╔═╡ f037fab1-659b-4d9b-a3dd-5ba562ee361c
size(df) # 9 columns

# ╔═╡ 959a4fa0-5b40-403c-b83e-addef8d5fd8a
names(df)

# ╔═╡ c6eced49-12cf-4d58-8b16-402ca956cf87
md"""
### Feature Selection

We are going to select the numerical features of our dataframe and `:fiction` as our target (which is derived form :Genre and one-hot-encoded)  
"""

# ╔═╡ 95a23a1d-e966-4da3-b458-2c1360beac9d
begin
	ndf = df[:, [:User_Rating, :Reviews, :Price, :Year, :fiction]]
	first(ndf, 7)
end

# ╔═╡ 28d182b0-a1a6-4df4-89f4-26cbb21bad2f
md"""
### Check how the data is balanced
"""

# ╔═╡ 49a979fa-9af6-4c7a-95cb-644ffa8823ef
classes = freqtable(target_final[:fiction])

# ╔═╡ 627462a1-6312-49ca-b06c-0adaa15be1cf
md"""
It looks like our dataset is slightly unbalanced with more non-fiction books than fiction books
"""

# ╔═╡ 066073a7-154a-4ec1-8c51-0e5f240a6176
PlutoUI.LocalResource("false_pos_false_neg.png")

# ╔═╡ 2d987a7a-00e8-4d51-8036-6f19273b77d4
md"""
### Split the Data
"""

# ╔═╡ aa543ea0-557e-4245-b35b-d5d8f0fd599a
begin
	train, test = TrainTestSplit(ndf, .75)
	size(train), size(test)
end

# ╔═╡ 2f837f27-d405-4821-8487-22c02abb49fc
md"""
### Build the model
"""

# ╔═╡ 801d4a21-5ac6-4870-8ec2-f99361e77bf0
fm = @formula(fiction ~ User_Rating + Reviews + Price + Year)

# ╔═╡ 073b8f6c-8eda-49cb-a9a7-5d22071c688f
logit = glm(fm, train, Binomial(), LogitLink())

# ╔═╡ 5556a389-e3bd-4b66-bee0-e8023675c806
md"""
#### Predictions
"""

# ╔═╡ 0402c30e-da3b-44dd-90b8-d3544391ff6c
begin
	predictions = predict(logit, test)
	prediction_class = [
		x < 0.5 ? false : true for x ∈ predictions 
	]
end

# ╔═╡ fd35496d-e570-402f-8c91-c93dd9eb075e
md"""
#### Accuracy
"""

# ╔═╡ a09a5f03-4800-4195-8955-272ed59890c8
prediction_df = DataFrame(y=test.fiction, ŷ=prediction_class, prob_predicted=predictions)

# ╔═╡ 2646689c-8f83-4bd4-960c-0603adc16fbf
prediction_df_correctly_classified = prediction_df.y .== prediction_df.ŷ

# ╔═╡ 468e4a05-6236-4f41-9844-14f222ae4f46
accuracy = prediction_df_correctly_classified |> mean

# ╔═╡ 8a6f38cc-d596-4100-816d-fc965cb7f052
md"""
#### Confusion matrix

We are going to use the ROC curve to evaluate the performance of our current model.
"""

# ╔═╡ b18f8914-8a6e-4420-be17-242edc675a44
PlutoUI.LocalResource("./confusion_matrix.png")

# ╔═╡ 879ba59f-8450-4e86-88e5-9fac935c1bec
confusion_matrix = MLBase.roc(prediction_df.y, prediction_df.ŷ)

# ╔═╡ 7f973c1f-efe7-4ea1-8009-1a8fa90bf77b
md"""
#### False negative rate
"""

# ╔═╡ 88928d7f-7235-4330-ba8a-97ba312da8f9
false_negative_rate(confusion_matrix)

# ╔═╡ 9e9a152a-28e9-4ad8-864f-8edd7eddb176
md"""
Now we are going to focus on the false negative and try to lower this rate.
"""

# ╔═╡ 94b50c8c-1a46-494f-894e-76432d16f85a
md"""
### Class Imbalance 
"""

# ╔═╡ 4575eeb6-d1e2-4e1a-bd4b-39809343d77a
classes

# ╔═╡ c723b61a-8987-45cb-af08-42f764914239
md"""
Let's use the SMOTE technique. SMOTE stands _synthetic minority over sampling technique_. 
"""

# ╔═╡ 3e8785dd-d459-4a39-93f1-60487284fc86
X₂, y₂ = smote(
	ndf[!, [:User_Rating, :Reviews, :Price, :Year]], ndf.fiction,  
	# ! to tell that we do not want the selected features to be balanced
	k=1, pct_under=200, pct_over=100
	# the value chosen for the percentages are derived from the class imbalacne (classes) 
	# thus 200 because max is 310 and minimum is 240 - with 200 we incraese the likelihood of achieving balance 
)

# ╔═╡ a19d8d02-dd5e-4663-9145-d549817954d2
balanced_classes = freqtable(y₂)
# smote add some synthetic values - this is why we get 480 in both cases now

# ╔═╡ 79d0252f-039e-48fe-90c0-6fd84e1af905
ndf₂ = hcat(X₂, y₂)

# ╔═╡ 92c9ce2a-a355-442c-8cb9-ef44ed4b01bd
begin
	rename!(ndf₂, :x1 => :target);
	names(ndf₂)
end

# ╔═╡ 0d5450de-16d7-430c-b116-b60ad757d29b
md"""
### A new model
"""

# ╔═╡ 58ee0fb2-c70d-4090-a477-a7afdcbf8818
begin 
	fm₂ = @formula(target ~ User_Rating + Reviews + Price + Year)
	logit₂ = glm(fm₂, ndf₂, Binomial(), LogitLink())
end

# ╔═╡ 784dfc3b-32fd-4471-9bd7-7a9930db0325


begin
	predictions₂ = predict(logit₂, test)
	prediction₂_class = [
		x < 0.5 ? false : true for x ∈ predictions₂ 
	]
end

# ╔═╡ 8f7f9e3b-e000-40db-9ea4-a75ea8d93ca9
prediction₂_df = DataFrame(y=test.fiction, ŷ=prediction₂_class, prob_predicted=predictions₂)

# ╔═╡ ef083554-9586-4136-8c0b-08a5f39a19bf
prediction₂_df_correctly_classified = prediction₂_df.y .== prediction₂_df.ŷ

# ╔═╡ 44873853-7348-4c4b-8507-19919d2905bd
md"""
#### Accuracy
"""

# ╔═╡ bffd5a34-f741-4dd7-8e39-afa2ace6ac0a
accuracy₂ = prediction₂_df_correctly_classified |> mean

# ╔═╡ 0c76eda9-a3b2-4feb-8121-06e9bae355c5
md"""
#### Confusion matrix
"""

# ╔═╡ 0a1dc294-1485-4657-b1c2-9019ba28846d
confusion₂_matrix = MLBase.roc(prediction₂_df.y, prediction₂_df.ŷ)

# ╔═╡ 8a49090d-9a0f-4c60-b9db-8df4af9fbc1d
md"""
#### False negative rate
"""

# ╔═╡ 73c26e88-75c7-45cc-b8d8-dda5aeb6d11c
false_negative_rate(confusion₂_matrix)

# ╔═╡ e94d9e15-70d0-4d0a-b058-bef54f9a5b97
html"""
<style>
  main {
    max-width: calc(900px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
ClassImbalance = "04a18a73-7590-580c-b363-eeca0919eb2a"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
FreqTables = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
GLM = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
Lathe = "38d8eb38-e7b1-11e9-0012-376b6c802672"
MLBase = "f0e99cf1-93fa-52ec-9ecc-5026115318e0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ROCAnalysis = "f535d66d-59bb-5153-8d2b-ef0a426c6aff"

[compat]
CSV = "~0.10.4"
ClassImbalance = "~0.8.7"
DataFrames = "~0.20.2"
FreqTables = "~0.3.2"
GLM = "~1.4.2"
Lathe = "~0.0.9"
MLBase = "~0.8.0"
PlutoUI = "~0.7.1"
ROCAnalysis = "~0.3.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.CategoricalArrays]]
deps = ["Compat", "DataAPI", "Future", "JSON", "Missings", "Printf", "Reexport", "Statistics", "Unicode"]
git-tree-sha1 = "23d7324164c89638c18f6d7f90d972fa9c4fa9fb"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.7.7"

[[deps.ClassImbalance]]
deps = ["Compat", "DataFrames", "Distributions", "LinearAlgebra", "Random", "Statistics", "StatsBase"]
git-tree-sha1 = "9503749483f4c3bfba567af52c26c14d00428b68"
uuid = "04a18a73-7590-580c-b363-eeca0919eb2a"
version = "0.8.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "87e84b2293559571802f97dd9c94cfd6be52c5e5"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.44.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["CategoricalArrays", "Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "Missings", "PooledArrays", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "7d5bf815cc0b30253e3486e8ce2b93bf9d0faff6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "0.20.2"

[[deps.DataStructures]]
deps = ["InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "88d48e133e6d3dd68183309877eac74393daa7eb"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.17.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "55e1de79bd2c397e048ca47d251f8fa70e530550"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.22.6"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "4863cbb7910079369e258dee4add9d06ead5063a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.8.14"

[[deps.FreqTables]]
deps = ["CategoricalArrays", "NamedArrays", "Tables"]
git-tree-sha1 = "ef6f073ccc7ef226e12ef892161029d2334756c7"
uuid = "da1fdf0e-e0ff-5433-a45f-9bb5ff651cb1"
version = "0.3.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Random", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "dc577ad8b146183c064b30e747e3afc6d6dfd62b"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.4.2"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.Lathe]]
deps = ["DataFrames", "Random"]
git-tree-sha1 = "5f64e72da1435568cd8362d6d0f364d210df3e9e"
uuid = "38d8eb38-e7b1-11e9-0012-376b6c802672"
version = "0.0.9"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MLBase]]
deps = ["IterTools", "Random", "Reexport", "StatsBase", "Test"]
git-tree-sha1 = "f63a8d37429568b8c4384d76c4a96fc2897d6ddf"
uuid = "f0e99cf1-93fa-52ec-9ecc-5026115318e0"
version = "0.8.0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f8c673ccc215eb50fcadb285f522420e29e69e1c"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "0.4.5"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "7d96d4c09526458d66ff84d7648be7eb7c38a547"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "SuiteSparse", "Test"]
git-tree-sha1 = "2fc6f50ddd959e462f0a2dbc802ddf2a539c6e35"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.9.12"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "Logging", "Markdown", "Random", "Suppressor"]
git-tree-sha1 = "45ce174d36d3931cd4e37a47f93e07d1455f038d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.1"

[[deps.PooledArrays]]
deps = ["DataAPI"]
git-tree-sha1 = "b1333d4eced1826e15adbdf01a4ecaccca9d353c"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "0.5.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.ROCAnalysis]]
deps = ["DataFrames", "LinearAlgebra", "Printf", "Random", "RecipesBase", "SpecialFunctions"]
git-tree-sha1 = "e04ce44600445a6dac9c9a9bf48ea8aa5c80e24a"
uuid = "f535d66d-59bb-5153-8d2b-ef0a426c6aff"
version = "0.3.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
deps = ["Pkg"]
git-tree-sha1 = "7b1d07f411bc8ddb7977ec7f377b97b158514fe0"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "0.2.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures", "Random", "Test"]
git-tree-sha1 = "03f5898c9959f8115e30bc7226ada7d0df554ddd"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "0.3.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["OpenSpecFun_jll"]
git-tree-sha1 = "d8d8b8a9f4119829410ecd706da4cc8594a1e020"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "0.10.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics"]
git-tree-sha1 = "19bfcb46245f69ff4013b3df3b977a289852c3a1"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.32.2"

[[deps.StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "3db41a7e4ae7106a6bcff8aa41833a4567c04655"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.21"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.Suppressor]]
git-tree-sha1 = "c6ed566db2fe3931292865b966d6d140b7ef32a9"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═4409281e-de31-11ec-0a35-9b335b8e6b36
# ╠═58be9293-5a04-4c05-9160-cb612e67b639
# ╟─5cab410f-a2cc-4e55-a6f7-28740767bbf9
# ╠═112e1901-6ff2-47f0-8d77-26ca31be4495
# ╟─0c29c313-fa37-4429-b644-72a6ff29771a
# ╠═17ddd360-10ef-4bb4-a473-903b3fc07c11
# ╟─28b43a70-49d1-4914-b07b-c464519f8339
# ╟─afd9c09f-bdc3-41b9-8d5a-99078f553540
# ╠═6e563b3b-4b84-44f0-b19d-6725ba23faff
# ╟─11ad2200-8c5b-4df8-a4e6-ecfdf2c20378
# ╠═b006154c-dae8-43d9-82c5-a0e001d6d9eb
# ╟─26f9065a-7d04-4dac-9ba8-b671b364cb2f
# ╠═d1af90a2-97c5-4de1-b17b-3eb414cdc59d
# ╠═9727c6e3-98de-4a2c-97de-aa61715ece2a
# ╟─b2da867b-ef43-4324-91d5-58790a3bc08c
# ╟─5842abd0-781f-4566-91de-145d2f682325
# ╠═c3fec45c-a20a-4deb-acfd-b2cc03a84367
# ╠═f037fab1-659b-4d9b-a3dd-5ba562ee361c
# ╠═959a4fa0-5b40-403c-b83e-addef8d5fd8a
# ╟─c6eced49-12cf-4d58-8b16-402ca956cf87
# ╠═95a23a1d-e966-4da3-b458-2c1360beac9d
# ╟─28d182b0-a1a6-4df4-89f4-26cbb21bad2f
# ╠═3242be09-3b0c-419b-9d2a-4fc2a7fa1b79
# ╠═49a979fa-9af6-4c7a-95cb-644ffa8823ef
# ╟─627462a1-6312-49ca-b06c-0adaa15be1cf
# ╟─066073a7-154a-4ec1-8c51-0e5f240a6176
# ╟─2d987a7a-00e8-4d51-8036-6f19273b77d4
# ╠═8c9d1d83-ff49-4c4a-b5c3-b6abfc86ed86
# ╠═aa543ea0-557e-4245-b35b-d5d8f0fd599a
# ╟─2f837f27-d405-4821-8487-22c02abb49fc
# ╠═801d4a21-5ac6-4870-8ec2-f99361e77bf0
# ╠═073b8f6c-8eda-49cb-a9a7-5d22071c688f
# ╟─5556a389-e3bd-4b66-bee0-e8023675c806
# ╠═0402c30e-da3b-44dd-90b8-d3544391ff6c
# ╟─fd35496d-e570-402f-8c91-c93dd9eb075e
# ╠═a09a5f03-4800-4195-8955-272ed59890c8
# ╠═2646689c-8f83-4bd4-960c-0603adc16fbf
# ╠═468e4a05-6236-4f41-9844-14f222ae4f46
# ╟─8a6f38cc-d596-4100-816d-fc965cb7f052
# ╟─b18f8914-8a6e-4420-be17-242edc675a44
# ╠═879ba59f-8450-4e86-88e5-9fac935c1bec
# ╟─7f973c1f-efe7-4ea1-8009-1a8fa90bf77b
# ╠═88928d7f-7235-4330-ba8a-97ba312da8f9
# ╟─9e9a152a-28e9-4ad8-864f-8edd7eddb176
# ╟─94b50c8c-1a46-494f-894e-76432d16f85a
# ╠═4575eeb6-d1e2-4e1a-bd4b-39809343d77a
# ╟─c723b61a-8987-45cb-af08-42f764914239
# ╠═3e8785dd-d459-4a39-93f1-60487284fc86
# ╠═a19d8d02-dd5e-4663-9145-d549817954d2
# ╠═79d0252f-039e-48fe-90c0-6fd84e1af905
# ╟─92c9ce2a-a355-442c-8cb9-ef44ed4b01bd
# ╟─0d5450de-16d7-430c-b116-b60ad757d29b
# ╠═58ee0fb2-c70d-4090-a477-a7afdcbf8818
# ╠═784dfc3b-32fd-4471-9bd7-7a9930db0325
# ╠═8f7f9e3b-e000-40db-9ea4-a75ea8d93ca9
# ╠═ef083554-9586-4136-8c0b-08a5f39a19bf
# ╟─44873853-7348-4c4b-8507-19919d2905bd
# ╠═bffd5a34-f741-4dd7-8e39-afa2ace6ac0a
# ╟─0c76eda9-a3b2-4feb-8121-06e9bae355c5
# ╠═0a1dc294-1485-4657-b1c2-9019ba28846d
# ╟─8a49090d-9a0f-4c60-b9db-8df4af9fbc1d
# ╠═73c26e88-75c7-45cc-b8d8-dda5aeb6d11c
# ╟─e94d9e15-70d0-4d0a-b058-bef54f9a5b97
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
