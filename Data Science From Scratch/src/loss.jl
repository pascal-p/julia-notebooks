module Loss

export AbstractLoss, ALoss, Float, loss, ∇loss, SSE, SoftmaxXEntropy

include("./tensor_dt.jl")
using .TensorDT: Tensor

## ======================================================================
## Loss
## ======================================================================
abstract type AbstractLoss end
const ALoss = AbstractLoss
const Float = Float64

loss(::AbstractLoss, _ŷ::Tensor, _y::Tensor) = throws(ArgumentError("Not Implemented"))
∇loss(::AbstractLoss, _ŷ::Tensor, _y::Tensor) = throws(ArgumentError("Not Implemented"))

#### Sum squared Error (SSE)

struct SSE <: AbstractLoss
end

function loss(_self::SSE, ŷ::Tensor, y::Tensor)::Float
  sum((ŷ .- y) .^ 2)
end

function ∇loss(_self::SSE, ŷ::Tensor, y::Tensor)::Tensor
  2 * (ŷ .- y)
end


struct SoftmaxXEntropy <: AbstractLoss
end

function loss(_self::SoftmaxXEntropy, ŷ::Tensor, y::Tensor; ϵ=1e-20)::Float
  -sum(log.(softmax(ŷ) .+ ϵ) .* y)
end

function ∇loss(_self::SoftmaxXEntropy, ŷ::Tensor, y::Tensor)::Tensor
    softmax(ŷ) .- y
end


## Internals

#### Softmax function helper
function softmax(tensor::Tensor)::Tensor
  """Softmax along ths last dimension"""
  ## for numerical stability - subtract largest value
  exps = exp.(tensor .- maximum(tensor))
  sum_exps = sum(exps)
  exps ./ sum_exps
end

end  ## Module
