### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 58d05c3e-8774-11eb-2f17-3daba3edae13
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
    import MLJFlux
    using Plots
    using Test
end

# ╔═╡ c3f6ddc0-8782-11eb-0197-25fdd80a50fd
begin
  using Tables

  data = (a = [1, 2, 3, 4],
    b = rand(4),
    c = rand(4),
    d = coerce(["male", "female", "female", "male"], OrderedFactor)
  )
  pretty(data)

  y₂, X₂, w₂ = unpack(data, ==(:a),
    name -> elscitype(Tables.getcolumn(data, name)) == Continuous,
    name -> true);

end

# ╔═╡ 2bb6648a-8774-11eb-17b7-0f6fef114c61
md"""
## A workshop introducing the machine learning toolbox MLJ - Part2 - Selecting, Training and Evaluating Models

  - source:[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)
  - based on [Machine Learning in Julia using MLJ, JuliaCon2020](https://github.com/ablaom/MachineLearningInJulia2020)
"""

# ╔═╡ 7240757e-8774-11eb-3c51-eb10a4c46db3
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

# ╔═╡ 72108d16-8774-11eb-0003-49693e396f19
md"""
##### TOC
  - [Selecting, Training and Evaluating Models](#selecting-training-and-evaluating-models)
  - [Step 1](#step1)
  - [Step 2](#step2)
  - [Step 3](#step3)
  - [Step 4](#step4)
  - [On learning curves](#learning_curves)
  - [Resources or this part](#resources)
  - [Exercises for Part 2](#exercises)
"""

# ╔═╡ 71d64138-8774-11eb-00ff-a3d20a55ccc8
md"""
 **Goals:**
 1. Search MLJ's database of model metadata to identify model candidates for a supervised learning task.
 2. Evaluate the performance of a model on a holdout set using basic `fit!`/`predict` work-flow.
 3. Inspect the outcomes of training and save these to a file.
 3. Evaluate performance using other resampling strategies, such as cross-validation, in one line, using `evaluate!`
 4. Plot a "learning curve", to inspect performance as a function of some model hyper-parameter, such as an iteration parameter

The "Hello World!" of machine learning is to classify Fisher's
famous iris data set. This time, we'll grab the data from
[OpenML](https://www.openml.org):
"""

# ╔═╡ e1fa26aa-8774-11eb-204a-a3c824321016
begin
  iris = OpenML.load(61); # a row table
  iris = DataFrames.DataFrame(iris);
  first(iris, 4)
end

# ╔═╡ 4f4601e2-8785-11eb-2401-e5a978807dc6
html"""
<p style="text-align: right;">
  <a id='step1'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ e1e48b42-8774-11eb-0e4e-07edf1692567
md"""
**Main goal.** To build and evaluate models for predicting the  `:class` variable, given the four remaining measurement variables.


##### Step 1. Inspect and fix scientific types
"""

# ╔═╡ e1c675c6-8774-11eb-0cc8-9fcd3ec74dff
schema(iris)

# ╔═╡ e1ad7eae-8774-11eb-0040-57d9e0fb1236
begin
  coerce!(iris, :class => Multiclass);
  schema(iris)
end

# ╔═╡ 720cb48c-8785-11eb-0649-1f4163b49de6
html"""
<p style="text-align: right;">
  <a id='step2'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ e1916f20-8774-11eb-3503-ef998f66e2bd
md"""
##### Step 2. Split data into input and target parts

Here's how we split the data into target and input features, which is needed for MLJ supervised models. We randomize the data at the same time:
"""

# ╔═╡ 2f9e782a-8775-11eb-1272-efb3abb86766
begin
  yᵢ, Xᵢ = unpack(iris, ==(:class), name->true; rng=123);
  scitype(yᵢ)
end

# ╔═╡ 2f6944fa-8775-11eb-1111-df2b2b267f84
md"""
###### On searching for a model

Here's how to see *all* models (not immediately useful):
"""

# ╔═╡ 2f50d958-8775-11eb-096e-0b8998321174
all_models = models()

# ╔═╡ 2f37d368-8775-11eb-2f0c-fd13ca4fe29d
meta = all_models[3]

# ╔═╡ 2f1ec62a-8775-11eb-26e2-85c032960d6a
meta_xgboost = all_models[153]

# ╔═╡ 2f0eb12c-8775-11eb-17f9-235038e0b0a7
targetscitype = meta.target_scitype

# ╔═╡ 2ef084b8-8775-11eb-2bc0-0b949d966e90
scitype(yᵢ) <: targetscitype
# So this model won't do. Let's  find all pure julia classifiers...

# ╔═╡ 2ed935ba-8775-11eb-08e9-d74a578c22fa
begin
  filter_julia_classifiers(meta) = AbstractVector{Finite} <: meta.target_scitype &&  meta.is_pure_julia

  models(filter_julia_classifiers)
end

# ╔═╡ 2ec20a02-8775-11eb-2449-5749cbbb60e1
md"""
Find all models with "Classifier" in `name` (or `docstring`):
"""

# ╔═╡ 2ea8ed54-8775-11eb-18d6-d1d30c96d908
models("Classifier")

# ╔═╡ e1782812-8774-11eb-1b1c-3faefea1001c
md"""
Find all (supervised) models that match my data!
"""

# ╔═╡ e109c3ae-8774-11eb-3f53-1dc77c89fc61
models(matching(Xᵢ, yᵢ))

# ╔═╡ 77d08a42-8785-11eb-0e54-fda94fc25cbe
html"""
<p style="text-align: right;">
  <a id='step3'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 7e2f4de8-8775-11eb-3cc3-510cbf8258b6
md"""
##### Step 3. Select and instantiate a model

To load the code defining a new model type we use the `@load` macro, which returns an *instance* of the type, with default hyperparameters:
"""

# ╔═╡ 7e17a8fa-8775-11eb-267a-f9732276336b
begin
  _model = @load NeuralNetworkClassifier pkg=MLJFlux
  modelᵢ = _model(epochs=15)
  info(modelᵢ)
end

# ╔═╡ 7df43b38-8775-11eb-1160-ab24fe881df7
md"""
In MLJ a *model* is just a struct containing hyper-parameters, and that's all. A model does not store *learned* parameters. Models are mutable:
"""

# ╔═╡ 7dc2a634-8775-11eb-1a2a-2b64699a3175
@test MLJFlux.NeuralNetworkClassifier(epochs=15) == modelᵢ

# ╔═╡ b14a0508-8775-11eb-2ea5-09289a0926b7
md"""
In MLJ a model and training/validation data are typically bound together in a *machine* as follows:
"""

# ╔═╡ 7da2d596-8775-11eb-22bd-bf94ffdff871
machᵢ = machine(modelᵢ, Xᵢ, yᵢ);

# ╔═╡ 7d8e181a-8775-11eb-1c85-8d0179791c4d
md"""
A machine stores *learned* parameters, among other things. We'll train this machine on 70% of the data and evaluate on a 30% holdout set. Let's start by dividing all row indices into `train` and `test` subsets:
"""

# ╔═╡ 7d70204e-8775-11eb-1bd3-111d1dd44c45
begin
  trainᵢ, testᵢ = partition(eachindex(yᵢ), 0.7)
  size(trainᵢ), size(testᵢ)
end

# ╔═╡ 7d5a596c-8775-11eb-1059-c38021f064e2
md"""
And now we can `fit` the model...
"""

# ╔═╡ 7d3c5bce-8775-11eb-242f-af3448ec4f6c
fit!(machᵢ, rows=trainᵢ, verbosity=2);

# [ Info: Loss is 1.098
# [ Info: Loss is 1.095
# [ Info: Loss is 1.091
# [ Info: Loss is 1.085
# [ Info: Loss is 1.079
# [ Info: Loss is 1.072
# [ Info: Loss is 1.067
# [ Info: Loss is 1.059
# [ Info: Loss is 1.052
# [ Info: Loss is 1.043
# [ Info: Loss is 1.033
# [ Info: Loss is 1.026
# [ Info: Loss is 1.015
# [ Info: Loss is 1.008
# [ Info: Loss is 0.9971

# ╔═╡ e0397248-8775-11eb-31f1-4745600b4927
md"""
... and `predict`:
"""

# ╔═╡ e020dba0-8775-11eb-04c6-5791fa04a0d0
predict(machᵢ, rows=testᵢ)  # or `predict(machᵢ, Xnew)`

# ╔═╡ dfebbeea-8775-11eb-0e03-19641479d64d
md"""
After training, one can inspect the learned parameters:
"""

# ╔═╡ dfd1df34-8775-11eb-083d-1f134983ca77
fitted_params(machᵢ)

# ╔═╡ f74b80a2-8775-11eb-3733-7f27c7d20f3d
md"""
Everything else the user might be interested in is accessed from the  training *report*:
"""

# ╔═╡ f7265138-8775-11eb-2873-6b37109e57df
report(machᵢ)

# ╔═╡ f70c5bca-8775-11eb-07c1-dfff7ad49f4a
md"""
You save a machine like this:
"""

# ╔═╡ 09a19f7a-8776-11eb-1203-f77b73622b87
MLJ.save("neural_net.jlso", machᵢ)

# ╔═╡ f6ef9698-8775-11eb-1400-7bc68f3dbe0f
md"""
And retrieve it like this:
"""

# ╔═╡ 15b16a2a-8776-11eb-1592-3dce20d4a188
begin
  mach₂ = machine("neural_net.jlso")
  predict(mach₂, Xᵢ)[1:3]
end

# ╔═╡ 15935300-8776-11eb-0c72-0f19462b9b10
md"""
If we want to fit a retrieved model, we will need to bind some data to it:
"""

# ╔═╡ 1576a3fe-8776-11eb-2e19-f7266559cf3f
begin
  mach₃ = machine("neural_net.jlso", Xᵢ, yᵢ)
  fit!(mach₃);
end

# ╔═╡ 2f56cae2-8776-11eb-1244-1f49372a694b
md"""
Machines remember the last set of hyper-parameters used during fit, which, in the case of iterative models, allows for a warm restart of computations in the case that only the iteration parameter is increased:
"""

# ╔═╡ 2f3979ec-8776-11eb-023e-c54951130c1a
begin
  modelᵢ.epochs = modelᵢ.epochs + 3
  fit!(machᵢ, rows=trainᵢ, verbosity=2);
end

# [ Info: Loss is 0.9844
# [ Info: Loss is 0.9706
# [ Info: Loss is 0.9555

# ╔═╡ 2f1fe682-8776-11eb-163d-67fa9dec2081
md"""
By default (for this particular model) we can also increase `:learning_rate` without triggering a cold restart:
"""

# ╔═╡ dfb95914-8775-11eb-0da8-bf42ce7e7350
begin
  modelᵢ.epochs = modelᵢ.epochs + 4
  modelᵢ.optimiser.eta = 10 * modelᵢ.optimiser.eta
  fit!(machᵢ, rows=trainᵢ, verbosity=2);
end

# [ Info: Loss is 0.7822
# [ Info: Loss is 0.7047
# [ Info: Loss is 0.6378
# [ Info: Loss is 0.5993

# ╔═╡ dfa1167e-8775-11eb-2245-a3e41d6512ac
md"""
However, change any other parameter and training will restart from scratch:
"""

# ╔═╡ 6af7b84a-8776-11eb-260a-8f04dee6e55a
begin
  modelᵢ.lambda = 0.001
  fit!(machᵢ, rows=trainᵢ, verbosity=2);
end

# [ Info: Loss is 1.055
# [ Info: Loss is 0.9297
# [ Info: Loss is 0.7862
# [ Info: Loss is 0.7138
# [ Info: Loss is 0.6547
# [ Info: Loss is 0.6223
# [ Info: Loss is 0.5939
# [ Info: Loss is 0.5621
# [ Info: Loss is 0.5432
# [ Info: Loss is 0.5187
# [ Info: Loss is 0.5065
# [ Info: Loss is 0.4927
# [ Info: Loss is 0.4777
# [ Info: Loss is 0.4196
# [ Info: Loss is 0.4481
# [ Info: Loss is 0.4189
# [ Info: Loss is 0.4034
# [ Info: Loss is 0.4599
# [ Info: Loss is 0.3912
# [ Info: Loss is 0.4244
# [ Info: Loss is 0.412
# [ Info: Loss is 0.4474
# [ Info: Loss is 0.4246
# [ Info: Loss is 0.389
# [ Info: Loss is 0.3978

# ╔═╡ 6adb6884-8776-11eb-12b2-8dc0829f1bc7
md"""
Let's train silently for a total of 50 epochs, and look at a prediction:
"""

# ╔═╡ 6aa68b5a-8776-11eb-2cbc-258c26de524c
begin
  modelᵢ.epochs = 50
  fit!(machᵢ, rows=trainᵢ);
  ŷᵢ = predict(machᵢ, Xᵢ[testᵢ, :]); # or predict(mach, rows=test)
  ŷᵢ[1]
end
# Optimising neural net:100%[=========================] Time: 0:00:00

# ╔═╡ df8118d8-8775-11eb-234c-a35cf41d7430
md"""
What's going on here?
"""

# ╔═╡ 989e2202-8776-11eb-03a1-49fa4508f71a
info(modelᵢ).prediction_type

# ╔═╡ 98800d12-8776-11eb-1c7c-457f310a3a4d
md"""
**Important**:
  - In MLJ, a model that can predict probabilities (and not just point values) will do so by default. (These models have supertype `Probabilistic`, while point-estimate predictors have supertype `Deterministic`.)
  - For most probabilistic predictors, the predicted object is a `Distributions.Distribution` object, supporting the `Distributions.jl` [API](https://juliastats.org/Distributions.jl/latest/extends/#Create-a-Distribution-1) for such objects. In particular, the methods `rand`,  `pdf`, `mode`, `median` and `mean` will apply, where appropriate.

So, to obtain the probability of "Iris-virginica" in the first test prediction, we do
"""

# ╔═╡ 9868dd68-8776-11eb-3633-afcbd37b82b6
pdf(ŷᵢ[1], "Iris-virginica")

# ╔═╡ 9850ae82-8776-11eb-33bd-4bfbb7eac41b
md"""
To get the most likely observation, we do
"""

# ╔═╡ 98393bc6-8776-11eb-0659-f7225d5839f0
mode(ŷᵢ[1])

# ╔═╡ 981f0ce2-8776-11eb-1546-83d6d1ec5727
md"""
These can be broadcast over multiple predictions in the usual way:
"""

# ╔═╡ be74448e-8776-11eb-3018-c722a9182899
broadcast(pdf, ŷᵢ[1:4], "Iris-versicolor")

# ╔═╡ be58b4d0-8776-11eb-3eea-3350fe77c4f2
mode.(ŷᵢ[1:4])

# ╔═╡ be3edd94-8776-11eb-31c6-634f25bacbc2
md"""
Or, alternatively, you can use the `predict_mode` operation instead of `predict`:
"""

# ╔═╡ be24b926-8776-11eb-09c2-335929294063
predict_mode(machᵢ, Xᵢ[testᵢ,:])[1:4] # or predict_mode(mach, rows=test)[1:4]

# ╔═╡ be14985e-8776-11eb-341f-f9c6c418f697
md"""
For a more conventional matrix of probabilities you can do this:
"""

# ╔═╡ bdf3586a-8776-11eb-0ac3-ddc972c36518
begin
  L = levels(yᵢ)
  pdf(ŷᵢ, L)[1:4, :]
end

# ╔═╡ bddcc460-8776-11eb-32a8-45a1bda54031
md"""
However, in a typical MLJ work-flow, this is not as useful as you might imagine. In particular, all probabilistic performance measures in MLJ expect distribution objects in their first slot:
"""

# ╔═╡ e700cc38-8776-11eb-1c82-35ed07df74af
cross_entropy(ŷᵢ, yᵢ[testᵢ]) |> mean

# ╔═╡ e6e1d9c2-8776-11eb-243c-4db077b59c05
md"""
To apply a deterministic measure, we first need to obtain point-estimates:
"""

# ╔═╡ e6c6f486-8776-11eb-20ed-4140d2fdfc59
misclassification_rate(mode.(ŷᵢ), yᵢ[testᵢ])

# ╔═╡ e6ad53c6-8776-11eb-37e9-f521bde89017
md"""
We note in passing that there is also a search tool for measures analogous to `models`:
"""

# ╔═╡ 98060a3a-8776-11eb-1385-ffc7eac03387
measures()

# ╔═╡ 03a66230-8777-11eb-0a4c-bda208768889
# measures(matching(y)) # experimental!

# ╔═╡ 861ed130-8785-11eb-207d-1b60a935f028
html"""
<p style="text-align: right;">
  <a id='step4'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 0388dd00-8777-11eb-11b6-23a5968841f7
md"""
##### Step 4. Evaluate the model performance

Naturally, MLJ provides boilerplate code for carrying out a model evaluation with a lot less fuss. Let's repeat the performance evaluation above and add an extra measure, `brier_score`:

"""

# ╔═╡ 1544115e-8777-11eb-28df-3167da05d7cb
evaluate!(machᵢ,
  resampling=Holdout(fraction_train=0.7),
  measures=[cross_entropy, brier_score])

# ╔═╡ 0376892a-8777-11eb-10fe-ebd9a30329b5
md"""
Or applying cross-validation instead:
"""

# ╔═╡ 03503764-8777-11eb-0793-598490c04eba
evaluate!(machᵢ,
  resampling=CV(nfolds=6),
  measures=[cross_entropy, brier_score])

# Evaluating over 6 folds: 100%[=========================] Time: 0:00:12

# ╔═╡ da97b186-8781-11eb-0591-757d7c34d247
md"""
Or, Monte Carlo cross-validation (cross-validation repeated randomized folds)
"""

# ╔═╡ da7f0320-8781-11eb-3047-832718ddd4d0
e = evaluate!(machᵢ, resampling=CV(nfolds=6, rng=123),
  repeats=3,
  measures=[cross_entropy, brier_score])

# Evaluating over 18 folds: 100%[=========================] Time: 0:00:35

# ╔═╡ da634a7c-8781-11eb-34ce-21239b737208
md"""
One can access the following properties of the output `e` of an evaluation: `measure`, `measurement`, `per_fold` (measurement for each fold) and `per_observation` (measurement per observation, if reported).
"""

# ╔═╡ da499c0a-8781-11eb-1ecc-c78a2894425e
e.measure

# ╔═╡ da312b96-8781-11eb-1a04-e709749917af
e.per_fold

# ╔═╡ da19bd4e-8781-11eb-2316-a77ff448d985
md"""
Finally note that we can restrict the rows of observations from which train and test folds are drawn, by specifying `rows=...`.

For  example, imagining the last 30% of target observations are `missing` you might have a work-flow like this:
"""

# ╔═╡ 03fb3db0-8782-11eb-22a3-abdefb466c7b
begin
  trainₓ, testₓ = partition(eachindex(yᵢ), 0.7)
  machₓ = machine(modelᵢ, Xᵢ, yᵢ)
  evaluate!(machₓ, resampling=CV(nfolds=6),
    measures=[cross_entropy, brier_score],
    rows=trainₓ)            # cv estimate, resampling from `train`
  fit!(machₓ, rows=trainₓ)    # re-train using all of `train` observations
  predict(machₓ, rows=testₓ); # and predict missing targets
end

# ╔═╡ f980ec9a-8784-11eb-3c1f-cbd12e90eb12
html"""
<a id='learning_curves'></a>
"""

# ╔═╡ 03e5ccf8-8782-11eb-3b06-3fd79d29ece7
md"""
##### On learning curves

Since our model is an iterative one, we might want to inspect the out-of-sample performance as a function of the iteration parameter. For this we can use the `learning_curve` function (which, incidentally can be applied to any model hyper-parameter). This  starts by defining a one-dimensional range object for the parameter  (more on this when we discuss tuning in Part 4):
"""

# ╔═╡ 03ca941a-8782-11eb-3d2c-992431e1eaf2
begin
  r = range(modelᵢ, :epochs, lower=1, upper=50, scale=:log)

  curve = learning_curve(machₓ, range=r,
    resampling=Holdout(fraction_train=0.7), # (default)
    measure=cross_entropy)
end

# ╔═╡ 03b234ea-8782-11eb-259a-0566fa974775
plot(curve.parameter_values, curve.measurements, lw=3,
  xlabel="epochs",
  ylabel="cross entropy on holdout set")

# ╔═╡ 70bb451e-8774-11eb-18df-512352f9b934
html"""
<p style="text-align: right;">
  <a id='resources'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 704ad2e8-8774-11eb-2083-812bdb1f4ffe
md"""
##### Resources for Part 2

  - From the MLJ manual:
    - [Getting Started](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/)
    - [Model Search](https://alan-turing-institute.github.io/MLJ.jl/dev/model_search/)
    - [Evaluating Performance](https://alan-turing-institute.github.io/MLJ.jl/dev/evaluating_model_performance/) (using `evaluate!`)
    - [Learning Curves](https://alan-turing-institute.github.io/MLJ.jl/dev/learning_curves/)
    - [Performance Measures](https://alan-turing-institute.github.io/MLJ.jl/dev/performance_measures/) (loss functions, scores, etc)
- From Data Science Tutorials:
    - [Choosing and evaluating a model](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/choosing-a-model/)
    - [Fit, predict, transform](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/fit-and-predict/)

"""

# ╔═╡ fbd65648-8774-11eb-1556-135f1f66e11a
html"""
<p style="text-align: right;">
  <a id='exercises'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ b8924b1c-8774-11eb-12f0-75a0c9247554
md"""
#### Exercises for Part 2


##### Exercise 1

(a) Identify all supervised MLJ models that can be applied (without type coercion or one-hot encoding) to a supervised learning problem with input features `X4` and target `y4` defined below:
"""

# ╔═╡ c2ca6d30-8774-11eb-2f9f-853ae8843263
begin
  import Distributions
  poisson = Distributions.Poisson

  age = 18 .+ 60 * rand(10);
  # do not use symbol => crash!
  salary = coerce(rand(["big", "huge", "small"], 10), OrderedFactor);
  levels!(salary, ["small", "big", "huge"]);

  X₁ = DataFrames.DataFrame(age=age, salary=salary)
end

# ╔═╡ 87ccbfea-8782-11eb-28c5-1fd0c3ca976e
begin
  n_devices(salary) = salary > "small" ? rand(poisson(1.3)) : rand(poisson(2.9))
  y₁ = [n_devices(row.salary) for row in eachrow(X₁)];
end

# ╔═╡ 877b6546-8782-11eb-0787-7f71094de4b0
schema(X₁)

# ╔═╡ 869d4842-8782-11eb-0863-77d366291f93
models(matching(X₁, y₁))

# ╔═╡ a810df34-8782-11eb-1729-19864c77e6f0
md"""
##### Exercise 2 (unpack)

After evaluating the following ...
"""

# ╔═╡ c2a292b0-8774-11eb-11d7-b5a05aa9f616
md"""
...attempt to guess the evaluations of the following:
"""

# ╔═╡ c27462d2-8774-11eb-102e-135655b15bc4
begin
  @test y₂ == data.a
  @test typeof(y₂) <: AbstractVector
end

# ╔═╡ d824285c-8782-11eb-09be-7bfa9e2f63dc
# Tables.columnnames(data)
typeof(X₂) # Tables.getcolumn(data, [:a, :b])

# ╔═╡ d809473a-8782-11eb-2331-19eccaff712a
begin
  # Xₙ contains only the continuous attributres from data
  @test X₂ == (b=data.b, c=data.c)
end

# ╔═╡ c2563758-8774-11eb-0903-dd227f7618d1
with_terminal() do
  pretty(X₂)
end

# ╔═╡ 105a8fe8-8783-11eb-2f0b-8fb550d77372
begin
  @test w₂ == data.d
  @test typeof(w₂) <: AbstractVector
end

# ╔═╡ 103d8df8-8783-11eb-2c3d-eff502ac833c
md"""
##### Exercise 3 (first steps in modeling Horse Colic)

(a) Suppose we want to use predict the `:outcome` variable in the
Horse Colic study introduced in Part 1, based on the remaining
variables that are `Continuous` (one-hot encoding categorical
variables is discussed later in Part 3) *while ignoring the others*.

Extract from the `horse` data set (defined in Part 1) appropriate
input features `X` and target variable `y`. (Do not, however,
randomize the observations.)
"""

# ╔═╡ 3de19b84-8783-11eb-139d-9d80c29134d4
begin
  const DIR = "."
  hfile = CSV.File(joinpath(DIR, "data", "horse.csv"));
  horse = DataFrames.DataFrame(hfile); # convert to data frame without copying columns
  first(horse, 4)
end

# ╔═╡ 1025137e-8783-11eb-365c-ab4ec44ed329
DataFrames.describe(horse, :eltype, :first => first)

# ╔═╡ af1ff426-8783-11eb-239f-1b70da86ce69
md"""
Let's make some changes for the scientific types
"""

# ╔═╡ c5c80b78-8783-11eb-2687-1b29f016d826
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

# ╔═╡ 100e01fc-8783-11eb-1434-bb5bf50dd24d
begin
  yₕ, Xₕ = unpack(horse, ==(:outcome),
    name -> elscitype(Tables.getcolumn(horse, name)) == Continuous);
  scitype(yₕ)
end

# ╔═╡ 7b44603a-8783-11eb-1c85-37ad050e6e26
md"""
(b) Create a 70:30 `train`/`test` split of the data and train a
`LogisticClassifier` model, from the `MLJLinearModels` package, on
the `train` rows. Use `lambda=100` and default values for the
other hyper-parameters. (Although one would normally standardize
(whiten) the continuous features for this model, do not do so here.)
After training:

- (i) Recalling that a logistic classifier (aka logistic regressor) is
  a linear-based model learning a *vector* of coefficients for each
  feature (one coefficient for each target class), use the
  `fitted_params` method to find this vector of coefficients in the
  case of the `:pulse` feature. (You can convert a vector of pairs `v =
  [x1 => y1, x2 => y2, ...]` into a dictionary with `Dict(v)`.)

- (ii) Evaluate the `cross_entropy` performance on the `test`
  observations.

- (iii) In how many `test` observations does the predicted
  probability of the observed class exceed 50%?

- (iv) Find the `misclassification_rate` in the `test` set.
  (*Hint.* As this measure is deterministic, you will either  need to broadcast `mode` or use `predict_mode` instead of
  `predict`.)

"""

# ╔═╡ 7b2c41ce-8783-11eb-0e4e-77c7c1f7ca6e
begin
  trainₕ, testₕ = partition(eachindex(yₕ), 0.7)
  size(trainₕ), size(testₕ)
end

# ╔═╡ 7b13911c-8783-11eb-000a-69067847d3ca
begin
  @load LogisticClassifier pkg=MLJLinearModels
  modelₕ = MLJLinearModels.LogisticClassifier(lambda=100)
  info(modelₕ)
end

# ╔═╡ 7aeb0e5e-8783-11eb-1560-0bd4641490ab
begin
  machₕ = machine(modelₕ, Xₕ, yₕ);
  fit!(machₕ, rows=trainₕ);
end

# ╔═╡ 0ff1eba2-8783-11eb-345b-712a8df94a74
Dict(fitted_params(machₕ)[:coefs])[:pulse]

# ╔═╡ 09ddfafc-8784-11eb-2bcc-27382c2cd9b9
begin
  ŷₕ = predict(machₕ, Xₕ[testₕ,:])
  cross_entropy(ŷₕ, yₕ[testₕ]) |> mean
end

# ╔═╡ 09c5248c-8784-11eb-03b7-09739daa1528
info(modelₕ).prediction_type

# ╔═╡ 09a98e2a-8784-11eb-27ef-2f37c8ce8a05
begin
  # The predicted probs of the actual obs. in the test are given by
  pₕ = broadcast(pdf, ŷₕ, yₕ[testₕ]);

  # The number of times this probability exceeds 50% is:
  filter(p -> p > 0.5, pₕ) |> length
end

# ╔═╡ 0974d978-8784-11eb-13a2-bf91e30d3b3c
misclassification_rate(mode.(ŷₕ), yₕ[testₕ])

# ╔═╡ 2a62df22-8784-11eb-1225-9f45e08c433d
md"""
(c) Instead use a `RandomForestClassifier` model from the
    `DecisionTree` package and:

- (i) Generate an appropriate learning curve to convince yourself
  that out-of-sample estimates of the `cross_entropy` loss do not
  substantially improve for `n_trees > 50`. Use default values for
  all other hyper-parameters, and feel free to use all available
  data to generate the curve.

- (ii) Fix `n_trees=90` and use `evaluate!` to obtain a 9-fold
  cross-validation estimate of the `cross_entropy`, restricting
  sub-sampling to the `train` observations.

- (iii) Now use *all* available data but set
  `resampling=Holdout(fraction_train=0.7)` to obtain a score you can
  compare with the `KNNClassifier` in part (b)(iii). Which model is
  better?
"""

# ╔═╡ 2a366eba-8784-11eb-192b-af01d875e165
begin
  @load RandomForestClassifier pkg=DecisionTree
  model_rf = DecisionTree.RandomForestClassifier(n_trees=50)
end

# ╔═╡ 2a193a7a-8784-11eb-110d-4f0a37c0ce40
begin
  mach_rf =  machine(model_rf, Xₕ, yₕ)
  evaluate!(mach_rf, resampling=CV(nfolds=6), measure=cross_entropy)
end

# ╔═╡ 24fc87e0-8784-11eb-018f-87fee51f7013
#TODO ...

# ╔═╡ Cell order:
# ╟─2bb6648a-8774-11eb-17b7-0f6fef114c61
# ╠═58d05c3e-8774-11eb-2f17-3daba3edae13
# ╟─7240757e-8774-11eb-3c51-eb10a4c46db3
# ╟─992cc480-8785-11eb-0572-c33c1c988efc
# ╟─72108d16-8774-11eb-0003-49693e396f19
# ╟─71d64138-8774-11eb-00ff-a3d20a55ccc8
# ╠═e1fa26aa-8774-11eb-204a-a3c824321016
# ╟─4f4601e2-8785-11eb-2401-e5a978807dc6
# ╟─e1e48b42-8774-11eb-0e4e-07edf1692567
# ╠═e1c675c6-8774-11eb-0cc8-9fcd3ec74dff
# ╠═e1ad7eae-8774-11eb-0040-57d9e0fb1236
# ╟─720cb48c-8785-11eb-0649-1f4163b49de6
# ╟─e1916f20-8774-11eb-3503-ef998f66e2bd
# ╠═2f9e782a-8775-11eb-1272-efb3abb86766
# ╟─2f6944fa-8775-11eb-1111-df2b2b267f84
# ╠═2f50d958-8775-11eb-096e-0b8998321174
# ╠═2f37d368-8775-11eb-2f0c-fd13ca4fe29d
# ╠═2f1ec62a-8775-11eb-26e2-85c032960d6a
# ╠═2f0eb12c-8775-11eb-17f9-235038e0b0a7
# ╠═2ef084b8-8775-11eb-2bc0-0b949d966e90
# ╠═2ed935ba-8775-11eb-08e9-d74a578c22fa
# ╟─2ec20a02-8775-11eb-2449-5749cbbb60e1
# ╠═2ea8ed54-8775-11eb-18d6-d1d30c96d908
# ╠═e1782812-8774-11eb-1b1c-3faefea1001c
# ╠═e109c3ae-8774-11eb-3f53-1dc77c89fc61
# ╟─77d08a42-8785-11eb-0e54-fda94fc25cbe
# ╟─7e2f4de8-8775-11eb-3cc3-510cbf8258b6
# ╠═7e17a8fa-8775-11eb-267a-f9732276336b
# ╟─7df43b38-8775-11eb-1160-ab24fe881df7
# ╠═7dc2a634-8775-11eb-1a2a-2b64699a3175
# ╟─b14a0508-8775-11eb-2ea5-09289a0926b7
# ╠═7da2d596-8775-11eb-22bd-bf94ffdff871
# ╟─7d8e181a-8775-11eb-1c85-8d0179791c4d
# ╠═7d70204e-8775-11eb-1bd3-111d1dd44c45
# ╟─7d5a596c-8775-11eb-1059-c38021f064e2
# ╠═7d3c5bce-8775-11eb-242f-af3448ec4f6c
# ╟─e0397248-8775-11eb-31f1-4745600b4927
# ╠═e020dba0-8775-11eb-04c6-5791fa04a0d0
# ╟─dfebbeea-8775-11eb-0e03-19641479d64d
# ╠═dfd1df34-8775-11eb-083d-1f134983ca77
# ╟─f74b80a2-8775-11eb-3733-7f27c7d20f3d
# ╠═f7265138-8775-11eb-2873-6b37109e57df
# ╟─f70c5bca-8775-11eb-07c1-dfff7ad49f4a
# ╠═09a19f7a-8776-11eb-1203-f77b73622b87
# ╟─f6ef9698-8775-11eb-1400-7bc68f3dbe0f
# ╠═15b16a2a-8776-11eb-1592-3dce20d4a188
# ╟─15935300-8776-11eb-0c72-0f19462b9b10
# ╠═1576a3fe-8776-11eb-2e19-f7266559cf3f
# ╟─2f56cae2-8776-11eb-1244-1f49372a694b
# ╠═2f3979ec-8776-11eb-023e-c54951130c1a
# ╟─2f1fe682-8776-11eb-163d-67fa9dec2081
# ╠═dfb95914-8775-11eb-0da8-bf42ce7e7350
# ╟─dfa1167e-8775-11eb-2245-a3e41d6512ac
# ╠═6af7b84a-8776-11eb-260a-8f04dee6e55a
# ╟─6adb6884-8776-11eb-12b2-8dc0829f1bc7
# ╠═6aa68b5a-8776-11eb-2cbc-258c26de524c
# ╟─df8118d8-8775-11eb-234c-a35cf41d7430
# ╠═989e2202-8776-11eb-03a1-49fa4508f71a
# ╟─98800d12-8776-11eb-1c7c-457f310a3a4d
# ╠═9868dd68-8776-11eb-3633-afcbd37b82b6
# ╟─9850ae82-8776-11eb-33bd-4bfbb7eac41b
# ╠═98393bc6-8776-11eb-0659-f7225d5839f0
# ╟─981f0ce2-8776-11eb-1546-83d6d1ec5727
# ╠═be74448e-8776-11eb-3018-c722a9182899
# ╠═be58b4d0-8776-11eb-3eea-3350fe77c4f2
# ╟─be3edd94-8776-11eb-31c6-634f25bacbc2
# ╠═be24b926-8776-11eb-09c2-335929294063
# ╟─be14985e-8776-11eb-341f-f9c6c418f697
# ╠═bdf3586a-8776-11eb-0ac3-ddc972c36518
# ╟─bddcc460-8776-11eb-32a8-45a1bda54031
# ╠═e700cc38-8776-11eb-1c82-35ed07df74af
# ╟─e6e1d9c2-8776-11eb-243c-4db077b59c05
# ╠═e6c6f486-8776-11eb-20ed-4140d2fdfc59
# ╟─e6ad53c6-8776-11eb-37e9-f521bde89017
# ╠═98060a3a-8776-11eb-1385-ffc7eac03387
# ╠═03a66230-8777-11eb-0a4c-bda208768889
# ╟─861ed130-8785-11eb-207d-1b60a935f028
# ╟─0388dd00-8777-11eb-11b6-23a5968841f7
# ╠═1544115e-8777-11eb-28df-3167da05d7cb
# ╟─0376892a-8777-11eb-10fe-ebd9a30329b5
# ╠═03503764-8777-11eb-0793-598490c04eba
# ╟─da97b186-8781-11eb-0591-757d7c34d247
# ╠═da7f0320-8781-11eb-3047-832718ddd4d0
# ╟─da634a7c-8781-11eb-34ce-21239b737208
# ╠═da499c0a-8781-11eb-1ecc-c78a2894425e
# ╠═da312b96-8781-11eb-1a04-e709749917af
# ╟─da19bd4e-8781-11eb-2316-a77ff448d985
# ╠═03fb3db0-8782-11eb-22a3-abdefb466c7b
# ╟─f980ec9a-8784-11eb-3c1f-cbd12e90eb12
# ╟─03e5ccf8-8782-11eb-3b06-3fd79d29ece7
# ╠═03ca941a-8782-11eb-3d2c-992431e1eaf2
# ╠═03b234ea-8782-11eb-259a-0566fa974775
# ╟─70bb451e-8774-11eb-18df-512352f9b934
# ╟─704ad2e8-8774-11eb-2083-812bdb1f4ffe
# ╟─fbd65648-8774-11eb-1556-135f1f66e11a
# ╟─b8924b1c-8774-11eb-12f0-75a0c9247554
# ╠═c2ca6d30-8774-11eb-2f9f-853ae8843263
# ╠═87ccbfea-8782-11eb-28c5-1fd0c3ca976e
# ╠═877b6546-8782-11eb-0787-7f71094de4b0
# ╠═869d4842-8782-11eb-0863-77d366291f93
# ╟─a810df34-8782-11eb-1729-19864c77e6f0
# ╠═c3f6ddc0-8782-11eb-0197-25fdd80a50fd
# ╟─c2a292b0-8774-11eb-11d7-b5a05aa9f616
# ╠═c27462d2-8774-11eb-102e-135655b15bc4
# ╠═d824285c-8782-11eb-09be-7bfa9e2f63dc
# ╠═d809473a-8782-11eb-2331-19eccaff712a
# ╠═c2563758-8774-11eb-0903-dd227f7618d1
# ╠═105a8fe8-8783-11eb-2f0b-8fb550d77372
# ╟─103d8df8-8783-11eb-2c3d-eff502ac833c
# ╠═3de19b84-8783-11eb-139d-9d80c29134d4
# ╠═1025137e-8783-11eb-365c-ab4ec44ed329
# ╟─af1ff426-8783-11eb-239f-1b70da86ce69
# ╠═c5c80b78-8783-11eb-2687-1b29f016d826
# ╠═100e01fc-8783-11eb-1434-bb5bf50dd24d
# ╟─7b44603a-8783-11eb-1c85-37ad050e6e26
# ╠═7b2c41ce-8783-11eb-0e4e-77c7c1f7ca6e
# ╠═7b13911c-8783-11eb-000a-69067847d3ca
# ╠═7aeb0e5e-8783-11eb-1560-0bd4641490ab
# ╠═0ff1eba2-8783-11eb-345b-712a8df94a74
# ╠═09ddfafc-8784-11eb-2bcc-27382c2cd9b9
# ╠═09c5248c-8784-11eb-03b7-09739daa1528
# ╠═09a98e2a-8784-11eb-27ef-2f37c8ce8a05
# ╠═0974d978-8784-11eb-13a2-bf91e30d3b3c
# ╟─2a62df22-8784-11eb-1225-9f45e08c433d
# ╠═2a366eba-8784-11eb-192b-af01d875e165
# ╠═2a193a7a-8784-11eb-110d-4f0a37c0ce40
# ╠═24fc87e0-8784-11eb-018f-87fee51f7013
