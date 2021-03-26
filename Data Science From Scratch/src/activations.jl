module Activations

export Activation, forward, backward, parms, ∇parms, Sigmoid, Tanh, ReLU

include("./tensor_dt.jl")
using ..TensorDT: Tensor

include("./abstract_layers.jl")
import ..AbstractLayers: AbstractLayer, AL, forward, backward, parms, ∇parms


## ======================================================================
## Activation Layer
## ======================================================================
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

function forward(self::Activation, input::Tensor)::Tensor
  self.store[self.name] = self.fn.(input)
  self.store[self.name]
end

function backward(self::Activation, ∇p::Tensor)::Tensor
  self.der_fn(self.store[self.name]) .* ∇p
end

parms(self::Activation) = []
∇parms(self::Activation) = []


### Sigmoid (Activation) function
function Sigmoid()
  σ = z -> 1. ./ (1. .+ exp.(-z))
  der_σ = z -> σ(z) .* (1 .- σ(z))
  Activation(:sigmoid, σ, der_σ)
end

### Tanh (Activation) function
function Tanh()
  tanₕ = z -> (x = exp.(z); y = exp.(-z); (x .- y) ./ (x .+ y))
  der_tanₕ = z -> 1 .- tanₕ.(z) .^ 2
  Activation(:tanh, tanₕ, der_tanₕ)
end

### ReLU (Activation) function
function ReLU()
  relu_fn = z -> max(zero(eltype(z)), z)
  der_relu = z -> (z₀ =	zero(eltype(z)); z .< z₀ ? z₀ : one(eltype(z)))
  Activation(:relu, relu_fn, der_relu)
end

end  ## Module
