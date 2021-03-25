module Optimizer

include("./tensor_dt.jl")
include("./abstract_layers.jl")

import Base: step

using .AbstractLayers: AbstractLayer
using .TensorDT: Tensor

## ======================================================================
## Optimization
## ======================================================================

abstract type AbstractOptimizer end
const AOpt = AbstractOptimizer
const NAOpt = Union{AOpt, Nothing}

step(::AbstractOptimizer, _l::AbstractLayer) = throws(ArgumentError("Not Implemented"))

#### (Vanilla) Gradient Descent (GD)

struct GD <: AbstractOptimizer
  η::Float64
end

function step(self::GD, sl::AbstractLayer)
  ## sl ≡ seq. layer
  for (_parms, _∇parms) ∈ zip(parms(sl), ∇(sl))
    _parms[:] = _parms - self.η .* _∇parms
  end
end

#### GD with momentum

mutable struct MomentumGD <: AbstractOptimizer
  η::Float64  ## learning rate
  α::Float64  ## momentum rate
  updates::Vector{Tensor}
  #
  function MomentumGD(;η=0.1, α=0.9, updates=Vector{Tensor}[])
    new(η, α, updates)
  end
end

function step(self::MomentumGD, sl::AbstractLayer)
  ## sl ≡ seq. layer
  length(self.updates) == 0 &&
  (self.updates = [zeros(eltype(∇p), size(∇p)) for ∇p ∈ ∇(sl)])
  #
  for (_upd, _parms, _∇parms) ∈ zip(self.updates, parms(sl), ∇(sl))
    ## apply momentum
    _upd[:] = self.α * _upd .+ (1. - self.α) * _∇parms
    ## take step
    _parms[:] = _parms - self.η .* _upd
  end
end

end  ## Module
