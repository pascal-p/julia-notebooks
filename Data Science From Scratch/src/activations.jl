module Activations

include("./abstract_layers.jl")

using .AbstractLayers: AbstractLayer

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

### Sigmoid (Activation) function
const Sigmoid = let
  σ = z -> 1. ./ (1. .+ exp.(-z))
  der_σ = z -> σ(z) .* (1 .- σ(z))
  Activation(:sigmoid, σ, der_σ)
end

### Tanh (Activation) function
const Tanh = let
  tanₕ = z -> (x = exp.(z); y = exp.(-z); (x .- y) ./ (x .+ y))
  der_tanₕ = z -> 1 .- tanₕ.(z) .^ 2
  Activation(:tanh, tanₕ, der_tanₕ)
end

### ReLU (Activation) function
const ReLU = let
  relu_fn = z -> max(zero(eltype(z)), z)
  der_relu = z -> (z₀ =	zero(eltype(z)); z .< z₀ ? z₀ : one(eltype(z)))
  Activation(:relu, relu_fn, der_relu)
end

end  ## Module
