### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9e4e93ea-8793-11eb-100e-4d3853237dde
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

# ╔═╡ 1282be54-8793-11eb-3575-af6b5b5cc6eb
md"""
## A workshop introducing the machine learning toolbox MLJ - Part4 - Tuning Hyper-parameters

  - source:[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)
  - based on [Machine Learning in Julia using MLJ, JuliaCon2020](https://github.com/ablaom/MachineLearningInJulia2020)
"""

# ╔═╡ 3b3dc082-8793-11eb-28d4-a9ec7ae95230
html"""
<a id='toc'></a>
"""

# ╔═╡ 3b1f0f8c-8793-11eb-01ae-43b0e6864086
md"""
##### TOC
  - [Naive tuning of a single Parameter](#naive-tuning)
  - [Self-Tuning Models](#self-tuning)
  - [Unbounded ranges and sampling](#unbounded-ranges)
  - [Resources or this part](#resources)
  - [Exercises for Part 4](#exercises)
"""

# ╔═╡ 2235d2c8-8793-11eb-18eb-ef8d66e5bb8e
html"""
<p style="text-align: right;">
  <a id='naive-tuning'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ dc7748d4-8792-11eb-28cf-635c2c924dc3
md"""
### Naive tuning of a single parameter

The most naive way to tune a single hyper-parameter is to use `learning_curve`, which we already saw in Part 2. Let's see this in the Horse Colic classification problem, in a case where the parameter to be tuned is *nested* (because the model is a pipeline):
"""

# ╔═╡ 7fb9f9ae-8793-11eb-161b-4131e1621b0a
begin
  const DIR = "."
    hfile = CSV.File(joinpath(DIR, "data", "horse.csv"));
    horse = DataFrames.DataFrame(hfile); # convert to data frame without copying columns
end

# ╔═╡ c3500cfa-8793-11eb-1f7b-6d23b07dd9a7
begin
  coerce!(horse, autotype(horse));
  coerce!(horse, Count => Continuous);
  coerce!(horse,
        :surgery               => Multiclass,
        :age                   => Multiclass,
        :mucous_membranes      => Multiclass,
        :capillary_refill_time => Multiclass,
        :outcome               => Multiclass,
        :cp_data               => Multiclass);
  schema(horse)
end

# ╔═╡ c331a116-8793-11eb-2de4-3130572c91cc
begin
  yₕ, Xₕ = unpack(horse, ==(:outcome), name -> true);
  scitype(yₕ)
end

# ╔═╡ c3147f0a-8793-11eb-34d1-35ad468cc0fa
@load LogisticClassifier pkg=MLJLinearModels

# ╔═╡ c2fd2da0-8793-11eb-16ce-4bf069a83cf0
begin
  modelₕ = @pipeline Standardizer ContinuousEncoder        MLJLinearModels.LogisticClassifier

  machₕ = machine(modelₕ, Xₕ, yₕ);
end

# ╔═╡ 2034a066-8794-11eb-21c1-af64ee1bdac8
rₕ = range(modelₕ, :(logistic_classifier.lambda), lower = 1e-2, upper=100,
  scale=:log10)

# ╔═╡ 34e486fc-8794-11eb-05a2-d19cd6695a73
md"""
If you're curious, you can see what `lambda` values this range will generate for a given resolution:
"""

# ╔═╡ 20190554-8794-11eb-21ad-5bb2a9c0016f
iterator(rₕ, 5)

# ╔═╡ 20015968-8794-11eb-37de-7f7e9074c251
begin
  _, _, lambdas, losses = learning_curve(machₕ, range=rₕ,
    resampling=CV(nfolds=6),
        resolution=30, # default
        measure=cross_entropy)

  plot(lambdas, losses, xscale=:log10,
    xlabel="lambda",
    ylabel="cross entropy using 6-fold CV")
end

# ╔═╡ 1fe99152-8794-11eb-35b7-ffc47f8024ea
best_lambda = lambdas[argmin(losses)]

# ╔═╡ e7e6beee-87c3-11eb-3ad0-41c7e2c612c0
html"""
<p style="text-align: right;">
  <a id='self-tuning'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 1fd19e44-8794-11eb-0e65-c935ea2d9867
md"""
### Self tuning models

A more sophisticated way to view hyper-parameter tuning (inspired by
MLR) is as a model *wrapper*. The wrapped model is a new model in
its own right and when you fit it, it tunes specified
hyper-parameters of the model being wrapped, before training on all
supplied data. Calling `predict` on the wrapped model is like
calling `predict` on the original model, but with the
hyper-parameters already optimized.

In other words, we can think of the wrapped model as a "self-tuning"
version of the original.

We now create a self-tuning version of the pipeline above, adding a
parameter from the `ContinuousEncoder` to the parameters we want
optimized.

First, let's choose a tuning strategy (from [these
options](https://github.com/alan-turing-institute/MLJTuning.jl#what-is-provided-here)). MLJ
supports ordinary `Grid` search (query `?Grid` for
details). However, as the utility of `Grid` search is limited to a
small number of parameters, and as `Grid` searches are demonstrated
elsewhere (see the [resources below](#resources-for-part-4)) we'll
demonstrate `RandomSearch` here:
"""

# ╔═╡ 1fb75a0a-8794-11eb-1157-f38619aaffac
tuning = RandomSearch(rng=123)

# ╔═╡ 1f99d98c-8794-11eb-3365-09608fee79cd
md"""
In this strategy each parameter is sampled according to a pre-specified prior distribution that is fit to the one-dimensional range object constructed using `range` as before. While one has a lot of control over the specification of the priors (run `?RandomSearch` for details) we'll let the algorithm generate these priors automatically.
"""

# ╔═╡ 9608ba16-8794-11eb-12ee-a905643b6de9
html"""
<p style="text-align: right;">
  <a id='unbounded-ranges'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 843525f4-8794-11eb-262a-bd9839059599
md"""
#### Unbounded ranges and sampling

In MLJ a range does not have to be bounded. Furthermore, in `RandomSearch` a A positive unbounded range is specified will be sampled using a `Gamma` distribution, by default:
"""

# ╔═╡ 83fe4d2c-8794-11eb-1395-c5908bda104c
r₂ = range(modelₕ, :(logistic_classifier.lambda), lower=0, origin=6, unit=5)

# ╔═╡ 83e467cc-8794-11eb-0ed6-6900e640b3be
md"""
Let's see what sampling using a Gamma distribution is going to mean for this range:
"""

# ╔═╡ 19325af0-8795-11eb-182b-251ef4508684
begin
  # import Distributions
  sampler_r = sampler(r₂, Distributions.Gamma)
  histogram(rand(sampler_r, 10000), nbins=50)
end

# ╔═╡ 19125886-8795-11eb-12f2-e1f6258d0aeb
md"""
The second parameter we'll add to this is *nominal* (finite) and, by default, will be sampled uniformly. Since it is nominal, we specify `values` instead of `upper` and `lower` bounds:
"""

# ╔═╡ 18f8de56-8795-11eb-0cfd-d73c64d968bd
r₃ = range(modelₕ, :(continuous_encoder.one_hot_ordered_factors),
  values = [true, false])

# ╔═╡ 18e01c22-8795-11eb-26ab-05ecf1c7ff90
md"""
##### The tuning wrapper

Now for the wrapper, which is an instance of `TunedModel`:
"""

# ╔═╡ 18c7df90-8795-11eb-21f6-67e53e00a527
tuned_model = TunedModel(model=modelₕ, ranges=[r₂, r₃],
  resampling=CV(nfolds=6), measures=cross_entropy,
  tuning=tuning, n=15)

# ╔═╡ 18aed248-8795-11eb-054b-1558b74bc6ea
md"""
We can apply the `fit!/predict` work-flow to `tuned_model` just as for any other model:
"""

# ╔═╡ 83c9e1b8-8794-11eb-1133-77f9475b62b8
begin
  tuned_mach = machine(tuned_model, Xₕ, yₕ);
  fit!(tuned_mach);
  predict(tuned_mach, rows=1:3)
end

# ╔═╡ f047f48a-8795-11eb-1f0f-b5e2fe9d7a2a
md"""
The outcomes of the tuning can be inspected from a detailed report. For example, we have:
"""

# ╔═╡ f04773ac-8795-11eb-3d99-358e3fb52fcc
begin
  rep_tuned_mach = report(tuned_mach);
  rep_tuned_mach.best_model
end

# ╔═╡ 2cad2636-8796-11eb-26e5-3dea19ddc99f
md"""
In the special case of two-parameters, you can also plot the results:
"""

# ╔═╡ 2c8a3108-8796-11eb-2e24-1f46d8653318
plot(tuned_mach)

# ╔═╡ 2c6fd7ea-8796-11eb-3fdf-8f29bb83cc37
md"""
Finally, let's compare cross-validation estimate of the performance of the self-tuning model with that of the original model (an example  of [*nested resampling*](https://mlr3book.mlr-org.com/nested-resampling.html) here):
"""

# ╔═╡ 2c549336-8796-11eb-0ac9-db88b339e91a
errₕ = evaluate!(machₕ, resampling=CV(nfolds=3), measure=cross_entropy)

# ╔═╡ 2c3af49e-8796-11eb-3fe8-43ba51426411
tuned_err = evaluate!(tuned_mach, resampling=CV(nfolds=3), measure=cross_entropy)

# ╔═╡ 57a0fe58-8796-11eb-0fb7-332dfa29bcf5
html"""
<p style="text-align: right;">
  <a id='resources'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 5516fd22-8796-11eb-20ba-ef554955d071
md"""
#### Resources for Part 4

- From the MLJ manual:
   - [Learning Curves](https://alan-turing-institute.github.io/MLJ.jl/dev/learning_curves/)
   - [Tuning Models](https://alan-turing-institute.github.io/MLJ.jl/dev/tuning_models/)
- The [MLJTuning repo](https://github.com/alan-turing-institute/MLJTuning.jl#who-is-this-repo-for) - mostly for developers

- From Data Science Tutorials:
    - [Tuning a model](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/model-tuning/)
    - [Crabs with XGBoost](https://alan-turing-institute.github.io/DataScienceTutorials.jl/end-to-end/crabs-xgb/) `Grid` tuning in stages for a tree-boosting model with many parameters
    - [Boston with LightGBM](https://alan-turing-institute.github.io/DataScienceTutorials.jl/end-to-end/boston-lgbm/) -  `Grid` tuning for another popular tree-booster
    - [Boston with Flux](https://alan-turing-institute.github.io/DataScienceTutorials.jl/end-to-end/boston-flux/) - optimizing batch size in a simple neural network regressor
- [UCI Horse Colic Data Set](http://archive.ics.uci.edu/ml/datasets/Horse+Colic)

"""

# ╔═╡ 54fc4464-8796-11eb-324b-0195abc8c4bc
html"""
<p style="text-align: right;">
  <a id='exercises'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 54e17b3e-8796-11eb-3b20-45a682c2065b
md"""
#### Exercises for Part 4

##### Exercise 1

This exercise continues our analysis of the King County House price prediction problem:
"""

# ╔═╡ 54c55cce-8796-11eb-3774-058c344a886a
begin
  hofile = CSV.File(joinpath(DIR, "data", "house.csv"));
  house = DataFrames.DataFrame(hofile);

  coerce!(house, autotype(hofile));
  coerce!(house, Count => Continuous, :zipcode => Multiclass);

  yₓ, Xₓ = unpack(house, ==(:price), name -> true, rng=123);
end

# ╔═╡ f04752ac-8795-11eb-03a3-a56cd548eca8
md"""
Your task will be to tune the following pipeline regression model:
"""

# ╔═╡ 1ae849ac-8797-11eb-2376-4189345388ff
@load(EvoTreeRegressor)

# ╔═╡ 1accb14c-8797-11eb-1c71-81ad55c19b1d
tree_booster = EvoTrees.EvoTreeRegressor(nrounds = 70);

# ╔═╡ 1ab6cef4-8797-11eb-2f81-6140be1f3b0d
modelₓ = @pipeline ContinuousEncoder tree_booster

# ╔═╡ 1a9b44e0-8797-11eb-3e92-2f8dbd5282ae
md"""
(a) Construct a bounded range `rₓ` for the `evo_tree_booster` parameter `max_depth`, varying between 1 and 12.

 (b) For the `nbins` parameter of the `EvoTreeRegressor`, define the range
"""

# ╔═╡ 1a7e108c-8797-11eb-11f8-f7be28d15ab9
# (a)
rₓ = range(modelₓ, :(evo_tree_regressor.max_depth),
  lower = 1.0, upper= 12.0)

# ╔═╡ 6c41590e-87c6-11eb-17e2-bd5698ae552f
# (b)
rₒ = range(modelₓ,
  :(evo_tree_regressor.nbins),
  lower = 2.5,
  upper= 7.5, scale=x->2^round(Int, x))

# ╔═╡ 43e21928-8797-11eb-0e87-cd5790ab59b1
md"""
(c) Optimize `model` over these parameter ranges `rₓ` and `r2`
using a random search with uniform priors (the default). Use
`Holdout()` resampling, and implement your search by first
constructing a "self-tuning" wrap of `model`, as described
above. Make `mae` (mean absolute error) the loss function that you
optimize, and search over a total of 40 combinations of
hyper-parameters.  If you have time, plot the results of your
search. Feel free to use all available data.

(d) Evaluate the best model found in the search using 3-fold
cross-validation and compare with that of the self-tuning model
(which is different!). Setting data hygiene concerns aside, feel
free to use all available data.
"""

# ╔═╡ 43cc0f16-8797-11eb-1cca-874f98f40302
tuned_modelₓ = TunedModel(model=modelₓ,
                         ranges=[rₓ, rₒ],
                         resampling=Holdout(),
                         measures=mae,
                         tuning=RandomSearch(rng=123),
                         n=40)

# ╔═╡ d60b7a5a-87c5-11eb-0685-5100caf67827
tuned_machₓ = machine(tuned_modelₓ, Xₓ, yₓ) |> fit!

# ╔═╡ d5ea675c-87c5-11eb-1bf4-d1ea71c95392
plot(tuned_machₓ)

# ╔═╡ ab758052-8797-11eb-1193-b1f04d8f328c
# (d)
begin
  best_modelₓ = report(tuned_machₓ).best_model;
  best_machₓ = machine(best_modelₓ, Xₓ, yₓ);
  best_errₓ = evaluate!(best_machₓ, resampling=CV(nfolds=3), measure=mae)
end

# ╔═╡ 0388a272-87c7-11eb-21e9-9190a2f07a1c
tuned_errₓ = evaluate!(tuned_machₓ, resampling=CV(nfolds=3), measure=mae)

# ╔═╡ Cell order:
# ╟─1282be54-8793-11eb-3575-af6b5b5cc6eb
# ╠═9e4e93ea-8793-11eb-100e-4d3853237dde
# ╟─3b3dc082-8793-11eb-28d4-a9ec7ae95230
# ╟─3b1f0f8c-8793-11eb-01ae-43b0e6864086
# ╟─2235d2c8-8793-11eb-18eb-ef8d66e5bb8e
# ╟─dc7748d4-8792-11eb-28cf-635c2c924dc3
# ╠═7fb9f9ae-8793-11eb-161b-4131e1621b0a
# ╠═c3500cfa-8793-11eb-1f7b-6d23b07dd9a7
# ╠═c331a116-8793-11eb-2de4-3130572c91cc
# ╠═c3147f0a-8793-11eb-34d1-35ad468cc0fa
# ╠═c2fd2da0-8793-11eb-16ce-4bf069a83cf0
# ╠═2034a066-8794-11eb-21c1-af64ee1bdac8
# ╟─34e486fc-8794-11eb-05a2-d19cd6695a73
# ╠═20190554-8794-11eb-21ad-5bb2a9c0016f
# ╠═20015968-8794-11eb-37de-7f7e9074c251
# ╠═1fe99152-8794-11eb-35b7-ffc47f8024ea
# ╟─e7e6beee-87c3-11eb-3ad0-41c7e2c612c0
# ╠═1fd19e44-8794-11eb-0e65-c935ea2d9867
# ╠═1fb75a0a-8794-11eb-1157-f38619aaffac
# ╟─1f99d98c-8794-11eb-3365-09608fee79cd
# ╟─9608ba16-8794-11eb-12ee-a905643b6de9
# ╟─843525f4-8794-11eb-262a-bd9839059599
# ╠═83fe4d2c-8794-11eb-1395-c5908bda104c
# ╟─83e467cc-8794-11eb-0ed6-6900e640b3be
# ╠═19325af0-8795-11eb-182b-251ef4508684
# ╟─19125886-8795-11eb-12f2-e1f6258d0aeb
# ╠═18f8de56-8795-11eb-0cfd-d73c64d968bd
# ╟─18e01c22-8795-11eb-26ab-05ecf1c7ff90
# ╠═18c7df90-8795-11eb-21f6-67e53e00a527
# ╟─18aed248-8795-11eb-054b-1558b74bc6ea
# ╠═83c9e1b8-8794-11eb-1133-77f9475b62b8
# ╟─f047f48a-8795-11eb-1f0f-b5e2fe9d7a2a
# ╠═f04773ac-8795-11eb-3d99-358e3fb52fcc
# ╟─2cad2636-8796-11eb-26e5-3dea19ddc99f
# ╠═2c8a3108-8796-11eb-2e24-1f46d8653318
# ╟─2c6fd7ea-8796-11eb-3fdf-8f29bb83cc37
# ╠═2c549336-8796-11eb-0ac9-db88b339e91a
# ╠═2c3af49e-8796-11eb-3fe8-43ba51426411
# ╟─57a0fe58-8796-11eb-0fb7-332dfa29bcf5
# ╟─5516fd22-8796-11eb-20ba-ef554955d071
# ╟─54fc4464-8796-11eb-324b-0195abc8c4bc
# ╟─54e17b3e-8796-11eb-3b20-45a682c2065b
# ╠═54c55cce-8796-11eb-3774-058c344a886a
# ╟─f04752ac-8795-11eb-03a3-a56cd548eca8
# ╠═1ae849ac-8797-11eb-2376-4189345388ff
# ╠═1accb14c-8797-11eb-1c71-81ad55c19b1d
# ╠═1ab6cef4-8797-11eb-2f81-6140be1f3b0d
# ╟─1a9b44e0-8797-11eb-3e92-2f8dbd5282ae
# ╠═1a7e108c-8797-11eb-11f8-f7be28d15ab9
# ╠═6c41590e-87c6-11eb-17e2-bd5698ae552f
# ╟─43e21928-8797-11eb-0e87-cd5790ab59b1
# ╠═43cc0f16-8797-11eb-1cca-874f98f40302
# ╠═d60b7a5a-87c5-11eb-0685-5100caf67827
# ╠═d5ea675c-87c5-11eb-1bf4-d1ea71c95392
# ╠═ab758052-8797-11eb-1193-b1f04d8f328c
# ╠═0388a272-87c7-11eb-21e9-9190a2f07a1c
