using Random, Distributions

const UVT{T} = Union{Vector{T}, Vector{Value{T}}} where {T <: AbstractFloat}

## Neuron DT
struct Neuron{T <: AbstractFloat}
  w::Vector{Value{T}}
  b::Value{T}

  function Neuron{T}(n_inp::Integer; dist=Uniform{T}(-1., 1.)) where {T <: AbstractFloat}
    @assert n_inp ≥ 1
    w = Value{T}.(rand(dist, n_inp))
    b = Value{T}(rand(dist, 1)[1])
    new(w, b)
  end

  function Neuron{Float32}(n_inp::Integer; dist=Uniform{Float32}(-1., 1.))
    @assert n_inp ≥ 1
    w = [Value{Float32}(Float32(rand(dist, n_inp)[1])) for _ ∈ 1:n_inp]
    b = Value{Float32}(Float32(rand(dist, 1)[1]))
    new(w, b)
  end
end

Neuron_f64(n_inp::Integer) = Neuron{Float64}(n_inp)

"""
    forward(...)
    eval neuron by taking the dot-product between input and weights, sum, add bias and pass it to activation function
"""
function forward(self::Neuron{T}, x::UVT{T}; act_fn=tanh) where {T <: AbstractFloat}
  # x == vector of inputs
  @assert length(self.w) >= 1 && length(self.w) == length(x)
  self.w .* x |> d -> sum(d; init=self.b) |> act_fn
end


## Layer DT
struct Layer{T <: AbstractFloat}
  neurons::Vector{Neuron{T}}

  function Layer{T}(n_inp::Integer, n_out::Integer) where {T <: AbstractFloat}
    @assert n_inp ≥ 1 && n_out ≥ 1
    vn = [Neuron{T}(n_inp) for _ ∈ 1:n_out]
    new(vn)
  end
end

function forward(self::Layer{T}, x::UVT{T}) where {T <: AbstractFloat}
  y = [forward(n, x) for n ∈ self.neurons]
  length(y) == 1 ? y[1] : y
end

parameters(self::Layer{T}) where {T <: AbstractFloat} =
  [np for n ∈ self.neurons for np ∈ parameters(n)]


## MLP DT
struct MLP{T <: AbstractFloat}
  layers::Vector{Layer{T}}

  function MLP{T}(n_inp::Integer, n_outs::Vector{<: Integer}) where {T <: AbstractFloat}
    @assert n_inp ≥ 1 && length(n_outs) ≥ 1
    sz = [n_inp, n_outs...]
    layers = [Layer{T}(sz[ix], sz[ix + 1]) for ix ∈ 1:length(n_outs)]
    new(layers)
  end
end

function forward(self::MLP{T}, x::UVT{T}) where {T <: AbstractFloat}
  for layer ∈ self.layers
    x = forward(layer, x) # mutate x
  end
  x
end
