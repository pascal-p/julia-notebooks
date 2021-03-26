module YaDeepLearning

using Random, Distributions, Flux.Data.MNIST, Images

export TensorDT
export AbstractLayers
export AbstractOptimizers
export Layers
export Optimizers
export Activations
export Initializations
export Loss
export AA

include("./tensor_dt.jl")
import .TensorDT: Tensor

include("./abstract_layers.jl")
import .AbstractLayers

include("./abstract_optimizers.jl")
import .AbstractOptimizers

include("./optimizers.jl")
import .Optimizers

include("./initializations.jl")
import .Initializations

include("./layers.jl")
import .Layers

include("./activations.jl")
import .Activations

include("./loss.jl")
import .Loss


## ======================================================================
## Const
## ======================================================================
const AA = AbstractArray


end ## Module
