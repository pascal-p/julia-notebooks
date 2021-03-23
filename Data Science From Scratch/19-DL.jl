### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
  using Test
  using Random
  using Distributions
  using PlutoUI
end

# ╔═╡ 8c80e072-8b59-11eb-3c21-a18fe43c4536
md"""
## Deep Learning (DL)

ref. from book **"Data Science from Scratch"**, Chap 19
"""

# ╔═╡ e7373726-8b59-11eb-2a2b-b5138e4f5268
html"""
<a id='toc'></a>
"""

# ╔═╡ f5ee64b2-8b59-11eb-2751-0778efd589cd
md"""
#### TOC
  - [Tensors](#tensor)
  - [The Layer Abstraction](#abstraction-layer)
  - [Neural Network as a sequence of layers](#nn-a-seq-of-layers)
  - [Loss and Optimization](#loss-n-optimization)
  - [...](#...)
"""

# ╔═╡ 164b4054-8b5a-11eb-03cc-9fc52eed5937
html"""
<p style="text-align: right;">
  <a id='tensor'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 31d3fa52-8b5d-11eb-017f-4308a2a06930
md"""
Julia implements natively multi-dimensional arrays (namely tensors in other languages/DL frameworks) which we are going to use here.
"""

# ╔═╡ d783876e-8b59-11eb-3ec1-39663403c77d
begin
  const Tensor = Array{T} where {T <: Real}
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
<p style="text-align: right;">
  <a id='abstraction-layer'></a>
  <a href="#toc">back to TOC</a>
</p>
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

  ∇(::AbstractLayer) = throws(ArgumentError("Not Implemented"))
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
    μ=0., σ=1., seed=42, DT::DataType=Float64)
  Random.seed!(seed)
  nd = Normal(μ, σ)
  DT == Float64 ? rand(nd, shape) : DT[rand(nd, shape)...]
end

# ╔═╡ 43d5f21a-8b77-11eb-397e-dda6619ddb03
mₒ = init_rand_normal((3, 2); DT=Float32)

# ╔═╡ b2b89bc8-8b76-11eb-397e-dda6619ddb03
m₁ = init_rand_normal((3, 2); μ=10., σ=2.)

# ╔═╡ a66e2e68-8b63-11eb-0153-3bb8586dd8b2
function init_rand_uniform(shape::Tuple;
    seed=42, DT::DataType=Float64)
  Random.seed!(seed)
  ud = Uniform(0., 1.)
  DT == Float64 ? rand(ud, shape) : DT[rand(ud, shape)...]
end

# ╔═╡ 3c685ea4-8b76-11eb-0c25-b917a390c8ba
m₂ = init_rand_uniform((3, 2))

# ╔═╡ a654fbbe-8b63-11eb-10a6-5f34a3164a8e
function init_xavier(shape::Tuple;
    seed=42, DT::DataType=Float64)
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
  - sigmoid
  - tanh
  - relu
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
		# println(" σ FOR>>>>> size(σ): $(size(self.store[self.name])) / size(input): $(size(input))")
		self.store[self.name]
	end

	function backward(self::Activation, ∇::Tensor)::Tensor
		r = self.der_fn(self.store[self.name]) .* ∇
		# println(" σ BACK>>>> size(∇): $(size(∇)) / size(res): $(size(r))")
		r
	end

	parms(self::Activation) = []

	∇(self::Activation) = []
end

# ╔═╡ 23b693ca-8c21-11eb-3340-337957fd81b7


# ╔═╡ e9a11fde-8c20-11eb-3046-331119a0dc9b


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
      DT=Float64, init_fn=init_xavier, seed=42)
    ##
    ## would also need μ and σ as kwargs for normal init.
    @assert 1 ≤ idim
    @assert 1 ≤ odim
    @assert init_fn ∈ INIT_FNs
    ##
    w = init_fn((odim, idim); seed, DT)
    b = zeros(DT, (odim, 1))
    new(idim, odim, w, b, :dense, Dict())
  end
end

# ╔═╡ 6657fdee-8bb1-11eb-397c-c56dc9ffeea4
# gen_key(self::Linear, prefix::Symbol) = Symbol(prefix, self._id[1])

# ╔═╡ 86d2aac4-8b64-11eb-2ce3-554d89f33f35
function forward(self::Linear, input::Tensor)::Tensor
	self.store[:input] = input  ## Storing the input for backward pass
	r = self.w * input + self.b
	# println("FOR[$(self._type) / $(objectid(self))] - stored size(input): $(size(input)) / computed res: $(r) with shape: $(size(r)) / parms(w) $(size(self.w)) => value: $(self.w)")
	r
end

# ╔═╡ 964d2ac2-8b72-11eb-28b5-ddc35ed07aa9
function backward(self::Linear, ∇::Tensor)::Tensor
	## as each bᵢ is added to output oᵢ, ∇b is the same as output ∇
	# println("=== >>> shape(∇): $(size(∇)) / shape(input): $(size(self.store[:input]))")
	self.store[:∇b] = ∇
	self.store[:∇w] = ∇ * self.store[:input]' # self.store[:input] * ∇'
	r = sum.(self.w' * ∇)
	# println("BAC[$(self._type) / $(objectid(self))] - stored size(∇b): $(size(∇)) /  stored size(∇w): $(size(self.store[:∇w])) / computed res: $(r) with shape: $(size(r))")
	
	@assert size(self.w) == size(self.store[:∇w]) "w and ∇w should have same shape: $(size(self.w)) == $(size(self.store[:∇w]))"
	@assert size(self.b) == size(self.store[:∇b]) "b and ∇b should have same shape: $(size(self.b)) == $(size(self.store[:∇b]))"
	
	r
end

# ╔═╡ a928209e-8b74-11eb-192c-8d53b41fb0a0
parms(self::Linear) = [self.w, self.b]

# ╔═╡ c03c06ce-8b74-11eb-3158-c758e41c696d
∇(self::Linear) = [self.store[:∇w], self.store[:∇b]]

# ╔═╡ c01aade4-8b74-11eb-0af8-73ad690afddb
html"""
<p style="text-align: right;">
  <a id='nn-a-seq-of-layers'></a>
  <a href="#toc">back to TOC</a>
</p>
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
		
		new(layers, :sequentiaL)
	end
end

# ╔═╡ bfc98a2a-8b74-11eb-3458-153202bf0b91
function forward(self::Sequential, input::Tensor)::Tensor
	for (ix, l) ∈ enumerate(self.layers)
		# print(" $(ix)  "); @show "FORWARD ", l._type, size(input), input	
		input = forward(l, input)
  	end
  	input
end

# ╔═╡ bfb091d4-8b74-11eb-0850-ab7a2e10ff52
function backward(self::Sequential, ∇::Tensor)::Tensor
	for (ix, l) ∈ enumerate(reverse(self.layers))
		# print(" $(4 - ix)  "); @show "BACWARD / REV ", l._type, size(∇), ∇
		∇ = backward(l, ∇)
	end
	∇
end

# ╔═╡ bf95bfd0-8b74-11eb-115e-0fc0dd1bc84f
parms(self::Sequential) = [p for l ∈ self.layers for p ∈ parms(l)]

# ╔═╡ a9082e56-8b74-11eb-2359-d91cbb8c5e23
∇(self::Sequential) = [∇p for l ∈ self.layers for ∇p ∈ ∇(l)]

# ╔═╡ 5b0074ac-8b88-11eb-397a-4971fb64f900
md"""
And now we can define a simple network for calculating the XOR function.
"""

# ╔═╡ dc8498c0-8b81-11eb-397e-dda6619ddb03
xor_net = Sequential([
  Linear(2, 2),
  Sigmoid, # (),
  Linear(2, 1),
])

# ╔═╡ d18ce6f0-8b8d-11eb-2d5c-bd298437f953
typeof(xor_net)

# ╔═╡ 7c12872a-8b88-11eb-1de6-fd84daec8930
html"""
<p style="text-align: right;">
  <a id='loss-n-optimization'></a>
  <a href="#toc">back to TOC</a>
</p>
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

  function loss(self::SSE, ŷ::Tensor, y::Tensor)::F
    sum((ŷ .- y) .^ 2)
  end

  function ∇loss(self::AbstractLoss, ŷ::Tensor, y::Tensor)::Tensor
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

  step(::AbstractOptimizer, _l::AbstractLayer) =
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

	function step(self::GD, sl::AbstractLayer)
		## sl ≡ seq. layer
		# println()
		for (_parms, _∇parms) ∈ zip(parms(sl), ∇(sl))
			# @show "==>", size(_parms), size(_∇parms), _parms, _∇parms
			_parms[:] = _parms - self.η .* _∇parms
		end
	end
end

# ╔═╡ e19d82b4-8b8a-11eb-3c22-e788d025e8b4
md"""
###### GD with momentum

TODO...
"""

# ╔═╡ 0c1df400-8b8c-11eb-1ed2-f78b522d0ae9
# TODO

# ╔═╡ 217c035a-8b8c-11eb-3e38-6b87cec5b14d


# ╔═╡ 21614b5a-8b8c-11eb-01e9-bd2517364992


# ╔═╡ 212a4800-8b8c-11eb-0b29-659a3be01512
md"""
#### XOR example

We will use xor_net as defined above
"""

# ╔═╡ 2111ca94-8b8c-11eb-0307-d932886e4b10
begin
  ## Training data
  xs = [0. 0.; 0. 1.; 1. 0.; 1. 1.]
  ys = [0.; 1.; 1.; 0.]
end

# ╔═╡ 61904ed8-8b96-11eb-3046-331119a0dc9b
size(xs[1, :]), size(reshape(xs[1, :], 2, :)), size(ys[1, :]), size(reshape(ys[1, :], 1, 1))

# ╔═╡ 7d8504f8-8b8c-11eb-3c22-e788d025e8b4
begin
  ya_optimizer = GD(0.05)
  ya_loss = SSE();
end

# ╔═╡ 7d69f7f8-8b8c-11eb-1de6-fd84daec8930
for epoch ∈ 1:10000
	epoch_loss = 0.

	for ix ∈ 1:size(xs)[1]
		_xs, _ys = xs[ix, :], ys[ix, :]
		(x, y) = (reshape(_xs, size(_xs)[1], :), reshape(_ys, size(_ys)[1], :))
		#x, y = view(xs, ix, :), view(ys, ix, :)
		#x, y = xs[ix, :], ys[ix, :]
		ŷ = forward(xor_net, x)
		epoch_loss += loss(ya_loss, ŷ, y)	
		∇p = ∇loss(ya_loss, ŷ, y)
		backward(xor_net, ∇p)		
		step(ya_optimizer, xor_net)
    end

    epoch % 100 == 0 && (@show epoch, epoch_loss)
end

# ╔═╡ 276897b0-8c27-11eb-3046-331119a0dc9b
with_terminal() do
	for p in parms(xor_net)
		println(p)
	end
end

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
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
# ╠═23b693ca-8c21-11eb-3340-337957fd81b7
# ╠═e9a11fde-8c20-11eb-3046-331119a0dc9b
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
# ╠═d18ce6f0-8b8d-11eb-2d5c-bd298437f953
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
# ╠═217c035a-8b8c-11eb-3e38-6b87cec5b14d
# ╠═21614b5a-8b8c-11eb-01e9-bd2517364992
# ╟─212a4800-8b8c-11eb-0b29-659a3be01512
# ╠═2111ca94-8b8c-11eb-0307-d932886e4b10
# ╠═61904ed8-8b96-11eb-3046-331119a0dc9b
# ╠═7d8504f8-8b8c-11eb-3c22-e788d025e8b4
# ╠═7d69f7f8-8b8c-11eb-1de6-fd84daec8930
# ╠═276897b0-8c27-11eb-3046-331119a0dc9b
