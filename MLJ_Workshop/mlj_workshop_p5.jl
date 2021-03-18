### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ ff8e2e5c-879a-11eb-0d3e-e5049a1cf3b5
begin
  using Pkg; Pkg.activate("MLJ_env", shared=true)
  using PlutoUI

    using CategoricalArrays
    import MLJLinearModels
    import DataFrames
    import CSV
    import DecisionTree
    using MLJ
    import MLJLinearModels
    import MultivariateStats
	import Distributions
    using Plots
    using Test
end

# ╔═╡ 4f20c7b4-879a-11eb-2209-cf5a5c88437e
md"""
## A workshop introducing the machine learning toolbox MLJ - Part5 - Advanced Model Composition

  - source:[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)
  - based on [Machine Learning in Julia using MLJ, JuliaCon2020](https://github.com/ablaom/MachineLearningInJulia2020)
"""

# ╔═╡ 78069384-879a-11eb-172b-23c56086cf2f
html"""
<a id='toc'></a>
"""

# ╔═╡ 7940701e-879a-11eb-3753-6d63fa224f3d
md"""
##### TOC
  - [Building a pipeline using the generic composition syntax](#building-pipeline)
  - [A composite model to average two regressor predictors](#composite-model)
  - [Resources or this part](#resources)
"""

# ╔═╡ 79280c84-879a-11eb-27e4-e19e80efbc15
md"""
> **Goals:**
> 1. Learn how to build a prototypes of a composite model, called a *learning network*
> 2. Learn how to use the `@from_network` macro to export a learning network as a new stand-alone model type

While `@pipeline` is great for composing models in an unbranching
sequence, for more complicated model composition you'll want to use
MLJ's generic model composition syntax. There are two main steps:

- **Prototype** the composite model by building a *learning
  network*, which can be tested on some (dummy) data as you build
  it.

- **Export** the learning network as a new stand-alone model type.

Like pipeline models, instances of the exported model type behave
like any other model (and are not bound to any data, until you wrap
them in a machine).
"""

# ╔═╡ 5d151ef4-87a1-11eb-0a27-adf50f61ae71
html"""
<p style="text-align: right;">
  <a id='building-pipeline'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 5e014aea-87a1-11eb-2091-833f05e273a5
md"""
#### Building a pipeline using the generic composition syntax

To warm up, we'll do the equivalent of
"""

# ╔═╡ 790e31b2-879a-11eb-0219-8bfd44bbd0a2
pipe = @pipeline Standardizer MLJLinearModels.LogisticClassifier;

# ╔═╡ 78f1e956-879a-11eb-3cb8-cbf7c8c9a2c6
md"""
using the generic syntax.
"""

# ╔═╡ 3038e52e-879b-11eb-155a-3b9240c2e866
md"""
Here's some dummy data we'll be using to test our learning network:
"""

# ╔═╡ 364e5f7a-879b-11eb-2a8b-5b7532fdd2ed
begin
	X₀, y₀ = make_blobs(5, 3)
	with_terminal() do
		pretty(X₀)
	end
end

# ╔═╡ 3ed487b4-879b-11eb-3293-5b2d629353e0
md"""
 **Step 0** - Proceed as if you were combining the models "by hand", using all the data available for training, transforming and prediction:
"""

# ╔═╡ 3ebad7e2-879b-11eb-21f3-f7e3328019d4
begin
	stand₀ = Standardizer();
	linear₀ = MLJLinearModels.LogisticClassifier();
end

# ╔═╡ 3ea2fddc-879b-11eb-0863-479f44d0034b
begin
	mach₀ = machine(stand₀, X₀);
	fit!(mach₀);
	Xstand₀ = transform(mach₀, X₀);
end

# ╔═╡ 3e6e8eaa-879b-11eb-0514-3de8464aec2d
begin
	mach₁ = machine(linear₀, Xstand₀, y₀);
	fit!(mach₁);
	ŷd = predict(mach₁, Xstand₀)
end

# ╔═╡ 1603af44-879c-11eb-034d-43faec4dfa53
md"""
**Step 1** - Edit your code as follows:
  - pre-wrap the data in `Source` nodes
  - delete the `fit!` calls
"""

# ╔═╡ 269c2a48-879c-11eb-062f-c77a84a41250
begin
	X₁ = source(X₀)  # or Xsd = source() if not testing
	y₁ = source(y₀)  # or ysd = source()
end

# ╔═╡ 267f95b8-879c-11eb-3683-4d82a83ce5dd
begin
	stand₁ = Standardizer();
	linear₁ = MLJLinearModels.LogisticClassifier();
end

# ╔═╡ 266347dc-879c-11eb-00d0-579f6bb9d793
begin
	mach₃ = machine(stand₁, X₁);
	Xstand₁ = transform(mach₃, X₁);
end

# ╔═╡ 264c5a72-879c-11eb-3b03-3b935674741d
begin
	mach₄ = machine(linear₁, Xstand₁, y₁);
	ŷ = predict(mach₄, Xstand₁);
end

# ╔═╡ 2615615c-879c-11eb-1ad7-1dca7e88b8b9
md"""
Now `X`, `y`, `Xstand` and `yhat` are *nodes* ("variables" or "dynammic data") instead of data. All training, predicting and transforming is now executed lazily, whenever we `fit!` one of these nodes. $(html"<br>")
We *call* a node to retrieve the data it represents in the original manual workflow.
"""

# ╔═╡ b9085140-879c-11eb-2bf3-9d7553c6e47d
begin
	fit!(Xstand₁)
	with_terminal() do
		Xstand₁() |> pretty
	end
end

# ╔═╡ b8ea3200-879c-11eb-3109-6564629b90e7
begin
	fit!(ŷ);
	ŷ()
end

# ╔═╡ b8cf3e70-879c-11eb-028e-2fde06bbe2b3
md"""
The node `ŷ` is the "descendant" (in an associated DAG we have defined) of a unique source node:
"""

# ╔═╡ b8b6ee0e-879c-11eb-1855-7d9fd8102ff7
sources(ŷ)

# ╔═╡ b89c6ce6-879c-11eb-0857-3f6d9f8e47d9
md"""
The data at the source node is replaced by `Xnew` to obtain a new prediction when we call `yhat` like this:
"""

# ╔═╡ f08ba086-879c-11eb-12fe-29c5ed220d89
begin
	Xnew, _y = make_blobs(2, 3);
	ŷ(Xnew)
end

# ╔═╡ f0729820-879c-11eb-0791-591900ba2773
md"""
**Step 2** - Export the learning network as a new stand-alone model type

Now, somewhat paradoxically, we can wrap the whole network in a
special machine - called a *learning network machine* - before have
defined the new model type. Indeed doing so is a necessary step in
the export process, for this machine will tell the export macro:

- what kind of model the composite will be (`Deterministic`,
  `Probabilistic` or `Unsupervised`)a

- which source nodes are input nodes and which are for the target

- which nodes correspond to each operation (`predict`, `transform`,
  etc) that we might want to define

"""

# ╔═╡ f05acfbc-879c-11eb-37d5-634f6429e3a5
begin
	surrogate = Probabilistic()     # a model with no fields!
	machₛ = machine(surrogate, X₁, y₁; predict=ŷ);
end

# ╔═╡ f03df408-879c-11eb-3914-b9d1cc896915
md"""
Although we have no real need to use it, this machine behaves like you'd expect it to:
"""

# ╔═╡ f026f51e-879c-11eb-2cbc-7931007bee2c
begin
	Xnew₁, _y₁ = make_blobs(2, 3)
	fit!(machₛ)
	predict(machₛ, Xnew₁)
end

# ╔═╡ a3c94e6e-879d-11eb-36df-6d09e6863d0f
md"""
Now we create a new model type using a Julia `struct` definition appropriately decorated:
"""

# ╔═╡ a3adcef8-879d-11eb-17d7-8303bc978368
@from_network machₛ begin
	
    mutable struct YaPipe
        standardizer = stand₁
        classifier = linear₁::Probabilistic
    end

end

# ╔═╡ a384ae76-879d-11eb-20df-f55d1cec4ce1
md"""
Instantiating and evaluating on some new data:
"""

# ╔═╡ f00d9e02-879c-11eb-2d82-77383805929e
begin
	pipeᵢ = YaPipe()
	
	Xᵢ, yᵢ = @load_iris;   # built-in data set
	
	machᵢ = machine(pipeᵢ, Xᵢ, yᵢ);
	evaluate!(machᵢ, measure=misclassification_rate, operation=predict_mode)
end

# ╔═╡ 8bcd9032-87a1-11eb-2911-8bd0473971bf
html"""
<p style="text-align: right;">
  <a id='composite-model'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 36d41bbc-879e-11eb-33ec-1d7b44b5abca
md"""
#### A composite model to average two regressor predictors

The following is condensed version of
[this](https://github.com/alan-turing-institute/MLJ.jl/blob/master/binder/MLJ_demo.ipynb)
tutorial. We will define a composite model that:

  - standardizes the input data

  - learns and applies a Box-Cox transformation to the target variable

  - blends the predictions of two supervised learning models - a ridge regressor and a random forest regressor; we'll blend using a simple average (for a more sophisticated stacking example, see [here](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/stacking/))

  - applies the *inverse* Box-Cox transformation to this blended prediction
"""

# ╔═╡ 36b75e46-879e-11eb-0599-d39bf1a74977
@load RandomForestRegressor pkg=DecisionTree

# ╔═╡ 3599f556-879f-11eb-3f03-0f78dd7b610a
@load RidgeRegressor pkg=MLJLinearModels

# ╔═╡ 79889a18-879f-11eb-0f3a-5d7deb0984a6
@load RandomForestRegressor pkg=DecisionTree

# ╔═╡ 369ce2e4-879e-11eb-26a0-97db50a6048f
md"""
**Input layer**
"""

# ╔═╡ 8fa14d14-879e-11eb-3e7d-4721cce58f3d
begin
	Xₛ = source()
	yₛ = source()
end

# ╔═╡ 8f83c014-879e-11eb-0982-7d918eaeb0e3
md"""
 **First layer and target transformation**
"""

# ╔═╡ a823e9d2-879e-11eb-2cc6-c91241e8ee66
begin
	std_model = Standardizer()
	stand = machine(std_model, Xₛ)
	W = MLJ.transform(stand, Xₛ)
end

# ╔═╡ a80150c0-879e-11eb-022c-a3f5457fd43f
begin
	box_model = UnivariateBoxCoxTransformer()
	box = machine(box_model, yₛ)
	z = MLJ.transform(box, yₛ)
end

# ╔═╡ 8f6ac156-879e-11eb-0ecc-8930e2044e8d
md"""
**Second layer**
"""

# ╔═╡ 8f4ba418-879e-11eb-368b-ddaa316099f0
begin
	ridge_model = MLJLinearModels.RidgeRegressor(lambda=0.1)
	ridge = machine(ridge_model, W, z)
end

# ╔═╡ 3680edc2-879e-11eb-19e6-83bbf95b9a51
begin
	forest_model = MLJDecisionTreeInterface.RandomForestRegressor(n_trees=50)
	forest = machine(forest_model, W, z)
end

# ╔═╡ 36662f9e-879e-11eb-12de-25f09360d3f5
ẑₛ = 0.5 * predict(ridge, W) + 0.5 * predict(forest, W)

# ╔═╡ 9b8a7870-879f-11eb-2671-d9f80b9598d5
md"""
**Output**
"""

# ╔═╡ 9b70e374-879f-11eb-04b5-87a9b8dc7803
ŷₛ = inverse_transform(box, ẑₛ)

# ╔═╡ 9b583018-879f-11eb-181e-91585bf7bdda
md"""
With the learning network defined, we're ready to export:
"""

# ╔═╡ 9b39e4dc-879f-11eb-3ae0-8df5e6a25913
@from_network machine(Deterministic(), Xₛ, yₛ, predict=ŷₛ) begin
    mutable struct CompositeModel
        rgs1 = ridge_model
        rgs2 = forest_model
	end
end

# ╔═╡ 9774caee-87a0-11eb-29d8-f928c2cdc209
md"""
Let's instantiate the new model type and try it out on some data:
"""

# ╔═╡ 97499ccc-87a0-11eb-1465-f1f8a0a2ca75
composite = CompositeModel()

# ╔═╡ 9aedc7fc-879f-11eb-1cc3-af422dcfdc05
begin
	Xₓ, yₓ = @load_boston;
	
	machₓ = machine(composite, Xₓ, yₓ);
	evaluate!(machₓ,
		resampling=CV(nfolds=6, shuffle=true),
		measures=[rms, mae])
end

# ╔═╡ ed04718c-87a0-11eb-346c-3b459bf27916
html"""
<p style="text-align: right;">
  <a id='resources'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 0a291696-87a1-11eb-1640-f13435ec21ac
md"""
### Resources for Part 5

- From the MLJ manual:
   - [Learning Networks](https://alan-turing-institute.github.io/MLJ.jl/stable/composing_models/#Learning-Networks-1)
- From Data Science Tutorials:
    - [Learning Networks](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/learning-networks/)
    - [Learning Networks 2](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/learning-networks-2/)

    - [Stacking](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/learning-networks-2/)
       an advanced example of model compostion

    - [Finer Control](https://alan-turing-institute.github.io/MLJ.jl/dev/composing_models/#Method-II:-Finer-control-(advanced)-1)
      exporting learning networks without a macro for finer control

"""

# ╔═╡ Cell order:
# ╟─4f20c7b4-879a-11eb-2209-cf5a5c88437e
# ╠═ff8e2e5c-879a-11eb-0d3e-e5049a1cf3b5
# ╟─78069384-879a-11eb-172b-23c56086cf2f
# ╟─7940701e-879a-11eb-3753-6d63fa224f3d
# ╟─79280c84-879a-11eb-27e4-e19e80efbc15
# ╟─5d151ef4-87a1-11eb-0a27-adf50f61ae71
# ╟─5e014aea-87a1-11eb-2091-833f05e273a5
# ╠═790e31b2-879a-11eb-0219-8bfd44bbd0a2
# ╟─78f1e956-879a-11eb-3cb8-cbf7c8c9a2c6
# ╟─3038e52e-879b-11eb-155a-3b9240c2e866
# ╠═364e5f7a-879b-11eb-2a8b-5b7532fdd2ed
# ╟─3ed487b4-879b-11eb-3293-5b2d629353e0
# ╠═3ebad7e2-879b-11eb-21f3-f7e3328019d4
# ╠═3ea2fddc-879b-11eb-0863-479f44d0034b
# ╠═3e6e8eaa-879b-11eb-0514-3de8464aec2d
# ╠═1603af44-879c-11eb-034d-43faec4dfa53
# ╠═269c2a48-879c-11eb-062f-c77a84a41250
# ╠═267f95b8-879c-11eb-3683-4d82a83ce5dd
# ╠═266347dc-879c-11eb-00d0-579f6bb9d793
# ╠═264c5a72-879c-11eb-3b03-3b935674741d
# ╟─2615615c-879c-11eb-1ad7-1dca7e88b8b9
# ╠═b9085140-879c-11eb-2bf3-9d7553c6e47d
# ╠═b8ea3200-879c-11eb-3109-6564629b90e7
# ╟─b8cf3e70-879c-11eb-028e-2fde06bbe2b3
# ╠═b8b6ee0e-879c-11eb-1855-7d9fd8102ff7
# ╟─b89c6ce6-879c-11eb-0857-3f6d9f8e47d9
# ╠═f08ba086-879c-11eb-12fe-29c5ed220d89
# ╟─f0729820-879c-11eb-0791-591900ba2773
# ╠═f05acfbc-879c-11eb-37d5-634f6429e3a5
# ╟─f03df408-879c-11eb-3914-b9d1cc896915
# ╠═f026f51e-879c-11eb-2cbc-7931007bee2c
# ╟─a3c94e6e-879d-11eb-36df-6d09e6863d0f
# ╠═a3adcef8-879d-11eb-17d7-8303bc978368
# ╟─a384ae76-879d-11eb-20df-f55d1cec4ce1
# ╠═f00d9e02-879c-11eb-2d82-77383805929e
# ╟─8bcd9032-87a1-11eb-2911-8bd0473971bf
# ╟─36d41bbc-879e-11eb-33ec-1d7b44b5abca
# ╠═36b75e46-879e-11eb-0599-d39bf1a74977
# ╠═3599f556-879f-11eb-3f03-0f78dd7b610a
# ╠═79889a18-879f-11eb-0f3a-5d7deb0984a6
# ╟─369ce2e4-879e-11eb-26a0-97db50a6048f
# ╠═8fa14d14-879e-11eb-3e7d-4721cce58f3d
# ╟─8f83c014-879e-11eb-0982-7d918eaeb0e3
# ╠═a823e9d2-879e-11eb-2cc6-c91241e8ee66
# ╠═a80150c0-879e-11eb-022c-a3f5457fd43f
# ╟─8f6ac156-879e-11eb-0ecc-8930e2044e8d
# ╠═8f4ba418-879e-11eb-368b-ddaa316099f0
# ╠═3680edc2-879e-11eb-19e6-83bbf95b9a51
# ╠═36662f9e-879e-11eb-12de-25f09360d3f5
# ╟─9b8a7870-879f-11eb-2671-d9f80b9598d5
# ╠═9b70e374-879f-11eb-04b5-87a9b8dc7803
# ╠═9b583018-879f-11eb-181e-91585bf7bdda
# ╠═9b39e4dc-879f-11eb-3ae0-8df5e6a25913
# ╟─9774caee-87a0-11eb-29d8-f928c2cdc209
# ╠═97499ccc-87a0-11eb-1465-f1f8a0a2ca75
# ╠═9aedc7fc-879f-11eb-1cc3-af422dcfdc05
# ╠═ed04718c-87a0-11eb-346c-3b459bf27916
# ╟─0a291696-87a1-11eb-1640-f13435ec21ac
