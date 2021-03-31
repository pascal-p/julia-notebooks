module TensorDT

using Images # Flux.Data.MNIST

export Tensor

# NOTE: Array{T} ≡ Vector{T} and Matrix{T}
const Tensor = Union{BitArray, Array{T}, Vector{Vector{T}}, Vector{ColorTypes.Gray{T}}} where {T <: Real}

end  ## Module
