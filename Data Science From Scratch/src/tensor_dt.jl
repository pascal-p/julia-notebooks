module TensorDT

using Images # Flux.Data.MNIST

export Tensor

const Tensor = Union{BitArray, Array{T}, Vector{ColorTypes.Gray{T}}} where {T <: Real}

end  ## Module
