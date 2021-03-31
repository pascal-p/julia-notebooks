module AbstractLayers

export AbstractLayer, AL, forward, backward, parms, ∇parms, idims, odims

include("./tensor_dt.jl")
using .TensorDT: Tensor


## ======================================================================
## The Layer Abstraction
## ======================================================================

abstract type AbstractLayer end
const AL = AbstractLayer

forward(::AbstractLayer, ::Tensor) = throw(ArgumentError("Not Implemented"))
backward(::AbstractLayer, ::Tensor) = throw(ArgumentError("Not Implemented"))
parms(::AbstractLayer) = throw(ArgumentError("Not Implemented"))
∇parms(::AbstractLayer) = throw(ArgumentError("Not Implemented"))

idims(self::AbstractLayer) = throw(ArgumentError("Not Implemented"))
odims(self::AbstractLayer) = throw(ArgumentError("Not Implemented"))

end ## Module
