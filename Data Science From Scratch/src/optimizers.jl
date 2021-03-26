module Optimizers

export AbstractOptimizer, GD, MomentumGD, astep

include("./tensor_dt.jl")
using ..TensorDT: Tensor

include("./abstract_layers.jl")
using ..AbstractLayers: AbstractLayer, AL, forward, backward, parms, ∇parms

include("./abstract_optimizers.jl")
using ..AbstractOptimizers: AbstractOptimizer, AOpt, NAOpt


## ======================================================================
## Optimization
## ======================================================================

#### (Vanilla) Gradient Descent (GD)

struct GD <: AbstractOptimizer
  η::Float64
end

function astep(self::GD, sl::AbstractLayer)
  ## sl ≡ seq. layer
  for (_parms, _∇parms) ∈ zip(parms(sl), ∇parms(sl))
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

function astep(self::MomentumGD, sl::AbstractLayer)
  ## sl ≡ seq. layer
  length(self.updates) == 0 &&
  (self.updates = [zeros(eltype(∇p), size(∇p)) for ∇p ∈ ∇parms(sl)])
  #
  for (_upd, _parms, _∇parms) ∈ zip(self.updates, parms(sl), ∇parms(sl))
    ## apply momentum
    _upd[:] = self.α * _upd .+ (1. - self.α) * _∇parms
    ## take a step
    _parms[:] = _parms - self.η .* _upd
  end
end

end  ## Module
