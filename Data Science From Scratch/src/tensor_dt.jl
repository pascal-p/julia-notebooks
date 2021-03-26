module TensorDT

using Images # Flux.Data.MNIST

const Tensor = Union{BitArray, Array{T}, Vector{ColorTypes.Gray{T}}} where {T <: Real}

end  ## Module
