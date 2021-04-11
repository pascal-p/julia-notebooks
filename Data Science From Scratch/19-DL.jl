### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 06755ffe-8e78-11eb-0492-154107f31423
using Pkg; Pkg.activate("MLJ_env", shared=true)

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
	using Test
	using Random
	using Distributions
	using PlutoUI
	using Plots
end

# ╔═╡ 8c80e072-8b59-11eb-3c21-a18fe43c4536
md"""
## Deep Learning (DL)

ref. from book **"Data Science from Scratch"**, Chap 19

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ e7373726-8b59-11eb-2a2b-b5138e4f5268
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ f5ee64b2-8b59-11eb-2751-0778efd589cd
html"""
<style>
  main {
	max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
	background: wheat;
  }
</style>
"""

# ╔═╡ 164b4054-8b5a-11eb-03cc-9fc52eed5937
html"""
<hr />
"""

# ╔═╡ 31d3fa52-8b5d-11eb-017f-4308a2a06930
md"""
Julia implements natively multi-dimensional arrays (namely tensors in other languages/DL frameworks) which we are going to use here.
"""

# ╔═╡ d783876e-8b59-11eb-3ec1-39663403c77d
begin
  const Tensor = Union{BitArray, Array{T}} where {T <: Real}
  const F = Float64
end

# ╔═╡ 25828140-8b5a-11eb-375c-61061d409d46
function mean(t::Tensor; dims::Integer=0, keep_shape=false)
  """
  Compute mean of tensor up to order 3
  FIXME: how to generalize this?
  """
  @assert 0 ≤ dims ≤ length(size(t))
  p = size(t) |> length

  if dims == 0
    return sum(t)/*(size(t)...)

  elseif p == 2
    d, n = dims, size(t)[dims]
    xr, yc = size(t)
    sum.([view(t, ((d == 1 ? i : 1:xr),
            (d == 2 ? i : 1:yc))...) for i ∈ 1:n]) / n

  elseif dims ≤ length(size(t))
    d, n = dims, size(t)[dims]
    xr, yc, zd = size(t)
    sum.([view(t, ((d == 1 ? i : 1:xr),
            (d == 2 ? i : 1:yc), (d == 3 ? i : 1:zd))...) for i ∈ 1:n]) / n
    else
      throws(ArgumentError("Not Implemented"))
    end
end

# ╔═╡ 59828562-8b5a-11eb-32df-c5eb8302912f
begin
  m = [0.8705316232370359 0.809449166245158;
    0.401883439532462 0.3131013871278703;
    0.3040771908917186 0.007551710346251239]

  @test mean(m) ≈ 0.4510990862300826

  ## mean over rows
  @test mean(m; dims=1) ≈ [0.5599935964940647, 0.23832827555344407, 0.10387630041265661]

  ## mean over cols
  @test mean(m; dims=2) ≈ [0.7882461268306082, 0.5650511318596397]
end

# ╔═╡ a9572022-8b5b-11eb-371d-f13966c4d526
begin
  t = zeros(F, (3, 2, 4))
  t[:, :, 1] = [0.164626  0.0597695; 0.604697  0.286739; 0.836432  0.302445]
  t[:, :, 2] = [0.592242 0.505178; 0.923708 0.473227; 0.0661196 0.787647]
  t[:, :, 3] = [0.16899 0.163547; 0.297063 0.385749; 0.326159 0.345408]
  t[:, :, 4] = [0.0881336 0.266533; 0.54628 0.798231; 0.760609 0.464476];

  @test mean(t) ≈ 0.4255836958333334

  @test mean(t, dims=1) ≈ [0.6696730333333333, 1.438564666666667, 1.2964318666666665]
  @test mean(t, dims=2) ≈ [2.6875296, 2.4194747500000005]
  @test mean(t, dims=3) ≈ [0.563677125, 0.8370304, 0.421729, 0.7310656499999999]
end

# ╔═╡ b57b356a-8b5c-11eb-037e-9125388bd979
md"""
Let us implement a (meta-) function which apply a function to each element of a multi-array (aka tensor). In `Julia` this is easy as we just need to use broadcasting
"""

# ╔═╡ 1be547ba-8b5c-11eb-1ae4-cdaa28a20a2b
tensor_apply(fn::Function, t::Tensor) = fn.(t)

# ╔═╡ 20c0eabc-8b5e-11eb-32dd-cd738a6e8f68
double_fn = x -> eltype(x)(2) * x

# ╔═╡ 3c5a9d7c-8b5e-11eb-287f-91f80252e3ee
begin
  _rt = tensor_apply(double_fn, t)

  @test _rt[:, :, 1] ≈ [0.329252 0.119539; 1.209394 0.573478; 1.672864 0.60489]
  @test _rt[:, :, 2] ≈ [1.184484 1.010356; 1.847416 0.946454; 0.1322392 1.575294]
  @test _rt[:, :, 3] ≈ [0.33798 0.327094; 0.594126 0.771498; 0.652318 0.690816]
  @test _rt[:, :, 4] ≈ [0.1762672 0.533066; 1.09256 1.596462; 1.521218 0.928952]
end

# ╔═╡ ddc961a2-8b5e-11eb-06bb-d7335d0d6eaa
md"""
Which is equivalent to:
"""

# ╔═╡ ea2b2c5a-8b5e-11eb-12fb-33885f709e3a
begin
  @test _rt ≈ 2. * t   # ≡ scalar × tensor (implicit broadcast)
  @test _rt ≈ 2. .* t  # explicit broadcast
end

# ╔═╡ 65c8011c-8b5f-11eb-2d14-29cdd068bbf7
begin
  ## Addition of 2 tensors
  @test t + _rt ≈ 3. * t

  ## Difference of 2 tensors
  @test t - _rt ≈ -1. * t
  @test _rt - t ≈ t

  ## ...
end

# ╔═╡ ab6ef588-8b62-11eb-04fa-ab3051ddd7db
html"""
<hr />
"""

# ╔═╡ ab54224e-8b62-11eb-3f76-8506247531dc
md"""
### The Layer Abstraction

Our fundamental abstraction is the layer, which is something that knows how to apply some function over its input and how to backpropagate gradients.


*Layer Interface*:
  - forward(...)
  - backward(...)
  - params(...)
  - gradients(...)
"""

# ╔═╡ 97901c1a-8b79-11eb-397e-dda6619ddb03
begin
  abstract type AbstractLayer end

  ## FIXME: review
  forward(::AbstractLayer, ::Tensor) = throws(ArgumentError("Not Implemented"))
  backward(::AbstractLayer, ::Tensor) = throws(ArgumentError("Not Implemented"))
  parms(::AbstractLayer) = throws(ArgumentError("Not Implemented"))
  ∇parms(::AbstractLayer) = throws(ArgumentError("Not Implemented"));
end

# ╔═╡ 96ef5f36-8b63-11eb-3503-617be0c0415b
md"""
##### Initialization of a Layer

We will implement three different shemes for initializing our weigths parameters:
  - pick values from random uniform distribution
  - pick values from standerd normal distribution
  - *Xavier* initialisation

"""

# ╔═╡ 86ca6718-8b75-11eb-1d18-c16694e4482d
function init_rand_normal(shape::Tuple;
		seed=42, DT::DataType=Float64,
		kwargs...)
	Random.seed!(seed)
	nd = Normal(haskey(kwargs, :μ) ? kwargs[:μ] : 0., 
		haskey(kwargs, :σ) ? kwargs[:σ] : 1.)
	DT == Float64 ? rand(nd, shape) : DT[rand(nd, shape)...]
end

# ╔═╡ 43d5f21a-8b77-11eb-397e-dda6619ddb03
mₒ = init_rand_normal((3, 2); DT=Float32)

# ╔═╡ b2b89bc8-8b76-11eb-397e-dda6619ddb03
m₁ = init_rand_normal((3, 2); μ=10., σ=2.)

# ╔═╡ a66e2e68-8b63-11eb-0153-3bb8586dd8b2
function init_rand_uniform(shape::Tuple;
    seed=42, DT::DataType=Float64, _kwargs...)
  Random.seed!(seed)
  ud = Uniform(0., 1.)
  DT == Float64 ? rand(ud, shape) : DT[rand(ud, shape)...]
end

# ╔═╡ 3c685ea4-8b76-11eb-0c25-b917a390c8ba
m₂ = init_rand_uniform((3, 2))

# ╔═╡ a654fbbe-8b63-11eb-10a6-5f34a3164a8e
function init_xavier(shape::Tuple;
    seed=42, DT::DataType=Float64, _kwargs...)
  σ = length(shape) / sum(shape)
  init_rand_normal(shape; σ, seed, DT)
end

# ╔═╡ 2c779860-8b77-11eb-397e-dda6619ddb03
m₃ = init_xavier((3, 2); DT=Float32)

# ╔═╡ 6345dd34-8b77-11eb-397e-dda6619ddb03
const INIT_FNs = [init_rand_normal, init_rand_uniform, init_xavier]

# ╔═╡ 3276d728-8b75-11eb-3bcb-95a228498748
md"""
##### Activation functions

We will implement the follwoing activation funtions:
  - Sigmoid
  - Tanh
  - ReLU
"""

# ╔═╡ d2d26a08-8b83-11eb-3975-57c2a8e1fd58
struct Activation <: AbstractLayer
  name::Symbol
  fn::Function
  der_fn::Function
  #
  _type::Symbol
  store::Dict

  function Activation(name, fn, der_fn)
    new(name, fn, der_fn, :activation, Dict())
  end
end

# ╔═╡ 18a07872-8b84-11eb-3046-331119a0dc9b
begin
  function forward(self::Activation, input::Tensor)::Tensor
    self.store[self.name] = self.fn.(input)
    self.store[self.name]
  end

  function backward(self::Activation, ∇p::Tensor)::Tensor
    self.der_fn(self.store[self.name]) .* ∇p
  end

  parms(self::Activation) = []

  ∇parms(self::Activation) = []
end

# ╔═╡ 879291b6-8b7a-11eb-3340-337957fd81b7
md"""
###### Sigmoid function
"""

# ╔═╡ 325b5476-8b75-11eb-0867-739680374b56
Sigmoid = let
	σ = z -> 1. ./ (1. .+ exp.(-z))
    der_σ = z -> σ(z) .* (1 .- σ(z))
	Activation(:sigmoid, σ, der_σ)
end

# ╔═╡ 9337d830-8c17-11eb-397c-c56dc9ffeea4
begin
  @test Sigmoid.name == :sigmoid

  @test Sigmoid.fn(0.) ≈ 0.5
  @test Sigmoid.fn(1.) ≈ 0.73105857863
  @test Sigmoid.fn(5.) ≈ 0.9933071490757
  @test Sigmoid.fn([5. 1. 0.]) ≈ [0.9933071490757 0.73105857863 0.5]

  @test Sigmoid.der_fn(0.) ≈ 0.25
  @test Sigmoid.der_fn(1.) ≈ 0.1966119332414841
  @test Sigmoid.der_fn(5.) ≈ 0.0066480566708051
end

# ╔═╡ 323ad930-8b75-11eb-315c-5398adedfb78
Tanh = let
	tanₕ = z -> (x = exp.(z); y = exp.(-z); (x .- y) ./ (x .+ y))
	der_tanₕ = z -> 1 .- tanₕ.(z) .^ 2
	Activation(:tanh, tanₕ, der_tanₕ)
end

# ╔═╡ 2e1816d2-8c19-11eb-3046-331119a0dc9b
begin
  @test Tanh.name == :tanh

  @test Tanh.fn(0.) ≈ 0.
  @test Tanh.fn(1.) ≈ 0.7615941559557649
  @test Tanh.fn(1.) ≈ -Tanh.fn(-1.)
  @test Tanh.fn(5.) ≈ 0.999909204262595
  @test Tanh.fn(5.) ≈ -Tanh.fn(-5.)

  @test Tanh.der_fn(0.) ≈ 1.0
  @test Tanh.der_fn(1.) ≈ 0.41997434161402614
  @test Tanh.der_fn(5.) ≈ 0.00018158323094408235
end

# ╔═╡ 41080436-8b86-11eb-2d5c-bd298437f953
md"""
###### ReLU function
"""

# ╔═╡ 321c84bc-8b75-11eb-3869-5b3dfd0fcba7
ReLU = let
	relu_fn = z -> max(zero(eltype(z)), z)
	der_relu = z -> (z₀ =	zero(eltype(z)); z .< z₀ ? z₀ : one(eltype(z)))
 	Activation(:relu, relu_fn, der_relu)
end

# ╔═╡ 04a96d56-8c1a-11eb-1de6-fd84daec8930
begin
  @test ReLU.name == :relu

  @test ReLU.fn(0.) ≈ 0.
  @test ReLU.fn(1.) ≈ 1.
  @test ReLU.fn(-1.) ≈ 0.
  @test ReLU.fn.([-1. 1]) ≈ [0. 1.]

  @test ReLU.der_fn(0.1) ≈ 1.0
  @test ReLU.der_fn(1.) ≈ 1.0
  @test ReLU.der_fn(5.) ≈ 1.0
  @test ReLU.der_fn(-5.) ≈ 0.0
end

# ╔═╡ a6305b04-8b63-11eb-25ea-fd23665f9606
md"""
##### Linear (or Dense) Layer
"""

# ╔═╡ 0a8f0468-8b63-11eb-2e53-9fa288538f73
struct Linear <: AbstractLayer
  idim::Integer   ## input dim
  odim::Integer   ## output dim
  ## parameters
  w::Tensor
  b::Tensor
  #
  _type::Symbol
  store::Dict # {Any. Any}

  ## Assume type is DT == Float64
  function Linear(idim::Integer, odim::Integer;
      DT=Float64, init_fn=init_xavier, seed=42, kwargs...)
    ##
    @assert 1 ≤ idim
    @assert 1 ≤ odim
    @assert init_fn ∈ INIT_FNs
    ##
    w = init_fn((odim, idim); seed, DT, kwargs...)
    b = zeros(DT, (odim, 1))
    new(idim, odim, w, b, :dense, Dict())
  end
end

# ╔═╡ 6657fdee-8bb1-11eb-397c-c56dc9ffeea4
# gen_key(self::Linear, prefix::Symbol) = Symbol(prefix, self._id[1])

# ╔═╡ 86d2aac4-8b64-11eb-2ce3-554d89f33f35
function forward(self::Linear, input::Tensor)::Tensor
  self.store[:input] = input  ## Storing the input for backward pass
  self.w * input + self.b
end

# ╔═╡ 964d2ac2-8b72-11eb-28b5-ddc35ed07aa9
function backward(self::Linear, ∇p::Tensor)::Tensor
  ## as each bᵢ is added to output oᵢ, ∇b is the same as output ∇
  self.store[:∇b] = ∇p
  self.store[:∇w] = ∇p * self.store[:input]'
  r = sum.(self.w' * ∇p)
  @assert size(self.w) == size(self.store[:∇w]) "w and ∇w should have same shape: $(size(self.w)) == $(size(self.store[:∇w]))"
  @assert size(self.b) == size(self.store[:∇b]) "b and ∇b should have same shape: $(size(self.b)) == $(size(self.store[:∇b]))"
  r
end

# ╔═╡ a928209e-8b74-11eb-192c-8d53b41fb0a0
parms(self::Linear) = [self.w, self.b]

# ╔═╡ c03c06ce-8b74-11eb-3158-c758e41c696d
∇parms(self::Linear) = [self.store[:∇w], self.store[:∇b]]

# ╔═╡ c01aade4-8b74-11eb-0af8-73ad690afddb
html"""
<hr />
"""

# ╔═╡ c0024696-8b74-11eb-321f-0dd3d94a8d48
md"""
### Neural Network as a sequence of Layers

We can think of a neural network as a sequence of layers (Linear/Dense, Activation,...).
"""

# ╔═╡ bfe7710e-8b74-11eb-0cc5-4946d943c398
struct Sequential <: AbstractLayer
  layers::Vector{AbstractLayer}
  _type::Symbol

  function Sequential(layers::Vector{AbstractLayer})
    ## output of prev. layer == input of curr layer
    @assert length(layers) > 0
    pl = layers[1]
    for cl ∈ layers[2:end]
      cl._type == :activation && continue
      @assert pl.odim == cl.idim
      pl = cl
    end

    new(layers, :sequential)
  end
end

# ╔═╡ bfc98a2a-8b74-11eb-3458-153202bf0b91
function forward(self::Sequential, input::Tensor)::Tensor
  for (ix, l) ∈ enumerate(self.layers)
    input = forward(l, input)
  end
  input
end

# ╔═╡ bfb091d4-8b74-11eb-0850-ab7a2e10ff52
function backward(self::Sequential, ∇::Tensor)::Tensor
  for (ix, l) ∈ enumerate(reverse(self.layers))
    ∇ = backward(l, ∇)
  end
  ∇
end

# ╔═╡ bf95bfd0-8b74-11eb-115e-0fc0dd1bc84f
parms(self::Sequential) = [p for l ∈ self.layers for p ∈ parms(l)]

# ╔═╡ a9082e56-8b74-11eb-2359-d91cbb8c5e23
∇parms(self::Sequential) = [∇p for l ∈ self.layers for ∇p ∈ ∇parms(l)]

# ╔═╡ 5b0074ac-8b88-11eb-397a-4971fb64f900
md"""
And now we can define a simple network for calculating the XOR function.
"""

# ╔═╡ dc8498c0-8b81-11eb-397e-dda6619ddb03
begin
  xor_seed = 19999
  xor_init = init_rand_normal

  xor_net = Sequential([
      Linear(2, 2; seed=xor_seed, init_fn=xor_init, μ=1., σ=10.),
      Sigmoid,
      Linear(2, 1; seed=xor_seed, init_fn=xor_init, μ=1, σ=10.),
  ])
end

# ╔═╡ 7c12872a-8b88-11eb-1de6-fd84daec8930
html"""
<hr />
"""

# ╔═╡ 7bf6740e-8b88-11eb-34ee-4db60fb0db8a
md"""
#### Loss and Optimization

"""

# ╔═╡ be7ae9c0-8b8a-11eb-1de6-fd84daec8930
md"""
##### Loss
"""

# ╔═╡ 7bdcd058-8b88-11eb-3340-337957fd81b7
begin
  abstract type AbstractLoss end

  loss(::AbstractLoss, _ŷ::Tensor, _y::Tensor) =
    throws(ArgumentError("Not Implemented"))

  ∇loss(::AbstractLoss, _ŷ::Tensor, _y::Tensor) =
    throws(ArgumentError("Not Implemented"))
end

# ╔═╡ 7bbf92cc-8b88-11eb-3046-331119a0dc9b
md"""
###### Sum squared Error (SSE)
"""

# ╔═╡ 051a9e80-8b8a-11eb-34ee-4db60fb0db8a
begin
  struct SSE <: AbstractLoss
  end

  function loss(_self::SSE, ŷ::Tensor, y::Tensor)::F
    sum((ŷ .- y) .^ 2)
  end

  function ∇loss(_self::AbstractLoss, ŷ::Tensor, y::Tensor)::Tensor
    2 * (ŷ .- y)
  end
end

# ╔═╡ 04dcc506-8b8a-11eb-3046-331119a0dc9b
md"""
##### Optimization
"""

# ╔═╡ 04c3d762-8b8a-11eb-397a-4971fb64f900
begin
  abstract type AbstractOptimizer end

  astep(::AbstractOptimizer, _l::AbstractLayer) =
    throws(ArgumentError("Not Implemented"))
end

# ╔═╡ 247b100e-8b8b-11eb-2d5c-bd298437f953
md"""
###### (Vanilla) Gradient Descent (GD)
"""

# ╔═╡ 33ad413e-8b8b-11eb-170e-0f17904c9f2c
begin
  struct GD <: AbstractOptimizer
    η::F
  end

  function astep(self::GD, sl::AbstractLayer)
    ## sl ≡ seq. layer
    for (_parms, _∇parms) ∈ zip(parms(sl), ∇parms(sl))
      _parms[:] = _parms - self.η .* _∇parms
    end
  end
end

# ╔═╡ e19d82b4-8b8a-11eb-3c22-e788d025e8b4
md"""
###### GD with momentum
"""

# ╔═╡ 0c1df400-8b8c-11eb-1ed2-f78b522d0ae9
begin
	mutable struct MomentumGD <: AbstractOptimizer
		η::F  ## learning rate
		α::F  ## momentum rate
		updates::Vector{Tensor}
		#
		function MomentumGD(;η=0.1, α=0.9, updates=Vector{Tensor}[])
			new(η, α, updates)
		end
	end

	function astep(self::MomentumGD, sl::AbstractLayer)
		## sl ≡ seq. layer
		length(self.updates) == 0 &&
			(self.updates = [zeros(eltype(∇p), size(∇p)) for ∇p ∈ ∇parms(sl)])
		#
		for (_upd, _parms, _∇parms) ∈ zip(self.updates, parms(sl), ∇parms(sl))
			## apply momentum
			_upd[:] = self.α * _upd .+ (1. - self.α) * _∇parms
			## take step
			_parms[:] = _parms - self.η .* _upd
		end
	end
end

# ╔═╡ 21614b5a-8b8c-11eb-01e9-bd2517364992
html"""
<hr />
"""

# ╔═╡ 212a4800-8b8c-11eb-0b29-659a3be01512
md"""
#### XOR example

We will use xor_net as defined above. But first le us defien a generic training loop.
"""

# ╔═╡ 3e135428-8c39-11eb-0307-d932886e4b10
begin
	const AL = AbstractLayer
	const AA = AbstractArray
	const ALoss = AbstractLoss
	const AOpt = AbstractOptimizer
end

# ╔═╡ 2111ca94-8b8c-11eb-0307-d932886e4b10
begin
  ## Training data
  xs = [0. 0.; 0. 1.; 1. 0.; 1. 1.]
  ys = [0.; 1.; 1.; 0.]
end

# ╔═╡ 580afffa-8c3a-11eb-0b29-659a3be01512
function zipper(x::AA, y::AA)
  @assert size(x)[1] == size(y)[1]

  ([x[ix, :], y[ix, :]] for ix ∈ 1:size(x)[1]) ## returns a gen.
end

# ╔═╡ 254daee6-8db7-11eb-231c-f331a607203c
function xor_accuracy(net::AbstractLayer, xs, ys, ϵ=1e-9):: F
  ncorrect = 0
  for (x, y) ∈ zipper(xs, ys)
    ŷ = forward(net, x)
    @show ŷ, y, abs(ŷ[1] - y[1]) ≤ ϵ
     abs(ŷ[1] - y[1]) ≤ ϵ && (ncorrect += 1)
  end
  ncorrect / length(ys)
end

# ╔═╡ 61904ed8-8b96-11eb-3046-331119a0dc9b
size(xs[1, :]), size(reshape(xs[1, :], 2, :)), size(ys[1, :]), size(reshape(ys[1, :], 1, 1))

# ╔═╡ ac9fbad6-8c3a-11eb-231c-f331a607203c
with_terminal() do
  for (x, y) in zip(xs, ys)
    println(x, " / ", y)
  end
end

# ╔═╡ 9577b10a-8db9-11eb-3046-331119a0dc9b
with_terminal() do
  for (x, y) in zipper(xs, ys)
    println(x, " / ", y)
  end
end

# ╔═╡ 276897b0-8c27-11eb-3046-331119a0dc9b
with_terminal() do
	for p in parms(xor_net); println(p); end
end

# ╔═╡ 8880560a-8db7-11eb-01e9-bd2517364992
xor_accuracy(xor_net, xs, ys)

# ╔═╡ 593338dc-8c3f-11eb-3978-75a4a2df9116
html"""
<hr />
"""

# ╔═╡ 319822fc-8c2a-11eb-397a-4971fb64f900
md"""
#### FizzBuzz example
"""

# ╔═╡ 9ef5592a-8c37-11eb-3046-331119a0dc9b
md"""
First some helper functions
"""

# ╔═╡ 47eaec34-8c45-11eb-3046-331119a0dc9b
function binary_encoder(x::Integer; n::Integer=10)::BitArray
  vbin::BitArray = fill(false, n)
  for ix ∈ 1:n
    vbin[ix] = x % 2
    x ÷= 2
  end
  vbin
end

# ╔═╡ 4baf8304-8c45-11eb-3340-337957fd81b7
begin
  @test binary_encoder(0) == [0, 0, 0, 0, 0, 0, 0, 0,  0,  0]
  @test binary_encoder(1)  == [1, 0, 0, 0, 0, 0, 0, 0,  0,  0]
  @test binary_encoder(10)  == [0, 1, 0, 1, 0, 0, 0, 0,  0,  0]
  @test binary_encoder(101) == [1, 0, 1, 0, 0, 1, 1, 0,  0,  0]
  @test binary_encoder(999) == [1, 1, 1, 0, 0, 1, 1, 1,  1,  1]
end

# ╔═╡ 5c2d2b14-8c45-11eb-2d5c-bd298437f953
function fizzbuzz_encoder(x::Integer)::BitArray
    if x % 15 == 0
        [0, 0, 0, 1]
    elseif x % 5 == 0
        [0, 0, 1, 0]
    elseif x % 3 == 0
        [0, 1, 0, 0]
    else
        [1, 0, 0, 0]
  end
end

# ╔═╡ 5c168c88-8c45-11eb-3c22-e788d025e8b4
begin
  @test fizzbuzz_encoder(2) == [1, 0, 0, 0]
  @test fizzbuzz_encoder(6) == [0, 1, 0, 0]
  @test fizzbuzz_encoder(10) == [0, 0, 1, 0]
  @test fizzbuzz_encoder(30) == [0, 0, 0, 1]
end

# ╔═╡ 5bfa74da-8c45-11eb-1de6-fd84daec8930
md"""
Second, let us define the accuracy. We will use thsi during the training of our fizzbuzz model.
"""

# ╔═╡ 5bdf8ee8-8c45-11eb-34ee-4db60fb0db8a
function fb_accuracy(net::AbstractLayer, low::Integer, high::Integer):: F
	ncorrect = 0
	for n ∈ low:high
		x = binary_encoder(n)
		r₁ = forward(net, x)
		r₂ = fizzbuzz_encoder(n)
		## NOTE: argmax(r₁) => CartesianIndex
		ŷ, y = argmax(r₁)[1], argmax(r₂)
		ŷ == y && (ncorrect += 1)
	end
	ncorrect / (high - low)
end

# ╔═╡ aa26a570-8c45-11eb-170e-0f17904c9f2c
md"""
Third, let us prepare some taining data (using our helper functions).
"""

# ╔═╡ b324dd40-8c45-11eb-231c-f331a607203c
begin
	## Training data
	rₛ = 101:1023
	xₛ = binary_encoder.(collect(rₛ))
	yₛ = fizzbuzz_encoder.(collect(rₛ))
	(xₛ, yₛ)
end

# ╔═╡ b3092534-8c45-11eb-0b29-659a3be01512
md"""
Fourth, let us define our model and optimizer.
"""

# ╔═╡ b2ecba78-8c45-11eb-0307-d932886e4b10
begin
  const Num_Hidden = 25
  #
  # random seed
  #
  fb_net = Sequential([
     Linear(10, Num_Hidden; init_fn=init_rand_uniform),
     Tanh,
     Linear(Num_Hidden, 4; init_fn=init_rand_uniform),
     Sigmoid
  ])
  #
  fb_opt = MomentumGD(;η=.1, α=.9)
  fb_loss = SSE()
end

# ╔═╡ b2d39ee4-8c45-11eb-1ed2-f78b522d0ae9
md"""
Fifth, let us define our training loop.
"""

# ╔═╡ 3e34451e-8c51-11eb-3978-75a4a2df9116
html"""
<hr />
"""

# ╔═╡ 48ba66fa-8c51-11eb-34ee-4db60fb0db8a
md"""
#### Softmax and Cross-Entropy Loss

The softmax function converts a vector of real numbers into a vector of probabilities.
"""

# ╔═╡ 489fe8d2-8c51-11eb-3340-337957fd81b7
function softmax(tensor::Tensor)::Tensor
	"""Softmax along ths last dimension"""
	## for numerical stability - subtract largest value
	exps = exp.(tensor .- maximum(tensor))
	sum_exps = sum(exps)
	exps ./ sum_exps
end

# ╔═╡ 4882bcee-8c51-11eb-3046-331119a0dc9b
begin
	@test softmax([1. 3. 2.]) ≈ [0.09003057 0.66524096 0.24472847]
	@test softmax([0. 1. 0.]) ≈ [0.21194155761708 0.5761168847658 0.21194155761708]
	@test softmax([8. 5. 0. 0.]) ≈ [0.9519657197813 0.04739558237461 0.0003193489220309 0.0003193489220309]
end

# ╔═╡ bd860472-8c53-11eb-0307-d932886e4b10
begin
	struct SoftmaxXEntropy <: AbstractLoss; end

	function loss(_self::SoftmaxXEntropy, ŷ::Tensor, y::Tensor; ϵ=1e-20)::F
		probs = softmax(ŷ)
		-sum(log.(probs .+ ϵ) .* y)
	end

	function ∇loss(_self::SoftmaxXEntropy, ŷ::Tensor, y::Tensor)::Tensor
		softmax(ŷ) .- y
	end
end

# ╔═╡ 6474f75a-8c38-11eb-1ed2-f78b522d0ae9
function train_loop(model::AL, xs::AA, ys::AA, loss_fn::ALoss, opt_fn::AOpt;
    epochs=3000, zip_fn=zip, acc_fn=nothing, verbose=false)
	#
	rec_loss = []
	for epoch ∈ 1:epochs
		epoch_loss = 0.
		for (x, y) ∈ zip_fn(xs, ys)
			ŷ = forward(model, x)
			epoch_loss += loss(loss_fn, ŷ, y)
			∇p = ∇loss(loss_fn, ŷ, y)
			backward(model, ∇p)
            astep(opt_fn, model)
		end
		if !isnothing(acc_fn)
			acc = acc_fn(model, 101, 1024)
			epoch % 100 == 0 && (@show epoch, epoch_loss, acc)
		else
			verbose && epoch % 100 == 0 && (@show epoch, epoch_loss)
		end
		push!(rec_loss, epoch_loss)
	end
	rec_loss
end

# ╔═╡ 7d69f7f8-8b8c-11eb-1de6-fd84daec8930
begin
	rec_loss = nothing
	xor_epochs = 1_000 # 3_000
	with_terminal() do
		xor_loss = SSE()
		xor_opt = GD(0.1)
		global rec_loss = train_loop(xor_net, xs, ys, xor_loss, xor_opt;
			epochs=xor_epochs, verbose=true, zip_fn=zipper)
	end
end

# ╔═╡ 70569cb6-8c44-11eb-397a-4971fb64f900
plot(1:xor_epochs, rec_loss, title="XOR training loss", legend=false)

# ╔═╡ ce39053e-8c45-11eb-01e9-bd2517364992
begin
	fb_rec_loss = nothing
	n_epo = 500

	with_terminal() do
		global fb_rec_loss = train_loop(fb_net, xₛ, yₛ, fb_loss, fb_opt;
			verbose=true, epochs=n_epo, acc_fn=fb_accuracy)
	end
end

# ╔═╡ 8090be8e-8c49-11eb-3978-75a4a2df9116
plot(1:n_epo, fb_rec_loss, title="FizzBuzz training loss", legend=false)

# ╔═╡ b0a16012-8c49-11eb-3046-331119a0dc9b
("Results (after training for $(n_epo) epochs): ", fb_accuracy(fb_net, 1, 101))

# ╔═╡ bd69d86a-8c53-11eb-1ed2-f78b522d0ae9
md"""
Now let us redo FizzBuzz, using our `SoftmaxXEntropy`.
"""

# ╔═╡ a3a76e8a-8c56-11eb-3046-331119a0dc9b
begin
	fb_netₓ = Sequential([
		Linear(10, Num_Hidden; init_fn=init_rand_uniform),
		Tanh,
		Linear(Num_Hidden, 4; init_fn=init_rand_uniform),
		# No final Sigmoid
	])
	fb_lossₓ = SoftmaxXEntropy()
	fb_optₓ = MomentumGD(;η=.05, α=.95)
end

# ╔═╡ bd4dc13e-8c53-11eb-170e-0f17904c9f2c
begin
	fb_rec_lossₓ = nothing
	n_epoₓ = 500

	with_terminal() do
		global fb_rec_lossₓ = train_loop(fb_netₓ, xₛ, yₛ, fb_lossₓ, fb_optₓ;
			verbose=true, epochs=n_epoₓ, acc_fn=fb_accuracy)
	end
end

# ╔═╡ e723003c-8c58-11eb-3046-331119a0dc9b
plot(1:n_epoₓ, fb_rec_lossₓ, title="FizzBuzz training loss (Xentropy)", legend=false)

# ╔═╡ 49b61c8e-8c56-11eb-3978-75a4a2df9116
("Results (after training for $(n_epoₓ) epochs): ", fb_accuracy(fb_netₓ, 1, 101))

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═06755ffe-8e78-11eb-0492-154107f31423
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╟─f5ee64b2-8b59-11eb-2751-0778efd589cd
# ╟─164b4054-8b5a-11eb-03cc-9fc52eed5937
# ╟─31d3fa52-8b5d-11eb-017f-4308a2a06930
# ╠═d783876e-8b59-11eb-3ec1-39663403c77d
# ╠═25828140-8b5a-11eb-375c-61061d409d46
# ╠═59828562-8b5a-11eb-32df-c5eb8302912f
# ╠═a9572022-8b5b-11eb-371d-f13966c4d526
# ╟─b57b356a-8b5c-11eb-037e-9125388bd979
# ╠═1be547ba-8b5c-11eb-1ae4-cdaa28a20a2b
# ╠═20c0eabc-8b5e-11eb-32dd-cd738a6e8f68
# ╠═3c5a9d7c-8b5e-11eb-287f-91f80252e3ee
# ╟─ddc961a2-8b5e-11eb-06bb-d7335d0d6eaa
# ╠═ea2b2c5a-8b5e-11eb-12fb-33885f709e3a
# ╠═65c8011c-8b5f-11eb-2d14-29cdd068bbf7
# ╟─ab6ef588-8b62-11eb-04fa-ab3051ddd7db
# ╟─ab54224e-8b62-11eb-3f76-8506247531dc
# ╠═97901c1a-8b79-11eb-397e-dda6619ddb03
# ╟─96ef5f36-8b63-11eb-3503-617be0c0415b
# ╠═86ca6718-8b75-11eb-1d18-c16694e4482d
# ╠═43d5f21a-8b77-11eb-397e-dda6619ddb03
# ╠═b2b89bc8-8b76-11eb-397e-dda6619ddb03
# ╠═a66e2e68-8b63-11eb-0153-3bb8586dd8b2
# ╠═3c685ea4-8b76-11eb-0c25-b917a390c8ba
# ╠═a654fbbe-8b63-11eb-10a6-5f34a3164a8e
# ╠═2c779860-8b77-11eb-397e-dda6619ddb03
# ╠═6345dd34-8b77-11eb-397e-dda6619ddb03
# ╟─3276d728-8b75-11eb-3bcb-95a228498748
# ╠═d2d26a08-8b83-11eb-3975-57c2a8e1fd58
# ╠═18a07872-8b84-11eb-3046-331119a0dc9b
# ╟─879291b6-8b7a-11eb-3340-337957fd81b7
# ╠═325b5476-8b75-11eb-0867-739680374b56
# ╠═9337d830-8c17-11eb-397c-c56dc9ffeea4
# ╠═323ad930-8b75-11eb-315c-5398adedfb78
# ╠═2e1816d2-8c19-11eb-3046-331119a0dc9b
# ╟─41080436-8b86-11eb-2d5c-bd298437f953
# ╠═321c84bc-8b75-11eb-3869-5b3dfd0fcba7
# ╠═04a96d56-8c1a-11eb-1de6-fd84daec8930
# ╟─a6305b04-8b63-11eb-25ea-fd23665f9606
# ╠═0a8f0468-8b63-11eb-2e53-9fa288538f73
# ╠═6657fdee-8bb1-11eb-397c-c56dc9ffeea4
# ╠═86d2aac4-8b64-11eb-2ce3-554d89f33f35
# ╠═964d2ac2-8b72-11eb-28b5-ddc35ed07aa9
# ╠═a928209e-8b74-11eb-192c-8d53b41fb0a0
# ╠═c03c06ce-8b74-11eb-3158-c758e41c696d
# ╟─c01aade4-8b74-11eb-0af8-73ad690afddb
# ╟─c0024696-8b74-11eb-321f-0dd3d94a8d48
# ╠═bfe7710e-8b74-11eb-0cc5-4946d943c398
# ╠═bfc98a2a-8b74-11eb-3458-153202bf0b91
# ╠═bfb091d4-8b74-11eb-0850-ab7a2e10ff52
# ╠═bf95bfd0-8b74-11eb-115e-0fc0dd1bc84f
# ╠═a9082e56-8b74-11eb-2359-d91cbb8c5e23
# ╟─5b0074ac-8b88-11eb-397a-4971fb64f900
# ╠═dc8498c0-8b81-11eb-397e-dda6619ddb03
# ╟─7c12872a-8b88-11eb-1de6-fd84daec8930
# ╟─7bf6740e-8b88-11eb-34ee-4db60fb0db8a
# ╟─be7ae9c0-8b8a-11eb-1de6-fd84daec8930
# ╠═7bdcd058-8b88-11eb-3340-337957fd81b7
# ╟─7bbf92cc-8b88-11eb-3046-331119a0dc9b
# ╠═051a9e80-8b8a-11eb-34ee-4db60fb0db8a
# ╟─04dcc506-8b8a-11eb-3046-331119a0dc9b
# ╠═04c3d762-8b8a-11eb-397a-4971fb64f900
# ╟─247b100e-8b8b-11eb-2d5c-bd298437f953
# ╠═33ad413e-8b8b-11eb-170e-0f17904c9f2c
# ╟─e19d82b4-8b8a-11eb-3c22-e788d025e8b4
# ╠═0c1df400-8b8c-11eb-1ed2-f78b522d0ae9
# ╟─21614b5a-8b8c-11eb-01e9-bd2517364992
# ╟─212a4800-8b8c-11eb-0b29-659a3be01512
# ╠═3e135428-8c39-11eb-0307-d932886e4b10
# ╠═2111ca94-8b8c-11eb-0307-d932886e4b10
# ╠═580afffa-8c3a-11eb-0b29-659a3be01512
# ╠═6474f75a-8c38-11eb-1ed2-f78b522d0ae9
# ╠═254daee6-8db7-11eb-231c-f331a607203c
# ╠═61904ed8-8b96-11eb-3046-331119a0dc9b
# ╠═ac9fbad6-8c3a-11eb-231c-f331a607203c
# ╠═9577b10a-8db9-11eb-3046-331119a0dc9b
# ╠═7d69f7f8-8b8c-11eb-1de6-fd84daec8930
# ╠═276897b0-8c27-11eb-3046-331119a0dc9b
# ╠═8880560a-8db7-11eb-01e9-bd2517364992
# ╠═70569cb6-8c44-11eb-397a-4971fb64f900
# ╟─593338dc-8c3f-11eb-3978-75a4a2df9116
# ╟─319822fc-8c2a-11eb-397a-4971fb64f900
# ╟─9ef5592a-8c37-11eb-3046-331119a0dc9b
# ╠═47eaec34-8c45-11eb-3046-331119a0dc9b
# ╠═4baf8304-8c45-11eb-3340-337957fd81b7
# ╠═5c2d2b14-8c45-11eb-2d5c-bd298437f953
# ╠═5c168c88-8c45-11eb-3c22-e788d025e8b4
# ╟─5bfa74da-8c45-11eb-1de6-fd84daec8930
# ╠═5bdf8ee8-8c45-11eb-34ee-4db60fb0db8a
# ╟─aa26a570-8c45-11eb-170e-0f17904c9f2c
# ╠═b324dd40-8c45-11eb-231c-f331a607203c
# ╟─b3092534-8c45-11eb-0b29-659a3be01512
# ╠═b2ecba78-8c45-11eb-0307-d932886e4b10
# ╟─b2d39ee4-8c45-11eb-1ed2-f78b522d0ae9
# ╠═ce39053e-8c45-11eb-01e9-bd2517364992
# ╠═8090be8e-8c49-11eb-3978-75a4a2df9116
# ╠═b0a16012-8c49-11eb-3046-331119a0dc9b
# ╟─3e34451e-8c51-11eb-3978-75a4a2df9116
# ╟─48ba66fa-8c51-11eb-34ee-4db60fb0db8a
# ╠═489fe8d2-8c51-11eb-3340-337957fd81b7
# ╠═4882bcee-8c51-11eb-3046-331119a0dc9b
# ╠═bd860472-8c53-11eb-0307-d932886e4b10
# ╟─bd69d86a-8c53-11eb-1ed2-f78b522d0ae9
# ╠═a3a76e8a-8c56-11eb-3046-331119a0dc9b
# ╠═bd4dc13e-8c53-11eb-170e-0f17904c9f2c
# ╠═e723003c-8c58-11eb-3046-331119a0dc9b
# ╠═49b61c8e-8c56-11eb-3978-75a4a2df9116
