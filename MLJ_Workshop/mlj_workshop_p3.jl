### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ db039f9e-8787-11eb-3037-6566e5cd35e1
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

# ╔═╡ 922be298-878e-11eb-16a8-35f47ace05e1
begin
	using Clustering
	using MLJClusteringInterface
end

# ╔═╡ 303866da-8791-11eb-0872-b908cba30c10
using Random

# ╔═╡ b0de5b8e-8787-11eb-1a63-e94d308ecf79
md"""
## A workshop introducing the machine learning toolbox MLJ - Part3 - Transformers and Pipelines

  - source:[MLJ](https://alan-turing-institute.github.io/MLJ.jl/stable/)
  - based on [Machine Learning in Julia using MLJ, JuliaCon2020](https://github.com/ablaom/MachineLearningInJulia2020)
"""

# ╔═╡ dae6f0a6-8787-11eb-18be-5bee665ff211
md"""
##### General resources

  - [List of methods introduced in this tutorial](methods.md)
  - [MLJ Cheatsheet](https://alan-turing-institute.github.io/MLJ.jl/dev/mlj_cheatsheet/)
  - [Common MLJ Workflows](https://alan-turing-institute.github.io/MLJ.jl/dev/common_mlj_workflows/)
  - [MLJ manual](https://alan-turing-institute.github.io/MLJ.jl/dev/)
  - [Data Science Tutorials in Julia](https://alan-turing-institute.github.io/DataScienceTutorials.jl/)
"""

# ╔═╡ dacb2c5e-8787-11eb-0f18-03004883918e
html"""
<a id='toc'></a>
"""

# ╔═╡ daadfbca-8787-11eb-1e8b-df76827065f3
md"""
##### TOC
  - [Transformers](#transformers)
  - [More transformers](#more-transformers)
  - [Pipelines](#pipelines)
  - [Training of composite models is "smart"](#training)
  - [Incorporating target transformations](#target-transfo)
  - [Resources or this part](#resources)
  - [Exercises for Part 3](#exercises)
"""

# ╔═╡ 336759dc-8788-11eb-2f1f-47edaaa7eeb6
html"""
<p style="text-align: right;">
  <a id='transformer'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 3468ea44-8788-11eb-0043-c777b00c423c
md"""
#### Transformers

Unsupervised models, which receive no target `y` during training,
always have a `transform` operation. They sometimes also support an
`inverse_transform` operation, with obvious meaning, and sometimes
support a `predict` operation (see the clustering example discussed
[here](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/#Transformers-that-also-predict-1)).
Otherwise, they are handled much like supervised models.

Here's a simple standardization example:
"""

# ╔═╡ 66ad95f4-8788-11eb-0d86-21ccf44a07ad
begin
	xᵣ = rand(100);
	@show (μ=mean(xᵣ), σ=std(xᵣ));
end

# ╔═╡ 6692ca9e-8788-11eb-0e22-23255f139aa5
begin
	modelᵣ = Standardizer() # a built-in model
	
	machᵣ = machine(modelᵣ, xᵣ)
	fit!(machᵣ)
	x̂ᵣ = transform(machᵣ, xᵣ);
	@show (μ=mean(x̂ᵣ,), σ=std(x̂ᵣ));
end

# ╔═╡ 667ae6fe-8788-11eb-37e0-937840f15342
md"""
This particular model has an `inverse_transform`:
"""

# ╔═╡ 665e3cac-8788-11eb-28ab-e1a34482956c
inverse_transform(machᵣ, x̂ᵣ) ≈ xᵣ

# ╔═╡ 662d8c94-8788-11eb-1cc2-ebadc5980bc4
md"""
### Re-encoding the King County House data as continuous

For further illustrations of transformers, let's re-encode *all* of the
King County House input features (see **[Ex
3/Part 1]**) into a set of `Continuous`
features. We do this with the `ContinuousEncoder` model, which, by
default, will:

  - one-hot encode all `Multiclass` features
  - coerce all `OrderedFactor` features to `Continuous` ones
  - coerce all `Count` features to `Continuous` ones (there aren't any)
  - drop any remaining non-Continuous features (none of these either)

First, we reload the data and fix the scitypes (Exercise 3):
"""

# ╔═╡ 66140f1a-8788-11eb-1b90-138a63cdc086
begin
	const DIR="."
	hfile = CSV.File(joinpath(DIR, "data", "house.csv"));

	house = DataFrames.DataFrame(hfile)
	coerce!(house, autotype(hfile))
	coerce!(house, Count => Continuous, :zipcode => Multiclass);
	schema(house)
end

# ╔═╡ da835c8e-8788-11eb-3905-0b961fb28506
yₕ, Xₕ = unpack(house, ==(:price), name -> true, rng=123);

# ╔═╡ da5ab4fa-8788-11eb-1aa3-c1a921e861c8
md"""
Instantiate the unsupervised model (transformer):
"""

# ╔═╡ da285618-8788-11eb-0635-8dcc0c9b5968
encoder = ContinuousEncoder() # a built-in model; no need to @load it

# ╔═╡ fe5fd3bc-8788-11eb-095a-29f563116783
md"""
Bind the model to the data and fit! $(html"<br />")
Then, Transform and inspect the result:
"""

# ╔═╡ fe3c4352-8788-11eb-02ab-a39f52eed4b8
begin
	machₕ = machine(encoder, Xₕ) |> fit!;
	Xcont = transform(machₕ, Xₕ);
	schema(Xcont)
end

# ╔═╡ 45ad2292-8789-11eb-1b70-e7df1c2198b4
html"""
<p style="text-align: right;">
  <a id='more-transformer'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 2688f3aa-8789-11eb-2ccc-57a834adb9d2
md"""
#### More transformers

Here's how to list all of MLJ's unsupervised models:
"""

# ╔═╡ fe1da1ce-8788-11eb-0235-47ac875ab7fb
models(m -> !m.is_supervised)

# ╔═╡ fe055a04-8788-11eb-2b38-2b23cbae597c
md"""
Some commonly used ones are built-in (do not require `@load`ing):

model type                  | does what?
----------------------------|----------------------------------------------
ContinuousEncoder | transform input table to a table of `Continuous` features (see above)
FeatureSelector | retain or dump selected features
FillImputer | impute missing values
OneHotEncoder | one-hot encoder `Multiclass` (and optionally `OrderedFactor`) features
Standardizer | standardize (whiten) a vector or all `Continuous` features of a table
UnivariateBoxCoxTransformer | apply a learned Box-Cox transformation to a vector
UnivariateDiscretizer | discretize a `Continuous` vector, and hence render its elscitypw `OrderedFactor`


In addition to "dynamic" transformers (ones that learn something
from the data and must be `fit!`) users can wrap ordinary functions
as transformers, and such *static* transformers can depend on
parameters, like the dynamic ones. See
[here](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/#Static-transformers-1)
for how to define your own static transformers.
"""

# ╔═╡ fdeaedae-8788-11eb-3dab-f16f800d2b77
html"""
<p style="text-align: right;">
  <a id='pipelines'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ da147a30-8788-11eb-01d0-ed61ac48ddee
md"""
#### Pipelines
"""

# ╔═╡ 65fa258c-8788-11eb-00c6-9f0b8f477d5d
length(schema(Xcont).names)

# ╔═╡ 013a548a-878a-11eb-160a-1da458bd2324
md"""
Let's suppose that additionally we'd like to reduce the dimension of our data.  A model that will do this is `PCA` from `MultivariateStats`:
"""

# ╔═╡ 01205ec2-878a-11eb-2fad-f9b213f4560f
# Pkg.add("MLJMultivariateStatsInterface")

# ╔═╡ 0103cd2a-878a-11eb-34df-8fb2e0261c30
reducer = @load PCA

# ╔═╡ 00ec055a-878a-11eb-3dac-1d0f6e10ea8c
md"""
Now, rather than simply repeating the work-flow above, applying the new
transformation to `Xcont`, we can combine both the encoding and the
dimension-reducing models into a single model, known as a
*pipeline*. 

While MLJ offers a powerful interface for composing
models in a variety of ways, we'll stick to these simplest class of
composite models for now. The easiest way to construct them is using
the `@pipeline` macro:
"""

# ╔═╡ 00d28b20-878a-11eb-108d-99e7981ae462
pipe = @pipeline encoder reducer

# ╔═╡ 266cd818-878a-11eb-34d6-c173735c9604
md"""
Notice that `pipe` is an *instance* of an automatically generated type (called `Pipeline<some digits>`).

The new model behaves like any other transformer:
"""

# ╔═╡ 2651f002-878a-11eb-2f30-71384dae63d3
begin
	machₚ = machine(pipe, Xₕ)
	fit!(machₚ)
	Xsmallₚ = transform(machₚ, Xₕ)
	schema(Xsmallₚ)
end

# ╔═╡ 2637ca10-878a-11eb-07be-af6d5a769213
md"""
Want to combine this pre-processing with ridge regression?
"""

# ╔═╡ 67bde8de-878a-11eb-19d9-4176c3871746
@load RidgeRegressor pkg=MLJLinearModels

# ╔═╡ 67a2c568-878a-11eb-2c52-1f3503de2742
rregr = MLJLinearModels.RidgeRegressor()

# ╔═╡ 6788dc0e-878a-11eb-1552-0d7d020eaa2c
pipe₂ = @pipeline encoder reducer rregr

# ╔═╡ 77a77936-878a-11eb-255c-116e90f96738
md"""
Now our pipeline is a supervised model, instead of a transformer, whose performance we can evaluate:
"""

# ╔═╡ 77885420-878a-11eb-08a8-43f03f192651
begin
	mach₂ = machine(pipe₂, Xₕ, yₕ)
	evaluate!(mach₂, measure=mae, resampling=Holdout()) # CV(nfolds=6) is default
end

# ╔═╡ abebfdde-878a-11eb-09ad-b1440c37497c
html"""
<p style="text-align: right;">
  <a id='training'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 775acdfc-878a-11eb-0007-5519985c1642
md"""
#### Training of composite models is "smart"

Now notice what happens if we train on all the data, then change a regressor hyper-parameter and retrain:
"""

# ╔═╡ 6776361a-878a-11eb-3fca-b721f6de3c4b
fit!(mach₂);

# ╔═╡ 261a54a8-878a-11eb-0b82-a55b8f646bb2
begin
	pipe₂.ridge_regressor.lambda = 0.1
	fit!(mach₂)
end

# ╔═╡ 235d9a16-878a-11eb-219f-7750704b1e0b
md"""
Second time only the ridge regressor is retrained!

Mutate a hyper-parameter of the `PCA` model and every model except the `ContinuousEncoder` (which comes before it will be retrained):
"""

# ╔═╡ 235c6dbc-878a-11eb-22b2-1f7f9f4fec5b
begin
	pipe₂.pca.pratio = 0.9999
	fit!(mach₂)
end

# ╔═╡ fa99cd76-878a-11eb-00f5-170c7825df20
md"""
##### Inspecting composite models

The dot syntax used above to change the values of *nested* hyper-parameters is also useful when inspecting the learned parameters and report generated when training a composite model:
"""

# ╔═╡ fa8042de-878a-11eb-10db-35eb7404e05b
fitted_params(mach₂).ridge_regressor

# ╔═╡ fa613254-878a-11eb-0d6a-1f07472f012c
report(mach₂).pca

# ╔═╡ fa4524ec-878a-11eb-2754-cd5ca0dcee5d
html"""
<p style="text-align: right;">
  <a id='target-transfo'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ fa29314c-878a-11eb-2fce-e95e75060931
md"""
##### Incorporating target transformations

Next, suppose that instead of using the raw `:price` as the training target, we want to use the log-price (a common practice in dealing with house price data). However, suppose that we still want to report final *predictions* on the original linear scale (and use these for evaluation purposes). Then we supply appropriate functions to key-word arguments `target` and `inverse`.

First we'll overload `log` and `exp` for broadcasting:
"""

# ╔═╡ 235c47bc-878a-11eb-3511-7b85a574207a
begin
	Base.log(v::AbstractArray) = log.(v)
	Base.exp(v::AbstractArray) = exp.(v)
end

# ╔═╡ 5282e4a0-878b-11eb-36df-73cdf38aaa7e
md"""
Now for the new pipeline:
"""

# ╔═╡ 52629a88-878b-11eb-3cf0-77bc93decb35
begin
	pipe₃ = @pipeline encoder reducer rregr target=log inverse=exp
	mach₃ = machine(pipe₃, Xₕ, yₕ)
	evaluate!(mach₃, measure=mae);
end

# ╔═╡ 52499fb0-878b-11eb-191c-7f89628d3a85
md"""
MLJ will also allow you to insert *learned* target transformations. For example, we might want to apply `Standardizer()` to the target, to standardize it, or `UnivariateBoxCoxTransformer()` to make it look Gaussian. Then instead of specifying a *function* for `target`, we specify an unsupervised *model* (or model type). One does not specify `inverse` because only models implementing `inverse_transform` are allowed.

Let's see which of these two options results in a better outcome:
"""

# ╔═╡ 5230d4dc-878b-11eb-2f83-e160aa434041
begin
	box = UnivariateBoxCoxTransformer(n=20)
	stand = Standardizer()
end

# ╔═╡ 52178a98-878b-11eb-191d-a3617b11098c
begin
	pipe₄ = @pipeline encoder reducer rregr target=box
	mach₄ = machine(pipe₄, Xₕ, yₕ)
	evaluate!(mach₄, measure=mae);
end

# ╔═╡ 51ff4a0a-878b-11eb-1663-3175d3023d3d
begin
	pipe₄.target = stand
	evaluate!(mach₄, measure=mae);
end

# ╔═╡ c419e15e-878b-11eb-12ae-f321152db3b4
html"""
<p style="text-align: right;">
  <a id='resources'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ c18d4b80-878b-11eb-03df-57554a304eac
md"""
#### Resources for Part 3

- From the MLJ manual:
    - [Transformers and other unsupervised models](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/)
    - [Linear pipelines](https://alan-turing-institute.github.io/MLJ.jl/dev/composing_models/#Linear-pipelines-1)
- From Data Science Tutorials:
    - [Composing models](https://alan-turing-institute.github.io/DataScienceTutorials.jl/getting-started/composing-models/)
"""

# ╔═╡ 4ae60c30-8791-11eb-3547-051e3ec0269e
html"""
<p style="text-align: right;">
  <a id='exercises'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ c178cd36-878b-11eb-019a-ab7f9371e0f0
md"""
#### Exercises for Part 3

##### Exercise 1

Consider again the Horse Colic classification problem considered in Exercise 6, but with all features, `Finite` and `Infinite`:
"""

# ╔═╡ 117c134a-878c-11eb-0062-910219a6efb9
begin
  h_file = CSV.File(joinpath(DIR, "data", "horse.csv"));
  horse = DataFrames.DataFrame(h_file); # convert to data frame without copying columns
end


# ╔═╡ 22e61c98-878c-11eb-07f6-075b60e2979a
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

# ╔═╡ c15af1f6-878b-11eb-207b-ff38182ab074
begin
	y₁, X₁ = unpack(horse, ==(:outcome), name -> true);
	schema(X₁)
end

# ╔═╡ 51e39daa-878b-11eb-2ac7-ff55af65453d
md"""
(a) Define a pipeline that:
- uses `Standardizer` to ensure that features that are already
  continuous are centered at zero and have unit variance
- re-encodes the full set of features as `Continuous`, using
  `ContinuousEncoder`
- uses the `KMeans` clustering model from `Clustering.jl`
  to reduce the dimension of the feature space to `k=10`.
- trains a `EvoTreeClassifier` (a gradient tree boosting
  algorithm in `EvoTrees.jl`) on the reduced data, using
  `nrounds=50` and default values for the other
   hyper-parameters

(b) Evaluate the pipeline on all data, using 6-fold cross-validation
and `cross_entropy` loss.

(c) Plot a learning curve which examines the effect on this loss
as the tree booster parameter `max_depth` varies from 2 to 10.
"""

# ╔═╡ 69ab3d78-878e-11eb-3b38-bf4f92b0f82a
# Pkg.add("Clustering")
# Pkg.add("MLJClusteringInterface")

# ╔═╡ 98847588-878e-11eb-1394-75d948d73c5c
@load KMeans pkg=Clustering

# ╔═╡ ab66fdd8-878e-11eb-1187-d11889a8895b
@load EvoTreeClassifier

# ╔═╡ e39ff3da-878e-11eb-18c7-1babe2dfe6e1
# (a) part
pipe₁ = @pipeline(Standardizer,
	ContinuousEncoder,
	KMeans(k=10),
	EvoTrees.EvoTreeClassifier(nrounds=50))

# ╔═╡ 661d2bd2-878c-11eb-0565-d9d420533cfc
# (b) part
begin
	mach₁ = machine(pipe₁, X₁, y₁)
	evaluate!(mach₁, resampling=CV(nfolds=6), measure=cross_entropy)
end

# ╔═╡ 6606b832-878c-11eb-3830-a3d32f3b07bd
# (c) part
begin
	r₁ = range(pipe₁, :(evo_tree_classifier.max_depth), lower=1, upper=10)

	curve₁ = learning_curve(mach₁,
		range=r₁,
		resampling=CV(nfolds=6),
		measure=cross_entropy)
end

# ╔═╡ 65ee2404-878c-11eb-028b-2d6b037a55f4
plot(curve₁.parameter_values, curve₁.measurements,
	xlabel="max_depth",
	ylabel="CV estimate of cross entropy",
	legend=false)

# ╔═╡ 65d52fe4-878c-11eb-3ba8-3d7f2375c137
md"""
(*from solutions to exercises*) Here's a second curve using a different random seed for the booster:
"""

# ╔═╡ 65bbf126-878c-11eb-2d17-151e58fe91f1
begin
	pipe₁.evo_tree_classifier.rng = Random.MersenneTwister(123)
	
	curve₂ = learning_curve(mach₁, 
		range=r₁,
		resampling=CV(nfolds=6),
		measure=cross_entropy)

	plot!(curve₂.parameter_values, curve₂.measurements)
end

# ╔═╡ Cell order:
# ╟─b0de5b8e-8787-11eb-1a63-e94d308ecf79
# ╠═db039f9e-8787-11eb-3037-6566e5cd35e1
# ╟─dae6f0a6-8787-11eb-18be-5bee665ff211
# ╟─dacb2c5e-8787-11eb-0f18-03004883918e
# ╟─daadfbca-8787-11eb-1e8b-df76827065f3
# ╟─336759dc-8788-11eb-2f1f-47edaaa7eeb6
# ╟─3468ea44-8788-11eb-0043-c777b00c423c
# ╠═66ad95f4-8788-11eb-0d86-21ccf44a07ad
# ╠═6692ca9e-8788-11eb-0e22-23255f139aa5
# ╟─667ae6fe-8788-11eb-37e0-937840f15342
# ╠═665e3cac-8788-11eb-28ab-e1a34482956c
# ╟─662d8c94-8788-11eb-1cc2-ebadc5980bc4
# ╠═66140f1a-8788-11eb-1b90-138a63cdc086
# ╠═da835c8e-8788-11eb-3905-0b961fb28506
# ╟─da5ab4fa-8788-11eb-1aa3-c1a921e861c8
# ╠═da285618-8788-11eb-0635-8dcc0c9b5968
# ╟─fe5fd3bc-8788-11eb-095a-29f563116783
# ╠═fe3c4352-8788-11eb-02ab-a39f52eed4b8
# ╟─45ad2292-8789-11eb-1b70-e7df1c2198b4
# ╟─2688f3aa-8789-11eb-2ccc-57a834adb9d2
# ╠═fe1da1ce-8788-11eb-0235-47ac875ab7fb
# ╟─fe055a04-8788-11eb-2b38-2b23cbae597c
# ╟─fdeaedae-8788-11eb-3dab-f16f800d2b77
# ╟─da147a30-8788-11eb-01d0-ed61ac48ddee
# ╠═65fa258c-8788-11eb-00c6-9f0b8f477d5d
# ╟─013a548a-878a-11eb-160a-1da458bd2324
# ╠═01205ec2-878a-11eb-2fad-f9b213f4560f
# ╠═0103cd2a-878a-11eb-34df-8fb2e0261c30
# ╟─00ec055a-878a-11eb-3dac-1d0f6e10ea8c
# ╠═00d28b20-878a-11eb-108d-99e7981ae462
# ╟─266cd818-878a-11eb-34d6-c173735c9604
# ╠═2651f002-878a-11eb-2f30-71384dae63d3
# ╟─2637ca10-878a-11eb-07be-af6d5a769213
# ╠═67bde8de-878a-11eb-19d9-4176c3871746
# ╠═67a2c568-878a-11eb-2c52-1f3503de2742
# ╠═6788dc0e-878a-11eb-1552-0d7d020eaa2c
# ╟─77a77936-878a-11eb-255c-116e90f96738
# ╠═77885420-878a-11eb-08a8-43f03f192651
# ╟─abebfdde-878a-11eb-09ad-b1440c37497c
# ╟─775acdfc-878a-11eb-0007-5519985c1642
# ╠═6776361a-878a-11eb-3fca-b721f6de3c4b
# ╠═261a54a8-878a-11eb-0b82-a55b8f646bb2
# ╟─235d9a16-878a-11eb-219f-7750704b1e0b
# ╠═235c6dbc-878a-11eb-22b2-1f7f9f4fec5b
# ╟─fa99cd76-878a-11eb-00f5-170c7825df20
# ╠═fa8042de-878a-11eb-10db-35eb7404e05b
# ╠═fa613254-878a-11eb-0d6a-1f07472f012c
# ╟─fa4524ec-878a-11eb-2754-cd5ca0dcee5d
# ╟─fa29314c-878a-11eb-2fce-e95e75060931
# ╠═235c47bc-878a-11eb-3511-7b85a574207a
# ╟─5282e4a0-878b-11eb-36df-73cdf38aaa7e
# ╠═52629a88-878b-11eb-3cf0-77bc93decb35
# ╟─52499fb0-878b-11eb-191c-7f89628d3a85
# ╠═5230d4dc-878b-11eb-2f83-e160aa434041
# ╠═52178a98-878b-11eb-191d-a3617b11098c
# ╠═51ff4a0a-878b-11eb-1663-3175d3023d3d
# ╠═c419e15e-878b-11eb-12ae-f321152db3b4
# ╟─c18d4b80-878b-11eb-03df-57554a304eac
# ╟─4ae60c30-8791-11eb-3547-051e3ec0269e
# ╟─c178cd36-878b-11eb-019a-ab7f9371e0f0
# ╠═117c134a-878c-11eb-0062-910219a6efb9
# ╠═22e61c98-878c-11eb-07f6-075b60e2979a
# ╠═c15af1f6-878b-11eb-207b-ff38182ab074
# ╟─51e39daa-878b-11eb-2ac7-ff55af65453d
# ╠═69ab3d78-878e-11eb-3b38-bf4f92b0f82a
# ╠═922be298-878e-11eb-16a8-35f47ace05e1
# ╠═98847588-878e-11eb-1394-75d948d73c5c
# ╠═ab66fdd8-878e-11eb-1187-d11889a8895b
# ╠═e39ff3da-878e-11eb-18c7-1babe2dfe6e1
# ╠═661d2bd2-878c-11eb-0565-d9d420533cfc
# ╠═6606b832-878c-11eb-3830-a3d32f3b07bd
# ╠═65ee2404-878c-11eb-028b-2d6b037a55f4
# ╟─65d52fe4-878c-11eb-3ba8-3d7f2375c137
# ╠═303866da-8791-11eb-0872-b908cba30c10
# ╠═65bbf126-878c-11eb-2d17-151e58fe91f1
