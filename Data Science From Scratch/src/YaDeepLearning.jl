module YaDeepLearning

using Random, Distributions, Flux.Data.MNIST, Images

import Base: step

export Tensor, AA
export AbstractLayer, AL
export Linear, Sequential, forward, backward, parms, ∇
export init_rand_normal, init_rand_uniform, init_xavier
export Activation, Sigmoid, Tanh, ReLU
export AbstractLoss, ALoss, SSE, SoftmaxXEntropy, loss, ∇loss, Float
export AbstractOptimizer, AOpt, NAOpt, GD, MomentumGD, step


include("./tensor_dt.jl")
include("./abstract_layers.jl")
include("./layers.jl")
include("./initializations.jl")
include("./activations.jl")
include("./loss.jl")
include("./optimizer.jl")


using .TensorDT: Tensor
using .AbstractLayers: AbstractLayer, AL
using .Layers: Linear, Sequential, forward, backward, parms, ∇
using .Activations: Activation, Sigmoid, Tanh, ReLU
using .Initializations: init_rand_normal, init_rand_uniform, init_xavier, INIT_FNs
using .Loss: AbstractLoss, ALoss, SSE, SoftmaxXEntropy, loss, ∇loss, Float
using .Optimizer: AbstractOptimizer, AOpt, NAOpt, GD, MomentumGD, step


## ======================================================================
## Const
## ======================================================================
const AA = AbstractArray


end ## Module
