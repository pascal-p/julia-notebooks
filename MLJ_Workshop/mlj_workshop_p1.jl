### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 18f8736c-8754-11eb-3a0c-c729d6c6b0d8
begin
  using Pkg; Pkg.activate("MLJ_env", shared=true)
  using PlutoUI

    using CategoricalArrays
    # import MLJLinearModels
    import DataFrames
    import CSV
    # import DecisionTree
    using MLJ
    # import MLJLinearModels
    # import MultivariateStats
    # import MLJFlux
    using Plots
end

# ╔═╡ 5aa90fa0-8762-11eb-18a8-a5a45edfd5a7
using Test

# ╔═╡ e3664c92-8753-11eb-325b-95ca5bcab046
md"""
## A workshop introducing the machine learning toolbox MLJ - Part 1 - Data Representation

  - source:[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)
  - based on [Machine Learning in Julia using MLJ, JuliaCon2020](https://github.com/ablaom/MachineLearningInJulia2020)
"""

# ╔═╡ 18e124b4-8754-11eb-07d4-a9eee0b8ba3b
md"""
##### General resources

  - [List of methods introduced in this tutorial](methods.md)
  - [MLJ Cheatsheet](https://alan-turing-institute.github.io/MLJ.jl/dev/mlj_cheatsheet/)
  - [Common MLJ Workflows](https://alan-turing-institute.github.io/MLJ.jl/dev/common_mlj_workflows/)
  - [MLJ manual](https://alan-turing-institute.github.io/MLJ.jl/dev/)
  - [Data Science Tutorials in Julia](https://alan-turing-institute.github.io/DataScienceTutorials.jl/)
"""

# ╔═╡ 992cc480-8785-11eb-0572-c33c1c988efc
html"""
<a id='toc'></a>
"""

# ╔═╡ 53bc7eb6-8764-11eb-326d-41138236d179
md"""
##### TOC
  - [Data Representation](#data-representation)
  - [Two-dimensional data](#2-dimensional)
  - [Fixing scientific types in tabular data](#fixing-scitype-tabular-data)
  - [Resources or this part](#resources)
  - [Exercises for Part 1](#exercises)
"""

# ╔═╡ 9dbf597a-8764-11eb-01e6-67bac4f668b5
html"""
<p style="text-align: right;">
  <a id='data-representation'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 18c455fa-8754-11eb-2683-9dfe2784e339
md"""
#### Data Representation

To help you focus on the intended *purpose* or *interpretation* of
data, MLJ models specify data requirements using *scientific types*,
instead of machine types. An example of a scientific type is
 `OrderedFactor`. The other basic "scalar" scientific types are
 illustrated below:
"""

# ╔═╡ 18acb3c8-8754-11eb-2d0a-5d82e2b47551
PlutoUI.LocalResource("assets/scitypes.png")

# ╔═╡ 185c6c10-8754-11eb-16a3-4b2439aa1d84
md"""
 A scientific type is an ordinary Julia type (so it can be used for
 method dispatch, for example) but it usually has no instances. The
 `scitype` function is used to articulate MLJ's convention about how
 different machine types will be interpreted by MLJ models:
"""

# ╔═╡ 7f3e28ec-8754-11eb-3c7e-e71dc9b2ca4e
begin
  time = [2.3, 4.5, 4.2, 1.8, 7.1]
  scitype(time)
end

# ╔═╡ 841c8930-8754-11eb-1596-0535d54e7558
begin
  _height = [185, 153, 163, 114, 180]
  scitype(_height)
end

# ╔═╡ 88b066ce-8754-11eb-1ec8-61fc466493d5
md"""
To fix data which MLJ is interpreting incorrectly, we use the `coerce` method:
"""

# ╔═╡ 8edfcc74-8754-11eb-3ac9-913d6db5d0c7
height = coerce(_height, Continuous)

# ╔═╡ 8ec4a37c-8754-11eb-05c6-e9d5aa55479f
md"""
Here's an example of data we would want interpreted as  `OrderedFactor` but isn't:
"""

# ╔═╡ 8e9259d0-8754-11eb-01ee-cd92c6663059
begin
  _exam_mark = ["rotten", "great", "bla",  missing, "great"]
  scitype(_exam_mark)
end

# ╔═╡ a152aad4-8754-11eb-33d1-cf4df8cd76d2
begin
  exam_mark_ = coerce(_exam_mark, OrderedFactor)
  levels(exam_mark_)
end

# ╔═╡ a134e1fc-8754-11eb-1664-1d96b05f7ca4
md"""
Use `levels!` to put the classes in the right order:
"""

# ╔═╡ ac1420c4-8754-11eb-3751-4df7eff8ada4
begin
  levels!(exam_mark_, ["rotten", "bla", "great"])
  exam_mark_[1] < exam_mark_[2]
end

# ╔═╡ abfabfc6-8754-11eb-0a32-93a7e254063d
levels(exam_mark_)

# ╔═╡ bd7c20be-8754-11eb-07a1-e182ca10e932
md"""
When sub-sampling, no levels are lost:
"""

# ╔═╡ abdefbf4-8754-11eb-1bc5-4950210910d7
levels(exam_mark_[1:2])

# ╔═╡ abc65bbe-8754-11eb-325f-d98618a30eb8
md"""
**Note on binary data.** There is no separate scientific type for binary data. Binary data is `OrderedFactor{2}` or  `Multiclass{2}`. If a binary measure like `truepositive` is a  applied to `OrderedFactor{2}` then the "positive" class is assumed to appear *second* in the ordering. If such a measure is applied to  `Multiclass{2}` data, a warning is issued. $(html"<br />")
A single `OrderedFactor` can be coerced to a single `Continuous` variable, for models that require this, while a `Multiclass` variable can only be one-hot encoded.

"""

# ╔═╡ b80f22e2-8764-11eb-1965-c13d87724698
html"""
<p style="text-align: right;">
  <a id='2-dimensional'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ a1223a20-8754-11eb-01c3-f5ae2dab2d10
md"""
### Two-dimensional data

Whenever it makes sense, MLJ Models generally expect two-dimensional data to be *tabular*. All the tabular formats implementing the  [Tables.jl API](https://juliadata.github.io/Tables.jl/stable/) (see this
 [list](https://github.com/JuliaData/Tables.jl/blob/master/INTEGRATIONS.md))
 have a scientific type of `Table` and can be used with such models. $(html"<br />")
The simplest example of a table is the julia native *column table*, which is just a named tuple of equal-length vectors:

"""

# ╔═╡ a1017da8-8754-11eb-1439-8da18a5b4fb2
begin
  column_table = (h=height, e=exam_mark_, t=time)
  #-
  scitype(column_table)
end

# ╔═╡ 8e76b9fa-8754-11eb-1d19-37ef9df3cb02
md"""
Notice the `Table{K}` type parameter `K` encodes the scientific types of the columns. (This is useful when comparing table scitypes with `<:`). To inspect the individual column scitypes, we use the `schema` method instead:

"""

# ╔═╡ e5835d02-8754-11eb-31e3-117515bbf480
schema(column_table)

# ╔═╡ e56c4c7a-8754-11eb-276d-27b1b96cfcc2
begin
  row_table = [(a=1, b=3.4),
    (a=2, b=4.5),
    (a=3, b=5.6)]
  schema(row_table)
end

# ╔═╡ e5501170-8754-11eb-036e-e346dd918f26
begin
  # using DataFrames
  df = DataFrames.DataFrame(column_table)
  #-
  schema(df)
end

# ╔═╡ e53b6164-8754-11eb-1ff9-67fff6d1aa66
begin
  # using CSV
  const DIR = "."
  file = CSV.File(joinpath(DIR, "data", "horse.csv"));
  schema(file) # (triggers a file read)
end

# ╔═╡ e5207a7a-8754-11eb-23a4-5547a267fcf1
begin
  matrix_table = MLJ.table(rand(2,3))
  schema(matrix_table)
  # The matrix is *not* copied, only wrapped.
end

# ╔═╡ c7fbf07c-8764-11eb-2c7c-577d1599693a
html"""
<p style="text-align: right;">
  <a id='fixing-scitype-tabular-data'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ e5075f04-8754-11eb-25e7-0d6208bc1994
md"""
### Fixing scientific types in tabular data

To show how we can correct the scientific types of data in tables, we introduce a cleaned up version of the UCI Horse Colic Data Set (the cleaning work-flow is described [here](https://alan-turing-institute.github.io/DataScienceTutorials.jl/end-to-end/horse/#dealing_with_missing_values))
"""

# ╔═╡ 05353384-8762-11eb-00f0-b107afd1e3c2
begin
  hfile = CSV.File(joinpath(DIR, "data", "horse.csv"));
  horse = DataFrames.DataFrame(hfile); # convert to data frame without copying columns
  first(horse, 4)
end

# ╔═╡ 051e501a-8762-11eb-38f6-2bf36faca359
md"""
From [the UCI
docs](http://archive.ics.uci.edu/ml/datasets/Horse+Colic) we can
surmise how each variable ought to be interpreted (a step in our
work-flow that cannot reliably be left to the computer):

variable                    | scientific type (interpretation)
----------------------------|-----------------------------------
`:surgery`                  | Multiclass
`:age`                      | Multiclass
`:rectal_temperature`       | Continuous
`:pulse`                    | Continuous
`:respiratory_rate`         | Continuous
`:temperature_extremities`  | OrderedFactor
`:mucous_membranes`         | Multiclass
`:capillary_refill_time`    | Multiclass
`:pain`                     | OrderedFactor
`:peristalsis`              | OrderedFactor
`:abdominal_distension`     | OrderedFactor
`:packed_cell_volume`       | Continuous
`:total_protein`            | Continuous
`:outcome`                  | Multiclass
`:surgical_lesion`          | OrderedFactor
`:cp_data`                  | Multiclass
"""

# ╔═╡ 0502deca-8762-11eb-151a-29f6fa8801ef
md"""
Let's see how MLJ will actually interpret the data, as it is currently encoded:
"""

# ╔═╡ 04ec04d4-8762-11eb-126d-a90a7d326b72
schema(horse)

# ╔═╡ 030776da-8762-11eb-05ef-59c20464000a
md"""
As a first correction step, we can get MLJ to "guess" the appropriate fix, using the `autotype` method:
"""

# ╔═╡ 23e4b28c-8762-11eb-326b-dba661ca1e8d
autotype(horse)

# ╔═╡ 23ca0dec-8762-11eb-2bc6-d7d4e43255ec
md"""
Okay, this is not perfect, but a step in the right direction, which we implement like this:
"""

# ╔═╡ 23af76a8-8762-11eb-3ab4-03edc83b8310
begin
  coerce!(horse, autotype(horse));
  schema(horse)
end

# ╔═╡ 23952e56-8762-11eb-11ab-9b0f41f746fc
md"""
All remaining `Count` data should be `Continuous`:
"""

# ╔═╡ 46679cfc-8762-11eb-001b-bfd5fbb0d55b
begin
  coerce!(horse, Count => Continuous);
  schema(horse)
end

# ╔═╡ 4654e77e-8762-11eb-1c4f-5594e9a167cc
md"""
 We'll correct the remaining truant entries manually:
"""

# ╔═╡ 4636460c-8762-11eb-3612-4550488a4826
begin
  coerce!(horse,
        :surgery               => Multiclass,
        :age                   => Multiclass,
        :mucous_membranes      => Multiclass,
        :capillary_refill_time => Multiclass,
        :outcome               => Multiclass,
        :cp_data               => Multiclass);
  schema(horse)
end

# ╔═╡ de71ad74-8764-11eb-3d40-99f69a188626
html"""
<p style="text-align: right;">
  <a id='resources'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 23819eec-8762-11eb-2aa3-65dd52774eb6
md"""
### Resources for Part 1

- From the MLJ manual:
   - [A preview of data type specification in
  MLJ](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#A-preview-of-data-type-specification-in-MLJ-1)
   - [Data containers and scientific types](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#Data-containers-and-scientific-types-1)
   - [Working with Categorical Data](https://alan-turing-institute.github.io/MLJ.jl/dev/working_with_categorical_data/)
- [Summary](https://alan-turing-institute.github.io/MLJScientificTypes.jl/dev/#Summary-of-the-MLJ-convention-1) of the MLJ convention for representing scientific types
- [MLJScientificTypes.jl](https://alan-turing-institute.github.io/MLJScientificTypes.jl/dev/)
- From Data Science Tutorials:
    - [Data interpretation: Scientific Types](https://alan-turing-institute.github.io/DataScienceTutorials.jl/data/scitype/)
    - [Horse colic data](https://alan-turing-institute.github.io/DataScienceTutorials.jl/end-to-end/horse/)
- [UCI Horse Colic Data Set](http://archive.ics.uci.edu/ml/datasets/Horse+Colic)
"""

# ╔═╡ c037d4ce-8763-11eb-07c9-53b58dc26075
html"""
<p style="text-align: right;">
  <a id='exercises'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 5ac50c98-8762-11eb-0577-ad8d0739b47b
md"""
### Exercises for Part 1

#### Exercise 1
Try to guess how each code snippet below will evaluate:
"""

# ╔═╡ 5a913224-8762-11eb-2655-35a1ef0a1080
@test  scitype(42) == Count

# ╔═╡ 5a74975e-8762-11eb-0dce-59bb2cc49162
begin
  questions = ["who", "why", "what", "when"]
  @test scitype(questions) == AbstractVector{Textual}
  @test elscitype(questions) == Textual
end

# ╔═╡ 7677f504-8762-11eb-2b07-cfb36a99343b
begin
  A = rand(2, 3)
  @test scitype(A) == AbstractMatrix{Continuous}
  @test elscitype(A) == Continuous
end

# ╔═╡ 7661f966-8762-11eb-28fd-d36d8e4ad3d2
begin
  using SparseArrays
  Asparse = sparse(A)
  @test scitype(A) == AbstractMatrix{Continuous}
end

# ╔═╡ 76461336-8762-11eb-3074-e9fdbc9b1c5a
begin
  # using CategoricalArrays
  C1 = categorical(A)

  @test scitype(C1) == AbstractMatrix{Multiclass{6}}
  @test elscitype(C1) == Multiclass{6}
end

# ╔═╡ 762e61f8-8762-11eb-34b3-377a8a390bc6
begin
  v = [1, 2, missing, 4]
  @test scitype(v) == AbstractVector{Union{Missing, Count}}
  @test elscitype(v) == Union{Missing, Count}
  @test scitype(v[1:2]) == AbstractVector{Union{Missing, Count}}
end

# ╔═╡ 7612ee66-8762-11eb-2c31-d9e4afb204b9
md"""
#### Exercise 2

Coerce the following vector to make MLJ recognize it as a vector of  ordered factors (with an appropriate ordering):
"""

# ╔═╡ 8edd43ec-8762-11eb-28a0-2f52edaaa3a6
quality = ["good", "poor", "poor", "excellent", missing, "good", "excellent"]

# ╔═╡ 8ec5f76e-8762-11eb-0d91-6ddc349e67b5
begin
  nquality = coerce(quality, OrderedFactor)
  levels!(nquality, ["poor", "good", "excellent"])

  @test scitype(nquality) == AbstractVector{Union{Missing, OrderedFactor{3}}}
  @test nquality[1] > nquality[2] # as nquality[1] == "good" and nquality[2] == "poor"
end

# ╔═╡ 8eab3c6c-8762-11eb-1b3a-134e39a0621a
md"""
#### Exercise 3 (fixing scitypes in a table)

Fix the scitypes for the [House Prices in King
County](https://mlr3gallery.mlr-org.com/posts/2020-01-30-house-prices-in-king-county/)
dataset:
"""

# ╔═╡ 8e8fa024-8762-11eb-13f1-7b9f34905d87
begin
  hofile = CSV.File(joinpath(DIR, "data", "house.csv"));
  house = DataFrames.DataFrame(hofile); # convert to data frame without copying columns
  first(house, 4)
end

# ╔═╡ e200acee-8762-11eb-2ad3-0f7693b1377d
md"""
(Two features in the original data set have been deemed uninformative
and dropped, namely `:id` and `:date`. The original feature
`:yr_renovated` has been replaced by the `Bool` feature `is_renovated`.)
"""

# ╔═╡ e402aa38-8762-11eb-021e-e30f60a98bfa
@show schema(house)

# ╔═╡ fd5bc7bc-8762-11eb-19fb-9f28925654c6
autotype(house)

# ╔═╡ Cell order:
# ╟─e3664c92-8753-11eb-325b-95ca5bcab046
# ╠═18f8736c-8754-11eb-3a0c-c729d6c6b0d8
# ╟─18e124b4-8754-11eb-07d4-a9eee0b8ba3b
# ╟─992cc480-8785-11eb-0572-c33c1c988efc
# ╟─53bc7eb6-8764-11eb-326d-41138236d179
# ╟─9dbf597a-8764-11eb-01e6-67bac4f668b5
# ╟─18c455fa-8754-11eb-2683-9dfe2784e339
# ╠═18acb3c8-8754-11eb-2d0a-5d82e2b47551
# ╟─185c6c10-8754-11eb-16a3-4b2439aa1d84
# ╠═7f3e28ec-8754-11eb-3c7e-e71dc9b2ca4e
# ╠═841c8930-8754-11eb-1596-0535d54e7558
# ╟─88b066ce-8754-11eb-1ec8-61fc466493d5
# ╠═8edfcc74-8754-11eb-3ac9-913d6db5d0c7
# ╟─8ec4a37c-8754-11eb-05c6-e9d5aa55479f
# ╠═8e9259d0-8754-11eb-01ee-cd92c6663059
# ╠═a152aad4-8754-11eb-33d1-cf4df8cd76d2
# ╟─a134e1fc-8754-11eb-1664-1d96b05f7ca4
# ╠═ac1420c4-8754-11eb-3751-4df7eff8ada4
# ╠═abfabfc6-8754-11eb-0a32-93a7e254063d
# ╟─bd7c20be-8754-11eb-07a1-e182ca10e932
# ╠═abdefbf4-8754-11eb-1bc5-4950210910d7
# ╟─abc65bbe-8754-11eb-325f-d98618a30eb8
# ╟─b80f22e2-8764-11eb-1965-c13d87724698
# ╟─a1223a20-8754-11eb-01c3-f5ae2dab2d10
# ╠═a1017da8-8754-11eb-1439-8da18a5b4fb2
# ╟─8e76b9fa-8754-11eb-1d19-37ef9df3cb02
# ╠═e5835d02-8754-11eb-31e3-117515bbf480
# ╠═e56c4c7a-8754-11eb-276d-27b1b96cfcc2
# ╠═e5501170-8754-11eb-036e-e346dd918f26
# ╠═e53b6164-8754-11eb-1ff9-67fff6d1aa66
# ╠═e5207a7a-8754-11eb-23a4-5547a267fcf1
# ╟─c7fbf07c-8764-11eb-2c7c-577d1599693a
# ╟─e5075f04-8754-11eb-25e7-0d6208bc1994
# ╠═05353384-8762-11eb-00f0-b107afd1e3c2
# ╟─051e501a-8762-11eb-38f6-2bf36faca359
# ╟─0502deca-8762-11eb-151a-29f6fa8801ef
# ╠═04ec04d4-8762-11eb-126d-a90a7d326b72
# ╟─030776da-8762-11eb-05ef-59c20464000a
# ╠═23e4b28c-8762-11eb-326b-dba661ca1e8d
# ╟─23ca0dec-8762-11eb-2bc6-d7d4e43255ec
# ╠═23af76a8-8762-11eb-3ab4-03edc83b8310
# ╟─23952e56-8762-11eb-11ab-9b0f41f746fc
# ╠═46679cfc-8762-11eb-001b-bfd5fbb0d55b
# ╟─4654e77e-8762-11eb-1c4f-5594e9a167cc
# ╠═4636460c-8762-11eb-3612-4550488a4826
# ╠═de71ad74-8764-11eb-3d40-99f69a188626
# ╟─23819eec-8762-11eb-2aa3-65dd52774eb6
# ╟─c037d4ce-8763-11eb-07c9-53b58dc26075
# ╟─5ac50c98-8762-11eb-0577-ad8d0739b47b
# ╠═5aa90fa0-8762-11eb-18a8-a5a45edfd5a7
# ╠═5a913224-8762-11eb-2655-35a1ef0a1080
# ╠═5a74975e-8762-11eb-0dce-59bb2cc49162
# ╠═7677f504-8762-11eb-2b07-cfb36a99343b
# ╠═7661f966-8762-11eb-28fd-d36d8e4ad3d2
# ╠═76461336-8762-11eb-3074-e9fdbc9b1c5a
# ╠═762e61f8-8762-11eb-34b3-377a8a390bc6
# ╟─7612ee66-8762-11eb-2c31-d9e4afb204b9
# ╠═8edd43ec-8762-11eb-28a0-2f52edaaa3a6
# ╠═8ec5f76e-8762-11eb-0d91-6ddc349e67b5
# ╟─8eab3c6c-8762-11eb-1b3a-134e39a0621a
# ╠═8e8fa024-8762-11eb-13f1-7b9f34905d87
# ╟─e200acee-8762-11eb-2ad3-0f7693b1377d
# ╠═e402aa38-8762-11eb-021e-e30f60a98bfa
# ╠═fd5bc7bc-8762-11eb-19fb-9f28925654c6
