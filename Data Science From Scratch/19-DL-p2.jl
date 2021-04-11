### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ de098278-8e74-11eb-13e3-49c1b6e06e7d
using Pkg; Pkg.activate("MLJ_env", shared=true)

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

$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ 3972ef40-8d4f-11eb-3369-6dd94e7cfc13
Layers.Linear <: AbstractLayers.AbstractLayer, Layers.Linear <: AbstractLayers.AL

# ╔═╡ 6b3c5460-8dab-11eb-3046-331119a0dc9b
# on using: using vs import and provide extension
# cf. https://towardsdatascience.com/julias-big-problem-with-namespace-996d2e9ed71e

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
               keep_proba::Float64=.5)::BitArray where {N}
	rand(dt, shape) .≥ (1. - keep_proba)
end

# ╔═╡ 13a0940e-8ce4-11eb-231c-f331a607203c
begin
	using .TensorDT: Tensor
	import .AbstractLayers: AbstractLayer, forward, backward, parms, ∇parms

	mutable struct Dropout <: AbstractLayer
		keep_prob::Float64
		train::Bool
		mask::BitArray
		_type::Symbol
		#
		Dropout(;keep_prob=.5, train=true) =
			new(keep_prob, train, BitArray(undef), :regularization)
	end

	function forward(self::Dropout, input::Tensor)::Tensor
		if self.train
			self.mask = prand(eltype(input), size(input); 
				keep_proba=self.keep_prob)
			input .* self.mask
		else
			input * self.keep_prob # (1. - )
		end
	end

	function backward(self::Dropout, ∇p::Tensor)::Tensor
		!self.train &&
			throws(RuntimeError("Do NOT all backward when NOT in training mode"))
		∇p .* self.mask
	end

	parms(_self::Dropout) = []
	∇parms(_self::Dropout) = []
end

# ╔═╡ d3d074e4-8ce2-11eb-0307-d932886e4b10
md"""
Then let us define our dropout  layer.
"""

# ╔═╡ 80ddf0f4-8ce2-11eb-3046-331119a0dc9b
html"""
<hr />
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

# ╔═╡ 5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
typeof(train_imgs[1])

# ╔═╡ 394093fa-8cea-11eb-0071-eff3045a012b
plot(train_imgs[1]), train_labels[1]

# ╔═╡ 435c4444-8dfd-11eb-24e8-5543f905f199
# sum((train_imgs[10])), 
minimum(Float32.(train_imgs[1]))

# ╔═╡ e95983ba-8ceb-11eb-38fd-ed92cdcf754c
mosaicview(train_imgs[1:100]; nrow=5, ncol=20, npad=5)

# ╔═╡ d3a749a2-8cec-11eb-1f06-b568f244b576
md"""
Each image is  28x28 pixels, but our linear layer can only deal with one-dimensional input, therefore we need to flatten them.

We will also recenter both train and test sets by using the mean calculated over the training set.
"""

# ╔═╡ 31d3226a-8cf4-11eb-0897-39989ba76b58
begin
	## reshape (flatten) and cast from Gray{Normed{UInt8,8}} to Float32
	_train_imgs = [Float32.(img) for img ∈ (reshape.(train_imgs, NROWS * NCOLS))]
	_test_imgs = [Float32.(img) for img ∈ (reshape.(test_imgs, NROWS * NCOLS))]

	## calc. avg
	img_avg = Float32.(sum(_train_imgs) / length(_train_imgs) / (NROWS * NCOLS))
	@assert size(_train_imgs[1]) == size(img_avg) == (NROWS * NCOLS,)

	## Re-center, re-scale
	λ = img -> Float32.(img .- img_avg) 
	ntrain_imgs = λ.(_train_imgs); _train_imgs = nothing
	ntest_imgs = λ.(_test_imgs); _test_imgs = nothing

  	## ntrain_imgs ≡ Array{Array{Float32,1},1}
	@assert size(ntrain_imgs) == size(train_imgs)
	@assert size(ntest_imgs) == size(test_imgs)
end

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
	ntrain_labels[1:3]
end

# ╔═╡ ebd531e6-8cf7-11eb-228f-d530e7a48151
md"""
Let adjust our (previoulsy defined) train_loop function.
"""

# ╔═╡ 30bdc788-8d01-11eb-2f8f-9fd79593ddb8
begin

const AL, ALoss, NAOpt = AbstractLayers.AL, Loss.ALoss, AbstractOptimizers.NAOpt

function train_loop(model::AL, imgs::AA, labels::AA, loss_fn::ALoss;
    epochs=1, opt_fn::NAOpt=nothing, verbose=false)
	#
	rec_avg_loss, rec_acc = [], []
	ncorr, totloss = 0, 0.0
	#
	for e ∈ 1:epochs, t in 1:length(imgs)
		ŷ = Layers.forward(model, imgs[t])
		y = labels[t]
		## NOTE argmax => CartesianIndex
		argmax(ŷ)[1] == argmax(y) && (ncorr += 1)
		totloss += Loss.loss(loss_fn, ŷ, y)
		#
		if !isnothing(opt_fn)
			∇p = Loss.∇loss(loss_fn, ŷ, y)
			Layers.backward(model, ∇p)
			Optimizers.astep(opt_fn, model)
		end
		avg_loss = totloss / (e * t)
		acc = ncorr / (e * t)
		verbose && t % 5000 == 0 && (@show "$(e)/$(t)", avg_loss, acc)
		push!(rec_avg_loss, avg_loss)
		push!(rec_acc, acc)
	end
	(rec_avg_loss, rec_acc)
end

end

# ╔═╡ 84946000-8d02-11eb-3160-571efee8fb0b
md"""
Let us create a baseline to train a mluticlass logistic regression (which is a single linear layer followed by a softmax). One pass through the 60000 training examples should be enough to learn the model.
"""

# ╔═╡ d05f1c40-8d17-11eb-2724-4d989c4c6b92
begin
	lr_model = Layers.Linear(NROWS * NCOLS, NLABELS)
	lr_loss = Loss.SoftmaxXEntropy()
	lr_opt = Optimizers.MomentumGD(;η=.01, α=.99)
end

# ╔═╡ 848fd812-8d02-11eb-01d6-75965b08bcc5
with_terminal() do
	# Train
	global (tr1_avg_loss, tr1_acc) = train_loop(lr_model, ntrain_imgs, ntrain_labels,
		lr_loss; opt_fn=lr_opt, verbose=true)

	# Test model
	global (te1_avg_loss, te1_acc) = train_loop(lr_model, ntrain_imgs, ntrain_labels,		lr_loss)
	# rouglhy 90% of accuracy
end

# ╔═╡ 7d35f85e-8e07-11eb-228c-81d28a444b52
begin
	ntr, nte = 60_000, 10_000
	lg1 = grid(2, 1, heights=[0.5, 0.5])
	a = plot(tr1_avg_loss[1:ntr], label="train avg loss", leg=:bottomright)
	b = plot(tr1_acc[1:ntr], label="train acc.")
	plot(a, b, layout=lg1)
end

# ╔═╡ 6e7c18b4-8e09-11eb-0238-2515d39a89cd
begin
	lg2 = grid(2, 1, heights=[0.5, 0.5])
	a₂ = plot(te1_avg_loss[1:nte], label="test avg loss", leg=:bottomright)
	b₂ = plot(te1_acc[1:nte], label="test acc.")
	plot(a₂, b₂, layout=lg2)
end

# ╔═╡ 40d46802-8e0f-11eb-2e47-53096e24dbd8
md"""
And now let us define and train our neural network 
"""

# ╔═╡ 80dff352-8d02-11eb-06b1-5f5e325046f5
begin
	dropout₁ = Dropout(;keep_prob=0.9)
	dropout₂ = Dropout(;keep_prob=0.8)

	m_model = Layers.Sequential([
		Layers.Linear(NROWS * NCOLS, 3 * NLABELS),
		dropout₁,
		Activations.Tanh(),
		Layers.Linear(3 * NLABELS, NLABELS),
		dropout₂,
		Activations.Tanh(),
		Layers.Linear(NLABELS, NLABELS)
	])
	m_loss = Loss.SoftmaxXEntropy()
	m_opt = Optimizers.MomentumGD(;η=.01, α=.99)
	with_terminal() do
		## Train
		global (tr_avg_loss, tr_acc) = train_loop(m_model, ntrain_imgs, 
			ntrain_labels, m_loss; epochs=5, opt_fn=m_opt)

		## Test
		dropout₁.train = dropout₂.train = false
		global (te_avg_loss, te_acc) = train_loop(m_model, ntrain_imgs, 
			ntrain_labels, m_loss, verbose=true)
	end
end

# ╔═╡ f1af4256-8e02-11eb-0238-2515d39a89cd
begin
	## 2 epochs for training...
	x₁ = plot(tr_avg_loss[1:ntr], label="train avg loss", leg=:bottomright)
	x₂ = plot(tr_avg_loss[ntr+1:end], label="train avg loss", leg=:bottomright)
	
	y₁ = plot(tr_acc[1:ntr], label="train acc.", leg=:bottomright)
	y₂ = plot(tr_acc[ntr+1:end], label="train acc.")
	plot(x₁, x₂, y₁, y₂, layout=(2, 2))
end

# ╔═╡ 43a52692-8e10-11eb-2043-8f0be195f58a
begin
	x₃ = plot(te_avg_loss[1:ntr], label="test1 avg loss", leg=:bottomright)
	y₃ = plot(te_acc[1:ntr], label="test2 acc.", leg=:bottomright)
	plot(x₃, y₃, layout=(2, 1))
end

# ╔═╡ Cell order:
# ╟─8c80e072-8b59-11eb-3c21-a18fe43c4536
# ╠═de098278-8e74-11eb-13e3-49c1b6e06e7d
# ╠═ac463e7a-8b59-11eb-229e-db560e17c5f5
# ╠═10d6d90e-8d43-11eb-216c-8f94a3946fab
# ╠═3972ef40-8d4f-11eb-3369-6dd94e7cfc13
# ╠═6b3c5460-8dab-11eb-3046-331119a0dc9b
# ╟─e7373726-8b59-11eb-2a2b-b5138e4f5268
# ╟─f5ee64b2-8b59-11eb-2751-0778efd589cd
# ╟─81290d1c-8ce2-11eb-3340-337957fd81b7
# ╟─8ff1bb20-8ce2-11eb-1de6-fd84daec8930
# ╠═d3ee2138-8ce2-11eb-0b29-659a3be01512
# ╟─d3d074e4-8ce2-11eb-0307-d932886e4b10
# ╠═13a0940e-8ce4-11eb-231c-f331a607203c
# ╟─80ddf0f4-8ce2-11eb-3046-331119a0dc9b
# ╟─80a71408-8ce2-11eb-3978-75a4a2df9116
# ╠═d1ed1e36-8ce5-11eb-34ee-4db60fb0db8a
# ╠═d2b198b6-8ce2-11eb-170e-0f17904c9f2c
# ╠═d37f37b8-8ce8-11eb-2c00-3f98ca407f41
# ╠═5bf7729e-8dfd-11eb-070f-9b7ec0746bd7
# ╠═394093fa-8cea-11eb-0071-eff3045a012b
# ╠═435c4444-8dfd-11eb-24e8-5543f905f199
# ╠═e95983ba-8ceb-11eb-38fd-ed92cdcf754c
# ╟─d3a749a2-8cec-11eb-1f06-b568f244b576
# ╠═31d3226a-8cf4-11eb-0897-39989ba76b58
# ╟─6e7e7896-8cf8-11eb-062e-99492ec8cff8
# ╠═70f707c0-8cf6-11eb-11c2-73d7b28f7a0c
# ╠═70d84470-8cf6-11eb-23b6-c7ba506d8552
# ╠═c451451a-8cf7-11eb-183b-e358c9d618e0
# ╟─ebd531e6-8cf7-11eb-228f-d530e7a48151
# ╠═30bdc788-8d01-11eb-2f8f-9fd79593ddb8
# ╟─84946000-8d02-11eb-3160-571efee8fb0b
# ╠═d05f1c40-8d17-11eb-2724-4d989c4c6b92
# ╠═848fd812-8d02-11eb-01d6-75965b08bcc5
# ╠═7d35f85e-8e07-11eb-228c-81d28a444b52
# ╠═6e7c18b4-8e09-11eb-0238-2515d39a89cd
# ╟─40d46802-8e0f-11eb-2e47-53096e24dbd8
# ╠═80dff352-8d02-11eb-06b1-5f5e325046f5
# ╠═f1af4256-8e02-11eb-0238-2515d39a89cd
# ╠═43a52692-8e10-11eb-2043-8f0be195f58a
