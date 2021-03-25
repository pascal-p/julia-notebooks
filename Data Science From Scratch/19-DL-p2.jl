### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 10d6d90e-8d43-11eb-216c-8f94a3946fab
begin
	push!(LOAD_PATH, "./src")
	using YaDeepLearning
end

# ╔═╡ ac463e7a-8b59-11eb-229e-db560e17c5f5
begin
	using Test
	using Random
	using Distributions
	using PlutoUI
	using Plots
	using Flux.Data.MNIST
 	using Images
end

# ╔═╡ 8c80e072-8b59-11eb-3c21-a18fe43c4536
md"""
## Deep Learning (DL) (cont'ed)

ref. from book **"Data Science from Scratch"**, Chap 19
"""

# ╔═╡ e7373726-8b59-11eb-2a2b-b5138e4f5268
html"""
<a id='toc'></a>
"""

# ╔═╡ f5ee64b2-8b59-11eb-2751-0778efd589cd
md"""
#### TOC
  - [Dropout](#dropout)
  - TBD: [MNIST](#mnist)
"""

# ╔═╡ 81290d1c-8ce2-11eb-3340-337957fd81b7
md"""
#### Dropout

Droput is a technique for regularizing neural network (to prevent overfitting). It works as follows: 
  - at training time we randomly turn off a set of neurons (by replacing their output with 0) given a fixed probability. This seems to prevent overfitting by forcing the neural network to not rely  on any particular neuron.  

  - at evaluation time, we do not drop the neurons, but we scale down the outputs (uniformly) by using the same fraction (used at training time).
"""

# ╔═╡ 8ff1bb20-8ce2-11eb-1de6-fd84daec8930
md"""
Let us define a helper function on initialize the binary mask we need to apply dorpout at training time. 
"""

# ╔═╡ d3ee2138-8ce2-11eb-0b29-659a3be01512
function prand(dt::DataType, shape::NTuple{N, Integer}; 
		proba::Float64=.5)::BitArray where {N}
  rand(dt, shape) .≥ proba
end

# ╔═╡ d3d074e4-8ce2-11eb-0307-d932886e4b10
md"""
Then let us define our dropout  layer.
"""

# ╔═╡ 13a0940e-8ce4-11eb-231c-f331a607203c
mutable struct Dropout <: AbstractLayer
	keep_prob::Float
	train::Bool
	mask::BitArray
	
	Dropout(;keep_prob=.5, train=true) = new(keep_prob, train, BitArray(undef))
end

# ╔═╡ 7794de16-8ce4-11eb-3340-337957fd81b7
function forward(self::Dropout, input::Tensor)::Tensor
	if self.train
		self.mask = prand(eltype(tenosr), size(tensor); proba=self.keep_prob)
		tensor .* mask
	else
		tensor * (1 - self.keep_prob)
	end
end

# ╔═╡ 77766f94-8ce4-11eb-3046-331119a0dc9b
function backward(self::Dropout, ∇::Tensor)::Tensor
	self.train && ∇ .* self.mask
	throws(RuntimeError("Do NOT all backward when NOT in training mode"))
end

# ╔═╡ 80ddf0f4-8ce2-11eb-3046-331119a0dc9b
html"""
<p style="text-align: right;">
  <a id='mnist'></a>
  <a href="#toc">back to TOC</a>
</p>
"""

# ╔═╡ 80a71408-8ce2-11eb-3978-75a4a2df9116
md"""
#### MNIST
"""

# ╔═╡ d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
const NROWS, NCOLS, NLABELS = 28, 28, 10

# ╔═╡ d2b198b6-8ce2-11eb-170e-0f17904c9f2c
begin
	## Load labels and images from Flux.Data.MNIST
	train_labels, train_imgs = MNIST.labels(:train), MNIST.images(:train);
	test_labels, test_imgs = MNIST.labels(:test), MNIST.images(:test)
	size(train_labels), size(train_imgs), size(test_labels), size(test_imgs)
end

# ╔═╡ d37f37b8-8ce8-11eb-2c00-3f98ca407f41
size(train_imgs[1]), size(test_imgs[1])

# ╔═╡ 394093fa-8cea-11eb-0071-eff3045a012b
plot(train_imgs[1])

# ╔═╡ 28b70680-8cf7-11eb-0b49-430feeeef599
train_labels[1]

# ╔═╡ e95983ba-8ceb-11eb-38fd-ed92cdcf754c
mosaicview(train_imgs[1:100]; nrow=5, ncol=20, npad=5)

# ╔═╡ d3a749a2-8cec-11eb-1f06-b568f244b576
md"""
Each image is  28x28 pixels, but our linear layer can only deal with one-dimensional input, therefore we need to flatten them.

We will also normalize them by dividing by 256 (the whole range for 8-bit value).
"""

# ╔═╡ 31d3226a-8cf4-11eb-0897-39989ba76b58
begin
	## reshape (flatten) and cast from Gray{Normed{UInt8,8}} to Float32
	_train_imgs = [Float32.(img) for img ∈ (reshape.(train_imgs, NROWS * NCOLS))]
	_test_imgs = [Float32.(img) for img ∈ (reshape.(test_imgs, NROWS * NCOLS))]
	
	## calc. avg
	img_avg = sum(_train_imgs) / length(_train_imgs) / (NROWS * NCOLS); 
	@assert size(_train_imgs[1]) == size(img_avg) == (NROWS * NCOLS,)
	
	## Re-center, re-scale
	λ = img -> (img .- img_avg) / 256.
	ntrain_imgs = λ.(_train_imgs); _train_imgs = nothing
	ntest_imgs = λ.(_test_imgs); _test_imgs = nothing

	## ntrain_imgs ≡ Array{Array{Float32,1},1}
	@assert size(ntrain_imgs) == size(train_imgs)
	@assert size(ntest_imgs) == size(test_imgs)
end

# ╔═╡ e9d84e5c-8cf5-11eb-044f-3341127af565
# @test abs(sum(ntrain_imgs)) ≤ 4e-3
sum(sum.(ntrain_imgs[1]))

# ╔═╡ 6e7e7896-8cf8-11eb-062e-99492ec8cff8
md"""
Let us write a one hot encoder for our 10 outputs (digits from 0 to 9)
"""

# ╔═╡ 70f707c0-8cf6-11eb-11c2-73d7b28f7a0c
function one_hot_encoder(label::Integer; nlabels=NLABELS, DT=Float64)::Tensor
	# @assert label < nlabels
	a = zeros(DT, nlabels)
	a[label + 1] = one(DT)
	a
end

# ╔═╡ 70d84470-8cf6-11eb-23b6-c7ba506d8552
begin
	@test one_hot_encoder(3) == [0., 0., 0., 1., 0., 0., 0., 0., 0., 0.]
	@test one_hot_encoder(2; nlabels=5) == [0., 0., 1., 0., 0.]
end

# ╔═╡ c451451a-8cf7-11eb-183b-e358c9d618e0
begin
	ntrain_labels = one_hot_encoder.(train_labels)
	ntest_labels = one_hot_encoder.(test_labels);
end

# ╔═╡ ebd531e6-8cf7-11eb-228f-d530e7a48151
md"""
Let adjust our (previoulsy defined) train_loop function.
"""

# ╔═╡ 30bdc788-8d01-11eb-2f8f-9fd79593ddb8
function train_loop(model::AL, imgs::AA, labels::AA, loss_fn::ALoss;
		opt_fn::NAOpt=nothing, verbose=false)
	#
	rec_loss = []
	ncorr, totloss = 0, 0.0
	for t in 1:length(imgs)
		ŷ = forward(model, imgs[t])
		y = labels[t]
		# @show ŷ, y
		## NOTE argmax => CartesianIndex
		argmax(ŷ)[1] == argmax(y) && (ncorr += 1)
		totloss += loss(loss_fn, ŷ, y)
		# @show argmax(ŷ)[1], argmax(y)
		# break
		if !isnothing(opt_fn)
			∇p = ∇loss(loss_fn, ŷ, y)
			backward(model, ∇p)
			step(opt_fn, model)
		end
		avg_loss = totloss / t
		acc = ncorr / t
		verbose && t % 1000 == 0 && (@show t, avg_loss, acc)
		push!(rec_loss, totloss)
	end
	rec_loss
end

# ╔═╡ 84946000-8d02-11eb-3160-571efee8fb0b
md"""
Let us create a baseline to train a mluticlass logistic regression (which is a single linear layer followed by a softmax). One pass through the 60000 training examples should be enough to learn the model. 
"""

# ╔═╡ 3972ef40-8d4f-11eb-3369-6dd94e7cfc13
YaDeepLearning.Layers.Linear <: YaDeepLearning.AbstractLayers.AbstractLayer

# ╔═╡ 4bae9524-8d4f-11eb-0feb-05b58077eec8
YaDeepLearning.Layers.Linear <: YaDeepLearning.AbstractLayers.AL

# ╔═╡ d05f1c40-8d17-11eb-2724-4d989c4c6b92
begin
	lr_model = Linear(NROWS * NCOLS, NLABELS)
	lr_loss = SoftmaxXEntropy()
	lr_opt = MomentumGD(;η=.01, α=.99)
end

# ╔═╡ 848fd812-8d02-11eb-01d6-75965b08bcc5
with_terminal() do
	# Train
	train_loop(lr_model, ntrain_imgs, ntrain_labels, lr_loss; 
		opt_fn=lr_opt, verbose=true)
	
	# Test model
	train_loop(lr_model, ntrain_imgs, ntrain_labels, lr_loss)
end

# ╔═╡ 440d8bc0-8d4e-11eb-042b-df4e582d28fa
Tanh

# ╔═╡ 80dff352-8d02-11eb-06b1-5f5e325046f5
begin
	dropout₁ = Dropout(;keep_prob=0.9)
	dropout₂ = Dropout(;keep_prob=0.9)

	m_model = Sequential([
		Linear(NROWS * NCOLS, 3 * NLABELS),
		dropout₁,
		Tanh(),
		Linear(3 * NLABELS, NLABELS),
		dropout₂,
		Tanh(),
		Linear(NLABELS, NLABELS)
	])

	m_loss = SoftmaxXEntropy()
	m_opt = MomentumGD(;η=.01, α=.99)

	## Train
	train_loop(m_model, ntrain_imgs, ntrain_labels, m_loss; opt_fn=m_opt)
	
	## Test
	dropout1.train = dropout2.train = false
	train_loop(m_model, ntrain_imgs, ntrain_labels, m_loss)
	
end

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╠═10d6d90e-8d43-11eb-216c-8f94a3946fab
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╟─f5ee64b2-8b59-11eb-2751-0778efd589cd
# ╟─81290d1c-8ce2-11eb-3340-337957fd81b7
# ╟─8ff1bb20-8ce2-11eb-1de6-fd84daec8930
# ╠═d3ee2138-8ce2-11eb-0b29-659a3be01512
# ╟─d3d074e4-8ce2-11eb-0307-d932886e4b10
# ╠═13a0940e-8ce4-11eb-231c-f331a607203c
# ╠═7794de16-8ce4-11eb-3340-337957fd81b7
# ╠═77766f94-8ce4-11eb-3046-331119a0dc9b
# ╟─80ddf0f4-8ce2-11eb-3046-331119a0dc9b
# ╟─80a71408-8ce2-11eb-3978-75a4a2df9116
# ╠═d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
# ╠═d2b198b6-8ce2-11eb-170e-0f17904c9f2c
# ╠═d37f37b8-8ce8-11eb-2c00-3f98ca407f41
# ╠═394093fa-8cea-11eb-0071-eff3045a012b
# ╠═28b70680-8cf7-11eb-0b49-430feeeef599
# ╠═e95983ba-8ceb-11eb-38fd-ed92cdcf754c
# ╟─d3a749a2-8cec-11eb-1f06-b568f244b576
# ╠═31d3226a-8cf4-11eb-0897-39989ba76b58
# ╠═e9d84e5c-8cf5-11eb-044f-3341127af565
# ╟─6e7e7896-8cf8-11eb-062e-99492ec8cff8
# ╠═70f707c0-8cf6-11eb-11c2-73d7b28f7a0c
# ╠═70d84470-8cf6-11eb-23b6-c7ba506d8552
# ╠═c451451a-8cf7-11eb-183b-e358c9d618e0
# ╟─ebd531e6-8cf7-11eb-228f-d530e7a48151
# ╠═30bdc788-8d01-11eb-2f8f-9fd79593ddb8
# ╟─84946000-8d02-11eb-3160-571efee8fb0b
# ╠═3972ef40-8d4f-11eb-3369-6dd94e7cfc13
# ╠═4bae9524-8d4f-11eb-0feb-05b58077eec8
# ╠═d05f1c40-8d17-11eb-2724-4d989c4c6b92
# ╠═848fd812-8d02-11eb-01d6-75965b08bcc5
# ╠═440d8bc0-8d4e-11eb-042b-df4e582d28fa
# ╠═80dff352-8d02-11eb-06b1-5f5e325046f5
