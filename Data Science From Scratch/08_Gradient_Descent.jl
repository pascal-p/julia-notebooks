### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ e03dd22c-884c-11eb-2432-3dc04b0cf286
begin
  using Pkg; Pkg.activate("MLJ_env", shared=true)
  using Test
  using Plots
  using PlutoUI
  using Random
  using Distributions

  push!(LOAD_PATH, "./src")
  using YaLinearAlgebra
end

# ╔═╡ 380c26d0-881d-11eb-0461-f339488ea81e
md"""
## Gradient Descent

ref. from book **"Data Science from Scratch"**, Chap 8
"""

# ╔═╡ 83e01f80-884a-11eb-1ef7-e9cb5ab3ed20
html"""
<a id='toc'></a>
"""

# ╔═╡ 853ab02c-884a-11eb-01bf-1712dc177ffb
md"""
#### TOC
  - [Context](#context)
  - [Estimating the Gradient](#estimating-graident)
  - [Using the Gradient](#using-gradient)
  - [Choosing the right step](#right-step)
  - [Using Gradient Descent (GD) to fit models](#using-gd-fit-model)
  - [Mini-batch and Stochastic Gradient Descent](#mgd-sgd)
"""

# ╔═╡ 4c951444-8869-11eb-0b88-55a9fb9e51e6
html"""
<p style="text-align: right;">
  <a id='context'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 8c87c3b8-884a-11eb-10c8-73e2dab560ea
md"""
### Context
"""

# ╔═╡ 8c6ba818-884a-11eb-23e0-2f1c297d88f5
md"""
The gradient (vector of partial derivatives) gives the direction in which the function most quickly increase.

In ML we are looking at a best model (relative to some criteria) to fit the data. In this context "best" is obtained by minimizing a quantity (ex. minimize MSE between prediction and ground truth in a supervised setting) or maximizing a quantity (ex. likelihood of the data). This means that the problem is cast as an optimization problem. One technique to solve those optimization problems, which scale rather weel is **Gradient Descent** (or **Gradient Ascent**).

In a nutshell, Gradient Descent consists in picking a random starting point, computing the gradient (derivatives) of a given function w.r.t its parameters and take a small step in the opposite direction of the gradient (minimization setup, alternatively in the direction, for gradient ascent and a maximization setup) and repeat the process with this updated point until some convergence criteria.
"""

# ╔═╡ d2d18b22-884c-11eb-1f93-037453c5395b
begin
  f(x, y) = x^2 + y^2
  x = -10:10
  y = x
  plot(x, y, f, linetype=:surface)

  xₛ = 0:0.5:10
  yₛ = 0:-.45:-9
  zₛ = f.(xₛ, yₛ)
  scatter!(xₛ, yₛ, zₛ, marker=:v, markersize=4, color=:steelblue, legend=false)
end

# ╔═╡ 221734fe-8869-11eb-331a-b5810d0b784c
html"""
<p style="text-align: right;">
  <a id='estimating-gradient'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d297fa06-884c-11eb-294e-85992f901be1
md"""
### Estimating the gradient

If f is a function of one variable, its derivative at point x measures how f(x) changes as we make a very small change of x. The derivative is the limit of the difference of the quotients
"""

# ╔═╡ 1859c082-8853-11eb-18f6-2bc7a180b4a2
begin
  const AF =  AbstractFloat
  const VT = Vector{T} where T <: AbstractFloat
end

# ╔═╡ d27feefa-884c-11eb-3b84-1f529d7f6410
begin
  function diff_quotient(f::Function, x::AF, Δ::AF)::AF
    (f(x + Δ) - f(x)) / Δ
  end

  diff_quotient(f::Function, v::Vector{AF}, Δ::AF) = diff_quotient.(f, v, Δ)
end

# ╔═╡ 5618fb40-8853-11eb-3d2f-032437d22a09
md"""
The derivative is the slope of the tangent line at (x, f (x)) , while the difference quotient is the slope of the almost-tangent line that runs through (x + Δ, f (x + Δ)) . As Δ gets tends to 0,, the almost-tangent line gets closer and closer to the tangent line.
"""

# ╔═╡ 55fab426-8853-11eb-01f8-cbde45c7de9c
# TODO figure

# ╔═╡ 55e3efea-8853-11eb-0821-c5c580bc8fc5
md"""
For many function it is easy to compute the exact derivatives. For example for the square function we have:
"""

# ╔═╡ 55c56cc8-8853-11eb-04f4-3be84a352808
begin
  square(x::AF) = x * x
  square(v::Vector{AF}) = square.(v)

  deriv_square(x::AF) = 2. * x
  deriv_square(v::VT) = deriv_square.(v)
  end

# ╔═╡ d25d8eac-884c-11eb-2063-27413f8aba04
md"""
What if we cannot? Weel we can estimate the derivative by evaluating the difference quotient for very small Δ. For example:
"""

# ╔═╡ 480f7b18-8854-11eb-2898-8d876317ebe2
begin
  xᵣ = -10.:10.
  Δ = 1e-3

  yᵣ = square.(collect(xᵣ));
  dyᵣ = deriv_square.(xᵣ);
  dŷᵣ = diff_quotient.(square, xᵣ, Δ);
end

# ╔═╡ 47ee8cb4-8854-11eb-252b-852fd56aa40f
begin
  plot(xᵣ, yᵣ, label="Square", marker=:o, color=:green)
  scatter!(xᵣ, dyᵣ, label="Actual", marker=:o, color=:salmon)
  scatter!(xᵣ, dŷᵣ, label="Estimate", marker=:x, color=:darkslateblue,
    markersize=5, title="Actual derivatives vs Estimates")
end

# ╔═╡ 47d2c2cc-8854-11eb-35f9-952876481d02
md"""
When a function has sevral variables, it has multiple *partila derivatives* each indicating how f change when a small change is made in one of the input variable (while keeping the rest constant).
"""

# ╔═╡ f5980b54-8856-11eb-3e30-89c3f188ca8d
begin
  function ∂_diff_quotient(f::Function, v::VT, i::Integer, Δ::AF)::AF
    """
    Returns the i-th partial difference quotient of f at v
    """
    w = copy(v)
    w[i] += Δ
    (f.(w...) - f.(v...)) / Δ
  end

  ∂_diff_quotient(f::Function, v::Vector{AF}, Δ::AF)::AF =
    ∂_diff_quotient.(f, Tuple(v), 1:length(v), Δ)
end

# ╔═╡ f57b16b6-8856-11eb-3409-47f7b438f491
md"""
With this definition we can then estimate the gradient.
"""

# ╔═╡ f55dd09c-8856-11eb-1823-290fcb200662
function estimate_∇(f::Function, v::VT, Δ::AF)::VT
  [∂_diff_quotient(f, v, i, Δ) for i in 1:length(v)]
end

# ╔═╡ 33df0458-885c-11eb-2635-371a9590d833
begin
  fn(u::AF, v::AF) = u^2 + v

  ∂fnᵤ(u::AF, _v::AF) = 2. * u  # ∂fn w.r.t u
  ∂fnᵥ(_u::AF, v::AF) = 1       # ∂fn w.r.t v
end

# ╔═╡ e76a5b58-885c-11eb-0067-010ba1d4c9b5
begin
  Base.:≈(x::AF, y::AF; ϵ=1e-4) = abs(x - y) ≤ ϵ

  Base.:≈(u::Vector{T}, v::Vector{T}; ϵ=1e-4) where T <: AF = abs.(u - v) .≤ ϵ
end

# ╔═╡ e783d618-8858-11eb-0c0b-b57e54bd3757
begin
  Δ₁ = 1e-6
  vm = Float64[1., 2.]
  ix = 1
  @test ∂fnᵤ(vm...) ≈ ∂_diff_quotient(fn, vm, ix, Δ₁)
end

# ╔═╡ e767c1bc-8858-11eb-1b29-596a25a4fea4
html"""
<p style="text-align: right;">
  <a id='using-gradient'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ e747b052-8858-11eb-3c50-5355fef542c9
md"""
### Using the Gradient
"""

# ╔═╡ cc17413a-885d-11eb-1629-47fc5220529e
md"""
It is easy to see that the function `f` defines above is smallest when its input is a vector of zeros. But imagine let's say we do not know. In this case we can use  the gradients to find the minimum (this function is bivariate convexe) among all three-dimensional vectors.

We will start by picking a random starting point and then take tiny steps in the opposite direction of the gradient until we reach a point where the gradient is very small (which is guarantee to happen)
"""

# ╔═╡ cbfa193c-885d-11eb-3a48-97b26377b4fb
function ∇_step(v::VT, ∇::VT, η::AF)::VT
  @assert length(v) == length(∇)
  v + η * ∇
end

# ╔═╡ cbe180fe-885d-11eb-1307-7f3ac4897441
∇_sum_of_square(v::VT) = deriv_square(v)

# ╔═╡ d21bb0fe-884c-11eb-224f-216a811365a8
function gradient_descent(fn;range=1000, rng=MersenneTwister(42), η=1e-2)
  v = rand(rng, 3)
  for epoch ∈ 1:range
    ∇ = fn(v)
    v = ∇_step(v, ∇, -η) ## take a step in negative direction of the gradient
    epoch % 100 == 0 && println("$(epoch) => v: $(v)")
  end
  v
end

# ╔═╡ de2e6604-8863-11eb-3a27-8f8e8b55e5d8
with_terminal() do
  gradient_descent(∇_sum_of_square)
end

# ╔═╡ 3082d12e-8864-11eb-06bc-cdf9202cd20a
begin
  @test all(Base.:≈(gradient_descent(∇_sum_of_square), zeros(Float64, 3); ϵ=1.e-7))
  @test all(gradient_descent(∇_sum_of_square) ≈ zeros(Float64, 3))
end9.93698

-1.0823

# ╔═╡ 306b8d52-8864-11eb-1cbd-1341afcd52ff
html"""
<p style="text-align: right;">
  <a id='right-step'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 304ff894-8864-11eb-1449-b71da9112247
md"""
### Choosing the right step

It is clear why we choose to move in the opposite direction of the gradient while minimizing an (objective) function. Determining the right step however is something like an art and its value depends on the context.
  - Too large a step size and we are likely to overshoot and not converge to the optimum.
  - Too small a step and it will take ages to converge...

Not easy. There are mutliple options like fixed step size, gradual shrinking of the step size over time and other fancier options... To select the right step (or rnage of steps) one can try different options on a validation set...
"""

# ╔═╡ 8c4d28fc-884a-11eb-0de2-b58988dc7422
html"""
<p style="text-align: right;">
  <a id='using-gd-fit-model'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 8a07d906-8869-11eb-0bae-2582b352c05c
md"""
### Using Gradient Descent (GD) to fit models

In this collection of notebooks, we will be using gradient descent to fit parameterized models to data.

The usual case involves some dataset which we try to fit with a model (our hypothesis) that is characterized by some differentiable parameters. Also to measure the quality of our progress we will have a loss function.

Taking the data as being fixed, the loss function tells us how good (or bad) our model parameters are. We can use gradient descent to optimize this loss.

Let us try on a toy example.
"""

# ╔═╡ 89ebdac6-8869-11eb-25ac-2dac6a4b20aa
begin
  rng = MersenneTwister(42)
  data = [[x, 10x + 5. + 40. * randn(rng, 1)[1]] for x ∈ -50.:50.]
  # linear pattern with some (Normally distributed) noise
end

# ╔═╡ 89d1728a-8869-11eb-0001-875c2a452cf8
scatter(map(x -> x[1], data), map(y -> y[2], data), legend=false)

# ╔═╡ c0cc67c8-888b-11eb-272c-05a727c634ea
typeof(data)

# ╔═╡ 4bf3d986-886d-11eb-3ea8-7926f5babce0
function linear_∇(x::AF, y::AF, θ::VT)::VT
  slope, intercept = θ
  ŷ = slope * x + intercept   # prediction model
  Δerr = (ŷ - y)
  # squared_Δerr = Δerr^2
  [2. * Δerr * x, 2. * Δerr]
end

# ╔═╡ d8f972a0-8881-11eb-2be8-db89fb95a9f1
md"""
We are going to:
  1. Start with random initialisation of the parameters (θ)
  1. Compute the mean of the gradient
  1. Adjust θ
  1. Repeat
"""

# ╔═╡ 1b26337a-8882-11eb-2439-e106cdb884f5
function ∇_descent(inputs::Vector{Vector{T}};
    η=1e-5, nepochs=5_000) where T <: AF
  u = Uniform(-1., 1.)
  θ = [rand(u) for _ ∈ 1:2]

  for epoch ∈ 1:nepochs
    ∇ = μ([linear_∇(x, y, θ) for (x, y) ∈ inputs])
    θ = ∇_step(θ, ∇, -η)
    epoch % 100 == 0 && println("$(epoch) => θ: $(θ)")
  end

  (slope, intercept) = θ
end

# ╔═╡ 1b09cc9e-8882-11eb-0efc-630028d87217
begin
  slope, intercept = ∇_descent(data; nepochs=1_000)
  @test 9.90 ≤ slope ≤ 10.1
  @test abs(intercept) ≤ 1.0
end

# ╔═╡ 28b44b3c-88f8-11eb-23dd-bbfe325d70d3
md"""
Let's plot our result:
"""

# ╔═╡ 1c89f188-88f6-11eb-026c-e59bb08ac7ac
begin
  x_ = [-50.0, 50.0]
  y_ = slope .* x_ .+ intercept
  #
  scatter(map(x -> x[1], data), map(y -> y[2], data), legend=false)
  plot!(x_, y_, lw=3, color=:darkred)
end

# ╔═╡ 1ad358e4-8882-11eb-0559-bd43867dacfd
html"""
<p style="text-align: right;">
  <a id='mgd-sgd'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ d8d3bb0a-8881-11eb-35b2-8f486d6cc094
md"""
### Mini-batch and Stochastic Gradient Descent

In the preceding approach we evaluated the gradient on the whole dataset. This was fine because our dataset was small. In practice datasets can be big/large and this technique  becomes computationally expensive. This is why other techniques were devised, namely stochastic gradient descent and mini-batch gradient descent (a good trade-off between full gradient descent and stochastic gradient descent).


In mini-batch gradient descent, we compute the gradient and take a  gradient step based on a mini-batch sampled from the dataset:
"""

# ╔═╡ cd7c444a-8893-11eb-2409-f161ebc287b5
begin
	"""
	Generates batch-size sized min-batches from given dataset
	"""	
	
	struct MiniBatch{T <: Any}
		ds::Vector{Vector{T}}
		bsize::Integer  # batch-size

		function MiniBatch{T}(ds::Vector{Vector{T}}, bs::Integer) where T <: Any
			@assert 0 < bs ≤ length(ds)
			new(ds, bs)
    	end
  	end

  	Base.collect(iter::MiniBatch) = iter.ds

	function Base.iterate(iter::MiniBatch, 
			state=(view(iter.ds, 1:iter.bsize), iter.bsize + 1))
		batch, ix = state
		##
		isnothing(batch) && return nothing
		ix ≥ length(iter.ds) && return (batch, (nothing, ix))
		## otherwise
		jx = ix
		ix += iter.bsize
		ix = ix ≥ length(iter.ds) ? length(iter.ds) : ix
		(batch, (view(iter.ds, jx:ix - 1), ix))
	end

	Base.length(iter::MiniBatch) = length(iter.ds)
	Base.eltype(iter::MiniBatch) = eltype(iter.ds)
end

# ╔═╡ 714137c2-8900-11eb-3b4b-57abc5409bd2
let _ix = 0, bsz = 15
	for batch ∈ MiniBatch{Float64}(data, bsz)
		@assert length(batch) == bsz || 0 ≤ length(batch) ≤ bsz
		_ix += 1
	end
	@test _ix == 7
end

# ╔═╡ 7125e906-8900-11eb-3cd5-69755931c32d
let _ix = 0, bsz = 12
	for batch ∈ MiniBatch{Float64}(data, bsz)
		@assert length(batch) == bsz || 0 ≤ length(batch) ≤ bsz
		_ix += 1
	end
	@test _ix == 9
end

# ╔═╡ 401f3d8e-8904-11eb-1065-1de6c9bf32be
md"""
let's rewrite our gradient(∇) descent with min-batch:
"""

# ╔═╡ 70eef976-8900-11eb-3a03-af04f8dea9cc
function minibatch_∇_descent(inputs::Vector{Vector{T}};
    η=1e-5, nepochs=5_000, bsize=10) where T <: AF
  u = Uniform(-1., 1.)
  θ = [rand(u) for _ ∈ 1:2]

  for epoch ∈ 1:nepochs
		for batch ∈ MiniBatch{eltype(inputs[1][1])}(inputs, bsize)
			∇ = μ([linear_∇(x, y, θ) for (x, y) ∈ inputs])
    		θ = ∇_step(θ, ∇, -η)
		end
    epoch % 100 == 0 && println("$(epoch) => θ: $(θ)")
  end

  (slope, intercept) = θ
end

# ╔═╡ 70d67f74-8900-11eb-0174-f5c05571848e
begin
  slope₂, intercept₂ = minibatch_∇_descent(data; nepochs=100) ## only 100 epochs 
  @test 9.90 ≤ slope₂ ≤ 10.1
  @test abs(intercept₂) ≤ 1.0
end

# ╔═╡ 8d33a0f4-8906-11eb-3690-ddd49fc6cee1
begin
  # x_₂ = [-50.0, 50.0]
  y_₂ = slope .* x_ .+ intercept
  #
  scatter(map(x -> x[1], data), map(y -> y[2], data), legend=false)
  plot!(x_, y_₂, lw=3, color=:darkred)
end

# ╔═╡ 0a1acf66-8907-11eb-3eac-59a3e18d9c43
md"""
In this instance our mini-batch gradient descent worked pretty well, finding the optimal parameters in just 100 iteration (and actually less)... 

Basing gradient step on a small min-batch or just on one sampel (in the case of stochastic gradient descent) allows to take more steps, but the gradient can fluctuate a lot...
"""

# ╔═╡ Cell order:
# ╟─380c26d0-881d-11eb-0461-f339488ea81e
# ╠═e03dd22c-884c-11eb-2432-3dc04b0cf286
# ╟─83e01f80-884a-11eb-1ef7-e9cb5ab3ed20
# ╟─853ab02c-884a-11eb-01bf-1712dc177ffb
# ╟─4c951444-8869-11eb-0b88-55a9fb9e51e6
# ╟─8c87c3b8-884a-11eb-10c8-73e2dab560ea
# ╟─8c6ba818-884a-11eb-23e0-2f1c297d88f5
# ╠═d2d18b22-884c-11eb-1f93-037453c5395b
# ╟─221734fe-8869-11eb-331a-b5810d0b784c
# ╟─d297fa06-884c-11eb-294e-85992f901be1
# ╠═1859c082-8853-11eb-18f6-2bc7a180b4a2
# ╠═d27feefa-884c-11eb-3b84-1f529d7f6410
# ╟─5618fb40-8853-11eb-3d2f-032437d22a09
# ╠═55fab426-8853-11eb-01f8-cbde45c7de9c
# ╟─55e3efea-8853-11eb-0821-c5c580bc8fc5
# ╠═55c56cc8-8853-11eb-04f4-3be84a352808
# ╟─d25d8eac-884c-11eb-2063-27413f8aba04
# ╠═480f7b18-8854-11eb-2898-8d876317ebe2
# ╠═47ee8cb4-8854-11eb-252b-852fd56aa40f
# ╟─47d2c2cc-8854-11eb-35f9-952876481d02
# ╠═f5980b54-8856-11eb-3e30-89c3f188ca8d
# ╟─f57b16b6-8856-11eb-3409-47f7b438f491
# ╠═f55dd09c-8856-11eb-1823-290fcb200662
# ╠═33df0458-885c-11eb-2635-371a9590d833
# ╠═e76a5b58-885c-11eb-0067-010ba1d4c9b5
# ╠═e783d618-8858-11eb-0c0b-b57e54bd3757
# ╟─e767c1bc-8858-11eb-1b29-596a25a4fea4
# ╟─e747b052-8858-11eb-3c50-5355fef542c9
# ╟─cc17413a-885d-11eb-1629-47fc5220529e
# ╠═cbfa193c-885d-11eb-3a48-97b26377b4fb
# ╠═cbe180fe-885d-11eb-1307-7f3ac4897441
# ╠═d21bb0fe-884c-11eb-224f-216a811365a8
# ╠═de2e6604-8863-11eb-3a27-8f8e8b55e5d8
# ╠═3082d12e-8864-11eb-06bc-cdf9202cd20a
# ╟─306b8d52-8864-11eb-1cbd-1341afcd52ff
# ╟─304ff894-8864-11eb-1449-b71da9112247
# ╟─8c4d28fc-884a-11eb-0de2-b58988dc7422
# ╟─8a07d906-8869-11eb-0bae-2582b352c05c
# ╠═89ebdac6-8869-11eb-25ac-2dac6a4b20aa
# ╠═89d1728a-8869-11eb-0001-875c2a452cf8
# ╠═c0cc67c8-888b-11eb-272c-05a727c634ea
# ╠═4bf3d986-886d-11eb-3ea8-7926f5babce0
# ╟─d8f972a0-8881-11eb-2be8-db89fb95a9f1
# ╠═1b26337a-8882-11eb-2439-e106cdb884f5
# ╠═1b09cc9e-8882-11eb-0efc-630028d87217
# ╟─28b44b3c-88f8-11eb-23dd-bbfe325d70d3
# ╠═1c89f188-88f6-11eb-026c-e59bb08ac7ac
# ╟─1ad358e4-8882-11eb-0559-bd43867dacfd
# ╟─d8d3bb0a-8881-11eb-35b2-8f486d6cc094
# ╠═cd7c444a-8893-11eb-2409-f161ebc287b5
# ╠═714137c2-8900-11eb-3b4b-57abc5409bd2
# ╠═7125e906-8900-11eb-3cd5-69755931c32d
# ╟─401f3d8e-8904-11eb-1065-1de6c9bf32be
# ╠═70eef976-8900-11eb-3a03-af04f8dea9cc
# ╠═70d67f74-8900-11eb-0174-f5c05571848e
# ╠═8d33a0f4-8906-11eb-3690-ddd49fc6cee1
# ╟─0a1acf66-8907-11eb-3eac-59a3e18d9c43
