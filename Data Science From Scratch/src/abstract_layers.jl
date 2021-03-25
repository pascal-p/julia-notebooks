module AbstractLayers

include("./tensor_dt.jl")
using .TensorDT: Tensor


## ======================================================================
## The Layer Abstraction
## ======================================================================
abstract type AbstractLayer end

const AL = AbstractLayer

### FIXME: review
forward(::AbstractLayer, ::Tensor) = throws(ArgumentError("Not Implemented"))
backward(::AbstractLayer, ::Tensor) = throws(ArgumentError("Not Implemented"))
parms(::AbstractLayer) = throws(ArgumentError("Not Implemented"))
∇(::AbstractLayer) = throws(ArgumentError("Not Implemented"))

end
